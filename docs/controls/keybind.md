# Keybind

A keyboard shortcut recorder. Clicking the control puts it into listen mode (the key badge shows `…`); the next key pressed is saved as the new binding. The bound key fires `Callback` / `OnPressed` whenever it is pressed outside of game-processed input. Flag persistence is supported.

## Basic usage

```lua
local kb = tab:AddKeybind({
  Text    = "Action key",
  Default = Enum.KeyCode.E,
  Callback = function()
    print("keybind pressed")
  end,
})
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `"Keybind"` | Label displayed to the left of the key badge. |
| `Default` | `Enum.KeyCode` | `Enum.KeyCode.Unknown` | Initial key binding. |
| `Description` | `string` | — | Muted secondary line rendered below the label. |
| `Flag` | `string` | — | Config key used to persist the binding across sessions. |
| `Callback` | `function()` | — | Called (no arguments) whenever the bound key is pressed. |

## API

| Method | Returns | Notes |
|---|---|---|
| `GetKey()` | `Enum.KeyCode` | Returns the current key binding. |
| `SetKey(k)` | `nil` | Sets the binding programmatically; accepts an `Enum.KeyCode`. |
| `OnPressed(fn)` | `nil` | Registers an additional listener called when the key fires. |
| `Destroy()` | `nil` | Removes the control from the UI. |

## Examples

```lua
-- Basic bind with callback
tab:AddKeybind({
  Text     = "Action key",
  Default  = Enum.KeyCode.E,
  Callback = function() print("keybind pressed") end,
})

-- With a description line
tab:AddKeybind({
  Text        = "With description",
  Description = "Click then press a key.",
  Default     = Enum.KeyCode.Q,
})

-- Flag-bound — binding persists across sessions
tab:AddKeybind({ Text = "Saved bind", Flag = "ex_keybind", Default = Enum.KeyCode.F })

-- Reading and overriding at runtime
local kb = tab:AddKeybind({ Text = "Toggle UI", Default = Enum.KeyCode.RightShift })
kb.OnPressed(function()
  print("current key is", kb.GetKey().Name)
end)
kb.SetKey(Enum.KeyCode.P)  -- change binding programmatically
```
