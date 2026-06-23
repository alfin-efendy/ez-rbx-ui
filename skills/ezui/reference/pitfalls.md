# EzUI Pitfalls — Do / Don't

Common mistakes and v2→v3 migration guide.

---

## v2 → v3 Migration

### Window creation

| v2 | v3 |
|---|---|
| `EzUI:CreateNew({ Name = "My Hub" })` | `EzUI:CreateWindow({ Title = "My Hub" })` |
| `Size = { Width = 800, Height = 500 }` (pixels) | `Ratio = { Width = 0.4, Height = 0.55 }` (fraction of the viewport; auto-fits) |
| `Icon = "🏠"` (emoji) | `Icon = "home"` (Lucide name) |
| `window:ShowNotification(...)` | `Window:Notify(...)` or `Window:ShowSuccess/ShowWarning/ShowError/ShowInfo(...)` |

### Controls (mostly unchanged)

`AddLabel`, `AddButton`, `AddToggle`, `AddTextBox`, `AddNumberBox`, `AddSelectBox`, and `AddSeparator` keep the same names in v3.

New in v3 (no v2 equivalent): `AddSlider`, `AddKeybind`, `AddColorPicker`, `AddImage`, `AddProgressBar`, `AddTable`, `AddCard`, `AddResizable`, `AddAccordion`, `AddTabGroup`, sidebar search, `Dialog`, `ResetConfiguration`.

### Colors

| v2 | v3 |
|---|---|
| `Colors` module (`utils/colors`) | `EzUI.Theme` tokens and the `Theme` override key in `CreateWindow` |

---

## Layout — never touch Position / Size on controls

**Don't:**
```lua
-- WRONG: manually positioning a control
local toggle = tab:AddToggle({ Text = "Option" })
toggle.Frame.Position = UDim2.new(0, 10, 0, 50)   -- breaks layout
toggle.Frame.Size     = UDim2.new(0, 200, 0, 30)  -- breaks layout
```

**Do:**
```lua
-- Correct: EzUI uses UIListLayout + AutomaticSize + UIFlex internally.
-- Just add controls in order; the engine stacks them automatically.
tab:AddToggle({ Text = "Option A" })
tab:AddToggle({ Text = "Option B" })
```

The layout engine is fully engine-driven. Never set `Position`, `Size`, `AnchorPoint`, or `LayoutOrder` on controls.

---

## Controls must attach to a tab or accordion — never a raw frame

**Don't:**
```lua
-- WRONG: attaching to a raw ScreenGui / Frame
local frame = Instance.new("Frame", game.Players.LocalPlayer.PlayerGui)
frame:AddToggle({ ... })  -- AddToggle does not exist on a raw Instance
```

**Do:**
```lua
-- Correct: always get a host from Window:AddTab or host:AddAccordion
local tab = Window:AddTab({ Name = "Home", Icon = "home" })
tab:AddToggle({ Text = "Auto Farm" })

-- Or nest inside an accordion on that tab
local acc = tab:AddAccordion({ Title = "Advanced", Icon = "settings-2" })
acc:AddToggle({ Text = "Nested option" })
```

---

## Icons are Lucide names — never emoji

**Don't:**
```lua
Window:AddTab({ Name = "Home", Icon = "🏠" })   -- emoji — silently broken or ignored
tab:AddButton({ Text = "Run", Icon = "▶" })       -- emoji — same problem
```

**Do:**
```lua
Window:AddTab({ Name = "Home", Icon = "home" })   -- Lucide name
tab:AddButton({ Text = "Run", Icon = "play" })    -- Lucide name
```

See `reference/icons.md` for valid names and search tips.

---

## Flags do nothing without `Config = { Enabled = true }` AND executor file functions

**Don't:**
```lua
-- WRONG: Flag is set but no Config — value is not saved or restored
local Window = EzUI:CreateWindow({ Title = "My Hub" })
local tab = Window:AddTab({ Name = "Settings", Icon = "settings-2" })
tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false })
-- "autofarm" will never persist between sessions
```

**Do:**
```lua
-- Correct: enable Config so flags persist
local Window = EzUI:CreateWindow({
    Title  = "My Hub",
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})
local tab = Window:AddTab({ Name = "Settings", Icon = "settings-2" })
tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false })
-- Now "autofarm" is saved on change and restored on startup
```

Also required: the executor must provide `writefile`, `readfile`, `isfile`, `isfolder`, and `makefolder`. Without them the UI still works, but values won't persist between sessions.

---

## Callbacks receive the new value — not the control

**Don't:**
```lua
-- WRONG: expecting the control handle as the callback argument
tab:AddToggle({ Text = "Option", Callback = function(control)
    print(control.Get())  -- control is not the argument; this is the boolean value
end })
```

**Do:**
```lua
-- Correct: the argument IS the new value
tab:AddToggle({ Text = "Option", Callback = function(on)
    print("New value:", on)  -- on is true or false
end })

tab:AddSlider({ Text = "Speed", Min = 0, Max = 100, Callback = function(v)
    print("New speed:", v)   -- v is a number
end })

tab:AddSelectBox({ Text = "Mode", Options = {"A","B"}, Callback = function(val)
    print("Selected:", val)  -- val is the selected Value string
end })
```

---

