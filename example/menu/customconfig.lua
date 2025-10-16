local CustomConfig = {}

function CustomConfig:Init(_window)
    local tab = _window:AddTab({
        Name = "Custom Config",
        Icon = "⚙️"
    })

    -- Basic intro
    tab:AddLabel("Custom Configuration Examples")
    tab:AddLabel("Learn how to create and manage multiple independent configurations")
    tab:AddSeparator()
    
    -- Create sections
    self:AddSectionBasic(tab)
    self:AddSectionUserData(tab, _window)
    self:AddSectionGameData(tab, _window)
    self:AddSectionManagement(tab, _window)
end

function CustomConfig:AddSectionBasic(tab)
    local accordion = tab:AddAccordion({
        Name = "Configuration Basics",
        Icon = "📚",
    })
    
    accordion:AddLabel("🎯 Two Types of Configuration in EzUI:")
    accordion:AddSeparator()
    
    accordion:AddLabel("1️⃣ DEFAULT CONFIG (Automatic)")
    accordion:AddLabel("• Created automatically in EzUI:CreateNew()")
    accordion:AddLabel("• Used by components with 'Flag' parameter")
    accordion:AddLabel("• Auto-saves when component values change")
    accordion:AddLabel("• Location: FolderName/Configurations/FileName.json")
    accordion:AddLabel("• Access via: window.Settings")
    
    accordion:AddSeparator()
    
    accordion:AddLabel("2️⃣ CUSTOM CONFIG (Manual)")
    accordion:AddLabel("• Created manually with EzUI:NewConfig()")
    accordion:AddLabel("• Full manual control with SetValue/GetValue")
    accordion:AddLabel("• Custom directory and filename")
    accordion:AddLabel("• Perfect for user data, game progress, etc.")
    accordion:AddLabel("• Independent from default config")
    
    accordion:AddSeparator()
    
    accordion:AddLabel("📋 Code Examples:")
    accordion:AddSeparator()
    
    accordion:AddLabel("DEFAULT CONFIG Usage:")
    accordion:AddLabel("```lua")
    accordion:AddLabel("-- Components with Flag use default config")
    accordion:AddLabel("tab:AddToggle({")
    accordion:AddLabel("    Name = 'Dark Mode',")
    accordion:AddLabel("    Flag = 'DarkMode'  -- Auto-saved!")
    accordion:AddLabel("})")
    accordion:AddLabel("```")
    
    accordion:AddSeparator()
    
    accordion:AddLabel("CUSTOM CONFIG Usage:")
    accordion:AddLabel("```lua")
    accordion:AddLabel("-- Create custom config")
    accordion:AddLabel("local customConfig = EzUI:NewConfig({")
    accordion:AddLabel("    ConfigName = 'UserProfile',")
    accordion:AddLabel("    Directory = 'MyApp/Users'")
    accordion:AddLabel("})")
    accordion:AddLabel("customConfig:Load()")
    accordion:AddLabel("customConfig:SetValue('Username', 'John')")
    accordion:AddLabel("```")
end

