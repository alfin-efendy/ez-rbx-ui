local Button = {}

function Button:Init(_window)
    local tab = _window:AddTab({
        Name = "Button",
        Icon = "🔘"
    })

    -- Basic intro
    tab:AddLabel("Button Component Examples")
    tab:AddSeparator()
    
    -- Accordion: Basic Buttons
    self:AddSectionBasic(tab)
    
    -- Accordion: Button Variants
    self:AddSectionVariants(tab)
    
    -- Accordion: Interactive Buttons
    self:AddSectionInteractive(tab)
    
    -- Accordion: Button States
    self:AddSectionStates(tab)
    
    -- Accordion: Callback Examples
    self:AddSectionCallbacks(tab)
    
    -- Accordion: Button Configuration Options
    self:AddSectionConfiguration(tab)

    -- Accordion: Usage Tips
    self:AddSectionTips(tab)
end

function Button:AddSectionBasic(tab)
    local accordion = tab:AddAccordion({
        Name = "Basic Buttons",
        Icon = "🔴",
    })
    
    accordion:AddLabel("Click any button below to see it in action:")
    accordion:AddSeparator()
    
    -- Simple button with text callback
    accordion:AddButton({
        Text = "Simple Button",
        Callback = function()
            print("Simple button clicked!")
        end
    })
    
    -- Button with emoji
    accordion:AddButton({
        Text = "🎉 Button with Emoji",
        Callback = function()
            print("Emoji button clicked! 🎉")
        end
    })
    
    -- Button with longer text
    accordion:AddButton({
        Text = "Button with Longer Text",
        Callback = function()
            print("Long text button clicked!")
        end
    })
    
    -- Button with very long text to test width handling
    accordion:AddButton({
        Text = "Button with Very Long Text to Test Width Handling",
        Callback = function()
            print("Very long text button clicked!")
        end
    })
    
    -- Multiple buttons in sequence
    accordion:AddSeparator()
    accordion:AddLabel("Multiple buttons:")
    
    accordion:AddButton({
        Text = "Button 1",
        Callback = function()
            print("First button clicked!")
        end
    })
    
    accordion:AddButton({
        Text = "Button 2", 
        Callback = function()
            print("Second button clicked!")
        end
    })
    
    accordion:AddButton({
        Text = "Button 3",
        Callback = function()
            print("Third button clicked!")
        end
    })
end

