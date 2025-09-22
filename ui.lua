-- EzUI
local EzUI = {}

-- Configuration System
local HttpService = game:GetService("HttpService")
local EzUIFolder = "EzUI"
local ConfigurationFolder = EzUIFolder .. "/Configurations"
local ConfigurationExtension = ".json"

-- Global flags storage for configuration saving
EzUI.Flags = {}

-- Component registry for flag-based updates
EzUI.Components = {}

-- Global configuration state
EzUI.Configuration = {
	Enabled = false,
	FileName = "DefaultConfig",
	FolderName = "EzUI",
	AutoSave = true,
	AutoLoad = true
}

-- Helper functions for component registry
local function registerComponent(flag, componentAPI)
	if flag and componentAPI then
		if not EzUI.Components[flag] then
			EzUI.Components[flag] = {}
		end
		table.insert(EzUI.Components[flag], componentAPI)
	end
end

local function updateComponentsByFlag(flag, value)
	if EzUI.Components[flag] then
		for _, componentAPI in ipairs(EzUI.Components[flag]) do
			if componentAPI.Set then
				componentAPI.Set(value)
			elseif componentAPI.SetValue then
				componentAPI.SetValue(value)
			elseif componentAPI.SetText then
				componentAPI.SetText(value)
			elseif componentAPI.SetSelected then
				componentAPI.SetSelected(value)
			end
		end
	end
end

-- Configuration functions
local function saveConfiguration(fileName)
	if not fileName then return false end
	
	-- Check if we have any flags to save
	if next(EzUI.Flags) == nil then
		print("EzUI: No configuration data to save")
		return false
	end
	
	-- Use dynamic folder name from configuration
	local dynamicFolderName = EzUI.Configuration.FolderName or "EzUI"
	local dynamicConfigurationFolder = dynamicFolderName .. "/Configurations"
	
	-- Save to file if writefile is available
	if writefile then
		-- Create folder if it doesn't exist
		if not isfolder then
			warn("EzUI: Configuration saving requires isfolder function")
			return false
		end
		
		if not isfolder(dynamicFolderName) then
			makefolder(dynamicFolderName)
		end
		
		if not isfolder(dynamicConfigurationFolder) then
			makefolder(dynamicConfigurationFolder)
		end
		
		-- Write configuration file
		local filePath = dynamicConfigurationFolder .. "/" .. fileName .. ConfigurationExtension
		local success, result = pcall(function()
			writefile(filePath, HttpService:JSONEncode(EzUI.Flags))
		end)
		
		if success then
			print("EzUI: Configuration saved to " .. filePath)
			return true
		else
			warn("EzUI: Failed to save configuration: " .. tostring(result))
			return false
		end
	else
		warn("EzUI: Configuration saving requires writefile function")
		return false
	end
end

local function loadConfiguration(fileName)
	if not fileName or not readfile or not isfile then 
		warn("EzUI: Configuration loading requires readfile and isfile functions")
		return false 
	end
	
	-- Use dynamic folder name from configuration
	local dynamicFolderName = EzUI.Configuration.FolderName or "EzUI"
	local dynamicConfigurationFolder = dynamicFolderName .. "/Configurations"
	local filePath = dynamicConfigurationFolder .. "/" .. fileName .. ConfigurationExtension
	
	if not isfile(filePath) then
		print("EzUI: No configuration file found at " .. filePath)
		return false
	end
	
	local success, configData = pcall(function()
		return HttpService:JSONDecode(readfile(filePath))
	end)
	
	if not success then
		warn("EzUI: Failed to load configuration file: " .. tostring(configData))
		return false
	end
	
	-- Apply loaded configuration to flags and update components
	local applied = 0
	for flagName, flagValue in pairs(configData) do
		EzUI.Flags[flagName] = flagValue
		-- Update UI components that use this flag
		updateComponentsByFlag(flagName, flagValue)
		applied = applied + 1
	end
	
	print("EzUI: Configuration loaded from " .. filePath .. " (" .. applied .. " settings applied)")
	return true
end

-- Custom Configuration System (Independent from Window Configuration)
function EzUI.NewConfig(configName)
	-- Create a new custom configuration object
	-- configName: string - name of the configuration (will be used as filename)
	-- Returns: table - custom configuration object with its own methods
	
	if not configName or type(configName) ~= "string" then
		warn("EzUI.NewConfig: configName must be a string")
		return nil
	end
	
	-- Create independent storage for this custom config
	local customFlags = {}
	
	-- Save function for this custom config
	local function saveCustomConfig()
		-- Filter out keys with nil values
		local dataToSave = {}
		local hasData = false
		
		for key, value in pairs(customFlags) do
			if value ~= nil then
				dataToSave[key] = value
				hasData = true
			end
		end
		
		if not hasData then
			print("EzUI.CustomConfig: No valid data to save for " .. configName)
			return false
		end
		
		if not writefile or not isfolder or not makefolder then
			warn("EzUI.CustomConfig: File operations not available")
			return false
		end
		
		-- Use the main EzUI folder structure
		local dynamicFolderName = EzUI.Configuration.FolderName or "EzUI"
		local dynamicConfigurationFolder = dynamicFolderName .. "/Configurations"
		
		-- Create folders if they don't exist
		if not isfolder(dynamicFolderName) then
			makefolder(dynamicFolderName)
		end
		
		if not isfolder(dynamicConfigurationFolder) then
			makefolder(dynamicConfigurationFolder)
		end
		
		-- Save to separate JSON file
		local filePath = dynamicConfigurationFolder .. "/" .. configName .. ".json"
		local success, result = pcall(function()
			writefile(filePath, HttpService:JSONEncode(dataToSave))
		end)
		
		if success then
			local savedCount = 0
			for _ in pairs(dataToSave) do
				savedCount = savedCount + 1
			end
			print("EzUI.CustomConfig: " .. configName .. " saved to " .. filePath .. " (" .. savedCount .. " keys)")
			return true
		else
			warn("EzUI.CustomConfig: Failed to save " .. configName .. ": " .. tostring(result))
			return false
		end
	end
	
	-- Load function for this custom config
	local function loadCustomConfig()
		if not readfile or not isfile then
			warn("EzUI.CustomConfig: File operations not available")
			return false
		end
		
		local dynamicFolderName = EzUI.Configuration.FolderName or "EzUI"
		local dynamicConfigurationFolder = dynamicFolderName .. "/Configurations"
		local filePath = dynamicConfigurationFolder .. "/" .. configName .. ".json"
		
		if not isfile(filePath) then
			print("EzUI.CustomConfig: No file found for " .. configName .. " at " .. filePath)
			return false
		end
		
		local success, configData = pcall(function()
			return HttpService:JSONDecode(readfile(filePath))
		end)
		
		if not success then
			warn("EzUI.CustomConfig: Failed to load " .. configName .. ": " .. tostring(configData))
			return false
		end
		
		-- Apply loaded data and update components
		local applied = 0
		for flagName, flagValue in pairs(configData) do
			customFlags[flagName] = flagValue
			applied = applied + 1
		end
		
		print("EzUI.CustomConfig: " .. configName .. " loaded (" .. applied .. " settings applied)")
		return true
	end

	-- Auto-load function for custom config
	local function autoLoadCustomConfig()
		if loadCustomConfig() then
			-- Apply loaded values to EzUI.Flags to sync with main configuration system
			for flagName, flagValue in pairs(customFlags) do
				EzUI.Flags[flagName] = flagValue
				-- Update UI components that use this flag
				updateComponentsByFlag(flagName, flagValue)
			end
		end
	end
	
	-- Auto-load configuration when first declaring custom config
	task.defer(function()
		autoLoadCustomConfig()
	end)
	
	-- Return custom configuration object
	return {
		-- Get value by key
		GetValue = function(key)
			if not key then
				warn("EzUI.CustomConfig.GetValue: key parameter is required")
				return nil
			end
			return customFlags[key]
		end,
		
		-- Set value by key and update associated components
		SetValue = function(key, value)
			if not key then
				warn("EzUI.CustomConfig.SetValue: key parameter is required")
				return false
			end
			
			customFlags[key] = value
			
			saveCustomConfig()
			return true
		end,

		-- Get all key-value pairs
		GetAll = function()
			local result = {}
			for key, value in pairs(customFlags) do
				if value ~= nil then
					result[key] = value
				end
			end
			return result
		end,

		-- Get All Keys
		GetAllKeys = function()
			local keys = {}
			for key, value in pairs(customFlags) do
				if value ~= nil then
					table.insert(keys, key)
				end
			end
			return keys
		end,

		-- Delete a specific key
		DeleteKey = function(key)
			if not key then
				warn("EzUI.CustomConfig.DeleteKey: key parameter is required")
				return false
			end
			
			if customFlags[key] ~= nil then
				customFlags[key] = nil
				
				saveCustomConfig()
				return true
			else
				warn("EzUI.CustomConfig.DeleteKey: key '" .. key .. "' not found")
				return false
			end
		end
	}
end

