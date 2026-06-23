# Controls reference

Call these on a `tab` (from `Window:AddTab`) or an `accordion` (from `host:AddAccordion`).
Identical API on both. Any control with a `Flag` auto-persists when the window has a `Config`.

## AddToggle
`host:AddToggle(opts)` — an on/off switch.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | `"Toggle"` | label |
| Default | boolean | `false` | initial state |
| Description | string | nil | muted secondary line below label |
| Flag | string | nil | persists when window has Config |
| Callback | function | nil | receives the new boolean |

**Returns:** `{ Get() -> boolean, Set(v: boolean), OnChanged(fn), Destroy() }`

```lua
local t = tab:AddToggle({ Text = "Auto Farm", Default = false, Flag = "autofarm",
  Callback = function(on) print(on) end })
t.Set(true)
```

## AddSelectBox
`host:AddSelectBox(opts)` — a dropdown (single or multi-select).

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | — | label |
| Options | table | `{}` | array of strings, or `{ Value, Text/Label, Icon?, Desc? }`, or `{ Divider = true }` |
| Default | any | — | matches `Value` |
| Multi | boolean | `false` | multi-select |
| AllowNone | boolean | `false` | allow empty selection |
| Searchable | boolean | auto | search box (auto-shows for lists longer than 5 items) |
| Disabled | boolean | `false` | non-interactive |
| Loading | boolean | `false` | spinner state |
| Description | string | nil | helper text under label |
| OnOpen | function | nil | `OnOpen(api)` — refresh options on open; combine with `api.Reload()` to refetch every open |
| LoadOptions | function | nil | async provider returning the options table (may yield). Shows `Loading…` (value hidden) until it returns; runs non-blocking |
| Timeout | number | `60` | seconds before `LoadOptions` is given up on and the loading state clears |
| Flag | string | nil | stores `Value` |
| Callback | function | nil | receives the new value on change |

**Returns:** `{ GetValue(), SetValue(v), SetOptions(o), SetDisabled(b), SetLoading(b), Reload() }`

```lua
local s = tab:AddSelectBox({ Text = "Mode", Multi = true, Searchable = true,
  Options = { { Value = "a", Text = "Alpha" }, { Value = "b", Text = "Beta" } },
  Flag = "modes" })

-- async: one function returns the options (may yield). The field shows "Loading…" until it
-- returns; no manual SetLoading. Default pre-selects; Reload() re-runs it.
tab:AddSelectBox({ Text = "Weapon", Flag = "weapon", Default = "wpn_005",
  LoadOptions = function() return fetchWeapons() end })  -- -> { { Value, Text }, ... }
```

## AddLabel
`host:AddLabel(opts)` — a text element in the default foreground color. Single-line by default; pass `Variant = "paragraph"` for a multi-line label that wraps and auto-sizes its height.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string \| function | `""` | label text; also accepted as the first positional argument. Honors explicit `\n` line breaks when `Variant = "paragraph"`. **If a function**, EzUI re-evaluates it on `Interval` and updates the label itself (see Reactive text below) |
| Interval | number | `1` | seconds between re-evaluations when `Text` (or `SetText`) is a function. Ignored for a static string |
| Variant | string | `"default"` | `"default"` (single line), `"paragraph"` (wraps + auto-height, muted color), `"section"` (uppercased heading). `AddParagraph`/`AddSection` are shorthands for the latter two |

**Returns:** `{ Frame, SetText(s), SetLocked(b), Destroy() }` — `SetText` accepts a string (static) or a function (reactive).

```lua
local lbl = tab:AddLabel("Hello, world!")
lbl.SetText("Updated at runtime!")

-- multi-line label: a default label is single-line (extra lines clip), so use the paragraph variant
tab:AddLabel({ Variant = "paragraph", Text = "First line\nSecond line\nWraps automatically too." })
```

**Reactive text (function-valued).** Pass a function instead of a string and EzUI re-evaluates it every `Interval` seconds (default 1), updating the label for you — no manual loop. One shared `Heartbeat` scheduler drives every reactive label (active only while ≥1 exists), it's capability-safe, and a value that hasn't changed isn't re-written. If the function errors, the last good value is kept and a warning is logged once. `SetText(fn)` switches a static label to reactive; `SetText("...")` switches it back and stops polling; `Destroy()` deregisters it.

