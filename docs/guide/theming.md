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

Controls the corner rounding (in pixels) applied to panels, cards, inputs, and buttons.

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

Controls padding and gap values (in pixels) used throughout the layout engine.

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

Controls the text size and weight for each text role. Each entry is a `{ Weight = Enum.FontWeight, Size = <px> }` table.

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

Controls tween durations (in seconds) for transitions such as tabs, accordions, and toasts.

| Key | Default | Speed |
|---|---|---|
| `fast` | `0.12` | Snappy micro-interactions |
| `base` | `0.18` | Standard transitions |
| `slow` | `0.28` | Deliberate, large animations |

```lua
Theme = { Motion = { fast = 0.08, base = 0.15, slow = 0.25 } }
```

## Deep-Merge Behavior

A partial `Theme` table is deep-merged onto the built-in defaults. You only need to specify the tokens you want to change — all other tokens remain at their defaults. There is no need to copy the entire theme table.

```lua
-- Only the primary color changes; everything else uses the zinc dark defaults.
EzUI:CreateWindow({
    Theme = { Colors = { primary = Color3.fromRGB(99, 102, 241) } }
})
```

## Color mode (dark / light) {#color-mode-dark-light}

EzUI ships two complete palettes: `dark` (default, zinc-based) and `light` (white-based). Choose at window creation time with the `Mode` config key, or switch the live window with `SetMode`:

```lua
-- Light mode from the start
local Window = EzUI:CreateWindow({ Mode = "light" })

-- Switch live at runtime
Window:SetMode("light")
Window:SetMode("dark")

-- Read the current mode
print(Window:GetMode()) -- "dark" or "light"
```

The `Colors` tokens above describe the dark palette. In light mode the same token names map to lighter equivalents — your per-window `Theme.Colors` overrides apply on top of whichever palette is active. See the [Window API](/api/window#color-mode) for `GetMode` / `SetMode` reference.

### Theme-adaptive logo

A brand logo that is a **single-color glyph** (e.g. an SVG exported with `fill="currentColor"`) can follow the mode automatically. Export it as a **white-on-transparent PNG** and opt in with `ImageAdaptive` (title bar) or the floating toggle's `Adaptive`:

```lua
EzUI:CreateWindow({
    Image = "rbxassetid://0",          -- a white-on-transparent glyph
    ImageAdaptive = true,              -- tints to `foreground`: near-white in dark, near-black in light
    FloatingToggle = { Type = "square", Image = "rbxassetid://0", Adaptive = true },
})
```

EzUI sets `ImageColor3` to the `foreground` token and re-tints it whenever `SetMode` flips the palette. Because `ImageColor3` multiplies, a white source tints cleanly to any color. Leave these `false` (the default) for full-color logos, which render untouched.
