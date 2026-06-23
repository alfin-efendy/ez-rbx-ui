# Paragraph

Multi-line wrapped text rendered in the muted foreground color. Height is automatic — the element grows to fit its content. Use it for descriptions, help text, and changelogs.

Text wraps automatically when a line is too long, and explicit `\n` line breaks are honored too — combine both for changelogs and release notes. A paragraph is a [Label](/controls/label) with `Variant = "paragraph"`, so it returns the same handle (`SetText`, `Destroy`).

## Basic usage

```lua
tab:AddParagraph("Paragraphs wrap long text and auto-size their height.")
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `""` | The paragraph body. Also accepted as the first positional string argument. Use `\n` for explicit line breaks. |

## API

| Method | Returns | Notes |
|---|---|---|
| `SetText(s)` | `nil` | Replaces the displayed text (height re-fits automatically). |
| `SetLocked(b)` | `nil` | Overlays a scrim that blocks interaction when `true`. |
| `Destroy()` | `nil` | Removes the element from the UI. |

## Examples

```lua
tab:AddParagraph(
  "Paragraphs wrap long text across multiple lines and auto-size their height. "
  .. "Use them for descriptions, changelogs, and help text within a tab."
)

-- Explicit line breaks with \n (e.g. a changelog)
local notes = tab:AddParagraph(
  "Changelog v3.1\n"
  .. "• Ratio is now a fraction of the screen\n"
  .. "• New StartHidden option\n"
  .. "• Bug fixes and polish"
)
-- SetText can rebuild it at runtime; the height re-fits
tab:AddButton({ Text = "Add a line", Callback = function()
  notes.SetText(notes.Frame.Text .. "\n• Appended at runtime")
end })

-- Inside an accordion
local acc = tab:AddAccordion({ Title = "Details", Icon = "rows-3" })
acc:AddParagraph("Nested paragraph text.")
```