- **Pass the function — don't call it.** `AddLabel(getter)` is reactive; `AddLabel(getter())` runs the getter ONCE and passes the resulting string → a static label that never updates.
- **Yielding getters are safe.** The getter runs on its own thread, so it may yield (`RemoteFunction:InvokeServer`/`task.wait`/`WaitForChild`) without blocking window construction. This is the other reason to pass it, not call it: `getter()` runs on your line, so a yielding getter there stalls construction and the controls after it never appear.
- Executor note: on some capability-strict executors the background scheduler can't write the GUI, so the reactive text may not visibly update — fall back to `SetText(...)` from your own loop there.

```lua
tab:AddLabel(function() return "Clock: " .. os.date("%H:%M:%S") end)            -- polls every 1s; pass the fn, don't call it
tab:AddLabel({ Text = function() return "FPS: " .. getFps() end, Interval = 0.5 })
local s = function() return Boss:GetStatusText() end                            -- a named getter (may InvokeServer/yield)
acc:AddLabel(s)        -- reactive (good)        acc:AddLabel(s())  -- static, called once (wrong)
```

## AddParagraph
`host:AddParagraph(opts)` — multi-line wrapped text in the muted foreground color; auto-sizes height. Honors explicit `\n` line breaks in addition to automatic wrapping. (Shorthand for `AddLabel` with `Variant = "paragraph"`.)

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string \| function | `""` | paragraph body; also accepted as the first positional argument. Use `\n` for explicit line breaks. **If a function**, it auto-updates every `Interval` (see Reactive text under `AddLabel`) — multi-line makes it a natural live status block |
| Interval | number | `1` | seconds between re-evaluations when `Text`/`SetText` is a function |

**Returns:** `{ Frame, SetText(s), SetLocked(b), Destroy() }` — `SetText` accepts a string (static) or a function (reactive).

```lua
tab:AddParagraph("Use paragraphs for descriptions, changelogs, and help text.")

-- explicit line breaks (e.g. a changelog); SetText can rebuild it at runtime
local notes = tab:AddParagraph("Changelog v3.1\n• Ratio is now a screen fraction\n• New StartHidden option")
notes.SetText(notes.Frame.Text .. "\n• Appended at runtime")

-- reactive multi-line status block: a function auto-updates every Interval (default 1s)
tab:AddParagraph(function() return "Clock: " .. os.date("%H:%M:%S") .. "\nUptime: " .. uptime() .. "s" end)
```

## AddSection
`host:AddSection(opts)` — an uppercase group heading that visually separates related controls.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | `""` | heading text; automatically uppercased; also accepted as the first positional string argument |

**Returns:** no return API (no handle methods documented)

```lua
tab:AddSection("General")
tab:AddSection("Advanced")
```

## AddSeparator
`host:AddSeparator()` — a 1 px horizontal divider in the border color; takes no options.

**Returns:** no return API (no handle methods documented)

```lua
tab:AddLabel("Above the separator")
tab:AddSeparator()
tab:AddLabel("Below the separator")
```

## AddButton
`host:AddButton(opts)` — a clickable action element in one of five visual variants.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | `"Button"` | label displayed on the button |
| Variant | string | `"default"` | `"default"`, `"secondary"`, `"outline"`, `"ghost"`, `"destructive"` |
| Icon | string | nil | Lucide icon name rendered left of the label |
| Callback | function | nil | called with no arguments when clicked |
| Action | string | nil | pass `"ResetConfig"` to wire built-in config-reset without a callback |

**Returns:** `{ SetText(s), SetEnabled(b), Destroy() }`

```lua
tab:AddButton({ Text = "Run", Variant = "default", Icon = "play",
  Callback = function() print("clicked") end })
```

## AddTextBox
`host:AddTextBox(opts)` — a single-line text input with optional icon, prefix/suffix, inline buttons, validation, and persistence.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | nil | row label; omit for full-width label-less input |
| Default | string | `""` | initial text value |
| Placeholder | string | `""` | ghost text shown when empty |
| Description | string | nil | muted secondary line below label |
| MaxLength | number | nil | truncates input silently at this character count |
| Copyable | boolean | `false` | read-only + adds a copy icon button |
| LeadingIcon | string | nil | Lucide icon at left edge of input |
| Prefix | string | nil | non-editable text before the caret (e.g. `"$"`) |
| Suffix | string | nil | non-editable text after editable area (e.g. `"USD"`) |
| TrailingIcon | string | nil | Lucide icon at right edge of input |
| Loading | boolean | `false` | starts in loading/spinner state |
| FullWidth | boolean | `false` | stacks label above input (recommended with Prefix/Suffix/Buttons) |
| Password | boolean | `false` | masks value; adds eye/eye-off reveal button |
| Clearable | boolean | `false` | shows × button when non-empty |
| Disabled | boolean | `false` | non-editable and dimmed |
| Buttons | table | nil | `{ { Icon?\|Text?, Tooltip?, Variant?, Callback?(text, ctl) } }` action buttons at right |
| Validate | function | nil | `(text) -> (ok, message)` — called on focus-loss; false turns border red |
| Flag | string | nil | persists when window has Config |
| Callback | function | nil | `(text, ctl)` — called on focus-loss |

