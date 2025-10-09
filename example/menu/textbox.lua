local TextBox = {}

function TextBox:Init(_window)
    local tab = _window:AddTab({
        Name = "TextBox",
        Icon = "📝"
    })

    -- Basic intro
    tab:AddLabel("TextBox Component Examples")
    tab:AddSeparator()
    
    -- Accordion: Basic TextBoxes
    self:AddSectionBasic(tab)
    
    -- Accordion: TextBox with Buttons
    self:AddSectionButtons(tab)
    
    -- Accordion: Multiline TextBoxes
    self:AddSectionMultiline(tab)
    
    -- Accordion: Validation & Input Types
    self:AddSectionValidation(tab)
    
    -- Accordion: Advanced Features
    self:AddSectionAdvanced(tab)
    
    -- Accordion: Form Examples
    self:AddSectionForms(tab)

    -- Accordion: Usage Tips
    self:AddSectionTips(tab)
end

function TextBox:AddSectionBasic(tab)
    local accordion = tab:AddAccordion({
        Name = "Basic TextBoxes",
        Icon = "📝",
    })
    
    accordion:AddLabel("Basic text input examples with different configurations:")
    accordion:AddSeparator()

    -- Basic TextBox with title
    accordion:AddTextBox({
        Name = "Username",
        Placeholder = "Enter your username...",
        Default = "",
        MaxLength = 50,
        Flag = "Username",
        Callback = function(text)
            print("Username changed:", text)
        end
    })

    -- TextBox without title (legacy style)
    accordion:AddTextBox({
        Placeholder = "Type something (no title)...",
        Default = "",
        Callback = function(text)
            print("No title TextBox:", text)
        end
    })

    -- TextBox with default value
    accordion:AddTextBox({
        Name = "Player Name",
        Placeholder = "Your display name...",
        Default = "Guest User",
        MaxLength = 30,
        Flag = "PlayerName",
        Callback = function(text)
            print("Player name changed:", text)
        end
    })

    -- Long title example  
    accordion:AddTextBox({
        Name = "Long Title Example for Testing",
        Placeholder = "This shows how long titles are handled...",
        Default = "",
        Flag = "LongTitle",
        Callback = function(text)
            print("Long title TextBox changed:", text)
        end
    })
end

function TextBox:AddSectionButtons(tab)
    local accordion = tab:AddAccordion({
        Name = "TextBox with Buttons",
        Icon = "🔘",
    })
    
    accordion:AddLabel("TextBoxes with integrated action buttons:")
    accordion:AddSeparator()

    -- TextBox with Submit Button
    accordion:AddTextBox({
        Name = "Message with Submit",
        Placeholder = "Type your message...",
        Default = "",
        MaxLength = 100,
        Flag = "MessageSubmit",
        Buttons = {
            {
                Text = "Submit",
                Variant = "primary",
                Callback = function(text, textBox)
                    print("✅ Submitted:", text)
                    textBox.Text = ""
                end
            }
        },
        Callback = function(text)
            print("Message text changed:", text)
        end
    })

    -- TextBox with Clear Button
    accordion:AddTextBox({
        Name = "Text with Clear",
        Placeholder = "Type something to clear...",
        Default = "Sample text",
        MaxLength = 50,
        Flag = "TextClear", 
        Buttons = {
            {
                Text = "Clear",
                Variant = "secondary",
                Callback = function(text, textBox)
                    textBox.Text = ""
                    print("🗑️ Text cleared")
                end
            }
        }
    })

    -- TextBox with Multiple Buttons
    accordion:AddTextBox({
        Name = "Multi-Button Example",
        Placeholder = "Enter command...",
        Default = "",
        MaxLength = 75,
        Flag = "MultiButton",
        Buttons = {
            {
                Text = "Send",
                Variant = "primary",
                Callback = function(text, textBox)
                    if #text > 0 then
                        print("📤 Sent:", text)
                        textBox.Text = ""
                    else
                        print("⚠️ Cannot send empty message")
                    end
                end
            },
            {
                Text = "Save", 
                Variant = "secondary",
                Callback = function(text, textBox)
                    print("💾 Saved:", text)
                end
            }
        },
        Callback = function(text)
            print("Command changed:", text)
        end
    })
end

