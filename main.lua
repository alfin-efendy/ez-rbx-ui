--[[ EzUI — Easy Roblox UI Library (rewrite). Entry point. ]]
local EzUI = {}

local Theme = require("core/theme")
local Icons = require("core/icons")
local Config = require("core/config")
local Create = require("core/create")
local Animate = require("core/animate")
local Signal = require("core/signal")
local Maid = require("core/maid")
local Overlay = require("core/overlay")

EzUI.Theme = Theme
EzUI.Icons = Icons
EzUI._internal = { Create = Create, Animate = Animate, Signal = Signal, Maid = Maid, Overlay = Overlay }

function EzUI:NewConfig(opts) return Config.new(opts) end

-- EzUI:CreateWindow is added in Plan 2 (containers).
EzUI.Version = "2.0.0-alpha.1"
EzUI.Author = "alfin-efendy"

return EzUI
