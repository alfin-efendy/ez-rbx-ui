# Core API

These are the top-level surfaces on the `EzUI` object that are not bound to any specific window.

---

## `EzUI:NewConfig(opts)` {#config}

Creates and returns a standalone config object for persisting arbitrary key/value data.

```lua
local cfg = EzUI:NewConfig({ FileName = "PlayerData" })
cfg:Set("coins", 1000)
print(cfg:Get("coins"))  -- 1000
```

### Options

| Key | Type | Default | Description |
|---|---|---|---|
| `FileName` | `string` | `"Settings"` | Name of the saved file (no extension) |
| `FolderName` | `string` | `"EzUI"` | Subfolder inside the executor workspace |
| `AutoSave` | `bool` | `true` | Write to disk on every `Set` call |
| `AutoLoad` | `bool` | `true` | Read from disk and apply values on creation |

### Config Object Methods

The object returned by `NewConfig` exposes the following methods:

#### `cfg:Get(flag)`

Returns the current value stored under `flag`, or `nil` if not set.

```lua
local v = cfg:Get("coins")
```

#### `cfg:Set(flag, value)`

Stores `value` under `flag`. If `AutoSave` is enabled, writes to disk immediately.

```lua
cfg:Set("coins", 1000)
```

#### `cfg:Save()`

Explicitly writes all values to disk. Returns `true` on success, `false` if the executor file functions are unavailable.

#### `cfg:Load()`

Reads values from disk and applies them. Returns `true` on success.

#### `cfg:ResetFlag(flag)`

Restores `flag` to the default registered for that key and re-invokes its setter.

#### `cfg:Reset(opts)`

Restores all registered flags to their defaults.

| Option | Default | Description |
|---|---|---|
| `ClearFile` | `false` | Also delete the saved file from disk instead of overwriting it |

#### `cfg:Register(flag, default, setter)`

Registers a flag with a default value and an optional setter function called when the value is loaded or reset. Controls with a `Flag` option call this automatically.

#### `cfg:GetAllKeys()`

Returns an array of all stored flag names.

#### `cfg:ActiveProfile()`

Returns the name of the currently active profile (default: `"Default"`).

#### `cfg:SwitchProfile(name)`

Switches to the named profile, loads its saved values, and returns the profile name.

#### `cfg:ListProfiles()`

Returns an array of profile names that have saved files on disk (always includes `"Default"`).

#### `cfg:DeleteProfile(name)`

Deletes the saved file for the named profile from disk.

::: tip Executor requirement
`Save` and `Load` require executor file functions: `writefile`, `readfile`, `isfile`, `isfolder`, `makefolder`. The config object works without them — values are held in memory — but they will not persist between sessions.
:::

See [Config & Flags](/guide/config-and-flags) for usage in the context of a window.

---

## `EzUI.Theme` {#theme}

The global design-token table. Tokens are grouped into five sub-tables: `Colors`, `Radius`, `Spacing`, `Font`, and `Motion`.

```lua
-- Read a token:
print(EzUI.Theme.Colors.primary)
```

Override tokens per window by passing a `Theme` table to `EzUI:CreateWindow`. A partial override is deep-merged onto the defaults — only the keys you specify are changed.

```lua
EzUI:CreateWindow({
    Theme = { Colors = { primary = Color3.fromRGB(59, 130, 246) } }
})
```

### Token Groups

#### `Colors`

Semantic color tokens (all `Color3`):

| Token | Role |
|---|---|
| `background` | Window and panel background |
| `card` | Card and surface backdrop |
| `surface` | Control surface (inputs, buttons) |
| `border` | Dividers and outlines |
| `input` | Input field border |
| `ring` | Focus ring |
| `foreground` | Primary text |
| `mutedForeground` | Secondary and hint text |
| `primary` | Accent color (buttons, toggles) |
| `primaryForeground` | Text on primary-colored surfaces |
| `destructive` | Danger actions and error state |
| `success` | Success state |
| `warning` | Warning state |
| `info` | Informational state |
| `switchTrackOff` | Toggle track color when off |

#### `Radius`

Corner-rounding values in pixels: `sm` (6), `md` (8), `lg` (10), `xl` (14), `window` (12).

#### `Spacing`

Layout spacing values in pixels: `pad` (16), `padLg` (24), `inputX` (12), `inputY` (8), `gap` (8), `section` (16), `major` (24), `icon` (8).

#### `Font`

Font weight and size descriptors for each text role: `title`, `header`, `label`, `body`, `muted`. Each is a `{ Weight, Size }` table where `Weight` is an `Enum.FontWeight`.

#### `Motion`

Animation duration constants in seconds: `fast` (0.12), `base` (0.18), `slow` (0.28).

See [Theming](/guide/theming) for the full override guide and palette reference.

---

## `EzUI.Icons` {#icons}

The icon module. Icon names follow the Lucide naming convention: lowercase and hyphen-separated (e.g. `"home"`, `"settings-2"`, `"circle-check"`). A curated subset of approximately 250 icons ships in the bundle.

Pass an icon name as a string wherever an `Icon` option is accepted:

```lua
Window:AddTab({ Name = "Home", Icon = "home" })
tab:AddButton({ Text = "Run", Icon = "play", Callback = function() end })
```

### `EzUI.Icons.get(name)`

Returns a table with `Id`, `ImageRectSize`, and `ImageRectOffset` for applying the icon to a Roblox `ImageLabel`, or `nil` if the name is not in the bundle.

### `EzUI.Icons.apply(imageLabel, name, color3?)`

Applies the named icon to an existing `ImageLabel` instance. Optionally sets `ImageColor3`. Returns `true` on success, `false` if the name is unknown.

::: tip Alias
`"house"` is aliased to `"home"` — both names resolve to the same icon.
:::

See [Icons](/guide/icons) for the usage guide and instructions for regenerating the bundled subset.
