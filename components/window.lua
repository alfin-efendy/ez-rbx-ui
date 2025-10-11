--[[
	Window Component
	EzUI Library - Modular Component
	
	Creates main window with responsive sizing and dragging
]]

local Window = {}
local Colors
local Accordion
local Button
local Label
local NumberBox
local Notification
local SelectBox
local Separator
local Tab
local TextBox
local Toggle

function Window:Init(_colors, _accordion, _button, _label, _numberbox, _notification, _selectbox, _separator, _tab, _textbox, _toggle)
    Colors = _colors
    Accordion = _accordion
    Button = _button
    Label = _label
    NumberBox = _numberbox
    Notification = _notification
    SelectBox = _selectbox
    Separator = _separator
    Tab = _tab
    TextBox = _textbox
    Toggle = _toggle
    
    -- Debug: Verify Colors module is loaded
    if not Colors then
        warn("Window:Init() - Colors module is nil!")
    elseif not Colors.Background then
        warn("Window:Init() - Colors module missing Background property!")
    end
end

function Window:GetViewportSize()
	local camera = workspace.CurrentCamera
	if not camera then
		camera = workspace:WaitForChild("CurrentCamera", 5)
	end
	
	local viewportSize = camera.ViewportSize
	
	if viewportSize.X <= 1 or viewportSize.Y <= 1 then
		viewportSize = Vector2.new(1366, 768)
		warn("EzUI: Using fallback viewport size:", viewportSize)
	end
	
	return viewportSize
end

function Window:CalculateDynamicSize(width, height)
	local viewportSize = self:GetViewportSize()
	
	local baseWidth = width or (viewportSize.X * 0.7)
	local baseHeight = height or (viewportSize.Y * 0.4)
	
	local scaleMultiplier = 1
	if viewportSize.X >= 1920 then
		scaleMultiplier = 1.2
	elseif viewportSize.X >= 1366 then
		scaleMultiplier = 1.0
	elseif viewportSize.X >= 1024 then
		scaleMultiplier = 0.9
	else
		scaleMultiplier = 0.8
	end
	
	local finalWidth = math.max(300, math.min(viewportSize.X * 0.8, baseWidth * scaleMultiplier))
	local finalHeight = math.max(200, math.min(viewportSize.Y * 0.8, baseHeight * scaleMultiplier))
	
	return finalWidth, finalHeight
end

