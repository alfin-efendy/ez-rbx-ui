---
layout: home
hero:
  name: EzUI
  text: A modern UI library for Roblox
  tagline: shadcn-inspired design, Fluent acrylic, Lucide icons, engine-driven flex layout, and flag-based config with auto-save.
  image:
    src: /brand/ezui-docs-hero.png
    alt: EzUI interface preview
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: Controls
      link: /controls/
    - theme: alt
      text: View on GitHub
      link: https://github.com/alfin-efendy/ez-rbx-ui
features:
  - title: Drop-in install
    details: One loadstring line in an executor, or require the bundled ModuleScript in Studio.
  - title: Full control set
    details: Toggle, slider, number box, multi-select, keybind, color picker, text box, table, card, image, and progress bar.
  - title: Engine-driven layout
    details: UIListLayout + AutomaticSize + UIFlex — no manual Y positioning, smooth tab and accordion transitions.
  - title: Flag-based config
    details: Any control with a Flag auto-saves and restores; one call resets every flag to its default.
  - title: Theming
    details: Override design tokens per window — colors, radius, spacing, fonts, motion — deep-merged onto the defaults.
  - title: Lucide icons
    details: Curated ~250-icon subset by name (e.g. "home", "play", "settings-2"), no emoji.
---

## Quick install

```lua
local EzUI = loadstring(game:HttpGet("https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"))()
```

See [Getting Started](/guide/getting-started) for a full walkthrough.
