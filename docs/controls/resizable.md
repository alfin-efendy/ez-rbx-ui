# Resizable

A split-pane container with a draggable grip that lets users resize two or more panes at runtime. Each pane is itself a full control host — you can call any `Add*` method on it, just like a tab or accordion.

## Basic usage

```lua
local rz = tab:AddResizable({
  Direction = "Horizontal",
  Panes = { { Default = 0.4 }, { Default = 0.6 } },
  Height = 140,
})

rz.Panes[1]:AddLabel("Left pane")
rz.Panes[1]:AddButton({ Text = "Action" })
rz.Panes[2]:AddLabel("Right pane")
rz.Panes[2]:AddToggle({ Text = "Option" })
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Direction` | `"Horizontal" \| "Vertical"` | `"Horizontal"` | Orientation of the split. Horizontal places panes side-by-side; Vertical stacks them. |
| `Panes` | `{ { Default?, Min? } }[]` | two equal panes | Array of pane definitions. `Default` is the initial size fraction (auto-normalized so fractions need not sum to 1). `Min` is the minimum fraction a pane can shrink to when dragging (default `0.1`). |
| `Height` | `number` | `160` (H) / `200` (V) | Container height in pixels. |

## API

| Member | Type | Notes |
|---|---|---|
| `Panes` | `host[]` | Array of pane host objects, one per pane definition. Each pane supports the full `Add*` control API (e.g. `rz.Panes[1]:AddLabel(…)`, `rz.Panes[2]:AddToggle(…)`). |
| `Destroy()` | `nil` | Removes the entire resizable container and disconnects all drag listeners. |

## Examples

```lua
-- Horizontal split with custom initial sizes and min-size constraints
local rz = tab:AddResizable({
  Direction = "Horizontal",
  Panes = {
    { Default = 0.4, Min = 0.2 },
    { Default = 0.6, Min = 0.2 },
  },
  Height = 140,
})
rz.Panes[1]:AddLabel("Left pane")
rz.Panes[1]:AddButton({ Text = "Action" })
rz.Panes[2]:AddLabel("Right pane")
rz.Panes[2]:AddToggle({ Text = "Option" })

-- Vertical split
local rv = tab:AddResizable({
  Direction = "Vertical",
  Panes = { {}, {} },
  Height = 200,
})
rv.Panes[1]:AddLabel("Top pane")
rv.Panes[2]:AddLabel("Bottom pane")

-- Inside an accordion
local acc = tab:AddAccordion({ Title = "Split view", Icon = "columns-2" })
local r1 = acc:AddResizable({ Panes = { {}, {} }, Height = 100 })
r1.Panes[1]:AddLabel("Left")
r1.Panes[2]:AddLabel("Right")
```

Drag the centre grip to resize the panes. The `Min` option clamps how small a pane can become. See [Controls overview](/controls/) for the full list of `Add*` methods available on each pane.
