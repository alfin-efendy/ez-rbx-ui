local Label = {}

function Label:Init(_window)
    local tab = _window:AddTab({
        Name = "Label",
        Icon = "🏷️"
    })

    -- Basic static labels
    tab:AddLabel("Label Component Examples")
    tab:AddSeparator()
    
    -- Accordion: Basic Labels
   self:AddSectionBasic(tab)
    
    -- Accordion: Status Labels
    self:AddSectionStatus(tab)
    
    -- Accordion: Dynamic Time Labels
    self:AddSectionDynamic(tab)
    
    -- Accordion: System Stats
    self:AddSectionStatistics(tab)
    
    -- Accordion: Player Information
    self:AddSectionPlayerInfo(tab)
    
    -- Accordion: Interactive Labels (SetText, GetText, SetTextSize)
    self:AddSectionInteractive(tab)

    -- Accordion: Usage Tips
    self:AddSectionTips(tab)
end

function Label:AddSectionBasic(tab)
     local accordion = tab:AddAccordion({
        Name = "Basic Labels",
        Icon = "📄",
    })
    
    accordion:AddLabel("This is a simple static text label")
    accordion:AddLabel("✨ Labels support emoji and unicode characters")
    accordion:AddLabel("You can add as many labels as you need")
    accordion:AddLabel("Labels are perfect for instructions")
    
    -- Examples with Size parameter
    accordion:AddSeparator()
    accordion:AddLabel("📏 Labels with custom sizes:")
    accordion:AddLabel({Text = "Small text (size 12)", Size = 12})
    accordion:AddLabel({Text = "Default text (size 14)"})
    accordion:AddLabel({Text = "Large text (size 18)", Size = 18})
    accordion:AddLabel({Text = "Extra large text (size 22)", Size = 22})
    
    -- Examples with Color parameter
    accordion:AddSeparator()
    accordion:AddLabel("🎨 Labels with custom colors:")
    accordion:AddLabel({Text = "Red label", Color = Color3.fromRGB(255, 85, 85)})
    accordion:AddLabel({Text = "Green label", Color = Color3.fromRGB(85, 255, 85)})
    accordion:AddLabel({Text = "Blue label", Color = Color3.fromRGB(85, 170, 255)})
    accordion:AddLabel({Text = "Yellow label", Color = Color3.fromRGB(255, 255, 85)})
    accordion:AddLabel({Text = "Purple label", Color = Color3.fromRGB(170, 85, 255)})
    
    -- Examples with both Size and Color
    accordion:AddSeparator()
    accordion:AddLabel("✨ Combined: Size + Color")
    accordion:AddLabel({
        Text = "Big Red Warning!", 
        Size = 20, 
        Color = Color3.fromRGB(255, 85, 85)
    })
    accordion:AddLabel({
        Text = "Small Green Success", 
        Size = 12, 
        Color = Color3.fromRGB(85, 255, 85)
    })
end

function Label:AddSectionStatus(tab)
    local accordion = tab:AddAccordion({
        Name = "Status Labels",
        Icon = "🚦",
        Open = false
    })
    
    accordion:AddLabel("ℹ️ Info: Labels are read-only text elements")
    accordion:AddLabel("⚠️ Warning: Dynamic labels update automatically")
    accordion:AddLabel("✅ Success: Your configuration is saved")
    accordion:AddLabel("❌ Error: Something went wrong")
    accordion:AddLabel("🔔 Notification: You have 3 new messages")
    accordion:AddLabel("⚡ Alert: High performance mode enabled")
end

function Label:AddSectionDynamic(tab)
    local accordion = tab:AddAccordion({
        Name = "Dynamic Labels",
        Icon = "🔄",
        Open = false
    })
    
    accordion:AddLabel(function()
        return "⏰ Current Time: " .. os.date("%X")
    end)
    
    accordion:AddLabel(function()
        return "📅 Current Date: " .. os.date("%x")
    end)
    
    accordion:AddLabel(function()
        return "🕐 Full Date: " .. os.date("%c")
    end)
    
    accordion:AddLabel(function()
        return "⏱️ Tick Count: " .. string.format("%.2f", tick())
    end)
    
    local startTime = tick()
    accordion:AddLabel(function()
        return "⏳ Uptime: " .. string.format("%.0f", tick() - startTime) .. " seconds"
    end)
end

function Label:AddSectionStatistics(tab)
    local accordion = tab:AddAccordion({
        Name = "System Statistics",
        Icon = "📈",
        Open = false
    })
    
    accordion:AddLabel(function()
        local fps = 1 / game:GetService("RunService").RenderStepped:Wait()
        return "📊 FPS: " .. string.format("%.0f", fps)
    end)
    
    accordion:AddLabel(function()
        local stats = game:GetService("Stats")
        local memory = stats:GetTotalMemoryUsageMb()
        return "💾 Memory Usage: " .. string.format("%.2f", memory) .. " MB"
    end)
    
    accordion:AddLabel(function()
        local stats = game:GetService("Stats")
        local heartbeat = stats:GetTotalMemoryUsageMb()
        return "💓 Heartbeat: Active"
    end)
end

function Label:AddSectionPlayerInfo(tab)
    local accordion = tab:AddAccordion({
        Name = "Player Information",
        Icon = "🎮",
        Open = false
    })
    
    accordion:AddLabel(function()
        local player = game.Players.LocalPlayer
        return "👤 Username: " .. player.Name
    end)
    
    accordion:AddLabel(function()
        local player = game.Players.LocalPlayer
        return "🆔 User ID: " .. player.UserId
    end)
    
    accordion:AddLabel(function()
        local player = game.Players.LocalPlayer
        return "🎮 Display Name: " .. player.DisplayName
    end)
    
    accordion:AddLabel(function()
        local player = game.Players.LocalPlayer
        return "🎂 Account Age: " .. player.AccountAge .. " days"
    end)
    
    accordion:AddLabel(function()
        local player = game.Players.LocalPlayer
        return "⭐ Membership: " .. (player.MembershipType.Name or "None")
    end)
