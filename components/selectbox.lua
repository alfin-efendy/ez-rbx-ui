--[[
local Colors = require(game.ReplicatedStorage.utils.colors)
	SelectBox Component
	EzUI Library - Modular Component
	
	Creates a dropdown select box with search and multi-select support
	Note: This is a simplified modular version. For full features, use the main UI library.
]]
local SelectBox = {}

local Colors

function SelectBox:Init(_colors)
	Colors = _colors
end

function SelectBox:Create(config)
	local rawOptions = config.Options or {"Option 1", "Option 2", "Option 3"}
	local placeholder = config.Placeholder or "Select option..."
	local multiSelect = config.MultiSelect or false
	local callback = config.Callback or function() end
	local flag = config.Flag
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local isForAccordion = config.IsForAccordion or false
	local screenGui = config.ScreenGui
	local EzUI = config.EzUI
	local saveConfiguration = config.SaveConfiguration
	local registerComponent = config.RegisterComponent
	local EzUIConfig = config.EzUIConfig
	
	-- Normalize options to {text, value} format
	local options = {}
	for i, option in ipairs(rawOptions) do
		if type(option) == "string" then
			table.insert(options, {text = option, value = option})
		elseif type(option) == "table" and option.text and option.value then
			table.insert(options, option)
		end
	end
	
	local selectedValues = {}
	local isOpen = false
	
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
			if type(flagValue) == "table" then
				selectedValues = flagValue
			elseif flagValue ~= "" then
				selectedValues = {flagValue}
			end
		end
	end
	
	-- Main container
	local selectContainer = Instance.new("Frame")
	if isForAccordion then
		selectContainer.Size = UDim2.new(1, 0, 0, 25)
		selectContainer.Position = UDim2.new(0, 0, 0, currentY)
		selectContainer.ZIndex = 6
	else
		selectContainer.Size = UDim2.new(1, -20, 0, 25)
		selectContainer.Position = UDim2.new(0, 10, 0, currentY)
		selectContainer.ZIndex = 3
		selectContainer:SetAttribute("ComponentStartY", currentY)
	end
	selectContainer.BackgroundTransparency = 1
	selectContainer.ClipsDescendants = false
	selectContainer.Parent = parentContainer
	
	-- Select button
	local selectButton = Instance.new("TextButton")
	selectButton.Size = UDim2.new(1, -25, 1, 0)
	selectButton.Position = UDim2.new(0, 0, 0, 0)
	selectButton.BackgroundColor3 = Colors.Dropdown.Option
	selectButton.BorderColor3 = Colors.Dropdown.Border
	selectButton.BorderSizePixel = 2
	selectButton.Text = "  " .. placeholder
	selectButton.TextColor3 = Colors.Text.Secondary
	selectButton.TextXAlignment = Enum.TextXAlignment.Left
	selectButton.Font = Enum.Font.SourceSans
	selectButton.TextSize = isForAccordion and 12 or 14
	selectButton.ZIndex = isForAccordion and 7 or 4
	selectButton.Parent = selectContainer
	
	-- Arrow button
	local arrow = Instance.new("TextButton")
	arrow.Size = UDim2.new(0, 25, 1, 0)
	arrow.Position = UDim2.new(1, -25, 0, 0)
	arrow.BackgroundColor3 = Colors.Surface.Default
	arrow.BorderColor3 = Colors.Dropdown.Border
	arrow.BorderSizePixel = 2
	arrow.Text = "▼"
	arrow.TextColor3 = Colors.Text.Secondary
	arrow.Font = Enum.Font.SourceSans
	arrow.TextSize = 10
	arrow.ZIndex = isForAccordion and 7 or 4
	arrow.Parent = selectContainer
	
	-- Dropdown frame
	local dropdownHeight = math.min(#options * 30 + 30, 200)
	local dropdownFrame = Instance.new("ScrollingFrame")
	dropdownFrame.Size = UDim2.new(1, 0, 0, dropdownHeight)
	dropdownFrame.Position = UDim2.new(0, 0, 1, 3)
	dropdownFrame.BackgroundColor3 = Colors.Dropdown.Background
	dropdownFrame.BorderColor3 = Colors.Dropdown.Border
	dropdownFrame.BorderSizePixel = 2
	dropdownFrame.Visible = false
	dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 30 + 30)
	dropdownFrame.ScrollBarThickness = 6
	dropdownFrame.ZIndex = 25
	dropdownFrame.Parent = screenGui or selectContainer.Parent
	
	-- Search box
	local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(1, -10, 0, 20)
	searchBox.Position = UDim2.new(0, 5, 0, 5)
	searchBox.BackgroundColor3 = Colors.Input.Background
	searchBox.BorderColor3 = Colors.Input.Border
	searchBox.BorderSizePixel = 1
	searchBox.PlaceholderText = "Search..."
	searchBox.Text = ""
	searchBox.TextColor3 = Colors.Text.Primary
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 10
	searchBox.ZIndex = 26
	searchBox.Parent = dropdownFrame
	
	-- Options container
	local optionsContainer = Instance.new("Frame")
	optionsContainer.Size = UDim2.new(1, 0, 1, -30)
	optionsContainer.Position = UDim2.new(0, 0, 0, 30)
	optionsContainer.BackgroundTransparency = 1
	optionsContainer.ZIndex = 26
	optionsContainer.Parent = dropdownFrame
	
	-- List layout
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = optionsContainer
	
	-- Update display text
	local function updateDisplayText()
		if #selectedValues == 0 then
			selectButton.Text = "  " .. placeholder
			selectButton.TextColor3 = Colors.Text.Secondary
		elseif multiSelect and #selectedValues > 1 then
			selectButton.Text = "  " .. #selectedValues .. " items selected"
			selectButton.TextColor3 = Colors.Text.Primary
		else
			local displayText = selectedValues[1]
			for _, option in ipairs(options) do
				if option.value == selectedValues[1] then
					displayText = option.text
					break
				end
			end
			selectButton.Text = "  " .. (displayText or "Unknown")
			selectButton.TextColor3 = Colors.Text.Primary
		end
	end
	
	-- Calculate dropdown position
	local function calculateDropdownPosition()
		local absolutePos = selectContainer.AbsolutePosition
		local absoluteSize = selectContainer.AbsoluteSize
		dropdownFrame.Position = UDim2.new(0, absolutePos.X, 0, absolutePos.Y + absoluteSize.Y + 3)
		dropdownFrame.Size = UDim2.new(0, absoluteSize.X, 0, dropdownHeight)
	end
	
	-- Create options
	local function refreshOptions()
		for _, child in pairs(optionsContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		
		for i, option in ipairs(options) do
			local optionButton = Instance.new("TextButton")
			optionButton.Size = UDim2.new(1, -10, 0, 30)
			optionButton.BackgroundColor3 = Colors.Dropdown.Option
			optionButton.BorderSizePixel = 0
			optionButton.Text = "  " .. option.text
			optionButton.TextColor3 = Colors.Text.Primary
			optionButton.TextXAlignment = Enum.TextXAlignment.Left
			optionButton.Font = Enum.Font.SourceSans
			optionButton.TextSize = 12
			optionButton.ZIndex = 27
			optionButton.Parent = optionsContainer
			
			-- Checkmark
			local checkmark = Instance.new("TextLabel")
			checkmark.Size = UDim2.new(0, 20, 1, 0)
			checkmark.Position = UDim2.new(1, -20, 0, 0)
			checkmark.BackgroundTransparency = 1
			checkmark.Text = ""
			checkmark.TextColor3 = Colors.Status.Success
			checkmark.Font = Enum.Font.SourceSansBold
			checkmark.TextSize = 12
			checkmark.ZIndex = 28
			checkmark.Visible = multiSelect
			checkmark.Parent = optionButton
			
			-- Check if selected
			local isSelected = false
			for _, val in ipairs(selectedValues) do
				if val == option.value then
					isSelected = true
					break
				end
			end
			
			if isSelected then
				checkmark.Text = "✓"
				optionButton.BackgroundColor3 = Colors.Dropdown.OptionSelected
			end
			
			-- Click handler
			optionButton.MouseButton1Click:Connect(function()
				if multiSelect then
					local found = false
					for j, val in ipairs(selectedValues) do
						if val == option.value then
							table.remove(selectedValues, j)
							found = true
							break
						end
					end
					
					if not found then
						table.insert(selectedValues, option.value)
					end
					
					refreshOptions()
				else
					selectedValues = {option.value}
					isOpen = false
					dropdownFrame.Visible = false
					arrow.Text = "▼"
				end
				
				updateDisplayText()
				
				-- Save to configuration
				if flag then
					local valueToSave = multiSelect and selectedValues or (selectedValues[1] or "")
					
					-- Check if using custom config object
					if EzUIConfig and type(EzUIConfig.SetValue) == "function" then
						EzUIConfig.SetValue(flag, valueToSave)
					-- Fallback to EzUI.Flags
					elseif EzUI and EzUI.Flags then
						EzUI.Flags[flag] = valueToSave
						-- Auto-save if enabled
						if EzUI.Configuration and EzUI.Configuration.AutoSave and saveConfiguration then
							saveConfiguration(EzUI.Configuration.FileName)
						end
					end
				end
				
				callback(selectedValues, option.value)
			end)
			
			-- Hover effects
			optionButton.MouseEnter:Connect(function()
				if not isSelected then
					optionButton.BackgroundColor3 = Colors.Dropdown.OptionHover
				end
			end)
			
			optionButton.MouseLeave:Connect(function()
				if not isSelected then
					optionButton.BackgroundColor3 = Colors.Dropdown.Option
				end
			end)
		end
	end
	
	-- Toggle dropdown
	local function toggleDropdown()
		isOpen = not isOpen
		dropdownFrame.Visible = isOpen
		arrow.Text = isOpen and "▲" or "▼"
		
		if isOpen then
			calculateDropdownPosition()
		end
	end
	
	-- Button handlers
	selectButton.MouseButton1Click:Connect(toggleDropdown)
	arrow.MouseButton1Click:Connect(toggleDropdown)
	
	-- Search filter
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local searchText = string.lower(searchBox.Text)
		for _, child in pairs(optionsContainer:GetChildren()) do
			if child:IsA("TextButton") then
				local optionText = string.lower(child.Text)
				child.Visible = searchText == "" or string.find(optionText, searchText, 1, true) ~= nil
			end
		end
	end)
	
	-- Initial setup
	refreshOptions()
	updateDisplayText()
	
	-- SelectBox API
	local selectBoxAPI = {
		GetSelected = function()
			return selectedValues
		end,
		SetSelected = function(values)
			selectedValues = type(values) == "table" and values or (values ~= "" and {values} or {})
			refreshOptions()
			updateDisplayText()
		end,
		Clear = function()
			selectedValues = {}
			refreshOptions()
			updateDisplayText()
		end,
		Refresh = function(newOptions)
			rawOptions = newOptions
			options = {}
			for i, option in ipairs(rawOptions) do
				if type(option) == "string" then
					table.insert(options, {text = option, value = option})
				elseif type(option) == "table" and option.text and option.value then
					table.insert(options, option)
				end
			end
			selectedValues = {}
			refreshOptions()
			updateDisplayText()
		end,
		Set = function(values)
			selectedValues = type(values) == "table" and values or (values ~= "" and {values} or {})
			updateDisplayText()
		end,
		Cleanup = function()
			if dropdownFrame then
				dropdownFrame:Destroy()
			end
			if selectContainer then
				selectContainer:Destroy()
			end
		end
	}
	
	-- Register component
	if registerComponent then
		registerComponent(flag, selectBoxAPI)
	end
	
	return selectBoxAPI
end

return SelectBox
