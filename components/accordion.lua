--[[
	Accordion Component
	EzUI Library - Modular Component
	
	Creates a collapsible accordion with dynamic content
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
	local title = config.Title or "Accordion"
	local defaultExpanded = config.DefaultExpanded or false
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local onToggle = config.OnToggle or function() end
	
	-- Accordion state
	local isExpanded = defaultExpanded
	local accordionHeight = 30
	local contentHeight = 0
	local components = {}
	
	-- Main accordion container
	local accordionContainer = Instance.new("Frame")
	accordionContainer.Size = UDim2.new(1, -20, 0, accordionHeight)
	accordionContainer.Position = UDim2.new(0, 10, 0, currentY)
	accordionContainer.BackgroundColor3 = Colors.Background.Tertiary
	accordionContainer.BorderSizePixel = 0
	accordionContainer.ClipsDescendants = false
	accordionContainer.ZIndex = 3
	accordionContainer.Parent = parentContainer
	
	-- Round corners
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 4)
	containerCorner.Parent = accordionContainer
	
	-- Header (clickable)
	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundColor3 = Colors.Surface.Default
	header.BorderSizePixel = 0
	header.Text = ""
	header.ZIndex = 4
	header.Parent = accordionContainer
	
	-- Header round corners
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 4)
	headerCorner.Parent = header
	
	-- Arrow indicator
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(0, 5, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = isExpanded and "▼" or "►"
	arrow.TextColor3 = Colors.Text.Secondary
	arrow.TextSize = 12
	arrow.Font = Enum.Font.SourceSansBold
	arrow.ZIndex = 5
	arrow.Parent = header
	
	-- Title label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -30, 1, 0)
	titleLabel.Position = UDim2.new(0, 25, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Colors.Text.Primary
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 5
	titleLabel.Parent = header
	
	-- Content container with padding
	local contentContainer = Instance.new("Frame")
	contentContainer.Size = UDim2.new(1, -10, 1, -35)
	contentContainer.Position = UDim2.new(0, 5, 0, 32)
	contentContainer.BackgroundTransparency = 1
	contentContainer.ClipsDescendants = false
	contentContainer.Visible = isExpanded
	contentContainer.ZIndex = 4
	contentContainer.Parent = accordionContainer
	
	-- Content scroll frame
	local contentScrollFrame = Instance.new("ScrollingFrame")
	contentScrollFrame.Size = UDim2.new(1, 0, 1, 0)
	contentScrollFrame.Position = UDim2.new(0, 0, 0, 0)
	contentScrollFrame.BackgroundTransparency = 1
	contentScrollFrame.BorderSizePixel = 0
	contentScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScrollFrame.ScrollBarThickness = 6
	contentScrollFrame.ScrollBarImageColor3 = Colors.Scrollbar.Thumb
	contentScrollFrame.ClipsDescendants = false
	contentScrollFrame.ZIndex = 4
	contentScrollFrame.Parent = contentContainer
	
	-- Function to update accordion size
	local function updateSize()
		local targetHeight = isExpanded and (contentHeight + 35) or 30
		
		-- Animate size change
		local tween = game:GetService("TweenService"):Create(
			accordionContainer,
			TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, -20, 0, targetHeight)}
		)
		tween:Play()
		
		-- Update canvas size
		contentScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
	end
	
	-- Function to animate content visibility
	local function animateContent()
		contentContainer.Visible = isExpanded
		
		if isExpanded then
			-- Fade in
			for _, child in pairs(contentScrollFrame:GetChildren()) do
				if child:IsA("GuiObject") then
					child.Visible = true
				end
			end
		end
	end
	
	-- Toggle function
	local function toggle()
		isExpanded = not isExpanded
		arrow.Text = isExpanded and "▼" or "►"
		
		animateContent()
		updateSize()
		
		-- Call callback
		local success, err = pcall(function()
			onToggle(isExpanded)
		end)
		
		if not success then
			warn("Accordion toggle callback error:", err)
		end
	end
	
	-- Header click handler
	header.MouseButton1Click:Connect(toggle)
	
	-- Hover effect
	header.MouseEnter:Connect(function()
		header.BackgroundColor3 = Colors.Surface.Hover
	end)
	
	header.MouseLeave:Connect(function()
		header.BackgroundColor3 = Colors.Surface.Default
	end)
	
	-- Initial state
	if isExpanded then
		animateContent()
	end
	
	-- Track current Y position for components inside accordion
	local componentY = 0
	
	-- Accordion API
	local accordionAPI = {
		Container = accordionContainer,
		ContentFrame = contentScrollFrame,
		IsExpanded = function()
			return isExpanded
		end,
		Expand = function()
			if not isExpanded then
				toggle()
			end
		end,
		Collapse = function()
			if isExpanded then
				toggle()
			end
		end,
		Toggle = toggle,
		SetTitle = function(newTitle)
			title = newTitle
			titleLabel.Text = newTitle
		end,
		GetContentHeight = function()
			return contentHeight
		end,
		SetContentHeight = function(height)
			contentHeight = height
			updateSize()
		end,
		UpdateSize = updateSize,
		AddComponent = function(component)
			table.insert(components, component)
		end,
		GetComponents = function()
			return components
		end,
		
		-- Add Button Component to Accordion
		AddButton = function(buttonConfig)
			if not Button then
				warn("Accordion.AddButton: Button module not initialized")
				return nil
			end
			
			local btnConfig = type(buttonConfig) == "string" and {Text = buttonConfig} or buttonConfig or {}
			btnConfig.Parent = contentScrollFrame
			btnConfig.Y = componentY
			btnConfig.IsForAccordion = true
			btnConfig.EzUI = config.EzUI
			btnConfig.SaveConfiguration = config.SaveConfiguration
			btnConfig.RegisterComponent = config.RegisterComponent
			
			local buttonAPI = Button:Create(btnConfig)
			componentY = componentY + 30
			contentHeight = componentY
			updateSize()
			
			table.insert(components, buttonAPI)
			return buttonAPI
		end,
		
		-- Add Toggle Component to Accordion
		AddToggle = function(toggleConfig)
			if not Toggle then
				warn("Accordion.AddToggle: Toggle module not initialized")
				return nil
			end
			
			toggleConfig = toggleConfig or {}
			toggleConfig.Parent = contentScrollFrame
			toggleConfig.Y = componentY
			toggleConfig.IsForAccordion = true
			toggleConfig.EzUI = config.EzUI
			toggleConfig.SaveConfiguration = config.SaveConfiguration
			toggleConfig.RegisterComponent = config.RegisterComponent
			toggleConfig.EzUIConfig = config.EzUIConfig
			
			local toggleAPI = Toggle:Create(toggleConfig)
			componentY = componentY + 30
			contentHeight = componentY
			updateSize()
			
			table.insert(components, toggleAPI)
			return toggleAPI
		end,
		
		-- Add TextBox Component to Accordion
		AddTextBox = function(textboxConfig)
			if not TextBox then
				warn("Accordion.AddTextBox: TextBox module not initialized")
				return nil
			end
			
			textboxConfig = textboxConfig or {}
			textboxConfig.Parent = contentScrollFrame
			textboxConfig.Y = componentY
			textboxConfig.IsForAccordion = true
			textboxConfig.EzUI = config.EzUI
			textboxConfig.SaveConfiguration = config.SaveConfiguration
			textboxConfig.RegisterComponent = config.RegisterComponent
			textboxConfig.EzUIConfig = config.EzUIConfig
			
			local textboxAPI = TextBox:Create(textboxConfig)
			componentY = componentY + 30
			contentHeight = componentY
			updateSize()
			
			table.insert(components, textboxAPI)
			return textboxAPI
		end,
		
		-- Add NumberBox Component to Accordion
		AddNumberBox = function(numberboxConfig)
			if not NumberBox then
				warn("Accordion.AddNumberBox: NumberBox module not initialized")
				return nil
			end
			
			numberboxConfig = numberboxConfig or {}
			numberboxConfig.Parent = contentScrollFrame
			numberboxConfig.Y = componentY
			numberboxConfig.IsForAccordion = true
			numberboxConfig.EzUI = config.EzUI
			numberboxConfig.SaveConfiguration = config.SaveConfiguration
			numberboxConfig.RegisterComponent = config.RegisterComponent
			numberboxConfig.EzUIConfig = config.EzUIConfig
			
			local numberboxAPI = NumberBox:Create(numberboxConfig)
			componentY = componentY + 30
			contentHeight = componentY
			updateSize()
			
			table.insert(components, numberboxAPI)
			return numberboxAPI
		end,
		
		-- Add SelectBox Component to Accordion
		AddSelectBox = function(selectboxConfig)
			if not SelectBox then
				warn("Accordion.AddSelectBox: SelectBox module not initialized")
				return nil
			end
			
			selectboxConfig = selectboxConfig or {}
			selectboxConfig.Parent = contentScrollFrame
			selectboxConfig.Y = componentY
			selectboxConfig.IsForAccordion = true
			selectboxConfig.ScreenGui = config.ScreenGui
			selectboxConfig.EzUI = config.EzUI
			selectboxConfig.SaveConfiguration = config.SaveConfiguration
			selectboxConfig.RegisterComponent = config.RegisterComponent
			selectboxConfig.EzUIConfig = config.EzUIConfig
			
			local selectboxAPI = SelectBox:Create(selectboxConfig)
			componentY = componentY + 30
			contentHeight = componentY
			updateSize()
			
			table.insert(components, selectboxAPI)
			return selectboxAPI
		end,
		
		-- Add Label Component to Accordion
		AddLabel = function(labelConfig)
			if not Label then
				warn("Accordion.AddLabel: Label module not initialized")
				return nil
			end
			
			local lblConfig = type(labelConfig) == "string" and {Text = labelConfig} or labelConfig or {}
			lblConfig.Parent = contentScrollFrame
			lblConfig.Y = componentY
			lblConfig.IsForAccordion = true
			
			local labelAPI = Label:Create(lblConfig)
			componentY = componentY + 25
			contentHeight = componentY
			updateSize()
			
			table.insert(components, labelAPI)
			return labelAPI
		end,
		
		-- Add Separator Component to Accordion
		AddSeparator = function(separatorConfig)
			if not Separator then
				warn("Accordion.AddSeparator: Separator module not initialized")
				return nil
			end
			
			separatorConfig = separatorConfig or {}
			separatorConfig.Parent = contentScrollFrame
			separatorConfig.Y = componentY
			separatorConfig.IsForAccordion = true
			
			local separatorAPI = Separator:Create(separatorConfig)
			componentY = componentY + 15
			contentHeight = componentY
			updateSize()
			
			table.insert(components, separatorAPI)
			return separatorAPI
		end
	}
	
	return accordionAPI
end

return Accordion
