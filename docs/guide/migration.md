# Migration

## v1 → v2

v2 is a full rewrite with a clean-break API. The table below maps every changed surface.

| v1 | v2 |
|---|---|
| `EzUI:CreateNew({ Name = ... })` | `EzUI:CreateWindow({ Title = ... })` |
| `Size = { Width, Height }` | unchanged |
| `tab = window:AddTab({ Name, Icon = "🏠" })` | `Icon = "home"` (Lucide name, not emoji) |
| `tab:AddLabel/AddButton/AddToggle/AddTextBox/AddNumberBox/AddSelectBox/AddSeparator` | same names |
| `window:ShowNotification/ShowSuccess/ShowError(...)` | `window:Notify/ShowSuccess/ShowError(...)` |
| `Colors` module (`utils/colors`) | `EzUI.Theme` tokens / `Theme` override |
| `EzUI:NewConfig(...)` | unchanged |
| flags (`Flag = "..."`) | unchanged |
| — | **new:** `AddSlider`, `AddKeybind`, `AddColorPicker`, `AddImage`, `AddProgressBar`, `AddTable`, `AddTabGroup`, sidebar search, `Dialog`, `ResetConfiguration` |

v2 internals are a clean rewrite: engine-driven layout (`UIListLayout` + `AutomaticSize` + `UIFlex`) instead of manual Y positioning, a single-tween accordion (no O(n²) reflow), and `CanvasGroup` tab transitions.

---

## v2 → v3

v3 keeps the full v2 public API — no renames, no removals. The following additive features were confirmed in `components/` during implementation:

### `AddCard`

Windows and tabs now expose `AddCard`, a new v3 control that renders a styled card surface with an optional banner image, title, body paragraph, and action buttons. It is **not** a host — it does not accept child controls. Pass all content via an options table and see [Card](/controls/card) for the full option set.

```lua
tab:AddCard({
  Title = "Welcome",
  Body  = "A rich card with action buttons.",
  Buttons = {
    { Text = "Confirm", Callback = function() end },
    { Text = "Dismiss", Variant = "ghost" },
  },
})
```

### `TextBox` — `LeadingIcon`, `Password`, and `Validate`

`AddTextBox` gained three new options (`components/textbox.lua`):

- **`LeadingIcon`** — Lucide icon name rendered inside the left edge of the input field.
- **`Password`** — when `true`, masks the input and shows a reveal toggle button.
- **`Validate`** — a function `(value) -> ok, message` called on focus-lost. Displays an inline error message when `ok` is `false`.

```lua
tab:AddTextBox({
    Text = "Password",
    Password = true,
    LeadingIcon = "lock",
    Validate = function(v)
        if #v < 8 then return false, "Must be at least 8 characters" end
        return true
    end
})
```

### `Description` on Controls

Many controls now accept a `Description` option that renders a secondary muted-text line below the label. Confirmed on: `AddToggle`, `AddSlider`, `AddTextBox`, `AddSelectBox`, `AddKeybind`, `AddColorPicker`, `AddNumberBox`.

```lua
tab:AddToggle({
    Text = "Auto Farm",
    Description = "Automatically farms resources in the background.",
    Flag = "autofarm",
    Default = false,
})
```
