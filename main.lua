--[[ EzUI — Easy Roblox UI Library (rewrite). Entry point. ]]
local EzUI = {}

-- The bundler rewrites require() ONLY in this entry file (not inside embedded
-- modules), so modules must NOT require each other. Load each module once here,
-- then inject the dependency registry R via Module.Init(R).
local R = {}
R.Theme = require("core/theme")
R.Create = require("core/create")
R.Signal = require("core/signal")
R.Maid = require("core/maid")
R.Icons = require("core/icons")
R.Config = require("core/config")
R.Flag = require("core/flag")
R.Animate = require("core/animate")
R.Overlay = require("core/overlay")
R.Acrylic = require("core/acrylic")
R.Separator = require("components/separator")
R.Label = require("components/label")
R.Button = require("components/button")
R.Toggle = require("components/toggle")
R.TextBox = require("components/textbox")
R.NumberBox = require("components/numberbox")
R.SelectBox = require("components/selectbox")
R.Image = require("components/image")
R.ProgressBar = require("components/progressbar")
R.Slider = require("components/slider")
R.Keybind = require("components/keybind")
R.Tooltip = require("components/tooltip")
R.Dialog = require("components/dialog")
R.Notification = require("components/notification")
R.PlayerSelector = require("components/playerselector")
R.Table = require("components/table")
R.ColorPicker = require("components/colorpicker")
R.Host = require("components/host")
R.Resizable = require("components/resizable")
R.Accordion = require("components/accordion")
R.Tab = require("components/tab")
R.Window = require("components/window")

for _, m in pairs(R) do
  if type(m) == "table" and type(m.Init) == "function" then m.Init(R) end
end

EzUI.Theme = R.Theme
EzUI.Icons = R.Icons
EzUI._internal = R

function EzUI:NewConfig(opts) return R.Config.new(opts) end

function EzUI:CreateWindow(config)
  config = config or {}
  if config.Parent == nil then
    local ok, hui = pcall(function() return gethui and gethui() end)
    config.Parent = (ok and hui) or game:GetService("CoreGui")
  end
  return R.Window.new(config)
end

EzUI.Version = "2.0.0-alpha.1"
EzUI.Author = "alfin-efendy"

return EzUI