end

function Label:AddSectionInteractive(tab)
    local accordion = tab:AddAccordion({
        Name = "Interactive Labels",
        Icon = "🎛️",
        Open = false
    })
    
    -- Example 1: SetText() method
    accordion:AddLabel("🔧 Example 1: SetText() Method")
    accordion:AddSeparator()
    
    local dynamicLabel = accordion:AddLabel("Initial text - will change!")
    local clickCount = 0
    
    accordion:AddButton({
        Text = "Change Label Text",
        Callback = function()
            clickCount = clickCount + 1
            dynamicLabel:SetText("✨ Button clicked " .. clickCount .. " times!")
        end
    })
    
    accordion:AddSeparator()
    
    -- Example 2: GetText() method
    accordion:AddLabel("📖 Example 2: GetText() Method")
    accordion:AddSeparator()
    
    local sourceLabel = accordion:AddLabel("This is the source text")
    local displayLabel = accordion:AddLabel("Current text: N/A")
    
    accordion:AddButton({
        Text = "Get & Display Text",
        Callback = function()
            local text = sourceLabel:GetText()
            displayLabel:SetText("📝 Retrieved: '" .. text .. "'")
        end
    })
    
    accordion:AddSeparator()
    
    -- Example 3: SetTextSize() method
    accordion:AddLabel("📏 Example 3: SetTextSize() Method")
    accordion:AddSeparator()
    
    local sizeLabel = accordion:AddLabel("Resize me with buttons below!")
    local currentSize = 14
    
    accordion:AddButton({
        Text = "Increase Size (+2)",
        Callback = function()
            currentSize = math.min(currentSize + 2, 24)
            sizeLabel:SetTextSize(currentSize)
            sizeLabel:SetText("Current size: " .. currentSize .. "px")
        end
    })
    
    accordion:AddButton({
        Text = "Decrease Size (-2)",
        Callback = function()
            currentSize = math.max(currentSize - 2, 10)
            sizeLabel:SetTextSize(currentSize)
            sizeLabel:SetText("Current size: " .. currentSize .. "px")
        end
    })
    
    accordion:AddButton({
        Text = "Reset Size (14px)",
        Callback = function()
            currentSize = 14
            sizeLabel:SetTextSize(currentSize)
            sizeLabel:SetText("Resize me with buttons below!")
        end
    })
    
    accordion:AddSeparator()
    
    -- Example 4: Combining all methods
    accordion:AddLabel("🎨 Example 4: Combined Methods")
    accordion:AddSeparator()
    
    local comboLabel = accordion:AddLabel("Interactive label demo")
    local messages = {
        "🎉 Welcome to EzUI!",
        "🚀 Modular UI Library",
        "💡 Easy to use",
        "⚡ Fast & Efficient",
        "🎯 Feature Rich"
    }
    local messageIndex = 1
    local sizes = {12, 14, 16, 18}
    local sizeIndex = 2
    
    accordion:AddButton({
        Text = "Next Message",
        Callback = function()
            messageIndex = (messageIndex % #messages) + 1
            local text = messages[messageIndex]
            comboLabel:SetText(text)
        end
    })
    
    accordion:AddButton({
        Text = "Cycle Text Size",
        Callback = function()
            sizeIndex = (sizeIndex % #sizes) + 1
            local size = sizes[sizeIndex]
            comboLabel:SetTextSize(size)
        end
    })
    
    accordion:AddButton({
        Text = "Show Current State",
        Callback = function()
            local text = comboLabel:GetText()
            comboLabel:SetText("📊 Text: '" .. text .. "' | Size: " .. sizes[sizeIndex] .. "px")
        end
    })
end

function Label:AddSectionTips(tab)
    tab:AddLabel("📝 How to use Labels:")
    tab:AddSeparator()
    tab:AddLabel("  • Use static labels for fixed text")
    tab:AddLabel("  • Use dynamic labels for real-time data")
    tab:AddLabel("  • Combine with separators for organization")
    tab:AddLabel("  • Add emoji for visual appeal")
    tab:AddLabel("  • Use accordions to group related labels")
    tab:AddSeparator()
    tab:AddLabel("🎯 Best Practices:")
    tab:AddLabel("  • Keep label text concise and clear")
    tab:AddLabel("  • Use consistent formatting")
    tab:AddLabel("  • Update dynamic labels efficiently")
    tab:AddLabel("  • Consider performance with many labels")
    tab:AddSeparator()
    tab:AddLabel("🔧 Label Methods:")
    tab:AddLabel("  • SetText(text) - Change label text")
    tab:AddLabel("  • GetText() - Retrieve current text")
    tab:AddLabel("  • SetTextSize(size) - Adjust font size")
    tab:AddLabel("  • Combine methods for dynamic interactions")
    tab:AddSeparator()
    tab:AddLabel("🎨 Label Parameters:")
    tab:AddLabel("  • Text - The label text (string or function)")
    tab:AddLabel("  • Size - Custom font size (number, default: 14/16)")
    tab:AddLabel("  • Color - Custom text color (Color3)")
    tab:AddSeparator()
    
    -- Examples at tab level with custom size and color
    tab:AddLabel({
        Text = "💡 Example: Large blue heading", 
        Size = 20, 
        Color = Color3.fromRGB(85, 170, 255)
    })
    
    tab:AddLabel({
        Text = "⚠️ Example: Small yellow warning", 
        Size = 12, 
        Color = Color3.fromRGB(255, 220, 100)
    })
end

return Label