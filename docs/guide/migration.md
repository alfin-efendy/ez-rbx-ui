# Migration

## v2 → v3

v3 is a full rewrite with a clean-break API. The table below maps every changed surface from v2.

| v2 | v3 |
|---|---|
| `EzUI:CreateNew({ Name = ... })` | `EzUI:CreateWindow({ Title = ... })` |
| `Size = { Width, Height }` | unchanged |
| `tab = window:AddTab({ Name, Icon = "🏠" })` | `Icon = "home"` (Lucide name, not emoji) |
| `tab:AddLabel/AddButton/AddToggle/AddTextBox/AddNumberBox/AddSelectBox/AddSeparator` | same names |
| `window:ShowNotification/ShowSuccess/ShowError(...)` | `window:Notify/ShowSuccess/ShowError(...)` |
| `Colors` module (`utils/colors`) | `EzUI.Theme` tokens / `Theme` override |
| `EzUI:NewConfig(...)` | unchanged |
| flags (`Flag = "..."`) | unchanged |
| — | **new:** `AddSlider`, `AddKeybind`, `AddColorPicker`, `AddImage`, `AddProgressBar`, `AddTable`, `AddCard`, `AddResizable`, `AddTabGroup`, sidebar search, `Dialog`, `ResetConfiguration` |

v3 internals are a clean rewrite: engine-driven layout (`UIListLayout` + `AutomaticSize` + `UIFlex`) instead of manual Y positioning, a single-tween accordion (no O(n²) reflow), and `CanvasGroup` tab transitions.

The most significant new v3 controls and options are detailed below.

### `AddCard`

Windows and tabs expose `AddCard`, which renders a styled card surface with an optional banner image, title, body paragraph, and action buttons. It is **not** a host — it does not accept child controls. Pass all content via an options table and see [Card](/controls/card) for the full option set.

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

### `AddResizable`

A split-pane container control. Each pane is itself a control host, so you add controls into `Panes[i]` just like a tab or accordion. See [Resizable](/controls/resizable).

```lua
local rz = tab:AddResizable({ Direction = "Horizontal", Panes = { { Default = 0.4 }, { Default = 0.6 } } })
rz.Panes[1]:AddLabel("Left pane")
rz.Panes[2]:AddToggle({ Text = "Option" })
```

### `TextBox` — `LeadingIcon`, `Password`, and `Validate`

`AddTextBox` carries a rich option set (`components/textbox.lua`):

- **`LeadingIcon`** / **`TrailingIcon`** — Lucide icon names rendered inside the left/right edge of the input field.
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

See [TextBox](/controls/textbox) for the full option and method set (input-group buttons, `Clearable`, `SetLoading`, `SetValid`/`SetInvalid`, and more).

### `Description` on controls

Many controls accept a `Description` option that renders a secondary muted-text line below the label. Available on: `AddToggle`, `AddSlider`, `AddTextBox`, `AddSelectBox`, `AddKeybind`, `AddColorPicker`, `AddNumberBox`.

```lua
tab:AddToggle({
    Text = "Auto Farm",
    Description = "Automatically farms resources in the background.",
    Flag = "autofarm",
    Default = false,
})
```

### New `CreateWindow` options

v3 adds `Mode` (`"dark"` / `"light"`), `AutoAdapt`, `ConfirmClose`, `OnClose`, and `Parent`, plus live `GetMode()` / `SetMode()` methods for switching the color mode at runtime. See [Window & Tabs](/guide/window-and-tabs).
