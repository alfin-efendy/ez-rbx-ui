-- Import library

-- If using as a ModuleScript in ReplicatedStorage, uncomment below:
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local EzUI = require(ReplicatedStorage:WaitForChild("EzUI"))

local EzUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/alfin-efendy/ez-rbx-ui/refs/heads/main/ui.lua'))()

-- Create window with configuration enabled
local window = EzUI.CreateWindow({
	Name = "My App",
	Width = 700, -- Optional: Override default calculated width
	Height = 400, -- Optional: Override default calculated height
	Opacity = 0.9,  -- 0.1 to 1.0 (10% to 100%)
	AutoAdapt = true, -- Optional: Auto-resize on viewport changes (default true)
	AutoShow = false, -- Start hidden, can be shown later
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "MyApp", -- Custom folder name
		FileName = "settings", -- Custom file name
		AutoLoad = true, -- Auto-load on window creation
		AutoSave = true, -- Auto-save on window close
	},
})

-- Create a tab
local tab = window:AddTab({
    Name = "Inputs",
    Icon = "ℹ️",
    Visible = true,
    Callback = function(tabName, activated)
        print("Tab", tabName, activated and "activated" or "deactivated")
    end
})

-- Test Toggle with Flag
tab:AddToggle({
	Name = "Enable Feature",
	Default = false,
	Flag = "EnableFeature", -- This will save/load automatically
	Callback = function(value)
		print("Feature enabled:", value)
	end
})

-- Test TextBox with Flag
tab:AddTextBox({
	Name = "Username",
	Placeholder = "Enter your username...",
	Default = "Player",
	Flag = "Username", -- This will save/load automatically
	Callback = function(text)
		print("Username set to:", text)
	end
})

-- Test NumberBox with Flag
tab:AddNumberBox({
	Name = "Speed",
	Placeholder = "Enter speed...",
	Default = 16,
	Min = 0,
	Max = 100,
	Increment = 1,
	Flag = "PlayerSpeed", -- This will save/load automatically
	Callback = function(value)
		print("Speed set to:", value)
	end
})

-- Test SelectBox with Flag
tab:AddSelectBox({
	Name = "Theme",
	Options = {"Dark", "Light", "Auto"},
	Default = "Dark",
	Flag = "AppTheme", -- This will save/load automatically
	Callback = function(selected)
		print("Theme set to:", selected[1])
	end
})

-- Test MultiSelect with Flag
tab:AddSelectBox({
	Name = "Features",
	Options = {"Feature A", "Feature B", "Feature C"},
	MultiSelect = true,
	Placeholder = "Select features...",
	Flag = "EnabledFeatures", -- This will save/load automatically
	Callback = function(selected)
		print("Features selected:", table.concat(selected, ", "))
	end
})

-- Test Accordion with Flags
local accordion = tab:AddAccordion({
    Title = "Advanced Features",
    Icon = "🚀",
    Expanded = false,
    Callback = function(expanded)
        print("Advanced Accordion:", expanded and "🚀 Expanded" or "🛸 Collapsed")
    end
})

accordion:AddToggle({
    Name = "Debug Mode",
    Default = false,
    Flag = "DebugMode",
    Callback = function(value)
        print("Debug mode:", value)
    end
})

accordion:AddTextBox({
    Name = "API Key",
    Placeholder = "Enter API key...",
    Default = "",
    Flag = "APIKey",
    Callback = function(text)
        print("API Key set")
    end
})

-- Manual configuration management
tab:AddButton(
	"Save Configuration",
	function()
		window:SaveConfiguration()
		print("Configuration saved manually!")
	end
)

tab:AddButton(
	"Load Configuration", 
	function()
		local loaded = window:LoadConfiguration()
		if loaded then
			print("Configuration loaded manually!")
		else
			print("No configuration found to load")
		end
	end
)

tab:AddButton(
	"Show Current Flags",
	function()
		print("Current flags:")
		for flag, value in pairs(EzUI.Flags) do
			print("  " .. flag .. ":", value)
		end
	end
)

tab:AddButton(
    "Debug",
    function()
        local HttpService = game:GetService("HttpService")
        local success, json = pcall(function()
            return HttpService:JSONEncode(EzUI.Flags)
        end)
        if success then
            print("Current Flags as JSON:", json)
        else
            print("Error encoding flags to JSON")
        end

        print("Configuration folder:", EzUI.Configuration.FolderName)
        print("Configuration file:", EzUI.Configuration.FileName)

         local filePath = EzUI.Configuration.FolderName .. "/" .. EzUI.Configuration.FileName .. ".json"
        if isfile(filePath) then
            local content = readfile(filePath)
            print("Configuration file content:", content)
        else
            print("Configuration file does not exist:", filePath)
        end

        writefile(filePath, tostring(json))
        print("Debug log written to", filePath)
    end
)

print("Configuration system test loaded!")
print("All components with Flag parameter will automatically save/load their values")
print("Configuration will be saved to:", "workspace/"..EzUI.Configuration.FolderName.."/"..EzUI.Configuration.FileName..".json")