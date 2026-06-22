# Card

A rich content card that can display an optional banner image, a title, a body paragraph, and a row of action buttons. All fields are optional — use only what you need.

## Basic usage

```lua
tab:AddCard({
  Title = "Announcement",
  Body  = "Something important happened.",
})
```

## Options

| Key | Type | Default | Notes |
|---|---|---|---|
| `Title` | `string` | — | Bold label rendered above the body. |
| `Body` | `string` | — | Wrapped muted paragraph rendered below the title. |
| `Banner` | `string` | — | Roblox asset ID (e.g. `"rbxassetid://…"`). Renders a cropped 80 px banner at the top of the card. Omit to show no banner. |
| `Buttons` | `{ { Text, Variant?, Callback? } }` | — | List of action buttons rendered in a horizontal row at the bottom of the card. Each entry maps to an [Button](/controls/button) with the same `Variant` values (`"default"`, `"secondary"`, `"ghost"`, `"destructive"`). |

## API

| Method | Returns | Notes |
|---|---|---|
| `SetLocked(b)` | `nil` | Overlays a scrim that blocks interaction when `true`. |
| `Destroy()` | `nil` | Removes the card from the UI. |

## Examples

```lua
-- Full card with banner and action buttons
tab:AddCard({
  Title  = "Announcement",
  Body   = "A rich card with a banner image and action buttons.",
  Banner = "rbxassetid://0",
  Buttons = {
    {
      Text     = "Confirm",
      Callback = function()
        window:ShowSuccess({ Title = "Confirmed" })
      end,
    },
    { Text = "Dismiss", Variant = "ghost" },
  },
})

-- Minimal card — title and body only
tab:AddCard({
  Title = "Note",
  Body  = "No banner, no buttons.",
})

-- Inside an accordion
local acc = tab:AddAccordion({ Title = "Details", Icon = "rows-3" })
acc:AddCard({ Title = "Nested", Body = "Card inside an accordion." })
```
