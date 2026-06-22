# EzUI Theming Reference

EzUI ships a zinc dark palette with a monochrome white primary. All visual design tokens live in `EzUI.Theme` and can be overridden per window.

## Per-Window Override

Pass a `Theme` table to `EzUI:CreateWindow`. The table is **deep-merged** onto the defaults — you only specify what you want to change.

```lua
EzUI:CreateWindow({ Theme = { Colors = { primary = Color3.fromRGB(59, 130, 246) } } })
```

## Token Groups

### Colors

Semantic color tokens used throughout every control and panel.

| Token | Default (dark) | Role |
|---|---|---|
| `background` | `rgb(9,9,11)` | Window/panel background |
| `card` | `rgb(24,24,27)` | Card and surface backdrop |
| `surface` | `rgb(39,39,42)` | Control surface (inputs, buttons) |
| `border` | `rgb(63,63,70)` | Dividers and outlines |
| `input` | `rgb(39,39,42)` | Input field border |
| `ring` | `rgb(212,212,216)` | Focus ring |
| `foreground` | `rgb(250,250,250)` | Primary text |
| `mutedForeground` | `rgb(161,161,170)` | Secondary / hint text |
| `primary` | `rgb(250,250,250)` | Accent color (buttons, toggles) |
| `primaryForeground` | `rgb(24,24,27)` | Text on primary-colored surfaces |
| `destructive` | `rgb(239,68,68)` | Danger actions and error state |
| `success` | `rgb(34,197,94)` | Success state |
| `warning` | `rgb(234,179,8)` | Warning state |
| `info` | `rgb(59,130,246)` | Informational state |
| `switchTrackOff` | `rgb(39,39,42)` | Toggle track color when off |

Override any subset:

```lua
EzUI:CreateWindow({
    Theme = {
        Colors = {
            primary     = Color3.fromRGB(59, 130, 246),
            destructive = Color3.fromRGB(220, 38, 38),
        }
    }
})
```

### Radius

Corner rounding in pixels applied to panels, cards, inputs, and buttons.

| Key | Default | Used on |
|---|---|---|
| `sm` | `6` | Search box, tags, small chips |
| `md` | `8` | Floating toggle image, medium chips |
| `lg` | `10` | Content panel, buttons, cards |
| `xl` | `14` | Large panels |
| `window` | `12` | Window frame corners |

```lua
Theme = { Radius = { lg = 6, window = 8 } }
```

### Spacing

Padding and gap values (pixels) used by the layout engine.

| Key | Default | Used for |
|---|---|---|
| `pad` | `16` | Standard horizontal padding |
| `padLg` | `24` | Large padding sections |
| `inputX` | `12` | Input horizontal padding |
| `inputY` | `8` | Input vertical padding |
| `gap` | `8` | Spacing between sidebar and content panel |
| `section` | `16` | Vertical section spacing |
| `major` | `24` | Major vertical sections |
| `icon` | `8` | Icon gutter |

```lua
Theme = { Spacing = { pad = 12, gap = 6 } }
```

### Font

Text size and weight per role. Each entry is `{ Weight = Enum.FontWeight, Size = <px> }`.

| Key | Weight | Size (px) | Used for |
|---|---|---|---|
| `title` | `Bold` | `18` | Window title bar |
| `header` | `Medium` | `16` | Section headers |
| `label` | `Medium` | `14` | Control labels |
| `body` | `Regular` | `14` | Body / description text |
| `muted` | `Regular` | `12` | Hint text, tags, search |

```lua
Theme = { Font = { title = { Weight = Enum.FontWeight.Bold, Size = 20 } } }
```

### Motion

Tween durations (seconds) for tabs, accordions, toasts, and other transitions.

| Key | Default | Speed |
|---|---|---|
| `fast` | `0.12` | Snappy micro-interactions |
| `base` | `0.18` | Standard transitions |
| `slow` | `0.28` | Deliberate, large animations |

```lua
Theme = { Motion = { fast = 0.08, base = 0.15, slow = 0.25 } }
```

## Deep-Merge Behavior

A partial `Theme` override is deep-merged onto the built-in defaults. Unspecified tokens retain their defaults. There is no need to copy the entire theme table.

```lua
-- Only primary changes; all other tokens stay at their zinc dark defaults.
EzUI:CreateWindow({
    Theme = { Colors = { primary = Color3.fromRGB(99, 102, 241) } }
})
```

## Color Mode (Dark / Light)

EzUI ships two complete palettes: `"dark"` (default, zinc-based) and `"light"` (white-based). Set the mode at window creation time or switch it live:

```lua
-- Light mode from the start
local Window = EzUI:CreateWindow({ Mode = "light" })

-- Switch at runtime
Window:SetMode("light")
Window:SetMode("dark")
print(Window:GetMode())  -- "dark" or "light"
```

Per-window `Theme.Colors` overrides apply on top of whichever palette is active. Switching mode does not reset a `primary` or `primaryForeground` override that is already set.
