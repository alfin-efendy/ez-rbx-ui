-- Import library

-- If using as a ModuleScript in ReplicatedStorage roblox studio:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EzUI = require(ReplicatedStorage:WaitForChild("EzUI"))

-- If using via loadstring, uncomment below:
-- local EzUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/alfin-efendy/ez-rbx-ui/refs/heads/main/ui.lua'))()

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

-- New Custom Configuration System Examples
print("\n=== Custom Configuration System Examples ===")

-- Example 1: Create a custom configuration
print("\n1. Create custom configuration:")
local customConfig = EzUI.NewConfig("CustomConfig")

-- Example 2: Set and get values in custom config
print("\n2. Set and get values in custom config:")
customConfig.SetValue("PlayerPreference", "Dark Mode")
customConfig.SetValue("Volume", 75)
customConfig.SetValue("AutoConnect", true)

print("PlayerPreference:", customConfig.GetValue("PlayerPreference"))
print("Volume:", customConfig.GetValue("Volume"))
print("AutoConnect:", customConfig.GetValue("AutoConnect"))

-- Example 3: Update a value
print("\n3. Update a value:")
customConfig.SetValue("Volume", 85)
print("Updated Volume:", customConfig.GetValue("Volume"))

-- Example 4: Delete By Key
print("\n4. Delete by key:")
customConfig.DeleteKey("AutoConnect")

-- Example 5: Get all config keys and values
print("\n5. Get all config keys and values:")
local allConfigs = customConfig.GetAll()
print("All configurations:")
for key, value in pairs(allConfigs) do
	print("  " .. key .. ":", value)
end

-- Example 6: SelectBox with OnDropdownOpen callback
print("\n6. SelectBox with dynamic options:")
local dynamicOptions = {
	{text = "Option 1", value = "opt1"},
	{text = "Option 2", value = "opt2"}
}

tab:AddSelectBox({
	Name = "Dynamic SelectBox",
	Options = dynamicOptions,
	Default = "opt1",
	Flag = "DynamicSelect",
	Callback = function(selectedValues, changedValue)
		print("Dynamic SelectBox changed:", selectedValues[1] or "none")
	end,
	OnDropdownOpen = function(currentOptions, updateOptions)
		print("Dropdown opened! Current options count:", #currentOptions)
		
		-- Simulate dynamic data loading (e.g., from server, time-based data)
		local timeBasedOptions = {
			{text = "Current Time Option: " .. os.date("%H:%M:%S"), value = "time_" .. os.time()},
			{text = "Random Option: " .. math.random(1, 100), value = "random_" .. math.random(1, 100)},
			{text = "Static Option 1", value = "static1"},
			{text = "Static Option 2", value = "static2"}
		}
		
		-- Update the options with new data
		updateOptions(timeBasedOptions)
		print("Options updated with", #timeBasedOptions, "new options")
	end
})

-- Example 7: Multi-select SelectBox with OnDropdownOpen
print("\n7. Multi-select SelectBox with dynamic options:")
tab:AddSelectBox({
	Name = "Dynamic Multi-Select",
	Options = {{text = "Loading...", value = "loading"}},
	Default = {},
	MultiSelect = true,
	Flag = "DynamicMultiSelect",
	Callback = function(selectedValues, changedValue)
		print("Dynamic Multi-Select changed. Selected:", table.concat(selectedValues, ", "))
	end,
	OnDropdownOpen = function(currentOptions, updateOptions)
		-- Simulate loading data from different sources
		local serverData = {
			{text = "Server Item 1", value = "server1"},
			{text = "Server Item 2", value = "server2"},
			{text = "Server Item 3", value = "server3"}
		}
		
		local userPreferences = customConfig.GetAll()
		local configOptions = {}
		
		-- Convert custom config to options
		for key, value in pairs(userPreferences) do
			table.insert(configOptions, {
				text = key .. ": " .. tostring(value),
				value = "config_" .. key
			})
		end
		
		-- Combine all options
		local combinedOptions = {}
		for _, option in ipairs(serverData) do
			table.insert(combinedOptions, option)
		end
		for _, option in ipairs(configOptions) do
			table.insert(combinedOptions, option)
		end
		
		updateOptions(combinedOptions)
		print("Loaded", #combinedOptions, "options from multiple sources")
	end
})