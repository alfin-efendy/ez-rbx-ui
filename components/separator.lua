--[[
	Separator Component
	EzUI Library - Modular Component
	
	Creates a horizontal line separator
]]
local Separator = {}

local Colors

function Separator:Init(_colors)
	Colors = _colors
end

function Separator:Create(config)
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local isForAccordion = config.IsForAccordion or false
	
	local separator = Instance.new("Frame")
	if isForAccordion then
		separator.Size = UDim2.new(1, 0, 0, 1)
		separator.Position = UDim2.new(0, 0, 0, currentY + 5)
		separator.ZIndex = 5
	else
		separator.Size = UDim2.new(1, -20, 0, 1)
		separator.Position = UDim2.new(0, 10, 0, currentY + 5)
		separator.ZIndex = 3
		separator:SetAttribute("ComponentStartY", currentY)
	end
	separator.BackgroundColor3 = Colors.Special.Divider
	separator.BorderSizePixel = 0
	separator.Parent = parentContainer
	
	-- Create Separator API
	local separatorAPI = {}
	
	separatorAPI.SetColor = function(color)
		separator.BackgroundColor3 = color
	end
	
	return separatorAPI
end

return Separator
