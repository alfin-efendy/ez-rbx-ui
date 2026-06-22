# EzUI Config & Flags Reference

EzUI provides a flag-based configuration system that automatically saves and restores control values across sessions.

## Creating a Config

Use `EzUI:NewConfig` to create a standalone config object, or pass a `Config` table to `EzUI:CreateWindow` to attach persistence to an entire window.

```lua
local cfg = EzUI:NewConfig({ FileName = "PlayerData" })
cfg:Set("coins", 1000)
print(cfg:Get("coins"))  -- 1000
```

### Config Options

| Key | Type | Default | Description |
|---|---|---|---|
| `Enabled` | `bool` | `true` | Enable or disable persistence entirely |
| `FileName` | `string` | `"Settings"` | Name of the saved file (no extension) |
| `FolderName` | `string` | `"EzUI"` | Subfolder inside the executor's workspace |
| `AutoSave` | `bool` | `true` | Write to disk whenever a flag changes |
| `AutoLoad` | `bool` | `true` | Read from disk on startup and apply values |

## Flags

Any control that accepts a `Flag` option registers itself against the window's `Config`. When `AutoSave` is enabled, changing the control immediately writes to disk. When `AutoLoad` is enabled, the saved value is restored on startup and the control setter is called.

```lua
local Window = EzUI:CreateWindow({
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})

local tab = Window:AddTab({ Name = "Settings", Icon = "settings-2" })

-- "autofarm" is the flag key; its value is saved and restored automatically.
tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false,
    Callback = function(on) print("Auto Farm:", on) end })

tab:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 16, Flag = "walkspeed" })
```

Controls that support `Flag`: `AddToggle`, `AddSlider`, `AddTextBox`, `AddNumberBox`, `AddSelectBox`, `AddKeybind`, `AddColorPicker`.

The window's config object is accessible via `Window.Config`.

## Resetting Configuration

`Window:ResetConfiguration()` shows a confirmation dialog, restores every flagged control to its default value, and shows a success toast.

```lua
-- Shorthand via button Action:
tab:AddButton({
    Text    = "Reset Settings",
    Variant = "destructive",
    Action  = "ResetConfig",    -- triggers ResetConfiguration automatically
})

-- Or call directly:
Window:ResetConfiguration({ Confirm = true, ClearFile = false })
```

| Option | Default | Description |
|---|---|---|
| `Confirm` | `true` | Show a confirmation dialog before resetting |
| `ClearFile` | `false` | Also delete the saved file from disk |

To reset a single flag programmatically:

```lua
Window:ResetFlag("autofarm")
```

## File Function Requirement

**Persistence requires executor file functions.** EzUI checks for these at runtime:

- `writefile` — save config to disk
- `readfile` — load config from disk
- `isfile` — check if a file exists
- `isfolder` — check if a folder exists
- `makefolder` — create a folder

The UI works without them — controls still function normally and flags still wire up — but saved values will not persist between sessions. Most modern Roblox executors provide all five functions.
