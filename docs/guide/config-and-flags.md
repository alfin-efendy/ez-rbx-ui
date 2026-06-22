# Config & Flags

EzUI provides a flag-based configuration system that automatically saves and restores control values across sessions.

## Creating a Config

Use `EzUI:NewConfig` to create a standalone config object, or pass a `Config` table to `EzUI:CreateWindow` to attach persistence to an entire window.

```lua
local cfg = EzUI:NewConfig({ FileName = "PlayerData" })
cfg:Set("coins", 1000)
print(cfg:Get("coins"))  -- 1000
```

### Config Options

| Key | Type | Description |
|---|---|---|
| `Enabled` | `bool` | Enable or disable persistence entirely |
| `FileName` | `string` | Name of the saved file (no extension) |
| `FolderName` | `string` | Subfolder inside the executor's workspace |
| `AutoSave` | `bool` | Write to disk whenever a flag changes |
| `AutoLoad` | `bool` | Read from disk on startup and apply values |

## Flags

Any control that accepts a `Flag` option registers itself against the window's config. When `AutoSave` is enabled, writing the control updates the saved file. When `AutoLoad` is enabled, the saved value is restored on startup.

```lua
local Window = EzUI:CreateWindow({
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})

local tab = Window:AddTab({ Name = "Settings", Icon = "settings-2" })

-- This toggle's value is saved under the key "autofarm".
tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false,
    Callback = function(on) print("Auto Farm:", on) end })
```

## Resetting Configuration

`Window:ResetConfiguration()` confirms via a dialog, restores every flagged control to its default value, and shows a success toast.

```lua
tab:AddButton({
    Text = "Reset Settings",
    Variant = "destructive",
    Action = "ResetConfig",   -- shorthand: triggers ResetConfiguration automatically
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

The window's config object is also accessible directly via `Window.Config`.

## File Function Requirement

::: warning Executor requirement
Flag persistence requires the following executor file functions: `writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`.

The UI works without them — controls still function normally — but saved values will not persist between sessions. Most modern executors provide these functions.
:::
