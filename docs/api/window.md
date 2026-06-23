# Window API

The `Window` object is returned by `EzUI:CreateWindow(config)`. All tab management, visibility control, notifications, and dialogs are methods on this object.

## `EzUI:CreateWindow(config)`

Creates and displays a new window. Returns a `Window` object.

```lua
local Window = EzUI:CreateWindow({
    Title = "My Hub",
    Subtitle = "v3.0",
    Image = "rbxassetid://0",
    Ratio = 16/10,
    Transparency = 0.12,
    Animations = true,
    ToggleKey = Enum.KeyCode.RightControl,
    FloatingToggle = { Type = "simple", AutoHide = true },
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})
```

### Config Table

| Key | Type | Description |
|---|---|---|
| `Title` | `string` | Title-bar text |
| `Subtitle` | `string` | Secondary line shown under the title (grows the title bar) |
| `Image` | `string` | Title-bar logo image — `rbxassetid://` / `rbxthumb://` or an `http(s)://` URL |
| `Ratio` | `number` \| `{ Width, Height }` | Window aspect ratio (shape); the window auto-fits the viewport and stays responsive. Default `4/3` |
| `Transparency` | `number` | Window background transparency `0..1`; `0` = opaque, higher = more see-through. Default `0.12` |
| `Animations` | `bool` | Enable entrance/transition motion (FAB pop, window open/close, accordion + tab transitions). Default `true`. Pass `false` for reduced/instant motion on low-end devices or for accessibility |
| `ToggleKey` | `Enum.KeyCode` | Show/hide key (default `RightControl`) |
| `FloatingToggle` | `table` | Floating toggle button config — see [FloatingToggle config](#floatingtoggle-config). Pass `false` to disable |
| `Mode` | `"dark"` \| `"light"` | Initial color mode; default `"dark"`. See [Color mode](#color-mode) |
| `ConfirmClose` | `bool` | Show a confirm dialog before closing; default `true`. Pass `false` to close immediately |
| `OnClose` | `function` | Called (pcall-wrapped) when the window closes |
| `Parent` | `Instance` | Optional parent for the GUI; useful for custom mount points |
| `Theme` | `table` | Override design tokens (see [Theming](/guide/theming)) |
| `Config` | `{ Enabled, FileName, FolderName, AutoSave, AutoLoad }` | Flag persistence options (see [Config & Flags](/guide/config-and-flags)) |

---

## Tab Methods

### `AddTab(opts)`

Adds a tab to the sidebar and returns a tab object. The tab object supports all [Controls](/controls/) methods.

```lua
local tab = Window:AddTab({ Name = "Home", Icon = "home" })
```

| Key | Type | Description |
|---|---|---|
| `Name` | `string` | Tab label shown in the sidebar |
| `Icon` | `string` | Lucide icon name (see [Icons](/guide/icons)) |

### `AddTabGroup(name)`

Adds a named sidebar category group and returns a group object. Call `group:AddTab(opts)` to add tabs inside the group.

```lua
local group = Window:AddTabGroup("Main")
group:AddTab({ Name = "Home", Icon = "home" })
```

### `SearchTabs(query)`

Filters the sidebar tabs and their controls by the given text string. An empty string clears the filter. The built-in sidebar search field calls this method automatically.

```lua
Window:SearchTabs("farm")
```

---

## Visibility Methods

### `Show()`

Makes the window visible.

### `Hide()`

Hides the window without destroying it.

### `Toggle()`

Toggles visibility: shows if hidden, hides if visible.

### `IsVisible()`

Returns `true` if the window is currently visible, `false` otherwise.

### `Minimize()`

Hides the window and reveals the floating toggle button so the user can reopen it.

---

## Window Control Methods

### `SetTitle(s)`

Sets the window title-bar text to `s`.

### `SetSubtitle(s)`

Sets the subtitle line shown under the title. Requires the window to have been created with a `Subtitle` (the slot is built at creation).

### `SetImage(v)`

Updates the title-bar image. Accepts an `rbxassetid://` id or an `http(s)://` URL. Requires the window to have been created with an `Image`.

### `SetTransparency(n)`

Sets the window background transparency, `n` in `0..1` (`0` = opaque).

### `SetAnimationsEnabled(b)`

Toggles all library motion at runtime (`true` = animated, `false` = instant). The setting is process-wide; with multiple windows the last call wins.

### `AdaptToViewport()`

Re-fits the window to the current viewport, preserving the configured `Ratio`. A window the user hasn't moved is re-centered; once the user drags or resizes it, its position is kept (clamped on-screen) instead. Called automatically on creation and whenever the viewport size changes — the window is always responsive.

### `GetMode()`

Returns the current color mode: `"dark"` or `"light"`.

### `SetMode(mode)`

Switches the color palette live. Pass `"dark"` or `"light"`. Controls re-skin immediately without recreating the window.

### `SetFloatingToggleVisible(b)`

Shows (`b = true`) or hides (`b = false`) the floating toggle button.

### `SetFloatingToggle(opts)`

Rebuilds the floating toggle button at runtime with a new options table (the same shape as the [FloatingToggle config](#floatingtoggle-config)). Re-enables the button if it was disabled, and shows it immediately when `AutoHide = false`.

```lua
Window:SetFloatingToggle({ Type = "circle", Image = "rbxassetid://123" })
```

### FloatingToggle config

The `FloatingToggle` config key accepts a table (or `false` to disable the button entirely):

| Key | Type | Description |
|---|---|---|
| `Type` | `string` | `"simple"` (default) docks a chevron tab at the screen edge; `"circle"` is an accent-colored round button; `"square"` is a rounded surface tile |
| `Image` | `string` | Icon for the `circle`/`square` button — `rbxassetid://` / `rbxthumb://` or an `http(s)://` URL (falls back to a controller icon) |
| `Position` | `string` \| `UDim2` | Anchor — `"TopLeft"`, `"MidLeft"`, `"BottomLeft"`, `"TopRight"`, `"MidRight"`, `"BottomRight"`, or a raw `UDim2`. For `simple` it sets which edge the tab docks to (and its height); for `circle`/`square` it places the button fully visible at that anchor. Default: `simple` → `MidLeft`, others → `TopLeft` |
| `Size` | `{ Width, Height }` \| `UDim2` | Button size in pixels |
| `Draggable` | `bool` | When `true` (default), the player can drag the button; on release it magnet-snaps to the nearest left/right edge |
| `AutoHide` | `bool` | `true` (default) shows the button only while the window is hidden; `false` keeps it visible at all times (a persistent open/close toggle) |

```lua
EzUI:CreateWindow({
    FloatingToggle = {
        Type = "circle",
        Image = "rbxassetid://123",
        Position = "BottomRight",
        Size = { Width = 56, Height = 56 },
        AutoHide = false,
    },
})
```

With `FloatingToggle = false` the button is not created, and players can reopen the window only via the `ToggleKey` — avoid this on touch-only experiences.

### `Destroy()`

Closes the window, disconnects all connections, and destroys the UI. Equivalent to `Window:Close()`.

---

## Notification Methods

See [Notifications & Dialog](/guide/notifications-dialog) for full option details and examples.

### `Notify(opts)`

Shows a toast notification with full control over all options. Returns an `id` that can be passed to `DismissNotification`.

```lua
local id = Window:Notify({
    Title = "Item deleted",
    Type = "warning",
    Duration = 5000,
    Action = { Text = "Undo", Callback = function() end },
    OnDismiss = function() end,
})
```

| Key | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | required | Notification heading |
| `Message` | `string` | `nil` | Optional body text |
| `Type` | `string` | `"default"` | One of `"success"`, `"warning"`, `"error"`, `"info"` |
| `Duration` | `number` | `4000` | Auto-dismiss delay in milliseconds |
| `Action` | `{ Text, Callback }` | `nil` | Optional action button shown in the toast |
| `OnDismiss` | `function` | `nil` | Called when the toast is dismissed |

### `ShowSuccess(opts)`

Shorthand for `Notify` with `Type = "success"`.

### `ShowWarning(opts)`

Shorthand for `Notify` with `Type = "warning"`.

### `ShowError(opts)`

Shorthand for `Notify` with `Type = "error"`.

### `ShowInfo(opts)`

Shorthand for `Notify` with `Type = "info"`.

### `DismissNotification(id)`

Dismisses the notification identified by `id` (the value returned by `Notify`).

### `ClearNotifications()`

Dismisses all active notifications immediately.

---

## Dialog Method

See [Notifications & Dialog](/guide/notifications-dialog) for full option details and examples.

### `Dialog(opts)`

Opens a dimmed modal overlay with a title, optional message, and one or more buttons.

```lua
Window:Dialog({
    Title = "Delete item?",
    Message = "This cannot be undone.",
    Buttons = {
        { Text = "Cancel", Variant = "secondary" },
        { Text = "Delete", Variant = "destructive", Callback = function()
            Window:ShowSuccess({ Title = "Deleted" })
        end },
    },
})
```

| Key | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | required | Dialog heading |
| `Message` | `string` | `nil` | Optional body text |
| `Buttons` | `array` | required | One or more button descriptors (`{ Text, Variant?, Callback? }`) |
| `Modal` | `bool` | `true` | Dim the background while the dialog is open |

---

## Config Methods

See [Config & Flags](/guide/config-and-flags) for full details.

### `ResetConfiguration(opts)`

Restores all flagged controls to their default values. With `Confirm = true` (the default) it shows a confirmation dialog first, then toasts success.

| Option | Default | Description |
|---|---|---|
| `Confirm` | `true` | Show a confirmation dialog before resetting |
| `ClearFile` | `false` | Also delete the saved file from disk |

### `ResetFlag(flag)`

Resets a single flag to its default value without confirmation.

### `.Config`

The config object attached to this window (`EzUI:NewConfig` instance). Use it to call `cfg:Get(k)`, `cfg:Set(k, v)`, or other [Config API](/api/core#config) methods directly.

---

## Color mode

EzUI ships `dark` (default) and `light` palettes. Choose at creation time with the `Mode` config key, or switch the running window with `SetMode`:

```lua
-- Light mode from the start
local Window = EzUI:CreateWindow({ Mode = "light" })

-- Switch live at runtime
Window:SetMode("light")

-- Read the current mode
print(Window:GetMode()) -- "light"
```

See [Theming — Color mode](/guide/theming#color-mode-dark-light) for the full palette reference.

## Parenting & stealth

`CreateWindow` resolves where to mount the UI automatically via a fallback chain:
`gethui()` → `protect_gui` + `CoreGui` → `CoreGui` → `PlayerGui`. It also applies
stealth at runtime (random `ScreenGui` name, `cloneref`, dedupe of prior EzUI roots).

| Field | Type | Default | Effect |
|---|---|---|---|
| `Parent` | `Instance` | auto | Manual override; bypasses the whole chain. |
| `Stealth` | `bool` | `true` at runtime | Controls naming only. `false` → readable name `"EzUI"`. Dedupe / `protect` / service `cloneref` are always feature-detected-on. |
| `GuiName` | `string` | random / `"EzUI"` | Force a specific `ScreenGui` name. |
| `DisplayOrder` | `number` | `1000000` | `ScreenGui` render order (higher renders above game UI). |

In Roblox Studio the name stays the readable `"EzUI"` for easy debugging.
