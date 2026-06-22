# Controls

Controls are UI elements that you call on a **tab** or an **accordion**. Every `Add*` method is available on both.

```lua
local tab = window:AddTab({ Name = "Settings" })
tab:AddLabel("Hello")

local acc = tab:AddAccordion({ Title = "Advanced" })
acc:AddLabel("Nested")
```

Any control that accepts a `Flag` option automatically saves and restores its value via the config system — see [Config & Flags](/guide/config-and-flags).

## Control reference

| Control | Purpose |
|---|---|
| [Label](/controls/label) | Single-line text; supports runtime `SetText` |
| [Paragraph](/controls/paragraph) | Multi-line wrapped text for descriptions |
| [Section](/controls/section) | Uppercase group heading |
| [Separator](/controls/separator) | 1 px horizontal divider |
| [Button](/controls/button) | Clickable action button |
| [Toggle](/controls/toggle) | On/off boolean switch |
| [TextBox](/controls/textbox) | Single-line text input |
| [NumberBox](/controls/numberbox) | Numeric text input with min/max clamping |
| [Slider](/controls/slider) | Draggable range input |
| [SelectBox](/controls/selectbox) | Dropdown option picker |
| [Keybind](/controls/keybind) | Keyboard shortcut recorder |
| [ColorPicker](/controls/colorpicker) | HSV/hex color picker with popover |
| [Image](/controls/image) | Roblox asset or Lucide glyph |
| [ProgressBar](/controls/progressbar) | Animated fill bar (0–1) |
| [Table](/controls/table) | Scrollable data table |
| [Card](/controls/card) | Rich content card with banner, title, body, and action buttons |
| [Accordion](/controls/accordion) | Collapsible section that hosts nested controls |
