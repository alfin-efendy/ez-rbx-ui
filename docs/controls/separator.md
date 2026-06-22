# Separator

A 1 px horizontal divider in the border color, used to group related rows without a full section heading.

## Basic usage

```lua
tab:AddSeparator()
```

## Options

`AddSeparator` takes no options.

## Examples

```lua
tab:AddLabel("Above the separator")
tab:AddSeparator()
tab:AddLabel("Below the separator")

-- Inside an accordion
local acc = tab:AddAccordion({ Title = "Details", Icon = "rows-3" })
acc:AddLabel("Above")
acc:AddSeparator()
acc:AddLabel("Below")
```