function Button:AddSectionVariants(tab)
    local accordion = tab:AddAccordion({
        Name = "Button Variants",
        Icon = "🎨",
    })
    
    accordion:AddLabel("Different button styles using the Variant parameter:")
    accordion:AddSeparator()
    
    -- Primary variant (default)
    accordion:AddButton({
        Text = "Primary Button",
        Variant = "primary",
        Callback = function()
            print("Primary button clicked!")
        end
    })
    
    -- Secondary variant
    accordion:AddButton({
        Text = "Secondary Button",
        Variant = "secondary",
        Callback = function()
            print("Secondary button clicked!")
        end
    })
    
    -- Success variant
    accordion:AddButton({
        Text = "Success Button",
        Variant = "success",
        Callback = function()
            print("Success button clicked!")
        end
    })
    
    -- Warning variant
    accordion:AddButton({
        Text = "Warning Button",
        Variant = "warning",
        Callback = function()
            print("Warning button clicked!")
        end
    })
    
    -- Danger variant
    accordion:AddButton({
        Text = "Danger Button",
        Variant = "danger",
        Callback = function()
            print("Danger button clicked!")
        end
    })
    
    -- Info variant
    accordion:AddButton({
        Text = "Info Button",
        Variant = "info",
        Callback = function()
            print("Info button clicked!")
        end
    })
    
    -- Light variant
    accordion:AddButton({
        Text = "Light Button",
        Variant = "light",
        Callback = function()
            print("Light button clicked!")
        end
    })
    
    -- Dark variant
    accordion:AddButton({
        Text = "Dark Button",
        Variant = "dark",
        Callback = function()
            print("Dark button clicked!")
        end
    })
    
    accordion:AddSeparator()
    
    -- Dynamic variant example
    accordion:AddLabel("🔄 Dynamic Variant Change:")
    local dynamicButton = accordion:AddButton({
        Text = "Click to Change Variant",
        Variant = "primary",
        Callback = function()
            print("Dynamic variant button clicked!")
        end
    })
    
    local variants = {"primary", "secondary", "success", "warning", "danger", "info", "light", "dark"}
    local currentVariantIndex = 1
    
    accordion:AddButton({
        Text = "Change Button Variant",
        Variant = "info",
        Callback = function()
            currentVariantIndex = (currentVariantIndex % #variants) + 1
            local newVariant = variants[currentVariantIndex]
            dynamicButton:SetVariant(newVariant)
            dynamicButton:SetText("Current: " .. newVariant:gsub("^%l", string.upper))
            print("Changed to " .. newVariant .. " variant!")
        end
    })
end

function Button:AddSectionInteractive(tab)
    local accordion = tab:AddAccordion({
        Name = "Interactive Buttons",
        Icon = "⚡",
        Open = false
    })
    
    -- Counter example
    accordion:AddLabel("🔢 Button Click Counter:")
    local clickCount = 0
    local counterLabel = accordion:AddLabel("Clicks: 0")
    
    accordion:AddButton({
        Text = "Click Me!",
        Callback = function()
            clickCount = clickCount + 1
            counterLabel:SetText("Clicks: " .. clickCount)
            print("Button clicked " .. clickCount .. " times!")
        end
    })
    
    accordion:AddButton({
        Text = "Reset Counter",
        Callback = function()
            clickCount = 0
            counterLabel:SetText("Clicks: 0")
            print("Counter reset!")
        end
    })
    
    accordion:AddSeparator()
    
    -- Text changing example
    accordion:AddLabel("📝 Dynamic Button Text:")
    local messages = {
        "Hello World!",
        "Button Magic ✨",
        "Click Again 👆",
        "Amazing! 🎊",
        "One More Time 🔄"
    }
    local messageIndex = 1
    local messageLabel = accordion:AddLabel("Message: " .. messages[messageIndex])
    
    accordion:AddButton({
        Text = "Next Message",
        Callback = function()
            messageIndex = (messageIndex % #messages) + 1
            local newMessage = messages[messageIndex]
            messageLabel:SetText("Message: " .. newMessage)
            print("New message: " .. newMessage)
        end
    })
    
    accordion:AddSeparator()
    
    -- Random number generator
    accordion:AddLabel("🎲 Random Number Generator:")
    local randomLabel = accordion:AddLabel("Number: ???")
    
    accordion:AddButton({
        Text = "Generate Random Number",
        Callback = function()
            local randomNum = math.random(1, 100)
            randomLabel:SetText("Number: " .. randomNum)
            print("Generated random number: " .. randomNum)
        end
    })
end

function Button:AddSectionStates(tab)
    local accordion = tab:AddAccordion({
        Name = "Button States & Methods",
        Icon = "🎛️",
        Open = false
    })
    
    accordion:AddLabel("🔧 Button API Methods:")
    accordion:AddSeparator()
    
    -- SetText() method example
    accordion:AddLabel("📝 SetText() Method:")
    local textButton = accordion:AddButton({
        Text = "Original Text",
        Callback = function()
            print("Text button clicked!")
        end
    })
    
    accordion:AddButton({
        Text = "Change Button Text",
        Callback = function()
            local newTexts = {"New Text!", "Changed Again!", "Different Text", "Back to Start"}
            local randomText = newTexts[math.random(1, #newTexts)]
            textButton:SetText(randomText)
            print("Button text changed to: " .. randomText)
        end
    })
    
    accordion:AddSeparator()
    
    -- GetText() method example
    accordion:AddLabel("📖 GetText() Method:")
    local sourceButton = accordion:AddButton({
        Text = "Source Button Text",
        Callback = function()
            print("Source button clicked!")
        end
    })
    
    local displayLabel = accordion:AddLabel("Current button text: ???")
    
    accordion:AddButton({
        Text = "Get Button Text",
        Callback = function()
            local buttonText = sourceButton:GetText()
            displayLabel:SetText("Current button text: \"" .. buttonText .. "\"")
            print("Retrieved button text: " .. buttonText)
        end
    })
    
    accordion:AddSeparator()
    
    -- SetCallback() method example
    accordion:AddLabel("🔄 SetCallback() Method:")
    local callbackButton = accordion:AddButton({
        Text = "Dynamic Callback Button",
        Callback = function()
            print("Original callback!")
        end
    })
    
    local callbackCount = 1
    accordion:AddButton({
        Text = "Change Callback",
        Callback = function()
            callbackCount = callbackCount + 1
            callbackButton:SetCallback(function()
                print("New callback #" .. callbackCount .. " executed!")
            end)
            print("Callback changed to #" .. callbackCount)
        end
    })
    
    accordion:AddSeparator()
    
    -- SetEnabled() method example
    accordion:AddLabel("🔒 SetEnabled() Method:")
    local enableButton = accordion:AddButton({
        Text = "Toggle Me!",
        Callback = function()
            print("Enabled button clicked!")
        end
    })
    
    local isEnabled = true
    accordion:AddButton({
        Text = "Toggle Enable/Disable",
        Callback = function()
            isEnabled = not isEnabled
            enableButton:SetEnabled(isEnabled)
            print("Button " .. (isEnabled and "enabled" or "disabled"))
        end
    })
end

function Button:AddSectionCallbacks(tab)
    local accordion = tab:AddAccordion({
        Name = "Callback Examples",
        Icon = "⚙️",
        Open = false
    })
    
    accordion:AddLabel("Different types of button callbacks:")
    accordion:AddSeparator()
    
    -- Simple print callback
    accordion:AddButton({
        Text = "Print Message",
        Callback = function()
            print("📢 Hello from button callback!")
        end
    })
    
    -- Callback with parameters
    local userData = {name = "Player", score = 0}
    accordion:AddButton({
        Text = "Update Score",
        Callback = function()
            userData.score = userData.score + 10
            print("🎯 " .. userData.name .. "'s score: " .. userData.score)
        end
    })
    
    -- Callback that calls other functions
    local function showAlert(message)
        print("🚨 ALERT: " .. message)
    end
    
    accordion:AddButton({
        Text = "Show Alert",
        Callback = function()
            showAlert("This is a custom alert message!")
        end
    })
    
    -- Callback with conditional logic
    local buttonPresses = 0
    accordion:AddButton({
        Text = "Smart Button",
        Callback = function()
            buttonPresses = buttonPresses + 1
            if buttonPresses == 1 then
                print("👋 First click! Welcome!")
            elseif buttonPresses <= 5 then
                print("👆 Click #" .. buttonPresses .. " - Keep going!")
            elseif buttonPresses == 10 then
                print("🎉 Wow! 10 clicks! You're persistent!")
            else
                print("🤖 Click #" .. buttonPresses .. " - I'm still counting...")
            end
        end
    })
    
    -- Callback that modifies UI
    local statusLabel = accordion:AddLabel("Status: Ready")
    accordion:AddButton({
        Text = "Update Status",
        Callback = function()
            local statuses = {
                "✅ Processing...",
                "⏳ Working...",
                "🔄 Loading...",
                "✨ Complete!",
                "📋 Ready"
            }
            local randomStatus = statuses[math.random(1, #statuses)]
            statusLabel:SetText("Status: " .. randomStatus)
            print("Status updated to: " .. randomStatus)
        end
    })
end

function Button:AddSectionConfiguration(tab)
    local accordion = tab:AddAccordion({
        Name = "Configuration Options",
        Icon = "⚙️",
        Open = false
    })
    
    accordion:AddLabel("📋 Button Configuration Parameters:")
    accordion:AddSeparator()
    
    accordion:AddLabel("🔤 Text Parameter:")
    accordion:AddLabel("  • Sets the button display text")
    accordion:AddLabel("  • Can be changed dynamically with SetText()")
    
    accordion:AddButton({
        Text = "Example: Custom Text",
        Callback = function()
            print("Button with custom text clicked!")
        end
    })
    
    accordion:AddSeparator()
    
    accordion:AddLabel("⚡ Callback Parameter:")
    accordion:AddLabel("  • Function executed when button is clicked")
    accordion:AddLabel("  • Can be changed with SetCallback()")
    
    accordion:AddButton({
        Text = "Example: Custom Callback",
        Callback = function()
            print("🎯 This is a custom callback function!")
            print("📝 You can put any code here")
            print("🔥 Multiple print statements work too!")
        end
    })
    
    accordion:AddSeparator()
    
    accordion:AddLabel("🎨 Variant Parameter (Optional):")
    accordion:AddLabel("  • Changes button appearance and color scheme")
    accordion:AddLabel("  • Options: primary, secondary, success, warning,")
    accordion:AddLabel("    danger, info, light, dark")
    accordion:AddLabel("  • Can be changed with SetVariant()")
    
    accordion:AddButton({
        Text = "Example: Success Variant",
        Variant = "success",
        Callback = function()
            print("Success variant button clicked!")
        end
    })
    
    accordion:AddSeparator()
    
    accordion:AddLabel("🏷️ Flag Parameter (Optional):")
    accordion:AddLabel("  • Links button to configuration system")
    accordion:AddLabel("  • Enables saving/loading button state")
    
    accordion:AddButton({
        Text = "Example: Button with Flag",
        Flag = "ExampleButtonFlag",
        Callback = function()
            print("Button with flag clicked! Flag: ExampleButtonFlag")
        end
    })
    
    accordion:AddSeparator()
    
    accordion:AddLabel("📍 Parent Parameter:")
    accordion:AddLabel("  • Determines where button is placed")
    accordion:AddLabel("  • Automatically set by accordion/tab")
    
    accordion:AddLabel("📏 Y Parameter:")
    accordion:AddLabel("  • Sets vertical position (auto-managed)")
    accordion:AddLabel("  • Used internally for layout")
end

function Button:AddSectionTips(tab)
    tab:AddLabel("📝 How to use Buttons:")
    tab:AddSeparator()
    tab:AddLabel("  • Use clear, action-oriented text")
    tab:AddLabel("  • Keep button text concise and descriptive")
    tab:AddLabel("  • Always provide meaningful callbacks")
    tab:AddLabel("  • Consider user feedback in callbacks")
    tab:AddSeparator()
    tab:AddLabel("🎯 Best Practices:")
    tab:AddLabel("  • Use verbs for button text (e.g., 'Save', 'Delete')")
    tab:AddLabel("  • Provide immediate feedback when clicked")
    tab:AddLabel("  • Group related buttons together")
    tab:AddLabel("  • Use separators to organize button sections")
    tab:AddSeparator()
    tab:AddLabel("🔧 Button Methods:")
    tab:AddLabel("  • SetText(text) - Change button display text")
    tab:AddLabel("  • GetText() - Get current button text")
    tab:AddLabel("  • SetCallback(function) - Change click handler")
    tab:AddLabel("  • SetEnabled(boolean) - Enable/disable button")
    tab:AddLabel("  • SetVariant(variant) - Change button style")
    tab:AddLabel("  • GetVariant() - Get current variant")
    tab:AddSeparator()
    tab:AddLabel("🎨 Button Parameters:")
    tab:AddLabel("  • Text - Button display text (string)")
    tab:AddLabel("  • Callback - Click handler function")
    tab:AddLabel("  • Variant - Button style (primary, secondary, etc.)")
    tab:AddLabel("  • Flag - Configuration flag (optional)")
    tab:AddSeparator()
    tab:AddLabel("🌈 Available Variants:")
    tab:AddLabel("  • primary (default) - Main action button")
    tab:AddLabel("  • secondary - Secondary action button")
    tab:AddLabel("  • success - Positive/confirmation actions")
    tab:AddLabel("  • warning - Caution/warning actions")
    tab:AddLabel("  • danger - Destructive/delete actions")
    tab:AddLabel("  • info - Informational actions")
    tab:AddLabel("  • light - Light colored button")
    tab:AddLabel("  • dark - Dark colored button")
    tab:AddSeparator()
    
    -- Example buttons at tab level
    tab:AddLabel("💡 Example: Tab-level buttons")
    
    tab:AddButton({
        Text = "🌟 Awesome Tab Button",
        Callback = function()
            print("🎉 Tab-level button clicked!")
        end
    })
    
    tab:AddButton({
        Text = "🚀 Another Tab Button", 
        Callback = function()
            print("💫 Second tab button activated!")
        end
    })
end

return Button