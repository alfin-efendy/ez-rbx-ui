# Toggle

A labeled on/off switch. An optional description line can be added beneath the label for extra context. Toggles can be bound to a flag key for automatic persistence across sessions.

## Basic usage

```lua
local t = tab:AddToggle({
  Text    = "Enable feature",
  Default = false,
  Callback = function(on)
    print("toggle is now", on)
  end,
})
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `"Toggle"` | Label displayed to the left of the switch. |
| `Default` | `boolean` | `false` | Initial on/off state. |
| `Description` | `string` | — | Muted secondary line rendered below the label. |
| `Flag` | `string` | — | Config key used to persist the value across sessions. |
| `Callback` | `function(bool)` | — | Called with the new boolean value whenever the toggle changes. |

## API

| Method | Returns | Notes |
|---|---|---|
| `Get()` | `boolean` | Returns the current on/off value. |
| `Set(v)` | `nil` | Sets the toggle to `v` and fires `Callback` / `OnChanged`. |
| `OnChanged(fn)` | `nil` | Registers a listener called with the new value on every change. |
| `Destroy()` | `nil` | Removes the toggle from the UI. |

## Examples

```lua
-- Basic toggle with callback
tab:AddToggle({
  Text    = "Enable feature",
  Default = false,
  Callback = function(on)
    print("toggle", on)
  end,
})

-- With a description line
tab:AddToggle({
  Text        = "With description",
  Description = "Extra context shown under the label.",
  Default     = true,
})

-- Flag-bound — value persists across sessions
tab:AddToggle({
  Text    = "Remember me",
  Flag    = "ex_toggle",
  Default = true,
})

-- Reading and writing programmatically
local t = tab:AddToggle({ Text = "Dark mode", Default = false })
t.OnChanged(function(v)
  print("dark mode:", v)
end)
t.Set(true)   -- turn on
print(t.Get()) -- true
```
