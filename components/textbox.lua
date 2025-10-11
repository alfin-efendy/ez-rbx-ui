--[[
	TextBox Component
	EzUI Library - Modular Component
	
	Creates a text input field with character counter
]]
local TextBox = {}

local Colors

function TextBox:Init(_colors)
	Colors = _colors
end

function TextBox:Create(config)
	local name = config.Name or config.Title or ""
	local placeholder = config.Placeholder or "Enter text..."
	local defaultText = config.Default or ""
	local callback = config.Callback or function() end
	local maxLength = config.MaxLength or 100
	local multiline = config.Multiline or false
	local flag = config.Flag
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local isForAccordion = config.IsForAccordion or false
	local EzUI = config.EzUI
	local saveConfiguration = config.SaveConfiguration
	local registerComponent = config.RegisterComponent
	local settings = config.Settings
	
	-- Button configuration
	local buttons = config.Buttons or {} -- Array of button configs: {Text="Submit", Callback=function() end}
	local hasButtons = #buttons > 0
	
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
			warn("TextBox:Create - Parent is a table but no GUI object found. Keys:", table.concat(keys, ", "))
			parentContainer = nil
		end
	end
	
	-- Validate parent is an Instance
	if parentContainer and not typeof(parentContainer) == "Instance" then
		warn("TextBox:Create - Parent must be an Instance, got:", typeof(parentContainer))
		parentContainer = nil
	end
	
	-- TextBox state
	local currentText = defaultText
	
	-- Load from flag (supports both EzUI.Flags and custom config)
	if flag then
		local flagValue = nil
		
		-- Check if using custom config object
		if settings and type(settings.GetValue) == "function" then
			print("Loading TextBox value for flag:", flag)
			flagValue = settings:GetValue(flag)
		else
			warn("No settings object to load TextBox value.", flag)
		end
		
		if flagValue ~= nil then
			currentText = flagValue
			defaultText = currentText
		end
	end
	
		-- Calculate heights based on whether we have a title label
	local hasTitle = name and name ~= ""
	local labelHeight = hasTitle and 18 or 0
	local inputHeight = multiline and (isForAccordion and 60 or 80) or (isForAccordion and 25 or 30)
	local totalHeight = labelHeight + inputHeight + (hasTitle and 2 or 0) -- 2px spacing between label and input
	
	-- Main textbox container
	local textBoxContainer = Instance.new("Frame")
	if isForAccordion then
		textBoxContainer.Size = UDim2.new(1, -10, 0, totalHeight)
		textBoxContainer.Position = UDim2.new(0, 5, 0, currentY)
		textBoxContainer.ZIndex = 6
	else
		textBoxContainer.Size = UDim2.new(1, -20, 0, totalHeight)
		textBoxContainer.Position = UDim2.new(0, 10, 0, currentY)
		textBoxContainer.ZIndex = 3
		textBoxContainer:SetAttribute("ComponentStartY", currentY)
	end
	textBoxContainer.BackgroundTransparency = 1
	textBoxContainer.ClipsDescendants = true -- Ensure text doesn't overflow container
	textBoxContainer.Parent = parentContainer
	
	-- Title label (if name is provided)
	local titleLabel = nil
	if hasTitle then
		titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, 0, 0, labelHeight)
		titleLabel.Position = UDim2.new(0, 0, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = name
		titleLabel.TextColor3 = Colors.Text.Primary
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Font = Enum.Font.SourceSans
		titleLabel.TextSize = isForAccordion and 12 or 14
		titleLabel.ZIndex = isForAccordion and 7 or 4
		titleLabel.Parent = textBoxContainer
	end
	
	-- Calculate button width (each button is 80px wide + 5px spacing)
	local buttonWidth = hasButtons and (#buttons * 85) or 0 -- 80px + 5px spacing per button
	
	-- TextBox input
	local textBox = Instance.new("TextBox")
	if hasTitle then
		textBox.Size = UDim2.new(1, -buttonWidth, 0, inputHeight)
		textBox.Position = UDim2.new(0, 0, 0, labelHeight + 2)
	else
		if hasButtons then
			textBox.Size = UDim2.new(1, -buttonWidth, 1, 0)
		else
			textBox.Size = UDim2.new(1, 0, 1, 0)
		end
		textBox.Position = UDim2.new(0, 0, 0, 0)
	end
	textBox.BackgroundColor3 = Colors.Input.Background
	textBox.BorderColor3 = Colors.Input.Border
	textBox.BorderSizePixel = 1
	textBox.Text = defaultText
	textBox.PlaceholderText = placeholder
	textBox.TextColor3 = Colors.Input.Text
	textBox.PlaceholderColor3 = Colors.Text.Tertiary
	textBox.Font = Enum.Font.SourceSans
	textBox.TextSize = isForAccordion and 12 or 14
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
	textBox.MultiLine = multiline
	textBox.TextWrapped = multiline
	textBox.TextScaled = false -- Prevent text from scaling down automatically
	textBox.ClearTextOnFocus = false
	textBox.ClipsDescendants = true -- Clip text that overflows the TextBox
	textBox.ZIndex = isForAccordion and 7 or 4
	textBox.Parent = textBoxContainer
	
	-- Add padding to TextBox
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingTop = multiline and UDim.new(0, 4) or UDim.new(0, 0)
	padding.PaddingBottom = multiline and UDim.new(0, 4) or UDim.new(0, 0)
	padding.Parent = textBox
	
	-- Round corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = textBox
	
	-- Character counter (if maxLength is set)
	local charCounter = nil
	if maxLength and maxLength > 0 then
		charCounter = Instance.new("TextLabel")
		charCounter.Size = UDim2.new(0, 50, 0, 15)
		charCounter.Position = UDim2.new(1, -55, 1, -18)
		charCounter.BackgroundTransparency = 1
		charCounter.Text = string.len(currentText) .. "/" .. maxLength
		charCounter.TextColor3 = Colors.Text.Tertiary
		charCounter.Font = Enum.Font.SourceSans
		charCounter.TextSize = isForAccordion and 10 or 12
		charCounter.TextXAlignment = Enum.TextXAlignment.Right
		charCounter.ZIndex = isForAccordion and 8 or 5
		charCounter.Parent = textBoxContainer
	end
	
	-- Create buttons (if configured)
	local buttonObjects = {}
	if hasButtons then
		local buttonY = hasTitle and (labelHeight + 2) or 0
		local buttonHeight = inputHeight
		
		for i, buttonConfig in ipairs(buttons) do
			local buttonText = buttonConfig.Text or "Button"
			local buttonCallback = buttonConfig.Callback or function() end
			local buttonVariant = buttonConfig.Variant or "primary"
			
			-- Calculate button position (buttons are positioned from right to left)
			local buttonX = (1 - (i * 85 / textBoxContainer.AbsoluteSize.X)) -- 85px per button from right
			
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(0, 80, 0, buttonHeight)
			button.Position = UDim2.new(1, -i * 85 + 5, 0, buttonY) -- 5px spacing from edge
			button.BackgroundColor3 = buttonVariant == "primary" and Colors.Accent.Primary or Colors.Surface.Default
			button.BorderSizePixel = 0
			button.Text = buttonText
			button.TextColor3 = buttonVariant == "primary" and Color3.fromRGB(255, 255, 255) or Colors.Text.Primary
			button.Font = Enum.Font.SourceSans
			button.TextSize = isForAccordion and 11 or 13
			button.ZIndex = isForAccordion and 7 or 4
			button.Parent = textBoxContainer
			
			-- Button corner radius
			local buttonCorner = Instance.new("UICorner")
			buttonCorner.CornerRadius = UDim.new(0, 4)
			buttonCorner.Parent = button
			
			-- Button hover effects
			button.MouseEnter:Connect(function()
				if buttonVariant == "primary" then
					button.BackgroundColor3 = Colors.Accent.Hover
				else
					button.BackgroundColor3 = Colors.Surface.Hover
				end
			end)
			
			button.MouseLeave:Connect(function()
				if buttonVariant == "primary" then
					button.BackgroundColor3 = Colors.Accent.Primary
				else
					button.BackgroundColor3 = Colors.Surface.Default
				end
			end)
			
			-- Button click handler
			button.MouseButton1Click:Connect(function()
				if buttonCallback then
					buttonCallback(textBox.Text, textBox) -- Pass current text and textBox reference
				end
			end)
			
			table.insert(buttonObjects, {
				Button = button,
				Text = buttonText,
				Callback = buttonCallback
			})
		end
	end
	
	-- Function to update character counter
	local function updateCharCounter()
		if charCounter then
			local textLength = string.len(textBox.Text)
			charCounter.Text = textLength .. "/" .. maxLength
			
			-- Change color based on limit
			if textLength >= maxLength then
				charCounter.TextColor3 = Colors.Status.Error
			elseif textLength >= maxLength * 0.8 then
				charCounter.TextColor3 = Colors.Status.Warning
			else
				charCounter.TextColor3 = Colors.Text.Tertiary
			end
		end
	end
	
	-- Text change handler
	textBox.Changed:Connect(function(property)
		if property == "Text" then
			-- Enforce max length
			if maxLength and maxLength > 0 and string.len(textBox.Text) > maxLength then
				textBox.Text = string.sub(textBox.Text, 1, maxLength)
			end
			
			currentText = textBox.Text
			updateCharCounter()
			
			-- Save to configuration
			if flag then
				print("Saving TextBox value for flag:", flag, "Value:", currentText)
				settings:SetValue(flag, currentText)
			end
			
			-- Call user callback
			local success, errorMsg = pcall(function()
				callback(currentText)
			end)
			
			if not success then
				warn("TextBox callback error:", errorMsg)
			end
		end
	end)
	
	-- Focus effects
	textBox.Focused:Connect(function()
		textBox.BorderColor3 = Colors.Input.BorderFocus
	end)
	
	textBox.FocusLost:Connect(function()
		textBox.BorderColor3 = Colors.Input.Border
	end)
	
	-- Return TextBox API
	local textBoxAPI = {
		TextBox = textBoxContainer,
		Buttons = buttonObjects
	}
	
	function textBoxAPI:GetText()
		return currentText
	end
	
	function textBoxAPI:SetText(newText)
		textBox.Text = tostring(newText or "")
		currentText = textBox.Text
		updateCharCounter()
		-- Save to configuration
		if flag then
			settings:SetValue(flag, currentText)
		end
	end
	
	function textBoxAPI:Clear()
		textBox.Text = ""
		currentText = ""
		updateCharCounter()
		-- Save to configuration
		if flag then
			-- Check if using custom config object
			if EzUIConfig and type(EzUIConfig.SetValue) == "function" then
				EzUIConfig.SetValue(flag, currentText)
			-- Fallback to EzUI.Flags
			elseif EzUI and EzUI.Flags then
				EzUI.Flags[flag] = currentText
				-- Auto-save if enabled
				if EzUI.Configuration and EzUI.Configuration.AutoSave and saveConfiguration then
					saveConfiguration(EzUI.Configuration.FileName)
				end
			end
		end
	end
	
	function textBoxAPI:SetPlaceholder(newPlaceholder)
		textBox.PlaceholderText = tostring(newPlaceholder or "")
	end
	
	function textBoxAPI:Focus()
		textBox:CaptureFocus()
	end
	
	function textBoxAPI:Blur()
		textBox:ReleaseFocus()
	end
	
	function textBoxAPI:SetCallback(newCallback)
		callback = newCallback or function() end
	end
	
	function textBoxAPI:Set(newText)
		textBox.Text = tostring(newText or "")
		currentText = textBox.Text
		updateCharCounter()
	end
	
	-- Button-related methods
	function textBoxAPI:GetButton(index)
		return buttonObjects[index]
	end
	
	function textBoxAPI:SetButtonText(index, newText)
		if buttonObjects[index] then
			buttonObjects[index].Button.Text = newText
			buttonObjects[index].Text = newText
		end
	end
	
	function textBoxAPI:SetButtonCallback(index, newCallback)
		if buttonObjects[index] then
			buttonObjects[index].Callback = newCallback or function() end
			-- Note: We can't change the connected event, but we update the stored callback
		end
	end
	
	function textBoxAPI:EnableButton(index)
		if buttonObjects[index] then
			buttonObjects[index].Button.BackgroundTransparency = 0
			buttonObjects[index].Button.TextTransparency = 0
		end
	end
	
	function textBoxAPI:DisableButton(index)
		if buttonObjects[index] then
			buttonObjects[index].Button.BackgroundTransparency = 0.5
			buttonObjects[index].Button.TextTransparency = 0.5
		end
	end
	
	-- Register component for flag-based updates
	if registerComponent then
		registerComponent(flag, textBoxAPI)
	end
	
	return textBoxAPI
end

return TextBox
