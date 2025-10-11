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
	local updateCanvasSize = config.UpdateCanvasSize
	
	-- Create tab content frame for this specific tab
	local tabContent = Instance.new("Frame")
	tabContent.Size = UDim2.new(1, 0, 1, 0)
	tabContent.Position = UDim2.new(0, 0, 0, 0)
	tabContent.BackgroundTransparency = 1
	tabContent.Visible = false
	tabContent.ClipsDescendants = false -- Allow SelectBox dropdowns to show
	tabContent.ZIndex = 2 -- Above scroll frame
	tabContent.Parent = scrollFrame
	
	-- Store tab content in the tabContents table if it exists
	if tabContents then
		tabContents[tabName] = tabContent
	end
	
	-- Tab button (container)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1, -10, 0, 36)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = ""
	tabBtn.BorderSizePixel = 0
	tabBtn.ZIndex = 4
	tabBtn.Visible = tabVisible
	tabBtn.Parent = tabScrollFrame
	
	-- Rounded corners for tab button (only right side)
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 6)
	tabCorner.Parent = tabBtn
	
	-- Active indicator (left border with rounded right side)
	local activeIndicator = Instance.new("Frame")
	activeIndicator.Size = UDim2.new(0, 4, 0, 24)
	activeIndicator.Position = UDim2.new(0, 0, 0.5, -12)
	activeIndicator.BackgroundColor3 = Colors.Accent.Primary
	activeIndicator.BorderSizePixel = 0
	activeIndicator.ZIndex = 6
	activeIndicator.Visible = false
	activeIndicator.Parent = tabBtn
	
	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 4)
	indicatorCorner.Parent = activeIndicator
	
	-- Icon label (left aligned)
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 30, 1, 0)
	iconLabel.Position = UDim2.new(0, 8, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = tabIcon or ""
	iconLabel.TextColor3 = Colors.Tab.TextInactive
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 16
	iconLabel.TextXAlignment = Enum.TextXAlignment.Left
	iconLabel.ZIndex = 5
	iconLabel.Parent = tabBtn
	
	-- Title label (right aligned)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = tabName
	titleLabel.TextColor3 = Colors.Tab.TextInactive
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.ZIndex = 5
	titleLabel.Parent = tabBtn
	
	-- Function to update title alignment based on icon presence
	local function updateTitleAlignment()
		if tabIcon and tabIcon ~= "" then
			-- Icon on left, title on right
			titleLabel.Size = UDim2.new(1, -45, 1, 0)
			titleLabel.Position = UDim2.new(0, 38, 0, 0)
			titleLabel.TextXAlignment = Enum.TextXAlignment.Right
			iconLabel.Visible = true
		else
			-- No icon, title centered
			titleLabel.Size = UDim2.new(1, -16, 1, 0)
			titleLabel.Position = UDim2.new(0, 8, 0, 0)
			titleLabel.TextXAlignment = Enum.TextXAlignment.Center
			iconLabel.Visible = false
		end
	end
	
	-- Initial alignment setup
	updateTitleAlignment()

	-- Track current Y position for components (reduced top spacing)
	local currentY = 5
	
	-- Helper function to update canvas size after adding components
	local function updateTabCanvasSize()
		if updateCanvasSize and tabContent.Visible then
			-- Only update if this tab is currently active
			task.spawn(function()
				task.wait() -- Wait for component to be fully added
				updateCanvasSize()
			end)
		end
	end

	-- Tab API
	local tabAPI = {
		Button = tabBtn,
		Content = tabContent,
		Name = tabName,
	}
	
	function tabAPI:SetIcon(newIcon)
		tabIcon = newIcon
		iconLabel.Text = newIcon or ""
		updateTitleAlignment()
	end
	
	function tabAPI:SetTitle(newTitle)
		tabName = newTitle
		titleLabel.Text = newTitle
	end
	
	function tabAPI:SetVisible(visible)
		tabBtn.Visible = visible
	end
	
	function tabAPI:Show()
		tabContent.Visible = true
	end
	
	function tabAPI:Hide()
		tabContent.Visible = false
	end
	
	function tabAPI:IsVisible()
		return tabContent.Visible
	end
	
	function tabAPI:Select()
		tabContent.Visible = true
		tabBtn.BackgroundTransparency = 0
		tabBtn.BackgroundColor3 = Colors.Tab.BackgroundActive
		activeIndicator.Visible = true
		titleLabel.TextColor3 = Colors.Text.Primary
		iconLabel.TextColor3 = Colors.Text.Primary
		
		-- Update canvas size when tab becomes active
		if updateCanvasSize then
			-- Wait a frame to ensure visibility changes are processed
			task.spawn(function()
				task.wait()
				updateCanvasSize()
			end)
		end
		
		if tabCallback then
			tabCallback()
		end
	end
	
	function tabAPI:Deselect()
		tabContent.Visible = false
		tabBtn.BackgroundTransparency = 1
		activeIndicator.Visible = false
		titleLabel.TextColor3 = Colors.Tab.TextInactive
		iconLabel.TextColor3 = Colors.Tab.TextInactive
	end
	
	-- Hover effects
	tabBtn.MouseEnter:Connect(function()
		if not tabContent.Visible then
			tabBtn.BackgroundTransparency = 0
			tabBtn.BackgroundColor3 = Colors.Tab.BackgroundHover
		end
	end)
	
	tabBtn.MouseLeave:Connect(function()
		if not tabContent.Visible then
			tabBtn.BackgroundTransparency = 1
		else
			tabBtn.BackgroundTransparency = 0
			tabBtn.BackgroundColor3 = Colors.Tab.BackgroundActive
		end
	end)
	
	-- Add Button Component
	function tabAPI:AddButton(buttonConfig)
		if not Button then
			warn("Tab.AddButton: Button module not initialized")
			return nil
		end
		
		local btnConfig
		if type(buttonConfig) == "string" then
			btnConfig = {Text = buttonConfig}
		elseif type(buttonConfig) == "table" then
			btnConfig = buttonConfig
		else
			btnConfig = {}
		end
		
		btnConfig.Parent = tabContent
		btnConfig.Y = currentY
		btnConfig.EzUI = config.EzUI
		btnConfig.SaveConfiguration = config.SaveConfiguration
		btnConfig.RegisterComponent = config.RegisterComponent
		
		local buttonAPI = Button:Create(btnConfig)
		currentY = currentY + 35
		updateTabCanvasSize()
		
		return buttonAPI
	end
	
	-- Add Toggle Component
	function tabAPI:AddToggle(toggleConfig)
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
		toggleConfig.Settings= config.Settings
		
		local toggleAPI = Toggle:Create(toggleConfig)
		currentY = currentY + 35
		updateTabCanvasSize()
		
		return toggleAPI
	end
	
	-- Add TextBox Component
	function tabAPI:AddTextBox(textboxConfig)
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
		textboxConfig.Settings= config.Settings
		
		local textboxAPI = TextBox:Create(textboxConfig)
		
		-- Calculate height based on TextBox configuration
		local hasTitle = (textboxConfig.Name and textboxConfig.Name ~= "") or (textboxConfig.Title and textboxConfig.Title ~= "")
		local multiline = textboxConfig.Multiline or false
		local labelHeight = hasTitle and 18 or 0
		local inputHeight = multiline and 80 or 30
		local spacing = hasTitle and 2 or 0
		local totalHeight = labelHeight + inputHeight + spacing + 5 -- +5 for component spacing
		
		currentY = currentY + totalHeight
		updateTabCanvasSize()
		
		return textboxAPI
	end
	
	-- Add NumberBox Component
	function tabAPI:AddNumberBox(numberboxConfig)
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
		numberboxConfig.Settings= config.Settings
		
		local numberboxAPI = NumberBox:Create(numberboxConfig)
		currentY = currentY + 35
		updateTabCanvasSize()
		
		return numberboxAPI
	end
	
	-- Add SelectBox Component
	function tabAPI:AddSelectBox(selectboxConfig)
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
		selectboxConfig.Settings= config.Settings
		
		local selectboxAPI = SelectBox:Create(selectboxConfig)
		currentY = currentY + 30
		updateTabCanvasSize()
		
		return selectboxAPI
	end
	
	-- Add Label Component
	function tabAPI:AddLabel(labelConfig)
		if not Label then
			warn("Tab.AddLabel: Label module not initialized")
			return nil
		end
		
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
		
		lblConfig.Parent = tabContent
		lblConfig.Y = currentY
		-- Size and Color are already passed through if they exist in labelConfig table
		
		local labelAPI = Label:Create(lblConfig)
		currentY = currentY + 25
		updateTabCanvasSize()
		
		return labelAPI
	end
	
	-- Add Separator Component
	function tabAPI:AddSeparator(separatorConfig)
		if not Separator then
			warn("Tab.AddSeparator: Separator module not initialized")
			return nil
		end
		
		separatorConfig = separatorConfig or {}
		separatorConfig.Parent = tabContent
		separatorConfig.Y = currentY
		
		local separatorAPI = Separator:Create(separatorConfig)
		currentY = currentY + 15
		updateTabCanvasSize()
		
		return separatorAPI
	end
	
	-- Add Accordion Component (USING MODULAR ACCORDION)
	function tabAPI:AddAccordion(accordionConfig)
		if not Accordion then
			warn("Tab.AddAccordion: Accordion module not initialized")
			return nil
		end
		
		accordionConfig = accordionConfig or {}
		
		-- Set parent and position
		accordionConfig.Parent = tabContent
		accordionConfig.Y = currentY
		
		-- Pass through EzUI config
		accordionConfig.EzUI = config.EzUI
		accordionConfig.SaveConfiguration = config.SaveConfiguration
		accordionConfig.RegisterComponent = config.RegisterComponent
		accordionConfig.Settings= config.Settings
		accordionConfig.ScreenGui = config.ScreenGui
		
		-- Pass callback for height changes
		accordionConfig.OnHeightChanged = function()
			-- Recalculate tab height
			local maxY = 10
			
			for _, child in pairs(tabContent:GetChildren()) do
				if child:IsA("GuiObject") and child.Visible then
					local childBottom = child.Position.Y.Offset + child.AbsoluteSize.Y
					maxY = math.max(maxY, childBottom)
				end
			end
			
			-- Update currentY (reduced spacing)
			currentY = maxY + 5
			
			-- Use our unified canvas update function
			updateTabCanvasSize()
		end
		
		-- Create accordion using module
		local accordionAPI = Accordion:Create(accordionConfig)
		
		-- Update currentY for next component based on actual container size (reduced spacing)
		task.wait() -- Ensure size is rendered
		local actualHeight = accordionAPI.Container.AbsoluteSize.Y
		currentY = currentY + actualHeight + 5
		updateTabCanvasSize()
		
		return accordionAPI
	end
	
	return tabAPI
end

return Tab