function Window:CreateFloatingButton(screenGui, frame, toggleMinimizeCallback, autoShow)
	-- Create floating button (visibility based on AutoShow parameter)
	local floatingButton = Instance.new("Frame")
	floatingButton.Size = UDim2.new(0, 50, 0, 50)
	floatingButton.Position = UDim2.new(0, 0, 0.5, -25) -- Middle left by default
	floatingButton.BackgroundColor3 = Colors.Background.Primary
	floatingButton.BorderSizePixel = 0
	floatingButton.ZIndex = 100
	floatingButton.Visible = not autoShow -- Show floating button if window starts hidden
	floatingButton.Active = true
	floatingButton.Parent = screenGui
	
	-- Rounded corners for floating button
	local floatingCorner = Instance.new("UICorner")
	floatingCorner.CornerRadius = UDim.new(0, 12)
	floatingCorner.Parent = floatingButton
	
	-- Arrow icon
	local arrowIcon = Instance.new("TextLabel")
	arrowIcon.Size = UDim2.new(1, 0, 1, 0)
	arrowIcon.Position = UDim2.new(0, 0, 0, 0)
	arrowIcon.BackgroundTransparency = 1
	arrowIcon.Text = ">"
	arrowIcon.TextColor3 = Colors.Text.Primary
	arrowIcon.TextSize = 24
	arrowIcon.Font = Enum.Font.SourceSansBold
	arrowIcon.TextXAlignment = Enum.TextXAlignment.Center
	arrowIcon.TextYAlignment = Enum.TextYAlignment.Center
	arrowIcon.ZIndex = 101
	arrowIcon.Parent = floatingButton
	
	-- Click detector for floating button
	local floatingClickButton = Instance.new("TextButton")
	floatingClickButton.Size = UDim2.new(1, 0, 1, 0)
	floatingClickButton.BackgroundTransparency = 1
	floatingClickButton.Text = ""
	floatingClickButton.ZIndex = 102
	floatingClickButton.Parent = floatingButton
	
	-- Shadow effect for floating button
	local floatingShadow = Instance.new("Frame")
	floatingShadow.Size = UDim2.new(1, 4, 1, 4)
	floatingShadow.Position = UDim2.new(0, -2, 0, -2)
	floatingShadow.BackgroundColor3 = Colors.Background.Overlay
	floatingShadow.BackgroundTransparency = 0.8
	floatingShadow.BorderSizePixel = 0
	floatingShadow.ZIndex = 99
	floatingShadow.Parent = floatingButton
	
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 12)
	shadowCorner.Parent = floatingShadow
	
	-- Hover effects for floating button
	local originalColor = Colors.Background.Primary
	floatingClickButton.MouseEnter:Connect(function()
		floatingButton.BackgroundColor3 = Colors.Background.Secondary
	end)
	
	floatingClickButton.MouseLeave:Connect(function()
		floatingButton.BackgroundColor3 = originalColor
	end)
	
	-- Dragging functionality for floating button
	local floatingDragging = false
	local floatingDragInput, floatingDragStart, floatingStartPos
	local isOnLeftSide = true -- Track which side the button is on
	
	local function snapFloatingButton()
		-- Get viewport size
		local viewportSize = Window:GetViewportSize()
		local currentPos = floatingButton.AbsolutePosition
		local buttonWidth = floatingButton.AbsoluteSize.X
		local buttonHeight = floatingButton.AbsoluteSize.Y
		
		-- Determine which side is closer (left or right)
		local distanceToLeft = currentPos.X
		local distanceToRight = viewportSize.X - (currentPos.X + buttonWidth)
		
		local targetX, targetY
		local offsetAmount = 15 -- How much to offset off-screen
		
		if distanceToLeft < distanceToRight then
			-- Snap to left side - slightly off-screen
			targetX = -offsetAmount
			isOnLeftSide = true
			arrowIcon.Text = ">"
		else
			-- Snap to right side - slightly off-screen
			targetX = viewportSize.X - buttonWidth + offsetAmount
			isOnLeftSide = false
			arrowIcon.Text = "<"
		end
		
		-- Keep Y position but clamp to viewport bounds
		targetY = math.max(10, math.min(viewportSize.Y - buttonHeight - 10, currentPos.Y))
		
		-- Animate to snapped position
		floatingButton:TweenPosition(
			UDim2.new(0, targetX, 0, targetY),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.3,
			true
		)
	end
	
	local function updateFloatingDrag(input)
		local delta = input.Position - floatingDragStart
		local newPos = UDim2.new(
			floatingStartPos.X.Scale,
			floatingStartPos.X.Offset + delta.X,
			floatingStartPos.Y.Scale,
			floatingStartPos.Y.Offset + delta.Y
		)
		floatingButton.Position = newPos
	end
	
	floatingClickButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or 
		   input.UserInputType == Enum.UserInputType.Touch then
			floatingDragging = true
			floatingDragStart = input.Position
			floatingStartPos = floatingButton.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					floatingDragging = false
					-- Snap to nearest side when drag ends
					snapFloatingButton()
				end
			end)
		end
	end)
	
	floatingClickButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or
		   input.UserInputType == Enum.UserInputType.Touch then
			floatingDragInput = input
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if floatingDragging and input == floatingDragInput then
			updateFloatingDrag(input)
		end
	end)
	
	-- Click detection for restore window
	local clickStartTime = 0
	local clickStartPos = Vector2.new(0, 0)
	
	floatingClickButton.MouseButton1Down:Connect(function()
		clickStartTime = tick()
		clickStartPos = Vector2.new(floatingButton.AbsolutePosition.X, floatingButton.AbsolutePosition.Y)
	end)
	
	floatingClickButton.MouseButton1Up:Connect(function()
		local clickDuration = tick() - clickStartTime
		local currentPos = Vector2.new(floatingButton.AbsolutePosition.X, floatingButton.AbsolutePosition.Y)
		local dragDistance = (currentPos - clickStartPos).Magnitude
		
		-- Only toggle if it was a quick click (< 0.2s) and minimal drag (< 5 pixels)
		if clickDuration < 0.2 and dragDistance < 5 then
			toggleMinimizeCallback()
		end
	end)
	
	return {
		Frame = floatingButton,
		SnapToEdge = snapFloatingButton
	}
end

function Window:SetupMinimizeToggle(frame, floatingButton, originalPosition)
	local isMinimized = false
	
	local function toggleMinimize()
		isMinimized = not isMinimized
		
		if isMinimized then
			-- Minimize: hide window and show floating button
			originalPosition = frame.Position
			frame.Visible = false
			
			-- Show floating button with animation
			floatingButton.Frame.Visible = true
			floatingButton.Frame.Size = UDim2.new(0, 0, 0, 50)
			floatingButton.Frame:TweenSize(
				UDim2.new(0, 50, 0, 50),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.3,
				true,
				function()
					-- Snap to side after appearing
					floatingButton.SnapToEdge()
				end
			)
		else
			-- Restore: hide floating button and show window
			floatingButton.Frame:TweenSize(
				UDim2.new(0, 0, 0, 50),
				Enum.EasingDirection.In,
				Enum.EasingStyle.Quad,
				0.2,
				true,
				function()
					floatingButton.Frame.Visible = false
					frame.Visible = true
					frame.Position = originalPosition
				end
			)
		end
	end
	
	return {
		Toggle = toggleMinimize,
		IsMinimized = function() return isMinimized end
	}
