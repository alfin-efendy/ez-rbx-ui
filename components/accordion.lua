--[[
	Accordion Component
	EzUI Library - Modular Component
	
	Creates a collapsible accordion with dynamic content
	Uses proven logic from old ui.lua for reliable expand/collapse behavior
]]

-- Component modules (will be loaded by Window)
local Accordion = {}

local Colors
local Button
local Toggle
local TextBox
local NumberBox
local SelectBox
local Label
local Separator

-- Initialize component modules
function Accordion:Init(_colors, _button, _toggle, _textbox, _numberbox, _selectbox, _label, _separator)
	Colors = _colors
	Button = _button
	Toggle = _toggle
	TextBox = _textbox
	NumberBox = _numberbox
	SelectBox = _selectbox
	Label = _label
	Separator = _separator
end

function Accordion:Create(config)
	-- Configuration
	local title = config.Title or config.Name or "Accordion"
	local expanded = config.Expanded or config.Open or config.DefaultExpanded or false
	local icon = config.Icon or ""
	local tabContent = config.Parent
	local accordionStartY = config.Y or 0
	
	-- Accordion state
	local isExpanded = expanded
	local accordionContentHeight = 0
	
	-- Main accordion container
	local accordionContainer = Instance.new("Frame")
	accordionContainer.Size = UDim2.new(1, -20, 0, 30) -- Initial height just for header
	accordionContainer.Position = UDim2.new(0, 10, 0, accordionStartY)
	accordionContainer.BackgroundTransparency = 1
	accordionContainer.ClipsDescendants = false -- Allow content to show
	accordionContainer.ZIndex = 3
	accordionContainer.Parent = tabContent

	-- Store reference to this accordion
	accordionContainer:SetAttribute("AccordionStartY", accordionStartY)
	accordionContainer:SetAttribute("IsAccordion", true)
	
	-- Accordion header (clickable)
	local accordionHeader = Instance.new("TextButton")
	accordionHeader.Size = UDim2.new(1, 0, 0, 30)
	accordionHeader.Position = UDim2.new(0, 0, 0, 0)
	accordionHeader.BackgroundColor3 = Colors.Surface.Default
	accordionHeader.BorderSizePixel = 0
	accordionHeader.Text = ""
	accordionHeader.ZIndex = 4
	accordionHeader.Parent = accordionContainer
	
	-- Header round corners
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 4)
	headerCorner.Parent = accordionHeader
			
	-- Expand/Collapse arrow
	local accordionArrow = Instance.new("TextLabel")
	accordionArrow.Size = UDim2.new(0, 30, 1, 0)
	accordionArrow.Position = UDim2.new(0, 5, 0, 0)
	accordionArrow.BackgroundTransparency = 1
	accordionArrow.Text = isExpanded and "▼" or "►"
	accordionArrow.TextColor3 = Colors.Text.Secondary
	accordionArrow.TextSize = 12
	accordionArrow.Font = Enum.Font.SourceSansBold
	accordionArrow.ZIndex = 5
	accordionArrow.Parent = accordionHeader
	
	-- Icon (optional)
	local accordionIcon = Instance.new("TextLabel")
	accordionIcon.Size = UDim2.new(0, 25, 1, 0)
	accordionIcon.Position = UDim2.new(0, 30, 0, 0)
	accordionIcon.BackgroundTransparency = 1
	accordionIcon.Text = icon
	accordionIcon.TextColor3 = Colors.Text.Primary
	accordionIcon.TextXAlignment = Enum.TextXAlignment.Center
	accordionIcon.Font = Enum.Font.SourceSans
	accordionIcon.TextSize = 14
	accordionIcon.ZIndex = 5
	accordionIcon.Parent = accordionHeader
	
	-- Accordion title
	local accordionTitle = Instance.new("TextLabel")
	accordionTitle.Size = UDim2.new(1, -70, 1, 0)
	accordionTitle.Position = UDim2.new(0, 60, 0, 0)
	accordionTitle.BackgroundTransparency = 1
	accordionTitle.Text = title
	accordionTitle.TextColor3 = Colors.Text.Primary
	accordionTitle.TextXAlignment = Enum.TextXAlignment.Left
	accordionTitle.Font = Enum.Font.SourceSansBold
	accordionTitle.TextSize = 14
	accordionTitle.ZIndex = 5
	accordionTitle.Parent = accordionHeader
	
	-- Accordion content container (no scroll)
	local accordionContent = Instance.new("Frame")
	accordionContent.Size = UDim2.new(1, 0, 0, 0) -- Start with 0 height
	accordionContent.Position = UDim2.new(0, 0, 0, 32) -- Below header
	accordionContent.BackgroundColor3 = Colors.Background.Tertiary
	accordionContent.BorderSizePixel = 0
	accordionContent.Visible = isExpanded
	accordionContent.ClipsDescendants = false -- Don't clip content
	accordionContent.ZIndex = 4
	accordionContent.Parent = accordionContainer
	
	-- Round corners for content
	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 4)
	contentCorner.Parent = accordionContent
	
	-- Add padding to accordion content
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 5)
	contentPadding.PaddingBottom = UDim.new(0, 5)
	contentPadding.PaddingLeft = UDim.new(0, 5)
	contentPadding.PaddingRight = UDim.new(0, 5)
	contentPadding.Parent = accordionContent
	
	-- Content layout
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 5)
	contentLayout.Parent = accordionContent
	
	-- Track layout order for accordion content (UIListLayout handles actual positioning)
	local accordionCurrentY = 1
	
	-- Function to update positions of all components below this accordion (FROM UI.LUA)
	local function updateComponentsBelow()
		-- Get current accordion bottom position
		local accordionBottom = accordionContainer.Position.Y.Offset + accordionContainer.Size.Y.Offset
		
		-- Create a list of all components with their Y positions
		local components = {}
		for _, child in pairs(tabContent:GetChildren()) do
			if child:IsA("GuiObject") and child ~= accordionContainer then
				-- Check if this component has a stored start Y position
				local componentStartY = child:GetAttribute("ComponentStartY")
				if componentStartY and componentStartY > accordionStartY then
					table.insert(components, {
						component = child,
						originalY = componentStartY,
						currentY = child.Position.Y.Offset
					})
				end
			end
		end
		
		-- Sort components by their original Y position
		table.sort(components, function(a, b)
			return a.originalY < b.originalY
		end)
		
		-- Update positions of components that come after this accordion
		local nextY = accordionBottom + 5
		for _, componentData in ipairs(components) do
			componentData.component.Position = UDim2.new(0, 10, 0, nextY)
			-- Add the component's height to calculate next position
			nextY = nextY + componentData.component.Size.Y.Offset + 5
		end
	end
	
	-- Function to recalculate total tab height (FROM UI.LUA)
	local function recalculateTabHeight()
		-- Wait to ensure all size updates are rendered
		task.wait()
		
		-- Callback to parent tab to recalculate
		if config.OnHeightChanged then
			config.OnHeightChanged()
		end
	end
	
	-- Function to update accordion container size (FROM UI.LUA)
	local function updateAccordionSize()
		-- Get the actual content size from UIListLayout
		local actualContentHeight = contentLayout.AbsoluteContentSize.Y + 20 -- Add padding
		accordionContentHeight = actualContentHeight
		
		-- Update accordion container size
		local totalHeight = 35 + (isExpanded and accordionContentHeight or 0)
		accordionContainer.Size = UDim2.new(1, -20, 0, totalHeight)
		
		-- Update accordion content frame size
		if isExpanded then
			accordionContent.Size = UDim2.new(1, 0, 0, accordionContentHeight)
		end
		
		-- Update positions of components below
		updateComponentsBelow()
		
		-- Recalculate total tab height
		recalculateTabHeight()
	end
	
	-- Auto-update accordion size when content layout changes (now that updateAccordionSize is defined)
	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		-- Always update the content height, regardless of expanded state
		updateAccordionSize()
	end)
	
	-- Animation function for smooth expand/collapse (FROM UI.LUA)
	local function animateAccordion()
		local TweenService = game:GetService("TweenService")
		
		-- Calculate sizes BEFORE any changes
		local oldContainerHeight = accordionContainer.Size.Y.Offset
		local targetContentHeight = isExpanded and accordionContentHeight or 0
		local targetContainerHeight = 35 + targetContentHeight
		local heightDifference = targetContainerHeight - oldContainerHeight
					
		-- Store components that come after this accordion BEFORE size changes
		local componentsBelow = {}
		local accordionBottom = accordionContainer.Position.Y.Offset + oldContainerHeight
		
		for _, child in pairs(tabContent:GetChildren()) do
			if child:IsA("GuiObject") and child ~= accordionContainer then
				local childY = child.Position.Y.Offset
				if childY > accordionBottom then
					table.insert(componentsBelow, {
						component = child,
						currentY = childY,
						targetY = childY + heightDifference
					})
				end
			end
		end
		
		-- Update arrow direction
		accordionArrow.Text = isExpanded and "▼" or "►"
		
		-- Show content immediately if expanding
		if isExpanded then
			accordionContent.Visible = true
		end
		
		-- Animate container size
		local containerTween = TweenService:Create(
			accordionContainer,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, -20, 0, targetContainerHeight)}
		)
		
		-- Animate content size
		local contentTween = TweenService:Create(
			accordionContent,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, 0, 0, targetContentHeight)}
		)
		
		-- Animate components below
		for _, componentData in ipairs(componentsBelow) do
			local componentTween = TweenService:Create(
				componentData.component,
				TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{Position = UDim2.new(0, 10, 0, componentData.targetY)}
			)
			componentTween:Play()
		end
		
		containerTween:Play()
		contentTween:Play()
		
		-- Handle animation completion
		containerTween.Completed:Connect(function()
			-- Hide content after collapse animation
			if not isExpanded then
				accordionContent.Visible = false
			end
			
			-- Wait for next frame to ensure sizes are updated
			task.wait()
			
			-- Recalculate total tab height
			recalculateTabHeight()
		end)
	end
	
	-- Header click handler
	accordionHeader.MouseButton1Click:Connect(function()
		isExpanded = not isExpanded
		animateAccordion()
	end)
	
	-- Header hover effects
	accordionHeader.MouseEnter:Connect(function()
		accordionHeader.BackgroundColor3 = Colors.Surface.Hover
	end)
	
	accordionHeader.MouseLeave:Connect(function()
		accordionHeader.BackgroundColor3 = Colors.Surface.Default
	end)
	
	-- Create accordion API
	local accordionAPI = {
		Container = accordionContainer,
		ContentFrame = accordionContent,
	}
	
	-- Create accordion API
	local accordionAPI = {
		Container = accordionContainer,
		ContentFrame = accordionContent,
	}
	
	-- Accordion control methods
	function accordionAPI:Expand()
		if not isExpanded then
			isExpanded = true
			animateAccordion()
		end
	end
	
	function accordionAPI:Collapse()
		if isExpanded then
			isExpanded = false
			animateAccordion()
		end
	end
	
	function accordionAPI:Toggle()
		isExpanded = not isExpanded
		animateAccordion()
		return isExpanded
	end
	
	function accordionAPI:IsExpanded()
		return isExpanded
	end
	
	function accordionAPI:SetTitle(newTitle)
		title = newTitle
		accordionTitle.Text = newTitle
	end
	
	function accordionAPI:SetIcon(newIcon)
		icon = newIcon
		accordionIcon.Text = newIcon
	end
	
	function accordionAPI:GetHeight()
		return accordionContainer.AbsoluteSize.Y
	end
	
	function accordionAPI:GetContentHeight()
		return accordionContentHeight
	end
	
	-- Add Label method
	function accordionAPI:AddLabel(labelConfig)
		if not Label then return nil end
		
		local lblConfig
		if type(labelConfig) == "string" then
			lblConfig = {Text = labelConfig}
		elseif type(labelConfig) == "function" then
			lblConfig = {Text = labelConfig}
		elseif type(labelConfig) == "table" then
			lblConfig = labelConfig
		else
			lblConfig = {}
		end
		
		lblConfig.Parent = accordionContent
		lblConfig.Y = 0
		lblConfig.IsForAccordion = true
		-- Size and Color are already passed through if they exist in labelConfig table
		
		local labelAPI = Label:Create(lblConfig)
		if labelAPI and labelAPI.Label then
			-- UIListLayout will handle positioning automatically
			labelAPI.Label.LayoutOrder = accordionCurrentY
			accordionCurrentY = accordionCurrentY + 1 -- Just increment counter for LayoutOrder
		end
		
		-- Update accordion size (the connection should handle this automatically)
		updateAccordionSize()
		
		if isExpanded then
			animateAccordion()
		end
		
		return labelAPI
	end
	
	-- Add Button method
	function accordionAPI:AddButton(buttonConfig)
		if not Button then return nil end
		
		local btnConfig
		if type(buttonConfig) == "string" then
			btnConfig = {Text = buttonConfig}
		elseif type(buttonConfig) == "table" then
			btnConfig = buttonConfig
		else
			btnConfig = {}
		end
		
		btnConfig.Parent = accordionContent
		btnConfig.Y = 0
		btnConfig.IsForAccordion = true
		btnConfig.EzUI = config.EzUI
		btnConfig.SaveConfiguration = config.SaveConfiguration
		btnConfig.RegisterComponent = config.RegisterComponent
		
		local buttonAPI = Button:Create(btnConfig)
		if buttonAPI and buttonAPI.Button then
			buttonAPI.Button.LayoutOrder = accordionCurrentY
			accordionCurrentY = accordionCurrentY + 1 -- UIListLayout handles positioning
		end
		updateAccordionSize()
		
		if isExpanded then
			animateAccordion()
		end
		
		return buttonAPI
	end
	
	-- Add Toggle method
	function accordionAPI:AddToggle(toggleConfig)
		if not Toggle then return nil end
		
		toggleConfig = toggleConfig or {}
		toggleConfig.Parent = accordionContent
		toggleConfig.Y = 0
		toggleConfig.IsForAccordion = true
		toggleConfig.EzUI = config.EzUI
		toggleConfig.SaveConfiguration = config.SaveConfiguration
		toggleConfig.RegisterComponent = config.RegisterComponent
		toggleConfig.Settings= config.Settings
		
		local toggleAPI = Toggle:Create(toggleConfig)
		if toggleAPI and toggleAPI.Toggle then
			toggleAPI.Toggle.LayoutOrder = accordionCurrentY
			accordionCurrentY = accordionCurrentY + 1 -- UIListLayout handles positioning
		end
		updateAccordionSize()
		
		if isExpanded then
			animateAccordion()
		end
		
		return toggleAPI
	end
	
	-- Add TextBox method
	function accordionAPI:AddTextBox(textboxConfig)
		if not TextBox then return nil end
		
		textboxConfig = textboxConfig or {}
		textboxConfig.Parent = accordionContent
		textboxConfig.Y = 0
		textboxConfig.IsForAccordion = true
		textboxConfig.EzUI = config.EzUI
		textboxConfig.SaveConfiguration = config.SaveConfiguration
		textboxConfig.RegisterComponent = config.RegisterComponent
		textboxConfig.Settings= config.Settings
		
		local textboxAPI = TextBox:Create(textboxConfig)
		if textboxAPI and textboxAPI.TextBox then
			textboxAPI.TextBox.LayoutOrder = accordionCurrentY
			accordionCurrentY = accordionCurrentY + 1 -- UIListLayout handles positioning
		end
		updateAccordionSize()
		
		if isExpanded then
			animateAccordion()
		end
		
		return textboxAPI
	end
	
	-- Add NumberBox method
	function accordionAPI:AddNumberBox(numberboxConfig)
		if not NumberBox then return nil end
		
		numberboxConfig = numberboxConfig or {}
		numberboxConfig.Parent = accordionContent
		numberboxConfig.Y = 0
		numberboxConfig.IsForAccordion = true
		numberboxConfig.EzUI = config.EzUI
		numberboxConfig.SaveConfiguration = config.SaveConfiguration
		numberboxConfig.RegisterComponent = config.RegisterComponent
		numberboxConfig.Settings= config.Settings
		
		local numberboxAPI = NumberBox:Create(numberboxConfig)
		if numberboxAPI and numberboxAPI.NumberBox then
			numberboxAPI.NumberBox.LayoutOrder = accordionCurrentY
			accordionCurrentY = accordionCurrentY + 1 -- UIListLayout handles positioning
		end
		updateAccordionSize()
		
		if isExpanded then
			animateAccordion()
		end
		
		return numberboxAPI
	end
	
	-- Add SelectBox method
	function accordionAPI:AddSelectBox(selectboxConfig)
		if not SelectBox then return nil end
		
		selectboxConfig = selectboxConfig or {}
		selectboxConfig.Parent = accordionContent
		selectboxConfig.Y = 0
		selectboxConfig.IsForAccordion = true
		selectboxConfig.ScreenGui = config.ScreenGui
		selectboxConfig.EzUI = config.EzUI
		selectboxConfig.SaveConfiguration = config.SaveConfiguration
		selectboxConfig.RegisterComponent = config.RegisterComponent
		selectboxConfig.Settings= config.Settings
		
		local selectboxAPI = SelectBox:Create(selectboxConfig)
		if selectboxAPI and selectboxAPI.SelectBox then
			selectboxAPI.SelectBox.LayoutOrder = accordionCurrentY
			accordionCurrentY = accordionCurrentY + 1 -- UIListLayout handles positioning
		end
		updateAccordionSize()
		
		if isExpanded then
			animateAccordion()
		end
		
		return selectboxAPI
	end
	
	-- Add Separator method
	function accordionAPI:AddSeparator(separatorConfig)
		if not Separator then return nil end
		
		separatorConfig = separatorConfig or {}
		separatorConfig.Parent = accordionContent
		separatorConfig.Y = 0
		separatorConfig.IsForAccordion = true
		
		local separatorAPI = Separator:Create(separatorConfig)
		if separatorAPI and separatorAPI.Separator then
			separatorAPI.Separator.LayoutOrder = accordionCurrentY
			accordionCurrentY = accordionCurrentY + 1 -- UIListLayout handles positioning
		end
		updateAccordionSize()
		
		if isExpanded then
			animateAccordion()
		end
		
		return separatorAPI
	end
	
	-- Initialize with expanded state
	if isExpanded then
		updateAccordionSize()
		-- Don't animate on initial load, just set the size directly
		accordionContainer.Size = UDim2.new(1, -20, 0, 35 + accordionContentHeight)
		accordionContent.Size = UDim2.new(1, 0, 0, accordionContentHeight)
		accordionContent.Visible = true
		accordionArrow.Text = "▼"
	end
	
	return accordionAPI
end

return Accordion
