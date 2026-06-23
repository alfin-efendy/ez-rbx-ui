local h = require("tests.helper")
local R = h.loadLib()
local Label, Create = R.Label, R.Create

h.describe("label", function()
  h.it("default label shows text in foreground", function()
    local p = Create("Frame", {})
    local l = Label.new({ Parent = p, Text = "Hello", LayoutOrder = 1 })
    h.expect(l.Frame.Text).toBe("Hello")
    h.expect(l.Frame.TextColor3.R8).toBe(250)
    h.expect(l.Frame.Parent).toBe(p)
  end)
  h.it("section variant is uppercased muted", function()
    local l = Label.new({ Text = "General", Variant = "section" })
    h.expect(l.Frame.Text).toBe("GENERAL")
    h.expect(l.Frame.TextColor3.R8).toBe(161)  -- mutedForeground
  end)
  h.it("paragraph wraps; SetText updates", function()
    local l = Label.new({ Text = "a", Variant = "paragraph" })
    h.expect(l.Frame.TextWrapped).toBe(true)
    l.SetText("b"); h.expect(l.Frame.Text).toBe("b")
  end)
  h.it("SetText defers the GUI write when capability is absent", function()
    local R = h.loadLib(); local screen = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(screen)
    local lbl = R.Label.new({ Text = "init", Parent = R.Create("Frame", {}) })
    R.Safe._setCapabilityCheck(function() return false end)
    lbl.SetText("updated")
    h.expect(lbl.Frame.Text).toBe("init")     -- deferred: not applied yet
    h.mock.stepHeartbeat(0)
    h.expect(lbl.Frame.Text).toBe("updated")  -- applied in a capability context
    R.Safe._setCapabilityCheck(nil)
  end)
  h.it("a yielding source does not block construction or error; it lands on a later non-yielding tick", function()
    -- In Luau pcall is yieldable, so a source that yields (e.g. a RemoteFunction:InvokeServer getter)
    -- used to STALL Label.new -- which stalled UI construction and stopped every later control from
    -- being created. The poll must isolate the yield and never block.
    local p = Create("Frame", {})
    local phase = "yield"
    local src = function()
      if phase == "yield" then coroutine.yield() end   -- simulate an async getter on the first call
      return "ready"
    end
    local l = Label.new({ Parent = p, Text = src, Interval = 1 })
    h.expect(l.Frame.Text).toBe("")        -- first eval yielded -> not applied, but did NOT block/throw
    phase = "ready"                         -- source no longer yields (value now cached)
    h.mock.stepHeartbeat(1)                 -- next tick completes synchronously -> applies
    h.expect(l.Frame.Text).toBe("ready")
    l.Destroy()
  end)
  h.it("reactive poll is capability-safe: defers its write instead of a direct GUI write on the Heartbeat thread", function()
    -- Some executors' Heartbeat handlers LACK the GUI capability; a direct write there throws
    -- "lacking capability Plugin" every interval (and aborted the whole scheduler). The poll must
    -- route through Safe.mutate, exactly like SetText, so it degrades quietly.
    local R = h.loadLib(); local screen = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(screen)
    local n = 0
    local l = R.Label.new({ Parent = R.Create("Frame", {}), Text = function() n = n + 1; return "v" .. n end, Interval = 1 })
    h.expect(l.Frame.Text).toBe("v1")          -- initial render (at construction, on a capability thread)
    R.Safe._setCapabilityCheck(function() return false end)
    h.mock.stepHeartbeat(1)                     -- interval reached -> tick re-evaluates
    h.expect(l.Frame.Text).toBe("v1")          -- write DEFERRED (Safe.mutate), NOT a direct write
    h.mock.stepHeartbeat(0)                     -- flushed in a capability-bearing context
    h.expect(l.Frame.Text).toBe("v2")
    R.Safe._setCapabilityCheck(nil)
    l.Destroy()
  end)
end)

h.describe("reactive label (function-valued, auto-updating text)", function()
  h.it("a function Text renders its initial value immediately", function()
    local p = Create("Frame", {})
    local l = Label.new({ Parent = p, Text = function() return "now" end })
    h.expect(l.Frame.Text).toBe("now")
    l.Destroy()
  end)

  h.it("a function Text re-evaluates every Interval on the Heartbeat", function()
    local p = Create("Frame", {})
    local n = 0
    local l = Label.new({ Parent = p, Text = function() n = n + 1; return "tick " .. n end, Interval = 1 })
    h.expect(l.Frame.Text).toBe("tick 1")          -- initial eval
    h.mock.stepHeartbeat(0.5); h.expect(l.Frame.Text).toBe("tick 1")   -- sub-interval: no update
    h.mock.stepHeartbeat(0.5); h.expect(l.Frame.Text).toBe("tick 2")   -- acc reached interval: update
    l.Destroy()
  end)

  h.it("SetText(function) makes a static label reactive and evaluates immediately", function()
    local p = Create("Frame", {})
    local l = Label.new({ Parent = p, Text = "static" })
    h.expect(l.Frame.Text).toBe("static")
    local n = 0
    l.SetText(function() n = n + 1; return "dyn " .. n end)
    h.expect(l.Frame.Text).toBe("dyn 1")           -- immediate eval on switch
    h.mock.stepHeartbeat(1); h.expect(l.Frame.Text).toBe("dyn 2")
    l.Destroy()
  end)

  h.it("SetText(string) freezes a reactive label (stops polling)", function()
    local p = Create("Frame", {})
    local n = 0
    local l = Label.new({ Parent = p, Text = function() n = n + 1; return "d " .. n end, Interval = 1 })
    l.SetText("frozen")
    h.expect(l.Frame.Text).toBe("frozen")
    h.mock.stepHeartbeat(1); h.expect(l.Frame.Text).toBe("frozen")     -- no longer polling
    l.Destroy()
  end)

  h.it("an error in the function keeps the last good value (no flicker)", function()
    local p = Create("Frame", {})
    local boom = false
    local l = Label.new({ Parent = p, Text = function() if boom then error("x") end return "good" end, Interval = 1 })
    h.expect(l.Frame.Text).toBe("good")
    boom = true
    h.mock.stepHeartbeat(1); h.expect(l.Frame.Text).toBe("good")       -- unchanged on error
    l.Destroy()
  end)

  h.it("Destroy deregisters the label so it stops being evaluated", function()
    local p = Create("Frame", {})
    local n = 0
    local l = Label.new({ Parent = p, Text = function() n = n + 1; return tostring(n) end, Interval = 1 })
    h.expect(n).toBe(1)
    l.Destroy()
    h.mock.stepHeartbeat(1); h.expect(n).toBe(1)                       -- not evaluated after Destroy
  end)
end)

h.run()
