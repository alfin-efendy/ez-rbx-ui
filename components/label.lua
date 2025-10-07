--[[
	Label Component
	EzUI Library - Modular Component
	
	Creates a text label with optional dynamic function support
]]
local Label = {}

local Colors

function Label:Init(_colors)
    Colors = _colors
end

function Label:Create(config)
	local text = config.Text or ""
	local parentContainer = config.Parent
	local currentY = config.Y or 0
	local isForAccordion = config.IsForAccordion or false
	
	local label = Instance.new("TextLabel")
	if isForAccordion then
		label.Size = UDim2.new(1, 0, 0, 25)
		label.Position = UDim2.new(0, 0, 0, currentY)
		label.TextSize = 14
		label.ZIndex = 5
	else
		label.Size = UDim2.new(1, -20, 0, 30)
		label.Position = UDim2.new(0, 10, 0, currentY)
		label.TextSize = 16
		label.ZIndex = 3
		label:SetAttribute("ComponentStartY", currentY)
	end
	label.BackgroundTransparency = 1
	label.Text = type(text) == "function" and text() or text
	label.TextColor3 = Colors.Text.Primary
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.SourceSans
	label.Parent = parentContainer
	
	-- Store the text source (function or string)
	local textSource = text
	local updateConnection = nil
	
	-- Create Label API
	local labelAPI = {}
	
	-- Function to update text from source
	local function updateText()
		if type(textSource) == "function" then
			local success, result = pcall(textSource)
			if success then
				label.Text = tostring(result)
			else
				warn("Label dynamic text error:", result)
				label.Text = "[Error]"
			end
		else
			label.Text = tostring(textSource or "")
		end
	end
	
	labelAPI.SetText = function(newText)
		textSource = newText
		updateText()
	end
	
	labelAPI.GetText = function()
		return label.Text
	end
	
	labelAPI.SetTextColor = function(color)
		label.TextColor3 = color
	end
	
	labelAPI.SetTextSize = function(size)
		label.TextSize = size
	end
	
	-- Start auto-update if text is a function
	labelAPI.StartAutoUpdate = function(interval)
		interval = interval or 1
		
		if updateConnection then
			updateConnection:Disconnect()
		end
		
		if type(textSource) == "function" then
			local RunService = game:GetService("RunService")
			local lastUpdate = 0
			
			updateConnection = RunService.Heartbeat:Connect(function()
				local currentTime = tick()
				if currentTime - lastUpdate >= interval then
					updateText()
					lastUpdate = currentTime
				end
			end)
		end
	end
	
	labelAPI.StopAutoUpdate = function()
		if updateConnection then
			updateConnection:Disconnect()
			updateConnection = nil
		end
	end
	
	labelAPI.Update = function()
		updateText()
	end
	
	-- Cleanup when label is destroyed
	label.AncestryChanged:Connect(function()
		if not label.Parent then
			labelAPI.StopAutoUpdate()
		end
	end)
	
	-- If text is a function, start auto-update by default
	if type(textSource) == "function" then
		labelAPI.StartAutoUpdate(1)
	end
	
	return labelAPI
end

return Label
