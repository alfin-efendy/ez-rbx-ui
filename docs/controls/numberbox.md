# NumberBox

A numeric input with − and + step buttons. Clicking and holding either button accelerates the repeat rate. The scroll wheel also adjusts the value. Values can be entered by typing directly — compact notation (`1k`, `4.4m`, `72B`) is accepted when `Format = "compact"` is set. Optional prefix and suffix strings are stripped automatically during parsing.

## Basic usage

```lua
local nb = tab:AddNumberBox({
  Text    = "Amount",
  Default = 10,
  Min     = 0,
  Max     = 100,
  Step    = 5,
})
print(nb.GetValue())
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | — | Row label. Omit for a label-less box that spans the full width. |
| `Default` | `number` | `0` | Initial value, clamped to `Min..Max`. |
| `Min` | `number` | — | Minimum allowed value. The − button dims when the value reaches this. |
| `Max` | `number` | — | Maximum allowed value. The + button dims when the value reaches this. |
| `Step` | `number` | `1` | Amount added or subtracted per button press or scroll tick. |
| `Format` | `string` | — | `"compact"` renders `1.5k` / `123M` and accepts compact notation when typing. `"comma"` adds thousands separators (e.g. `1,234,567`). Omit for plain numbers. |
| `Decimals` | `number` | — | Number of decimal places to display. Only meaningful when `Format` is omitted or `"comma"`. |
| `Prefix` | `string` | — | Non-editable text prepended to the displayed value (e.g. `"$"`). Stripped automatically when the user types a new value. |
| `Suffix` | `string` | — | Non-editable text appended to the displayed value (e.g. `"%"`). Stripped automatically when the user types a new value. |
| `Description` | `string` | — | Muted secondary line rendered below the label. |
| `Flag` | `string` | — | Config key used to persist the value across sessions. |
| `Callback` | `function(number)` | — | Called with the new value after each confirmed change. |

## API

| Method | Returns | Notes |
|---|---|---|
| `GetValue()` | `number` | Returns the current numeric value. |
| `SetValue(n)` | `nil` | Sets the value (clamped to `Min..Max`) and fires `Callback`. |
| `SetMin(n)` | `nil` | Updates the minimum bound; re-clamps the current value. |
| `SetMax(n)` | `nil` | Updates the maximum bound; re-clamps the current value. |
| `Destroy()` | `nil` | Removes the control from the UI. |

## Examples

```lua
-- Basic
tab:AddNumberBox({ Text = "Amount", Default = 10, Min = 0, Max = 100, Step = 5 })

-- With a description
tab:AddNumberBox({
  Text        = "Quantity",
  Description = "Steps of 1.",
  Default     = 5,
  Min         = 0,
  Max         = 50,
})

-- Compact notation (1.5k, 123M); type "2k" or "4.4m" directly
tab:AddNumberBox({
  Text    = "Gold",
  Format  = "compact",
  Default = 1500,
  Min     = 0,
  Max     = 1000000000,
  Step    = 100,
})

-- Comma grouping with a currency prefix
tab:AddNumberBox({
  Text    = "Balance",
  Format  = "comma",
  Prefix  = "$",
  Default = 1234567,
  Min     = 0,
  Max     = 1000000000,
  Step    = 1000,
})

-- Suffix unit
tab:AddNumberBox({ Text = "Volume", Suffix = "%", Default = 80, Min = 0, Max = 100, Step = 5 })

-- Flag-bound — value persists across sessions
tab:AddNumberBox({ Text = "Saved count", Flag = "ex_number", Default = 3, Min = 0, Max = 99 })

-- Adjust bounds at runtime
local nb = tab:AddNumberBox({ Text = "Score", Default = 50, Min = 0, Max = 100 })
nb.SetMax(200)   -- expand the ceiling
nb.SetValue(150) -- set a value that was previously out of range
```