function CustomConfig:AddSectionUserData(tab, _window)
    local accordion = tab:AddAccordion({
        Name = "User Profile Config",
        Icon = "👤",
    })
    
    -- Create custom config for user data
    local userConfig = _window.EzUI:NewConfig({
        ConfigName = "UserProfile_Demo",
        Directory = "EzUIExample/UserData"
    })
    
    -- Load existing data
    userConfig:Load()
    
    accordion:AddLabel("This section uses CUSTOM CONFIG for user profile data:")
    accordion:AddSeparator()
    
    -- Username field
    local currentUsername = userConfig:GetValue("Username") or ""
    accordion:AddTextBox({
        Name = "Username",
        Text = currentUsername,
        Placeholder = "Enter your username...",
        Callback = function(value)
            userConfig:SetValue("Username", value)
            print("👤 Username saved to custom config:", value)
        end
    })
    
    -- Email field
    local currentEmail = userConfig:GetValue("Email") or ""
    accordion:AddTextBox({
        Name = "Email Address", 
        Text = currentEmail,
        Placeholder = "Enter your email...",
        Callback = function(value)
            userConfig:SetValue("Email", value)
            print("📧 Email saved to custom config:", value)
        end
    })
    
    -- Age field
    local currentAge = userConfig:GetValue("Age") or 18
    accordion:AddNumberBox({
        Name = "Age",
        Min = 13,
        Max = 100,
        Default = currentAge,
        Callback = function(value)
            userConfig:SetValue("Age", value)
            print("🎂 Age saved to custom config:", value)
        end
    })
    
    -- Preferences
    local currentNotifications = userConfig:GetValue("EmailNotifications")
    if currentNotifications == nil then currentNotifications = false end
    
    accordion:AddToggle({
        Name = "Email Notifications",
        Default = currentNotifications,
        Callback = function(value)
            userConfig:SetValue("EmailNotifications", value)
            print("📬 Email notifications:", value and "ON" or "OFF")
        end
    })
    
    -- Theme preference
    local currentTheme = userConfig:GetValue("PreferredTheme") or "Dark"
    accordion:AddSelectBox({
        Name = "Preferred Theme",
        Options = {"Dark", "Light", "Auto", "High Contrast"},
        Callback = function(selectedValues)
            local theme = type(selectedValues) == "table" and selectedValues[1] or selectedValues
            userConfig:SetValue("PreferredTheme", theme)
            print("🎨 Theme preference saved:", theme)
        end
    })
    
    accordion:AddSeparator()
    
    -- Load profile button
    accordion:AddButton({
        Name = "📂 Load Profile Data",
        Callback = function()
            print("\n=== USER PROFILE DATA ===")
            print("👤 Username:", userConfig:GetValue("Username") or "Not set")
            print("📧 Email:", userConfig:GetValue("Email") or "Not set")
            print("🎂 Age:", userConfig:GetValue("Age") or "Not set")
            print("📬 Notifications:", userConfig:GetValue("EmailNotifications") and "ON" or "OFF")
            print("🎨 Theme:", userConfig:GetValue("PreferredTheme") or "Not set")
            print("📁 Config file:", userConfig:GetInfo().FilePath)
        end
    })
    
    -- Clear profile button
    accordion:AddButton({
        Name = "🗑️ Clear Profile",
        Callback = function()
            userConfig:DeleteKey("Username")
            userConfig:DeleteKey("Email")
            userConfig:DeleteKey("Age")
            userConfig:DeleteKey("EmailNotifications")
            userConfig:DeleteKey("PreferredTheme")
            print("🗑️ User profile cleared!")
        end
    })
end

