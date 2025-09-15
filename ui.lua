-- EzUI
local EzUI = {}

function EzUI.CreateWindow(config)
	print("Creating window with config:", config.Name) -- debug info
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = config.Name or "MyWindow"
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	print("ScreenGui created and parented") -- debug info

	-- 🟦 Main window in the center of the screen
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, config.Width or 300, 0, config.Height or 200)
	frame.Position = UDim2.new(0.5, -(config.Width or 300) / 2, 0.5, -(config.Height or 200) / 2)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.ClipsDescendants = true -- ensure components do not go outside the window
	frame.ZIndex = 1 -- Base Z-index for window
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
	local resizeHandle = Instance.new("Frame")
	resizeHandle.Size = UDim2.new(0, 16, 0, 16)
	resizeHandle.Position = UDim2.new(1, -16, 1, -16)
	resizeHandle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	resizeHandle.BorderSizePixel = 0
	resizeHandle.ZIndex = 27 -- Higher than header
	resizeHandle.Parent = frame

	-- Resize icon using Frame as diagonal lines
	local line1 = Instance.new("Frame")
	line1.Size = UDim2.new(0, 1, 0, 12)
	line1.Position = UDim2.new(0, 11, 0, 2)
	line1.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	line1.BorderSizePixel = 0
	line1.Rotation = 45
	line1.ZIndex = 11
	line1.Parent = resizeHandle

	local line2 = Instance.new("Frame")
	line2.Size = UDim2.new(0, 1, 0, 9)
	line2.Position = UDim2.new(0, 8, 0, 4)
	line2.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	line2.BorderSizePixel = 0
	line2.Rotation = 45
	line2.ZIndex = 11
	line2.Parent = resizeHandle

	local line3 = Instance.new("Frame")
	line3.Size = UDim2.new(0, 1, 0, 6)
	line3.Position = UDim2.new(0, 5, 0, 6)
	line3.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	line3.BorderSizePixel = 0
	line3.Rotation = 45
	line3.ZIndex = 11
	line3.Parent = resizeHandle

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
			local newWidth = math.max(200, resizeStartSize.X.Offset + delta.X)
			local newHeight = math.max(100, resizeStartSize.Y.Offset + delta.Y)
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
	header.BorderSizePixel = 0
	header.ZIndex = 25 -- Higher than SelectBox dropdown
	header.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 1, 0)
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
	minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 170, 0)
	minimizeBtn.Text = "_"
	minimizeBtn.ZIndex = 26 -- Higher than header
	minimizeBtn.Parent = header

	-- 🟩 Floating button at the top left (below the Roblox logo button)
	local floatBtn = Instance.new("TextButton")
	floatBtn.Size = UDim2.new(0, 120, 0, 35)
	floatBtn.Position = UDim2.new(0, 10, 0, 45) -- offset downward to avoid Roblox logo collision
	floatBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 250)
	floatBtn.Text = "Open "..(config.Name or "UI")
	floatBtn.Visible = false
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

	function api:AddLabel(text)
	if not currentTabContent then return end
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 30)
	label.Position = UDim2.new(0, 10, 0, currentY)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
	label.Parent = currentTabContent
	-- Update Y position for the next element
	currentY = currentY + 35 -- 30px height + 5px spacing
	api:UpdateWindowSize()
	end

	function api:AddButton(text, callback)
	if not currentTabContent then return end
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 120, 0, 30)
	button.Position = UDim2.new(0, 10, 0, currentY)
	button.BackgroundColor3 = Color3.fromRGB(100, 150, 250)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 14
	button.BorderSizePixel = 0
	button.Parent = currentTabContent

	button.MouseButton1Click:Connect(callback)
	-- Update posisi Y untuk elemen berikutnya
	currentY = currentY + 35 -- 30px tinggi + 5px spacing
	api:UpdateWindowSize()
	end
	
	-- Fungsi untuk mengupdate ukuran window secara otomatis
	function api:UpdateWindowSize()
		-- Update CanvasSize dari currentTabContent agar scroll vertical aktif
		if currentTabContent then
			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentY + 10)
		end
	end

	-- API untuk tab
	function api:AddTab(tabName)
		-- Tab button
		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, -6, 0, 32) -- -6 untuk memberikan ruang scroll bar
		tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		tabBtn.Text = tabName
		tabBtn.Font = Enum.Font.SourceSansBold
		tabBtn.TextSize = 15
		tabBtn.BorderSizePixel = 0
		tabBtn.ZIndex = 4 -- Above tab panel
		tabBtn.Parent = tabScrollFrame

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

		-- Create tab API object
		local tabAPI = {}

		function tabAPI:AddLabel(text)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -20, 0, 30)
			label.Position = UDim2.new(0, 10, 0, tabCurrentY)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Font = Enum.Font.SourceSans
			label.TextSize = 16
			label.ZIndex = 3 -- Above tab content
			label.Parent = tabContent
			
			-- Update posisi Y untuk elemen berikutnya
			tabCurrentY = tabCurrentY + 35
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
		end

		function tabAPI:AddButton(text, callback)
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(0, 120, 0, 30)
			button.Position = UDim2.new(0, 10, 0, tabCurrentY)
			button.BackgroundColor3 = Color3.fromRGB(100, 150, 250)
			button.Text = text
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.Font = Enum.Font.SourceSans
			button.TextSize = 14
			button.BorderSizePixel = 0
			button.ZIndex = 3 -- Above tab content
			button.Parent = tabContent

			if callback then
				button.MouseButton1Click:Connect(callback)
			end
			
			-- Update posisi Y untuk elemen berikutnya
			tabCurrentY = tabCurrentY + 35
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
		end

		function tabAPI:AddSelectBox(config)
			-- Default config
			local rawOptions = config.Options or {"Option 1", "Option 2", "Option 3"}
			local placeholder = config.Placeholder or "Select option..."
			local multiSelect = config.MultiSelect or false
			local callback = config.Callback or function() end
			
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
			local isOpen = false
			local preventAutoClose = false -- Flag to prevent auto-closing during option clicks
			
			-- Main SelectBox container
			local selectContainer = Instance.new("Frame")
			selectContainer.Size = UDim2.new(1, -20, 0, 30) -- Full width with 10px padding on each side
			selectContainer.Position = UDim2.new(0, 10, 0, tabCurrentY)
			selectContainer.BackgroundTransparency = 1
			selectContainer.ClipsDescendants = false -- Important: allow dropdown to show outside
			selectContainer.ZIndex = 5
			selectContainer.Parent = tabContent
			
			-- SelectBox button (display area)
			local selectButton = Instance.new("TextButton")
			selectButton.Size = UDim2.new(1, -25, 1, 0)
			selectButton.Position = UDim2.new(0, 0, 0, 0)
			selectButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			selectButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
			selectButton.BorderSizePixel = 1
			selectButton.Text = "  " .. placeholder
			selectButton.TextColor3 = Color3.fromRGB(200, 200, 200)
			selectButton.TextXAlignment = Enum.TextXAlignment.Left
			selectButton.Font = Enum.Font.SourceSans
			selectButton.TextSize = 14
			selectButton.ZIndex = 6
			selectButton.Parent = selectContainer
			
			-- Dropdown arrow
			local arrow = Instance.new("TextLabel")
			arrow.Size = UDim2.new(0, 25, 1, 0)
			arrow.Position = UDim2.new(1, -25, 0, 0)
			arrow.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			arrow.BorderColor3 = Color3.fromRGB(100, 100, 100)
			arrow.BorderSizePixel = 1
			arrow.Text = "▼"
			arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
			arrow.TextXAlignment = Enum.TextXAlignment.Center
			arrow.Font = Enum.Font.SourceSans
			arrow.TextSize = 12
			arrow.ZIndex = 7
			arrow.Parent = selectContainer
			
			-- Dropdown list container
			local dropdownFrame = Instance.new("ScrollingFrame")
			dropdownFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 30 + 35, 185)) -- Extra space for search box
			dropdownFrame.Position = UDim2.new(0, 0, 1, 3)
			dropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			dropdownFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
			dropdownFrame.BorderSizePixel = 1
			dropdownFrame.Visible = false
			dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 30 + 35) -- Extra canvas space for search box
			dropdownFrame.ScrollBarThickness = 8
			dropdownFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
			dropdownFrame.ZIndex = 25 -- Very high Z-index to appear above everything
			dropdownFrame.ClipsDescendants = true
			dropdownFrame.Active = true
			dropdownFrame.Parent = screenGui -- Parent directly to ScreenGui to avoid clipping
			
			-- Search box
			local searchBox = Instance.new("TextBox")
			searchBox.Size = UDim2.new(1, -10, 0, 25)
			searchBox.Position = UDim2.new(0, 5, 0, 5)
			searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			searchBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
			searchBox.BorderSizePixel = 1
			searchBox.Text = ""
			searchBox.PlaceholderText = "Search options..."
			searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			searchBox.Font = Enum.Font.Gotham
			searchBox.TextSize = 12
			searchBox.ZIndex = 21 -- Higher than dropdown frame
			searchBox.ClearTextOnFocus = false
			searchBox.Parent = dropdownFrame
			
			-- Container for option items (below search box)
			local optionsContainer = Instance.new("Frame")
			optionsContainer.Size = UDim2.new(1, 0, 1, -35)
			optionsContainer.Position = UDim2.new(0, 0, 0, 35)
			optionsContainer.BackgroundTransparency = 1
			optionsContainer.ZIndex = 21 -- Same as search box
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
				local viewportSize = workspace.CurrentCamera.ViewportSize
				
				-- Calculate dropdown dimensions
				local dropdownHeight = dropdownFrame.Size.Y.Offset
				local dropdownWidth = absoluteSize.X
				
				-- Check if there's enough space below
				local spaceBelow = viewportSize.Y - (absolutePos.Y + absoluteSize.Y)
				local spaceAbove = absolutePos.Y
				
				local finalPosition
				local showAbove = false
				
				if spaceBelow >= dropdownHeight + 10 then
					-- Show dropdown below
					finalPosition = UDim2.new(0, absolutePos.X, 0, absolutePos.Y + absoluteSize.Y + 3)
					showAbove = false
				elseif spaceAbove >= dropdownHeight + 10 then
					-- Show dropdown above
					finalPosition = UDim2.new(0, absolutePos.X, 0, absolutePos.Y - dropdownHeight - 3)
					showAbove = true
				else
					-- Not enough space above or below, show below but adjust height
					local maxHeight = math.max(spaceBelow - 10, 100)
					dropdownFrame.Size = UDim2.new(0, dropdownWidth, 0, maxHeight)
					finalPosition = UDim2.new(0, absolutePos.X, 0, absolutePos.Y + absoluteSize.Y + 3)
					showAbove = false
				end
				
				-- Set size and position
				dropdownFrame.Size = UDim2.new(0, dropdownWidth, dropdownFrame.Size.Y.Scale, dropdownFrame.Size.Y.Offset)
				dropdownFrame.Position = finalPosition
				
				print("Dropdown position calculated:")
				print("  SelectBox position:", absolutePos)
				print("  Viewport size:", viewportSize)
				print("  Space below:", spaceBelow)
				print("  Space above:", spaceAbove)
				print("  Show above:", showAbove)
				print("  Final position:", finalPosition)
			end
			
			-- Function to toggle dropdown
			local function toggleDropdown()
				isOpen = not isOpen
				dropdownFrame.Visible = isOpen
				
				-- Debug print
				print("Dropdown toggled:", isOpen, "Options count:", #options)
				
				-- Only adjust dropdown size, keep container size fixed
				if isOpen then
					local dropdownHeight = math.min(#options * 30 + 35, 185) -- Include search box height
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
					
					print("Dropdown expanded, container size remains:", selectContainer.Size)
				else
					print("Dropdown collapsed, container size remains:", selectContainer.Size)
				end
			end
			
			-- Create dropdown options
			for i, option in ipairs(options) do
				local optionButton = Instance.new("TextButton")
				optionButton.Size = UDim2.new(1, 0, 0, 30)
				optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
				optionButton.BorderSizePixel = 0
				optionButton.Text = "  " .. option.text -- Display the text property
				optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				optionButton.TextXAlignment = Enum.TextXAlignment.Left
				optionButton.Font = Enum.Font.SourceSans
				optionButton.TextSize = 14
				optionButton.LayoutOrder = i
				optionButton.ZIndex = 22 -- Higher than container
				optionButton.Active = true
				optionButton.Parent = optionsContainer
				
				-- Selection indicator for multi-select
				local checkmark = Instance.new("TextLabel")
				checkmark.Size = UDim2.new(0, 25, 1, 0)
				checkmark.Position = UDim2.new(1, -25, 0, 0)
				checkmark.BackgroundTransparency = 1
				checkmark.Text = ""
				checkmark.TextColor3 = Color3.fromRGB(100, 200, 100)
				checkmark.TextXAlignment = Enum.TextXAlignment.Center
				checkmark.Font = Enum.Font.SourceSansBold
				checkmark.TextSize = 14
				checkmark.ZIndex = 23 -- Highest Z-index
				checkmark.Parent = optionButton
				
				print("Created option button:", option.text, "Value:", option.value, "Parent:", optionButton.Parent.Name)
				
				-- Option hover effect
				optionButton.MouseEnter:Connect(function()
					print("Mouse entered option:", option.text)
					if not table.find(selectedValues, option.value) then
						optionButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
					end
				end)
				
				optionButton.MouseLeave:Connect(function()
					print("Mouse left option:", option.text)
					if table.find(selectedValues, option.value) then
						optionButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
					else
						optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
					end
				end)
				
				-- Option click handler - SIMPLIFIED VERSION
				optionButton.MouseButton1Click:Connect(function()
					print("=== OPTION BUTTON CLICKED ===")
					print("Clicked option:", option.text, "Value:", option.value)
					print("Current isOpen:", isOpen)
					print("MultiSelect mode:", multiSelect)
					
					-- Set flag to prevent auto-close during processing
					preventAutoClose = true
					
					if multiSelect then
						-- Multi-select mode - dropdown stays open
						local found = false
						local foundIndex = nil
						for j, val in ipairs(selectedValues) do
							if val == option.value then
								found = true
								foundIndex = j
								break
							end
						end
						
						if found then
							-- Remove from selection
							table.remove(selectedValues, foundIndex)
							checkmark.Text = ""
							optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
							print("Removed from selection:", option.text, "Value:", option.value)
						else
							-- Add to selection
							table.insert(selectedValues, option.value)
							checkmark.Text = "✓"
							optionButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
							print("Added to selection:", option.text, "Value:", option.value)
						end
						
						print("Multi-select: Dropdown stays open")
						-- DO NOT CLOSE DROPDOWN - let user continue selecting
						
					else
						-- Single select mode - auto close after selection
						print("Single select - clearing all previous selections")
						selectedValues = {option.value}
						
						-- Update all option buttons in this dropdown
						for _, child in pairs(optionsContainer:GetChildren()) do
							if child:IsA("TextButton") then
								local childCheckmark = child:FindFirstChild("TextLabel")
								if childCheckmark then
									-- Find the option that matches this button
									local childOption = nil
									for _, opt in ipairs(options) do
										if "  " .. opt.text == child.Text then
											childOption = opt
											break
										end
									end
									
									if childOption and childOption.value == option.value then
										childCheckmark.Text = "✓"
										child.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
										print("Marked as selected:", childOption.text)
									else
										childCheckmark.Text = ""
										child.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
										if childOption then
											print("Unmarked:", childOption.text)
										end
									end
								end
							end
						end
						
						-- Close dropdown after selection for single select
						print("Single select: Closing dropdown in 0.15 seconds...")
						spawn(function()
							wait(0.15)
							if isOpen and not preventAutoClose then
								print("Actually closing dropdown now...")
								toggleDropdown()
							end
						end)
					end
					
					-- Update display text
					updateDisplayText()
					print("Updated display text")
					
					-- Call user callback with selected values and the clicked option
					print("Calling user callback...")
					local success, errorMsg = pcall(function()
						callback(selectedValues, option)
					end)
					
					if not success then
						warn("SelectBox callback error:", errorMsg)
					else
						print("Callback executed successfully")
					end
					
					-- Reset flag after processing complete
					spawn(function()
						wait(0.3) -- Reset after longer delay
						preventAutoClose = false
						print("Reset preventAutoClose flag")
					end)
					
					print("=== END OPTION CLICK ===")
				end)
			end
			
			-- Search functionality
			local allOptionButtons = {}
			for _, child in pairs(optionsContainer:GetChildren()) do
				if child:IsA("TextButton") then
					table.insert(allOptionButtons, child)
				end
			end
			
			local function filterOptions(searchText)
				searchText = searchText:lower()
				local visibleCount = 0
				
				for _, optionButton in pairs(allOptionButtons) do
					local optionText = optionButton.Text:sub(3):lower() -- Remove "  " prefix
					local isVisible = searchText == "" or optionText:find(searchText, 1, true) ~= nil
					
					optionButton.Visible = isVisible
					if isVisible then
						visibleCount = visibleCount + 1
					end
				end
				
				-- Update canvas size based on visible options
				local newCanvasHeight = (visibleCount * 30) + 35
				dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, newCanvasHeight)
				
				-- Update dropdown frame size and recalculate position
				local maxVisibleHeight = math.min(visibleCount * 30, 150) + 35
				dropdownFrame.Size = UDim2.new(0, selectContainer.AbsoluteSize.X, 0, maxVisibleHeight)
				
				-- Recalculate position when size changes
				if isOpen then
					calculateDropdownPosition()
				end
				
				print("Search filter applied:", searchText, "Visible options:", visibleCount)
			end
			
			-- Connect search box events
			searchBox.Changed:Connect(function(property)
				if property == "Text" then
					filterOptions(searchBox.Text)
				end
			end)
			
			-- Clear search when dropdown closes
			local originalToggleDropdown = toggleDropdown
			toggleDropdown = function()
				originalToggleDropdown()
				if not isOpen then
					searchBox.Text = ""
					filterOptions("") -- Show all options when reopening
				end
			end
			
			-- Update dropdown position when window or tab content moves/resizes
			local function onPositionChanged()
				if isOpen then
					calculateDropdownPosition()
				end
			end
			
			-- Connect to position/size changes
			selectContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(onPositionChanged)
			selectContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(onPositionChanged)
			
			-- Connect to scroll changes - close dropdown on scroll for better UX
			scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				if isOpen then
					toggleDropdown() -- Close dropdown when scrolling
				end
			end)
			
			-- Also connect to frame changes for when window is moved/resized
			frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(onPositionChanged)
			frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if isOpen then
					calculateDropdownPosition()
				end
			end)
			
			-- Close dropdown when clicking outside (improved detection)
			local UserInputService = game:GetService("UserInputService")
			local outsideConnection
			
			local function closeDropdownOutside()
				if outsideConnection then
					outsideConnection:Disconnect()
					outsideConnection = nil
				end
				
				-- Only setup outside click detection for multi-select mode
				if not multiSelect then
					print("Single select mode - no outside click detection needed")
					return
				end
				
				print("Setting up outside click detection for multi-select mode")
				outsideConnection = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen and not preventAutoClose then
						print("Outside click detected for multi-select, checking position...")
						
						-- Use spawn for async check with longer delay
						spawn(function()
							wait(0.3) -- Longer delay to ensure option clicks complete
							if isOpen and not preventAutoClose then
								local mouse = game.Players.LocalPlayer:GetMouse()
								local mousePos = Vector2.new(mouse.X, mouse.Y)
								
								-- Get container bounds
								local containerPos = selectContainer.AbsolutePosition
								local containerSize = selectContainer.AbsoluteSize
								
								-- Get dropdown bounds (includes search box)
								local dropdownPos = dropdownFrame.AbsolutePosition
								local dropdownSize = dropdownFrame.AbsoluteSize
								
								print("Mouse pos:", mousePos.X, mousePos.Y)
								print("Container bounds:", containerPos.X, containerPos.Y, "to", containerPos.X + containerSize.X, containerPos.Y + containerSize.Y)
								print("Dropdown bounds:", dropdownPos.X, dropdownPos.Y, "to", dropdownPos.X + dropdownSize.X, dropdownPos.Y + dropdownSize.Y)
								
								-- Check if click is outside both container AND dropdown areas
								local outsideContainer = mousePos.X < containerPos.X or mousePos.X > containerPos.X + containerSize.X or
								                        mousePos.Y < containerPos.Y or mousePos.Y > containerPos.Y + containerSize.Y
								
								local outsideDropdown = mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or
								                       mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y
								
								local isOutside = outsideContainer and outsideDropdown
								
								if isOutside then
									print("Multi-select: Click is outside both container and dropdown, closing dropdown")
									toggleDropdown()
									if outsideConnection then
										outsideConnection:Disconnect()
										outsideConnection = nil
									end
								else
									print("Multi-select: Click is inside container or dropdown area, keeping dropdown open")
								end
							else
								print("Outside click ignored - preventAutoClose is active or dropdown closed")
							end
						end)
					end
				end)
			end
			
			-- SelectBox button click handler
			selectButton.MouseButton1Click:Connect(function()
				print("=== SELECTBOX BUTTON CLICKED ===")
				print("Current isOpen state:", isOpen)
				print("MultiSelect mode:", multiSelect)
				toggleDropdown()
				print("After toggle, isOpen:", isOpen)
				
				-- Disconnect any existing outside detection first
				if outsideConnection then
					print("Disconnecting existing outside click detection...")
					outsideConnection:Disconnect()
					outsideConnection = nil
				end
				
				if isOpen and multiSelect then
					print("Dropdown opened in multi-select mode - setting up outside click detection...")
					-- Small delay before setting up outside detection to avoid immediate trigger
					spawn(function()
						wait(0.1)
						closeDropdownOutside()
					end)
				elseif isOpen then
					print("Dropdown opened in single-select mode - no outside detection needed")
				else
					print("Dropdown closed - no outside detection needed")
				end
				print("=== END SELECTBOX BUTTON CLICK ===")
			end)
			
			-- Update posisi Y untuk elemen berikutnya
			-- Use fixed spacing like other components
			tabCurrentY = tabCurrentY + 40
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
			
			-- Return SelectBox API
			return {
				GetSelected = function()
					return selectedValues
				end,
				SetSelected = function(values)
					selectedValues = values or {}
					updateDisplayText()
					
					-- Update checkmarks and colors based on values (not display text)
					for _, child in pairs(optionsContainer:GetChildren()) do
						if child:IsA("TextButton") then
							local childCheckmark = child:FindFirstChild("TextLabel")
							if childCheckmark then
								-- Find the option that matches this button
								local childOption = nil
								for _, opt in ipairs(options) do
									if "  " .. opt.text == child.Text then
										childOption = opt
										break
									end
								end
								
								local isSelected = false
								if childOption then
									for _, val in ipairs(selectedValues) do
										if val == childOption.value then
											isSelected = true
											break
										end
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
					
					-- Clear all checkmarks and colors
					for _, child in pairs(optionsContainer:GetChildren()) do
						if child:IsA("TextButton") then
							local childCheckmark = child:FindFirstChild("TextLabel")
							if childCheckmark then
								childCheckmark.Text = ""
								child.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
							end
						end
					end
				end,
				Refresh = function(newOptions)
					-- Clear existing options from optionsContainer
					for _, child in pairs(optionsContainer:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end
					
					-- Normalize new options to object format
					local rawOptions = newOptions or {}
					options = {}
					for i, option in ipairs(rawOptions) do
						if type(option) == "string" then
							-- Convert string to object format
							table.insert(options, {text = option, value = option})
						elseif type(option) == "table" and option.text and option.value then
							-- Already in object format
							table.insert(options, {text = option.text, value = option.value})
						else
							warn("SelectBox Refresh: Invalid option format at index " .. i .. ". Expected string or {text, value} object.")
						end
					end
					
					dropdownFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 30 + 35) -- Include search box space
					
					-- Clear selected values
					selectedValues = {}
					updateDisplayText()
					
					-- Clear and rebuild allOptionButtons array
					allOptionButtons = {}
					
					-- Recreate options with full functionality
					for i, option in ipairs(options) do
						local optionButton = Instance.new("TextButton")
						optionButton.Size = UDim2.new(1, 0, 0, 30)
						optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
						optionButton.BorderSizePixel = 0
						optionButton.Text = "  " .. option.text -- Use text property
						optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
						optionButton.TextXAlignment = Enum.TextXAlignment.Left
						optionButton.Font = Enum.Font.SourceSans
						optionButton.TextSize = 14
						optionButton.LayoutOrder = i
						optionButton.ZIndex = 22 -- Updated Z-index
						optionButton.Active = true
						
						-- Store the option value as an attribute for later reference
						optionButton:SetAttribute("OptionValue", option.value)
						
						optionButton.Parent = optionsContainer -- Use optionsContainer instead of dropdownFrame
						
						-- Add to allOptionButtons array
						table.insert(allOptionButtons, optionButton)
						
						-- Selection indicator
						local checkmark = Instance.new("TextLabel")
						checkmark.Size = UDim2.new(0, 25, 1, 0)
						checkmark.Position = UDim2.new(1, -25, 0, 0)
						checkmark.BackgroundTransparency = 1
						checkmark.Text = ""
						checkmark.TextColor3 = Color3.fromRGB(100, 200, 100)
						checkmark.TextXAlignment = Enum.TextXAlignment.Center
						checkmark.Font = Enum.Font.SourceSansBold
						checkmark.TextSize = 14
						checkmark.ZIndex = 23 -- Updated Z-index
						checkmark.Parent = optionButton
						
						-- Hover effects
						optionButton.MouseEnter:Connect(function()
							if not table.find(selectedValues, option.value) then
								optionButton.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
							end
						end)
						
						optionButton.MouseLeave:Connect(function()
							if table.find(selectedValues, option.value) then
								optionButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
							else
								optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
							end
						end)
						
						-- Click handler
						optionButton.MouseButton1Click:Connect(function()
							print("=== REFRESHED OPTION CLICK START ===")
							print("Refreshed option clicked:", option.text, "Value:", option.value)
							print("Multi-select mode:", multiSelect)
							print("Current selected values:", table.concat(selectedValues, ", "))
							
							-- Set preventAutoClose flag for multi-select
							if multiSelect then
								preventAutoClose = true
								print("Set preventAutoClose = true for multi-select")
							end
							
							if multiSelect then
								-- Multi-select mode - dropdown stays open
								local index = nil
								for j, val in ipairs(selectedValues) do
									if val == option.value then
										index = j
										break
									end
								end
								
								if index then
									-- Remove from selection
									table.remove(selectedValues, index)
									checkmark.Text = ""
									optionButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
									print("Removed from selection:", option.value)
								else
									-- Add to selection
									table.insert(selectedValues, option.value)
									checkmark.Text = "✓"
									optionButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
									print("Added to selection:", option.value)
								end
								
							else
								-- Single select mode
								selectedValues = {option.value}
								print("Single select - set to:", option.value)
								
								-- Update all checkmarks and colors
								for _, child in pairs(optionsContainer:GetChildren()) do
									if child:IsA("TextButton") then
										local childCheckmark = child:FindFirstChild("TextLabel")
										if childCheckmark then
											-- Find the corresponding option for this button
											local childOptionValue = child:GetAttribute("OptionValue")
											if childOptionValue == option.value then
												childCheckmark.Text = "✓"
												child.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
											else
												childCheckmark.Text = ""
												child.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
											end
										end
									end
								end
								
								-- Close dropdown for single select
								print("Single select: Closing dropdown in 0.15 seconds...")
								spawn(function()
									wait(0.15)
									if isOpen and not preventAutoClose then
										print("Actually closing dropdown now...")
										toggleDropdown()
									end
								end)
							end
							
							-- Update display text
							updateDisplayText()
							print("Updated display text")
							
							-- Call user callback
							print("Calling user callback...")
							local success, errorMsg = pcall(function()
								callback(selectedValues, option.value)
							end)
							
							if not success then
								warn("SelectBox callback error:", errorMsg)
							else
								print("Callback executed successfully")
							end
							
							-- Reset flag after processing complete
							spawn(function()
								wait(0.3) -- Reset after longer delay
								preventAutoClose = false
								print("Reset preventAutoClose flag")
							end)
							
							print("=== REFRESHED OPTION CLICK END ===")
						end)
					end
				end,
				Disconnect = function()
					if outsideConnection then
						outsideConnection:Disconnect()
					end
					-- Clean up dropdown from ScreenGui
					if dropdownFrame and dropdownFrame.Parent then
						dropdownFrame:Destroy()
					end
				end
			}
		end

		function tabAPI:AddToggle(config)
			-- Default config
			local text = config.Name or config.Text or "Toggle"
			local defaultValue = config.Default or false
			local callback = config.Callback or function() end
			
			-- Toggle state
			local isToggled = defaultValue
			
			-- Main toggle container
			local toggleContainer = Instance.new("Frame")
			toggleContainer.Size = UDim2.new(1, -20, 0, 30)
			toggleContainer.Position = UDim2.new(0, 10, 0, tabCurrentY)
			toggleContainer.BackgroundTransparency = 1
			toggleContainer.ZIndex = 3
			toggleContainer.Parent = tabContent
			
			-- Toggle label
			local toggleLabel = Instance.new("TextLabel")
			toggleLabel.Size = UDim2.new(1, -60, 1, 0)
			toggleLabel.Position = UDim2.new(0, 0, 0, 0)
			toggleLabel.BackgroundTransparency = 1
			toggleLabel.Text = text
			toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
			toggleLabel.Font = Enum.Font.SourceSans
			toggleLabel.TextSize = 16
			toggleLabel.ZIndex = 4
			toggleLabel.Parent = toggleContainer
			
			-- Toggle switch background
			local toggleBg = Instance.new("Frame")
			toggleBg.Size = UDim2.new(0, 50, 0, 24)
			toggleBg.Position = UDim2.new(1, -50, 0.5, -12)
			toggleBg.BackgroundColor3 = isToggled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
			toggleBg.BorderSizePixel = 0
			toggleBg.ZIndex = 4
			toggleBg.Parent = toggleContainer
			
			-- Round corners for toggle background
			local toggleBgCorner = Instance.new("UICorner")
			toggleBgCorner.CornerRadius = UDim.new(0, 12)
			toggleBgCorner.Parent = toggleBg
			
			-- Toggle switch button (circle)
			local toggleButton = Instance.new("TextButton")
			toggleButton.Size = UDim2.new(0, 20, 0, 20)
			toggleButton.Position = isToggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
			toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggleButton.BorderSizePixel = 0
			toggleButton.Text = ""
			toggleButton.ZIndex = 5
			toggleButton.Parent = toggleBg
			
			-- Round corners for toggle button
			local toggleButtonCorner = Instance.new("UICorner")
			toggleButtonCorner.CornerRadius = UDim.new(0, 10)
			toggleButtonCorner.Parent = toggleButton
			
			-- Function to update toggle appearance
			local function updateToggleAppearance()
				local targetBgColor = isToggled and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(100, 100, 100)
				local targetPosition = isToggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
				
				print("🎨 Updating toggle appearance for '" .. text .. "':")
				print("   isToggled:", isToggled)
				print("   targetBgColor:", targetBgColor)
				print("   targetPosition:", targetPosition)
				print("   Current toggleBg color:", toggleBg.BackgroundColor3)
				print("   Current toggleButton position:", toggleButton.Position)
				
				-- Immediately update the background color (no animation for SetValue calls)
				toggleBg.BackgroundColor3 = targetBgColor
				print("   ✅ Background color updated to:", toggleBg.BackgroundColor3)
				
				-- Immediately update the button position (no animation for SetValue calls)
				toggleButton.Position = targetPosition
				print("   ✅ Button position updated to:", toggleButton.Position)
				
				-- Also animate for smooth visual feedback
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
				
				print("   🎬 Tweens started for smooth animation")
			end
			
			-- Toggle click handler
			toggleButton.MouseButton1Click:Connect(function()
				isToggled = not isToggled
				updateToggleAppearance()
				
				-- Call user callback
				local success, errorMsg = pcall(function()
					callback(isToggled)
				end)
				
				if not success then
					warn("Toggle callback error:", errorMsg)
				end
				
				print("Toggle '" .. text .. "' changed to:", isToggled)
			end)
			
			-- Also allow clicking the background to toggle
			toggleBg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					isToggled = not isToggled
					updateToggleAppearance()
					
					-- Call user callback
					local success, errorMsg = pcall(function()
						callback(isToggled)
					end)
					
					if not success then
						warn("Toggle callback error:", errorMsg)
					end
					
					print("Toggle '" .. text .. "' changed to:", isToggled)
				end
			end)
			
			-- Hover effects
			toggleButton.MouseEnter:Connect(function()
				local hoverTween = game:GetService("TweenService"):Create(
					toggleButton,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{Size = UDim2.new(0, 22, 0, 22)}
				)
				hoverTween:Play()
			end)
			
			toggleButton.MouseLeave:Connect(function()
				local hoverTween = game:GetService("TweenService"):Create(
					toggleButton,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{Size = UDim2.new(0, 20, 0, 20)}
				)
				hoverTween:Play()
			end)
			
			-- Update posisi Y untuk elemen berikutnya
			tabCurrentY = tabCurrentY + 35
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
			
			-- Create toggle API object
			local toggleAPI = {}
			
			-- GetValue function (outside of return)
			function toggleAPI:GetValue()
				return isToggled
			end
			
			-- SetValue function (outside of return)
			function toggleAPI:SetValue(newValue)
				-- Simplified SetValue method inspired by Rayfield's clean approach
				print("🔧 Toggle '" .. text .. "' SetValue called with:", newValue, "(" .. type(newValue) .. ")")
				
				-- Handle toggle object detection (from previous debugging)
				if type(newValue) == "table" and newValue.GetValue and type(newValue.GetValue) == "function" then
					warn("🚨 ERROR: You're passing a TOGGLE OBJECT to SetValue!")
					warn("   Use: toggle:SetValue(true) ✅ NOT: toggle:SetValue(anotherToggle) ❌")
					
					-- Auto-fix: extract boolean value
					local success, toggleValue = pcall(function() return newValue:GetValue() end)
					if success and type(toggleValue) == "boolean" then
						print("   🛠️ Auto-fix: Extracted boolean value:", toggleValue)
						newValue = toggleValue
					else
						warn("   ❌ Cannot extract boolean from toggle object!")
						return
					end
				end
				
				-- Simple type conversion (inspired by Rayfield's simplicity)
				local boolValue
				if type(newValue) == "boolean" then
					boolValue = newValue
				elseif type(newValue) == "string" then
					boolValue = (newValue:lower() == "true")
				elseif type(newValue) == "number" then
					boolValue = (newValue ~= 0)
				else
					warn("Toggle SetValue: Expected boolean, got " .. type(newValue))
					return
				end
				
				-- Update state and UI (following Rayfield's pattern)
				local oldValue = isToggled
				isToggled = boolValue
				
				print("   Changed from", oldValue, "to", isToggled)
				
				-- Update visual appearance immediately
				updateToggleAppearance()
				
				print("   ✅ Toggle '" .. text .. "' successfully set to:", isToggled)
			end
			
			-- SetText function (outside of return)
			function toggleAPI:SetText(newText)
				text = newText
				toggleLabel.Text = newText
			end
			
			-- Return toggle API object
			return toggleAPI
		end

		function tabAPI:AddTextBox(config)
			-- Default config
			local placeholder = config.Placeholder or "Enter text..."
			local defaultText = config.Default or ""
			local callback = config.Callback or function() end
			local maxLength = config.MaxLength or 100
			local multiline = config.Multiline or false
			
			-- TextBox state
			local currentText = defaultText
			
			-- Main textbox container
			local textBoxContainer = Instance.new("Frame")
			textBoxContainer.Size = UDim2.new(1, -20, 0, multiline and 80 or 30)
			textBoxContainer.Position = UDim2.new(0, 10, 0, tabCurrentY)
			textBoxContainer.BackgroundTransparency = 1
			textBoxContainer.ZIndex = 3
			textBoxContainer.Parent = tabContent
			
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
			textBox.TextSize = 14
			textBox.TextXAlignment = Enum.TextXAlignment.Left
			textBox.TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
			textBox.MultiLine = multiline
			textBox.TextWrapped = multiline
			textBox.ClearTextOnFocus = false
			textBox.ZIndex = 4
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
				charCounter.TextSize = 12
				charCounter.TextXAlignment = Enum.TextXAlignment.Right
				charCounter.ZIndex = 5
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
			
			-- Update posisi Y untuk elemen berikutnya
			tabCurrentY = tabCurrentY + (multiline and 90 or 40)
			
			-- Update canvas size jika tab ini sedang aktif
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
			
			-- Return TextBox API
			return {
				GetText = function()
					return currentText
				end,
				SetText = function(newText)
					textBox.Text = tostring(newText or "")
					currentText = textBox.Text
					updateCharCounter()
				end,
				Clear = function()
					textBox.Text = ""
					currentText = ""
					updateCharCounter()
				end,
				SetPlaceholder = function(newPlaceholder)
					textBox.PlaceholderText = tostring(newPlaceholder or "")
				end,
				Focus = function()
					textBox:CaptureFocus()
				end,
				Blur = function()
					textBox:ReleaseFocus()
				end
			}
		end

		function tabAPI:AddNumberBox(config)
			-- Default config
			local placeholder = config.Placeholder or "Enter number..."
			local defaultValue = config.Default or 0
			local callback = config.Callback or function() end
			local minValue = config.Min or -math.huge
			local maxValue = config.Max or math.huge
			local increment = config.Increment or 1
			local decimals = config.Decimals or 0
			
			-- NumberBox state
			local currentValue = defaultValue
			
			-- Main numberbox container
			local numberBoxContainer = Instance.new("Frame")
			numberBoxContainer.Size = UDim2.new(1, -20, 0, 30)
			numberBoxContainer.Position = UDim2.new(0, 10, 0, tabCurrentY)
			numberBoxContainer.BackgroundTransparency = 1
			numberBoxContainer.ZIndex = 3
			numberBoxContainer.Parent = tabContent
			
			-- Number input box
			local numberBox = Instance.new("TextBox")
			numberBox.Size = UDim2.new(1, -60, 1, 0)
			numberBox.Position = UDim2.new(0, 0, 0, 0)
			numberBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			numberBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
			numberBox.BorderSizePixel = 1
			numberBox.Text = decimals > 0 and string.format("%." .. decimals .. "f", defaultValue) or tostring(defaultValue)
			numberBox.PlaceholderText = placeholder
			numberBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			numberBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
			numberBox.Font = Enum.Font.SourceSans
			numberBox.TextSize = 14
			numberBox.TextXAlignment = Enum.TextXAlignment.Center
			numberBox.TextYAlignment = Enum.TextYAlignment.Center
			numberBox.ClearTextOnFocus = false
			numberBox.ZIndex = 4
			numberBox.Parent = numberBoxContainer
			
			-- Round corners for number box
			local numberCorner = Instance.new("UICorner")
			numberCorner.CornerRadius = UDim.new(0, 4)
			numberCorner.Parent = numberBox
			
			-- Increment button (up arrow)
			local incrementBtn = Instance.new("TextButton")
			incrementBtn.Size = UDim2.new(0, 25, 0, 14)
			incrementBtn.Position = UDim2.new(1, -30, 0, 1)
			incrementBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			incrementBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
			incrementBtn.BorderSizePixel = 1
			incrementBtn.Text = "▲"
			incrementBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			incrementBtn.Font = Enum.Font.SourceSans
			incrementBtn.TextSize = 10
			incrementBtn.ZIndex = 4
			incrementBtn.Parent = numberBoxContainer
			
			-- Decrement button (down arrow)
			local decrementBtn = Instance.new("TextButton")
			decrementBtn.Size = UDim2.new(0, 25, 0, 14)
			decrementBtn.Position = UDim2.new(1, -30, 0, 15)
			decrementBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			decrementBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
			decrementBtn.BorderSizePixel = 1
			decrementBtn.Text = "▼"
			decrementBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			decrementBtn.Font = Enum.Font.SourceSans
			decrementBtn.TextSize = 10
			decrementBtn.ZIndex = 4
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
			
			-- Update position Y for next element
			-- Use fixed spacing like other components
			tabCurrentY = tabCurrentY + 40
			
			-- Update canvas size for active tab
			if tabContent == activeTab then
				currentY = tabCurrentY
				api:UpdateWindowSize()
			end
			
			-- Return NumberBox API
			return {
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
				end
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
			print("Tab activated:", tabName)
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

		-- Return tab API object
		return tabAPI
	end

	return api
end

return EzUI
