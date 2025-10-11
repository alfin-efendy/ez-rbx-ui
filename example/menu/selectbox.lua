local SelectBox = {}

function SelectBox:Init(_window)
    local tab = _window:AddTab({
        Name = "SelectBox",
        Icon = "📋"
    })

    -- Basic intro
    tab:AddLabel("SelectBox Component Examples")
    tab:AddSeparator()
    
    -- Accordion: Basic SelectBoxes
    self:AddSectionBasic(tab)
    
    -- Accordion: Multi-Select
    self:AddSectionMultiSelect(tab)
    
    -- Accordion: Advanced Options
    self:AddSectionAdvanced(tab)
    
    -- Accordion: Settings & Preferences
    self:AddSectionSettings(tab)
    
    -- Accordion: Data Selection
    self:AddSectionData(tab)
    
    -- Accordion: Interactive Examples
    self:AddSectionInteractive(tab)
    
    -- Accordion: Usage Tips
    self:AddSectionTips(tab)
end

function SelectBox:AddSectionBasic(tab)
    local accordion = tab:AddAccordion({
        Name = "Basic SelectBoxes",
        Icon = "📋",
    })
    
    accordion:AddLabel("Basic SelectBox usage with simple option lists:")
    accordion:AddSeparator()

    -- Simple SelectBox with string options
    accordion:AddSelectBox({
        Placeholder = "Choose an option...",
        Options = {"Option 1", "Option 2", "Option 3", "Option 4"},
        Callback = function(selectedValue)
            print("Basic SelectBox selected:", selectedValue)
        end
    })

    -- SelectBox with title and Flag for persistence
    accordion:AddSelectBox({
        Name = "User Preference",
        Placeholder = "Select your preference...",
        Options = {"Yes", "No", "Maybe"},
        Flag = "BasicPreference",
        Callback = function(selectedValue)
            print("Preference selected (saved):", selectedValue)
        end
    })

    -- Colors selection with title
    accordion:AddSelectBox({
        Name = "Favorite Color",
        Placeholder = "Pick a color...",
        Options = {"🔴 Red", "🟢 Green", "🔵 Blue", "🟡 Yellow", "🟣 Purple"},
        Flag = "ColorChoice",
        Callback = function(selectedValue)
            print("Color selected:", selectedValue)
        end
    })

    -- Size options with title
    accordion:AddSelectBox({
        Name = "Clothing Size",
        Placeholder = "Choose size...",
        Options = {"Small", "Medium", "Large", "Extra Large"},
        Flag = "SizeChoice",
        Callback = function(selectedValue)
            print("Size selected:", selectedValue)
        end
    })

    -- Priority levels with title
    accordion:AddSelectBox({
        Name = "Task Priority",
        Placeholder = "Set priority...",
        Options = {"🔥 High", "⚡ Medium", "💤 Low"},
        Flag = "PriorityLevel",
        Callback = function(selectedValue)
            print("Priority set:", selectedValue)
        end
    })
end

