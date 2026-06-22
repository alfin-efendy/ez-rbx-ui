# ColorPicker

An inline color swatch that opens a floating HSV picker on click. The picker provides a saturation/value square and a hue slider; click or drag either to change the color. The popover closes automatically when the control scrolls out of view. The value can be persisted with a flag.

## Basic usage

```lua
local cp = tab:AddColorPicker({
  Text    = "Box color",
  Default = Color3.fromRGB(120, 160, 255),
  Callback = function(c)
    print("color", c)
  end,
})
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `"Color"` | Label displayed to the left of the swatch. |
| `Default` | `Color3` | `Color3.fromRGB(255, 255, 255)` | Initial color. |
| `Description` | `string` | — | Muted secondary line rendered below the label. |
| `Flag` | `string` | — | Config key used to persist the color across sessions. Stored as an `{r, g, b}` array (0–255). |
| `Callback` | `function(Color3)` | — | Called with the new `Color3` value on every change. |

## API

| Method | Returns | Notes |
|---|---|---|
| `GetColor()` | `Color3` | Returns the current color. |
| `SetColor(c)` | `nil` | Sets the color programmatically and fires `Callback`. |
| `Destroy()` | `nil` | Removes the control from the UI. |

## Examples

```lua
-- Basic color picker with callback
tab:AddColorPicker({
  Text    = "Box color",
  Default = Color3.fromRGB(120, 160, 255),
  Callback = function(c) print("color", c) end,
})

-- With a description line
tab:AddColorPicker({
  Text        = "With description",
  Description = "Click to open the picker.",
  Default     = Color3.fromRGB(80, 200, 120),
})

-- Flag-bound — color persists across sessions
tab:AddColorPicker({ Text = "Saved color", Flag = "ex_color", Default = Color3.fromRGB(255, 80, 80) })

-- Reading and setting at runtime
local cp = tab:AddColorPicker({ Text = "Tint", Default = Color3.fromRGB(255, 255, 255) })
print(cp.GetColor())                            -- Color3 [255, 255, 255]
cp.SetColor(Color3.fromRGB(255, 0, 0))          -- set to red programmatically
```
