--[[
	Toggle Component
	EzUI Library - Modular Component
	
	Creates a toggle/switch with on/off states
]]
local Toggle = {}

local Colors

function Toggle:Init(_colors)
	Colors = _colors
end

function Toggle:Create(config)
	local text = config.Name or config.Text or "Toggle"
	local defaultValue = config.Default or false
	local callback = config.Callback or function() end
	local flag = config.Flag
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local isForAccordion = config.IsForAccordion or false
	local EzUI = config.EzUI
	local saveConfiguration = config.SaveConfiguration
	local registerComponent = config.RegisterComponent
	local EzUIConfig = config.EzUIConfig
	
	-- Toggle state
	local isToggled = defaultValue
	
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
			isToggled = flagValue
		end
	end
	
	-- Main toggle container
	local toggleContainer = Instance.new("Frame")
	if isForAccordion then
		toggleContainer.Size = UDim2.new(1, -10, 0, 25)
		toggleContainer.Position = UDim2.new(0, 5, 0, currentY)
		toggleContainer.ZIndex = 6
	else
		toggleContainer.Size = UDim2.new(1, -20, 0, 30)
		toggleContainer.Position = UDim2.new(0, 10, 0, currentY)
		toggleContainer.ZIndex = 3
		toggleContainer:SetAttribute("ComponentStartY", currentY)
	end
	toggleContainer.BackgroundTransparency = 1
	toggleContainer.Parent = parentContainer
	
	-- Toggle label
	local toggleLabel = Instance.new("TextLabel")
	if isForAccordion then
		toggleLabel.Size = UDim2.new(1, -45, 1, 0)
		toggleLabel.TextSize = 12
		toggleLabel.ZIndex = 7
	else
		toggleLabel.Size = UDim2.new(1, -60, 1, 0)
		toggleLabel.TextSize = 16
		toggleLabel.ZIndex = 4
	end
	toggleLabel.Position = UDim2.new(0, 0, 0, 0)
	toggleLabel.BackgroundTransparency = 1
	toggleLabel.Text = text
	toggleLabel.TextColor3 = Colors.Text.Primary
	toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	toggleLabel.Font = Enum.Font.SourceSans
	toggleLabel.Parent = toggleContainer
	
	-- Toggle switch background
	local toggleBg = Instance.new("Frame")
	if isForAccordion then
		toggleBg.Size = UDim2.new(0, 40, 0, 20)
		toggleBg.Position = UDim2.new(1, -40, 0.5, -10)
		toggleBg.ZIndex = 7
	else
		toggleBg.Size = UDim2.new(0, 50, 0, 24)
		toggleBg.Position = UDim2.new(1, -50, 0.5, -12)
		toggleBg.ZIndex = 4
	end
	toggleBg.BackgroundColor3 = isToggled and Colors.Toggle.On or Colors.Toggle.Off
	toggleBg.BorderSizePixel = 0
	toggleBg.Parent = toggleContainer
	
	-- Round corners for toggle background
	local toggleBgCorner = Instance.new("UICorner")
	toggleBgCorner.CornerRadius = UDim.new(0, isForAccordion and 10 or 12)
	toggleBgCorner.Parent = toggleBg
	
	-- Toggle switch button (circle)
	local toggleButton = Instance.new("TextButton")
	if isForAccordion then
		toggleButton.Size = UDim2.new(0, 16, 0, 16)
		toggleButton.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		toggleButton.ZIndex = 8
	else
		toggleButton.Size = UDim2.new(0, 20, 0, 20)
		toggleButton.Position = isToggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
		toggleButton.ZIndex = 5
	end
	toggleButton.BackgroundColor3 = Colors.Toggle.Handle
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = ""
	toggleButton.Parent = toggleBg
	
	-- Round corners for toggle button
	local toggleButtonCorner = Instance.new("UICorner")
	toggleButtonCorner.CornerRadius = UDim.new(0, isForAccordion and 8 or 10)
	toggleButtonCorner.Parent = toggleButton
	
	-- Function to update toggle appearance
	local function updateToggleAppearance()
		local targetBgColor = isToggled and Colors.Toggle.On or Colors.Toggle.Off
		local targetPosition
		
		if isForAccordion then
			targetPosition = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		else
			targetPosition = isToggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
		end
		
		-- Animate background color
		local bgTween = game:GetService("TweenService"):Create(
			toggleBg,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{BackgroundColor3 = targetBgColor}
		)
		bgTween:Play()
		
		-- Animate button position
		local buttonTween = game:GetService("TweenService"):Create(
			toggleButton,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{Position = targetPosition}
		)
		buttonTween:Play()
	end
	
	-- Toggle click handler
	local function handleToggle()
		isToggled = not isToggled
		updateToggleAppearance()
		
		-- Save to configuration
		if flag then
			-- Check if using custom config object
			if EzUIConfig and type(EzUIConfig.SetValue) == "function" then
				EzUIConfig.SetValue(flag, isToggled)
			-- Fallback to EzUI.Flags
			elseif EzUI and EzUI.Flags then
				EzUI.Flags[flag] = isToggled
				-- Auto-save if enabled
				if EzUI.Configuration and EzUI.Configuration.AutoSave and saveConfiguration then
					saveConfiguration(EzUI.Configuration.FileName)
				end
			end
		end
		
		-- Call user callback
		local success, errorMsg = pcall(function()
			callback(isToggled)
		end)
		
		if not success then
			warn("Toggle callback error:", errorMsg)
		end
	end
	
	toggleButton.MouseButton1Click:Connect(handleToggle)
	
	-- Also allow clicking the background to toggle
	toggleBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			handleToggle()
		end
	end)
	
	-- Hover effects
	toggleButton.MouseEnter:Connect(function()
		toggleButton.BackgroundColor3 = Colors.Toggle.Handle
	end)
	
	toggleButton.MouseLeave:Connect(function()
		toggleButton.BackgroundColor3 = Colors.Toggle.Handle
	end)
	
	-- Return Toggle API
	local toggleAPI = {}
	
	toggleAPI.SetValue = function(newValue)
		if type(newValue) == "boolean" and newValue ~= isToggled then
			isToggled = newValue
			updateToggleAppearance()
			
			-- Save to configuration
			if flag then
				-- Check if using custom config object
				if EzUIConfig and type(EzUIConfig.SetValue) == "function" then
					EzUIConfig.SetValue(flag, isToggled)
				-- Fallback to EzUI.Flags
				elseif EzUI and EzUI.Flags then
					EzUI.Flags[flag] = isToggled
					-- Auto-save if enabled
					if EzUI.Configuration and EzUI.Configuration.AutoSave and saveConfiguration then
						saveConfiguration(EzUI.Configuration.FileName)
					end
				end
			end
		end
	end
	
	toggleAPI.GetValue = function()
		return isToggled
	end
	
	toggleAPI.SetText = function(newText)
		text = newText
		toggleLabel.Text = newText
	end
	
	toggleAPI.SetCallback = function(newCallback)
		callback = newCallback or function() end
	end
	
	toggleAPI.Set = toggleAPI.SetValue
	
	-- Register component for flag-based updates
	if registerComponent then
		registerComponent(flag, toggleAPI)
	end
	
	return toggleAPI
end

return Toggle