function CustomConfig:AddSectionGameData(tab, _window)
    local accordion = tab:AddAccordion({
        Name = "Game Progress Config",
        Icon = "🎮",
    })
    
    -- Create separate config for game data
    local gameConfig = _window.EzUI:NewConfig({
        ConfigName = "GameProgress_Demo",
        Directory = "EzUIExample/GameData"
    })
    
    gameConfig:Load()
    
    accordion:AddLabel("This uses ANOTHER custom config for game progress:")
    accordion:AddSeparator()
    
    -- Game stats
    local currentLevel = gameConfig:GetValue("PlayerLevel") or 1
    local currentScore = gameConfig:GetValue("HighScore") or 0
    local currentCoins = gameConfig:GetValue("Coins") or 100
    
    accordion:AddNumberBox({
        Name = "Player Level",
        Min = 1,
        Max = 100,
        Default = currentLevel,
        Callback = function(value)
            gameConfig:SetValue("PlayerLevel", value)
            print("📊 Level saved:", value)
        end
    })
    
    accordion:AddNumberBox({
        Name = "High Score",
        Min = 0,
        Max = 999999,
        Default = currentScore,
        Callback = function(value)
            gameConfig:SetValue("HighScore", value)
            print("🏆 High score saved:", value)
        end
    })
    
    accordion:AddNumberBox({
        Name = "Coins",
        Min = 0,
        Max = 999999,
        Default = currentCoins,
        Callback = function(value)
            gameConfig:SetValue("Coins", value)
            print("💰 Coins saved:", value)
        end
    })
    
    -- Game actions
    accordion:AddSeparator()
    
    accordion:AddButton({
        Name = "🎯 Complete Level",
        Callback = function()
            local currentLvl = gameConfig:GetValue("PlayerLevel") or 1
            local newLevel = math.min(currentLvl + 1, 100)
            local bonusCoins = newLevel * 10
            local currentCoins = gameConfig:GetValue("Coins") or 0
            
            gameConfig:SetValue("PlayerLevel", newLevel)
            gameConfig:SetValue("Coins", currentCoins + bonusCoins)
            
            print("🎉 Level completed!")
            print("📈 New level:", newLevel)
            print("💰 Coins earned:", bonusCoins)
            print("💳 Total coins:", currentCoins + bonusCoins)
        end
    })
    
    accordion:AddButton({
        Name = "💎 Spend 50 Coins",
        Callback = function()
            local currentCoins = gameConfig:GetValue("Coins") or 0
            if currentCoins >= 50 then
                gameConfig:SetValue("Coins", currentCoins - 50)
                print("💸 Spent 50 coins!")
                print("💳 Remaining coins:", currentCoins - 50)
            else
                print("❌ Not enough coins! You have:", currentCoins)
            end
        end
    })
    
    accordion:AddButton({
        Name = "🏆 New High Score",
        Callback = function()
            local currentScore = gameConfig:GetValue("HighScore") or 0
            local newScore = currentScore + math.random(100, 1000)
            gameConfig:SetValue("HighScore", newScore)
            print("🏆 New high score achieved:", newScore)
        end
    })
    
    accordion:AddButton({
        Name = "📊 Show Game Stats",
        Callback = function()
            print("\n=== GAME STATISTICS ===")
            print("📊 Level:", gameConfig:GetValue("PlayerLevel") or 1)
            print("🏆 High Score:", gameConfig:GetValue("HighScore") or 0)
            print("💰 Coins:", gameConfig:GetValue("Coins") or 0)
            print("📁 Config file:", gameConfig:GetInfo().FilePath)
        end
    })
end

