--[[
	EzUI - Easy Roblox UI Library
	Main Entry Point
	
	A modern, modular UI library for Roblox with:
	- Centralized color palette system
	- Configuration management with auto-save/load
	- 10+ UI components
	- Tab system with icons
	- Window management with drag & resize
	
	Usage:
		local EzUI = require(game.ReplicatedStorage.main)
		
		local window = EzUI.({
			Name = "My UI",
			Size = {Width = 500, Height = 400}
		})
		
		local tab = window:AddTab("Home")
		tab:AddButton("Click Me", function()
			print("Button clicked!")
		end)
]]

local EzUI = {}

-- Import utility modules
local ColorsModule = require("utils/colors")
local ConfigModule = require("utils/config")

-- Debug: Verify Colors loaded
if ColorsModule then
	print("✅ Colors module loaded successfully")
	if ColorsModule.Background then
		print("✅ Colors.Background exists")
	else
		warn("❌ Colors.Background is nil!")
	end
else
	warn("❌ Colors module is nil!")
end

-- Import components
local Accordion = require("components/accordion")
local Button = require("components/button")
local Label = require("components/label")
local NumberBox = require("components/numberbox")
local Notification = require("components/notification")
local SelectBox = require("components/selectbox")
local Separator = require("components/separator")
local Tab = require("components/tab")
local TextBox = require("components/textbox")
local Toggle = require("components/toggle")
local Window = require("components/window")

-- Custom Configuration System
function EzUI:NewConfig(config)
	return ConfigModule:NewConfig(config)
end

-- Initialize Components
print("🔧 Initializing components...")
Accordion:Init(ColorsModule, Button, Toggle, TextBox, NumberBox, SelectBox, Label, Separator)
Button:Init(ColorsModule)
Label:Init(ColorsModule)
NumberBox:Init(ColorsModule)
SelectBox:Init(ColorsModule)
Separator:Init(ColorsModule)
Tab:Init(ColorsModule, Accordion, Button, Toggle, TextBox, NumberBox, SelectBox, Label, Separator)
TextBox:Init(ColorsModule)
Toggle:Init(ColorsModule)
Window:Init(ColorsModule, Accordion, Button, Label, NumberBox, Notification, SelectBox, Separator, Tab, TextBox, Toggle)
print("✅ All components initialized")

-- Main Window Creation Function
function EzUI:CreateNew(config)
	print("🪟 Creating window...")
	
	-- Pass all required modules and config to Window component
	local windowSetup = {
		Title = config.Title or config.Name or "EzUI Window",
		Width = config.Width or (config.Size and config.Size.Width) or 600,
		Height = config.Height or (config.Size and config.Size.Height) or 400,
		Opacity = config.Opacity or 0.9,
		AutoShow = config.AutoShow or true,
		Draggable = config.Draggable,
		BackgroundColor = config.BackgroundColor,
		CornerRadius = config.CornerRadius,
	}

	-- Create config system
	local configSystem = ConfigModule:NewConfig({
		FolderName = config.FolderName or "EzUI",
		FileName = config.FileName or "Settings",
	})

	configSystem:Load()

	local allKeys = configSystem:GetAllKeys()
	print("EzUI:CreateNew - Loaded config keys:", table.concat(allKeys, ", "))

	-- Store config in EzUI for global access
	windowSetup.Settings = configSystem

	return Window:Create(windowSetup)
end

-- Expose version info
EzUI.Version = "2.0.0"
EzUI.Author = "EzUI Library"

return EzUI