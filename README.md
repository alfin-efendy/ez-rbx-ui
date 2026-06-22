# EzUI — Roblox UI Library

A modern, modular UI library for Roblox scripts. shadcn-inspired design, Fluent-style acrylic panel, Lucide icons, CSS-flex-like layout (engine-driven, no manual positioning), smooth tab/accordion transitions, and a flag-based config system with auto-save/load and reset.

> **v3 is a full rewrite with a clean-break API.** If you used the old v2 `EzUI:CreateNew` / emoji-icon API, see [Migration](#migration-from-v2).

📖 **Documentation:** https://alfin-efendy.github.io/ez-rbx-ui/

---

## Install

**Executor (loadstring):**
```lua
local EzUI = loadstring(game:HttpGet("https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"))()
```

**ModuleScript (Studio):** place the bundled `ez-rbx-ui.lua` in `ReplicatedStorage` and `require` it.

---

## Quick start

```lua
local Window = EzUI:CreateWindow({
    Title = "My Hub",
    Ratio = 16/10,                            -- window shape; auto-fits the viewport
    Subtitle = "v3.0",
    Image = "rbxassetid://0",                 -- rbxassetid:// or http(s):// url
    Transparency = 0.12,
    ToggleKey = Enum.KeyCode.RightControl,   -- show/hide
    FloatingToggle = { Type = "simple", AutoHide = true },  -- mobile/touch button
    Config = { Enabled = true, FileName = "MyHub", AutoSave = true, AutoLoad = true },
})

local tab = Window:AddTab({ Name = "Home", Icon = "home" })   -- icons are Lucide names

tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false,
    Callback = function(on) print("Auto Farm:", on) end })

tab:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 16, Flag = "walkspeed" })

tab:AddButton({ Text = "Execute", Variant = "default", Icon = "play", Callback = function()
    Window:ShowSuccess({ Title = "Done", Message = "Script ran." })
end })
```

See [`example/main.lua`](example/main.lua) for a full playground (`make run` to serve it).

---

## Window API

`EzUI:CreateWindow(config)` — `config`:

| Key | Type | Notes |
|---|---|---|
| `Title` | string | title-bar text |
| `Subtitle` | string | secondary line under the title |
| `Image` | string | title-bar logo (`rbxassetid://` or `http(s)://`) |
| `Ratio` | number \| `{ Width, Height }` | window aspect ratio; auto-fits the viewport (default `4/3`) |
| `Transparency` | number | window background transparency `0..1` (default `0.12`) |
| `ToggleKey` | `Enum.KeyCode` | show/hide key (default `RightControl`) |
| `FloatingToggle` | table | `{ Type, Position, Image, Size, Draggable, AutoHide }` (or `false` to disable) |
| `Theme` | table | override design tokens (see [Theming](#theming)) |
| `Config` | `{ Enabled, FileName, FolderName, AutoSave, AutoLoad }` | flag persistence |

**Methods:** `AddTab(opts)`, `AddTabGroup(name)`, `SearchTabs(query)`, `Show()`, `Hide()`, `Toggle()`, `IsVisible()`, `Minimize()`, `SetTitle(s)`, `SetSubtitle(s)`, `SetImage(v)`, `SetTransparency(n)`, `AdaptToViewport()`, `SetFloatingToggle(opts)`, `SetFloatingToggleVisible(b)`, `Destroy()`, and:

- **Notifications:** `Notify(opts)`, `ShowSuccess/ShowWarning/ShowError/ShowInfo(opts)`, `DismissNotification(id)`, `ClearNotifications()` — `opts = { Title, Message?, Type?, Duration?=4000, Action?, OnDismiss? }`.
- **Dialog:** `Dialog({ Title, Message?, Buttons = { { Text, Variant?, Callback? }, ... }, Modal?=true })`.
- **Config:** `ResetConfiguration({ Confirm?=true, ClearFile?=false })`, `ResetFlag(flag)`, and `.Config` (the config object).

**Tab groups & search:** `local g = Window:AddTabGroup("Main"); g:AddTab({...})` adds a sidebar category. The built-in sidebar search filters tabs **and** their controls by text (full-text); `Window:SearchTabs(query)` does it programmatically.

---

## Controls

Call these on a `tab` or an `accordion` (same API):

| Method | Key options |
|---|---|
| `AddLabel(text or opts)` | `Text` |
| `AddParagraph(text)` | wrapped muted text |
| `AddSection(text)` | uppercase group header |
| `AddSeparator()` | — |
| `AddButton(opts)` | `Text, Variant (default/secondary/outline/ghost/destructive), Icon, Callback, Action="ResetConfig", Tooltip` |
| `AddToggle(opts)` | `Text, Default, Flag, Callback` → `Get()/Set(v)/OnChanged(fn)` |
| `AddTextBox(opts)` | `Text, Default, Placeholder, MaxLength, Copyable, Flag` → `GetText()/SetText(s)/Focus()/Clear()` |
| `AddNumberBox(opts)` | `Text, Default, Min, Max, Step, Format ("compact"/"comma"), Decimals, Prefix, Suffix, Flag` → `GetValue()/SetValue(n)/SetMin/SetMax`. Type `1k`/`4.4m`/`72B` directly; hold −/+ or scroll to adjust |
| `AddSlider(opts)` | `Text, Min, Max, Default, Step, Flag` → `GetValue()/SetValue(n)/OnChanged(fn)` |
| `AddSelectBox(opts)` | `Text, Options, Default, Multi, AllowNone, Searchable, Disabled, Loading, OnOpen, Flag` → `GetValue()/SetValue(v)/SetOptions(o)/SetDisabled(b)/SetLoading(b)`. Options may be `{ Value, Text/Label, Icon, Desc }` — `Value` is stored/flagged, `Text` is shown. Search auto-shows for long lists; flips up near the screen edge; click outside closes it; `OnOpen(api)` refreshes options on open |
| `AddKeybind(opts)` | `Text, Default (Enum.KeyCode), Flag, Callback` → `GetKey()/SetKey(k)/OnPressed(fn)` |
| `AddColorPicker(opts)` | `Text, Default (Color3), Flag` → `GetColor()/SetColor(c)` |
| `AddImage(opts)` | `Image` (rbxassetid) or `Lucide` (icon name), `Height` |
| `AddProgressBar(opts)` | `Default (0..1)` → `Get()/Set(p)` |
| `AddTable(opts)` | `Columns, Rows` → `SetData(rows)/AddRow(row)/Clear()` |
| `AddAccordion(opts)` | `Title, Icon, Expanded` → a collapsible host with the same `AddX` methods, plus `Toggle()/Expand()/Collapse()/IsExpanded()/SetTitle(s)/SetIcon(name)` |

Any control with a `Flag` (and a window `Config`) auto-saves and restores its value, and is restored on `ResetConfiguration`.

---

## Icons

Icons are **Lucide** names (e.g. `"home"`, `"settings-2"`, `"play"`, `"users"`). A curated subset (~250) ships in the bundle. The picker/icon data is generated from [`latte-soft/lucide-roblox`](https://github.com/latte-soft/lucide-roblox); regenerate/extend via `scripts/icons.manifest.txt` + `make icons`. (`"house"` is aliased to `"home"`.)

---

## Theming

Tokens live in `EzUI.Theme` (zinc dark palette, monochrome white primary). Override per window:

```lua
EzUI:CreateWindow({ Theme = { Colors = { primary = Color3.fromRGB(59, 130, 246) } } })
```

Token groups: `Colors` (`background, card, surface, border, input, ring, foreground, mutedForeground, primary, primaryForeground, destructive, success, warning, info, switchTrackOff`), `Radius`, `Spacing`, `Font`, `Motion`. A partial override is deep-merged onto the defaults, so you only specify what you change.

---

## Config & flags

```lua
local cfg = EzUI:NewConfig({ FileName = "PlayerData" })
cfg:Set("coins", 1000); print(cfg:Get("coins"))
```

Controls with `Flag` register against the window's `Config`. `Window:ResetConfiguration()` confirms via a dialog, restores every flag to its default (re-applying each control), and toasts success.

**Requires** executor file functions for persistence: `writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`. The UI works without them; settings just won't persist.

---

## Migration from v2

| v2 | v3 |
|---|---|
| `EzUI:CreateNew({ Name = ... })` | `EzUI:CreateWindow({ Title = ... })` |
| `Size = { Width, Height }` | `Ratio = w/h` (aspect ratio; auto-fits the viewport) |
| `tab = window:AddTab({ Name, Icon = "🏠" })` | `Icon = "home"` (Lucide name, not emoji) |
| `tab:AddLabel/AddButton/AddToggle/AddTextBox/AddNumberBox/AddSelectBox/AddSeparator` | same names |
| `window:ShowNotification/ShowSuccess/ShowError(...)` | `window:Notify/ShowSuccess/ShowError(...)` |
| `Colors` module (`utils/colors`) | `EzUI.Theme` tokens / `Theme` override |
| `EzUI:NewConfig(...)` | unchanged |
| flags (`Flag = "..."`) | unchanged |
| — | **new:** `AddSlider, AddKeybind, AddColorPicker, AddImage, AddProgressBar, AddTable, AddCard, AddResizable`, `AddTabGroup`, sidebar search, `Dialog`, `ResetConfiguration` |

v3 internals are a clean rewrite: engine-driven layout (`UIListLayout` + `AutomaticSize` + `UIFlex`) instead of manual Y positioning, a single-tween accordion (no O(n²) reflow), and `CanvasGroup` tab transitions.

---

## Build

```
make build    # bundle main.lua -> output/bundle.lua  (lua-bundler)
make test     # headless unit tests (PUC lua + Roblox mock)
make check    # build + test + faithful bundle verify
make run      # build + serve example/main.lua on :8081
make icons    # regenerate the curated Lucide table from scripts/icons.manifest.txt
```

---

## License

See [LICENSE](LICENSE). Lucide icons: ISC; the `latte-soft/lucide-roblox` port: MIT.

**Created by alfin-efendy.**
