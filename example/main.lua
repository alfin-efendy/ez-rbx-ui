--[[
  EzUI — usage playground (one file per menu under example/menu/).

  Build + serve:  make run    (bundles this against ../output/bundle, serves on :8081)
  In Roblox:      load the released ez-rbx-ui.lua via loadstring + HttpGet, then EzUI:CreateWindow{...}
]]
local EzUI = require("../output/bundle")

-- The EzUI brand mark, rendered as a WHITE-on-transparent PNG and hosted on the docs site. It is a
-- single-color glyph, so `*Adaptive` tints it to the theme foreground (near-white in dark, near-black
-- in light) and re-tints automatically on SetMode -- one asset that reads cleanly in both modes.
-- The PNG is downloaded once via the executor's writefile + getcustomasset (needs HttpGet too); under
-- Studio/headless it is a graceful no-op (no logo). Source: docs/public/brand/ezui-blade-zu-icon.svg.
local LOGO = "https://alfin-efendy.github.io/ez-rbx-ui/brand/ezui-blade-zu-icon.png"

local window = EzUI:CreateWindow({
  Title = "EzUI Demo",
  Ratio = { Width = 0.4, Height = 0.55 },   -- 40% of the screen wide, 55% tall
  Subtitle = "Component playground",
  Image = LOGO,                             -- title-bar logo
  ImageAdaptive = true,                     -- tint the mono glyph to the theme foreground (dark/light)
  Transparency = 0.12,
  ToggleKey = Enum.KeyCode.RightControl,
  StartHidden = false,
  -- square FAB shows the logo (no magnet); Adaptive tints it to match the active mode
  FloatingToggle = { Type = "square", Image = LOGO, Adaptive = true, AutoHide = true },
  Config = { Enabled = true, FileName = "EzUIDemo", AutoSave = true, AutoLoad = true },
  OnClose = function() print("EzUI closed — settings saved.") end,
})

-- literal requires only (the bundler embeds/rewrites only literal-string require calls)
require("menu/home")(window)
require("menu/settings")(window)

local inputs = window:AddTabGroup("Inputs")
require("menu/components/button")(window, inputs)
require("menu/components/toggle")(window, inputs)
require("menu/components/textbox")(window, inputs)
require("menu/components/numberbox")(window, inputs)
require("menu/components/selectbox")(window, inputs)
require("menu/components/slider")(window, inputs)
require("menu/components/keybind")(window, inputs)
require("menu/components/colorpicker")(window, inputs)

local display = window:AddTabGroup("Display")
require("menu/components/label")(window, display)
require("menu/components/paragraph")(window, display)
require("menu/components/separator")(window, display)
require("menu/components/image")(window, display)
require("menu/components/progressbar")(window, display)
require("menu/components/table")(window, display)
require("menu/components/card")(window, display)

local containers = window:AddTabGroup("Containers")
require("menu/components/accordion")(window, containers)
require("menu/components/resizable")(window, containers)

local overlays = window:AddTabGroup("Overlays")
require("menu/components/tooltip")(window, overlays)
require("menu/components/dialog")(window, overlays)
require("menu/components/notification")(window, overlays)

window:Tag({ Text = "v3", Icon = "sparkles" })
window:ShowInfo({ Title = "Welcome", Message = "EzUI demo loaded. Press RightControl to toggle.", Duration = 5000 })