**Returns:** `{ GetText(), SetText(s), Focus(), Clear(), SetLoading(b), SetValid(), SetInvalid(msg), SetDisabled(b), Destroy() }`

```lua
local tb = tab:AddTextBox({ Text = "Name", Placeholder = "Type your name…", Flag = "username" })
print(tb.GetText())
```

## AddNumberBox
`host:AddNumberBox(opts)` — a numeric input with − and + step buttons, scroll-wheel support, and optional compact/comma formatting.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | nil | row label; omit for full-width label-less input |
| Default | number | `0` | initial value, clamped to Min..Max |
| Min | number | nil | minimum allowed value |
| Max | number | nil | maximum allowed value |
| Step | number | `1` | amount per button press or scroll tick |
| Format | string | nil | `"compact"` (1.5k/123M) or `"comma"` (1,234,567); omit for plain |
| Decimals | number | nil | decimal places to display (omit or plain format only) |
| Prefix | string | nil | non-editable text before value (e.g. `"$"`) |
| Suffix | string | nil | non-editable text after value (e.g. `"%"`) |
| Description | string | nil | muted secondary line below label |
| Flag | string | nil | persists when window has Config |
| Callback | function | nil | receives the new number after each confirmed change |

**Returns:** `{ GetValue(), SetValue(n), SetMin(n), SetMax(n), Destroy() }`

```lua
local nb = tab:AddNumberBox({ Text = "Speed", Default = 50, Min = 0, Max = 200, Step = 5,
  Suffix = "%", Flag = "speed" })
nb.SetMax(300)
```

## AddSlider
`host:AddSlider(opts)` — a horizontal drag control for selecting a numeric value within a fixed range.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | nil | row label |
| Min | number | `0` | left end of track |
| Max | number | `100` | right end of track |
| Default | number | Min | initial value, snapped to nearest Step |
| Step | number | `1` | snap increment |
| Description | string | nil | muted secondary line below label |
| Flag | string | nil | persists when window has Config |
| Callback | function | nil | receives the new number after each drag or SetValue |

**Returns:** `{ GetValue(), SetValue(n), OnChanged(fn), Destroy() }`

```lua
local s = tab:AddSlider({ Text = "Volume", Min = 0, Max = 100, Default = 80, Flag = "volume",
  Callback = function(v) print("vol:", v) end })
s.SetValue(50)
```

## AddKeybind
`host:AddKeybind(opts)` — a keyboard shortcut recorder; click to listen, next key pressed becomes the binding.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | `"Keybind"` | label left of the key badge |
| Default | Enum.KeyCode | `Enum.KeyCode.Unknown` | initial key binding |
| Description | string | nil | muted secondary line below label |
| Flag | string | nil | persists when window has Config |
| Callback | function | nil | called (no arguments) when the bound key is pressed |

**Returns:** `{ GetKey() -> Enum.KeyCode, SetKey(k), OnPressed(fn), Destroy() }`

```lua
local kb = tab:AddKeybind({ Text = "Toggle UI", Default = Enum.KeyCode.RightShift, Flag = "toggleKey",
  Callback = function() print("pressed") end })
kb.SetKey(Enum.KeyCode.P)
```

## AddColorPicker
`host:AddColorPicker(opts)` — an inline color swatch that opens a floating HSV picker on click.

| Option | Type | Default | Notes |
|---|---|---|---|
| Text | string | `"Color"` | label left of the swatch |
| Default | Color3 | `Color3.fromRGB(255,255,255)` | initial color |
| Description | string | nil | muted secondary line below label |
| Flag | string | nil | persists as `{r,g,b}` (0–255) when window has Config |
| Callback | function | nil | receives the new `Color3` on every change |

**Returns:** `{ GetColor() -> Color3, SetColor(c), Destroy() }`

```lua
local cp = tab:AddColorPicker({ Text = "Tint", Default = Color3.fromRGB(120, 160, 255), Flag = "tint",
  Callback = function(c) print("color", c) end })
cp.SetColor(Color3.fromRGB(255, 0, 0))
```

## AddImage
`host:AddImage(opts)` — displays a Roblox asset image or a Lucide icon glyph at a fixed height.

