local EzUI = require("../output/bundle")
local Label = require("menu/label")
local Button = require("menu/button")
local TextBox = require("menu/textbox")
local NumberBox = require("menu/numberbox")
local Toggle = require("menu/toggle")
local SelectBox = require("menu/selectbox")
local Notification = require("menu/notification")

local window = EzUI:CreateNew({
    Name = "Example",
    Width = 750,
    Height = 400,
    Opacity = 0.9,
    AutoAdapt = true,
    AutoShow = true,
    FolderName = "EzUIExample",
    FileName = "ExampleConfig",
    OnClose = function()
        print("🔔 Window is closing!")
        print("💾 Saving user preferences...")
        
        -- Example: Save any unsaved data
        -- Could save current settings, user preferences, etc.
        print("✅ Data saved successfully!")
        print("👋 Thank you for using EzUI Example!")
        
        -- Optional: Show confirmation that data was saved
        warn("EzUI Example window closed - all data has been saved.")
    end
})

-- Set up additional close callback after window creation (demonstrates API usage)
window:SetCloseCallback(function()
    print("🔧 Additional close callback triggered!")
    print("🧹 Cleaning up resources...")
    
    -- Example cleanup operations
    print("  - Disconnecting event listeners")
    print("  - Clearing cached data") 
    print("  - Saving final state")
    
    -- Simulate cleanup delay
    wait(0.5)
    print("✨ Cleanup completed!")
    
    -- Final goodbye message
    print("===================================")
    print("🎉 EzUI Example Session Ended")
    print("📊 Session Statistics:")
    print("  - Components demonstrated: 7")
    print("  - Examples shown: 50+")
    print("  - Close callbacks: Working!")
    print("===================================")
end)

-- Initialize component examples
Label:Init(window)
Button:Init(window)
TextBox:Init(window)
NumberBox:Init(window)
Toggle:Init(window)
SelectBox:Init(window)
Notification:Init(window)