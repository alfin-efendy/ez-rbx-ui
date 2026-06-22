# Image

Displays a Roblox asset image or a Lucide icon glyph at a fixed height. The image scales with `ScaleType.Fit` so it never distorts.

## Basic usage

```lua
-- Lucide glyph
tab:AddImage({ Lucide = "gamepad-2", Height = 64 })

-- Raw Roblox asset
tab:AddImage({ Image = "rbxassetid://0", Height = 80 })
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Image` | `string` | `""` | Roblox asset ID string (e.g. `"rbxassetid://…"`). Mutually exclusive with `Lucide`. |
| `Lucide` | `string` | — | Name of a Lucide icon (e.g. `"gamepad-2"`). Renders the glyph using the icon sheet. |
| `Height` | `number` | `80` | Height in pixels. Width is always 100%. |
| `Color` | `Color3` | varies | Tint color. Defaults to the theme foreground color for `Lucide` glyphs, or white (`Color3.fromRGB(255, 255, 255)`) for raw `Image` assets. |

## API

| Method | Returns | Notes |
|---|---|---|
| `SetImage(v)` | `nil` | Swaps the displayed image at runtime. Pass an `rbxassetid://…` string. |
| `Destroy()` | `nil` | Removes the image from the UI. |

## Examples

```lua
-- Lucide icon as a decorative glyph
tab:AddImage({ Lucide = "gamepad-2", Height = 64 })

-- Asset image (replace 0 with a real asset ID)
tab:AddImage({ Image = "rbxassetid://0", Height = 80 })

-- Swap the image at runtime
local img = tab:AddImage({ Image = "rbxassetid://0", Height = 80 })
img:SetImage("rbxassetid://12345678")

-- Inside an accordion
local acc = tab:AddAccordion({ Title = "Preview", Icon = "rows-3" })
acc:AddImage({ Lucide = "gamepad-2", Height = 48 })
```
