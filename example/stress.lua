-- Require the BUILT bundle (run `make build` first / `make stress` does it).
local EzUI = require("../output/bundle")

local window = EzUI:CreateWindow({
  Title = "EzUI Stress Test",
  Ratio = { Width = 0.4, Height = 0.55 },
  Transparency = 0.12,
  FloatingToggle = { Type = "simple", AutoHide = true },
  Config = { FileName = "EzUIStress", AutoSave = false },
})

local function buildTab(tab, i)
  tab:AddSection("Controls")
  tab:AddParagraph("Every control type, mounted via the host mixin.")
  tab:AddToggle({ Text = "Enable " .. i, Default = (i % 2 == 0), Flag = "enable_" .. i, Tooltip = "Toggles feature " .. i })
  tab:AddSlider({ Text = "Speed", Min = 0, Max = 100, Default = 50, Flag = "speed_" .. i })
  tab:AddNumberBox({ Text = "Amount", Default = 10, Min = 0, Max = 100, Flag = "amount_" .. i })
  tab:AddSelectBox({ Text = "Mode", Options = { "Alpha", "Beta", "Gamma" }, Default = "Alpha", Flag = "mode_" .. i })
  tab:AddKeybind({ Text = "Hotkey", Default = Enum.KeyCode.E, Flag = "key_" .. i,
    Callback = (i == 1) and function() window:ShowSuccess({ Title = "Hotkey", Message = "Bound key pressed." }) end or nil })
  tab:AddColorPicker({ Text = "ESP Color", Default = Color3.fromRGB(255, 80, 80), Flag = "color_" .. i })
  tab:AddProgressBar({ Default = 0.4 })
  tab:AddTextBox({ Text = "Key", Default = "ABC-123", Copyable = true })
  tab:AddTable({ Columns = { "Player", "Score" }, Rows = { { "Alpha", "120" }, { "Beta", "98" } } })
  tab:AddButton({ Text = "Save", Variant = "default", Icon = "check", Callback = function()
    window:ShowSuccess({ Title = "Saved", Message = "Settings persisted." })
  end })
  tab:AddSeparator()
  tab:AddButton({ Text = "Reset to Defaults", Variant = "destructive", Action = "ResetConfig" })

  for j = 1, 8 do
    local acc = tab:AddAccordion({ Title = "Accordion " .. j, Icon = "settings-2", Expanded = (j == 1) })
    acc:AddToggle({ Text = "Feature " .. j, Default = false })
    acc:AddSlider({ Text = "Level", Min = 1, Max = 10, Default = 3 })
  end
end

local mainGroup = window:AddTabGroup("Main")
for i = 1, 10 do buildTab(mainGroup:AddTab({ Name = "Tab " .. i, Icon = "home" }), i) end

local extraGroup = window:AddTabGroup("Extra")
for i = 11, 20 do buildTab(extraGroup:AddTab({ Name = "Tab " .. i, Icon = "star" }), i) end

-- ───────────────────────────────────────────────────────────────────────────
-- Concurrency stress: drive EzUI from NON-MAIN threads, which lack the Roblox
-- "Plugin" capability. EzUI's capability-safe dispatch (Safe.mutate) must keep
-- these from throwing "lacking capability Plugin" while still updating the UI
-- (the GUI write lands on the next Heartbeat; state/values stay synchronous).
-- This tab IS the manual acceptance test for coroutine/task.spawn safety.
local function buildConcurrencyTab(tab)
  tab:AddSection("Capability-safe concurrency")
  tab:AddParagraph("Each toggle drives EzUI from a thread that lacks the 'Plugin' capability. "
    .. "Before capability-safe dispatch these threw 'lacking capability Plugin'; now they update live.")

  -- 1) ASYMMETRIC coroutine: the classic model — the coroutine yields control
  --    BACK to whoever resumed it. A driver loop resumes it once per tick; the
  --    coroutine itself mutates the UI (on the coroutine thread) before yielding.
  tab:AddSection("Asymmetric coroutine (yield ⇄ resume)")
  local asymLabel = tab:AddLabel("idle")
  local asymBar = tab:AddProgressBar({ Default = 0 })
  local asymOn, asymCo = false, nil
  tab:AddToggle({ Text = "Run asymmetric", Default = false, Callback = function(on)
    asymOn = on
    if not on then return end
    asymCo = coroutine.create(function()
      local n = 0
      while true do
        n = n + 1
        asymLabel.SetText("asymmetric: tick " .. n)   -- GUI mutation on the coroutine thread
        asymBar.Set((n % 20) / 20)
        if n % 5 == 0 then window:ShowInfo({ Title = "Asymmetric", Message = "tick " .. n, Duration = 1500 }) end
        coroutine.yield()                              -- hand control back to the resumer
      end
    end)
    task.spawn(function()                              -- driver: resume the generator each tick
      while asymOn and coroutine.status(asymCo) ~= "dead" do
        coroutine.resume(asymCo)
        task.wait(0.5)
      end
    end)
  end })

  -- 2) SYMMETRIC coroutines: control transfers DIRECTLY from one coroutine to the
  --    other (no "return to resumer"). Lua's primitives are asymmetric, so we
  --    emulate symmetric transfer with a trampoline: each coroutine names who runs
  --    NEXT (symCurrent) and yields; the driver just relays to the named one.
  tab:AddSection("Symmetric coroutines (A ⇄ B transfer)")
  local symLabel = tab:AddLabel("idle")
  local symOn, symA, symB, symCurrent = false, nil, nil, nil
  tab:AddToggle({ Text = "Run symmetric", Default = false, Callback = function(on)
    symOn = on
    if not on then return end
    local round = 0
    symA = coroutine.create(function()
      while true do
        round = round + 1
        symLabel.SetText("symmetric: A → B (round " .. round .. ")")
        symCurrent = symB                              -- transfer control to B
        coroutine.yield()
      end
    end)
    symB = coroutine.create(function()
      while true do
        symLabel.SetText("symmetric: B → A")
        symCurrent = symA                              -- transfer control back to A
        coroutine.yield()
      end
    end)
    symCurrent = symA
    task.spawn(function()                              -- trampoline: relay to the active coroutine
      while symOn do
        coroutine.resume(symCurrent)
        task.wait(0.6)
      end
    end)
  end })

  -- 3) task.spawn: a detached background loop on the Roblox task scheduler.
  tab:AddSection("task.spawn (background loop)")
  local spawnLabel = tab:AddLabel("idle")
  local spawnBar = tab:AddProgressBar({ Default = 0 })
  local spawnOn = false
  tab:AddToggle({ Text = "Run task.spawn", Default = false, Callback = function(on)
    spawnOn = on
    if not on then return end
    task.spawn(function()
      local n = 0
      while spawnOn do
        n = n + 1
        spawnLabel.SetText("task.spawn: iteration " .. n)
        spawnBar.Set((n % 10) / 10)
        if n % 4 == 0 then window:ShowInfo({ Title = "task.spawn", Message = "bg loop " .. n, Duration = 1500 }) end
        task.wait(0.7)
      end
    end)
  end })
end

local concGroup = window:AddTabGroup("Concurrency")
buildConcurrencyTab(concGroup:AddTab({ Name = "Threads", Icon = "activity" }))

window:ShowInfo({ Title = "Welcome", Message = "EzUI stress test loaded. Open Concurrency → Threads.", Duration = 5000 })
