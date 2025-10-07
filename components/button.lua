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
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local isForAccordion = config.IsForAccordion or false
	
	local button = Instance.new("TextButton")
	if isForAccordion then
		button.Size = UDim2.new(0, 100, 0, 25)
		button.Position = UDim2.new(0, 0, 0, currentY)
		button.BorderColor3 = Colors.Text.Primary
		button.BorderSizePixel = 2
		button.TextSize = 12
		button.ZIndex = 5
		
		-- Round corners for accordion button
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 4)
		buttonCorner.Parent = button
		
		-- Button hover effects for accordion
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Colors.Button.PrimaryHover
		end)
		
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Colors.Button.Primary
		end)
	else
		button.Size = UDim2.new(0, 120, 0, 30)
		button.Position = UDim2.new(0, 10, 0, currentY)
		button.BorderSizePixel = 0
		button.TextSize = 14
		button.ZIndex = 3
		button:SetAttribute("ComponentStartY", currentY)
	end
	button.BackgroundColor3 = Colors.Button.Primary
	button.Text = text
	button.TextColor3 = Colors.Text.Primary
	button.Font = Enum.Font.SourceSans
	button.Parent = parentContainer

	if callback then
		button.MouseButton1Click:Connect(callback)
	end
	
	-- Create Button API
	local buttonAPI = {}
	
	buttonAPI.SetText = function(newText)
		button.Text = newText or ""
	end
	
	buttonAPI.GetText = function()
		return button.Text
	end
	
	buttonAPI.SetCallback = function(newCallback)
		callback = newCallback or function() end
		button.MouseButton1Click:Connect(callback)
	end
	
	buttonAPI.SetEnabled = function(enabled)
		button.Active = enabled
		if enabled then
			button.BackgroundColor3 = Colors.Button.Primary
		else
			button.BackgroundColor3 = Colors.Button.PrimaryDisabled
		end
	end
	
	return buttonAPI
end

return Button
