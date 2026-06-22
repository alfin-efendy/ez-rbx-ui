# Slider

A horizontal drag control for selecting a numeric value within a fixed range. The current value is displayed in a small readout to the right of the label. Values snap to the nearest `Step` increment as you drag. Sliders support an optional description line, a flag for persistence, and an `OnChanged` listener for live readouts.

## Basic usage

```lua
local s = tab:AddSlider({
  Text    = "Speed",
  Min     = 0,
  Max     = 100,
  Default = 50,
})
print(s.GetValue())
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | — | Row label. Shown above the track with the current value to the right. |
| `Min` | `number` | `0` | Minimum value (left end of the track). |
| `Max` | `number` | `100` | Maximum value (right end of the track). |
| `Default` | `number` | `Min` | Initial value, snapped to the nearest `Step`. |
| `Step` | `number` | `1` | Snap increment. Values are rounded to the nearest multiple of `Step` relative to `Min`. |
| `Description` | `string` | — | Muted secondary line rendered below the label. |
| `Flag` | `string` | — | Config key used to persist the value across sessions. |
| `Callback` | `function(number)` | — | Called with the new value after each drag or `SetValue` call. |

## API

| Method | Returns | Notes |
|---|---|---|
| `GetValue()` | `number` | Returns the current snapped value. |
| `SetValue(n)` | `nil` | Sets the value (snapped and clamped), fires `Callback` and `OnChanged`. |
| `OnChanged(fn)` | `nil` | Registers a listener called with the new value on every change. Use this for live readouts. |
| `Destroy()` | `nil` | Removes the slider from the UI. |

## Examples

```lua
-- Live readout via OnChanged
local readout = tab:AddLabel("Speed: 16")
local s = tab:AddSlider({ Text = "Speed", Min = 16, Max = 200, Default = 16 })
s.OnChanged(function(v)
  readout.SetText("Speed: " .. tostring(v))
end)

-- With a description
tab:AddSlider({
  Text        = "With description",
  Description = "Drag to adjust.",
  Min         = 0,
  Max         = 100,
  Default     = 30,
})

-- Flag-bound — value persists across sessions
tab:AddSlider({
  Text    = "Saved volume",
  Flag    = "ex_slider",
  Min     = 0,
  Max     = 100,
  Default = 50,
})

-- Programmatic update
local vol = tab:AddSlider({ Text = "Volume", Min = 0, Max = 100, Default = 80 })
vol.SetValue(50)
print(vol.GetValue()) -- 50
```
