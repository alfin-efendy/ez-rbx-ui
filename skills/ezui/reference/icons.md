# EzUI Icons Reference

EzUI uses **Lucide** icons throughout — in tabs, buttons, accordions, and the image control.

## Usage

Pass a Lucide icon name as a string wherever an `Icon` option is accepted:

```lua
Window:AddTab({ Name = "Home", Icon = "home" })

tab:AddButton({ Text = "Run", Icon = "play", Callback = function() end })

tab:AddAccordion({ Title = "Advanced", Icon = "settings-2" })

tab:AddImage({ Lucide = "users", Height = 48 })
```

Icon names follow Lucide's convention: lowercase, hyphen-separated (e.g. `"settings-2"`, `"arrow-right"`, `"circle-check"`).

## Bundled Subset

A curated subset of approximately 250 icons ships in the bundle to keep file size manageable. The subset covers common UI needs: navigation, actions, status indicators, and media.

Some representative names: `"home"`, `"settings"`, `"settings-2"`, `"play"`, `"pause"`, `"search"`, `"user"`, `"users"`, `"check"`, `"plus"`, `"trash-2"`, `"eye"`, `"lock"`, `"zap"`, `"shield"`, `"star"`, `"heart"`, `"info"`, `"circle-check"`, `"triangle-alert"`, `"refresh-cw"`, `"gamepad-2"`.

When unsure whether a name is included, prefer common verbs and nouns. The full set is available at runtime in `EzUI.Icons`.

### Alias

`"house"` is aliased to `"home"` — both names resolve to the same icon. This alias exists because this Lucide port predates an upstream icon rename.

## Regenerating Icons

The icon data is generated from [`latte-soft/lucide-roblox`](https://github.com/latte-soft/lucide-roblox). To add icons or update the subset:

1. Edit `scripts/icons.manifest.txt` — add or remove Lucide icon names, one per line.
2. Run `make icons` to regenerate the icon table in the bundle.

```bash
make icons
```

Only icons listed in the manifest will be available at runtime.