function TextBox:AddSectionMultiline(tab)
    local accordion = tab:AddAccordion({
        Name = "Multiline TextBoxes",
        Icon = "📄",
    })
    
    accordion:AddLabel("TextBoxes with multiline support for larger text input:")
    accordion:AddSeparator()

    -- Basic multiline
    accordion:AddTextBox({
        Name = "Description",
        Placeholder = "Enter description...",
        Default = "",
        Multiline = true,
        MaxLength = 200,
        Flag = "Description",
        Callback = function(text)
            print("Description changed:", text)
        end
    })

    -- Large multiline TextBox for notes
    accordion:AddTextBox({
        Name = "Notes & Comments",
        Placeholder = "Enter your notes here...\nSupports multiple lines\nPerfect for longer text",
        Default = "",
        Multiline = true,
        MaxLength = 500,
        Flag = "Notes",
        Callback = function(text)
            print("Notes changed (" .. #text .. " characters):", text:sub(1, 50) .. (#text > 50 and "..." or ""))
        end
    })

    -- Code/Script input TextBox
    accordion:AddTextBox({
        Name = "Script Code",
        Placeholder = "print('Hello World!')",
        Default = "-- Enter your code here",
        Multiline = true,
        MaxLength = 1000,
        Flag = "ScriptCode",
        Callback = function(text)
            print("Script code updated (" .. #text .. " chars)")
        end
    })
end

function TextBox:AddSectionValidation(tab)
    local accordion = tab:AddAccordion({
        Name = "Validation & Input Types",
        Icon = "✅",
    })
    
    accordion:AddLabel("TextBoxes with validation and specialized input types:")
    accordion:AddSeparator()

    -- Password-style TextBox
    accordion:AddTextBox({
        Name = "Password",
        Placeholder = "Enter your password...",
        Default = "",
        MaxLength = 20,
        Flag = "Password",
        Callback = function(text)
            print("Password changed: " .. string.rep("*", #text))
        end
    })

    -- Email input with validation
    accordion:AddTextBox({
        Name = "Email Address",
        Placeholder = "user@example.com",
        Default = "",
        MaxLength = 100,
        Flag = "Email",
        Callback = function(text)
            if string.find(text, "@") then
                print("Email changed:", text)
            else
                print("Email (invalid format):", text)
            end
        end
    })

    -- URL/Link TextBox
    accordion:AddTextBox({
        Name = "Website URL",
        Placeholder = "https://example.com",
        Default = "",
        MaxLength = 200,
        Flag = "WebsiteURL",
        Callback = function(text)
            if string.find(text, "^https?://") then
                print("Valid URL:", text)
            elseif #text > 0 then
                print("URL (missing protocol):", text)
            end
        end
    })
end

function TextBox:AddSectionAdvanced(tab)
    local accordion = tab:AddAccordion({
        Name = "Advanced Features",
        Icon = "⚙️",
    })
    
    accordion:AddLabel("Advanced TextBox features and use cases:")
    accordion:AddSeparator()

    -- Search TextBox with button
    accordion:AddTextBox({
        Name = "Search with Button",
        Placeholder = "🔍 Search for items...",
        Default = "",
        MaxLength = 50,
        Flag = "SearchQuery",
        Buttons = {
            {
                Text = "🔍",
                Variant = "primary",
                Callback = function(text, textBox)
                    if #text > 0 then
                        print("🔍 Searching for:", text)
                    else
                        print("⚠️ Please enter a search term")
                    end
                end
            }
        },
        Callback = function(text)
            if #text > 0 then
                print("Searching for:", text)
            else
                print("Search cleared")
            end
        end
    })

    -- File Path with Browse Button
    accordion:AddTextBox({
        Name = "File Path",
        Placeholder = "C:\\path\\to\\file.txt",
        Default = "",
        MaxLength = 200,
        Flag = "FilePath",
        Buttons = {
            {
                Text = "📁",
                Variant = "secondary",
                Callback = function(text, textBox)
                    print("📁 Browse file dialog for:", text)
                end
            },
            {
                Text = "✓",
                Variant = "primary",
                Callback = function(text, textBox)
                    if #text > 0 then
                        print("✅ File path confirmed:", text)
                    else
                        print("⚠️ Please select a file path")
                    end
                end
            }
        }
    })

    -- JSON Config with validation
    accordion:AddTextBox({
        Name = "JSON Configuration",
        Placeholder = '{"setting": "value"}',
        Default = '{\n  "autoSave": true,\n  "theme": "dark"\n}',
        Multiline = true,
        MaxLength = 500,
        Flag = "JSONConfig",
        Buttons = {
            {
                Text = "Validate",
                Variant = "primary",
                Callback = function(text, textBox)
                    if text:match("^%s*{.*}%s*$") then
                        print("✅ JSON appears valid")
                    else
                        print("❌ Invalid JSON format")
                    end
                end
            },
            {
                Text = "Format",
                Variant = "secondary",
                Callback = function(text, textBox)
                    print("🔧 JSON formatting applied")
                end
            }
        }
    })
end

function TextBox:AddSectionForms(tab)
    local accordion = tab:AddAccordion({
        Name = "Form Examples",
        Icon = "📋",
    })
    
    accordion:AddLabel("Complete form examples using multiple TextBoxes:")
    accordion:AddSeparator()

    -- Chat message form
    accordion:AddLabel("💬 Chat Interface:")
    accordion:AddTextBox({
        Name = "Chat Message",
        Placeholder = "Type your message...",
        Default = "",
        MaxLength = 150,
        Flag = "ChatMessage",
        Buttons = {
            {
                Text = "Send",
                Variant = "primary",
                Callback = function(text, textBox)
                    if #text > 0 then
                        print("💬 Message sent:", text)
                        textBox.Text = ""
                    end
                end
            }
        }
    })

    accordion:AddSeparator()
    accordion:AddLabel("👤 User Registration:")
    
    -- User registration form
    accordion:AddTextBox({
        Name = "Full Name",
        Placeholder = "Enter your full name...",
        Default = "",
        MaxLength = 50,
        Flag = "FormName"
    })

    accordion:AddTextBox({
        Name = "Email",
        Placeholder = "user@example.com",
        Default = "",
        MaxLength = 100,
        Flag = "FormEmail",
        Buttons = {
            {
                Text = "✓",
                Variant = "secondary",
                Callback = function(text, textBox)
                    if text:match("@") then
                        print("✅ Email format valid:", text)
                    else
                        print("❌ Invalid email format")
                    end
                end
            }
        }
    })

    accordion:AddTextBox({
        Name = "Bio",
        Placeholder = "Tell us about yourself...",
        Default = "",
        Multiline = true,
        MaxLength = 300,
        Flag = "FormBio"
    })

    -- Form submission
    accordion:AddTextBox({
        Name = "Submit Registration",
        Placeholder = "Click submit when ready...",
        Default = "",
        MaxLength = 1,
        Flag = "FormSubmit",
        Buttons = {
            {
                Text = "Submit Form",
                Variant = "primary", 
                Callback = function(text, textBox)
                    print("📋 Registration form submitted!")
                    print("Form data collected from all fields")
                end
            },
            {
                Text = "Reset",
                Variant = "secondary",
                Callback = function(text, textBox)
                    textBox.Text = ""
                    print("🔄 Form reset")
                end
            }
        }
    })
end

function TextBox:AddSectionTips(tab)
    local accordion = tab:AddAccordion({
        Name = "Usage Tips & Best Practices",
        Icon = "💡",
    })
    
    accordion:AddLabel("📌 TextBox Configuration Tips:")
    accordion:AddLabel("• Use Name parameter for clear labeling")
    accordion:AddLabel("• Set appropriate MaxLength for input validation")
    accordion:AddLabel("• Use Multiline for longer text input")
    accordion:AddLabel("• Add Buttons for immediate actions")
    accordion:AddLabel("• Use Flag parameter for data persistence")
    
    accordion:AddSeparator()
    accordion:AddLabel("🎨 Button Integration Tips:")
    accordion:AddLabel("• Primary variant for main actions (Submit, Send)")
    accordion:AddLabel("• Secondary variant for utility actions (Clear, Reset)")
    accordion:AddLabel("• Use emoji icons for compact buttons (🔍, 📁, ✓)")
    accordion:AddLabel("• Multiple buttons work left-to-right")
    
    accordion:AddSeparator()
    accordion:AddLabel("⚡ Performance Tips:")
    accordion:AddLabel("• Use appropriate MaxLength to prevent spam")
    accordion:AddLabel("• Validate input in Callback functions")
    accordion:AddLabel("• Clear TextBox after form submission")
    accordion:AddLabel("• Use Flag system for automatic save/load")
end

return TextBox