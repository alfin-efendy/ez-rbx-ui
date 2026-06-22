# Icons

EzUI uses **Lucide** icons throughout — in tabs, buttons, accordions, and the image control.

## Usage

Pass a Lucide icon name as a string wherever an `Icon` option is accepted:

```lua
Window:AddTab({ Name = "Home", Icon = "home" })

tab:AddButton({ Text = "Run", Icon = "play", Callback = function() end })

tab:AddAccordion({ Title = "Advanced", Icon = "settings-2" })

tab:AddImage({ Lucide = "users", Height = 48 })
```

Icon names follow the Lucide naming convention: lowercase, hyphen-separated (e.g. `"settings-2"`, `"arrow-right"`, `"circle-check"`).

## Bundled Subset

A curated subset of approximately 250 icons ships in the bundle to keep the file size manageable. The subset covers common UI needs: navigation, actions, status indicators, and media.

### Alias

`"house"` is aliased to `"home"` — both names resolve to the same icon.

## Regenerating Icons

The icon data is generated from [`latte-soft/lucide-roblox`](https://github.com/latte-soft/lucide-roblox). To add icons or update the subset:

1. Edit `scripts/icons.manifest.txt` — add or remove Lucide icon names, one per line.
2. Run `make icons` to regenerate the icon table in the bundle.

```bash
make icons
```

The manifest file controls exactly which icons are included. Only icons listed there will be available at runtime.
