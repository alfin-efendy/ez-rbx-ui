# Section

An uppercase group heading used to visually separate related controls on a tab or accordion. The text is automatically converted to uppercase.

## Basic usage

```lua
tab:AddSection("Appearance")
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | `""` | Heading text. Automatically uppercased. Also accepted as the first positional string argument. |

## Examples

```lua
tab:AddSection("General")
tab:AddToggle({ Text = "Enable feature", Flag = "featureEnabled" })

tab:AddSection("Advanced")
tab:AddSlider({ Text = "Speed", Min = 0, Max = 100, Flag = "speed" })
```
