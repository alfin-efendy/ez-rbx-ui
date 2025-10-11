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
	
	-- Handle case where Parent might be a component API object instead of Instance
	if parentContainer and type(parentContainer) == "table" then
		-- Look for common GUI object properties in component APIs
		if parentContainer.Frame then
			parentContainer = parentContainer.Frame
		elseif parentContainer.Button then
			parentContainer = parentContainer.Button
		elseif parentContainer.Label then
			parentContainer = parentContainer.Label
		elseif parentContainer.Container then
			parentContainer = parentContainer.Container
		else
			-- List available keys for debugging
			local keys = {}
			for k, v in pairs(parentContainer) do
				table.insert(keys, tostring(k))
			end
			warn("Separator:Create - Parent is a table but no GUI object found. Keys:", table.concat(keys, ", "))
			parentContainer = nil
		end
	end
	
	-- Validate parent is an Instance
	if parentContainer and not typeof(parentContainer) == "Instance" then
		warn("Separator:Create - Parent must be an Instance, got:", typeof(parentContainer))
		parentContainer = nil
	end
	
	local separator = Instance.new("Frame")
	if isForAccordion then
		separator.Size = UDim2.new(1, 0, 0, 1)
		-- Don't set Position for accordion separators - let UIListLayout handle it
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
	local separatorAPI = {
		Separator = separator
	}
	
	function separatorAPI:SetColor(color)
		separator.BackgroundColor3 = color
	end
	
	return separatorAPI
end

return Separator
