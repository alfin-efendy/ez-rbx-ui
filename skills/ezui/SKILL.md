---
name: ezui
description: >-
  Use when building or modifying a Roblox client UI / script hub / menu / GUI
  with the EzUI library (alfin-efendy/ez-rbx-ui), or when EzUI is already present
  in the project. Covers window setup, all controls, theming, config/flags,
  notifications and dialogs. Not for Roblox game logic unrelated to the UI.
---

# EzUI — Roblox UI Library

EzUI is a modular Roblox UI library: shadcn-inspired design, Fluent acrylic
panel, Lucide icons, engine-driven (flex-like) layout, tabs/accordions, and
flag-based config persistence. Use it to build script hubs, menus, and GUIs.

## Install

Executor (loadstring):

```lua
local EzUI = loadstring(game:HttpGet("https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua"))()
```

ModuleScript (Studio): place the bundled `ez-rbx-ui.lua` in `ReplicatedStorage` and `require` it.

## Golden path

```lua
local Window = EzUI:CreateWindow({ Title = "My Hub", Subtitle = "v1.0" })
local tab = Window:AddTab({ Name = "Home", Icon = "home" }) -- Icon is a Lucide name

tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false,
  Callback = function(on) print("Auto Farm:", on) end })

tab:AddButton({ Text = "Run", Variant = "default", Icon = "play", Callback = function()
  Window:ShowSuccess({ Title = "Done", Message = "Script ran." })
end })
```

## Mental model (hard rules)

1. **Layout is engine-driven.** Never set `Position`, `Size`, or anchors on
   controls — EzUI lays everything out automatically.
2. **Icons are Lucide names** (e.g. `"home"`, `"play"`, `"settings-2"`), never
   emoji. See `reference/icons.md`.
3. **Controls live only on a `tab` or an `accordion`** (identical `AddX` API).
   Create them with `Window:AddTab(...)` or `host:AddAccordion(...)`.
4. **Flags require a window `Config`.** Any control with a `Flag` auto-saves and
   restores — but only when the window was created with `Config = { Enabled = true, … }`
   and the executor provides file functions. See `reference/config-flags.md`.
5. **Callbacks receive the new value** (e.g. a toggle callback gets `true`/`false`).

## Guardrails

Only use methods and options listed in `reference/`. **Do not invent options or
controls.** When unsure about a control's exact options or return API, read its
reference file BEFORE writing code.

## Navigation map

| To do this | Read |
|---|---|
| Add any control to a tab/accordion (toggle, slider, select, table, …) | `reference/controls.md` |
| Create/configure a window, tabs, tab groups, notifications, dialogs | `reference/window.md` |
| Recolor / restyle (theme tokens, per-window override) | `reference/theming.md` |
| Persist settings, flags, reset configuration | `reference/config-flags.md` |
| Pick a valid icon name | `reference/icons.md` |
| Build a complete feature end-to-end (hub, settings tab, etc.) | `reference/recipes.md` |
| Avoid common mistakes / migrate from v2 | `reference/pitfalls.md` |
