--[[
	Notification Component (Sonner-style)
	EzUI Library - Modular Component
	
	Creates toast notifications with stacking, animations, and different types
	Similar to Sonner from shadcn/ui
]]

local Notification = {}

local Colors
local TweenService = game:GetService("TweenService")

-- Global notification container and state
local NotificationContainer = nil
local ActiveNotifications = {}
local NotificationId = 0
local MaxNotifications = 5
local NotificationWidth = 300  -- Reduced from 350
local NotificationHeight = 55  -- Reduced from 70
local StackOffset = 6          -- Reduced from 8
local AnimationDuration = 0.3

function Notification:Init(_colors)
	Colors = _colors
end

-- Initialize the global notification container
local function initializeContainer(screenGui)
	if NotificationContainer then return end
	
	NotificationContainer = Instance.new("Frame")
	NotificationContainer.Name = "NotificationContainer"
	NotificationContainer.Size = UDim2.new(0, NotificationWidth + 20, 1, 0)
	NotificationContainer.Position = UDim2.new(1, -NotificationWidth - 30, 0, 0) -- Top right
	NotificationContainer.BackgroundTransparency = 1
	NotificationContainer.ZIndex = 1000
	NotificationContainer.Parent = screenGui
end

-- Create individual notification
local function createNotification(config)
	local notificationType = config.Type or "info" -- info, success, warning, error
	local title = config.Title or ""
	local message = config.Message or config.Description or ""
	local duration = config.Duration or 4000 -- milliseconds
	local action = config.Action -- {label, callback}
	local onDismiss = config.OnDismiss
	
	-- Generate unique ID
	NotificationId = NotificationId + 1
	local id = NotificationId
	
	-- Create notification frame
	local notification = Instance.new("Frame")
	notification.Name = "Notification_" .. id
	notification.Size = UDim2.new(0, NotificationWidth, 0, NotificationHeight)
	notification.Position = UDim2.new(0, 10, 0, 20) -- Start position
	notification.BackgroundColor3 = Colors.Surface.Elevated
	notification.BorderSizePixel = 0
	notification.ZIndex = 1001
	notification.ClipsDescendants = false
	notification.Parent = NotificationContainer
	
	-- Notification corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification
	
	-- Notification border/stroke
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Transparency = 0.8
	
	-- Type-specific colors
	if notificationType == "success" then
		stroke.Color = Colors.Status.Success
	elseif notificationType == "warning" then
		stroke.Color = Colors.Status.Warning
	elseif notificationType == "error" then
		stroke.Color = Colors.Status.Error
	else -- info
		stroke.Color = Colors.Border.Default
	end
	stroke.Parent = notification
	
	-- Subtle shadow effect
	local shadow = Instance.new("Frame")
	shadow.Size = UDim2.new(1, 4, 1, 4)
	shadow.Position = UDim2.new(0, -2, 0, 2)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.9
	shadow.ZIndex = notification.ZIndex - 1
	shadow.Parent = notification
	
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 10)
	shadowCorner.Parent = shadow
	
	-- Status indicator (colored bar)
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 4, 1, -12)
	indicator.Position = UDim2.new(0, 6, 0, 6)
	indicator.BorderSizePixel = 0
	indicator.ZIndex = notification.ZIndex + 1
	indicator.Parent = notification
	
	if notificationType == "success" then
		indicator.BackgroundColor3 = Colors.Status.Success
	elseif notificationType == "warning" then
		indicator.BackgroundColor3 = Colors.Status.Warning
	elseif notificationType == "error" then
		indicator.BackgroundColor3 = Colors.Status.Error
	else -- info
		indicator.BackgroundColor3 = Colors.Accent.Primary
	end
	
	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(0, 2)
	indicatorCorner.Parent = indicator
	
	-- Icon (emoji-based for simplicity, more compact)
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 16, 0, 16)  -- Reduced from 20x20
	icon.Position = UDim2.new(0, 16, 0, 8)  -- Closer to edges
	icon.BackgroundTransparency = 1
	icon.Font = Enum.Font.GothamBold  -- Use bold for better icon visibility
	icon.TextSize = 14  -- Reduced from 16
	icon.TextColor3 = Colors.Text.Primary
	icon.TextXAlignment = Enum.TextXAlignment.Center
	icon.TextYAlignment = Enum.TextYAlignment.Center
	icon.ZIndex = notification.ZIndex + 1
	icon.Parent = notification
	
	if notificationType == "success" then
		icon.Text = "✓"
		icon.TextColor3 = Colors.Status.Success
	elseif notificationType == "warning" then
		icon.Text = "⚠"
		icon.TextColor3 = Colors.Status.Warning
	elseif notificationType == "error" then
		icon.Text = "!"  -- Changed to exclamation mark for better visibility
		icon.TextColor3 = Colors.Status.Error
		icon.TextSize = 16  -- Slightly larger for error icon
	else -- info
		icon.Text = "i"  -- Changed to simple 'i' for info
		icon.TextColor3 = Colors.Accent.Primary
	end
	
	-- Content container (more compact)
	local contentContainer = Instance.new("Frame")
	contentContainer.Size = UDim2.new(1, action and -80 or -50, 1, -8)  -- Reduced margins
	contentContainer.Position = UDim2.new(0, 40, 0, 4)  -- Closer positioning
	contentContainer.BackgroundTransparency = 1
	contentContainer.ZIndex = notification.ZIndex + 1
	contentContainer.Parent = notification
	
	-- Title (more compact)
	local hasTitle = title and title ~= ""
	local titleLabel = nil
	if hasTitle then
		titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, 0, 0, 16)  -- Reduced from 18
		titleLabel.Position = UDim2.new(0, 0, 0, 1)  -- Reduced from 2
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.TextColor3 = Colors.Text.Primary
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextYAlignment = Enum.TextYAlignment.Top
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 13  -- Reduced from 14
		titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		titleLabel.ZIndex = contentContainer.ZIndex + 1
		titleLabel.Parent = contentContainer
	end
	
	-- Message (more compact)
	if message and message ~= "" then
		local messageLabel = Instance.new("TextLabel")
		messageLabel.Size = UDim2.new(1, 0, hasTitle and 0, 14 or 1, 0)  -- Reduced from 16
		messageLabel.Position = UDim2.new(0, 0, hasTitle and 0, 17 or 0, 0)  -- Reduced from 20
		messageLabel.BackgroundTransparency = 1
		messageLabel.Text = message
		messageLabel.TextColor3 = Colors.Text.Secondary
		messageLabel.TextXAlignment = Enum.TextXAlignment.Left
		messageLabel.TextYAlignment = hasTitle and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
		messageLabel.Font = Enum.Font.Gotham
		messageLabel.TextSize = 11  -- Reduced from 12
		messageLabel.TextWrapped = true
		messageLabel.ZIndex = contentContainer.ZIndex + 1
		messageLabel.Parent = contentContainer
	end
	
	-- Action button (more compact)
	if action then
		local actionButton = Instance.new("TextButton")
		actionButton.Size = UDim2.new(0, 50, 0, 20)  -- Reduced from 60x24
		actionButton.Position = UDim2.new(1, -55, 0.5, -10)  -- Adjusted position
		actionButton.BackgroundColor3 = Colors.Button.Primary
		actionButton.BorderSizePixel = 0
		actionButton.Text = action.label or "Action"
		actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		actionButton.Font = Enum.Font.Gotham
		actionButton.TextSize = 10  -- Reduced from 11
		actionButton.ZIndex = notification.ZIndex + 2
		actionButton.Parent = notification
		
		local actionCorner = Instance.new("UICorner")
		actionCorner.CornerRadius = UDim.new(0, 4)
		actionCorner.Parent = actionButton
		
		-- Action button hover
		actionButton.MouseEnter:Connect(function()
			local tween = TweenService:Create(actionButton, TweenInfo.new(0.2), {
				BackgroundColor3 = Colors.Button.PrimaryHover
			})
			tween:Play()
		end)
		
		actionButton.MouseLeave:Connect(function()
			local tween = TweenService:Create(actionButton, TweenInfo.new(0.2), {
				BackgroundColor3 = Colors.Button.Primary
			})
			tween:Play()
		end)
		
		actionButton.MouseButton1Click:Connect(function()
			if action.callback then
				action.callback()
			end
			Notification:Dismiss(id)
		end)
	end
	
	-- Close button (moved to top-right corner)
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 20, 0, 20)
	closeButton.Position = UDim2.new(1, -24, 0, 0)  -- Moved even closer to top edge
	closeButton.BackgroundTransparency = 1
	closeButton.Text = "×"
	closeButton.TextColor3 = Colors.Text.Secondary
	closeButton.TextSize = 16
	closeButton.Font = Enum.Font.GothamBold
	closeButton.ZIndex = notification.ZIndex + 2
	closeButton.Parent = notification
	
	-- Close button hover
	closeButton.MouseEnter:Connect(function()
		closeButton.TextColor3 = Colors.Text.Primary
		closeButton.BackgroundTransparency = 0.9
		closeButton.BackgroundColor3 = Colors.Surface.Hover
	end)
	
	closeButton.MouseLeave:Connect(function()
		closeButton.TextColor3 = Colors.Text.Secondary
		closeButton.BackgroundTransparency = 1
	end)
	
	closeButton.MouseButton1Click:Connect(function()
		Notification:Dismiss(id)
	end)
	
	-- Progress bar (for duration, more compact)
	local progressBar = Instance.new("Frame")
	progressBar.Size = UDim2.new(1, -8, 0, 2)  -- Slightly wider (reduced margin from 12 to 8)
	progressBar.Position = UDim2.new(0, 4, 1, -6)  -- Adjusted position (closer to bottom edge)
	progressBar.BackgroundColor3 = indicator.BackgroundColor3
	progressBar.BackgroundTransparency = 0.7
	progressBar.BorderSizePixel = 0
	progressBar.ZIndex = notification.ZIndex + 1
	progressBar.Parent = notification
	
	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 1)
	progressCorner.Parent = progressBar
	
	-- Store notification data
	local notificationData = {
		id = id,
		frame = notification,
		duration = duration,
		onDismiss = onDismiss,
		startTime = tick() * 1000,
		progressBar = progressBar
	}
	
	table.insert(ActiveNotifications, notificationData)
	
	-- Calculate proper position for this notification
	local notificationIndex = #ActiveNotifications
	local yOffset = 20 + ((notificationIndex - 1) * (NotificationHeight + StackOffset))
	
	-- Animate in from off-screen to proper stacked position
	notification.Position = UDim2.new(1, 0, 0, yOffset) -- Start off-screen at correct Y
	local slideIn = TweenService:Create(notification, 
		TweenInfo.new(AnimationDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{Position = UDim2.new(0, 10, 0, yOffset)}
	)
	slideIn:Play()
	
	-- Update positions for all other notifications (to apply stacking effects)
	updateNotificationPositions()
	
	-- Auto dismiss after duration
	if duration > 0 then
		task.spawn(function()
			local startTime = tick() * 1000
			while true do
				task.wait(0.1)
				local elapsed = (tick() * 1000) - startTime
				local progress = elapsed / duration
				
				if progress >= 1 then
					Notification:Dismiss(id)
					break
				end
				
				-- Update progress bar
				progressBar.Size = UDim2.new(1 - progress, -12, 0, 2)
			end
		end)
	end
	
	-- Remove old notifications if exceeding max
	if #ActiveNotifications > MaxNotifications then
		Notification:Dismiss(ActiveNotifications[1].id)
	end
	
	return id
end

-- Update notification positions with stacking effect
function updateNotificationPositions()
	for i, notificationData in ipairs(ActiveNotifications) do
		local yOffset = 20 + ((i - 1) * (NotificationHeight + StackOffset))
		local scale = math.max(0.95, 1 - ((i - 1) * 0.02)) -- Slight scale reduction for stacked items
		local transparency = math.min(0.3, (i - 1) * 0.1) -- Slight transparency for stacked items
		
		local tween = TweenService:Create(notificationData.frame,
			TweenInfo.new(AnimationDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0, 10, 0, yOffset),
				Size = UDim2.new(0, NotificationWidth * scale, 0, NotificationHeight * scale)
			}
		)
		tween:Play()
		
		-- Apply transparency to stacked notifications
		if i > 1 then
			notificationData.frame.BackgroundTransparency = transparency
		else
			notificationData.frame.BackgroundTransparency = 0
		end
	end
