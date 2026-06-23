# Paragraph

Multi-line wrapped text rendered in the muted foreground color. Height is automatic — the element grows to fit its content. Use it for descriptions, help text, and changelogs.

Text wraps automatically when a line is too long, and explicit `\n` line breaks are honored too — combine both for changelogs and release notes. A paragraph is a [Label](/controls/label) with `Variant = "paragraph"`, so it returns the same handle (`SetText`, `Destroy`) and supports the same **reactive (function-valued) text** — multi-line makes it a natural live status block.

## Basic usage

```lua
tab:AddParagraph("Paragraphs wrap long text and auto-size their height.")
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Text` | `string \| function` | `""` | The paragraph body. Also accepted as the first positional argument. Use `\n` for explicit line breaks. **If a function**, the paragraph becomes reactive (auto-updates every `Interval`) — see [Reactive text](#reactive-text-function-valued). |
| `Interval` | `number` | `1` | Seconds between re-evaluations when `Text` (or `SetText`) is a function. Ignored for a static string. |

## API

| Method | Returns | Notes |
|---|---|---|
| `SetText(v)` | `nil` | Replaces the text (height re-fits). Pass a **string** for a fixed value (stops polling if it was reactive), or a **function** to make it reactive. |
| `SetLocked(b)` | `nil` | Overlays a scrim that blocks interaction when `true`. |
| `Destroy()` | `nil` | Removes the element from the UI (and deregisters it from the reactive scheduler). |

## Reactive text (function-valued)

Pass a **function** instead of a string and EzUI re-evaluates it every `Interval` seconds (default `1`), rebuilding the (auto-sizing) paragraph for you:

```lua
-- live multi-line status block — pass the function, don't call it
tab:AddParagraph(function()
  return "State: " .. Farm:GetState() .. "\nQueue: " .. Farm:GetQueueText()
end)
```

The rules are identical to a reactive [Label](/controls/label#reactive-text-function-valued):

- **Pass the function, don't call it.** `AddParagraph(getStatus)` is reactive; `AddParagraph(getStatus())` runs the getter once and passes a static string.
- **Yielding getters are safe.** The getter runs on its own thread, so it may `InvokeServer`/`task.wait` without blocking window construction — which is exactly why you must pass it, not call it (calling it runs on your line and would stall construction there).
- `SetText(fn)`/`SetText("...")` toggle reactive/static; errors keep the last good value.

::: tip Executor note
On some executors the background scheduler can't write the GUI, so a reactive paragraph may not update there — drive it with `SetText(...)` from your own loop instead. See [Label → Reactive text](/controls/label#reactive-text-function-valued).
:::

## Examples

```lua
tab:AddParagraph(
  "Paragraphs wrap long text across multiple lines and auto-size their height. "
  .. "Use them for descriptions, changelogs, and help text within a tab."
)

-- Explicit line breaks with \n (e.g. a changelog)
local notes = tab:AddParagraph(
  "Changelog v3.1\n"
  .. "• Ratio is now a fraction of the screen\n"
  .. "• New StartHidden option\n"
  .. "• Bug fixes and polish"
)
-- SetText can rebuild it at runtime; the height re-fits
tab:AddButton({ Text = "Add a line", Callback = function()
  notes.SetText(notes.Frame.Text .. "\n• Appended at runtime")
end })

-- Inside an accordion
local acc = tab:AddAccordion({ Title = "Details", Icon = "rows-3" })
acc:AddParagraph("Nested paragraph text.")

-- Reactive multi-line status block: pass a function (don't call it)
acc:AddParagraph(function()
  return "Players: " .. #game.Players:GetPlayers() .. "\nUptime: " .. math.floor(os.clock()) .. "s"
end)
```