| Option | Type | Default | Notes |
|---|---|---|---|
| Image | string | `""` | Roblox asset ID string (e.g. `"rbxassetid://…"`); mutually exclusive with Lucide |
| Lucide | string | nil | Lucide icon name rendered as a glyph |
| Height | number | `80` | height in pixels; width is always 100% |
| Color | Color3 | varies | tint color; defaults to theme foreground for Lucide, white for Image |

**Returns:** `{ SetImage(v), Destroy() }`

```lua
tab:AddImage({ Lucide = "gamepad-2", Height = 64 })
-- or a raw asset:
tab:AddImage({ Image = "rbxassetid://12345678", Height = 80 })
```

## AddTable
`host:AddTable(opts)` — a scrollable data table with a fixed header row and scrollable body.

| Option | Type | Default | Notes |
|---|---|---|---|
| Columns | table | `{}` | array of column header label strings |
| Rows | table | `{}` | initial row data; each row is `{ string, ... }` matching column count |
| Height | number | `120` | height (px) of the scrollable body; total height = Height + 26 (header) |

**Returns:** `{ AddRow(cells) -> Frame, SetData(rows), Clear(), Destroy() }`

```lua
local t = tab:AddTable({
  Columns = { "Player", "Kills", "Deaths" },
  Rows = { { "Alpha", "12", "3" }, { "Bravo", "8", "5" } },
})
t.AddRow({ "Charlie", "15", "1" })
```

## AddProgressBar
`host:AddProgressBar(opts)` — an animated horizontal fill bar representing a value between 0 and 1.

| Option | Type | Default | Notes |
|---|---|---|---|
| Default | number | `0` | initial fill value, clamped to 0..1 |
| Color | Color3 | theme primary | override fill color |

**Returns:** `{ Get() -> number, Set(p), SetLocked(b), Destroy() }`

```lua
local pb = tab:AddProgressBar({ Default = 0.2 })
pb.Set(0.8)   -- animate fill to 80%
```

## AddResizable
`host:AddResizable(opts)` — a split-pane container with a draggable grip; each pane is a full control host.

| Option | Type | Default | Notes |
|---|---|---|---|
| Direction | string | `"Horizontal"` | `"Horizontal"` (side-by-side) or `"Vertical"` (stacked) |
| Panes | table | two equal panes | array of `{ Default?, Min? }` pane definitions; Default = initial size fraction, Min = minimum fraction (default `0.1`) |
| Height | number | `160` (H) / `200` (V) | container height in pixels |

**Returns:** `{ Panes: host[], Destroy() }` — each `Panes[i]` supports the full `Add*` control API

```lua
local rz = tab:AddResizable({
  Direction = "Horizontal",
  Panes = { { Default = 0.4 }, { Default = 0.6 } },
  Height = 140,
})
rz.Panes[1]:AddLabel("Left")
rz.Panes[2]:AddToggle({ Text = "Option" })
```

## AddCard
`host:AddCard(opts)` — a rich content card with optional banner image, title, body paragraph, and action buttons.

| Option | Type | Default | Notes |
|---|---|---|---|
| Title | string | nil | bold label above the body |
| Body | string | nil | wrapped muted paragraph below the title |
| Banner | string | nil | Roblox asset ID for an 80 px banner image at the top |
| Buttons | table | nil | `{ { Text, Variant?, Callback? } }` action buttons at the bottom |

**Returns:** `{ SetLocked(b), Destroy() }`

```lua
tab:AddCard({
  Title = "Announcement",
  Body  = "Something important happened.",
  Buttons = {
    { Text = "Confirm", Callback = function() print("confirmed") end },
    { Text = "Dismiss", Variant = "ghost" },
  },
})
```

## AddAccordion
`host:AddAccordion(opts)` — a collapsible card that hosts any controls; clicking the header toggles the body open/closed.

| Option | Type | Default | Notes |
|---|---|---|---|
| Title | string | `"Section"` | header text |
| Icon | string | nil | Lucide icon name shown left of title |
| Expanded | boolean | `false` | when `true` the accordion starts open |

**Returns:** `{ Toggle() -> boolean, Expand(), Collapse(), IsExpanded() -> boolean, SetTitle(s), SetIcon(name)† , Destroy() }` plus all `Add*` control methods
† Only applies when an Icon was set at creation.

```lua
local acc = tab:AddAccordion({ Title = "Advanced", Icon = "settings-2", Expanded = false })
acc:AddToggle({ Text = "Nested toggle", Default = true })
acc:AddSlider({ Text = "Nested slider", Min = 0, Max = 10, Default = 5 })
acc:Expand()
```
