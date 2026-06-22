# Button

A clickable action element available in five visual variants. Buttons support an optional leading icon and a built-in `"ResetConfig"` action that resets all saved flags without extra wiring.

## Basic usage

```lua
tab:AddButton({
  Text     = "Confirm",
  Callback = function()
    window:ShowSuccess({ Title = "Done" })
  end,
})
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `"Button"` | Label displayed on the button. |
| `Variant` | `string` | `"default"` | Visual style — see the table below. |
| `Icon` | `string` | — | Lucide icon name (e.g. `"play"`). Rendered to the left of the label. |
| `Callback` | `function` | — | Called with no arguments when the button is clicked. |
| `Action` | `string` | — | Pass `"ResetConfig"` to wire the built-in config-reset without a callback. |

### Variants

| Value | Appearance |
|---|---|
| `"default"` | Filled with the theme primary color. |
| `"secondary"` | Filled with the muted surface color. |
| `"outline"` | Transparent fill with a border stroke. |
| `"ghost"` | No fill and no border; tinted on hover. |
| `"destructive"` | Filled with the destructive (red) color. |

## API

| Method | Returns | Notes |
|---|---|---|
| `SetText(s)` | `nil` | Replaces the button label at runtime. |
| `SetEnabled(b)` | `nil` | When `false`, dims the label and disables clicks. |
| `Destroy()` | `nil` | Removes the button from the UI. |

## Examples

```lua
-- All five variants
tab:AddButton({ Text = "Default" })
tab:AddButton({ Text = "Secondary",   Variant = "secondary" })
tab:AddButton({ Text = "Outline",     Variant = "outline" })
tab:AddButton({ Text = "Ghost",       Variant = "ghost" })
tab:AddButton({ Text = "Destructive", Variant = "destructive" })

-- With a leading icon
tab:AddButton({ Text = "Play", Icon = "play" })

-- Built-in reset — no callback required
tab:AddButton({
  Text    = "Reset config",
  Variant = "destructive",
  Action  = "ResetConfig",
})

-- Inside an accordion
local acc = tab:AddAccordion({ Title = "Actions", Icon = "rows-3" })
acc:AddButton({ Text = "Action" })
```
