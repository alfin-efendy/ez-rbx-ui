# Accordion

A collapsible card that hosts any [Controls](/controls/) inside it. Clicking the header toggles the body open or closed with an animated resize. An optional leading icon can be set, and the panel can start expanded by default.

## Basic usage

```lua
local acc = tab:AddAccordion({ Title = "Advanced settings", Icon = "settings-2" })
acc:AddToggle({ Text = "Nested toggle", Default = true })
acc:AddSlider({ Text = "Nested slider", Min = 0, Max = 10, Default = 5 })
acc:AddButton({ Text = "Nested button" })
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Title` | `string` | `"Section"` | Header text. |
| `Icon` | `string` | — | Lucide icon name shown to the left of the title (e.g. `"settings-2"`, `"rows-3"`). |
| `Expanded` | `bool` | `false` | When `true` the accordion starts open. |

## API

The accordion handle exposes all the same `AddX` methods as a tab (e.g. `AddToggle`, `AddSlider`, `AddButton`, `AddSelectBox`, etc.), plus the following lifecycle methods:

| Method | Returns | Notes |
|---|---|---|
| `Toggle()` | `boolean` | Toggles open/closed; returns the new `expanded` state. |
| `Expand()` | `nil` | Opens the accordion (no-op if already open). |
| `Collapse()` | `nil` | Closes the accordion (no-op if already closed). |
| `IsExpanded()` | `boolean` | Returns `true` when the panel is currently open. |
| `SetTitle(s)` | `nil` | Updates the header text at runtime. |
| `SetIcon(name)` | `nil` | Swaps the leading icon. Only applies when an `Icon` was set at creation. |
| `Destroy()` | `nil` | Removes the accordion and all its children from the UI. |

## Examples

```lua
-- Collapsed by default; nest multiple controls
local acc = tab:AddAccordion({ Title = "Advanced settings", Icon = "settings-2", Expanded = false })
acc:AddToggle({ Text = "Nested toggle", Default = true })
acc:AddSlider({ Text = "Nested slider", Min = 0, Max = 10, Default = 5 })
acc:AddButton({ Text = "Nested button" })

-- Expanded by default
local acc2 = tab:AddAccordion({ Title = "Open on load", Icon = "settings-2", Expanded = true })
acc2:AddToggle({ Text = "Nested toggle", Default = false })
acc2:AddButton({ Text = "Nested button" })

-- Control programmatically
local acc3 = tab:AddAccordion({ Title = "Controlled", Icon = "rows-3" })
acc3:AddLabel("Some content")

acc3:Expand()
print(acc3:IsExpanded())  -- true
acc3:Collapse()
acc3:Toggle()             -- opens again

acc3:SetTitle("Renamed section")
acc3:SetIcon("star")
```