end

-- Public API
function Notification:Create(config)
	if not config then
		warn("Notification:Create requires a config table")
		return nil
	end
	
	-- Initialize container if needed
	local screenGui = config.ScreenGui or game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChildOfClass("ScreenGui")
	initializeContainer(screenGui)
	
	return createNotification(config)
end

-- Dismiss notification by ID
function Notification:Dismiss(id)
	for i, notificationData in ipairs(ActiveNotifications) do
		if notificationData.id == id then
			-- Animate out
			local slideOut = TweenService:Create(notificationData.frame,
				TweenInfo.new(AnimationDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{Position = UDim2.new(1, 0, notificationData.frame.Position.Y.Scale, notificationData.frame.Position.Y.Offset)}
			)
			
			slideOut:Play()
			slideOut.Completed:Connect(function()
				notificationData.frame:Destroy()
			end)
			
			-- Call dismiss callback
			if notificationData.onDismiss then
				notificationData.onDismiss()
			end
			
			-- Remove from active notifications
			table.remove(ActiveNotifications, i)
			
			-- Update positions
			updateNotificationPositions()
			break
		end
	end
end

-- Clear all notifications
function Notification:Clear()
	for _, notificationData in ipairs(ActiveNotifications) do
		local slideOut = TweenService:Create(notificationData.frame,
			TweenInfo.new(AnimationDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{Position = UDim2.new(1, 0, notificationData.frame.Position.Y.Scale, notificationData.frame.Position.Y.Offset)}
		)
		slideOut:Play()
		slideOut.Completed:Connect(function()
			notificationData.frame:Destroy()
		end)
	end
	ActiveNotifications = {}
end

-- Convenience methods for different types
function Notification:Success(config)
	config = config or {}
	config.Type = "success"
	return self:Create(config)
end

function Notification:Warning(config)
	config = config or {}
	config.Type = "warning"
	return self:Create(config)
end

function Notification:Error(config)
	config = config or {}
	config.Type = "error"
	return self:Create(config)
end

function Notification:Info(config)
	config = config or {}
	config.Type = "info"
	return self:Create(config)
end

return Notification