## Don't invent options — only documented ones exist

**Don't:**
```lua
-- WRONG: none of these options exist in the documented API
tab:AddToggle({
    Text     = "Option",
    Size     = UDim2.new(1, 0, 0, 40),  -- no Size option
    Color    = Color3.new(1, 0, 0),      -- no Color option on Toggle
    Rounded  = true,                     -- no Rounded option
    OnHover  = function() end,           -- no OnHover option
})

tab:AddButton({
    Text    = "Run",
    Width   = 200,         -- no Width option
    Height  = 40,          -- no Height option
    OnHover = function() end,
})
```

**Do:**
```lua
-- Only use options listed in reference/controls.md and reference/window.md.
tab:AddToggle({ Text = "Option", Default = false, Flag = "opt",
    Description = "Optional helper text.", Callback = function(on) print(on) end })

tab:AddButton({ Text = "Run", Variant = "default", Icon = "play",
    Callback = function() end })
```

When in doubt, read the relevant section in `reference/controls.md` before adding an option.

---

## Call syntax: dot-call for simple controls, colon for window/accordion/tab

**Don't:**
```lua
-- WRONG: using colon syntax on a simple-control return handle
local t = tab:AddToggle({ Text = "A" })
t:Set(true)   -- errors: t is not a userdata/object with colon methods

local acc = tab:AddAccordion({ Title = "B" })
acc.Expand()  -- errors: Expand is a colon method
```

**Do:**
```lua
-- Simple control handles (Toggle, Slider, SelectBox, TextBox, …) — dot-call:
local t  = tab:AddToggle({ Text = "A" })
t.Set(true)
t.Get()         -- returns boolean

local s  = tab:AddSlider({ Text = "Speed", Min = 0, Max = 100 })
s.SetValue(50)

-- Accordion and Window — colon-call (they are full objects):
local acc = tab:AddAccordion({ Title = "Advanced" })
acc:Expand()
acc:AddToggle({ Text = "Nested" })

Window:Show()
Window:Hide()
Window:ResetConfiguration()
```

---

## `Ratio` replaces the old `Size` table (and is now a viewport fraction, not pixels or an aspect ratio)

**Don't:**
```lua
-- WRONG: v2 style; Size is not a valid key in v3
EzUI:CreateWindow({ Title = "Hub", Size = { Width = 800, Height = 500 } })
-- WRONG: Ratio is no longer an aspect ratio; values > 1 are clamped to ~92% of the screen
EzUI:CreateWindow({ Title = "Hub", Ratio = 16 / 10 })
```

**Do:**
```lua
-- Correct: Ratio is the window size as a fraction of the viewport (per axis)
EzUI:CreateWindow({ Title = "Hub", Ratio = { Width = 0.4, Height = 0.55 } })  -- 40% x 55%
-- a single number applies the same fraction to both axes:
EzUI:CreateWindow({ Title = "Hub", Ratio = 0.5 })  -- 50% x 50%
```

---

## Reactive labels: pass the function — don't call it

A function-valued `AddLabel` / `AddParagraph` is **reactive**: EzUI re-evaluates it every `Interval` (default 1s) on its own thread and updates the text for you. Pass the function **reference** — calling it yourself produces a static label, and if the getter yields it blocks construction.

**Don't:**
```lua
local function bossStatus() return Boss:GetStatusText() end   -- may InvokeServer / WaitForChild / yield

acc:AddLabel(bossStatus())   -- WRONG: calls it once → a static string. And if bossStatus yields, this
                             -- LINE blocks before AddLabel even runs, so every control added after it
                             -- never appears (the section looks half-built).
```

**Do:**
```lua
acc:AddLabel(bossStatus)     -- Correct: pass the function. EzUI calls it on its own thread, so a
                             -- yielding getter is safe, and the label auto-updates every Interval.

-- need a one-time snapshot instead of live updates? pass a plain string:
acc:AddLabel(bossStatus())   -- only OK when bossStatus returns instantly AND you don't want updates
```

On a capability-strict executor a reactive label may not visibly update (the background thread can't write the GUI). Drive it with `SetText(...)` from your own loop there.

---

## EzUI is safe to call from coroutines / task.spawn

Notifications (`Window:ShowInfo/...`), window methods (`Show`, `Hide`, `Minimize`, `SetMode`,
`SetAccent`, `SetFloatingToggleVisible`), and handle-mutators (`SetText`, `SetValue`, `Set`,
`SetOptions`, `SetData`, `SetColor`, `SetImage`, `SetLocked`, ...) are safe to call from any
thread — including a `task.spawn`/`coroutine` loop. EzUI routes the GUI write through a
capability-safe dispatcher (`Safe.mutate`): on a thread that holds the GUI capability it runs
inline (synchronous, as before); on a `task.spawn`/`coroutine` thread it defers the write to the
next `RunService.Heartbeat` (which holds the capability). Values/callbacks stay synchronous; only
the GUI write may land one frame later. You do NOT need to wrap EzUI calls in your own Heartbeat.

`````lua
local lbl = tab:AddLabel("init")
task.spawn(function()
  while true do
    Window:ShowInfo({ Title = "Loop", Message = "tick" })
    lbl.SetText("t=" .. tostring(os.clock()))
    task.wait(1)
  end
end)
`````
