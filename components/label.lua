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
	local textSize = config.Size or config.TextSize -- Support both Size and TextSize
	local textColor = config.Color or config.TextColor -- Support both Color and TextColor
	
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
			warn("Label:Create - Parent is a table but no GUI object found. Keys:", table.concat(keys, ", "))
			parentContainer = nil
		end
	end
	
	-- Validate parent is an Instance
	if parentContainer and not typeof(parentContainer) == "Instance" then
		warn("Label:Create - Parent must be an Instance, got:", typeof(parentContainer))
		parentContainer = nil
	end
	
	local label = Instance.new("TextLabel")
	if isForAccordion then
		-- Calculate height based on text size with some padding
		local calculatedTextSize = textSize or 14
		local labelHeight = math.max(calculatedTextSize + 8, 20) -- Minimum 20px height
		label.Size = UDim2.new(1, 0, 0, labelHeight)
		-- Don't set Position for accordion labels - let UIListLayout handle it
		label.TextSize = calculatedTextSize
		label.ZIndex = 5
		-- No debug background needed
	else
		label.Size = UDim2.new(1, -20, 0, 30)
		label.Position = UDim2.new(0, 10, 0, currentY)
		label.TextSize = textSize or 16
		label.ZIndex = 3
		label:SetAttribute("ComponentStartY", currentY)
	end
	label.BackgroundTransparency = 1
	local labelText = type(text) == "function" and text() or text
	label.Text = tostring(labelText or "")
	label.TextColor3 = textColor or Colors.Text.Primary
	
	-- Debug: Ensure text is visible by using a contrasting color for accordion labels
	if isForAccordion and not textColor then
		label.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for accordion labels
	end
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.SourceSans
	label.Visible = true -- Ensure label is visible
	label.Parent = parentContainer
	
	-- Store the text source (function or string)
	local textSource = text
	local updateConnection = nil
	
	-- Create Label API
	local labelAPI = {
		Label = label
	}
	
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
	
	function labelAPI:SetText(newText)
		textSource = newText
		updateText()
	end
	
	function labelAPI:GetText()
		return label.Text
	end
	
	function labelAPI:SetTextColor(color)
		label.TextColor3 = color
	end
	
	function labelAPI:SetTextSize(size)
		label.TextSize = size
		-- Update label height if in accordion
		if isForAccordion then
			local labelHeight = math.max(size + 8, 20)
			label.Size = UDim2.new(1, 0, 0, labelHeight)
		end
	end
	
	function labelAPI:GetHeight()
		return label.AbsoluteSize.Y
	end
	
	-- Start auto-update if text is a function
	function labelAPI:StartAutoUpdate(interval)
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
	
	function labelAPI:StopAutoUpdate()
		if updateConnection then
			updateConnection:Disconnect()
			updateConnection = nil
		end
	end
	
	function labelAPI:Update()
		updateText()
	end
	
	-- Cleanup when label is destroyed
	label.AncestryChanged:Connect(function()
		if not label.Parent then
			labelAPI:StopAutoUpdate()
		end
	end)
	
	-- If text is a function, start auto-update by default
	if type(textSource) == "function" then
		labelAPI:StartAutoUpdate(1)
	end
	
	return labelAPI
end

return Label