function SelectBox:AddSectionMultiSelect(tab)
    local accordion = tab:AddAccordion({
        Name = "Multi-Select Options",
        Icon = "☑️",
    })
    
    accordion:AddLabel("SelectBoxes with multi-selection capability:")
    accordion:AddSeparator()

    -- Multi-select hobbies with title
    accordion:AddSelectBox({
        Name = "Your Hobbies",
        Placeholder = "Select your hobbies (multiple)...",
        Options = {"🎮 Gaming", "📚 Reading", "🎵 Music", "🏃 Sports", "🎨 Art", "💻 Programming"},
        MultiSelect = true,
        Flag = "Hobbies",
        Callback = function(selectedValues)
            if type(selectedValues) == "table" then
                print("Hobbies selected:", table.concat(selectedValues, ", "))
            else
                print("Hobbies selected:", selectedValues)
            end
        end
    })

    -- Multi-select languages with title
    accordion:AddSelectBox({
        Name = "Programming Languages",
        Placeholder = "Languages you know...",
        Options = {"Lua", "Python", "JavaScript", "C++", "Java", "C#", "Go", "Rust"},
        MultiSelect = true,
        Flag = "Languages",
        Callback = function(selectedValues)
            if type(selectedValues) == "table" then
                print("Languages known (" .. #selectedValues .. "):", table.concat(selectedValues, ", "))
            else
                print("Language selected:", selectedValues)
            end
        end
    })

    -- Multi-select features
    accordion:AddSelectBox({
        Placeholder = "Enable features (multiple)...",
        Options = {"Auto-Save", "Dark Mode", "Notifications", "Sound Effects", "Advanced Tools"},
        MultiSelect = true,
        Flag = "EnabledFeatures",
        Callback = function(selectedValues)
            if type(selectedValues) == "table" then
                print("✅ Features enabled:", table.concat(selectedValues, ", "))
            else
                print("✅ Feature enabled:", selectedValues)
            end
        end
    })

    -- Multi-select categories
    accordion:AddSelectBox({
        Placeholder = "Select categories of interest...",
        Options = {"Technology", "Science", "Art", "Sports", "Music", "Travel", "Food", "Education"},
        MultiSelect = true,
        Flag = "Categories",
        Callback = function(selectedValues)
            if type(selectedValues) == "table" then
                print("📂 Categories (" .. #selectedValues .. " selected):", table.concat(selectedValues, ", "))
            else
                print("📂 Category selected:", selectedValues)
            end
        end
    })
end

function SelectBox:AddSectionAdvanced(tab)
    local accordion = tab:AddAccordion({
        Name = "Advanced Options",
        Icon = "⚙️",
    })
    
    accordion:AddLabel("Advanced SelectBox configurations with complex data:")
    accordion:AddSeparator()

    -- Complex options with text/value pairs
    accordion:AddSelectBox({
        Placeholder = "Select server region...",
        Options = {
            {text = "🇺🇸 US East (Virginia)", value = "us-east-1"},
            {text = "🇺🇸 US West (California)", value = "us-west-1"},
            {text = "🇪🇺 Europe (Ireland)", value = "eu-west-1"},
            {text = "🇦🇺 Asia Pacific (Sydney)", value = "ap-southeast-2"},
            {text = "🇯🇵 Asia Pacific (Tokyo)", value = "ap-northeast-1"}
        },
        Flag = "ServerRegion",
        Callback = function(selectedValue)
            print("🌍 Server region selected:", selectedValue)
        end
    })

    -- Quality settings
    accordion:AddSelectBox({
        Placeholder = "Graphics quality...",
        Options = {
            {text = "🔥 Ultra (Best)", value = "ultra"},
            {text = "⭐ High", value = "high"},
            {text = "🔧 Medium", value = "medium"},
            {text = "⚡ Low (Fast)", value = "low"},
            {text = "🏃 Potato (Fastest)", value = "potato"}
        },
        Flag = "GraphicsQuality",
        Callback = function(selectedValue)
            print("🎮 Graphics quality:", selectedValue)
        end
    })

    -- Resolution options
    accordion:AddSelectBox({
        Placeholder = "Screen resolution...",
        Options = {
            "1920x1080 (Full HD)",
            "2560x1440 (2K)",
            "3840x2160 (4K)",
            "1366x768 (HD)",
            "1280x720 (HD Ready)"
        },
        Flag = "Resolution",
        Callback = function(selectedValue)
            print("🖥️ Resolution selected:", selectedValue)
        end
    })

    -- Difficulty with descriptions
    accordion:AddSelectBox({
        Placeholder = "Game difficulty...",
        Options = {
            "👶 Beginner - Easy and forgiving",
            "🎯 Normal - Balanced experience", 
            "💪 Hard - Challenging gameplay",
            "💀 Expert - For veterans only",
            "🔥 Nightmare - Insane difficulty"
        },
        Flag = "Difficulty",
        Callback = function(selectedValue)
            print("⚔️ Difficulty set:", selectedValue)
        end
    })
end

function SelectBox:AddSectionSettings(tab)
    local accordion = tab:AddAccordion({
        Name = "Settings & Preferences",
        Icon = "🛠️",
    })
    
    accordion:AddLabel("Common settings and configuration options:")
    accordion:AddSeparator()

    accordion:AddLabel("🎨 Appearance Settings:")

    -- Theme selection
    accordion:AddSelectBox({
        Placeholder = "Select theme...",
        Options = {"🌞 Light", "🌙 Dark", "🌈 Colorful", "🎯 High Contrast", "🖤 OLED Black"},
        Flag = "Theme",
        Callback = function(selectedValue)
            print("🎨 Theme changed to:", selectedValue)
        end
    })

    -- Font size
    accordion:AddSelectBox({
        Placeholder = "Font size...",
        Options = {"Tiny", "Small", "Medium", "Large", "Extra Large"},
        Flag = "FontSize",
        Callback = function(selectedValue)
            print("📝 Font size:", selectedValue)
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("🔊 Audio Settings:")

    -- Audio quality
    accordion:AddSelectBox({
        Placeholder = "Audio quality...",
        Options = {"Low (32kbps)", "Medium (128kbps)", "High (320kbps)", "Lossless"},
        Flag = "AudioQuality",
        Callback = function(selectedValue)
            print("🎵 Audio quality:", selectedValue)
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("🌐 Language & Region:")

    -- Language selection
    accordion:AddSelectBox({
        Placeholder = "Select language...",
        Options = {"🇺🇸 English", "🇪🇸 Español", "🇫🇷 Français", "🇩🇪 Deutsch", "🇯🇵 日本語", "🇨🇳 中文"},
        Flag = "Language",
        Callback = function(selectedValue)
            print("🌍 Language changed to:", selectedValue)
        end
    })

    -- Time format
    accordion:AddSelectBox({
        Placeholder = "Time format...",
        Options = {"12-hour (AM/PM)", "24-hour"},
        Flag = "TimeFormat",
        Callback = function(selectedValue)
            print("🕐 Time format:", selectedValue)
        end
    })

    -- Date format
    accordion:AddSelectBox({
        Placeholder = "Date format...",
        Options = {"MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD", "DD-MM-YYYY"},
        Flag = "DateFormat",
        Callback = function(selectedValue)
            print("📅 Date format:", selectedValue)
        end
    })
end

function SelectBox:AddSectionData(tab)
    local accordion = tab:AddAccordion({
        Name = "Data Selection",
        Icon = "📊",
    })
    
    accordion:AddLabel("SelectBoxes for data filtering and organization:")
    accordion:AddSeparator()

    -- Sort options
    accordion:AddSelectBox({
        Placeholder = "Sort by...",
        Options = {
            "📅 Date (Newest first)",
            "📅 Date (Oldest first)",
            "🔤 Name (A-Z)",
            "🔤 Name (Z-A)",
            "📊 Size (Largest first)",
            "📊 Size (Smallest first)"
        },
        Flag = "SortBy",
        Callback = function(selectedValue)
            print("📋 Sorting by:", selectedValue)
        end
    })

    -- Filter options
    accordion:AddSelectBox({
        Placeholder = "Filter items...",
        Options = {"All Items", "Recent", "Favorites", "Archived", "Shared", "Private"},
        Flag = "FilterBy",
        Callback = function(selectedValue)
            print("🔍 Filtering by:", selectedValue)
        end
    })

    -- View options
    accordion:AddSelectBox({
        Placeholder = "View style...",
        Options = {"📋 List View", "🗂️ Grid View", "📑 Card View", "📊 Table View"},
        Flag = "ViewStyle",
        Callback = function(selectedValue)
            print("👁️ View changed to:", selectedValue)
        end
    })

    -- Export format
    accordion:AddSelectBox({
        Placeholder = "Export format...",
        Options = {"📄 PDF", "📊 Excel (XLSX)", "📝 CSV", "🌐 HTML", "📋 JSON", "📁 ZIP"},
        Flag = "ExportFormat",
        Callback = function(selectedValue)
            print("💾 Export format:", selectedValue)
        end
    })

    -- Time range
    accordion:AddSelectBox({
        Placeholder = "Time range...",
        Options = {
            "Today",
            "This Week", 
            "This Month",
            "Last 3 Months",
            "This Year",
            "All Time",
            "Custom Range"
        },
        Flag = "TimeRange",
        Callback = function(selectedValue)
            print("📅 Time range:", selectedValue)
        end
    })
end

function SelectBox:AddSectionInteractive(tab)
    local accordion = tab:AddAccordion({
        Name = "Interactive Examples",
        Icon = "🎯",
    })
    
    accordion:AddLabel("Interactive SelectBoxes with dynamic behavior:")
    accordion:AddSeparator()

    -- Country/State selection (simulated dependency)
    accordion:AddSelectBox({
        Placeholder = "Select country...",
        Options = {"🇺🇸 United States", "🇨🇦 Canada", "🇬🇧 United Kingdom", "🇦🇺 Australia", "🇩🇪 Germany"},
        Flag = "Country",
        Callback = function(selectedValue)
            print("🌍 Country selected:", selectedValue)
            if selectedValue == "🇺🇸 United States" then
                print("  📍 States available: California, Texas, New York, Florida...")
            elseif selectedValue == "🇨🇦 Canada" then
                print("  📍 Provinces available: Ontario, Quebec, British Columbia...")
            end
        end
    })

    -- Category/Subcategory selection
    accordion:AddSelectBox({
        Placeholder = "Select category...",
        Options = {"💻 Technology", "🎮 Gaming", "🎵 Music", "📚 Education", "🏃 Sports"},
        Flag = "MainCategory",
        Callback = function(selectedValue)
            print("📂 Category selected:", selectedValue)
            if selectedValue == "💻 Technology" then
                print("  🔧 Subcategories: Programming, Hardware, AI, Web Dev...")
            elseif selectedValue == "🎮 Gaming" then
                print("  🎯 Subcategories: Action, RPG, Strategy, Sports...")
            elseif selectedValue == "🎵 Music" then
                print("  🎼 Subcategories: Pop, Rock, Classical, Electronic...")
            end
        end
    })

    -- Multi-select with counter
    local selectedCount = 0
    accordion:AddSelectBox({
        Placeholder = "Select team members (max 5)...",
        Options = {"Alice", "Bob", "Charlie", "Diana", "Eve", "Frank", "Grace", "Henry"},
        MultiSelect = true,
        Flag = "TeamMembers",
        Callback = function(selectedValues)
            if type(selectedValues) == "table" then
                selectedCount = #selectedValues
                print("👥 Team members (" .. selectedCount .. "/5):", table.concat(selectedValues, ", "))
                if selectedCount >= 5 then
                    print("⚠️ Maximum team size reached!")
                end
            else
                selectedCount = 1
                print("👥 Team member selected:", selectedValues)
            end
        end
    })

    -- Dynamic options based on previous selections
    accordion:AddSelectBox({
        Placeholder = "Select game mode...",
        Options = {"Single Player", "Co-op (2 players)", "Multiplayer (4 players)", "Online Battle"},
        Flag = "GameMode",
        Callback = function(selectedValue)
            print("🎮 Game mode:", selectedValue)
            if selectedValue == "Single Player" then
                print("  ⚙️ Available: Story Mode, Free Play, Challenges")
            elseif selectedValue == "Co-op (2 players)" then
                print("  ⚙️ Available: Campaign, Survival, Puzzle")
            elseif selectedValue == "Multiplayer (4 players)" then
                print("  ⚙️ Available: Party Games, Competition, Custom")
            elseif selectedValue == "Online Battle" then
                print("  ⚙️ Available: Ranked, Casual, Tournament")
            end
        end
    })
end

function SelectBox:AddSectionTips(tab)
    local accordion = tab:AddAccordion({
        Name = "Usage Tips & Best Practices",
        Icon = "💡",
    })
    
    accordion:AddLabel("📌 SelectBox Configuration Tips:")
    accordion:AddLabel("• Use Name parameter for clear labeling (optional)")
    accordion:AddLabel("• Use Options array for available choices")
    accordion:AddLabel("• Set MultiSelect=true for multiple selections")
    accordion:AddLabel("• Use Flag parameter for persistent selections")
    accordion:AddLabel("• Provide clear Placeholder text")
    accordion:AddLabel("• Handle both single values and arrays in callbacks")
    
    accordion:AddSeparator()
    accordion:AddLabel("🎯 Option Format Tips:")
    accordion:AddLabel("• Simple strings: {'Option 1', 'Option 2'}")
    accordion:AddLabel("• Text/Value pairs: {{text='Display', value='key'}}")
    accordion:AddLabel("• Use emojis for visual categorization")
    accordion:AddLabel("• Keep option text concise but descriptive")
    accordion:AddLabel("• Consider alphabetical or logical ordering")
    
    accordion:AddSeparator()
    accordion:AddLabel("⚡ Best Practices:")
    accordion:AddLabel("• Single-select: For mutually exclusive choices")
    accordion:AddLabel("• Multi-select: For feature toggles or categories")
    accordion:AddLabel("• Validate selections in callback functions")
    accordion:AddLabel("• Provide feedback for selection changes")
    accordion:AddLabel("• Group related options logically")
    
    accordion:AddSeparator()
    accordion:AddLabel("🔧 Common Use Cases:")
    accordion:AddLabel("• Settings: Theme, language, quality options")
    accordion:AddLabel("• Filters: Sort by, filter by, time range")
    accordion:AddLabel("• Categories: Tags, groups, classifications")
    accordion:AddLabel("• Data: Server regions, formats, templates")
    accordion:AddLabel("• Features: Enable/disable multiple options")
    
    accordion:AddSeparator()
    accordion:AddLabel("🎨 UI Design Tips:")
    accordion:AddLabel("• Use descriptive placeholders")
    accordion:AddLabel("• Consider option count (too many = search needed)")
    accordion:AddLabel("• Provide visual feedback for multi-selections")
    accordion:AddLabel("• Group similar SelectBoxes in sections")
    accordion:AddLabel("• Use consistent option naming patterns")
    
    accordion:AddSeparator()
    accordion:AddLabel("⚙️ Advanced Features:")
    accordion:AddLabel("• Dynamic options based on other selections")
    accordion:AddLabel("• Validation of selection limits")
    accordion:AddLabel("• Search functionality for large option lists")
    accordion:AddLabel("• Dependent SelectBoxes (country/state)")
    accordion:AddLabel("• Custom formatting in callback functions")
end

return SelectBox