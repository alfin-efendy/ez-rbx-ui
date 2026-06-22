# Label

A single-line text element that renders in the default foreground color. It returns a handle so the text can be updated at runtime via `SetText`.

## Basic usage

```lua
tab:AddLabel("Hello, world!")
-- or with an options table
tab:AddLabel({ Text = "Hello, world!" })
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `""` | Label text. Also accepted as the first positional string argument. |

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

-- Label inside an accordion
local acc = tab:AddAccordion({ Title = "Advanced", Icon = "rows-3" })
acc:AddLabel("Nested label")
```
