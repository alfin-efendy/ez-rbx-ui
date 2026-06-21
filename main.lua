--[[ EzUI — Easy Roblox UI Library (rewrite). Entry point. ]]
local EzUI = {}

-- lua-bundler keys modules by their require STRING and resolves the path relative
-- to the FIRST file that requires that string. Requiring every module here from the
-- repo root (dependency order) pre-registers each string, so nested cross-requires
-- inside components/ (e.g. window -> "core/acrylic", "components/tab") match the
-- already-registered root-resolved module instead of resolving to components/core/...
local Theme = require("core/theme")
local Create = require("core/create")
local Animate = require("core/animate")
local Signal = require("core/signal")
local Maid = require("core/maid")
local Icons = require("core/icons")
local Overlay = require("core/overlay")
local Acrylic = require("core/acrylic")
local Config = require("core/config")
local Accordion = require("components/accordion")
local Tab = require("components/tab")
local Window = require("components/window")

EzUI.Theme = Theme
EzUI.Icons = Icons
EzUI._internal = { Create = Create, Animate = Animate, Signal = Signal, Maid = Maid, Overlay = Overlay }

function EzUI:NewConfig(opts) return Config.new(opts) end

function EzUI:CreateWindow(config)
  config = config or {}
  if config.Parent == nil then
    local ok, hui = pcall(function() return gethui and gethui() end)
    config.Parent = (ok and hui) or game:GetService("CoreGui")
  end
  return Window.new(config)
end

EzUI.Version = "2.0.0-alpha.1"
EzUI.Author = "alfin-efendy"

return EzUI
