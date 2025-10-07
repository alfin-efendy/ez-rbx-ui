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
	local EzUIConfig = config.EzUIConfig
	
	-- TextBox state
	local currentText = defaultText
	
	-- Load from flag (supports both EzUI.Flags and custom config)
	if flag then
		local flagValue = nil
		
		-- Check if using custom config object
		if EzUIConfig and type(EzUIConfig.GetValue) == "function" then
			flagValue = EzUIConfig.GetValue(flag)
		-- Fallback to EzUI.Flags
		elseif EzUI and EzUI.Flags then
			flagValue = EzUI.Flags[flag]
		end
		
		if flagValue ~= nil then
			currentText = flagValue
			defaultText = currentText
		end
	end
	
	-- Main textbox container
	local textBoxContainer = Instance.new("Frame")
	if isForAccordion then
		textBoxContainer.Size = UDim2.new(1, -10, 0, multiline and 60 or 25)
		textBoxContainer.Position = UDim2.new(0, 5, 0, currentY)
		textBoxContainer.ZIndex = 6
	else
		textBoxContainer.Size = UDim2.new(1, -20, 0, multiline and 80 or 30)
		textBoxContainer.Position = UDim2.new(0, 10, 0, currentY)
		textBoxContainer.ZIndex = 3
		textBoxContainer:SetAttribute("ComponentStartY", currentY)
	end
	textBoxContainer.BackgroundTransparency = 1
	textBoxContainer.Parent = parentContainer
	
	-- TextBox input
	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, 0, 1, 0)
	textBox.Position = UDim2.new(0, 0, 0, 0)
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
	textBox.ClearTextOnFocus = false
	textBox.ZIndex = isForAccordion and 7 or 4
	textBox.Parent = textBoxContainer
	
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
		GetText = function()
			return currentText
		end,
		SetText = function(newText)
			textBox.Text = tostring(newText or "")
			currentText = textBox.Text
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
		end,
		Clear = function()
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
		end,
		SetPlaceholder = function(newPlaceholder)
			textBox.PlaceholderText = tostring(newPlaceholder or "")
		end,
		Focus = function()
			textBox:CaptureFocus()
		end,
		Blur = function()
			textBox:ReleaseFocus()
		end,
		SetCallback = function(newCallback)
			callback = newCallback or function() end
		end,
		Set = function(newText)
			textBox.Text = tostring(newText or "")
			currentText = textBox.Text
			updateCharCounter()
		end
	}
	
	-- Register component for flag-based updates
	if registerComponent then
		registerComponent(flag, textBoxAPI)
	end
	
	return textBoxAPI
end

return TextBox
