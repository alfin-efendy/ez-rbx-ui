# Paragraph

Multi-line wrapped text rendered in the muted foreground color. Height is automatic — the element grows to fit its content. Use it for descriptions, help text, and changelogs.

## Basic usage

```lua
tab:AddParagraph("Paragraphs wrap long text and auto-size their height.")
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `""` | The paragraph body. Also accepted as the first positional string argument. |

## Examples

```lua
tab:AddParagraph(
  "Paragraphs wrap long text across multiple lines and auto-size their height. "
  .. "Use them for descriptions, changelogs, and help text within a tab."
)

-- Inside an accordion
local acc = tab:AddAccordion({ Title = "Details", Icon = "rows-3" })
acc:AddParagraph("Nested paragraph text.")
```
