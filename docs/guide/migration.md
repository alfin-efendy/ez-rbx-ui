# Migration

The current published release is **v2**. This documentation covers **v3**, which is in active development on this branch and **not yet released**. This page lists what changes when you move from the published v2 to v3.

::: info v3 is unreleased
The install snippets throughout these docs pull the **latest GitHub release**, which is still **v2** until v3 ships. Treat the v3-only features below as forthcoming.
:::

## v2 → v3

v3 keeps the v2 window and control API — every method documented for v2 is still present, with no renames or removals — and adds the following.

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

### `AddResizable`

A new split-pane container control. Each pane is itself a control host, so you add controls into `Panes[i]` just like a tab or accordion. See [Resizable](/controls/resizable).

```lua
local rz = tab:AddResizable({ Direction = "Horizontal", Panes = { { Default = 0.4 }, { Default = 0.6 } } })
rz.Panes[1]:AddLabel("Left pane")
rz.Panes[2]:AddToggle({ Text = "Option" })
```

### `TextBox` — `LeadingIcon`, `Password`, and `Validate`

`AddTextBox` gained several new options (`components/textbox.lua`):

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

Many controls now accept a `Description` option that renders a secondary muted-text line below the label. Confirmed on: `AddToggle`, `AddSlider`, `AddTextBox`, `AddSelectBox`, `AddKeybind`, `AddColorPicker`, `AddNumberBox`.

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
