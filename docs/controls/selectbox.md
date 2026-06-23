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
| `LoadOptions` | `function` | — | Provider that returns the options table. While the call is pending the field shows `Loading…` (the value is hidden) and the dropdown shows a loading row; both clear when the function returns. Runs **synchronously** on the calling thread (at creation, or inside the `Reload`/`OnOpen` handler) so the GUI update keeps the executor capability needed to mutate a protected (`gethui`/`CoreGui`) UI — a loader that yields briefly blocks the caller, but most read cached data. Combine with `OnOpen = function(api) api.Reload() end` to refetch on every open. |
| `Timeout` | `number` | `60` | Seconds after which the loading spinner is cleared if `LoadOptions` has not returned. A result that arrives later still applies. |
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
| `Reload()` | `nil` | Re-run `LoadOptions` (loading state is handled automatically) |

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

Async load with `LoadOptions` — one function returns the options (it may yield). The field
shows its loading state automatically until the function returns, and the call is async so it
never blocks other controls. The stored `Value` differs from the shown `Text`:

```lua
local WEAPON_DB = { wpn_001 = "Bow", wpn_002 = "Shield", wpn_003 = "Sword" }
local function weaponOptions()
  task.wait(3) -- HTTP, datastore, etc. — may take a few seconds
  local out = {}
  for id, name in pairs(WEAPON_DB) do out[#out + 1] = { Value = id, Text = name } end
  return out
end

-- loads on creation; Timeout defaults to 60s. No manual SetLoading needed.
local wsel = tab:AddSelectBox({ Text = "Weapon", Flag = "weapon_id", LoadOptions = weaponOptions })

-- re-run the loader any time (loading is handled for you)
tab:AddButton({ Text = "Reload", Callback = function() wsel.Reload() end })
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
