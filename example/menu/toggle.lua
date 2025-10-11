local Toggle = {}

function Toggle:Init(_window)
    local tab = _window:AddTab({
        Name = "Toggle",
        Icon = "🔘"
    })

    -- Basic intro
    tab:AddLabel("Toggle Component Examples")
    tab:AddSeparator()
    
    -- Accordion: Basic Toggles
    self:AddSectionBasic(tab)
    
    -- Accordion: States & Defaults
    self:AddSectionStates(tab)
    
    -- Accordion: Settings & Preferences
    self:AddSectionSettings(tab)
    
    -- Accordion: Feature Controls
    self:AddSectionFeatures(tab)
    
    -- Accordion: Interactive Examples
    self:AddSectionInteractive(tab)
    
    -- Accordion: Advanced Usage
    self:AddSectionAdvanced(tab)
    
    -- Accordion: Usage Tips
    self:AddSectionTips(tab)
end

function Toggle:AddSectionBasic(tab)
    local accordion = tab:AddAccordion({
        Name = "Basic Toggles",
        Icon = "🔘",
    })
    
    accordion:AddLabel("Basic toggle usage with simple on/off functionality:")
    accordion:AddSeparator()

    -- Simple toggle (default off)
    accordion:AddToggle({
        Name = "Basic Toggle",
        Default = false,
        Callback = function(state)
            print("Basic toggle:", state and "ON" or "OFF")
        end
    })

    -- Toggle with default on
    accordion:AddToggle({
        Name = "Default On Toggle",
        Default = true,
        Flag = "DefaultOn",
        Callback = function(state)
            print("Default on toggle:", state and "ENABLED" or "DISABLED")
        end
    })

    -- Toggle with flag for persistence
    accordion:AddToggle({
        Name = "Persistent Toggle",
        Default = false,
        Flag = "PersistentToggle",
        Callback = function(state)
            print("Persistent toggle (saved):", state and "✓" or "✗")
        end
    })

    -- Simple yes/no toggle
    accordion:AddToggle({
        Name = "Yes/No Option",
        Default = false,
        Flag = "YesNoOption",
        Callback = function(state)
            print("Yes/No option:", state and "YES" or "NO")
        end
    })
end

function Toggle:AddSectionStates(tab)
    local accordion = tab:AddAccordion({
        Name = "States & Defaults",
        Icon = "⚡",
    })
    
    accordion:AddLabel("Toggles with different default states and behaviors:")
    accordion:AddSeparator()

    -- Various default states
    accordion:AddToggle({
        Name = "Always Start Off",
        Default = false,
        Flag = "AlwaysOff",
        Callback = function(state)
            print("Always start off:", state and "🟢 ON" or "🔴 OFF")
        end
    })

    accordion:AddToggle({
        Name = "Always Start On",
        Default = true,
        Flag = "AlwaysOn",
        Callback = function(state)
            print("Always start on:", state and "🟢 ACTIVE" or "🔴 INACTIVE")
        end
    })

    -- State-dependent behavior
    accordion:AddToggle({
        Name = "Master Switch",
        Default = true,
        Flag = "MasterSwitch",
        Callback = function(state)
            if state then
                print("🔋 Master switch ENABLED - All systems go!")
            else
                print("🔌 Master switch DISABLED - Systems offline")
            end
        end
    })

    -- Binary choice toggle
    accordion:AddToggle({
        Name = "Light/Dark Mode",
        Default = false,
        Flag = "DarkMode",
        Callback = function(state)
            print("Theme:", state and "🌙 Dark Mode" or "☀️ Light Mode")
        end
    })

    -- On/Off status indicator
    accordion:AddToggle({
        Name = "Status Indicator",
        Default = false,
        Flag = "StatusIndicator",
        Callback = function(state)
            print("Status:", state and "🟢 ONLINE" or "🔴 OFFLINE")
        end
    })
end

