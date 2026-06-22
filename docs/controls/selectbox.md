# SelectBox

A dropdown for choosing one or many options, with optional search, per-item icons/descriptions, async loading, and flag persistence.

## Basic usage

```lua
local sel = tab:AddSelectBox({ Text = "Mode", Options = { "Auto", "Manual", "Hybrid" }, Default = "Auto" })
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string` | — | Field label |
| `Options` | `table` | `{}` | Strings, or `{ Value, Text/Label, Icon?, Desc? }`, or `{ Divider = true }` |
| `Default` | any | — | Selected value (or table of values when `Multi`) |
| `Multi` | `bool` | `false` | Allow multiple selections |
| `AllowNone` | `bool` | `false` | Permit an empty selection |
| `Searchable` | `bool` | auto | Search box; auto-shows for lists longer than 5 items |
| `Disabled` | `bool` | `false` | Non-interactive |
| `Loading` | `bool` | `false` | Show a spinner on the field |
| `Description` | `string` | — | Helper text under the label |
| `OnOpen` | `function` | — | `OnOpen(api)` — refresh options each time the dropdown opens |
| `Callback` | `function` | — | Called with the new value on change |
| `Flag` | `string` | — | Persist the selected `Value` to config |

When an option is a table, `Value` is stored/flagged and `Text`/`Label` is shown in the UI.

## API

| Method | Returns | Notes |
|---|---|---|
| `GetValue()` | any | Current value(s) |
| `SetValue(v)` | `nil` | Set selection programmatically |
| `SetOptions(o)` | `nil` | Replace the option list |
| `SetDisabled(b)` | `nil` | Enable/disable |
| `SetLoading(b)` | `nil` | Toggle the loading spinner |

## Examples

Single, multi, and per-item icon/description:

```lua
tab:AddSelectBox({ Text = "Tags", Options = { "A", "B", "C" }, Multi = true, Default = { "A" } })

tab:AddSelectBox({ Text = "Weapon", AllowNone = true, Options = {
  { Value = "Bow", Icon = "target", Desc = "Ranged" },
  { Divider = true },
  { Value = "Shield", Icon = "shield", Desc = "Defense" },
} })
```

Async load with `OnOpen` (the stored `Value` differs from the shown `Text`):

```lua
local WEAPON_DB = { wpn_001 = "Bow", wpn_002 = "Shield", wpn_003 = "Sword" }
local function weaponOptions()
  local out = {}
  for id, name in pairs(WEAPON_DB) do out[#out + 1] = { Value = id, Text = name } end
  return out
end

local wsel = tab:AddSelectBox({ Text = "Weapon", Flag = "weapon_id", Loading = true, Options = {},
  OnOpen = function(api) api.SetOptions(weaponOptions()) end })

wsel.SetLoading(true)
task.delay(1.5, function() wsel.SetOptions(weaponOptions()); wsel.SetLoading(false) end)
```

Runtime option replacement and callback notification:

```lua
local sel = tab:AddSelectBox({ Text = "Mode", Options = { "Auto", "Manual", "Hybrid" }, Default = "Auto" })

-- shuffle options at runtime
sel.SetOptions({ "Apple", "Banana", "Cherry" })

-- flag-bound — value persists across sessions
tab:AddSelectBox({ Text = "Saved choice", Flag = "ex_select", Options = { "One", "Two", "Three" }, Default = "One" })

-- notify on change
tab:AddSelectBox({ Text = "Notify", Options = { "Red", "Green", "Blue" }, Default = "Red",
  Callback = function(v) print("Picked:", v) end })
```
