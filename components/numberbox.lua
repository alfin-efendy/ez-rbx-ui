--[[
	NumberBox Component
	EzUI Library - Modular Component
	
	Creates a numeric input field with increment/decrement buttons
]]
local NumberBox = {}

local Colors

function NumberBox:Init(_colors)
	Colors = _colors
end

function NumberBox:Create(config)
	local name = config.Name or config.Title or ""
	local placeholder = config.Placeholder or "Enter number..."
	local defaultValue = config.Default or 0
	local callback = config.Callback or function() end
	local minValue = config.Min or -math.huge
	local maxValue = config.Max or math.huge
	local increment = config.Increment or 1
	local decimals = config.Decimals or 0
	local flag = config.Flag
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local isForAccordion = config.IsForAccordion or false
	local EzUI = config.EzUI
	local saveConfiguration = config.SaveConfiguration
	local registerComponent = config.RegisterComponent
	local settings = config.Settings
	
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
			warn("NumberBox:Create - Parent is a table but no GUI object found. Keys:", table.concat(keys, ", "))
			parentContainer = nil
		end
	end
	
	-- Validate parent is an Instance
	if parentContainer and not typeof(parentContainer) == "Instance" then
		warn("NumberBox:Create - Parent must be an Instance, got:", typeof(parentContainer))
		parentContainer = nil
	end
	
	-- NumberBox state
	local currentValue = defaultValue
	
	-- Load from flag (supports both EzUI.Flags and custom config)
	if flag then
		local flagValue = nil
		
		-- Check if using custom config object
		if settings and type(settings.GetValue) == "function" then
			flagValue = settings:GetValue(flag)
		end
		
		if flagValue ~= nil then
			currentValue = flagValue
			defaultValue = currentValue
		end
	end
	
	-- Main numberbox container
	local numberBoxContainer = Instance.new("Frame")
	if isForAccordion then
		numberBoxContainer.Size = UDim2.new(1, -10, 0, 25)
		-- Don't set Position for accordion numberboxes - let UIListLayout handle it
		numberBoxContainer.ZIndex = 6
	else
		numberBoxContainer.Size = UDim2.new(1, -20, 0, 30)
		numberBoxContainer.Position = UDim2.new(0, 10, 0, currentY)
		numberBoxContainer.ZIndex = 3
		numberBoxContainer:SetAttribute("ComponentStartY", currentY)
	end
	numberBoxContainer.BackgroundTransparency = 1
	numberBoxContainer.ClipsDescendants = true -- Ensure text doesn't overflow container
	numberBoxContainer.Parent = parentContainer
	
	-- Number input box
	local numberBox = Instance.new("TextBox")
	if isForAccordion then
		numberBox.Size = UDim2.new(1, -45, 1, 0)
		numberBox.TextSize = 12
		numberBox.ZIndex = 7
	else
		numberBox.Size = UDim2.new(1, -60, 1, 0)
		numberBox.TextSize = 14
		numberBox.ZIndex = 4
	end
	numberBox.Position = UDim2.new(0, 0, 0, 0)
	numberBox.BackgroundColor3 = Colors.Input.Background
	numberBox.BorderColor3 = Colors.Input.Border
	numberBox.BorderSizePixel = 1
	numberBox.Text = decimals > 0 and string.format("%." .. decimals .. "f", defaultValue) or tostring(defaultValue)
	numberBox.PlaceholderText = placeholder
	numberBox.TextColor3 = Colors.Input.Text
	numberBox.PlaceholderColor3 = Colors.Input.Placeholder
	numberBox.Font = Enum.Font.SourceSans
	numberBox.TextXAlignment = Enum.TextXAlignment.Center
	numberBox.TextYAlignment = Enum.TextYAlignment.Center
	numberBox.TextScaled = false -- Prevent text from scaling down automatically
	numberBox.ClipsDescendants = true -- Clip text that overflows the TextBox
	numberBox.ClearTextOnFocus = false
	numberBox.Parent = numberBoxContainer
	
	-- Add padding to NumberBox
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingTop = UDim.new(0, 0)
	padding.PaddingBottom = UDim.new(0, 0)
	padding.Parent = numberBox
	
	-- Round corners for number box
	local numberCorner = Instance.new("UICorner")
	numberCorner.CornerRadius = UDim.new(0, 4)
	numberCorner.Parent = numberBox
	
	-- Increment button (up arrow)
	local incrementBtn = Instance.new("TextButton")
	if isForAccordion then
		incrementBtn.Size = UDim2.new(0, 20, 0, 12)
		incrementBtn.Position = UDim2.new(1, -22, 0, 1)
		incrementBtn.TextSize = 8
		incrementBtn.ZIndex = 7
	else
		incrementBtn.Size = UDim2.new(0, 25, 0, 14)
		incrementBtn.Position = UDim2.new(1, -30, 0, 1)
		incrementBtn.TextSize = 10
		incrementBtn.ZIndex = 4
	end
	incrementBtn.BackgroundColor3 = Colors.Surface.Default
	incrementBtn.BorderColor3 = Colors.Border.Default
	incrementBtn.BorderSizePixel = 1
	incrementBtn.Text = "▲"
	incrementBtn.TextColor3 = Colors.Text.Secondary
	incrementBtn.Font = Enum.Font.SourceSans
	incrementBtn.Parent = numberBoxContainer
	
	-- Decrement button (down arrow)
	local decrementBtn = Instance.new("TextButton")
	if isForAccordion then
		decrementBtn.Size = UDim2.new(0, 20, 0, 12)
		decrementBtn.Position = UDim2.new(1, -22, 0, 13)
		decrementBtn.TextSize = 8
		decrementBtn.ZIndex = 7
	else
		decrementBtn.Size = UDim2.new(0, 25, 0, 14)
		decrementBtn.Position = UDim2.new(1, -30, 0, 15)
		decrementBtn.TextSize = 10
		decrementBtn.ZIndex = 4
	end
	decrementBtn.BackgroundColor3 = Colors.Surface.Default
	decrementBtn.BorderColor3 = Colors.Border.Default
	decrementBtn.BorderSizePixel = 1
	decrementBtn.Text = "▼"
	decrementBtn.TextColor3 = Colors.Text.Secondary
	decrementBtn.Font = Enum.Font.SourceSans
	decrementBtn.Parent = numberBoxContainer
	
	-- Calculate heights based on whether we have a title label
	local hasTitle = name and name ~= ""
	local labelHeight = hasTitle and 18 or 0
	local inputHeight = isForAccordion and 25 or 30
	local totalHeight = labelHeight + inputHeight + (hasTitle and 2 or 0) -- 2px spacing between label and input

	-- Adjust container size
	if isForAccordion then
		numberBoxContainer.Size = UDim2.new(1, -10, 0, totalHeight)
	else
		numberBoxContainer.Size = UDim2.new(1, -20, 0, totalHeight)
	end

	-- Title label (if name is provided)
	if hasTitle then
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, 0, 0, labelHeight)
		titleLabel.Position = UDim2.new(0, 0, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = name
		titleLabel.TextColor3 = Colors.Text.Primary
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Font = Enum.Font.SourceSans
		titleLabel.TextSize = isForAccordion and 12 or 14
		titleLabel.ZIndex = isForAccordion and 7 or 4
		titleLabel.Parent = numberBoxContainer
	end

	-- Adjust numberBox position and size
	if hasTitle then
		numberBox.Position = UDim2.new(0, 0, 0, labelHeight + 2) -- Add spacing below title
		numberBox.Size = UDim2.new(1, -60, 0, inputHeight)
	else
		numberBox.Position = UDim2.new(0, 0, 0, 0)
	end

	-- Adjust increment and decrement button positions
	if hasTitle then
		-- Position buttons relative to numberBox when title exists
		local buttonY = labelHeight + 2
		if isForAccordion then
			incrementBtn.Position = UDim2.new(1, -22, 0, buttonY + 1)
			decrementBtn.Position = UDim2.new(1, -22, 0, buttonY + 13)
		else
			incrementBtn.Position = UDim2.new(1, -30, 0, buttonY + 1)
			decrementBtn.Position = UDim2.new(1, -30, 0, buttonY + 15)
		end
	else
		-- Keep original positions when no title
		if isForAccordion then
			incrementBtn.Position = UDim2.new(1, -22, 0, 1)
			decrementBtn.Position = UDim2.new(1, -22, 0, 13)
		else
			incrementBtn.Position = UDim2.new(1, -30, 0, 1)
			decrementBtn.Position = UDim2.new(1, -30, 0, 15)
		end
	end

	-- Function to validate and update value
	local function updateValue(newValue)
		-- Clamp to min/max
		newValue = math.max(minValue, math.min(maxValue, newValue))
		
		-- Round to decimal places
		if decimals > 0 then
			local multiplier = 10 ^ decimals
			newValue = math.floor(newValue * multiplier + 0.5) / multiplier
		else
			newValue = math.floor(newValue + 0.5)
		end
		
		currentValue = newValue
	
		-- Update text box display
		if decimals > 0 then
			numberBox.Text = string.format("%." .. decimals .. "f", newValue)
		else
			numberBox.Text = tostring(newValue)
		end
		
		-- Save to configuration
		if flag then
			settings:SetValue(flag, currentValue)
		end
		-- Call user callback
		local success, errorMsg = pcall(function()
			callback(currentValue)
		end)
		
		if not success then
			warn("NumberBox callback error:", errorMsg)
		end
		
		return newValue
	end 
	
	-- Text change handler with validation
	numberBox.FocusLost:Connect(function()
		local inputText = numberBox.Text
		local numValue = tonumber(inputText)
		
		if numValue then
			updateValue(numValue)
		else
			-- Invalid input, revert to current value
			if decimals > 0 then
				numberBox.Text = string.format("%." .. decimals .. "f", currentValue)
			else
				numberBox.Text = tostring(currentValue)
			end
		end
	end)
	
	-- Increment button handler
	incrementBtn.MouseButton1Click:Connect(function()
		updateValue(currentValue + increment)
	end)
	
	-- Decrement button handler
	decrementBtn.MouseButton1Click:Connect(function()
		updateValue(currentValue - increment)
	end)
	
	-- Button hover effects
	incrementBtn.MouseEnter:Connect(function()
		incrementBtn.BackgroundColor3 = Colors.Surface.Hover
	end)
	
	incrementBtn.MouseLeave:Connect(function()
		incrementBtn.BackgroundColor3 = Colors.Surface.Default
	end)
	
	decrementBtn.MouseEnter:Connect(function()
		decrementBtn.BackgroundColor3 = Colors.Surface.Hover
	end)
	
	decrementBtn.MouseLeave:Connect(function()
		decrementBtn.BackgroundColor3 = Colors.Surface.Default
	end)
	
	-- Focus effects
	numberBox.Focused:Connect(function()
		numberBox.BorderColor3 = Colors.Input.BorderFocus
	end)
	
	numberBox.FocusLost:Connect(function()
		numberBox.BorderColor3 = Colors.Input.Border
	end)
	
	-- Return NumberBox API
	local numberBoxAPI = {
		NumberBox = numberBoxContainer
	}
	
	function numberBoxAPI:GetValue()
		return currentValue
	end
	
	function numberBoxAPI:SetValue(newValue)
		local numValue = tonumber(newValue)
		if numValue then
			updateValue(numValue)
		else
			warn("NumberBox SetValue: Expected number, got " .. type(newValue))
		end
	end
	
	function numberBoxAPI:SetMin(newMin)
		minValue = tonumber(newMin) or -math.huge
		updateValue(currentValue)
	end
	
	function numberBoxAPI:SetMax(newMax)
		maxValue = tonumber(newMax) or math.huge
		updateValue(currentValue)
	end
	
	function numberBoxAPI:SetIncrement(newIncrement)
		increment = tonumber(newIncrement) or 1
	end
	
	function numberBoxAPI:Clear()
		updateValue(0)
	end
	
	function numberBoxAPI:Focus()
		numberBox:CaptureFocus()
	end
	
	function numberBoxAPI:Blur()
		numberBox:ReleaseFocus()
	end
	
	function numberBoxAPI:SetCallback(newCallback)
		callback = newCallback or function() end
	end
	
	function numberBoxAPI:Set(newValue)
		local numValue = tonumber(newValue)
		if numValue then
			updateValue(numValue)
		end
	end
	
	-- Register component for flag-based updates
	if registerComponent then
		registerComponent(flag, numberBoxAPI)
	end
	
	return numberBoxAPI
end

return NumberBox
