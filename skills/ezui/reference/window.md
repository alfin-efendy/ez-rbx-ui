# Window, Tabs, Notifications & Dialog

Everything here is a method on the `Window` object returned by `EzUI:CreateWindow`.

---

## CreateWindow

`EzUI:CreateWindow(config)` — creates and displays the main window frame. Returns a `Window` object.

```lua
local Window = EzUI:CreateWindow({
    Title = "My Hub",
    Subtitle = "v3.0",
    Image = "rbxassetid://0",
    Ratio = 16/10,
    Transparency = 0.12,
    ToggleKey = Enum.KeyCode.RightControl,
    FloatingToggle = { Type = "simple", AutoHide = true },
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})
```

### Config table

| Key | Type | Default | Notes |
|---|---|---|---|
| `Title` | `string` | — | Title-bar text |
| `Subtitle` | `string` | — | Secondary line shown under the title (grows the title bar) |
| `Image` | `string` | — | Title-bar logo — `rbxassetid://` / `rbxthumb://` or an `http(s)://` URL |
| `Ratio` | `number` \| `{ Width, Height }` | `4/3` | Window aspect ratio; auto-fits the viewport and stays responsive |
| `Transparency` | `number` | `0.12` | Window background transparency `0..1`; `0` = opaque |
| `Animations` | `bool` | `true` | Enable entrance/transition motion (FAB pop, window open/close, accordion + tab transitions); pass `false` for reduced/instant motion on low-end devices or for accessibility |
| `ToggleKey` | `Enum.KeyCode` | `RightControl` | Show/hide keyboard key |
| `FloatingToggle` | `table` \| `false` | enabled | Floating toggle button config — see [FloatingToggle](#floatingtoggle) below. Pass `false` to disable |
| `Theme` | `table` | — | Override design tokens (deep-merged onto defaults) |
| `Config` | `{ Enabled, FileName, FolderName, AutoSave, AutoLoad }` | — | Flag persistence options |
| `Mode` | `"dark"` \| `"light"` | `"dark"` | Initial color mode |
| `ConfirmClose` | `bool` | `true` | Show a confirm dialog before closing; pass `false` to close immediately |
| `OnClose` | `function` | — | Called (pcall-wrapped) when the window closes |
| `Parent` | `Instance` | — | Optional parent for the GUI |

### Window methods

| Method | Description |
|---|---|
| `AddTab(opts)` | Add a tab to the sidebar — see [AddTab](#addtab) |
| `AddTabGroup(name)` | Add a named sidebar category — see [AddTabGroup](#addtabgroup) |
| `SearchTabs(query)` | Programmatically filter tabs and their controls by text |
| `Show()` | Make the window visible |
| `Hide()` | Hide the window without destroying it |
| `Toggle()` | Toggle visibility |
| `IsVisible()` | Returns `true` if the window is currently visible |
| `Minimize()` | Hide the window and reveal the floating toggle button |
| `SetTitle(s)` | Update the title-bar text |
| `SetSubtitle(s)` | Update the subtitle text |
| `SetImage(v)` | Update the title-bar image (`rbxassetid://` or URL) |
| `SetTransparency(n)` | Set background transparency `0..1` |
| `GetMode()` | Returns the current color mode: `"dark"` or `"light"` |
| `SetMode(mode)` | Switch the color palette live (`"dark"` or `"light"`); controls re-skin immediately |
| `SetAnimationsEnabled(b)` | Toggle all library motion at runtime (`true` = animated, `false` = instant) |
| `AdaptToViewport()` | Re-fit the window to the current viewport (also runs automatically) |
| `SetFloatingToggle(opts)` | Rebuild the floating toggle button with new options |
| `SetFloatingToggleVisible(b)` | Show (`true`) or hide (`false`) the floating toggle button |
| `Destroy()` | Tear down the window and all its children |

**Notification methods:** `Notify(opts)`, `ShowSuccess(opts)`, `ShowWarning(opts)`, `ShowError(opts)`, `ShowInfo(opts)`, `DismissNotification(id)`, `ClearNotifications()` — see [Notifications](#notifications).

**Dialog method:** `Dialog(opts)` — see [Dialog](#dialog).

**Config methods:** `ResetConfiguration(opts)`, `ResetFlag(flag)`, `.Config` — see `reference/config-flags.md`.

---

## AddTab

`Window:AddTab(opts)` — adds a tab to the sidebar and returns a tab host. All `AddX` controls (toggle, slider, button, etc.) are called on this object.

```lua
local tab = Window:AddTab({ Name = "Home", Icon = "home" })
tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false })
tab:AddButton({ Text = "Run", Icon = "play", Callback = function() end })
```

| Key | Type | Notes |
|---|---|---|
| `Name` | `string` | Tab label shown in the sidebar |
| `Icon` | `string` | Lucide icon name (see `reference/icons.md`) |

The returned tab exposes the full `Add*` control API — see `reference/controls.md`.

---

## AddTabGroup

`Window:AddTabGroup(name)` — adds a named sidebar category group and returns a group object. Call `group:AddTab(opts)` to add tabs inside the group. The tab objects returned work identically to those from `Window:AddTab`.

```lua
local group = Window:AddTabGroup("Main")
local homeTab = group:AddTab({ Name = "Home", Icon = "home" })
local settingsTab = group:AddTab({ Name = "Settings", Icon = "settings-2" })

homeTab:AddLabel("Welcome")
settingsTab:AddToggle({ Text = "Dark mode", Flag = "darkmode" })
```

---

## NewConfig

`EzUI:NewConfig(opts)` — creates a standalone config object for persisting arbitrary key/value data outside of a window. See `reference/config-flags.md` for the full API.

```lua
local cfg = EzUI:NewConfig({ FileName = "PlayerData" })
cfg:Set("coins", 1000)
print(cfg:Get("coins"))  -- 1000
```

---

### FloatingToggle

The `FloatingToggle` config key accepts a table (or `false` to disable the button entirely). The floating toggle button (FAB) lets players reopen the window after it's hidden — essential on touch devices.

```lua
EzUI:CreateWindow({
    FloatingToggle = {
        Type = "circle",
        Image = "rbxassetid://123",
        Position = "BottomRight",
        Size = { Width = 56, Height = 56 },
        Draggable = true,
        AutoHide = false,
    },
})
```

| Key | Type | Description |
|---|---|---|
| `Type` | `string` | `"simple"` (default) — a chevron tab that docks at the screen edge; `"circle"` — accent-colored round button; `"square"` — rounded surface tile |
| `Position` | `string` \| `UDim2` | `"TopLeft"`, `"MidLeft"`, `"BottomLeft"`, `"TopRight"`, `"MidRight"`, `"BottomRight"`, or a raw `UDim2`. Default: `simple` → `MidLeft`, others → `TopLeft` |
| `Image` | `string` | Icon for `circle`/`square` buttons — `rbxassetid://` / `rbxthumb://` or an `http(s)://` URL; falls back to a controller icon |
| `Size` | `{ Width, Height }` \| `UDim2` | Button size in pixels |
| `Draggable` | `bool` | `true` (default): player can drag it; on release it magnet-snaps to the nearest screen edge |
| `AutoHide` | `bool` | `true` (default): visible only while the window is hidden; `false`: always visible (persistent toggle) |

Pass `FloatingToggle = false` to remove the button entirely. With it disabled, players can only reopen the window via `ToggleKey` — avoid this on touch-only experiences.

Change the button at runtime:

```lua
Window:SetFloatingToggle({ Type = "square", Image = "rbxassetid://123" })
Window:SetFloatingToggleVisible(true)   -- force show / hide
```

---

### Notifications

All notification methods are on the `Window` object. `Notify` returns an id for later dismissal.

```lua
-- Typed shorthands
Window:ShowSuccess({ Title = "Saved", Message = "All good." })
Window:ShowWarning({ Title = "Careful" })
Window:ShowError({ Title = "Failed" })
Window:ShowInfo({ Title = "Heads up" })

-- Full control
local id = Window:Notify({
    Title = "Item deleted",
    Type = "warning",
    Duration = 5000,
    Action = { Text = "Undo", Callback = function()
        Window:ShowSuccess({ Title = "Restored" })
    end },
    OnDismiss = function() print("dismissed") end,
})

-- Dismiss programmatically
Window:DismissNotification(id)
Window:ClearNotifications()
```

**`Notify(opts)` options:**

| Key | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | required | Notification heading |
| `Message` | `string` | `nil` | Optional body text |
| `Type` | `string` | `"default"` | `"success"`, `"warning"`, `"error"`, `"info"` |
| `Duration` | `number` | `4000` | Auto-dismiss delay in milliseconds |
| `Action` | `{ Text, Callback }` | `nil` | Optional action button shown in the toast |
| `OnDismiss` | `function` | `nil` | Called when the toast is dismissed |

`ShowSuccess/ShowWarning/ShowError/ShowInfo(opts)` are shorthands for `Notify` with the corresponding `Type` pre-set; they accept the same opts table.

Toasts have a countdown indicator that pauses while the cursor hovers over them.

---

### Dialog

`Window:Dialog(opts)` — opens a dimmed modal overlay with a title, optional message, and one or more buttons. The dialog closes automatically when any button is clicked.

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

**`Dialog(opts)` options:**

| Key | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | required | Dialog heading |
| `Message` | `string` | `nil` | Optional body text |
| `Buttons` | `array` | required | One or more button descriptors — `{ Text, Variant?, Callback? }` |
| `Modal` | `bool` | `true` | Dim the background while the dialog is open |

**Button descriptor:**

| Key | Type | Notes |
|---|---|---|
| `Text` | `string` | Button label |
| `Variant` | `string` | `"default"`, `"secondary"`, `"outline"`, `"ghost"`, `"destructive"` |
| `Callback` | `function` | Called when the button is clicked; dialog closes automatically |