function Toggle:AddSectionSettings(tab)
    local accordion = tab:AddAccordion({
        Name = "Settings & Preferences",
        Icon = "⚙️",
    })
    
    accordion:AddLabel("Common settings and preference toggles:")
    accordion:AddSeparator()

    accordion:AddLabel("🔊 Audio Settings:")
    
    -- Audio settings
    accordion:AddToggle({
        Name = "Sound Effects",
        Default = true,
        Flag = "SoundFX",
        Callback = function(state)
            print("🔊 Sound effects:", state and "ENABLED" or "MUTED")
        end
    })

    accordion:AddToggle({
        Name = "Background Music",
        Default = true,
        Flag = "BGMusic",
        Callback = function(state)
            print("🎵 Background music:", state and "PLAYING" or "STOPPED")
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("🎮 Gameplay Settings:")

    -- Gameplay settings
    accordion:AddToggle({
        Name = "Auto-Save",
        Default = true,
        Flag = "AutoSave",
        Callback = function(state)
            print("💾 Auto-save:", state and "ENABLED" or "DISABLED")
        end
    })

    accordion:AddToggle({
        Name = "Show Tutorials",
        Default = true,
        Flag = "ShowTutorials",
        Callback = function(state)
            print("📚 Tutorials:", state and "VISIBLE" or "HIDDEN")
        end
    })

    accordion:AddToggle({
        Name = "Enable Cheats",
        Default = false,
        Flag = "EnableCheats",
        Callback = function(state)
            print("🎯 Cheats:", state and "⚠️ ENABLED" or "🔒 DISABLED")
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("🎨 Display Settings:")

    -- Display settings
    accordion:AddToggle({
        Name = "Fullscreen Mode",
        Default = false,
        Flag = "Fullscreen",
        Callback = function(state)
            print("🖥️ Fullscreen:", state and "ENABLED" or "WINDOWED")
        end
    })

    accordion:AddToggle({
        Name = "VSync",
        Default = true,
        Flag = "VSync",
        Callback = function(state)
            print("🔄 VSync:", state and "ON" or "OFF")
        end
    })
end

function Toggle:AddSectionFeatures(tab)
    local accordion = tab:AddAccordion({
        Name = "Feature Controls",
        Icon = "🛠️",
    })
    
    accordion:AddLabel("Feature toggles for enabling/disabling functionality:")
    accordion:AddSeparator()

    -- Development features
    accordion:AddLabel("🔧 Development Features:")
    
    accordion:AddToggle({
        Name = "Debug Mode",
        Default = false,
        Flag = "DebugMode",
        Callback = function(state)
            if state then
                print("🐛 Debug mode ENABLED - Verbose logging active")
            else
                print("🐛 Debug mode DISABLED - Normal operation")
            end
        end
    })

    accordion:AddToggle({
        Name = "Show FPS Counter",
        Default = false,
        Flag = "ShowFPS",
        Callback = function(state)
            print("📊 FPS counter:", state and "VISIBLE" or "HIDDEN")
        end
    })

    accordion:AddToggle({
        Name = "Developer Console",
        Default = false,
        Flag = "DevConsole",
        Callback = function(state)
            print("💻 Developer console:", state and "🟢 OPEN" or "🔴 CLOSED")
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("🌐 Network Features:")

    -- Network features
    accordion:AddToggle({
        Name = "Online Mode",
        Default = true,
        Flag = "OnlineMode",
        Callback = function(state)
            print("🌐 Online mode:", state and "🟢 CONNECTED" or "🔴 OFFLINE")
        end
    })

    accordion:AddToggle({
        Name = "Auto-Update",
        Default = true,
        Flag = "AutoUpdate",
        Callback = function(state)
            print("🔄 Auto-update:", state and "ENABLED" or "DISABLED")
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("🔒 Security Features:")

    -- Security features
    accordion:AddToggle({
        Name = "Anti-Cheat",
        Default = true,
        Flag = "AntiCheat",
        Callback = function(state)
            print("🛡️ Anti-cheat:", state and "🟢 ACTIVE" or "🔴 INACTIVE")
        end
    })

    accordion:AddToggle({
        Name = "Safe Mode",
        Default = false,
        Flag = "SafeMode",
        Callback = function(state)
            print("🔒 Safe mode:", state and "🟢 ENABLED" or "🔓 DISABLED")
        end
    })
end

function Toggle:AddSectionInteractive(tab)
    local accordion = tab:AddAccordion({
        Name = "Interactive Examples",
        Icon = "🎯",
    })
    
    accordion:AddLabel("Interactive toggles that affect other toggles:")
    accordion:AddSeparator()

    -- Master control toggle
    local masterEnabled = true
    accordion:AddToggle({
        Name = "🔋 Master Control",
        Default = true,
        Flag = "MasterControl",
        Callback = function(state)
            masterEnabled = state
            print("🔋 Master control:", state and "🟢 ALL SYSTEMS GO" or "🔴 SYSTEMS OFFLINE")
            
            if not state then
                print("   ⚠️ All subsystems automatically disabled")
            else
                print("   ✅ Subsystems can now be enabled")
            end
        end
    })

    -- Dependent toggles
    accordion:AddToggle({
        Name = "Subsystem A",
        Default = false,
        Flag = "SubsystemA",
        Callback = function(state)
            if masterEnabled then
                print("🔧 Subsystem A:", state and "🟢 ONLINE" or "🔴 OFFLINE")
            else
                print("⚠️ Subsystem A: Cannot enable - Master control is OFF")
            end
        end
    })

    accordion:AddToggle({
        Name = "Subsystem B",
        Default = false,
        Flag = "SubsystemB",
        Callback = function(state)
            if masterEnabled then
                print("⚙️ Subsystem B:", state and "🟢 ACTIVE" or "🔴 INACTIVE")
            else
                print("⚠️ Subsystem B: Cannot enable - Master control is OFF")
            end
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("🎮 Game Mode Selection:")

    -- Game mode toggles (exclusive)
    accordion:AddToggle({
        Name = "Easy Mode",
        Default = true,
        Flag = "EasyMode",
        Callback = function(state)
            if state then
                print("🟢 Easy mode ACTIVATED - Difficulty reduced")
            else
                print("🔴 Easy mode DEACTIVATED")
            end
        end
    })

    accordion:AddToggle({
        Name = "Hard Mode",
        Default = false,
        Flag = "HardMode",
        Callback = function(state)
            if state then
                print("🔥 Hard mode ACTIVATED - Challenge increased!")
            else
                print("🔴 Hard mode DEACTIVATED")
            end
        end
    })

    accordion:AddToggle({
        Name = "Expert Mode",
        Default = false,
        Flag = "ExpertMode",
        Callback = function(state)
            if state then
                print("💀 Expert mode ACTIVATED - Maximum difficulty!")
            else
                print("🔴 Expert mode DEACTIVATED")
            end
        end
    })
end

function Toggle:AddSectionAdvanced(tab)
    local accordion = tab:AddAccordion({
        Name = "Advanced Usage",
        Icon = "⚙️",
    })
    
    accordion:AddLabel("Advanced toggle configurations and use cases:")
    accordion:AddSeparator()

    -- Counter toggle
    local toggleCount = 0
    accordion:AddToggle({
        Name = "Toggle Counter",
        Default = false,
        Flag = "ToggleCounter",
        Callback = function(state)
            toggleCount = toggleCount + 1
            print("🔢 Toggle #" .. toggleCount .. ":", state and "ON" or "OFF")
        end
    })

    -- Timer toggle
    accordion:AddToggle({
        Name = "Timer Toggle",
        Default = false,
        Flag = "TimerToggle",
        Callback = function(state)
            if state then
                print("⏰ Timer started at:", os.date("%H:%M:%S"))
            else
                print("⏹️ Timer stopped at:", os.date("%H:%M:%S"))
            end
        end
    })

    -- Performance toggle
    accordion:AddToggle({
        Name = "Performance Mode",
        Default = false,
        Flag = "PerformanceMode",
        Callback = function(state)
            if state then
                print("🚀 Performance mode: High-speed, reduced quality")
            else
                print("🎨 Quality mode: Standard speed, high quality")
            end
        end
    })

    -- Experimental features
    accordion:AddToggle({
        Name = "🧪 Experimental Features",
        Default = false,
        Flag = "ExperimentalFeatures",
        Callback = function(state)
            if state then
                print("🧪 Experimental features ENABLED")
                print("   ⚠️ Warning: May cause instability")
            else
                print("🧪 Experimental features DISABLED")
                print("   ✅ Using stable features only")
            end
        end
    })

    -- Data collection toggle
    accordion:AddToggle({
        Name = "Analytics Collection",
        Default = false,
        Flag = "Analytics",
        Callback = function(state)
            if state then
                print("📊 Analytics: Data collection ENABLED")
                print("   ℹ️ Helping improve the application")
            else
                print("📊 Analytics: Data collection DISABLED")
                print("   🔒 Privacy mode active")
            end
        end
    })

    -- Backup toggle
    accordion:AddToggle({
        Name = "Auto Backup",
        Default = true,
        Flag = "AutoBackup",
        Callback = function(state)
            if state then
                print("💾 Auto backup: ENABLED (every 5 minutes)")
            else
                print("💾 Auto backup: DISABLED (manual only)")
            end
        end
    })
end

function Toggle:AddSectionTips(tab)
    local accordion = tab:AddAccordion({
        Name = "Usage Tips & Best Practices",
        Icon = "💡",
    })
    
    accordion:AddLabel("📌 Toggle Configuration Tips:")
    accordion:AddLabel("• Use Name parameter for clear, descriptive labels")
    accordion:AddLabel("• Set appropriate Default values for expected behavior")
    accordion:AddLabel("• Use Flag parameter for persistent toggle states")
    accordion:AddLabel("• Provide meaningful feedback in Callback functions")
    accordion:AddLabel("• Consider user expectations for default states")
    
    accordion:AddSeparator()
    accordion:AddLabel("🎯 Best Practices:")
    accordion:AddLabel("• Default=true: Features users expect to be on")
    accordion:AddLabel("• Default=false: Optional or advanced features")
    accordion:AddLabel("• Use clear ON/OFF language in callbacks")
    accordion:AddLabel("• Group related toggles in accordions")
    accordion:AddLabel("• Consider toggle dependencies and interactions")
    
    accordion:AddSeparator()
    accordion:AddLabel("⚡ Common Use Cases:")
    accordion:AddLabel("• Settings: Audio, display, gameplay preferences")
    accordion:AddLabel("• Features: Debug mode, experimental options")
    accordion:AddLabel("• States: Online/offline, enabled/disabled")
    accordion:AddLabel("• Modes: Easy/hard, light/dark, performance/quality")
    accordion:AddLabel("• Controls: Master switches, subsystem toggles")
    
    accordion:AddSeparator()
    accordion:AddLabel("🔧 Implementation Tips:")
    accordion:AddLabel("• Use Flag for automatic save/load functionality")
    accordion:AddLabel("• Validate state changes in callback functions")
    accordion:AddLabel("• Provide visual/audio feedback for state changes")
    accordion:AddLabel("• Consider default states for new vs returning users")
    accordion:AddLabel("• Group dependent toggles for better UX")
    
    accordion:AddSeparator()
    accordion:AddLabel("🎨 UI Design Tips:")
    accordion:AddLabel("• Use descriptive names instead of generic 'Toggle'")
    accordion:AddLabel("• Group similar toggles in sections")
    accordion:AddLabel("• Consider the impact of default states on UX")
    accordion:AddLabel("• Provide clear feedback when toggles interact")
    accordion:AddLabel("• Use emojis in names for visual categorization")
end

return Toggle