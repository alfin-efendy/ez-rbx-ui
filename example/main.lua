--[[
  EzUI — usage playground (one file per menu under example/menu/).

  Build + serve:  make run    (bundles this against ../output/bundle, serves on :8081)
  In Roblox:      load the released ez-rbx-ui.lua via loadstring + HttpGet, then EzUI:CreateWindow{...}
]]
local EzUI = require("../output/bundle")

local window = EzUI:CreateWindow({
  Title = "EzUI Demo",
  Size = { Width = 600, Height = 440 },
  Acrylic = true,
  ToggleKey = Enum.KeyCode.RightControl,
  FloatingToggle = true,
  Config = { Enabled = true, FileName = "EzUIDemo", AutoSave = true, AutoLoad = true },
  OnClose = function() print("EzUI closed — settings saved.") end,
})

-- literal requires only (the bundler embeds/rewrites only literal-string require calls)
require("menu/home")(window)

local inputs = window:AddTabGroup("Inputs")
require("menu/components/button")(window, inputs)
require("menu/components/toggle")(window, inputs)
require("menu/components/textbox")(window, inputs)
require("menu/components/numberbox")(window, inputs)
require("menu/components/selectbox")(window, inputs)
require("menu/components/slider")(window, inputs)
require("menu/components/keybind")(window, inputs)
require("menu/components/colorpicker")(window, inputs)
require("menu/components/playerselector")(window, inputs)

local display = window:AddTabGroup("Display")
require("menu/components/label")(window, display)
require("menu/components/paragraph")(window, display)
require("menu/components/separator")(window, display)
require("menu/components/image")(window, display)
require("menu/components/progressbar")(window, display)
require("menu/components/table")(window, display)
require("menu/components/card")(window, display)

require("menu/settings")(window)
require("menu/credits")(window)

window:Tag({ Text = "v3", Icon = "sparkles" })
window:ShowInfo({ Title = "Welcome", Message = "EzUI demo loaded. Press RightControl to toggle.", Duration = 5000 })
