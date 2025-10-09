--[[
	Button Component
	EzUI Library - Modular Component
	
	Creates a clickable button with hover effects
]]
local Button = {}

local Colors

function Button:Init(_colors)
	Colors = _colors
end

function Button:Create(config)
	local text = config.Text or "Button"
	local callback = config.Callback or function() end
	local variant = config.Variant or "primary"
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
			warn("Button:Create - Parent is a table but no GUI object found. Keys:", table.concat(keys, ", "))
			parentContainer = nil
		end
	end
	
	-- Validate parent is an Instance
	if parentContainer and not typeof(parentContainer) == "Instance" then
		warn("Button:Create - Parent must be an Instance, got:", typeof(parentContainer))
		parentContainer = nil
	end
	
	-- Function to get variant colors
	local function getVariantColors(variantName)
		local variants = {
			primary = {
				background = Colors.Button.Primary,
				backgroundHover = Colors.Button.PrimaryHover,
				text = Colors.Text.Primary,
				border = Colors.Text.Primary
			},
			secondary = {
				background = Color3.fromRGB(108, 117, 125),
				backgroundHover = Color3.fromRGB(90, 98, 104),
				text = Color3.fromRGB(255, 255, 255),
				border = Color3.fromRGB(108, 117, 125)
			},
			success = {
				background = Color3.fromRGB(40, 167, 69),
				backgroundHover = Color3.fromRGB(34, 142, 58),
				text = Color3.fromRGB(255, 255, 255),
				border = Color3.fromRGB(40, 167, 69)
			},
			warning = {
				background = Color3.fromRGB(255, 193, 7),
				backgroundHover = Color3.fromRGB(217, 164, 6),
				text = Color3.fromRGB(33, 37, 41),
				border = Color3.fromRGB(255, 193, 7)
			},
			danger = {
				background = Color3.fromRGB(220, 53, 69),
				backgroundHover = Color3.fromRGB(187, 45, 59),
				text = Color3.fromRGB(255, 255, 255),
				border = Color3.fromRGB(220, 53, 69)
			},
			info = {
				background = Color3.fromRGB(13, 202, 240),
				backgroundHover = Color3.fromRGB(11, 172, 204),
				text = Color3.fromRGB(255, 255, 255),
				border = Color3.fromRGB(13, 202, 240)
			},
			light = {
				background = Color3.fromRGB(248, 249, 250),
				backgroundHover = Color3.fromRGB(211, 212, 213),
				text = Color3.fromRGB(33, 37, 41),
				border = Color3.fromRGB(248, 249, 250)
			},
			dark = {
				background = Color3.fromRGB(33, 37, 41),
				backgroundHover = Color3.fromRGB(28, 31, 35),
				text = Color3.fromRGB(255, 255, 255),
				border = Color3.fromRGB(33, 37, 41)
			}
		}
		
		return variants[variantName] or variants.primary
	end
	
	local variantColors = getVariantColors(variant)
	
	local button = Instance.new("TextButton")
	if isForAccordion then
		-- Make button width responsive to content (takes full available width)
		button.Size = UDim2.new(1, -10, 0, 25)
		-- Don't set Position for accordion buttons - let UIListLayout handle it
		button.BorderColor3 = variantColors.border
		button.BorderSizePixel = 2
		button.TextSize = 12
		button.ZIndex = 5
		
		-- Round corners for accordion button
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 4)
		buttonCorner.Parent = button
		
		-- Button hover effects for accordion
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = variantColors.backgroundHover
		end)
		
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = variantColors.background
		end)
	else
		button.Size = UDim2.new(0, 120, 0, 30)
		button.Position = UDim2.new(0, 10, 0, currentY)
		button.BorderSizePixel = 0
		button.TextSize = 14
		button.ZIndex = 3
		button:SetAttribute("ComponentStartY", currentY)
	end
	button.BackgroundColor3 = variantColors.background
	button.Text = text
	button.TextColor3 = variantColors.text
	button.Font = Enum.Font.SourceSans
	button.TextScaled = false  -- Keep original text size
	button.TextWrapped = false -- Don't wrap text to new lines
	button.TextTruncate = Enum.TextTruncate.AtEnd -- Add ... at end if text is too long
	button.Parent = parentContainer

	-- Add hover effects for non-accordion buttons
	if not isForAccordion then
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = variantColors.backgroundHover
		end)
		
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = variantColors.background
		end)
	end

	if callback then
		button.MouseButton1Click:Connect(callback)
	end
	
	-- Create Button API
	local buttonAPI = {
		Button = button
	}

	function buttonAPI:SetText(newText)
		button.Text = newText or ""
	end

	function buttonAPI:GetText()
		return button.Text
	end

	function buttonAPI:SetCallback(newCallback)
		callback = newCallback or function() end
		button.MouseButton1Click:Connect(callback)
	end

	function buttonAPI:SetEnabled(enabled)
		button.Active = enabled
		if enabled then
			button.BackgroundColor3 = variantColors.background
		else
			-- Create a disabled version by reducing opacity/brightness
			local r, g, b = variantColors.background.R, variantColors.background.G, variantColors.background.B
			button.BackgroundColor3 = Color3.fromRGB(
				math.floor(r * 255 * 0.5),
				math.floor(g * 255 * 0.5),
				math.floor(b * 255 * 0.5)
			)
		end
	end
	
	function buttonAPI:SetVariant(newVariant)
		variant = newVariant or "primary"
		variantColors = getVariantColors(variant)
		
		-- Update button colors
		button.BackgroundColor3 = variantColors.background
		button.TextColor3 = variantColors.text
		if isForAccordion then
			button.BorderColor3 = variantColors.border
		end
	end
	
	function buttonAPI:GetVariant()
		return variant
	end
	
	return buttonAPI
end

return Button
