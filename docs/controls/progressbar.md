# ProgressBar

An animated horizontal fill bar that represents a progress value between 0 and 1. The fill animates smoothly when updated via `Set`.

## Basic usage

```lua
local pb = tab:AddProgressBar({ Default = 0.4 })
pb.Set(1)   -- fill to 100%
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Default` | `number` | `0` | Initial fill value, clamped to `0..1`. |
| `Color` | `Color3` | theme primary | Override the fill color. When omitted the fill tracks the accent color automatically. |

## API

| Method | Returns | Notes |
|---|---|---|
| `Get()` | `number` | Returns the current value (`0..1`). |
| `Set(p)` | `nil` | Animates the fill to `p` (clamped to `0..1`). |
| `SetLocked(b)` | `nil` | Overlays a scrim that blocks interaction when `true`. |
| `Destroy()` | `nil` | Removes the element from the UI. |

## Examples

```lua
local pb = tab:AddProgressBar({ Default = 0.4 })
local p = 0.4

tab:AddButton({
  Text = "+20%",
  Callback = function()
    p = math.min(1, p + 0.2)
    pb.Set(p)
  end,
})

tab:AddButton({
  Text = "Reset",
  Variant = "secondary",
  Callback = function()
    p = 0
    pb.Set(0)
  end,
})

-- Custom fill color
tab:AddProgressBar({ Default = 0.7, Color = Color3.fromRGB(34, 197, 94) })
```