function CustomConfig:AddSectionManagement(tab, _window)
    local accordion = tab:AddAccordion({
        Name = "Config Management",
        Icon = "🔧",
    })
    
    accordion:AddLabel("Compare DEFAULT config vs CUSTOM configs:")
    accordion:AddSeparator()
    
    -- Show default config data
    accordion:AddButton({
        Name = "📋 Show Default Config",
        Callback = function()
            print("\n=== DEFAULT CONFIG DATA ===")
            print("(Components with Flag parameter)")
            local data = _window.Settings:GetAll()
            if next(data) then
                for key, value in pairs(data) do
                    print("  " .. key .. ": " .. tostring(value))
                end
            else
                print("  No data saved yet")
            end
            print("📁 File:", _window.Settings:GetInfo().FilePath)
        end
    })
    
    -- Show all configs
    accordion:AddButton({
        Name = "📊 Show All Config Files",
        Callback = function()
            print("\n=== ALL CONFIGURATION FILES ===")
            
            -- Default config
            local defaultInfo = _window.Settings:GetInfo()
            print("1️⃣ DEFAULT CONFIG:")
            print("   📁 File:", defaultInfo.FilePath)
            print("   🔧 Type: Auto-managed (Flag components)")
            
            -- User config
            local userConfig = _window.EzUI:NewConfig({
                ConfigName = "UserProfile_Demo",
                Directory = "EzUIExample/UserData"
            })
            local userInfo = userConfig:GetInfo()
            print("\n2️⃣ USER PROFILE CONFIG:")
            print("   📁 File:", userInfo.FilePath)
            print("   🔧 Type: Manual control (SetValue/GetValue)")
            
            -- Game config  
            local gameConfig = _window.EzUI:NewConfig({
                ConfigName = "GameProgress_Demo",
                Directory = "EzUIExample/GameData"
            })
            local gameInfo = gameConfig:GetInfo()
            print("\n3️⃣ GAME DATA CONFIG:")
            print("   📁 File:", gameInfo.FilePath)
            print("   🔧 Type: Manual control (SetValue/GetValue)")
            
            print("\n💡 Benefits of multiple configs:")
            print("• Separate data types for better organization")
            print("• Independent backup and sharing")
            print("• Different access patterns (auto vs manual)")
        end
    })
    
    -- Save all configs
    accordion:AddButton({
        Name = "💾 Save All Configs",
        Callback = function()
            print("\n💾 Saving all configurations...")
            
            -- Save default
            local defaultSaved = _window.Settings:Save()
            print("1️⃣ Default config:", defaultSaved and "✅ SUCCESS" or "❌ FAILED")
            
            -- Save user config
            local userConfig = _window.EzUI:NewConfig({
                ConfigName = "UserProfile_Demo", 
                Directory = "EzUIExample/UserData"
            })
            local userSaved = userConfig:Save()
            print("2️⃣ User config:", userSaved and "✅ SUCCESS" or "❌ FAILED")
            
            -- Save game config
            local gameConfig = _window.EzUI:NewConfig({
                ConfigName = "GameProgress_Demo",
                Directory = "EzUIExample/GameData"  
            })
            local gameSaved = gameConfig:Save()
            print("3️⃣ Game config:", gameSaved and "✅ SUCCESS" or "❌ FAILED")
            
            print("💾 All configurations saved!")
        end
    })
    
    accordion:AddSeparator()
    
    -- API examples
    accordion:AddLabel("🔍 API Methods Available:")
    accordion:AddLabel("• config:GetValue(key) - Get single value")
    accordion:AddLabel("• config:SetValue(key, value) - Set single value")
    accordion:AddLabel("• config:GetAll() - Get all key-value pairs")
    accordion:AddLabel("• config:GetAllKeys() - Get all keys")
    accordion:AddLabel("• config:DeleteKey(key) - Remove specific key")
    accordion:AddLabel("• config:Save() - Manual save to file")
    accordion:AddLabel("• config:Load() - Load from file")
    accordion:AddLabel("• config:GetInfo() - Get config file information")
    
    accordion:AddSeparator()
    
    accordion:AddLabel("💡 Usage Tips:")
    accordion:AddLabel("• Use default config for UI settings")
    accordion:AddLabel("• Use custom configs for user/game data")
    accordion:AddLabel("• Always call Load() after creating custom config")
    accordion:AddLabel("• SetValue() automatically saves to file")
    accordion:AddLabel("• Different configs = different files & directories")
    
    accordion:AddSeparator()
    
    -- Add some components using default config for comparison
    accordion:AddLabel("🔄 DEFAULT CONFIG Examples (for comparison):")
    accordion:AddLabel("These components use the default config with Flag parameter:")
    
    accordion:AddToggle({
        Name = "Example: Enable Auto-Save",
        Flag = "Demo_AutoSave",  -- This goes to default config
        Callback = function(value)
            print("🔄 Auto-save (DEFAULT config):", value and "ON" or "OFF")
        end
    })
    
    accordion:AddSelectBox({
        Name = "Example: Default Language",
        Options = {"English", "Indonesian", "Spanish", "French"},
        Flag = "Demo_Language",  -- This goes to default config
        Callback = function(selectedValues)
            local language = type(selectedValues) == "table" and selectedValues[1] or selectedValues
            print("🌐 Language (DEFAULT config):", language)
        end
    })
    
    accordion:AddLabel("👆 These components automatically save to default config!")
    accordion:AddLabel("Compare with custom config components above 👆")
end

return CustomConfig