end

function Window:CreateResizeHandle(frame, minWidth, minHeight, maxWidth, maxHeight)
	-- Create resize handle in bottom-right corner
	local resizeHandle = Instance.new("ImageButton")
	resizeHandle.Size = UDim2.new(0, 20, 0, 20)
	resizeHandle.Position = UDim2.new(1, -20, 1, -20)
	resizeHandle.BackgroundColor3 = Colors.Accent.Primary
	resizeHandle.BackgroundTransparency = 0.7
	resizeHandle.BorderSizePixel = 0
    resizeHandle.Image = "rbxassetid://16898613613"
    resizeHandle.ImageRectOffset = Vector2.new(820,196)
	resizeHandle.ImageRectSize = Vector2.new(48, 48) 
	resizeHandle.ZIndex = 10
	resizeHandle.Active = true
	resizeHandle.Parent = frame
	
	-- Corner radius
	local handleCorner = Instance.new("UICorner")
	handleCorner.CornerRadius = UDim.new(0, 4)
	handleCorner.Parent = resizeHandle
	
	-- Hover effect
	resizeHandle.MouseEnter:Connect(function()
		resizeHandle.BackgroundTransparency = 0.3
	end)
	
	resizeHandle.MouseLeave:Connect(function()
		resizeHandle.BackgroundTransparency = 0.7
	end)
	
	-- Resize functionality
	local resizing = false
	local resizeStart, startSize
	
	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or 
		   input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			startSize = frame.AbsoluteSize
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or 
		   input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - resizeStart
			
			-- Calculate new size
			local newWidth = startSize.X + delta.X
			local newHeight = startSize.Y + delta.Y
			
			-- Apply min/max constraints
			newWidth = math.max(minWidth or 300, newWidth)
			newHeight = math.max(minHeight or 200, newHeight)
			
			if maxWidth then
				newWidth = math.min(maxWidth, newWidth)
			end
			
			if maxHeight then
				newHeight = math.min(maxHeight, newHeight)
			end
			
			-- Update frame size
			frame.Size = UDim2.new(0, newWidth, 0, newHeight)
		end
	end)
	
	return resizeHandle
end

function Window:CreateTabPanelResizer(tabPanel, scrollFrame, minTabWidth, maxTabWidth)
	-- Create resize handle on right edge of tab panel
	local resizer = Instance.new("Frame")
	resizer.Size = UDim2.new(0, 4, 1, 0)
	resizer.Position = UDim2.new(1, 0, 0, 0)
	resizer.BackgroundColor3 = Colors.Accent.Primary
	resizer.BackgroundTransparency = 0.9
	resizer.BorderSizePixel = 0
	resizer.ZIndex = 10
	resizer.Active = true
	resizer.Parent = tabPanel
	
	-- Visual indicator (appears on hover)
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 2, 1, 0)
	indicator.Position = UDim2.new(0, 1, 0, 0)
	indicator.BackgroundColor3 = Colors.Accent.Primary
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.ZIndex = 11
	indicator.Parent = resizer
	
	-- Hover effects
	resizer.MouseEnter:Connect(function()
		resizer.BackgroundTransparency = 0.7
		indicator.BackgroundTransparency = 0
	end)
	
	resizer.MouseLeave:Connect(function()
		resizer.BackgroundTransparency = 0.9
		indicator.BackgroundTransparency = 1
	end)
	
	-- Resize functionality
	local resizing = false
	local resizeStart, startWidth
	
	resizer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or 
		   input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			startWidth = tabPanel.AbsoluteSize.X
			
			-- Show indicator while resizing
			indicator.BackgroundTransparency = 0
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					indicator.BackgroundTransparency = 1
				end
			end)
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or 
		   input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - resizeStart
			
			-- Calculate new width
			local newWidth = startWidth + delta.X
			
			-- Apply constraints
			newWidth = math.max(minTabWidth or 80, newWidth)
			newWidth = math.min(maxTabWidth or 300, newWidth)
			
			-- Update tab panel width
			tabPanel.Size = UDim2.new(0, newWidth, 1, -30)
			
			-- Update scroll frame position and size
			scrollFrame.Position = UDim2.new(0, newWidth, 0, 30)
			scrollFrame.Size = UDim2.new(1, -newWidth, 1, -30)
		end
	end)
	
	return resizer
end

