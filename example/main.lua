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

-- literal requires (the bundler only embeds/rewrites literal-string require calls)
local menus = {
  require("menu/home"),
  require("menu/controls"),
  require("menu/components"),
  require("menu/visuals"),
  require("menu/players"),
  require("menu/settings"),
  require("menu/credits"),
}
for _, build in ipairs(menus) do build(window) end

window:Tag({ Text = "v3", Icon = "sparkles" })
window:ShowInfo({ Title = "Welcome", Message = "EzUI demo loaded. Press RightControl to toggle.", Duration = 5000 })
