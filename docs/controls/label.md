# Label

A text element that renders in the default foreground color. It returns a handle so the text can be updated at runtime via `SetText`. Single-line by default; use `Variant = "paragraph"` for a multi-line label.

## Basic usage

```lua
tab:AddLabel("Hello, world!")
-- or with an options table
tab:AddLabel({ Text = "Hello, world!" })
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `""` | Label text. Also accepted as the first positional string argument. Honors explicit `\n` line breaks when `Variant = "paragraph"`. |
| `Variant` | `string` | `"default"` | `"default"` — single line (extra lines are clipped). `"paragraph"` — wraps and auto-sizes its height, in the muted color. `"section"` — an uppercased group heading. `AddParagraph` and `AddSection` are shorthands for the last two. |

## API

| Method | Returns | Notes |
|---|---|---|
| `SetText(s)` | `nil` | Replaces the displayed text. |
| `SetLocked(b)` | `nil` | Overlays a scrim that blocks interaction when `true`. |
| `Destroy()` | `nil` | Removes the element from the UI. |

## Examples

```lua
-- Default label
tab:AddLabel("Static label")

-- Dynamic label updated at runtime
local dyn = tab:AddLabel("Click the button to change me")
tab:AddButton({
  Text = "Set text",
  Callback = function()
    dyn.SetText("Updated at runtime!")
  end,
})

-- Multi-line label: a default label is single-line (extra lines clip), so use the
-- paragraph variant — it wraps, auto-sizes its height, and honors explicit \n breaks.
tab:AddLabel({
  Variant = "paragraph",
  Text = "First line\nSecond line\nThird line — wraps automatically when a line is too long to fit.",
})

-- Label inside an accordion
local acc = tab:AddAccordion({ Title = "Advanced", Icon = "rows-3" })
acc:AddLabel("Nested label")
```
