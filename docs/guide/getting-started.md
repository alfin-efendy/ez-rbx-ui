# Getting Started

EzUI is a modern, modular UI library for Roblox scripts. It features a shadcn-inspired design, Fluent-style acrylic panel, Lucide icons, CSS-flex-like layout (engine-driven, no manual positioning), smooth tab and accordion transitions, and a flag-based config system with auto-save/load and reset.

## Install

### Executor (loadstring)

Paste this at the top of your script:

```lua
local EzUI = loadstring(game:HttpGet("https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"))()
```

### ModuleScript (Studio)

1. Download `ez-rbx-ui.lua` from the latest release.
2. Place it inside `ReplicatedStorage`.
3. Require it from any LocalScript:

```lua
local EzUI = require(game:GetService("ReplicatedStorage")["ez-rbx-ui"])
```

## Quick Start

The example below creates a window, adds a tab with three controls, and wires up a success notification on button click.

```lua
local Window = EzUI:CreateWindow({
    Title = "My Hub",
    Ratio = { Width = 0.4, Height = 0.55 },   -- 40% of the screen wide, 55% tall; auto-fits
    Subtitle = "v3.0",
    Transparency = 0.12,
    ToggleKey = Enum.KeyCode.RightControl,   -- show/hide
    FloatingToggle = { Type = "simple", AutoHide = true },  -- mobile/touch button
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})

local tab = Window:AddTab({ Name = "Home", Icon = "home" })   -- icons are Lucide names

tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false,
    Callback = function(on) print("Auto Farm:", on) end })

tab:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 16, Flag = "walkspeed" })

tab:AddButton({ Text = "Execute", Variant = "default", Icon = "play", Callback = function()
    Window:ShowSuccess({ Title = "Done", Message = "Script ran." })
end })
```

Any control with a `Flag` and a window `Config` automatically saves and restores its value across sessions (requires executor file functions — see [Config & Flags](/guide/config-and-flags)).

---

Next: [Window & Tabs](/guide/window-and-tabs) · [Controls](/controls/)
