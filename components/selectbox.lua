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
	local name = config.Name or config.Title or ""
	local rawOptions = config.Options or {"Option 1", "Option 2", "Option 3"}
	local placeholder = config.Placeholder or "Select option..."
	local multiSelect = config.MultiSelect or false
	local callback = config.Callback or function() end
	local onDropdownOpen = config.OnDropdownOpen or function() end
	local onInit = config.OnInit or function() end
	local bottomSheetMaxHeight = config.BottomSheetHeight or config.MaxHeight or 320
	local flag = config.Flag
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local isForAccordion = config.IsForAccordion or false
	local screenGui = config.ScreenGui
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
			warn("SelectBox:Create - Parent is a table but no GUI object found. Keys:", table.concat(keys, ", "))
			parentContainer = nil
		end
	end
	
	-- Validate parent is an Instance
	if parentContainer and not typeof(parentContainer) == "Instance" then
		warn("SelectBox:Create - Parent must be an Instance, got:", typeof(parentContainer))
		parentContainer = nil
	end
	
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
	
	-- Title configuration
	local hasTitle = name and name ~= ""
	local labelHeight = isForAccordion and 16 or 18
	local selectHeight = isForAccordion and 25 or 30
	local totalHeight = hasTitle and (labelHeight + selectHeight + 2) or selectHeight
	
	-- Load from flag (supports both EzUI.Flags and custom config)
	if flag then
		local flagValue = nil
		
		-- Check if using custom config object
		if settings and type(settings.GetValue) == "function" then
			flagValue = settings:GetValue(flag)
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
		selectContainer.Size = UDim2.new(1, 0, 0, totalHeight)
		-- Don't set Position for accordion selectboxes - let UIListLayout handle it
		selectContainer.ZIndex = 6
	else
		selectContainer.Size = UDim2.new(1, -20, 0, totalHeight)
		selectContainer.Position = UDim2.new(0, 10, 0, currentY)
		selectContainer.ZIndex = 3
		selectContainer:SetAttribute("ComponentStartY", currentY)
	end
	selectContainer.BackgroundTransparency = 1
	selectContainer.ClipsDescendants = false
	selectContainer.Parent = parentContainer
	
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
		titleLabel.Parent = selectContainer
	end
	
	-- Select button (modern design)
	local selectButton = Instance.new("TextButton")
	if hasTitle then
		selectButton.Size = UDim2.new(1, 0, 0, selectHeight)
		selectButton.Position = UDim2.new(0, 0, 0, labelHeight + 2)
	else
		selectButton.Size = UDim2.new(1, 0, 1, 0)
		selectButton.Position = UDim2.new(0, 0, 0, 0)
	end
	selectButton.BackgroundColor3 = Colors.Input.Background
	selectButton.BorderSizePixel = 0
	selectButton.Text = "  " .. placeholder
	selectButton.TextColor3 = Colors.Text.Secondary
	selectButton.TextXAlignment = Enum.TextXAlignment.Left
	selectButton.Font = Enum.Font.Gotham
	selectButton.TextSize = isForAccordion and 12 or 14
	selectButton.TextScaled = false
	selectButton.ClipsDescendants = true
	selectButton.ZIndex = isForAccordion and 7 or 4
	selectButton.Parent = selectContainer
	
	-- Chips container for multi-select (scrollable, tighter spacing)
	local chipsContainer = Instance.new("ScrollingFrame")
	chipsContainer.Size = UDim2.new(1, -24, 1, -2) -- Reduced gap to arrow
	chipsContainer.Position = UDim2.new(0, 8, 0, 1)
	chipsContainer.BackgroundTransparency = 1
	chipsContainer.BorderSizePixel = 0
	chipsContainer.ClipsDescendants = true
	chipsContainer.ScrollBarThickness = 0 -- Hide scrollbar for cleaner look
	chipsContainer.ScrollingDirection = Enum.ScrollingDirection.X -- Horizontal scroll
	chipsContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be auto-calculated
	chipsContainer.ZIndex = selectButton.ZIndex + 1
	chipsContainer.Parent = selectButton
	chipsContainer.Visible = false -- Initially hidden
	
	-- Chips layout
	local chipsLayout = Instance.new("UIListLayout")
	chipsLayout.FillDirection = Enum.FillDirection.Horizontal
	chipsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	chipsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	chipsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	chipsLayout.Padding = UDim.new(0, 4)
	chipsLayout.Wraps = false -- No wrapping since we're scrolling horizontally
	chipsLayout.Parent = chipsContainer
	
	-- Modern rounded corners
	local selectCorner = Instance.new("UICorner")
	selectCorner.CornerRadius = UDim.new(0, 8)
	selectCorner.Parent = selectButton
	
	-- Subtle border effect
	local selectStroke = Instance.new("UIStroke")
	selectStroke.Color = Colors.Input.Border
	selectStroke.Thickness = 1
	selectStroke.Parent = selectButton
	
	-- Padding for better text spacing (further reduced right padding)
	local selectPadding = Instance.new("UIPadding")
	selectPadding.PaddingLeft = UDim.new(0, 8)
	selectPadding.PaddingRight = UDim.new(0, 24)
	selectPadding.PaddingTop = UDim.new(0, 1)
	selectPadding.PaddingBottom = UDim.new(0, 1)
	selectPadding.Parent = selectButton
	
	-- Modern arrow icon (embedded in select button, tighter positioning)
	local arrow = Instance.new("TextLabel")
	if hasTitle then
		arrow.Size = UDim2.new(0, 20, 0, selectHeight)
		arrow.Position = UDim2.new(1, -20, 0, labelHeight + 2)
	else
		arrow.Size = UDim2.new(0, 20, 1, 0)
		arrow.Position = UDim2.new(1, -20, 0, 0)
	end
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = Colors.Text.Secondary
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.TextYAlignment = Enum.TextYAlignment.Center
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = isForAccordion and 14 or 16
	arrow.ZIndex = isForAccordion and 8 or 5
	arrow.Parent = selectContainer
	
	-- Find the window frame container
	local windowFrame = screenGui and screenGui:FindFirstChild("Frame") or selectContainer.Parent
	while windowFrame and not (windowFrame.Name:find("Frame") and windowFrame.Parent == screenGui) do
		windowFrame = windowFrame.Parent
		if windowFrame == screenGui or not windowFrame then
			windowFrame = screenGui:FindFirstChildOfClass("Frame")
			break
		end
	end
	
	-- Bottom sheet overlay (TextButton for click detection)
	local bottomSheetOverlay = Instance.new("TextButton")
	bottomSheetOverlay.Size = UDim2.new(1, 0, 1, 0)
	bottomSheetOverlay.Position = UDim2.new(0, 0, 0, 0)
	bottomSheetOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bottomSheetOverlay.BackgroundTransparency = 0.5
	bottomSheetOverlay.BorderSizePixel = 0
	bottomSheetOverlay.Text = ""
	bottomSheetOverlay.Visible = false
	bottomSheetOverlay.ZIndex = 100
	bottomSheetOverlay.Parent = windowFrame or screenGui or selectContainer.Parent
	
	-- Bottom sheet container (customizable height)
	local bottomSheetHeight = math.min(#options * 35 + 90, bottomSheetMaxHeight)
	local bottomSheet = Instance.new("Frame")
	bottomSheet.Size = UDim2.new(1, -40, 0, bottomSheetHeight)
	bottomSheet.Position = UDim2.new(0, 20, 1, 0) -- Start below window
	bottomSheet.BackgroundColor3 = Colors.Surface.Default
	bottomSheet.BorderSizePixel = 0
	bottomSheet.ZIndex = 101
	bottomSheet.Parent = bottomSheetOverlay
	
	-- Modern rounded corners for bottom sheet
	local bottomSheetCorner = Instance.new("UICorner")
	bottomSheetCorner.CornerRadius = UDim.new(0, 12)
	bottomSheetCorner.Parent = bottomSheet
	
	-- Handle bar at top of bottom sheet (smaller)
	local handleBar = Instance.new("Frame")
	handleBar.Size = UDim2.new(0, 32, 0, 3)
	handleBar.Position = UDim2.new(0.5, -16, 0, 6)
	handleBar.BackgroundColor3 = Colors.Text.Secondary
	handleBar.BorderSizePixel = 0
	handleBar.ZIndex = 102
	handleBar.Parent = bottomSheet
	
	local handleCorner = Instance.new("UICorner")
	handleCorner.CornerRadius = UDim.new(0, 1.5)
	handleCorner.Parent = handleBar
	
	-- Title for bottom sheet (smaller)
	local sheetTitle = Instance.new("TextLabel")
	sheetTitle.Size = UDim2.new(1, -32, 0, 24)
	sheetTitle.Position = UDim2.new(0, 16, 0, 16)
	sheetTitle.BackgroundTransparency = 1
	sheetTitle.Text = name ~= "" and name or "Select Option"
	sheetTitle.TextColor3 = Colors.Text.Primary
	sheetTitle.TextXAlignment = Enum.TextXAlignment.Left
	sheetTitle.TextYAlignment = Enum.TextYAlignment.Center
	sheetTitle.Font = Enum.Font.GothamBold
	sheetTitle.TextSize = 16
	sheetTitle.ZIndex = 102
	sheetTitle.Parent = bottomSheet
	
	-- Modern search box (smaller)
	local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(1, -32, 0, 32)
	searchBox.Position = UDim2.new(0, 16, 0, 48)
	searchBox.BackgroundColor3 = Colors.Input.Background
	searchBox.BorderSizePixel = 0
	searchBox.PlaceholderText = "🔍 Search options..."
	searchBox.Text = ""
	searchBox.TextColor3 = Colors.Text.Primary
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 13
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ZIndex = 102
	searchBox.Parent = bottomSheet
	
	-- Search box styling
	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 6)
	searchCorner.Parent = searchBox
	
	local searchPadding = Instance.new("UIPadding")
	searchPadding.PaddingLeft = UDim.new(0, 12)
	searchPadding.PaddingRight = UDim.new(0, 12)
	searchPadding.Parent = searchBox
	
	-- Options container (scrollable, smaller)
	local optionsScrollFrame = Instance.new("ScrollingFrame")
	optionsScrollFrame.Size = UDim2.new(1, -32, 1, -96)
	optionsScrollFrame.Position = UDim2.new(0, 16, 0, 88)
	optionsScrollFrame.BackgroundTransparency = 1
	optionsScrollFrame.BorderSizePixel = 0
	optionsScrollFrame.ScrollBarThickness = 4
	optionsScrollFrame.ScrollBarImageColor3 = Colors.Accent.Primary
	optionsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	optionsScrollFrame.ZIndex = 102
	optionsScrollFrame.Parent = bottomSheet
	
	local optionsContainer = Instance.new("Frame")
	optionsContainer.Size = UDim2.new(1, 0, 0, 0) -- Auto-size based on content
	optionsContainer.Position = UDim2.new(0, 0, 0, 0)
	optionsContainer.BackgroundTransparency = 1
	optionsContainer.ZIndex = 103
	optionsContainer.Parent = optionsScrollFrame
	
	-- List layout
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = optionsContainer
	
	-- Forward declarations
	local updateDisplayText, refreshOptions, removeSelectedValue
	
	-- Update display text and chips
	function updateDisplayText()
		-- Clear existing chips
		for _, child in pairs(chipsContainer:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		
		if #selectedValues == 0 then
			-- Show placeholder text
			selectButton.Text = "  " .. placeholder
			selectButton.TextColor3 = Colors.Text.Secondary
			chipsContainer.Visible = false
		elseif multiSelect and #selectedValues > 0 then
			-- Hide button text and show chips
			selectButton.Text = ""
			chipsContainer.Visible = true
			
			local totalWidth = 0
			
			-- Create chips for all selected items
			for i, value in ipairs(selectedValues) do
				local displayText = value
				for _, option in ipairs(options) do
					if option.value == value then
						displayText = option.text
						break
					end
				end
				
				-- Create chip container
				local chip = Instance.new("Frame")
				chip.Size = UDim2.new(0, 0, 0, selectHeight - 8) -- Auto-width, fit height
				chip.BackgroundColor3 = Colors.Accent.Primary
				chip.BorderSizePixel = 0
				chip.ZIndex = chipsContainer.ZIndex + 1
				chip.LayoutOrder = i
				chip.Parent = chipsContainer
				
				-- Chip corner radius
				local chipCorner = Instance.new("UICorner")
				chipCorner.CornerRadius = UDim.new(0, (selectHeight - 8) / 2) -- Pill shape
				chipCorner.Parent = chip
				
				-- Chip text
				local chipText = Instance.new("TextLabel")
				chipText.Size = UDim2.new(1, -20, 1, 0) -- Leave space for X button
				chipText.Position = UDim2.new(0, 8, 0, 0)
				chipText.BackgroundTransparency = 1
				chipText.Text = displayText
				chipText.TextColor3 = Color3.fromRGB(255, 255, 255)
				chipText.TextXAlignment = Enum.TextXAlignment.Left
				chipText.TextYAlignment = Enum.TextYAlignment.Center
				chipText.Font = Enum.Font.Gotham
				chipText.TextSize = isForAccordion and 10 or 12
				chipText.TextScaled = false
				chipText.ZIndex = chip.ZIndex + 1
				chipText.Parent = chip
				
				-- X button for removing chip
				local removeButton = Instance.new("TextButton")
				removeButton.Size = UDim2.new(0, 16, 0, 16)
				removeButton.Position = UDim2.new(1, -18, 0.5, -8)
				removeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				removeButton.BackgroundTransparency = 0.2
				removeButton.BorderSizePixel = 0
				removeButton.Text = "×"
				removeButton.TextColor3 = Colors.Accent.Primary
				removeButton.TextSize = 12
				removeButton.Font = Enum.Font.GothamBold
				removeButton.ZIndex = chip.ZIndex + 2
				removeButton.Parent = chip
				
				-- X button corner radius
				local removeCorner = Instance.new("UICorner")
				removeCorner.CornerRadius = UDim.new(0, 8)
				removeCorner.Parent = removeButton
				
				-- X button hover effect
				removeButton.MouseEnter:Connect(function()
					removeButton.BackgroundTransparency = 0
				end)
				
				removeButton.MouseLeave:Connect(function()
					removeButton.BackgroundTransparency = 0.2
				end)
				
				-- Remove chip on click
				removeButton.MouseButton1Click:Connect(function()
					removeSelectedValue(value)
				end)
				
				-- Auto-size chip based on text
				local textBounds = game:GetService("TextService"):GetTextSize(
					displayText,
					chipText.TextSize,
					chipText.Font,
					Vector2.new(200, chipText.AbsoluteSize.Y)
				)
				local chipWidth = textBounds.X + 32 -- Text width + padding + X button
				chip.Size = UDim2.new(0, chipWidth, 0, selectHeight - 8)
				
				-- Add to total width for canvas sizing
				totalWidth = totalWidth + chipWidth + 4 -- Include padding
			end
			
			-- Update canvas size for horizontal scrolling
			chipsContainer.CanvasSize = UDim2.new(0, math.max(totalWidth, chipsContainer.AbsoluteSize.X), 0, 0)
		else
			-- Single select mode
			local displayText = selectedValues[1]
			for _, option in ipairs(options) do
				if option.value == selectedValues[1] then
					displayText = option.text
					break
				end
			end
			selectButton.Text = "  " .. (displayText or "Unknown")
			selectButton.TextColor3 = Colors.Text.Primary
			chipsContainer.Visible = false
		end
	end
	
	-- Remove a selected value (for chip removal)
	function removeSelectedValue(value)
		for i, val in ipairs(selectedValues) do
			if val == value then
				table.remove(selectedValues, i)
				break
			end
		end
		updateDisplayText()
		refreshOptions()
		
		-- Save to configuration
		if flag then
			local valueToSave = multiSelect and selectedValues or (selectedValues[1] or "")
			settings:SetValue(flag, valueToSave)
		end
		
		callback(selectedValues, value)
	end
	
	-- Show/hide bottom sheet with animation
	local TweenService = game:GetService("TweenService")
	
	local function showBottomSheet()
		bottomSheetOverlay.Visible = true
		
		-- Call OnDropdownOpen callback when dropdown is opened
		if onDropdownOpen then
			onDropdownOpen(options, function(newOptions)
				-- Callback function to update options
				if newOptions and type(newOptions) == "table" then
					-- Update options with new data
					rawOptions = newOptions
					options = {}
					for i, option in ipairs(rawOptions) do
						if type(option) == "string" then
							table.insert(options, {text = option, value = option})
						elseif type(option) == "table" and option.text and option.value then
							table.insert(options, option)
						end
					end
					
					-- Refresh the options display
					refreshOptions()
				end
			end)
		end
		
		-- Animate overlay fade in
		local overlayTween = TweenService:Create(bottomSheetOverlay, 
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{BackgroundTransparency = 0.3}
		)
		overlayTween:Play()
		
		-- Animate bottom sheet slide up from bottom of window
		local sheetTween = TweenService:Create(bottomSheet, 
			TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
			{Position = UDim2.new(0, 20, 1, -bottomSheetHeight - 20)}
		)
		sheetTween:Play()
		
		-- Animate arrow rotation
		local arrowTween = TweenService:Create(arrow, 
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{Rotation = 180}
		)
		arrowTween:Play()
	end
	
	local function hideBottomSheet()
		-- Animate overlay fade out
		local overlayTween = TweenService:Create(bottomSheetOverlay, 
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{BackgroundTransparency = 1}
		)
		
		-- Animate bottom sheet slide down to bottom of window
		local sheetTween = TweenService:Create(bottomSheet, 
			TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
			{Position = UDim2.new(0, 20, 1, 20)}
		)
		
		-- Animate arrow rotation back
		local arrowTween = TweenService:Create(arrow, 
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
			{Rotation = 0}
		)
		arrowTween:Play()
		
		sheetTween:Play()
		overlayTween:Play()
		
		overlayTween.Completed:Connect(function()
			bottomSheetOverlay.Visible = false
		end)
	end
	
	-- Create options
	function refreshOptions()
		for _, child in pairs(optionsContainer:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("UIListLayout") then
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
		end
		
		-- Update canvas size for scrolling (smaller option height)
		local totalHeight = #options * 35
		optionsContainer.Size = UDim2.new(1, 0, 0, totalHeight)
		optionsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
		
		-- Update bottom sheet height based on current options count
		local newBottomSheetHeight = math.min(#options * 35 + 90, bottomSheetMaxHeight)
		if newBottomSheetHeight ~= bottomSheetHeight then
			bottomSheetHeight = newBottomSheetHeight
			bottomSheet.Size = UDim2.new(1, -40, 0, bottomSheetHeight)
		end
		
		for i, option in ipairs(options) do
			-- Modern option button (smaller)
			local optionButton = Instance.new("TextButton")
			optionButton.Size = UDim2.new(1, 0, 0, 35)
			optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 35)
			optionButton.BackgroundColor3 = Colors.Surface.Default
			optionButton.BackgroundTransparency = 0
			optionButton.BorderSizePixel = 0
			optionButton.Text = ""
			optionButton.ZIndex = 103
			optionButton.Parent = optionsContainer
			
			-- Option text (smaller)
			local optionText = Instance.new("TextLabel")
			optionText.Size = UDim2.new(1, -48, 1, 0)
			optionText.Position = UDim2.new(0, 16, 0, 0)
			optionText.BackgroundTransparency = 1
			optionText.Text = option.text
			optionText.TextColor3 = Colors.Text.Primary
			optionText.TextXAlignment = Enum.TextXAlignment.Left
			optionText.TextYAlignment = Enum.TextYAlignment.Center
			optionText.Font = Enum.Font.Gotham
			optionText.TextSize = 13
			optionText.ZIndex = 104
			optionText.Parent = optionButton
			
			-- Modern checkmark/selection indicator (smaller)
			local checkmark = Instance.new("Frame")
			checkmark.Size = UDim2.new(0, 16, 0, 16)
			checkmark.Position = UDim2.new(1, -28, 0.5, -8)
			checkmark.BackgroundColor3 = Colors.Status.Success
			checkmark.BorderSizePixel = 0
			checkmark.Visible = false
			checkmark.ZIndex = 104
			checkmark.Parent = optionButton
			
			local checkCorner = Instance.new("UICorner")
			checkCorner.CornerRadius = UDim.new(0, 8)
			checkCorner.Parent = checkmark
			
			local checkIcon = Instance.new("TextLabel")
			checkIcon.Size = UDim2.new(1, 0, 1, 0)
			checkIcon.BackgroundTransparency = 1
			checkIcon.Text = "✓"
			checkIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
			checkIcon.TextXAlignment = Enum.TextXAlignment.Center
			checkIcon.TextYAlignment = Enum.TextYAlignment.Center
			checkIcon.Font = Enum.Font.GothamBold
			checkIcon.TextSize = 10
			checkIcon.ZIndex = 105
			checkIcon.Parent = checkmark
			
			-- Check if selected
			local isSelected = false
			for _, val in ipairs(selectedValues) do
				if val == option.value then
					isSelected = true
					break
				end
			end
			
			if isSelected then
				checkmark.Visible = true
				optionButton.BackgroundColor3 = Colors.Input.Background
				optionText.TextColor3 = Colors.Status.Success
			end
			
			-- Hover effect
			optionButton.MouseEnter:Connect(function()
				if not isSelected then
					optionButton.BackgroundColor3 = Colors.Input.Background
				end
			end)
			
			optionButton.MouseLeave:Connect(function()
				if not isSelected then
					optionButton.BackgroundColor3 = Colors.Surface.Default
				end
			end)
			
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
					hideBottomSheet()
				end
				
				updateDisplayText()
				
				-- Save to configuration
				if flag then
					local valueToSave = multiSelect and selectedValues or (selectedValues[1] or "")
					settings:SetValue(flag, valueToSave)
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
	
	-- Toggle bottom sheet
	local function toggleBottomSheet()
		isOpen = not isOpen
		if isOpen then
			showBottomSheet()
		else
			hideBottomSheet()
		end
	end
	
	-- Button handlers
	selectButton.MouseButton1Click:Connect(toggleBottomSheet)
	
	-- Overlay click to close
	bottomSheetOverlay.MouseButton1Click:Connect(function()
		if isOpen then
			isOpen = false
			hideBottomSheet()
		end
	end)
	
	-- Search filter
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local searchText = string.lower(searchBox.Text)
		local visibleCount = 0
		
		for _, child in pairs(optionsContainer:GetChildren()) do
			if child:IsA("TextButton") then
				local optionTextLabel = child:FindFirstChild("TextLabel")
				if optionTextLabel then
					local optionText = string.lower(optionTextLabel.Text)
					local isVisible = searchText == "" or string.find(optionText, searchText, 1, true) ~= nil
					child.Visible = isVisible
					if isVisible then
						visibleCount = visibleCount + 1
					end
				end
			end
		end
		
		-- Update scroll canvas size based on visible items
		local visibleHeight = visibleCount * 50
		optionsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, visibleHeight)
	end)
	
	-- Initial setup
	refreshOptions()
	updateDisplayText()
	
	-- SelectBox API
	local selectBoxAPI = {
		SelectBox = selectContainer
	}
	
	function selectBoxAPI:GetSelected()
		return selectedValues
	end
	
	function selectBoxAPI:SetSelected(values)
		selectedValues = type(values) == "table" and values or (values ~= "" and {values} or {})
		refreshOptions()
		updateDisplayText()
	end
	
	function selectBoxAPI:Clear()
		selectedValues = {}
		refreshOptions()
		updateDisplayText()
	end
	
	function selectBoxAPI:Refresh(newOptions)
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
	end
	
	function selectBoxAPI:Set(values)
		selectedValues = type(values) == "table" and values or (values ~= "" and {values} or {})
		updateDisplayText()
	end
	
	function selectBoxAPI:Cleanup()
		if bottomSheetOverlay then
			bottomSheetOverlay:Destroy()
		end
		if selectContainer then
			selectContainer:Destroy()
		end
	end
	
	-- Register component
	if registerComponent then
		registerComponent(flag, selectBoxAPI)
	end
	
	-- Execute OnInit callback after component is fully created
	if onInit and type(onInit) == "function" then
		-- Preserve selected values before calling onInit
		local preservedSelectedValues = selectedValues
		
		-- Call OnInit with selectBoxAPI and options update function
		onInit(selectBoxAPI, {
			currentOptions = options,
			updateOptions = function(newOptions)
				-- Callback function to update options on initialization
				if newOptions and type(newOptions) == "table" then
					-- Update options with new data
					rawOptions = newOptions
					options = {}
					for i, option in ipairs(rawOptions) do
						if type(option) == "string" then
							table.insert(options, {text = option, value = option})
						elseif type(option) == "table" and option.text and option.value then
							table.insert(options, option)
						end
					end
					
					-- Restore selected values after options update
					selectedValues = preservedSelectedValues
					
					-- Refresh the options display
					refreshOptions()
					-- Update display text after refreshing options
					updateDisplayText()
				end
			end
		})
	end
	
	return selectBoxAPI
end

return SelectBox