function Window:Create(config)
	-- Ensure Colors is initialized with detailed error
	if not Colors then
		error("Window:Create() - Colors module is nil. Window:Init() may not have been called or Colors parameter was nil.")
	end
	
	if not Colors.Background then
		error("Window:Create() - Colors.Background is nil. The Colors module may not have loaded correctly.")
	end
	
	local title = config.Title or "EzUI Window"
	local width = config.Width
	local height = config.Height
	local opacity = config.Opacity or 0.9
	local autoShow = config.AutoShow ~= nil and config.AutoShow or true
	local draggable = config.Draggable ~= nil and config.Draggable or true
	local resizable = config.Resizable ~= nil and config.Resizable or true
	local tabPanelResizable = config.TabPanelResizable ~= nil and config.TabPanelResizable or true
	local backgroundColor = config.BackgroundColor or Colors.Background.Secondary
	local cornerRadius = config.CornerRadius or 8
	local minWidth = config.MinWidth or 300
	local minHeight = config.MinHeight or 200
	local maxWidth = config.MaxWidth
	local maxHeight = config.MaxHeight
	local tabPanelWidth = config.TabPanelWidth or 130
	local minTabPanelWidth = config.MinTabPanelWidth or 80
	local maxTabPanelWidth = config.MaxTabPanelWidth or 300
	local settings = config.Settings or {}
	local autoAdapt = config.AutoAdapt ~= nil and config.AutoAdapt or true
	
	-- Close callback functionality
	local onCloseCallback = config.OnClose or nil
	
	opacity = math.max(0.1, math.min(1.0, opacity))
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = title
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local windowWidth, windowHeight = self:CalculateDynamicSize(width, height)
	
	-- Main window frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
	frame.Position = UDim2.new(0.5, -windowWidth / 2, 0.5, -windowHeight / 2)
	frame.BackgroundColor3 = backgroundColor
	frame.BackgroundTransparency = 1 - opacity
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.ClipsDescendants = true
	frame.ZIndex = 1
	frame.Visible = autoShow
	frame.Parent = screenGui
	
	-- Rounded corners
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, cornerRadius)
	frameCorner.Parent = frame
	
	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = Colors.Background.Primary
	titleBar.BorderSizePixel = 0
	titleBar.ZIndex = 2
	titleBar.Parent = frame
	
	-- Title bar rounded corners (top only)
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, cornerRadius)
	titleCorner.Parent = titleBar
	
	-- Title text
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -70, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Colors.Text.Primary
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 3
	titleLabel.Parent = titleBar
	
	-- Minimize button
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
	minimizeBtn.Position = UDim2.new(1, -60, 0, 0)
	minimizeBtn.BackgroundTransparency = 1
	minimizeBtn.Text = "−"
	minimizeBtn.TextColor3 = Colors.Text.Primary
	minimizeBtn.TextSize = 24
	minimizeBtn.Font = Enum.Font.SourceSansBold
	minimizeBtn.ZIndex = 3
	minimizeBtn.Parent = titleBar
	
	minimizeBtn.MouseEnter:Connect(function()
		minimizeBtn.TextColor3 = Colors.Accent.Primary
	end)
	
	minimizeBtn.MouseLeave:Connect(function()
		minimizeBtn.TextColor3 = Colors.Text.Primary
	end)
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -30, 0, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Colors.Text.Primary
	closeBtn.TextSize = 24
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.ZIndex = 3
	closeBtn.Parent = titleBar
	
	closeBtn.MouseEnter:Connect(function()
		closeBtn.TextColor3 = Colors.Status.Error
	end)
	
	closeBtn.MouseLeave:Connect(function()
		closeBtn.TextColor3 = Colors.Text.Primary
	end)
	
	-- Create confirmation dialog elements (hidden by default)
	local confirmationOverlay = Instance.new("Frame")
	confirmationOverlay.Size = UDim2.new(1, 0, 1, 0)
	confirmationOverlay.Position = UDim2.new(0, 0, 0, 0)
	confirmationOverlay.BackgroundColor3 = Colors.Special.Overlay
	confirmationOverlay.BackgroundTransparency = 0.5
	confirmationOverlay.BorderSizePixel = 0
	confirmationOverlay.ZIndex = 100
	confirmationOverlay.Visible = false
	confirmationOverlay.Parent = frame
	
	local confirmationDialog = Instance.new("Frame")
	confirmationDialog.Size = UDim2.new(0, 300, 0, 130)
	confirmationDialog.Position = UDim2.new(0.5, -150, 0.5, -65)
	confirmationDialog.BackgroundColor3 = Colors.Surface.Elevated
	confirmationDialog.BorderSizePixel = 0
	confirmationDialog.ZIndex = 101
	confirmationDialog.Parent = confirmationOverlay
	
	local confirmDialogCorner = Instance.new("UICorner")
	confirmDialogCorner.CornerRadius = UDim.new(0, 8)
	confirmDialogCorner.Parent = confirmationDialog
	
	-- Confirmation dialog title
	local confirmTitle = Instance.new("TextLabel")
	confirmTitle.Size = UDim2.new(1, -20, 0, 25)
	confirmTitle.Position = UDim2.new(0, 10, 0, 8)
	confirmTitle.BackgroundTransparency = 1
	confirmTitle.Text = "⚠️ Confirm Close"
	confirmTitle.TextColor3 = Colors.Text.Primary
	confirmTitle.TextSize = 14
	confirmTitle.Font = Enum.Font.GothamBold
	confirmTitle.TextXAlignment = Enum.TextXAlignment.Left
	confirmTitle.ZIndex = 102
	confirmTitle.Parent = confirmationDialog
	
	-- Confirmation message
	local confirmMessage = Instance.new("TextLabel")
	confirmMessage.Size = UDim2.new(1, -20, 0, 35)
	confirmMessage.Position = UDim2.new(0, 10, 0, 35)
	confirmMessage.BackgroundTransparency = 1
	confirmMessage.Text = "Are you sure you want to close?"
	confirmMessage.TextColor3 = Colors.Text.Secondary
	confirmMessage.TextSize = 12
	confirmMessage.Font = Enum.Font.Gotham
	confirmMessage.TextWrapped = true
	confirmMessage.TextXAlignment = Enum.TextXAlignment.Left
	confirmMessage.TextYAlignment = Enum.TextYAlignment.Top
	confirmMessage.ZIndex = 102
	confirmMessage.Parent = confirmationDialog
	
	-- Button container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Size = UDim2.new(1, -20, 0, 32)
	buttonContainer.Position = UDim2.new(0, 10, 1, -40)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.ZIndex = 102
	buttonContainer.Parent = confirmationDialog
	
	-- Cancel button
	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0, 130, 0, 32)
	cancelBtn.Position = UDim2.new(0, 0, 0, 0)
	cancelBtn.BackgroundColor3 = Colors.Button.Secondary
	cancelBtn.BorderSizePixel = 0
	cancelBtn.Text = "Cancel"
	cancelBtn.TextColor3 = Colors.Text.Primary
	cancelBtn.TextSize = 13
	cancelBtn.Font = Enum.Font.GothamBold
	cancelBtn.ZIndex = 103
	cancelBtn.Parent = buttonContainer
	
	local cancelCorner = Instance.new("UICorner")
	cancelCorner.CornerRadius = UDim.new(0, 6)
	cancelCorner.Parent = cancelBtn
	
	-- Confirm button
	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(0, 130, 0, 32)
	confirmBtn.Position = UDim2.new(1, -130, 0, 0)
	confirmBtn.BackgroundColor3 = Colors.Button.Danger
	confirmBtn.BorderSizePixel = 0
	confirmBtn.Text = "Close"
	confirmBtn.TextColor3 = Colors.Text.Primary
	confirmBtn.TextSize = 13
	confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.ZIndex = 103
	confirmBtn.Parent = buttonContainer
	
	local confirmCorner = Instance.new("UICorner")
	confirmCorner.CornerRadius = UDim.new(0, 6)
	confirmCorner.Parent = confirmBtn
	
	-- Button hover effects
	cancelBtn.MouseEnter:Connect(function()
		cancelBtn.BackgroundColor3 = Colors.Button.SecondaryHover
	end)
	
	cancelBtn.MouseLeave:Connect(function()
		cancelBtn.BackgroundColor3 = Colors.Button.Secondary
	end)
	
	confirmBtn.MouseEnter:Connect(function()
		confirmBtn.BackgroundColor3 = Colors.Button.DangerHover
	end)
	
	confirmBtn.MouseLeave:Connect(function()
		confirmBtn.BackgroundColor3 = Colors.Button.Danger
	end)
	
	-- Cancel button action
	cancelBtn.MouseButton1Click:Connect(function()
		confirmationOverlay.Visible = false
	end)
	
	-- Confirm button action
	confirmBtn.MouseButton1Click:Connect(function()
		confirmationOverlay.Visible = false
		
		-- Call user close callback before destroying
		if onCloseCallback then
			local success, errorMsg = pcall(function()
				onCloseCallback()
			end)
			
			if not success then
				warn("Close callback error:", errorMsg)
			end
		end
		
		screenGui:Destroy()
	end)
	
	-- Close button shows confirmation dialog
	closeBtn.MouseButton1Click:Connect(function()
		confirmationOverlay.Visible = true
	end)
	
	-- Tab panel (left side)
	local tabPanel = Instance.new("Frame")
	tabPanel.Size = UDim2.new(0, tabPanelWidth, 1, -30)
	tabPanel.Position = UDim2.new(0, 0, 0, 30)
	tabPanel.BackgroundColor3 = Colors.Background.Primary
	tabPanel.BorderSizePixel = 0
	tabPanel.ZIndex = 2
	tabPanel.Parent = frame
	
	-- Tab scroll frame
	local tabScrollFrame = Instance.new("ScrollingFrame")
	tabScrollFrame.Size = UDim2.new(1, 0, 1, 0)
	tabScrollFrame.Position = UDim2.new(0, 0, 0, 0)
	tabScrollFrame.BackgroundTransparency = 1
	tabScrollFrame.BorderSizePixel = 0
	tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScrollFrame.ScrollBarThickness = 6
	tabScrollFrame.ScrollBarImageColor3 = Colors.Scrollbar.Thumb
	tabScrollFrame.ZIndex = 3
	tabScrollFrame.Parent = tabPanel
	
	-- List layout for tabs
	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 3)
	tabListLayout.Parent = tabScrollFrame
	
	-- Content scroll frame
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -tabPanelWidth, 1, -30)
	scrollFrame.Position = UDim2.new(0, tabPanelWidth, 0, 30)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.ScrollBarImageColor3 = Colors.Scrollbar.Thumb
	scrollFrame.ClipsDescendants = true
	scrollFrame.ZIndex = 2
	scrollFrame.Parent = frame
	
	-- Function to update canvas size (USING OLD UI.LUA LOGIC - Line ~692)
	local updateCanvasSize  -- Forward declaration
	
	updateCanvasSize = function()
		-- Calculate actual content height for the active tab only
		local maxY = 10
		
		-- Find the currently visible tab content frame
		local activeTabContent = nil
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("Frame") and child.Visible then
				activeTabContent = child
				break
			end
		end
		
		if activeTabContent then
			-- Calculate content height within the active tab
			for _, child in ipairs(activeTabContent:GetChildren()) do
				if child:IsA("GuiObject") and child.Visible then
					local childY = child.Position.Y.Offset
					local childHeight = child.AbsoluteSize.Y
					local childBottom = childY + childHeight
					
					if childBottom > maxY then
						maxY = childBottom
					end
				end
			end
		end
		
		-- Set canvas size with padding
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, maxY + 20)
	end
	
	-- Dragging functionality
	if draggable then
		local dragging = false
		local dragInput, dragStart, startPos
		
		local function update(input)
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
		
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or 
			   input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		
		titleBar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or
			   input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		
		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if dragging and input == dragInput then
				update(input)
			end
		end)
	end
	
	-- Resize functionality
	local resizeHandle = nil
	if resizable then
		resizeHandle = self:CreateResizeHandle(frame, minWidth, minHeight, maxWidth, maxHeight)
	end
	
	-- Tab panel resize functionality
	local tabPanelResizer = nil
	if tabPanelResizable then
		tabPanelResizer = self:CreateTabPanelResizer(tabPanel, scrollFrame, minTabPanelWidth, maxTabPanelWidth)
	end
	
	-- Monitor frame size changes and update canvas
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		-- Update canvas size when window is resized
		task.spawn(updateCanvasSize)
	end)
	
	-- Tab management
	local tabs = {}
	local tabContents = {}
	local currentTab = nil
	local tabCount = 0
	local originalHeight = windowHeight
	local originalPosition = frame.Position
	
	-- Setup minimize/restore functionality (create control first)
	local minimizeControl = {
		Toggle = nil,
		IsMinimized = nil
	}
	
	-- Create floating button with toggle callback
	local floatingButton = self:CreateFloatingButton(screenGui, frame, function()
		if minimizeControl.Toggle then
			minimizeControl.Toggle()
		end
	end, autoShow)
	
	-- Now create the actual minimize control
	local actualMinimizeControl = self:SetupMinimizeToggle(frame, floatingButton, originalPosition)
	minimizeControl.Toggle = actualMinimizeControl.Toggle
	minimizeControl.IsMinimized = actualMinimizeControl.IsMinimized
	
	-- Connect minimize button
	minimizeBtn.MouseButton1Click:Connect(minimizeControl.Toggle)
	
	-- Keyboard shortcut for toggle minimize (Ctrl + M or Ctrl + H)
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		-- Don't trigger if user is typing in a text box
		if gameProcessed then return end
		
		-- Check for Ctrl + M or Ctrl + H
		if input.KeyCode == Enum.KeyCode.M or input.KeyCode == Enum.KeyCode.H then
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or 
			   UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
				minimizeControl.Toggle()
			end
		end
	end)
	
	-- Initialize Notification component
	if Notification then
		Notification:Init(Colors)
	end
	
	-- Window API
	local windowAPI = {
		ScreenGui = screenGui,
		Frame = frame,
		TitleBar = titleBar,
		TabScrollFrame = tabScrollFrame,
		ScrollFrame = scrollFrame,
		TabPanel = tabPanel,
		FloatingButton = floatingButton.Frame,
		ResizeHandle = resizeHandle,
		TabPanelResizer = tabPanelResizer,
		UpdateCanvasSize = updateCanvasSize,  -- Expose update function for accordion callbacks
		Notification = Notification, -- Expose notification component
	}
	
	function windowAPI:Show()
		-- Show the window
		frame.Visible = true
		-- Hide the floating button when window is shown
		floatingButton.Frame.Visible = false
		-- If window was minimized, restore it
		if minimizeControl.IsMinimized() then
			minimizeControl.Toggle()
		end
	end
	
	function windowAPI:Hide()
		-- Hide the window
		frame.Visible = false
		-- Show the floating button when window is hidden
		floatingButton.Frame.Visible = true
	end
	
	function windowAPI:IsVisible()
		-- Check if the window is currently visible (not minimized)
		return frame.Visible and not minimizeControl.IsMinimized()
	end
	
	function windowAPI:ToggleVisibility()
		-- Toggle window visibility
		if self:IsVisible() then
			self:Hide()
		else
			self:Show()
		end
		return self:IsVisible()
	end
	
	function windowAPI:Toggle()
		return self:ToggleVisibility()
	end
	
	function windowAPI:Minimize()
		if not minimizeControl.IsMinimized() then
			minimizeControl.Toggle()
		end
	end
	
	function windowAPI:Restore()
		if minimizeControl.IsMinimized() then
			minimizeControl.Toggle()
		end
	end
	
	function windowAPI:ToggleMinimize()
		minimizeControl.Toggle()
	end
	
	function windowAPI:IsMinimized()
		return minimizeControl.IsMinimized()
	end
	
	function windowAPI:Destroy()
		screenGui:Destroy()
	end
	
	function windowAPI:SetTitle(newTitle)
		titleLabel.Text = newTitle
		title = newTitle
	end
	
	function windowAPI:SetSize(newWidth, newHeight)
		windowWidth = newWidth
		originalHeight = newHeight
		frame.Size = UDim2.new(0, newWidth, 0, newHeight)
	end
	
	function windowAPI:SetPosition(x, y)
		frame.Position = UDim2.new(0, x, 0, y)
	end
	
	function windowAPI:Center()
		local viewportSize = Window:GetViewportSize()
		local size = frame.AbsoluteSize
		frame.Position = UDim2.new(
			0, (viewportSize.X - size.X) / 2,
			0, (viewportSize.Y - size.Y) / 2
		)
	end
	
	function windowAPI:SetResizable(enabled)
		if resizeHandle then
			resizeHandle.Visible = enabled
		end
	end
	
	function windowAPI:GetSize()
		return frame.AbsoluteSize
	end
	
	function windowAPI:SetTabPanelWidth(newWidth)
		newWidth = math.max(minTabPanelWidth, math.min(maxTabPanelWidth, newWidth))
		tabPanel.Size = UDim2.new(0, newWidth, 1, -30)
		scrollFrame.Position = UDim2.new(0, newWidth, 0, 30)
		scrollFrame.Size = UDim2.new(1, -newWidth, 1, -30)
	end
	
	function windowAPI:GetTabPanelWidth()
		return tabPanel.AbsoluteSize.X
	end
	
	function windowAPI:SetTabPanelResizable(enabled)
		if tabPanelResizer then
			tabPanelResizer.Visible = enabled
		end
	end
	
	function windowAPI:GetTabs()
		return tabs
	end
	
	function windowAPI:GetCurrentTab()
		return currentTab
	end
	
	function windowAPI:SelectTab(index)
		if tabs[index] then
			if currentTab then
				currentTab:Deselect()
			end
			currentTab = tabs[index]
			currentTab:Select()
		end
	end

	function windowAPI:AddTab(config)
		-- Handle string shortcut
		if type(config) == "string" then
			config = {Name = config}
		end
		
		-- Validate config
		if type(config) ~= "table" then
			warn("EzUI Window.AddTab: config must be a string or table")
			return nil
		end
		
		local tabName = config.Name or "Tab " .. (tabCount + 1)
		local icon = config.Icon or ""
		
		-- Create the tab using Tab component
		local tabConfig = {
			Name = tabName,
			Icon = icon,
			TabScrollFrame = tabScrollFrame,
			TabContents = tabContents,
			ScrollFrame = scrollFrame,
			ScreenGui = screenGui,
			WindowAPI = windowAPI,  -- Pass window API reference for accordion canvas updates
			UpdateCanvasSize = updateCanvasSize,  -- Pass canvas update function
			Settings = settings  -- Optional settings for the tab
		}
	
		local tabAPI = Tab:Create(tabConfig)
		
		if not tabAPI then
			warn("EzUI Window.AddTab: Failed to create tab")
			return nil
		end
		
		-- Add click handler to switch tabs
		tabAPI.Button.MouseButton1Click:Connect(function()
			if currentTab and currentTab ~= tabAPI then
				currentTab:Deselect()
			end
			currentTab = tabAPI
			tabAPI:Select()
		end)
		
		-- Store tab reference
		tabCount = tabCount + 1
		tabs[tabCount] = tabAPI
		
		-- Auto-select first tab
		if tabCount == 1 then
			currentTab = tabAPI
			tabAPI:Select()
		end
		
		-- Update tab scroll canvas size
		tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y)
		
		return tabAPI
	end
	
	-- Notification methods
	function windowAPI:ShowNotification(config)
		if not Notification then
			warn("Notification component not initialized")
			return nil
		end
		config = config or {}
		config.ScreenGui = screenGui
		return Notification:Create(config)
	end
	
	function windowAPI:ShowSuccess(title, message, duration, action)
		return self:ShowNotification({
			Type = "success",
			Title = title,
			Message = message,
			Duration = duration,
			Action = action
		})
	end
	
	function windowAPI:ShowWarning(title, message, duration, action)
		return self:ShowNotification({
			Type = "warning",
			Title = title,
			Message = message,
			Duration = duration,
			Action = action
		})
	end
	
	function windowAPI:ShowError(title, message, duration, action)
		return self:ShowNotification({
			Type = "error",
			Title = title,
			Message = message,
			Duration = duration,
			Action = action
		})
	end
	
	function windowAPI:ShowInfo(title, message, duration, action)
		return self:ShowNotification({
			Type = "info",
			Title = title,
			Message = message,
			Duration = duration,
			Action = action
		})
	end
	
	function windowAPI:DismissNotification(id)
		if Notification then
			Notification:Dismiss(id)
		end
	end
	
	function windowAPI:ClearNotifications()
		if Notification then
			Notification:Clear()
		end
	end

	function windowAPI:GetConfigValue(key)
		return settings:GetValue(key)
	end

	function windowAPI:SetConfigValue(key, value)
		settings:SetValue(key, value)
	end
	
	-- Viewport adaptation methods
	function windowAPI:AdaptToViewport()
		-- Recalculate window size based on current viewport
		local currentViewport = self:GetViewportSize()
		local baseWidth = config.Width or (currentViewport.X * 0.3)
		local baseHeight = config.Height or (currentViewport.Y * 0.4)
		
		-- Apply resolution-based scaling
		local scaleMultiplier = 1
		if currentViewport.X >= 1920 then -- 1080p+
			scaleMultiplier = 1.2
		elseif currentViewport.X >= 1366 then -- 720p-1080p
			scaleMultiplier = 1.0
		elseif currentViewport.X >= 1024 then -- Tablet size
			scaleMultiplier = 0.9
		else -- Mobile/small screens
			scaleMultiplier = 0.8
		end
		
		-- Calculate new size with limits
		local newWidth = math.max(250, math.min(currentViewport.X * 0.8, baseWidth * scaleMultiplier))
		local newHeight = math.max(150, math.min(currentViewport.Y * 0.8, baseHeight * scaleMultiplier))
		
		-- Apply new size and center the window
		frame.Size = UDim2.new(0, newWidth, 0, newHeight)
		frame.Position = UDim2.new(0.5, -newWidth / 2, 0.5, -newHeight / 2)
	end
	
	function windowAPI:GetDynamicSize()
		local currentViewport = self:GetViewportSize()
		return {
			Width = frame.Size.X.Offset,
			Height = frame.Size.Y.Offset,
			ViewportWidth = currentViewport.X,
			ViewportHeight = currentViewport.Y
		}
	end
	
	function windowAPI:SetSize(width, height)
		local viewportSize = self:GetViewportSize()
		
		-- Apply constraints
		width = math.max(300, math.min(width, viewportSize.X * 0.9))
		height = math.max(200, math.min(height, viewportSize.Y * 0.9))
		
		frame.Size = UDim2.new(0, width, 0, height)
		
		return {Width = width, Height = height}
	end
	
	-- Close callback functionality
	function windowAPI:SetCloseCallback(callback)
		onCloseCallback = callback
	end
	
	function windowAPI:Close()
		-- Call user callback before destroying
		if onCloseCallback then
			local success, errorMsg = pcall(function()
				onCloseCallback()
			end)
			
			if not success then
				warn("Close callback error:", errorMsg)
			end
		end
		
		-- Destroy the UI
		if screenGui then
			screenGui:Destroy()
		end
	end
	
	-- Auto-adapt to viewport changes (optional)
	if autoAdapt then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			task.wait(0.1) -- Small delay to ensure viewport is stable
			windowAPI:AdaptToViewport()
		end)
	end
	
	return windowAPI
end

return Window
