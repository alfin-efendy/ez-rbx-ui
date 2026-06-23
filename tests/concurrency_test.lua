-- Verifies EzUI's capability-safe dispatch (Safe.mutate) holds when the UI is driven
-- from NON-MAIN threads — asymmetric coroutine, symmetric coroutines (trampoline
-- transfer), and task.spawn. The headless mock has no Roblox capability model, so we
-- force the no-capability path with Safe._setCapabilityCheck(false): GUI writes must be
-- deferred to the Heartbeat (applied on h.mock.stepHeartbeat) while state stays sync.
-- Mirror of example/stress.lua's Concurrency tab.
local h = require("tests.helper")

local function setup()
  local R = h.loadLib()
  R.Safe._setCapabilityCheck(nil)            -- start each test on the default (inline) probe
  local screen = h.roblox.Instance.new("ScreenGui")
  R.Overlay.get(screen)
  local w = R.Window.new({ Title = "Conc", Parent = screen })
  local tab = w:AddTab({ Name = "T" })
  return R, w, tab
end

h.describe("concurrency (capability-safe dispatch from non-main threads)", function()
  h.it("asymmetric coroutine: yielded ticks defer their GUI writes, then land in FIFO order", function()
    local R, _, tab = setup()
    local label = tab:AddLabel("idle")
    R.Safe._setCapabilityCheck(function() return false end)
    -- generator that mutates the UI then yields control back to the resumer
    local co = coroutine.create(function()
      for n = 1, 3 do label.SetText("asym " .. n); coroutine.yield() end
    end)
    coroutine.resume(co); coroutine.resume(co); coroutine.resume(co)  -- drive 3 ticks
    h.expect(label.Frame.Text).toBe("idle")        -- all three writes deferred, nothing applied yet
    h.mock.stepHeartbeat(0)                          -- flush the FIFO queue in a capability context
    h.expect(label.Frame.Text).toBe("asym 3")       -- replayed in order; last write wins
    R.Safe._setCapabilityCheck(nil)
  end)

  h.it("symmetric coroutines: trampoline transfer (A⇄B) defers then lands", function()
    local R, _, tab = setup()
    local label = tab:AddLabel("idle")
    R.Safe._setCapabilityCheck(function() return false end)
    local a, b, current
    a = coroutine.create(function() while true do label.SetText("A->B"); current = b; coroutine.yield() end end)
    b = coroutine.create(function() while true do label.SetText("B->A"); current = a; coroutine.yield() end end)
    current = a
    for _ = 1, 3 do coroutine.resume(current) end   -- relays A, then B, then A
    h.expect(label.Frame.Text).toBe("idle")          -- deferred
    h.mock.stepHeartbeat(0)
    h.expect(label.Frame.Text).toBe("A->B")          -- 3rd transfer ran A again
    R.Safe._setCapabilityCheck(nil)
  end)

  h.it("task.spawn: state stays synchronous, GUI write defers to the Heartbeat", function()
    local R, _, tab = setup()
    local label = tab:AddLabel("idle")
    local bar = tab:AddProgressBar({ Default = 0 })
    R.Safe._setCapabilityCheck(function() return false end)
    h.roblox.task.spawn(function()
      for n = 1, 4 do label.SetText("spawn " .. n); bar.Set(n / 4) end
    end)
    h.expect(bar.Get()).toBe(1)                      -- value (state) updated synchronously
    h.expect(label.Frame.Text).toBe("idle")          -- GUI write deferred
    h.mock.stepHeartbeat(0)
    h.expect(label.Frame.Text).toBe("spawn 4")
    R.Safe._setCapabilityCheck(nil)
  end)

  h.it("notifications fired from a coroutine defer the toast but reserve the id synchronously", function()
    local R, w, tab = setup()
    local ov = R.Overlay.get(w.Gui)
    R.Notification.clearAll()
    R.Safe._setCapabilityCheck(function() return false end)
    local id
    local co = coroutine.create(function() id = w:ShowInfo({ Title = "C", Duration = 0 }) end)
    coroutine.resume(co)
    h.expect(type(id)).toBe("number")                -- id reserved synchronously even off-thread
    h.expect(R.Notification.count()).toBe(1)
    local function toasts() local n = 0 for _, c in ipairs(ov:GetChildren()) do
      if c.Name == "ToastContainer" then for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then n = n + 1 end end end
    end return n end
    h.expect(toasts()).toBe(0)                        -- toast GUI deferred
    h.mock.stepHeartbeat(0)
    h.expect(toasts()).toBe(1)                        -- built in a capability context
    R.Safe._setCapabilityCheck(nil)
    R.Notification.clearAll()
  end)

  h.it("inline path: with capability present the same patterns apply immediately (no Heartbeat)", function()
    local R, _, tab = setup()
    local label = tab:AddLabel("idle")               -- default probe succeeds in the mock -> inline
    h.roblox.task.spawn(function() label.SetText("inline") end)
    h.expect(label.Frame.Text).toBe("inline")
  end)
end)

h.run()
