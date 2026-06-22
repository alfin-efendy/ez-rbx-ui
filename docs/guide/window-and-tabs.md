# Window & Tabs

## Creating a Window

Call `EzUI:CreateWindow(config)` once to create the main window frame. All controls live inside tabs, which are added to the window.

```lua
local Window = EzUI:CreateWindow({
    Title = "My Hub",
    Size = { Width = 560, Height = 420 },
    Acrylic = true,
    ToggleKey = Enum.KeyCode.RightControl,
    FloatingToggle = true,
    Theme = { Colors = { primary = Color3.fromRGB(59, 130, 246) } },
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})
```

### Config Keys

| Key | Type | Notes |
|---|---|---|
| `Title` | `string` | Title-bar text |
| `Size` | `{ Width, Height }` | Window size in pixels |
| `Acrylic` | `bool` | Acrylic sheen panel (`false` = flat). Opaque and readable either way |
| `ToggleKey` | `Enum.KeyCode` | Show/hide key (default `RightControl`) |
| `FloatingToggle` | `bool` | Show a floating toggle button (auto-enabled on touch devices) |
| `Mode` | `"dark"` \| `"light"` | Initial color mode; default `"dark"`. See [Color mode](/guide/theming#color-mode-dark-light) |
| `AutoAdapt` | `bool` | Auto-fit the window to the viewport on creation; default `true`. Pass `false` to skip |
| `ConfirmClose` | `bool` | Show a confirm dialog before closing; default `true`. Pass `false` to close immediately |
| `OnClose` | `function` | Called (pcall-wrapped) when the window closes |
| `Parent` | `Instance` | Optional parent for the GUI; useful for custom mount points |
| `Theme` | `table` | Override design tokens (see [Theming](/guide/theming)) |
| `Config` | `{ Enabled, FileName, FolderName, AutoSave, AutoLoad }` | Flag persistence (see [Config & Flags](/guide/config-and-flags)) |

## Window Methods

| Method | Description |
|---|---|
| `AddTab(opts)` | Add a tab to the sidebar |
| `AddTabGroup(name)` | Add a named sidebar category group |
| `SearchTabs(query)` | Programmatically filter tabs and their controls |
| `Show()` | Make the window visible |
| `Hide()` | Hide the window |
| `Toggle()` | Toggle visibility |
| `IsVisible()` | Returns `true` if the window is visible |
| `Minimize()` | Collapse the window |
| `SetTitle(s)` | Update the title-bar text |
| `AdaptToViewport()` | Reposition/resize to fit the current screen |
| `GetMode()` | Returns the current color mode (`"dark"` or `"light"`) |
| `SetMode(mode)` | Switch the color palette live (`"dark"` / `"light"`) |
| `SetFloatingToggleVisible(b)` | Show or hide the floating toggle button |
| `Destroy()` | Tear down the window and all its children |

For notification and dialog methods, see [Notifications & Dialog](/guide/notifications-dialog).  
For config/flag reset methods, see [Config & Flags](/guide/config-and-flags).

## Tabs

Add a tab by calling `Window:AddTab(opts)`. The returned tab object exposes every `AddX` control method.

```lua
local tab = Window:AddTab({ Name = "Home", Icon = "home" })

tab:AddLabel("Welcome to My Hub")
tab:AddButton({ Text = "Run", Callback = function() print("clicked") end })
```

`Icon` accepts any Lucide icon name (see [Icons](/guide/icons)).

## Tab Groups

Group related tabs under a named sidebar category with `Window:AddTabGroup(name)`. The group object exposes the same `AddTab` method.

```lua
local group = Window:AddTabGroup("Main")

local homeTab = group:AddTab({ Name = "Home", Icon = "house" })
local settingsTab = group:AddTab({ Name = "Settings", Icon = "settings-2" })
```

## Sidebar Search

The window includes built-in full-text sidebar search that filters both tab names and their controls. Users activate it by typing in the search box at the top of the sidebar.

To trigger a search programmatically:

```lua
Window:SearchTabs("walk speed")
```

This narrows the sidebar to only tabs that contain controls matching the query.