function EzUI.CreateWindow(config)
	-- Extract opacity parameter (default 1.0 = fully opaque)
	local windowOpacity = config.Opacity or 1.0
	-- Clamp opacity between 0.1 and 1.0
	windowOpacity = math.max(0.1, math.min(1.0, windowOpacity))
	
	-- Extract AutoShow parameter (default true = automatically show window)
	local autoShow = config.AutoShow
	if autoShow == nil then
		autoShow = true -- Default to true if not specified
	end
	
	-- Extract Configuration parameters
	local configSaving = config.ConfigurationSaving or {}
	local configEnabled = configSaving.Enabled or false
	local configFileName = configSaving.FileName or config.Name or "DefaultConfig"
	local configFolderName = configSaving.FolderName or "EzUI"
	local configAutoSave = configSaving.AutoSave
	if configAutoSave == nil then
		configAutoSave = true -- Default to true if not specified
	end
	local configAutoLoad = configSaving.AutoLoad
	if configAutoLoad == nil then
		configAutoLoad = true -- Default to true if not specified
	end
	
	-- Set global configuration for components to access
	EzUI.Configuration.Enabled = configEnabled
	EzUI.Configuration.FileName = configFileName
	EzUI.Configuration.FolderName = configFolderName
	EzUI.Configuration.AutoSave = configAutoSave
	EzUI.Configuration.AutoLoad = configAutoLoad
	
	-- Get viewport size for dynamic scaling with proper initialization
	local function getViewportSize()
		local camera = workspace.CurrentCamera
		if not camera then
			-- Wait for camera to be available
			camera = workspace:WaitForChild("CurrentCamera", 5)
		end
		
		local viewportSize = camera.ViewportSize
		
		-- Check if viewport size is valid (not 1,1)
		if viewportSize.X <= 1 or viewportSize.Y <= 1 then
			-- Fallback to default resolution if viewport not ready
			viewportSize = Vector2.new(1366, 768)
			warn("EzUI: Using fallback viewport size:", viewportSize)
		end
		
		return viewportSize
	end
	
	-- Calculate dynamic window dimensions based on viewport
	local function calculateDynamicSize()
		local viewportSize = getViewportSize()

		local baseWidth = config.Width or (viewportSize.X * 0.7) -- 70% of screen width
		local baseHeight = config.Height or (viewportSize.Y * 0.4) -- 40% of screen height
		
		-- Apply resolution-based scaling
		local scaleMultiplier = 1
		if viewportSize.X >= 1920 then -- 1080p+
			scaleMultiplier = 1.2
		elseif viewportSize.X >= 1366 then -- 720p-1080p
			scaleMultiplier = 1.0
		elseif viewportSize.X >= 1024 then -- Tablet size
			scaleMultiplier = 0.9
		else -- Mobile/small screens
			scaleMultiplier = 0.8
		end
		
		-- Apply scaling and enforce minimum/maximum sizes
		local finalWidth = math.max(300, math.min(viewportSize.X * 0.8, baseWidth * scaleMultiplier))
		local finalHeight = math.max(200, math.min(viewportSize.Y * 0.8, baseHeight * scaleMultiplier))
		
		return finalWidth, finalHeight
	end
	
	local windowWidth, windowHeight = calculateDynamicSize()
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = config.Name or "MyWindow"
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	-- 🟦 Main window in the center of the screen
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
	frame.Position = UDim2.new(0.5, -windowWidth / 2, 0.5, -windowHeight / 2)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BackgroundTransparency = 1 - windowOpacity -- Convert opacity to transparency
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.ClipsDescendants = true -- ensure components do not go outside the window
	frame.ZIndex = 1 -- Base Z-index for window
	frame.Visible = autoShow -- Set initial visibility based on AutoShow parameter
	frame.Parent = screenGui

	-- ScrollingFrame for window content
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -100, 1, -30) -- already adjusted for tab panel
	scrollFrame.Position = UDim2.new(0, 100, 0, 30) -- already adjusted for tab panel
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.ClipsDescendants = false -- Allow dropdowns to show outside
	scrollFrame.ZIndex = 2 -- Above window frame
	scrollFrame.Parent = frame

	-- Vertical Tab Panel
	local tabPanel = Instance.new("Frame")
	tabPanel.Size = UDim2.new(0, 100, 1, -30)
	tabPanel.Position = UDim2.new(0, 0, 0, 30)
	tabPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	tabPanel.BackgroundTransparency = 1 - windowOpacity -- Match window opacity
	tabPanel.BorderSizePixel = 0
	tabPanel.ClipsDescendants = true
	tabPanel.ZIndex = 2 -- Above window frame
	tabPanel.Parent = frame

	-- ScrollingFrame for tab buttons
	local tabScrollFrame = Instance.new("ScrollingFrame")
	tabScrollFrame.Size = UDim2.new(1, 0, 1, 0)
	tabScrollFrame.Position = UDim2.new(0, 0, 0, 0)
	tabScrollFrame.BackgroundTransparency = 1
	tabScrollFrame.BorderSizePixel = 0
	tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScrollFrame.ScrollBarThickness = 6
	tabScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
	tabScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	tabScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	tabScrollFrame.ZIndex = 3 -- Above tab panel
	tabScrollFrame.Parent = tabPanel

	-- Container for tab buttons
	local tabButtonLayout = Instance.new("UIListLayout")
	tabButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabButtonLayout.Padding = UDim.new(0, 4)
	tabButtonLayout.Parent = tabScrollFrame

	-- Update canvas size when tab layout changes
	tabButtonLayout.Changed:Connect(function(property)
		if property == "AbsoluteContentSize" then
			tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, tabButtonLayout.AbsoluteContentSize.Y + 8)
		end
	end)

	-- Tab content container (Frame for each tab inside scrollFrame)
	local tabContents = {}
	local activeTab = nil
	local activeTabName = nil

	-- Resize handle in the bottom right corner
	local resizeHandle = Instance.new("ImageButton")
	resizeHandle.Size = UDim2.new(0, 16, 0, 16)
	resizeHandle.Position = UDim2.new(1, -16, 1, -16)
	resizeHandle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	resizeHandle.BorderSizePixel = 0
	resizeHandle.Image = "rbxassetid://16898613613"
	resizeHandle.ImageRectOffset = Vector2.new(820,196)
	resizeHandle.ImageRectSize = Vector2.new(48, 48) 
	resizeHandle.ZIndex = 27 -- Higher than header
	resizeHandle.Parent = frame
	
	-- Resize dragging variables
	local resizeDragging = false
	local resizeStartPos, resizeStartSize, resizeInput

	local UserInputService = game:GetService("UserInputService")

	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizeDragging = true
			resizeStartPos = input.Position
			resizeStartSize = frame.Size
			resizeInput = input
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizeDragging = false
				end
			end)
		end
	end)

	resizeHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			resizeInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == resizeInput and resizeDragging then
			local delta = input.Position - resizeStartPos
			-- Calculate dynamic minimum sizes based on current viewport
			local currentViewport = getViewportSize()
			local minWidth = math.max(250, currentViewport.X * 0.15) -- Minimum 15% of screen width
			local minHeight = math.max(150, currentViewport.Y * 0.2) -- Minimum 20% of screen height
			local maxWidth = currentViewport.X * 0.9 -- Maximum 90% of screen width
			local maxHeight = currentViewport.Y * 0.9 -- Maximum 90% of screen height
			
			local newWidth = math.max(minWidth, math.min(maxWidth, resizeStartSize.X.Offset + delta.X))
			local newHeight = math.max(minHeight, math.min(maxHeight, resizeStartSize.Y.Offset + delta.Y))
			frame.Size = UDim2.new(0, newWidth, 0, newHeight)
			-- Update window position to stay centered
			frame.Position = UDim2.new(0.5, -newWidth / 2, 0.5, -newHeight / 2)
			-- Update scrollFrame to match
			scrollFrame.Size = UDim2.new(1, -100, 1, -30)
			-- Update resize handle position
			resizeHandle.Position = UDim2.new(1, -16, 1, -16)
		end
	end)

	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	header.BackgroundTransparency = 1 - windowOpacity -- Match window opacity
	header.BorderSizePixel = 0
	header.ZIndex = 25 -- Higher than SelectBox dropdown
	header.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -100, 1, 0) -- Make room for resize, minimize and close buttons
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = config.Name or "My Window"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 16
	title.ZIndex = 26 -- Higher than header
	title.Parent = header

	-- Minimize Button
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
	minimizeBtn.Position = UDim2.new(1, -60, 0, 0) -- Positioned to the left of close button
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 170, 0)
	minimizeBtn.Text = "-"
	minimizeBtn.ZIndex = 26 -- Higher than header
	minimizeBtn.Parent = header

	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -30, 0, 0) -- Positioned at the far right
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextSize = 18
	closeBtn.ZIndex = 26 -- Higher than header
	closeBtn.Parent = header
	
	-- Close button hover effects
	closeBtn.MouseEnter:Connect(function()
		closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
	end)
	
	closeBtn.MouseLeave:Connect(function()
		closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end)

	-- 🟩 Floating button at the top left (below the Roblox logo button)
	local floatBtn = Instance.new("TextButton")
	floatBtn.Size = UDim2.new(0, 120, 0, 35)
	floatBtn.Position = UDim2.new(0, 10, 0, 45) -- offset downward to avoid Roblox logo collision
	floatBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 250)
	floatBtn.Text = "Open "..(config.Name or "UI")
	floatBtn.Visible = not autoShow -- Show floating button if window starts hidden
	floatBtn.ZIndex = 30 -- Very high Z-index for floating button
	floatBtn.Parent = screenGui

	-- Service & drag variables
	local UserInputService = game:GetService("UserInputService")
	local dragging, dragInput, dragStart, startPos
	local currentTarget

	local function updateDrag(input)
		if currentTarget then
			local delta = input.Position - dragStart
			currentTarget.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end

	-- 🎯 Drag header (move window)
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			currentTarget = frame

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					currentTarget = nil
				end
			end)
		end
	end)

	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	-- 🎯 Drag floating button
	floatBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = floatBtn.Position
			currentTarget = floatBtn

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					currentTarget = nil
				end
			end)
		end
	end)

	floatBtn.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	-- Global listener
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			updateDrag(input)
		end
	end)

	-- Minimize Button
	minimizeBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
		floatBtn.Visible = true
	end)

	floatBtn.MouseButton1Click:Connect(function()
		frame.Visible = true
		floatBtn.Visible = false
	end)

	-- Public API
	local api = {}
	local currentY = 10 -- Initial Y position inside the active tab content
	local currentTabContent = nil

	-- Fungsi untuk mengupdate ukuran window secara otomatis
	function api:UpdateWindowSize()
		-- Update CanvasSize dari currentTabContent agar scroll vertical aktif
		if currentTabContent then
			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY + 10)
		end
	end

	-- API untuk tab
	function api:AddTab(config)
		-- Support both old string parameter and new config parameter for backward compatibility
		local tabName, tabIcon, tabVisible, tabCallback
		
		if type(config) == "string" then
			-- Old format: api:AddTab("Tab Name")
			tabName = config
			tabIcon = nil
			tabVisible = true
			tabCallback = nil
		else
			-- New format: api:AddTab({Name = "Tab Name", Icon = "📁", Visible = true, Callback = function() end})
			tabName = config.Name or config.Title or "New Tab"
			tabIcon = config.Icon or nil
			tabVisible = config.Visible ~= nil and config.Visible or true
			tabCallback = config.Callback or nil
		end
		
		-- Tab button (container)
		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, -6, 0, 32) -- -6 untuk memberikan ruang scroll bar
		tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		tabBtn.Text = "" -- No text, we'll use separate labels
		tabBtn.BorderSizePixel = 0
		tabBtn.ZIndex = 4 -- Above tab panel
		tabBtn.Visible = tabVisible
		tabBtn.Parent = tabScrollFrame
		
		-- Icon label (left aligned)
		local iconLabel = Instance.new("TextLabel")
		iconLabel.Size = UDim2.new(0, 30, 1, 0)
		iconLabel.Position = UDim2.new(0, 5, 0, 0)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Text = tabIcon or ""
		iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		iconLabel.Font = Enum.Font.SourceSansBold
		iconLabel.TextSize = 15
		iconLabel.TextXAlignment = Enum.TextXAlignment.Left
		iconLabel.ZIndex = 5
		iconLabel.Parent = tabBtn
		
		-- Title label (alignment depends on icon presence)
		local titleLabel = Instance.new("TextLabel")
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = tabName
		titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLabel.Font = Enum.Font.SourceSansBold
		titleLabel.TextSize = 15
		titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		titleLabel.ZIndex = 5
		titleLabel.Parent = tabBtn
		
		-- Function to update title alignment based on icon presence
		local function updateTitleAlignment()
			if tabIcon and tabIcon ~= "" then
				-- Has icon: title right-aligned, positioned after icon
				titleLabel.Size = UDim2.new(1, -40, 1, 0) -- Leave space for icon
				titleLabel.Position = UDim2.new(0, 35, 0, 0)
				titleLabel.TextXAlignment = Enum.TextXAlignment.Right
				iconLabel.Visible = true
			else
				-- No icon: title left-aligned, full width
				titleLabel.Size = UDim2.new(1, -10, 1, 0) -- Full width with padding
				titleLabel.Position = UDim2.new(0, 5, 0, 0)
				titleLabel.TextXAlignment = Enum.TextXAlignment.Left
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
		tabContent.ClipsDescendants = false -- Allow SelectBox dropdowns to show
		tabContent.ZIndex = 2 -- Above scroll frame
		tabContent.Parent = scrollFrame
		tabContents[tabName] = tabContent

		-- Tab-specific Y position tracking
		local tabCurrentY = 10

		-- Centralized SelectBox component that can be used by both tab and accordion APIs
		local function createSelectBox(config, parentContainer, currentY, updateSizeFunction, animateFunction, isExpanded, isForAccordion)
			-- Default config
			local rawOptions = config.Options or {"Option 1", "Option 2", "Option 3"}
			local placeholder = config.Placeholder or "Select option..."
			local multiSelect = config.MultiSelect or false
			local callback = config.Callback or function() end
			local onDropdownOpen = config.OnDropdownOpen or function() end
			local flag = config.Flag
			
			-- Normalize options to object format {text = "", value = ""}
			local options = {}
			for i, option in ipairs(rawOptions) do
				if type(option) == "string" then
					-- Convert string to object format
					table.insert(options, {text = option, value = option})
				elseif type(option) == "table" and option.text and option.value then
					-- Already in object format
					table.insert(options, {text = option.text, value = option.value})
				else
					warn("SelectBox: Invalid option format at index " .. i .. ". Expected string or {text, value} object.")
				end
			end
			
			-- Selected values storage (stores actual values, not display text)
			local selectedValues = {}
			
			-- Set initial values from flag if exists
			if flag and EzUI.Flags[flag] ~= nil then
				if multiSelect then
					-- For multiselect, flag should be an array
					selectedValues = EzUI.Flags[flag] or {}
				else
					-- For single select, flag should be a single value
					selectedValues = {EzUI.Flags[flag]}
				end
			end
			
			local isOpen = false
			local preventAutoClose = false -- Flag to prevent auto-closing during option clicks
			
			-- Main SelectBox container
			local selectContainer = Instance.new("Frame")
			if isForAccordion then
				selectContainer.Size = UDim2.new(1, 0, 0, 25) -- Full width for accordion (padding handles spacing)
				selectContainer.Position = UDim2.new(0, 0, 0, currentY)
			else
				selectContainer.Size = UDim2.new(1, -20, 0, 25) -- Standard size for tab
				selectContainer.Position = UDim2.new(0, 10, 0, currentY)
				-- Mark this component's start position for accordion tracking
				selectContainer:SetAttribute("ComponentStartY", currentY)
			end
			selectContainer.BackgroundTransparency = 1
			selectContainer.ClipsDescendants = false -- Important: allow dropdown to show outside
			selectContainer.ZIndex = isForAccordion and 6 or 3 -- Higher Z-index for accordion
			selectContainer.Parent = parentContainer
			
			-- SelectBox button (main clickable area)
			local selectButton = Instance.new("TextButton")
			selectButton.Size = UDim2.new(1, -25, 1, 0) -- Leave space for arrow
			selectButton.Position = UDim2.new(0, 0, 0, 0)
			selectButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			selectButton.BorderColor3 = Color3.fromRGB(180, 180, 180)
			selectButton.BorderSizePixel = 2
			selectButton.Text = "  " .. placeholder
			selectButton.TextColor3 = Color3.fromRGB(200, 200, 200)
			selectButton.TextXAlignment = Enum.TextXAlignment.Left
			selectButton.Font = Enum.Font.SourceSans
			selectButton.TextSize = isForAccordion and 12 or 14
			selectButton.ZIndex = isForAccordion and 7 or 4
			selectButton.Parent = selectContainer
			
			-- Dropdown arrow (clickable)
			local arrow = Instance.new("TextButton")
			arrow.Size = UDim2.new(0, 25, 1, 0)
			arrow.Position = UDim2.new(1, -25, 0, 0)
			arrow.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			arrow.BorderColor3 = Color3.fromRGB(180, 180, 180)
			arrow.BorderSizePixel = 2
			arrow.Text = "▼"
			arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
			arrow.TextXAlignment = Enum.TextXAlignment.Center
			arrow.Font = Enum.Font.SourceSans
			arrow.TextSize = 10
			arrow.ZIndex = isForAccordion and 7 or 4
			arrow.Parent = selectContainer
			
			-- Dropdown list container
			local dropdownHeight = isForAccordion and math.min(#options * 25 + 30, 150) or math.min(#options * 30 + 30, 200)
			local dropdownFrame = Instance.new("ScrollingFrame")
			dropdownFrame.Size = UDim2.new(1, 0, 0, dropdownHeight)
			dropdownFrame.Position = UDim2.new(0, 0, 1, 3)
			dropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			dropdownFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
			dropdownFrame.BorderSizePixel = 2
			dropdownFrame.Visible = false
			dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, isForAccordion and (#options * 25 + 30) or (#options * 30 + 30))
			dropdownFrame.ScrollBarThickness = 6
			dropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
			dropdownFrame.ZIndex = 25 -- Very high Z-index to appear above everything
			dropdownFrame.ClipsDescendants = true
			dropdownFrame.Active = true
			dropdownFrame.Parent = screenGui -- Parent directly to ScreenGui to avoid clipping
			
			-- Search box
			local searchBox = Instance.new("TextBox")
			searchBox.Size = UDim2.new(1, -10, 0, 20)
			searchBox.Position = UDim2.new(0, 5, 0, 5)
			searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			searchBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
			searchBox.BorderSizePixel = 1
			searchBox.Text = ""
			searchBox.PlaceholderText = "Search options..."
			searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			searchBox.Font = Enum.Font.Gotham
			searchBox.TextSize = 10
			searchBox.ZIndex = 26 -- Higher than dropdown frame
			searchBox.ClearTextOnFocus = false
			searchBox.Parent = dropdownFrame
			
			-- Container for option items (below search box)
			local optionsContainer = Instance.new("Frame")
			optionsContainer.Size = UDim2.new(1, 0, 1, -30)
			optionsContainer.Position = UDim2.new(0, 0, 0, 30)
			optionsContainer.BackgroundTransparency = 1
			optionsContainer.ZIndex = 26 -- Same as search box
			optionsContainer.Parent = dropdownFrame
			
			-- List layout for dropdown items
			local listLayout = Instance.new("UIListLayout")
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Parent = optionsContainer
			
			-- Function to update display text
			local function updateDisplayText()
				if #selectedValues == 0 then
					selectButton.Text = "  " .. placeholder
					selectButton.TextColor3 = Color3.fromRGB(200, 200, 200)
				elseif multiSelect then
					if #selectedValues == 1 then
						-- Find the display text for the selected value
						local displayText = selectedValues[1]
						for _, option in ipairs(options) do
							if option.value == selectedValues[1] then
								displayText = option.text
								break
							end
						end
						selectButton.Text = "  " .. displayText
					elseif #selectedValues == 0 then
						selectButton.Text = "  None"
					else
						selectButton.Text = "  " .. #selectedValues .. " items selected"
					end
					selectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				else
					-- Single select - find display text for the selected value
					local displayText = selectedValues[1]
					for _, option in ipairs(options) do
						if option.value == selectedValues[1] then
							displayText = option.text
							break
						end
					end
					selectButton.Text = "  " .. displayText
					selectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
			end
			
			-- Function to calculate dropdown position
			local function calculateDropdownPosition()
				-- Get absolute position of selectContainer
				local absolutePos = selectContainer.AbsolutePosition
				local absoluteSize = selectContainer.AbsoluteSize
				local viewportSize = getViewportSize()
				
				-- Calculate dropdown dimensions
				local dropdownHeight = dropdownFrame.Size.Y.Offset
				local dropdownWidth = absoluteSize.X
				
				-- Check if there's enough space below
				local spaceBelow = viewportSize.Y - (absolutePos.Y + absoluteSize.Y)
				local spaceAbove = absolutePos.Y
				
				local finalPosition
				
				if spaceBelow >= dropdownHeight + 10 then
					-- Show dropdown below
					finalPosition = UDim2.new(0, absolutePos.X, 0, absolutePos.Y + absoluteSize.Y + 3)
				elseif spaceAbove >= dropdownHeight + 10 then
					-- Show dropdown above
					finalPosition = UDim2.new(0, absolutePos.X, 0, absolutePos.Y - dropdownHeight - 3)
				else
					-- Show below anyway if both spaces are insufficient
					finalPosition = UDim2.new(0, absolutePos.X, 0, absolutePos.Y + absoluteSize.Y + 3)
				end
				
				dropdownFrame.Position = finalPosition
				dropdownFrame.Size = UDim2.new(0, dropdownWidth, 0, dropdownHeight)
			end
			
			-- Function to refresh options display
			local function refreshOptionsDisplay()
				-- Clear existing options
				for _, child in pairs(optionsContainer:GetChildren()) do
					if child:IsA("TextButton") then
						child:Destroy()
					end
				end
				
				-- Recreate options with new data
				for i, option in ipairs(options) do
					local optionHeight = isForAccordion and 25 or 30
					local optionButton = Instance.new("TextButton")
					optionButton.Size = UDim2.new(1, -10, 0, optionHeight)
					optionButton.Position = UDim2.new(0, 5, 0, (i-1) * optionHeight)
					optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					optionButton.BorderSizePixel = 0
					optionButton.Text = "  " .. option.text
					optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
					optionButton.TextXAlignment = Enum.TextXAlignment.Left
					optionButton.Font = Enum.Font.SourceSans
					optionButton.TextSize = isForAccordion and 10 or 12
					optionButton.ZIndex = 27
					optionButton.Parent = optionsContainer
					
					-- Checkmark for multi-select
					local checkmark = Instance.new("TextLabel")
					checkmark.Size = UDim2.new(0, 20, 1, 0)
					checkmark.Position = UDim2.new(1, -20, 0, 0)
					checkmark.BackgroundTransparency = 1
					checkmark.Text = ""
					checkmark.TextColor3 = Color3.fromRGB(100, 255, 100)
					checkmark.TextXAlignment = Enum.TextXAlignment.Center
					checkmark.Font = Enum.Font.SourceSansBold
					checkmark.TextSize = 12
					checkmark.ZIndex = 28
					checkmark.Parent = optionButton
					checkmark.Visible = multiSelect
					
					-- Check if this option is already selected
					local isSelected = false
					for _, value in ipairs(selectedValues) do
						if value == option.value then
							isSelected = true
							break
						end
					end
					
					if isSelected then
						checkmark.Text = "✓"
						optionButton.BackgroundColor3 = Color3.fromRGB(70, 120, 70)
					end
					
					optionButton.MouseButton1Click:Connect(function()
						preventAutoClose = true -- Prevent auto-close during processing
						
						if multiSelect then
							-- Toggle selection for multi-select
							local isCurrentlySelected = false
							local indexToRemove = nil
							for j, value in ipairs(selectedValues) do
								if value == option.value then
									isCurrentlySelected = true
									indexToRemove = j
									break
								end
							end
							
							if isCurrentlySelected then
								table.remove(selectedValues, indexToRemove)
								checkmark.Text = ""
								optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
							else
								table.insert(selectedValues, option.value)
								checkmark.Text = "✓"
								optionButton.BackgroundColor3 = Color3.fromRGB(70, 120, 70)
							end
						else
							-- Single select
							selectedValues = {option.value}
							updateDisplayText()
							isOpen = false
							dropdownFrame.Visible = false
							arrow.Text = "▼"
						end
						
						updateDisplayText()
						
						-- Save to flag if specified
						if flag then
							if multiSelect then
								EzUI.Flags[flag] = selectedValues
							else
								EzUI.Flags[flag] = selectedValues[1] or nil
							end
							if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
								saveConfiguration(EzUI.Configuration.FileName)
							end
						end
						
						-- Call callback
						if callback then
							callback(selectedValues, option.value)
						end
						
						preventAutoClose = false -- Re-enable auto-close
					end)
					
					optionButton.MouseEnter:Connect(function()
						if optionButton.BackgroundColor3 ~= Color3.fromRGB(70, 120, 70) then
							optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
						end
					end)
					
					optionButton.MouseLeave:Connect(function()
						local isCurrentlySelected = false
						for _, val in ipairs(selectedValues) do
							if val == option.value then
								isCurrentlySelected = true
								break
							end
						end
						
						if not isCurrentlySelected then
							optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
						end
					end)
				end
				
				-- Update canvas size
				local optionHeight = isForAccordion and 25 or 30
				dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #options * optionHeight + 30)
			end
			
			local function toggleDropdown()
				isOpen = not isOpen
				dropdownFrame.Visible = isOpen
				
				-- Update arrow direction
				arrow.Text = isOpen and "▲" or "▼"
				
				-- Call OnDropdownOpen callback when dropdown is opened
				if isOpen and onDropdownOpen then
					onDropdownOpen(options, function(newOptions)
						-- Callback function to update options
						if newOptions and type(newOptions) == "table" then
							-- Update options dengan format baru
							rawOptions = newOptions
							options = {}
							for i, option in ipairs(rawOptions) do
								if type(option) == "string" then
									table.insert(options, {text = option, value = option})
								elseif type(option) == "table" and option.text and option.value then
									table.insert(options, {text = option.text, value = option.value})
								end
							end
							
							-- Refresh tampilan options
							refreshOptionsDisplay()
						end
					end)
				end
				
				-- Only adjust dropdown size, keep container size fixed
				if isOpen then
					local dropdownHeight = isForAccordion and math.min(#options * 25 + 30, 150) or math.min(#options * 30 + 30, 200)
					dropdownFrame.Size = UDim2.new(0, selectContainer.AbsoluteSize.X, 0, dropdownHeight)
					
					-- Calculate optimal position
					calculateDropdownPosition()
					
					-- Bring dropdown to front
					dropdownFrame.ZIndex = 25
					searchBox.ZIndex = 26
					optionsContainer.ZIndex = 26
					for _, child in pairs(optionsContainer:GetChildren()) do
						if child:IsA("TextButton") then
							child.ZIndex = 27
							local checkmark = child:FindFirstChild("TextLabel")
							if checkmark then
								checkmark.ZIndex = 28
							end
						end
					end
				end
			end
			
			-- Create dropdown options
			refreshOptionsDisplay()
			
			-- Filter options based on search
			local function filterOptions(searchText)
				local visibleCount = 0
				local optionHeight = isForAccordion and 25 or 30
				for i, child in ipairs(optionsContainer:GetChildren()) do
					if child:IsA("TextButton") then
						local option = options[i]
						if option and string.find(string.lower(option.text), string.lower(searchText), 1, true) then
							child.Visible = true
							child.Position = UDim2.new(0, 5, 0, visibleCount * optionHeight)
							visibleCount = visibleCount + 1
						else
							child.Visible = false
						end
					end
				end
				
				-- Update canvas size
				dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, visibleCount * optionHeight + 30)
			end
			
			-- Search functionality
			searchBox.Changed:Connect(function(property)
				if property == "Text" then
					filterOptions(searchBox.Text)
				end
			end)
			
			-- Wrapper to reset search when dropdown closes
			local originalToggleDropdown = toggleDropdown
			toggleDropdown = function()
				originalToggleDropdown()
				if not isOpen then
					searchBox.Text = ""
					filterOptions("") -- Show all options when reopening
				end
			end
			
			-- SelectBox button click handler
			selectButton.MouseButton1Click:Connect(function()
				toggleDropdown()
			end)
			
			-- Arrow click handler (same functionality as selectButton)
			arrow.MouseButton1Click:Connect(function()
				toggleDropdown()
			end)
			
			-- Create SelectBox API
			local selectBoxAPI = {
				GetSelected = function()
					return selectedValues
				end,
				SetSelected = function(values)
					selectedValues = values or {}
					updateDisplayText()
					
					-- Save to flag if specified
					if flag then
						if multiSelect then
							EzUI.Flags[flag] = selectedValues
						else
							EzUI.Flags[flag] = selectedValues[1] or nil
						end
						if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
							saveConfiguration(EzUI.Configuration.FileName)
						end
					end
					
					-- Update visual state of options
					for _, child in pairs(optionsContainer:GetChildren()) do
						if child:IsA("TextButton") then
							local childOption = nil
							local childIndex = nil
							for i, option in ipairs(options) do
								local optionChild = optionsContainer:GetChildren()[i]
								if optionChild == child then
									childOption = option
									childIndex = i
									break
								end
							end
							
							local childCheckmark = child:FindFirstChild("TextLabel")
							if childCheckmark and childOption then
								local isSelected = false
								for _, val in ipairs(selectedValues) do
									if val == childOption.value then
										isSelected = true
										break
									end
								end
								
								childCheckmark.Text = isSelected and "✓" or ""
								child.BackgroundColor3 = isSelected and Color3.fromRGB(70, 120, 70) or Color3.fromRGB(50, 50, 50)
							end
						end
					end
				end,
				Clear = function()
					selectedValues = {}
					updateDisplayText()
					
					-- Save to flag if specified
					if flag then
						if multiSelect then
							EzUI.Flags[flag] = {}
						else
							EzUI.Flags[flag] = nil
						end
						if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
							saveConfiguration(EzUI.Configuration.FileName)
						end
					end
					
					-- Clear visual state
					for _, child in pairs(optionsContainer:GetChildren()) do
						if child:IsA("TextButton") then
							local checkmark = child:FindFirstChild("TextLabel")
							if checkmark then
								checkmark.Text = ""
							end
							child.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
						end
					end
				end,
				Refresh = function(newOptions)
					-- Clear existing options
					for _, child in pairs(optionsContainer:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end
					
					-- Update options
					rawOptions = newOptions
					options = {}
					for i, option in ipairs(rawOptions) do
						if type(option) == "string" then
							table.insert(options, {text = option, value = option})
						elseif type(option) == "table" and option.text and option.value then
							table.insert(options, {text = option.text, value = option.value})
						end
					end
					
					-- Recreate options (similar to above)
					for i, option in ipairs(options) do
						local optionHeight = isForAccordion and 25 or 30
						local optionButton = Instance.new("TextButton")
						optionButton.Size = UDim2.new(1, -10, 0, optionHeight)
						optionButton.Position = UDim2.new(0, 5, 0, (i-1) * optionHeight)
						optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
						optionButton.BorderSizePixel = 0
						optionButton.Text = "  " .. option.text
						optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
						optionButton.TextXAlignment = Enum.TextXAlignment.Left
						optionButton.Font = Enum.Font.SourceSans
						optionButton.TextSize = isForAccordion and 10 or 12
						optionButton.ZIndex = 27
						optionButton.Parent = optionsContainer
						
						local checkmark = Instance.new("TextLabel")
						checkmark.Size = UDim2.new(0, 20, 1, 0)
						checkmark.Position = UDim2.new(1, -20, 0, 0)
						checkmark.BackgroundTransparency = 1
						checkmark.Text = ""
						checkmark.TextColor3 = Color3.fromRGB(100, 255, 100)
						checkmark.TextXAlignment = Enum.TextXAlignment.Center
						checkmark.Font = Enum.Font.SourceSansBold
						checkmark.TextSize = 12
						checkmark.ZIndex = 28
						checkmark.Parent = optionButton
						checkmark.Visible = multiSelect
						
						optionButton.MouseButton1Click:Connect(function()
							preventAutoClose = true
							
							if multiSelect then
								local isSelected = false
								local indexToRemove = nil
								for j, value in ipairs(selectedValues) do
									if value == option.value then
										isSelected = true
										indexToRemove = j
										break
									end
								end
								
								if isSelected then
									table.remove(selectedValues, indexToRemove)
									checkmark.Text = ""
									optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
								else
									table.insert(selectedValues, option.value)
									checkmark.Text = "✓"
									optionButton.BackgroundColor3 = Color3.fromRGB(70, 120, 70)
								end
							else
								selectedValues = {option.value}
								updateDisplayText()
								isOpen = false
								dropdownFrame.Visible = false
								arrow.Text = "▼"
							end
							
							updateDisplayText()
							
							if callback then
								callback(selectedValues, option.value)
							end
							
							-- Save to flag if specified
							if flag then
								if multiSelect then
									EzUI.Flags[flag] = selectedValues
								else
									EzUI.Flags[flag] = selectedValues[1] or nil
								end
								if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
									saveConfiguration(EzUI.Configuration.FileName)
								end
							end
							
							if not multiSelect and not preventAutoClose then
								spawn(function()
									wait(0.1)
									isOpen = false
									dropdownFrame.Visible = false
									arrow.Text = "▼"
								end)
							end
							
							preventAutoClose = false
						end)
						
						optionButton.MouseEnter:Connect(function()
							if optionButton.BackgroundColor3 ~= Color3.fromRGB(70, 120, 70) then
								optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
							end
						end)
						
						optionButton.MouseLeave:Connect(function()
							local isSelected = false
							for _, val in ipairs(selectedValues) do
								if val == option.value then
									isSelected = true
									break
								end
							end
							
							if not isSelected then
								optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
							end
						end)
					end
					
					-- Update canvas size
					local optionHeight = isForAccordion and 25 or 30
					dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #options * optionHeight + 30)
					
					-- Clear selected values
					selectedValues = {}
					updateDisplayText()
				end,
				-- Set function for configuration loading
				Set = function(values)
					selectedValues = values or {}
					updateDisplayText()
				end
			}
			
			-- Register component for flag-based updates
			registerComponent(flag, selectBoxAPI)
			
			-- Return SelectBox API
			return selectBoxAPI
		end

		-- Centralized Label component that can be used by both tab and accordion APIs
		local function createLabel(text, parentContainer, currentY, updateSizeFunction, animateFunction, isExpanded, isForAccordion)
			local label = Instance.new("TextLabel")
			if isForAccordion then
				label.Size = UDim2.new(1, 0, 0, 25) -- Full width for accordion (padding handles spacing)
				label.Position = UDim2.new(0, 0, 0, currentY)
				label.TextSize = 14
				label.ZIndex = 5
			else
				label.Size = UDim2.new(1, -20, 0, 30) -- Standard size for tab
				label.Position = UDim2.new(0, 10, 0, currentY)
				label.TextSize = 16
				label.ZIndex = 3
				-- Mark this component's start position for accordion tracking
				label:SetAttribute("ComponentStartY", currentY)
			end
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Font = Enum.Font.SourceSans
			label.Parent = parentContainer
			
			return label
		end

		-- Centralized Button component that can be used by both tab and accordion APIs
		local function createButton(text, callback, parentContainer, currentY, updateSizeFunction, animateFunction, isExpanded, isForAccordion)
			local button = Instance.new("TextButton")
			if isForAccordion then
				button.Size = UDim2.new(0, 100, 0, 25)
				button.Position = UDim2.new(0, 0, 0, currentY)
				button.BorderColor3 = Color3.fromRGB(255, 255, 255)
				button.BorderSizePixel = 2
				button.TextSize = 12
				button.ZIndex = 5
				
				-- Round corners for accordion button
				local buttonCorner = Instance.new("UICorner")
				buttonCorner.CornerRadius = UDim.new(0, 4)
				buttonCorner.Parent = button
				
				-- Button hover effects for accordion
				button.MouseEnter:Connect(function()
					button.BackgroundColor3 = Color3.fromRGB(120, 170, 255)
				end)
				
				button.MouseLeave:Connect(function()
					button.BackgroundColor3 = Color3.fromRGB(100, 150, 250)
				end)
			else
				button.Size = UDim2.new(0, 120, 0, 30)
				button.Position = UDim2.new(0, 10, 0, currentY)
				button.BorderSizePixel = 0
				button.TextSize = 14
				button.ZIndex = 3
				-- Mark this component's start position for accordion tracking
				button:SetAttribute("ComponentStartY", currentY)
			end
			button.BackgroundColor3 = Color3.fromRGB(100, 150, 250)
			button.Text = text
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.Font = Enum.Font.SourceSans
			button.Parent = parentContainer

			if callback then
				button.MouseButton1Click:Connect(callback)
			end
			
			return button
		end

		-- Centralized Separator component that can be used by both tab and accordion APIs
		local function createSeparator(parentContainer, currentY, updateSizeFunction, animateFunction, isExpanded, isForAccordion)
			local separator = Instance.new("Frame")
			if isForAccordion then
				separator.Size = UDim2.new(1, 0, 0, 1) -- Full width for accordion (padding handles spacing)
				separator.Position = UDim2.new(0, 0, 0, currentY + 5)
				separator.ZIndex = 5
			else
				separator.Size = UDim2.new(1, -20, 0, 1) -- Standard size for tab
				separator.Position = UDim2.new(0, 10, 0, currentY + 5)
				separator.ZIndex = 3
				-- Mark this component's start position for accordion tracking
				separator:SetAttribute("ComponentStartY", currentY)
			end
			separator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			separator.BorderSizePixel = 0
			separator.Parent = parentContainer
			
			return separator
		end

		-- Centralized Toggle component that can be used by both tab and accordion APIs
		local function createToggle(config, parentContainer, currentY, updateSizeFunction, animateFunction, isExpanded, isForAccordion)
			-- Default config
			local text = config.Name or config.Text or "Toggle"
			local defaultValue = config.Default or false
			local callback = config.Callback or function() end
			local flag = config.Flag -- Optional flag for configuration saving
			
			-- Toggle state
			local isToggled = defaultValue
			
			-- Set initial value from flag if exists
			if flag and EzUI.Flags[flag] ~= nil then
				isToggled = EzUI.Flags[flag]
			end
			
			-- Main toggle container
			local toggleContainer = Instance.new("Frame")
			if isForAccordion then
				toggleContainer.Size = UDim2.new(1, -10, 0, 25) -- Compact size for accordion
				toggleContainer.Position = UDim2.new(0, 5, 0, currentY)
				toggleContainer.ZIndex = 6
			else
				toggleContainer.Size = UDim2.new(1, -20, 0, 30) -- Standard size for tab
				toggleContainer.Position = UDim2.new(0, 10, 0, currentY)
				toggleContainer.ZIndex = 3
				-- Mark this component's start position for accordion tracking
				toggleContainer:SetAttribute("ComponentStartY", currentY)
			end
			toggleContainer.BackgroundTransparency = 1
			toggleContainer.Parent = parentContainer
			
			-- Toggle label
			local toggleLabel = Instance.new("TextLabel")
			if isForAccordion then
				toggleLabel.Size = UDim2.new(1, -45, 1, 0)
				toggleLabel.TextSize = 12 -- Smaller text for accordion
				toggleLabel.ZIndex = 7
			else
				toggleLabel.Size = UDim2.new(1, -60, 1, 0)
				toggleLabel.TextSize = 16 -- Normal text for tab
				toggleLabel.ZIndex = 4
			end
			toggleLabel.Position = UDim2.new(0, 0, 0, 0)
			toggleLabel.BackgroundTransparency = 1
			toggleLabel.Text = text
			toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
			toggleLabel.Font = Enum.Font.SourceSans
			toggleLabel.Parent = toggleContainer
			
			-- Toggle switch background
			local toggleBg = Instance.new("Frame")
			if isForAccordion then
				toggleBg.Size = UDim2.new(0, 40, 0, 20) -- Smaller for accordion
				toggleBg.Position = UDim2.new(1, -40, 0.5, -10)
				toggleBg.ZIndex = 7
			else
				toggleBg.Size = UDim2.new(0, 50, 0, 24) -- Standard for tab
				toggleBg.Position = UDim2.new(1, -50, 0.5, -12)
				toggleBg.ZIndex = 4
			end
			toggleBg.BackgroundColor3 = isToggled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
			toggleBg.BorderSizePixel = 0
			toggleBg.Parent = toggleContainer
			
			-- Round corners for toggle background
			local toggleBgCorner = Instance.new("UICorner")
			toggleBgCorner.CornerRadius = UDim.new(0, isForAccordion and 10 or 12)
			toggleBgCorner.Parent = toggleBg
			
			-- Toggle switch button (circle)
			local toggleButton = Instance.new("TextButton")
			if isForAccordion then
				toggleButton.Size = UDim2.new(0, 16, 0, 16) -- Smaller for accordion
				toggleButton.Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
				toggleButton.ZIndex = 8
			else
				toggleButton.Size = UDim2.new(0, 20, 0, 20) -- Standard for tab
				toggleButton.Position = isToggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
				toggleButton.ZIndex = 5
			end
			toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggleButton.BorderSizePixel = 0
			toggleButton.Text = ""
			toggleButton.Parent = toggleBg
			
			-- Round corners for toggle button
			local toggleButtonCorner = Instance.new("UICorner")
			toggleButtonCorner.CornerRadius = UDim.new(0, isForAccordion and 8 or 10)
			toggleButtonCorner.Parent = toggleButton
			
			-- Function to update toggle appearance
			local function updateToggleAppearance()
				local targetBgColor = isToggled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
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
			toggleButton.MouseButton1Click:Connect(function()
				isToggled = not isToggled
				updateToggleAppearance()
				
				-- Save to flag if specified
				if flag then
					EzUI.Flags[flag] = isToggled
					if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
						saveConfiguration(EzUI.Configuration.FileName)
					end
				end
				
				-- Call user callback
				local success, errorMsg = pcall(function()
					callback(isToggled)
				end)
				
				if not success then
					warn("Toggle callback error:", errorMsg)
				end
			end)
			
			-- Also allow clicking the background to toggle
			toggleBg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isToggled = not isToggled
					updateToggleAppearance()
					
					-- Save to flag if specified
					if flag then
						EzUI.Flags[flag] = isToggled
						if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
							saveConfiguration(EzUI.Configuration.FileName)
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
			end)
			
			-- Hover effects
			toggleButton.MouseEnter:Connect(function()
				toggleButton.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
			end)
			
			toggleButton.MouseLeave:Connect(function()
				toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			end)
			
			-- Return Toggle API
			local toggleAPI = {}
			toggleAPI.SetValue = function(newValue)
				if type(newValue) == "boolean" and newValue ~= isToggled then
					isToggled = newValue
					updateToggleAppearance()
					
					-- Save to flag if specified
					if flag then
						EzUI.Flags[flag] = isToggled
						if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
							saveConfiguration(EzUI.Configuration.FileName)
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
			
			-- Set function for configuration loading
			toggleAPI.Set = toggleAPI.SetValue
			
			-- Register component for flag-based updates
			registerComponent(flag, toggleAPI)
			
			return toggleAPI
		end

		-- Centralized TextBox component that can be used by both tab and accordion APIs
		local function createTextBox(config, parentContainer, currentY, updateSizeFunction, animateFunction, isExpanded, isForAccordion)
			-- Default config
			local placeholder = config.Placeholder or "Enter text..."
			local defaultText = config.Default or ""
			local callback = config.Callback or function() end
			local maxLength = config.MaxLength or 100
			local multiline = config.Multiline or false
			local flag = config.Flag
			
			-- TextBox state
			local currentText = defaultText
			
			-- Set initial value from flag if exists
			if flag and EzUI.Flags[flag] ~= nil then
				currentText = EzUI.Flags[flag]
				defaultText = currentText
			end
			
			-- Main textbox container
			local textBoxContainer = Instance.new("Frame")
			if isForAccordion then
				textBoxContainer.Size = UDim2.new(1, -10, 0, multiline and 60 or 25) -- Compact for accordion
				textBoxContainer.Position = UDim2.new(0, 5, 0, currentY)
				textBoxContainer.ZIndex = 6
			else
				textBoxContainer.Size = UDim2.new(1, -20, 0, multiline and 80 or 30) -- Standard for tab
				textBoxContainer.Position = UDim2.new(0, 10, 0, currentY)
				textBoxContainer.ZIndex = 3
				-- Mark this component's start position for accordion tracking
				textBoxContainer:SetAttribute("ComponentStartY", currentY)
			end
			textBoxContainer.BackgroundTransparency = 1
			textBoxContainer.Parent = parentContainer
			
			-- TextBox input
			local textBox = Instance.new("TextBox")
			textBox.Size = UDim2.new(1, 0, 1, 0)
			textBox.Position = UDim2.new(0, 0, 0, 0)
			textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			textBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
			textBox.BorderSizePixel = 1
			textBox.Text = defaultText
			textBox.PlaceholderText = placeholder
			textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			textBox.Font = Enum.Font.SourceSans
			textBox.TextSize = isForAccordion and 12 or 14 -- Smaller text for accordion
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
				charCounter.TextColor3 = Color3.fromRGB(150, 150, 150)
				charCounter.Font = Enum.Font.SourceSans
				charCounter.TextSize = isForAccordion and 10 or 12 -- Smaller for accordion
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
						charCounter.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red when at limit
					elseif textLength >= maxLength * 0.8 then
						charCounter.TextColor3 = Color3.fromRGB(255, 200, 100) -- Orange when close to limit
					else
						charCounter.TextColor3 = Color3.fromRGB(150, 150, 150) -- Gray when safe
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
					
					-- Save to flag if specified
					if flag then
						EzUI.Flags[flag] = currentText
						if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
							saveConfiguration(EzUI.Configuration.FileName)
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
				textBox.BorderColor3 = Color3.fromRGB(100, 150, 250)
			end)
			
			textBox.FocusLost:Connect(function()
				textBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
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
					-- Save to flag if specified
					if flag then
						EzUI.Flags[flag] = currentText
						if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
							saveConfiguration(EzUI.Configuration.FileName)
						end
					end
				end,
				Clear = function()
					textBox.Text = ""
					currentText = ""
					updateCharCounter()
					-- Save to flag if specified
					if flag then
						EzUI.Flags[flag] = currentText
						if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
							saveConfiguration(EzUI.Configuration.FileName)
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
				-- Set function for configuration loading
				Set = function(newText)
					textBox.Text = tostring(newText or "")
					currentText = textBox.Text
					updateCharCounter()
				end
			}
			
			-- Register component for flag-based updates
			registerComponent(flag, textBoxAPI)
			
			return textBoxAPI
		end

		-- Centralized NumberBox component that can be used by both tab and accordion APIs
		local function createNumberBox(config, parentContainer, currentY, updateSizeFunction, animateFunction, isExpanded, isForAccordion)
			-- Default config
			local placeholder = config.Placeholder or "Enter number..."
			local defaultValue = config.Default or 0
			local callback = config.Callback or function() end
			local minValue = config.Min or -math.huge
			local maxValue = config.Max or math.huge
			local increment = config.Increment or 1
			local decimals = config.Decimals or 0
			local flag = config.Flag
			
			-- NumberBox state
			local currentValue = defaultValue
			
			-- Set initial value from flag if exists
			if flag and EzUI.Flags[flag] ~= nil then
				currentValue = EzUI.Flags[flag]
				defaultValue = currentValue
			end
			
			-- Main numberbox container
			local numberBoxContainer = Instance.new("Frame")
			if isForAccordion then
				numberBoxContainer.Size = UDim2.new(1, -10, 0, 25) -- Compact for accordion
				numberBoxContainer.Position = UDim2.new(0, 5, 0, currentY)
				numberBoxContainer.ZIndex = 6
			else
				numberBoxContainer.Size = UDim2.new(1, -20, 0, 30) -- Standard for tab
				numberBoxContainer.Position = UDim2.new(0, 10, 0, currentY)
				numberBoxContainer.ZIndex = 3
				-- Mark this component's start position for accordion tracking
				numberBoxContainer:SetAttribute("ComponentStartY", currentY)
			end
			numberBoxContainer.BackgroundTransparency = 1
			numberBoxContainer.Parent = parentContainer
			
			-- Number input box
			local numberBox = Instance.new("TextBox")
			if isForAccordion then
				numberBox.Size = UDim2.new(1, -45, 1, 0) -- Smaller for accordion
				numberBox.TextSize = 12 -- Smaller text for accordion
				numberBox.ZIndex = 7
			else
				numberBox.Size = UDim2.new(1, -60, 1, 0) -- Standard for tab
				numberBox.TextSize = 14 -- Normal text for tab
				numberBox.ZIndex = 4
			end
			numberBox.Position = UDim2.new(0, 0, 0, 0)
			numberBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			numberBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
			numberBox.BorderSizePixel = 1
			numberBox.Text = decimals > 0 and string.format("%." .. decimals .. "f", defaultValue) or tostring(defaultValue)
			numberBox.PlaceholderText = placeholder
			numberBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			numberBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			numberBox.Font = Enum.Font.SourceSans
			numberBox.TextXAlignment = Enum.TextXAlignment.Center
			numberBox.TextYAlignment = Enum.TextYAlignment.Center
			numberBox.ClearTextOnFocus = false
			numberBox.Parent = numberBoxContainer
			
			-- Round corners for number box
			local numberCorner = Instance.new("UICorner")
			numberCorner.CornerRadius = UDim.new(0, 4)
			numberCorner.Parent = numberBox
			
			-- Increment button (up arrow)
			local incrementBtn = Instance.new("TextButton")
			if isForAccordion then
				incrementBtn.Size = UDim2.new(0, 20, 0, 12) -- Smaller for accordion
				incrementBtn.Position = UDim2.new(1, -22, 0, 1)
				incrementBtn.TextSize = 8
				incrementBtn.ZIndex = 7
			else
				incrementBtn.Size = UDim2.new(0, 25, 0, 14) -- Standard for tab
				incrementBtn.Position = UDim2.new(1, -30, 0, 1)
				incrementBtn.TextSize = 10
				incrementBtn.ZIndex = 4
			end
			incrementBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			incrementBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
			incrementBtn.BorderSizePixel = 1
			incrementBtn.Text = "▲"
			incrementBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			incrementBtn.Font = Enum.Font.SourceSans
			incrementBtn.Parent = numberBoxContainer
			
			-- Decrement button (down arrow)
			local decrementBtn = Instance.new("TextButton")
			if isForAccordion then
				decrementBtn.Size = UDim2.new(0, 20, 0, 12) -- Smaller for accordion
				decrementBtn.Position = UDim2.new(1, -22, 0, 13)
				decrementBtn.TextSize = 8
				decrementBtn.ZIndex = 7
			else
				decrementBtn.Size = UDim2.new(0, 25, 0, 14) -- Standard for tab
				decrementBtn.Position = UDim2.new(1, -30, 0, 15)
				decrementBtn.TextSize = 10
				decrementBtn.ZIndex = 4
			end
			decrementBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			decrementBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
			decrementBtn.BorderSizePixel = 1
			decrementBtn.Text = "▼"
			decrementBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			decrementBtn.Font = Enum.Font.SourceSans
			decrementBtn.Parent = numberBoxContainer
			
			-- Function to validate and update value
			local function updateValue(newValue)
				-- Clamp to min/max
				newValue = math.max(minValue, math.min(maxValue, newValue))
				
				-- Round to decimal places
				if decimals > 0 then
					local multiplier = 10 ^ decimals
					newValue = math.floor(newValue * multiplier + 0.5) / multiplier
				else
					newValue = math.floor(newValue + 0.5)
				end
				
				currentValue = newValue
				
				-- Update text box display
				if decimals > 0 then
					numberBox.Text = string.format("%." .. decimals .. "f", newValue)
				else
					numberBox.Text = tostring(newValue)
				end
				
				-- Save to flag if specified
				if flag then
					EzUI.Flags[flag] = currentValue
					if EzUI.Configuration.Enabled and EzUI.Configuration.AutoSave then
						saveConfiguration(EzUI.Configuration.FileName)
					end
				end
				
				-- Call user callback
				local success, errorMsg = pcall(function()
					callback(currentValue)
				end)
				
				if not success then
					warn("NumberBox callback error:", errorMsg)
				end
				
				return newValue
			end
			
			-- Text change handler with validation
			numberBox.FocusLost:Connect(function()
				local inputText = numberBox.Text
				local numValue = tonumber(inputText)
				
				if numValue then
					updateValue(numValue)
				else
					-- Invalid input, revert to current value
					if decimals > 0 then
						numberBox.Text = string.format("%." .. decimals .. "f", currentValue)
					else
						numberBox.Text = tostring(currentValue)
					end
				end
			end)
			
			-- Increment button handler
			incrementBtn.MouseButton1Click:Connect(function()
				updateValue(currentValue + increment)
			end)
			
			-- Decrement button handler
			decrementBtn.MouseButton1Click:Connect(function()
				updateValue(currentValue - increment)
			end)
			
			-- Button hover effects
			incrementBtn.MouseEnter:Connect(function()
				incrementBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			end)
			
			incrementBtn.MouseLeave:Connect(function()
				incrementBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			end)
			
			decrementBtn.MouseEnter:Connect(function()
				decrementBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			end)
			
			decrementBtn.MouseLeave:Connect(function()
				decrementBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			end)
			
			-- Focus effects
			numberBox.Focused:Connect(function()
				numberBox.BorderColor3 = Color3.fromRGB(100, 150, 250)
			end)
			
			numberBox.FocusLost:Connect(function()
				numberBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
			end)
			
			-- Return NumberBox API
			local numberBoxAPI = {
				GetValue = function()
					return currentValue
				end,
				SetValue = function(newValue)
					local numValue = tonumber(newValue)
					if numValue then
						updateValue(numValue)
					else
						warn("NumberBox SetValue: Expected number, got " .. type(newValue))
					end
				end,
				SetMin = function(newMin)
					minValue = tonumber(newMin) or -math.huge
					updateValue(currentValue) -- Re-validate current value
				end,
				SetMax = function(newMax)
					maxValue = tonumber(newMax) or math.huge
					updateValue(currentValue) -- Re-validate current value
				end,
				SetIncrement = function(newIncrement)
					increment = tonumber(newIncrement) or 1
				end,
				Clear = function()
					updateValue(0)
				end,
				Focus = function()
					numberBox:CaptureFocus()
				end,
				Blur = function()
					numberBox:ReleaseFocus()
				end,
				SetCallback = function(newCallback)
					callback = newCallback or function() end
				end,
				-- Set function for configuration loading
				Set = function(newValue)
					local numValue = tonumber(newValue)
					if numValue then
						updateValue(numValue)
					end
				end
			}
			
			-- Register component for flag-based updates
			registerComponent(flag, numberBoxAPI)
			
			return numberBoxAPI
		end

		-- Create tab API object
		local tabAPI = {}

		function tabAPI:AddLabel(text)
			-- Use centralized Label function for tab
			local label = createLabel(text, tabContent, tabCurrentY, nil, nil, nil, false)
			
			-- Update posisi Y untuk elemen berikutnya
			tabCurrentY = tabCurrentY + 35
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
		end

		function tabAPI:AddButton(text, callback)
			-- Use centralized Button function for tab
			local button = createButton(text, callback, tabContent, tabCurrentY, nil, nil, nil, false)
			
			-- Update posisi Y untuk elemen berikutnya
			tabCurrentY = tabCurrentY + 35
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
		end

		function tabAPI:AddSelectBox(config)
			-- Use centralized SelectBox function for tab
			local selectBoxAPI = createSelectBox(
				config, 
				tabContent, 
				tabCurrentY, 
				function() -- updateSizeFunction
					if tabContent == activeTab then
						currentY = tabCurrentY
						api:UpdateWindowSize()
					end
				end, 
				nil, -- animateFunction (not needed for tabs)
				true, -- isExpanded (always true for tabs)
				false -- isForAccordion = false
			)
			
			-- Update posisi Y untuk elemen berikutnya
			tabCurrentY = tabCurrentY + 40
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
			
			-- Return SelectBox API
			return selectBoxAPI
		end

		function tabAPI:AddToggle(config)
			-- Use centralized Toggle function for tab
			local toggleAPI = createToggle(config, tabContent, tabCurrentY, nil, nil, nil, false)
			
			-- Update posisi Y untuk elemen berikutnya
			tabCurrentY = tabCurrentY + 35
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
			
			-- Return Toggle API
			return toggleAPI
		end

		function tabAPI:AddTextBox(config)
			-- Use centralized TextBox function for tab
			local textBoxAPI = createTextBox(config, tabContent, tabCurrentY, nil, nil, nil, false)
			
			-- Update posisi Y untuk elemen berikutnya
			local multiline = config.Multiline or false
			tabCurrentY = tabCurrentY + (multiline and 90 or 40)
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
			
			-- Return TextBox API
			return textBoxAPI
		end

		function tabAPI:AddNumberBox(config)
			-- Use centralized NumberBox function for tab
			local numberBoxAPI = createNumberBox(config, tabContent, tabCurrentY, nil, nil, nil, false)
			
			-- Update position Y for next element
			tabCurrentY = tabCurrentY + 40
			
			-- Update canvas size for active tab
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
			
			-- Return NumberBox API
			return numberBoxAPI
		end

		function tabAPI:AddSeparator()
			-- Use centralized Separator function for tab
			local separator = createSeparator(tabContent, tabCurrentY, nil, nil, nil, false)
			
			-- Update posisi Y untuk elemen berikutnya (separator uses +15 spacing like accordion)
			tabCurrentY = tabCurrentY + 15
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
		end

		function tabAPI:AddAccordion(config)
			-- Default config
			local title = config.Title or config.Name or "Accordion"
			local expanded = config.Expanded ~= nil and config.Expanded or false
			local callback = config.Callback or function() end
			local icon = config.Icon or "📁" -- Optional icon for the accordion
			
			-- Accordion state
			local isExpanded = expanded
			local accordionContentHeight = 0
			local accordionStartY = tabCurrentY -- Store initial Y position
			
			-- Main accordion container
			local accordionContainer = Instance.new("Frame")
			accordionContainer.Size = UDim2.new(1, -20, 0, 30) -- Initial height just for header
			accordionContainer.Position = UDim2.new(0, 10, 0, tabCurrentY)
			accordionContainer.BackgroundTransparency = 1
			accordionContainer.ClipsDescendants = false -- Allow content to show
			accordionContainer.ZIndex = 3
			accordionContainer.Parent = tabContent

			-- Store reference to this accordion in tab content for position tracking
			accordionContainer:SetAttribute("AccordionStartY", tabCurrentY)
			accordionContainer:SetAttribute("IsAccordion", true)
			
			-- Accordion header (clickable)
			local accordionHeader = Instance.new("TextButton")
			accordionHeader.Size = UDim2.new(1, 0, 0, 30)
			accordionHeader.Position = UDim2.new(0, 0, 0, 0)
			accordionHeader.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			accordionHeader.BorderColor3 = Color3.fromRGB(100, 100, 100)
			accordionHeader.BorderSizePixel = 1
			accordionHeader.Text = "" -- We'll use custom labels
			accordionHeader.ZIndex = 4
			accordionHeader.Parent = accordionContainer
					
			-- Expand/Collapse arrow
			local accordionArrow = Instance.new("TextLabel")
			accordionArrow.Size = UDim2.new(0, 30, 1, 0)
			accordionArrow.Position = UDim2.new(0, 5, 0, 0)
			accordionArrow.BackgroundTransparency = 1
			accordionArrow.Text = isExpanded and "▼" or "▶"
			accordionArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
			accordionArrow.TextXAlignment = Enum.TextXAlignment.Center
			accordionArrow.Font = Enum.Font.SourceSans
			accordionArrow.TextSize = 14
			accordionArrow.ZIndex = 5
			accordionArrow.Parent = accordionHeader
			
			-- Icon (optional)
			local accordionIcon = Instance.new("TextLabel")
			accordionIcon.Size = UDim2.new(0, 25, 1, 0)
			accordionIcon.Position = UDim2.new(0, 35, 0, 0)
			accordionIcon.BackgroundTransparency = 1
			accordionIcon.Text = icon
			accordionIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
			accordionIcon.TextXAlignment = Enum.TextXAlignment.Center
			accordionIcon.Font = Enum.Font.SourceSans
			accordionIcon.TextSize = 16
			accordionIcon.ZIndex = 5
			accordionIcon.Parent = accordionHeader
			
			-- Accordion title
			local accordionTitle = Instance.new("TextLabel")
			accordionTitle.Size = UDim2.new(1, -70, 1, 0)
			accordionTitle.Position = UDim2.new(0, 65, 0, 0)
			accordionTitle.BackgroundTransparency = 1
			accordionTitle.Text = title
			accordionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
			accordionTitle.TextXAlignment = Enum.TextXAlignment.Left
			accordionTitle.Font = Enum.Font.SourceSansBold
			accordionTitle.TextSize = 16
			accordionTitle.ZIndex = 5
			accordionTitle.Parent = accordionHeader
			
			-- Accordion content container (scrollable)
			local accordionContent = Instance.new("ScrollingFrame")
			accordionContent.Size = UDim2.new(1, 0, 0, 0) -- Start with 0 height
			accordionContent.Position = UDim2.new(0, 0, 0, 35) -- Below header with small gap
			accordionContent.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			accordionContent.BorderColor3 = Color3.fromRGB(80, 80, 80)
			accordionContent.BorderSizePixel = 1
			accordionContent.Visible = isExpanded
			accordionContent.CanvasSize = UDim2.new(0, 0, 0, 0)
			accordionContent.ScrollBarThickness = 6
			accordionContent.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
			accordionContent.ScrollingDirection = Enum.ScrollingDirection.Y
			accordionContent.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			accordionContent.ZIndex = 4
			accordionContent.Parent = accordionContainer
			
			-- Round corners for content (bottom only)
			local contentCorner = Instance.new("UICorner")
			contentCorner.CornerRadius = UDim.new(0, 4)
			contentCorner.Parent = accordionContent
			
			-- Add padding to accordion content
			local contentPadding = Instance.new("UIPadding")
			contentPadding.PaddingTop = UDim.new(0, 8)
			contentPadding.PaddingBottom = UDim.new(0, 8)
			contentPadding.PaddingLeft = UDim.new(0, 8)
			contentPadding.PaddingRight = UDim.new(0, 8)
			contentPadding.Parent = accordionContent
			
			-- Content layout
			local contentLayout = Instance.new("UIListLayout")
			contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			contentLayout.Padding = UDim.new(0, 5)
			contentLayout.Parent = accordionContent
			
			-- Track content Y position within accordion
			local accordionCurrentY = 10
			
			-- Function to update positions of all components below this accordion
			local function updateComponentsBelow()
				local currentAccordionBottom = accordionContainer.Position.Y.Offset + accordionContainer.Size.Y.Offset
				local accordionHeightChange = accordionContainer.Size.Y.Offset - 35 -- 35 is header height
				
				-- Find all components that come after this accordion and update their positions
				for _, child in pairs(tabContent:GetChildren()) do
					if child:IsA("GuiObject") and child ~= accordionContainer then
						-- Check if this component is positioned after the accordion
						local childCurrentY = child.Position.Y.Offset
						local accordionHeaderBottom = accordionStartY + 35 -- Just the header
						
						if childCurrentY > accordionHeaderBottom then
							-- This component comes after the accordion, adjust its position
							local newY = accordionStartY + accordionContainer.Size.Y.Offset + 5 + (childCurrentY - accordionHeaderBottom - 5)
							child.Position = UDim2.new(child.Position.X.Scale, child.Position.X.Offset, 0, newY)
						end
					end
				end
			end
			
			-- Function to recalculate total tab height including all accordions
			local function recalculateTabHeight()
				local maxY = 10
				
				for _, child in pairs(tabContent:GetChildren()) do
					if child:IsA("GuiObject") then
						local childBottom = child.Position.Y.Offset + child.Size.Y.Offset
						maxY = math.max(maxY, childBottom)
					end
				end
				
				-- Update the global tab current Y to reflect new total height
				tabCurrentY = maxY + 10
				
				-- Update canvas size if this tab is active
				if tabContent == activeTab then
					currentY = tabCurrentY
					api:UpdateWindowSize()
				end
			end
			
			-- Function to update accordion container size and canvas
			local function updateAccordionSize()
				-- Update canvas size for content
				accordionContent.CanvasSize = UDim2.new(0, 0, 0, accordionCurrentY + 10)
				
				-- Calculate accordion content height (max 150px, scrollable if needed)
				accordionContentHeight = math.min(accordionCurrentY + 20, 150)
				
				-- Update accordion container size
				local totalHeight = 35 + (isExpanded and accordionContentHeight or 0) -- Header + content
				accordionContainer.Size = UDim2.new(1, -20, 0, totalHeight)
				
				-- Update accordion content frame size
				if isExpanded then
					accordionContent.Size = UDim2.new(1, 0, 0, accordionContentHeight)
				end
				
				-- Update positions of components below this accordion
				updateComponentsBelow()
				
				-- Recalculate total tab height
				recalculateTabHeight()
			end
			
			-- Animation function for smooth expand/collapse
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
				accordionArrow.Text = isExpanded and "▼" or "▶"
				
				-- Show content immediately if expanding, hide after animation if collapsing
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
						{Position = UDim2.new(componentData.component.Position.X.Scale, componentData.component.Position.X.Offset, 0, componentData.targetY)}
					)
					componentTween:Play()
				end
				
				containerTween:Play()
				contentTween:Play()
				
				-- Hide content after collapse animation
				if not isExpanded then
					containerTween.Completed:Connect(function()
						accordionContent.Visible = false
					end)
				end
				
				-- Update tab canvas after animation completes
				containerTween.Completed:Connect(function()
					recalculateTabHeight()
				end)
			end
			
			-- Header click handler
			accordionHeader.MouseButton1Click:Connect(function()
				isExpanded = not isExpanded
				
				-- Call user callback
				local success, errorMsg = pcall(function()
					callback(isExpanded)
				end)
				
				if not success then
					warn("Accordion callback error:", errorMsg)
				end
				
				animateAccordion()
			end)
			
			-- Header hover effects
			accordionHeader.MouseEnter:Connect(function()
				accordionHeader.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			end)
			
			accordionHeader.MouseLeave:Connect(function()
				accordionHeader.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
			end)
			
			-- Update position Y for next element and mark it
			tabCurrentY = tabCurrentY + 40 -- Initial spacing for header
			
			-- Create accordion content API
			local accordionAPI = {}
			
			function accordionAPI:AddLabel(text)
				-- Use centralized Label function for accordion
				local label = createLabel(text, accordionContent, accordionCurrentY, updateAccordionSize, animateAccordion, isExpanded, true)
				
				accordionCurrentY = accordionCurrentY + 30
				updateAccordionSize()
				
				if isExpanded then
					animateAccordion()
				end
			end
			
			function accordionAPI:AddButton(text, buttonCallback)
				-- Use centralized Button function for accordion
				local button = createButton(text, buttonCallback, accordionContent, accordionCurrentY, updateAccordionSize, animateAccordion, isExpanded, true)
				
				accordionCurrentY = accordionCurrentY + 30
				updateAccordionSize()
				
				if isExpanded then
					animateAccordion()
				end
			end
			
			function accordionAPI:AddSelectBox(config)
				-- Use centralized SelectBox function for accordion
				local selectBoxAPI = createSelectBox(
					config, 
					accordionContent, 
					accordionCurrentY, 
					updateAccordionSize, 
					animateAccordion, 
					isExpanded, 
					true -- isForAccordion = true
				)
				
				-- Update accordion position
				accordionCurrentY = accordionCurrentY + 35 -- Height + spacing
				updateAccordionSize()
				
				if isExpanded then
					animateAccordion()
				end
				
				-- Return SelectBox API
				return selectBoxAPI
			end
			
			function accordionAPI:AddSeparator()
				-- Use centralized Separator function for accordion
				local separator = createSeparator(accordionContent, accordionCurrentY, updateAccordionSize, animateAccordion, isExpanded, true)
				
				accordionCurrentY = accordionCurrentY + 15
				updateAccordionSize()
				
				if isExpanded then
					animateAccordion()
				end
			end
			
			function accordionAPI:AddToggle(config)
				-- Use centralized Toggle function for accordion
				local toggleAPI = createToggle(config, accordionContent, accordionCurrentY, updateAccordionSize, animateAccordion, isExpanded, true)
				
				-- Update accordion position
				accordionCurrentY = accordionCurrentY + 30
				updateAccordionSize()
				
				if isExpanded then
					animateAccordion()
				end
				
				-- Return Toggle API
				return toggleAPI
			end

			function accordionAPI:AddTextBox(config)
				-- Use centralized TextBox function for accordion
				local textBoxAPI = createTextBox(config, accordionContent, accordionCurrentY, updateAccordionSize, animateAccordion, isExpanded, true)
				
				-- Update accordion position
				local multiline = config.Multiline or false
				accordionCurrentY = accordionCurrentY + (multiline and 70 or 35) -- Compact spacing for accordion
				updateAccordionSize()
				
				if isExpanded then
					animateAccordion()
				end
				
				-- Return TextBox API
				return textBoxAPI
			end

			function accordionAPI:AddNumberBox(config)
				-- Use centralized NumberBox function for accordion
				local numberBoxAPI = createNumberBox(config, accordionContent, accordionCurrentY, updateAccordionSize, animateAccordion, isExpanded, true)
				
				-- Update accordion position
				accordionCurrentY = accordionCurrentY + 35 -- Compact spacing for accordion
				updateAccordionSize()
				
				if isExpanded then
					animateAccordion()
				end
				
				-- Return NumberBox API
				return numberBoxAPI
			end
			
			-- Initialize with expanded state
			if isExpanded then
				updateAccordionSize()
				animateAccordion()
			end
			
			-- Return accordion API
			return {
				Expand = function()
					if not isExpanded then
						isExpanded = true
						animateAccordion()
						
						-- Call user callback
						local success, errorMsg = pcall(function()
							callback(isExpanded)
						end)
						
						if not success then
							warn("Accordion callback error:", errorMsg)
						end
					end
				end,
				Collapse = function()
					if isExpanded then
						isExpanded = false
						animateAccordion()
						
						-- Call user callback
						local success, errorMsg = pcall(function()
							callback(isExpanded)
						end)
						
						if not success then
							warn("Accordion callback error:", errorMsg)
						end
					end
				end,
				Toggle = function()
					isExpanded = not isExpanded
					animateAccordion()
					
					-- Call user callback
					local success, errorMsg = pcall(function()
						callback(isExpanded)
					end)
					
					if not success then
						warn("Accordion callback error:", errorMsg)
					end
					
					return isExpanded
				end,
				IsExpanded = function()
					return isExpanded
				end,
				SetTitle = function(newTitle)
					title = newTitle
					accordionTitle.Text = newTitle
				end,
				SetIcon = function(newIcon)
					icon = newIcon
					accordionIcon.Text = newIcon
				end,
				AddLabel = accordionAPI.AddLabel,
				AddButton = accordionAPI.AddButton,
				AddSelectBox = accordionAPI.AddSelectBox,
				AddSeparator = accordionAPI.AddSeparator,
				AddToggle = accordionAPI.AddToggle,
				AddTextBox = accordionAPI.AddTextBox,
				AddNumberBox = accordionAPI.AddNumberBox
			}
		end

		-- Tab button click
		tabBtn.MouseButton1Click:Connect(function()
			-- Reset all tab buttons to normal color and hide contents
			for _, content in pairs(tabContents) do
				content.Visible = false
			end
			for _, btn in pairs(tabScrollFrame:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				end
			end

			-- Activate the clicked tab
			tabContent.Visible = true
			tabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			activeTab = tabContent
			activeTabName = tabName
			currentTabContent = tabContent
			currentY = tabCurrentY
			api:UpdateWindowSize()
			
			-- Call user callback if provided
			if tabCallback then
				local success, errorMsg = pcall(function()
					tabCallback(tabName, true) -- tab name and activated state
				end)
				
				if not success then
					warn("Tab callback error:", errorMsg)
				end
			end
		end)

		-- Auto-activate first tab
		if not activeTab then
			tabContent.Visible = true
			activeTab = tabContent
			activeTabName = tabName
			currentTabContent = tabContent
			currentY = tabCurrentY
			tabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			api:UpdateWindowSize()
		end

		-- Return tab API object with enhanced methods
		local enhancedTabAPI = {}
		
		-- Copy all existing tabAPI methods
		for key, value in pairs(tabAPI) do
			enhancedTabAPI[key] = value
		end
		
		-- Add new tab control methods
		function enhancedTabAPI:SetVisible(visible)
			tabBtn.Visible = visible
			tabVisible = visible
		end
		
		function enhancedTabAPI:GetVisible()
			return tabVisible
		end
		
		function enhancedTabAPI:SetTitle(newTitle)
			tabName = newTitle
			titleLabel.Text = newTitle
		end
		
		function enhancedTabAPI:GetTitle()
			return tabName
		end
		
		function enhancedTabAPI:SetIcon(newIcon)
			tabIcon = newIcon
			iconLabel.Text = newIcon or ""
			updateTitleAlignment()
		end
		
		function enhancedTabAPI:GetIcon()
			return tabIcon
		end
		
		function enhancedTabAPI:Activate()
			-- Programmatically activate this tab
			-- Reset all tab buttons to normal color and hide contents
			for _, content in pairs(tabContents) do
				content.Visible = false
			end
			for _, btn in pairs(tabScrollFrame:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				end
			end

			-- Activate this tab
			tabContent.Visible = true
			tabBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			activeTab = tabContent
			activeTabName = tabName
			currentTabContent = tabContent
			currentY = tabCurrentY
			api:UpdateWindowSize()
			
			-- Call user callback if provided
			if tabCallback then
				local success, errorMsg = pcall(function()
					tabCallback(tabName, true)
				end)
				
				if not success then
					warn("Tab callback error:", errorMsg)
				end
			end
		end
		
		function enhancedTabAPI:IsActive()
			return activeTab == tabContent
		end
		
		function enhancedTabAPI:SetCallback(newCallback)
			tabCallback = newCallback
		end
		
		return enhancedTabAPI
	end

	-- Window opacity control methods
	function api:SetOpacity(opacity)
		-- Clamp opacity between 0.1 and 1.0
		windowOpacity = math.max(0.1, math.min(1.0, opacity))
		local transparency = 1 - windowOpacity
		
		-- Update main window components
		frame.BackgroundTransparency = transparency
		tabPanel.BackgroundTransparency = transparency
		header.BackgroundTransparency = transparency
	end
	
	function api:GetOpacity()
		return windowOpacity
	end
	
	function api:FadeIn(duration)
		duration = duration or 0.3
		local TweenService = game:GetService("TweenService")
		local targetTransparency = 1 - windowOpacity
		
		-- Start from fully transparent
		frame.BackgroundTransparency = 1
		tabPanel.BackgroundTransparency = 1
		header.BackgroundTransparency = 1
		
		-- Tween to target opacity
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		
		local frameTween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = targetTransparency})
		local tabPanelTween = TweenService:Create(tabPanel, tweenInfo, {BackgroundTransparency = targetTransparency})
		local headerTween = TweenService:Create(header, tweenInfo, {BackgroundTransparency = targetTransparency})
		
		frameTween:Play()
		tabPanelTween:Play()
		headerTween:Play()
	end
	
	function api:FadeOut(duration)
		duration = duration or 0.3
		local TweenService = game:GetService("TweenService")
		
		-- Tween to fully transparent
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		
		local frameTween = TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 1})
		local tabPanelTween = TweenService:Create(tabPanel, tweenInfo, {BackgroundTransparency = 1})
		local headerTween = TweenService:Create(header, tweenInfo, {BackgroundTransparency = 1})
		
		frameTween:Play()
		tabPanelTween:Play()
		headerTween:Play()
	end
	
	function api:Show()
		-- Show the window by enabling the ScreenGui
		screenGui.Enabled = true
		-- Hide the floating button when window is shown
		floatBtn.Visible = false
	end
	
	function api:Hide()
		-- Hide the window by disabling the ScreenGui
		screenGui.Enabled = false
		-- Show the floating button when window is hidden
		floatBtn.Visible = true
	end
	
	function api:IsVisible()
		-- Check if the window is currently visible
		return screenGui.Enabled
	end
	
	function api:ToggleVisibility()
		-- Toggle window visibility
		screenGui.Enabled = not screenGui.Enabled
		-- Toggle floating button visibility (opposite of window)
		floatBtn.Visible = not screenGui.Enabled
		return screenGui.Enabled
	end
	
	function api:AdaptToViewport()
		-- Recalculate window size based on current viewport
		local currentViewport = getViewportSize()
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
	
	function api:GetDynamicSize()
		local currentViewport = getViewportSize()
		return {
			Width = frame.Size.X.Offset,
			Height = frame.Size.Y.Offset,
			ViewportWidth = currentViewport.X,
			ViewportHeight = currentViewport.Y
		}
	end
	
	-- Set window size programmatically
	function api:SetSize(width, height)
		local viewportSize = getViewportSize()
		
		-- Apply constraints
		width = math.max(300, math.min(width, viewportSize.X * 0.9))
		height = math.max(200, math.min(height, viewportSize.Y * 0.9))
		
		frame.Size = UDim2.new(0, width, 0, height)
		
		-- Update canvas size for scrolling
		if currentTabContent then
			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY + 10)
		end
		
		return {Width = width, Height = height}
	end
	
	-- Auto-adapt to viewport changes (optional)
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if config.AutoAdapt ~= false then -- Default true, can be disabled
			wait(0.1) -- Small delay to ensure viewport is stable
			api:AdaptToViewport()
		end
	end)

	-- Close window functionality
	local onCloseCallback = nil
	
	function api:SetCloseCallback(callback)
		onCloseCallback = callback
	end
	
	function api:Close()
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
	
	-- Configuration Management API
	function api:SaveConfiguration()
		if configEnabled then
			saveConfiguration(configFileName)
		else
			warn("EzUI: Configuration saving is not enabled for this window")
		end
	end
	
	function api:LoadConfiguration()
		if configEnabled then
			return loadConfiguration(configFileName)
		else
			warn("EzUI: Configuration saving is not enabled for this window")
			return false
		end
	end
	
	function api:GetConfigurationStatus()
		return {
			Enabled = configEnabled,
			FileName = configFileName,
			FolderName = configFolderName,
			AutoSave = configAutoSave,
			AutoLoad = configAutoLoad,
			FlagsCount = #EzUI.Flags
		}
	end
	
	-- Connect close button functionality
	closeBtn.MouseButton1Click:Connect(function()
		api:Close()
	end)
	
	-- Add ESC key support for closing window
	local closeConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
			api:Close()
		end
	end)
	
	-- Store connection to disconnect it when window is destroyed
	local function disconnectCloseConnection()
		if closeConnection then
			closeConnection:Disconnect()
			closeConnection = nil
		end
	end
	
	-- Override Close function to also disconnect the connection
	local originalClose = api.Close
	api.Close = function(self)
		disconnectCloseConnection()
		originalClose(self)
	end
	
	-- Auto-load configuration if enabled
	if configEnabled and configAutoLoad then
		task.defer(function()
			local loaded = loadConfiguration(configFileName)
			if loaded then
				print("EzUI: Auto-loaded configuration for " .. configFileName)
			end
		end)
	end

	return api
end

return EzUI
