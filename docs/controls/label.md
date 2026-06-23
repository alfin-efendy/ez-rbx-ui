# Label

A text element that renders in the default foreground color. It returns a handle so the text can be updated at runtime via `SetText`. Single-line by default; use `Variant = "paragraph"` for a multi-line label.

`Text` may be a **string** (static) or a **function** (reactive — EzUI re-evaluates it on an interval and updates the label for you). See [Reactive text](#reactive-text-function-valued).

## Basic usage

```lua
tab:AddLabel("Hello, world!")
-- or with an options table
tab:AddLabel({ Text = "Hello, world!" })
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string \| function` | `""` | Label text. Also accepted as the first positional argument. Honors explicit `\n` line breaks when `Variant = "paragraph"`. **If a function**, the label becomes reactive — see [Reactive text](#reactive-text-function-valued). |
| `Interval` | `number` | `1` | Seconds between re-evaluations when `Text` (or `SetText`) is a function. Ignored for a static string. |
| `Variant` | `string` | `"default"` | `"default"` — single line (extra lines are clipped). `"paragraph"` — wraps and auto-sizes its height, in the muted color. `"section"` — an uppercased group heading. `AddParagraph` and `AddSection` are shorthands for the last two. |

## API

| Method | Returns | Notes |
|---|---|---|
| `SetText(v)` | `nil` | Replaces the text. Pass a **string** to set a fixed value (and stop polling if it was reactive), or a **function** to make it reactive — see [Reactive text](#reactive-text-function-valued). |
| `SetLocked(b)` | `nil` | Overlays a scrim that blocks interaction when `true`. |
| `Destroy()` | `nil` | Removes the element from the UI (and deregisters it from the reactive scheduler). |

## Reactive text (function-valued)

Pass a **function** instead of a string and EzUI re-evaluates it every `Interval` seconds (default `1`) and updates the label for you — no manual loop:

```lua
tab:AddLabel(function() return "Clock: " .. os.date("%H:%M:%S") end)            -- polls every 1s
tab:AddLabel({ Text = function() return "Coins: " .. getCoins() end, Interval = 0.5 })
```

### Pass the function — don't call it

This is the one thing to get right. Pass the function **reference**; do not call it yourself:

```lua
local function bossStatus() return Boss:GetStatusText() end

acc:AddLabel(bossStatus)        -- ✅ reactive: EzUI calls it every Interval and updates the label
acc:AddLabel(bossStatus())      -- ❌ this CALLS it once and passes the resulting string → a static label
```

`AddLabel(getter)` is reactive; `AddLabel(getter())` runs the getter a single time and passes its result, so the label never updates.

### Yielding getters are safe

The getter runs on its own thread, so it may **yield** — a `RemoteFunction:InvokeServer`, `task.wait`, `WaitForChild`, etc. — without blocking window construction or the other controls. This is the other reason to pass the function instead of calling it: `getter()` runs on *your* line, so a yielding getter there stalls construction at that point and the controls after it never appear.

```lua
-- A getter that fetches from the server is fine — just pass it, don't call it.
tab:AddParagraph(function() return Stats:Fetch().Summary end)   -- may InvokeServer/yield internally
```

### Behavior

- One shared `Heartbeat` scheduler drives every reactive label (it only runs while at least one exists). A value that hasn't changed isn't re-written.
- If the getter errors, the label keeps its last good value and a warning is logged once.
- `SetText(fn)` switches a static label to reactive; `SetText("...")` switches it back to static and stops polling; `Destroy()` deregisters it.

::: tip Executor note
On some executors the background scheduler isn't allowed to write the GUI, so a reactive label may not visibly update there. If that happens, drive the text with `SetText(...)` from your own loop (which runs in a context that *can* write) instead of passing a function.
:::

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

-- Multi-line label: a default label is single-line (extra lines clip), so use the
-- paragraph variant — it wraps, auto-sizes its height, and honors explicit \n breaks.
tab:AddLabel({
  Variant = "paragraph",
  Text = "First line\nSecond line\nThird line — wraps automatically when a line is too long to fit.",
})

-- Label inside an accordion
local acc = tab:AddAccordion({ Title = "Advanced", Icon = "rows-3" })
acc:AddLabel("Nested label")

-- Reactive label: pass a function (don't call it) — EzUI updates it every Interval
acc:AddLabel(function() return "Ping: " .. getPing() .. "ms" end)
```
