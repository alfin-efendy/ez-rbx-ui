# Theming

EzUI ships with a zinc dark palette and a monochrome white primary color. All visual tokens live in `EzUI.Theme` and can be overridden per window.

## Per-Window Override

Pass a `Theme` table to `EzUI:CreateWindow`. Only the keys you specify are applied — the rest keep their defaults (deep-merge behavior).

```lua
EzUI:CreateWindow({ Theme = { Colors = { primary = Color3.fromRGB(59, 130, 246) } } })
```

## Token Groups

### Colors

The `Colors` group contains every semantic color token:

| Token | Default role |
|---|---|
| `background` | Window/panel background |
| `card` | Card and surface backdrop |
| `surface` | Control surface (inputs, buttons) |
| `border` | Dividers and outlines |
| `input` | Input field border |
| `ring` | Focus ring |
| `foreground` | Primary text |
| `mutedForeground` | Secondary / hint text |
| `primary` | Accent color (buttons, toggles) |
| `primaryForeground` | Text on primary-colored surfaces |
| `destructive` | Danger actions and error state |
| `success` | Success state |
| `warning` | Warning state |
| `info` | Informational state |
| `switchTrackOff` | Toggle track color when off |

Override any subset:

```lua
EzUI:CreateWindow({
    Theme = {
        Colors = {
            primary = Color3.fromRGB(59, 130, 246),
            destructive = Color3.fromRGB(220, 38, 38),
        }
    }
})
```

### Radius

Controls the corner rounding applied to panels, cards, inputs, and buttons.

```lua
Theme = { Radius = { base = 8, sm = 4, lg = 12 } }
```

### Spacing

Controls padding and gap values used throughout the layout engine.

```lua
Theme = { Spacing = { xs = 4, sm = 8, md = 12, lg = 16 } }
```

### Font

Controls the typeface and weight applied to labels, headings, and inputs.

```lua
Theme = { Font = { Body = Enum.Font.Gotham, Heading = Enum.Font.GothamBold } }
```

### Motion

Controls animation durations and easing for transitions (accordions, tabs, toasts).

```lua
Theme = { Motion = { Duration = 0.18, EasingStyle = Enum.EasingStyle.Quint } }
```

## Deep-Merge Behavior

A partial `Theme` table is deep-merged onto the built-in defaults. You only need to specify the tokens you want to change — all other tokens remain at their defaults. There is no need to copy the entire theme table.

```lua
-- Only the primary color changes; everything else uses the zinc dark defaults.
EzUI:CreateWindow({
    Theme = { Colors = { primary = Color3.fromRGB(99, 102, 241) } }
})
```
