--[[
	Tab Component
	EzUI Library - Modular Component
	
	Creates a tab with icon, title, and content
]]
-- Component modules (will be loaded by Window)

local Tab = {}

local Colors
local Button
local Toggle
local TextBox
local NumberBox
local SelectBox
local Label
local Separator
local Accordion

-- Initialize component modules
function Tab:Init(_colors, _accordion, _button, _toggle, _textbox, _numberbox, _selectbox, _label, _separator)
	Colors = _colors
	Accordion = _accordion
	Button = _button
	Toggle = _toggle
	TextBox = _textbox
	NumberBox = _numberbox
	SelectBox = _selectbox
	Label = _label
	Separator = _separator
end

function Tab:Create(config)
	local tabName = config.Name or config.Title or "New Tab"
	local tabIcon = config.Icon or nil
	local tabVisible = config.Visible ~= nil and config.Visible or true
	local tabCallback = config.Callback or nil
	local tabScrollFrame = config.TabScrollFrame
	local tabContents = config.TabContents
	local scrollFrame = config.ScrollFrame
	
	-- Tab button (container)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1, -6, 0, 32)
	tabBtn.BackgroundColor3 = Colors.Tab.Background
	tabBtn.Text = ""
	tabBtn.BorderSizePixel = 0
	tabBtn.ZIndex = 4
	tabBtn.Visible = tabVisible
	tabBtn.Parent = tabScrollFrame
	
	-- Icon label (left aligned)
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 30, 1, 0)
	iconLabel.Position = UDim2.new(0, 5, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = tabIcon or ""
	iconLabel.TextColor3 = Colors.Tab.Text
	iconLabel.Font = Enum.Font.SourceSansBold
	iconLabel.TextSize = 15
	iconLabel.TextXAlignment = Enum.TextXAlignment.Left
	iconLabel.ZIndex = 5
	iconLabel.Parent = tabBtn
	
	-- Title label (alignment depends on icon presence)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = tabName
	titleLabel.TextColor3 = Colors.Tab.Text
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 15
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.ZIndex = 5
	titleLabel.Parent = tabBtn
	
	-- Function to update title alignment based on icon presence
	local function updateTitleAlignment()
		if tabIcon and tabIcon ~= "" then
			titleLabel.Size = UDim2.new(1, -40, 1, 0)
			titleLabel.Position = UDim2.new(0, 35, 0, 0)
			titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			iconLabel.Visible = true
		else
			titleLabel.Size = UDim2.new(1, -10, 1, 0)
			titleLabel.Position = UDim2.new(0, 5, 0, 0)
			titleLabel.TextXAlignment = Enum.TextXAlignment.Center
			iconLabel.Visible = false
		end
	end
	
	-- Initial alignment setup
	updateTitleAlignment()

	-- Tab content frame
	local tabContent = Instance.new("Frame")
	tabContent.Size = UDim2.new(1, 0, 1, 0)
	tabContent.Position = UDim2.new(0, 0, 0, 0)
	tabContent.BackgroundTransparency = 1
	tabContent.Visible = false
	tabContent.ClipsDescendants = false
	tabContent.ZIndex = 2
	tabContent.Parent = scrollFrame
	tabContents[tabName] = tabContent

	-- Track current Y position for components
	local currentY = 0

	-- Tab API
	local tabAPI = {
		Button = tabBtn,
		Content = tabContent,
		Name = tabName,
		SetIcon = function(newIcon)
			tabIcon = newIcon
			iconLabel.Text = newIcon or ""
			updateTitleAlignment()
		end,
		SetTitle = function(newTitle)
			tabName = newTitle
			titleLabel.Text = newTitle
		end,
		SetVisible = function(visible)
			tabBtn.Visible = visible
		end,
		Show = function()
			tabContent.Visible = true
		end,
		Hide = function()
			tabContent.Visible = false
		end,
		IsVisible = function()
			return tabContent.Visible
		end,
		
		-- Add Button Component
		AddButton = function(buttonConfig)
			if not Button then
				warn("Tab.AddButton: Button module not initialized")
				return nil
			end
			
			local btnConfig = type(buttonConfig) == "string" and {Text = buttonConfig} or buttonConfig or {}
			btnConfig.Parent = tabContent
			btnConfig.Y = currentY
			btnConfig.EzUI = config.EzUI
			btnConfig.SaveConfiguration = config.SaveConfiguration
			btnConfig.RegisterComponent = config.RegisterComponent
			
			local buttonAPI = Button:Create(btnConfig)
			currentY = currentY + 35
			
			return buttonAPI
		end,
		
		-- Add Toggle Component
		AddToggle = function(toggleConfig)
			if not Toggle then
				warn("Tab.AddToggle: Toggle module not initialized")
				return nil
			end
			
			toggleConfig = toggleConfig or {}
			toggleConfig.Parent = tabContent
			toggleConfig.Y = currentY
			toggleConfig.EzUI = config.EzUI
			toggleConfig.SaveConfiguration = config.SaveConfiguration
			toggleConfig.RegisterComponent = config.RegisterComponent
			toggleConfig.EzUIConfig = config.EzUIConfig
			
			local toggleAPI = Toggle:Create(toggleConfig)
			currentY = currentY + 35
			
			return toggleAPI
		end,
		
		-- Add TextBox Component
		AddTextBox = function(textboxConfig)
			if not TextBox then
				warn("Tab.AddTextBox: TextBox module not initialized")
				return nil
			end
			
			textboxConfig = textboxConfig or {}
			textboxConfig.Parent = tabContent
			textboxConfig.Y = currentY
			textboxConfig.EzUI = config.EzUI
			textboxConfig.SaveConfiguration = config.SaveConfiguration
			textboxConfig.RegisterComponent = config.RegisterComponent
			textboxConfig.EzUIConfig = config.EzUIConfig
			
			local textboxAPI = TextBox:Create(textboxConfig)
			currentY = currentY + 35
			
			return textboxAPI
		end,
		
		-- Add NumberBox Component
		AddNumberBox = function(numberboxConfig)
			if not NumberBox then
				warn("Tab.AddNumberBox: NumberBox module not initialized")
				return nil
			end
			
			numberboxConfig = numberboxConfig or {}
			numberboxConfig.Parent = tabContent
			numberboxConfig.Y = currentY
			numberboxConfig.EzUI = config.EzUI
			numberboxConfig.SaveConfiguration = config.SaveConfiguration
			numberboxConfig.RegisterComponent = config.RegisterComponent
			numberboxConfig.EzUIConfig = config.EzUIConfig
			
			local numberboxAPI = NumberBox:Create(numberboxConfig)
			currentY = currentY + 35
			
			return numberboxAPI
		end,
		
		-- Add SelectBox Component
		AddSelectBox = function(selectboxConfig)
			if not SelectBox then
				warn("Tab.AddSelectBox: SelectBox module not initialized")
				return nil
			end
			
			selectboxConfig = selectboxConfig or {}
			selectboxConfig.Parent = tabContent
			selectboxConfig.Y = currentY
			selectboxConfig.ScreenGui = config.ScreenGui
			selectboxConfig.EzUI = config.EzUI
			selectboxConfig.SaveConfiguration = config.SaveConfiguration
			selectboxConfig.RegisterComponent = config.RegisterComponent
			selectboxConfig.EzUIConfig = config.EzUIConfig
			
			local selectboxAPI = SelectBox:Create(selectboxConfig)
			currentY = currentY + 30
			
			return selectboxAPI
		end,
		
		-- Add Label Component
		AddLabel = function(labelConfig)
			if not Label then
				warn("Tab.AddLabel: Label module not initialized")
				return nil
			end
			
			local lblConfig = type(labelConfig) == "string" and {Text = labelConfig} or labelConfig or {}
			lblConfig.Parent = tabContent
			lblConfig.Y = currentY
			
			local labelAPI = Label:Create(lblConfig)
			currentY = currentY + 25
			
			return labelAPI
		end,
		
		-- Add Separator Component
		AddSeparator = function(separatorConfig)
			if not Separator then
				warn("Tab.AddSeparator: Separator module not initialized")
				return nil
			end
			
			separatorConfig = separatorConfig or {}
			separatorConfig.Parent = tabContent
			separatorConfig.Y = currentY
			
			local separatorAPI = Separator:Create(separatorConfig)
			currentY = currentY + 15
			
			return separatorAPI
		end,
		
		-- Add Accordion Component
		AddAccordion = function(accordionConfig)
			if not Accordion then
				warn("Tab.AddAccordion: Accordion module not initialized")
				return nil
			end
			
			accordionConfig = accordionConfig or {}
			accordionConfig.Parent = tabContent
			accordionConfig.Y = currentY
			accordionConfig.ScreenGui = config.ScreenGui
			accordionConfig.EzUI = config.EzUI
			accordionConfig.SaveConfiguration = config.SaveConfiguration
			accordionConfig.RegisterComponent = config.RegisterComponent
			accordionConfig.EzUIConfig = config.EzUIConfig
			
			local accordionAPI = Accordion:Create(accordionConfig)
			currentY = currentY + 35
			
			return accordionAPI
		end
	}
	
	return tabAPI
end

return Tab
