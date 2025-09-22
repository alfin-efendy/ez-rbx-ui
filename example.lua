-- Import library
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EzUILib = require(ReplicatedStorage:WaitForChild("EzUI"))

-- local EzUILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/alfin-efendy/ez-rbx-ui/refs/heads/main/ui.lua'))()

-- Create window and set properties
local window = EzUILib.CreateWindow({
	Name = "My New UI",
	Width = 400, -- Optional: Override default calculated width
	Height = 300, -- Optional: Override default calculated height
	Opacity = 0.9,  -- 0.1 to 1.0 (10% to 100%)
	AutoAdapt = true, -- Optional: Auto-resize on viewport changes (default true)
})

-- Set up close callback (optional)
window:SetCloseCallback(function()
	print("Window is closing! Performing cleanup...")
	
	-- You can add cleanup logic here:
	-- - Save data
	-- - Disconnect events
	-- - Clean up variables
	-- - Show confirmation dialog
	
	print("Cleanup completed!")
end)

-- Create tabs and store references
local inputTab = window:AddTab({
    Name = "Inputs",
    Icon = "ℹ️",
    Visible = true,
    Callback = function(tabName, activated)
        print("Tab", tabName, activated and "activated" or "deactivated")
    end
})
local selectBoxTab = window:AddTab("Select Box")
local toggleTab = window:AddTab("Toggles")
local accordionTab = window:AddTab("Accordions")

-- Add input field to inputTab
inputTab:AddLabel("TextBox & NumberBox Components")
inputTab:AddLabel("")

-- TextBox Examples
inputTab:AddLabel("Single Line TextBox:")

local nameTextBox = inputTab:AddTextBox({
	Placeholder = "Enter your name...",
	Default = "",
	MaxLength = 50,
	Callback = function(text)
		print("Name changed:", text)
	end
})

inputTab:AddLabel("Multi-line TextBox:")

local descriptionTextBox = inputTab:AddTextBox({
	Placeholder = "Enter a description...",
	Default = "Type your story here...",
	MaxLength = 200,
	Multiline = true,
	Callback = function(text)
		print("Description changed:", text)
	end
})

inputTab:AddLabel("TextBox Control Buttons:")

inputTab:AddButton("Get Name Text", function()
	local text = nameTextBox.GetText()
	print("Current name:", text)
end)

inputTab:AddButton("Set Name", function()
	nameTextBox.SetText("John Doe")
	print("Name set to: John Doe")
end)

inputTab:AddButton("Clear Name", function()
	nameTextBox.Clear()
	print("Name cleared!")
end)

inputTab:AddButton("Focus Name Box", function()
	nameTextBox.Focus()
	print("Name box focused!")
end)

inputTab:AddLabel("")
inputTab:AddLabel("NumberBox Examples:")

-- NumberBox Examples
inputTab:AddLabel("Age NumberBox (Integer):")

local ageNumberBox = inputTab:AddNumberBox({
	Placeholder = "Age",
	Default = 18,
	Min = 0,
	Max = 120,
	Increment = 1,
	Decimals = 0,
	Callback = function(value)
		print("Age changed:", value)
	end
})

inputTab:AddLabel("Price NumberBox (Decimal):")

local priceNumberBox = inputTab:AddNumberBox({
	Placeholder = "Price ($)",
	Default = 9.99,
	Min = 0,
	Max = 999.99,
	Increment = 0.01,
	Decimals = 2,
	Callback = function(value)
		print("Price changed: $" .. value)
	end
})

inputTab:AddLabel("Percentage NumberBox:")

local percentageNumberBox = inputTab:AddNumberBox({
	Placeholder = "Percentage (%)",
	Default = 50,
	Min = 0,
	Max = 100,
	Increment = 5,
	Decimals = 1,
	Callback = function(value)
		print("Percentage changed:", value .. "%")
	end
})

inputTab:AddLabel("NumberBox Control Buttons:")

inputTab:AddButton("Get Age", function()
	local age = ageNumberBox.GetValue()
	print("Current age:", age)
end)

inputTab:AddButton("Set Age to 25", function()
	ageNumberBox.SetValue(25)
	print("Age set to 25")
end)

inputTab:AddButton("Get Price", function()
	local price = priceNumberBox.GetValue()
	print("Current price: $" .. price)
end)

inputTab:AddButton("Set Price to $19.99", function()
	priceNumberBox.SetValue(19.99)
	print("Price set to $19.99")
end)

inputTab:AddButton("Random Percentage", function()
	local randomPercent = math.random(0, 100)
	percentageNumberBox.SetValue(randomPercent)
	print("Percentage set to:", randomPercent .. "%")
end)

inputTab:AddLabel("")
inputTab:AddLabel("Advanced NumberBox Features:")

-- Advanced NumberBox with dynamic limits
local dynamicNumberBox = inputTab:AddNumberBox({
	Placeholder = "Dynamic limits...",
	Default = 50,
	Min = 0,
	Max = 100,
	Increment = 1,
	Decimals = 0,
	Callback = function(value)
		print("Dynamic value:", value)
	end
})

inputTab:AddButton("Set Min to 10", function()
	dynamicNumberBox.SetMin(10)
	print("Minimum set to 10")
end)

inputTab:AddButton("Set Max to 200", function()
	dynamicNumberBox.SetMax(200)
	print("Maximum set to 200")
end)

inputTab:AddButton("Set Increment to 10", function()
	dynamicNumberBox.SetIncrement(10)
	print("Increment set to 10")
end)

inputTab:AddButton("Reset Limits", function()
	dynamicNumberBox.SetMin(0)
	dynamicNumberBox.SetMax(100)
	dynamicNumberBox.SetIncrement(1)
	print("Limits reset to 0-100, increment 1")
end)

inputTab:AddLabel("")
inputTab:AddLabel("Form Example - User Registration:")

-- Form example combining multiple inputs
local formData = {}

local usernameInput = inputTab:AddTextBox({
	Placeholder = "Username (3-20 chars)",
	MaxLength = 20,
	Callback = function(text)
		formData.username = text
		print("Username:", text)
	end
})

local emailInput = inputTab:AddTextBox({
	Placeholder = "Email address",
	MaxLength = 100,
	Callback = function(text)
		formData.email = text
		print("Email:", text)
	end
})

local ageInput = inputTab:AddNumberBox({
	Placeholder = "Age",
	Default = 18,
	Min = 13,
	Max = 100,
	Increment = 1,
	Decimals = 0,
	Callback = function(value)
		formData.age = value
		print("Age:", value)
	end
})

local bioInput = inputTab:AddTextBox({
	Placeholder = "Tell us about yourself...",
	MaxLength = 500,
	Multiline = true,
	Callback = function(text)
		formData.bio = text
		print("Bio length:", string.len(text))
	end
})

inputTab:AddButton("Submit Form", function()
	print("=== FORM SUBMISSION ===")
	print("Username:", formData.username or "Not set")
	print("Email:", formData.email or "Not set")
	print("Age:", formData.age or "Not set")
	print("Bio:", formData.bio or "Not set")
	print("========================")
end)

inputTab:AddButton("Clear Form", function()
	usernameInput.Clear()
	emailInput.Clear()
	ageInput.SetValue(18)
	bioInput.Clear()
	formData = {}
	print("Form cleared!")
end)

-- Add select box to selectBoxTab
selectBoxTab:AddLabel("Single Select SelectBox (Object Format):")

-- SelectBox with single select using object format
local singleSelect = selectBoxTab:AddSelectBox({
	Placeholder = "Choose one country...",
	Options = {
		{text = "🇮🇩 Indonesia", value = "ID"},
		{text = "🇲🇾 Malaysia", value = "MY"},
		{text = "🇸🇬 Singapore", value = "SG"},
		{text = "🇹🇭 Thailand", value = "TH"},
		{text = "🇵🇭 Philippines", value = "PH"},
		{text = "🇻🇳 Vietnam", value = "VN"},
		{text = "🇲🇲 Myanmar", value = "MM"},
		{text = "🇱🇦 Laos", value = "LA"},
		{text = "🇰🇭 Cambodia", value = "KH"},
		{text = "🇧🇳 Brunei", value = "BN"}
	},
	MultiSelect = false,
	PreventAutoClose = false,
	Callback = function(selected, clicked)
		print("Single select - Selected values:", table.concat(selected, ", "))
		print("Clicked value:", clicked)
	end
})

selectBoxTab:AddButton("Get Selected", function()
	local selected = singleSelect.GetSelected()
	print("Current selection values:", table.concat(selected, ", "))
end)

selectBoxTab:AddButton("Set Selection", function()
	singleSelect.SetSelected({"ID"}) -- Use value, not display text
end)

selectBoxTab:AddButton("Set Different Country", function()
	singleSelect.SetSelected({"SG"}) -- Singapore by value
end)

selectBoxTab:AddButton("Clear Selection", function()
	singleSelect.Clear()
end)

selectBoxTab:AddLabel("Multi Select SelectBox (Object Format):")

-- SelectBox with multi select using object format
local multiSelect = selectBoxTab:AddSelectBox({
	Placeholder = "Choose multiple programming languages...",
	Options = {
		{text = "🐍 Python", value = "python"},
		{text = "⚛️ JavaScript", value = "javascript"},
		{text = "🌕 Lua", value = "lua"},
		{text = "☕ Java", value = "java"},
		{text = "⚡ C++", value = "cpp"},
		{text = "🦀 Rust", value = "rust"},
		{text = "💎 Ruby", value = "ruby"},
		{text = "🔷 TypeScript", value = "typescript"},
		{text = "🐹 Go", value = "go"},
		{text = "🔥 C#", value = "csharp"}
	},
	MultiSelect = true,
	PreventAutoClose = false,
	Callback = function(selected, clicked)
		print("Multi select - All selected values:", table.concat(selected, ", "))
		print("Last clicked value:", clicked)
	end
})

selectBoxTab:AddButton("Get All Selected", function()
	local selected = multiSelect.GetSelected()
	print("Currently selected values:", table.concat(selected, ", "))
	print("Total count:", #selected)
end)

selectBoxTab:AddButton("Set Web Languages", function()
	multiSelect.SetSelected({"javascript", "typescript", "python"}) -- Use values
end)

selectBoxTab:AddButton("Set System Languages", function()
	multiSelect.SetSelected({"cpp", "rust", "go", "csharp"}) -- Use values
end)

selectBoxTab:AddButton("Clear All", function()
	multiSelect.Clear()
end)

selectBoxTab:AddLabel("Dynamic Options SelectBox:")

local dynamicSelect = selectBoxTab:AddSelectBox({
	Placeholder = "Dynamic options...",
	Options = {
		{text = "📱 Mobile", value = "mobile"},
		{text = "💻 Desktop", value = "desktop"}
	},
	MultiSelect = false,
	PreventAutoClose = false,
	Callback = function(selected, clicked)
		print("Dynamic - Selected values:", table.concat(selected, ", "))
		print("Dynamic - Clicked value:", clicked)
	end
})

selectBoxTab:AddButton("Add Number Options", function()
	local numberOptions = {}
	for i = 1, 10 do
		table.insert(numberOptions, {
			text = "🔢 Number " .. i,
			value = "num_" .. i
		})
	end
	dynamicSelect.Refresh(numberOptions)
end)

selectBoxTab:AddButton("Add Color Options", function()
	local colorOptions = {
		{text = "🔴 Red", value = "red"},
		{text = "🟢 Green", value = "green"},
		{text = "🔵 Blue", value = "blue"},
		{text = "🟡 Yellow", value = "yellow"},
		{text = "🟣 Purple", value = "purple"},
		{text = "🟠 Orange", value = "orange"},
		{text = "🩷 Pink", value = "pink"},
		{text = "🩵 Cyan", value = "cyan"}
	}
	dynamicSelect.Refresh(colorOptions)
end)

selectBoxTab:AddButton("Add Animal Options", function()
	local animalOptions = {
		{text = "🐱 Cat", value = "cat"},
		{text = "🐶 Dog", value = "dog"},
		{text = "🐦 Bird", value = "bird"},
		{text = "🐠 Fish", value = "fish"},
		{text = "🐰 Rabbit", value = "rabbit"},
		{text = "🐹 Hamster", value = "hamster"},
		{text = "🐢 Turtle", value = "turtle"},
		{text = "🐍 Snake", value = "snake"}
	}
	dynamicSelect.Refresh(animalOptions)
end)

-- Add backward compatibility demonstration
selectBoxTab:AddLabel("")
selectBoxTab:AddLabel("Legacy String Array (Backward Compatible):")

local legacySelect = selectBoxTab:AddSelectBox({
	Placeholder = "Old format still works...",
	Options = {"Legacy Option 1", "Legacy Option 2", "Legacy Option 3"}, -- Old string format
	MultiSelect = false,
	PreventAutoClose = false,
	Callback = function(selected, clicked)
		print("Legacy - Selected:", table.concat(selected, ", "))
		print("Legacy - Clicked:", clicked)
	end
})

selectBoxTab:AddButton("Test Legacy Format", function()
	legacySelect.SetSelected({"Legacy Option 2"})
	print("Legacy format works! Selected: Legacy Option 2")
end)

-- Add toggles to toggleTab
toggleTab:AddLabel("Komponen Toggle - Testing Suite")
toggleTab:AddLabel("")

-- Test 1: Basic Toggle (default false)
local basicToggle = toggleTab:AddToggle({
	Name = "Basic Toggle",
	Default = false,
	Callback = function(Value)
		print("Basic Toggle changed:", Value)
	end
})

-- Test 2: Toggle dengan default true
local enabledToggle = toggleTab:AddToggle({
	Name = "Pre-enabled Toggle",
	Default = true,
	Callback = function(Value)
		print("Pre-enabled Toggle:", Value)
	end
})

-- Test 3: Toggle untuk fitur
local featureToggle = toggleTab:AddToggle({
	Name = "Enable Advanced Features",
	Default = false,
	Callback = function(Value)
		if Value then
			print("✅ Advanced features activated!")
		else
			print("❌ Advanced features deactivated!")
		end
	end
})

-- Test 4: Toggle untuk notifikasi
local notifToggle = toggleTab:AddToggle({
	Name = "Show Notifications",
	Default = true,
	Callback = function(Value)
		print("Notifications:", Value and "🔔 ON" or "🔕 OFF")
	end
})

-- Test 5: Toggle untuk debug mode
local debugToggle = toggleTab:AddToggle({
	Name = "Debug Mode",
	Default = false,
	Callback = function(Value)
		print("Debug Mode:", Value and "🐛 ENABLED" or "🚫 DISABLED")
		if Value then
			print("Debug info will be shown")
		else
			print("Debug info hidden")
		end
	end
})

-- Test 6: Toggle untuk sound
local soundToggle = toggleTab:AddToggle({
	Name = "Sound Effects",
	Default = true,
	Callback = function(Value)
		print("Sound Effects:", Value and "🔊 ON" or "🔇 OFF")
	end
})

toggleTab:AddLabel("")
toggleTab:AddLabel("Toggle Control Buttons:")

-- Button untuk menampilkan semua status
toggleTab:AddButton("Show All States", function()
	print("=== TOGGLE STATES ===")
	print("Basic Toggle:", basicToggle:GetValue())
	print("Pre-enabled Toggle:", enabledToggle:GetValue())
	print("Advanced Features:", featureToggle:GetValue())
	print("Notifications:", notifToggle:GetValue())
	print("Debug Mode:", debugToggle:GetValue())
	print("Sound Effects:", soundToggle:GetValue())
	print("====================")
end)

-- Button untuk enable semua
toggleTab:AddButton("Enable All", function()
	basicToggle:SetValue(true)        -- ✅ Pass boolean
	enabledToggle:SetValue(true)      -- ✅ Pass boolean  
	featureToggle:SetValue(true)      -- ✅ Pass boolean
	notifToggle:SetValue(true)        -- ✅ Pass boolean
	debugToggle:SetValue(true)        -- ✅ Pass boolean
	soundToggle:SetValue(true)        -- ✅ Pass boolean
	print("🟢 All toggles enabled!")
end)

-- Button untuk disable semua
toggleTab:AddButton("Disable All", function()
	basicToggle:SetValue(false)
	enabledToggle:SetValue(false)
	featureToggle:SetValue(false)
	notifToggle:SetValue(false)
	debugToggle:SetValue(false)
	soundToggle:SetValue(false)
	print("🔴 All toggles disabled!")
end)

-- Button untuk randomize
toggleTab:AddButton("Randomize All", function()
	local toggles = {basicToggle, enabledToggle, featureToggle, notifToggle, debugToggle, soundToggle}
	for _, toggle in ipairs(toggles) do
		toggle:SetValue(math.random() > 0.5)
	end
	print("🎲 All toggles randomized!")
end)

-- ===== ACCORDION TAB =====
accordionTab:AddLabel("Komponen Accordion - Collapsible Sections")
accordionTab:AddLabel("")

-- Basic Accordion (collapsed by default)
local basicAccordion = accordionTab:AddAccordion({
	Title = "Basic Accordion",
	Icon = "📂",
	Expanded = false,
	Callback = function(expanded)
		print("Basic Accordion:", expanded and "📂 Expanded" or "📁 Collapsed")
	end
})

-- Add content to basic accordion
basicAccordion:AddLabel("This is content inside the accordion!")
basicAccordion:AddLabel("You can add multiple items here.")
basicAccordion:AddButton("Action Button", function()
	print("Button clicked inside basic accordion!")
end)
basicAccordion:AddSeparator()
basicAccordion:AddLabel("Content after separator")
basicAccordion:AddSelectBox({
    Options = {"Option 1", "Option 2", "Option 3"},
    Placeholder = "Select option...",
    MultiSelect = false,
    Callback = function(selected, clicked) end
})

-- Settings Accordion (expanded by default)
local settingsAccordion = accordionTab:AddAccordion({
	Title = "Application Settings",
	Icon = "⚙️",
	Expanded = true,
	Callback = function(expanded)
		print("Settings Accordion:", expanded and "⚙️ Expanded" or "🔧 Collapsed")
	end
})

-- Add settings content
settingsAccordion:AddLabel("🎨 Theme Settings")
settingsAccordion:AddButton("Dark Theme", function()
	print("Dark theme applied!")
end)
settingsAccordion:AddButton("Light Theme", function()
	print("Light theme applied!")
end)
settingsAccordion:AddSeparator()
settingsAccordion:AddLabel("🔊 Audio Settings")
settingsAccordion:AddButton("Enable Sound", function()
	print("Sound enabled!")
end)
settingsAccordion:AddButton("Disable Sound", function()
	print("Sound disabled!")
end)

-- File Operations Accordion
local fileAccordion = accordionTab:AddAccordion({
	Title = "File Operations",
	Icon = "💾",
	Expanded = false,
	Callback = function(expanded)
		print("File Operations:", expanded and "💾 Expanded" or "📁 Collapsed")
	end
})

-- Add file operation content
fileAccordion:AddLabel("📁 File Management")
fileAccordion:AddButton("Create New File", function()
	print("Creating new file...")
end)
fileAccordion:AddButton("Open File", function()
	print("Opening file...")
end)
fileAccordion:AddButton("Save File", function()
	print("Saving file...")
end)
fileAccordion:AddSeparator()
fileAccordion:AddLabel("🗂️ Recent Files")
fileAccordion:AddButton("document.txt", function()
	print("Opening document.txt")
end)
fileAccordion:AddButton("script.lua", function()
	print("Opening script.lua")
end)

-- User Profile Accordion
local profileAccordion = accordionTab:AddAccordion({
	Title = "User Profile",
	Icon = "👤",
	Expanded = false,
	Callback = function(expanded)
		print("Profile Accordion:", expanded and "👤 Expanded" or "👥 Collapsed")
	end
})

-- Add profile content
profileAccordion:AddLabel("👋 Welcome, User!")
profileAccordion:AddLabel("Level: 25 | XP: 1,250/2,000")
profileAccordion:AddButton("View Profile", function()
	print("Opening profile page...")
end)
profileAccordion:AddButton("Edit Profile", function()
	print("Opening profile editor...")
end)
profileAccordion:AddSeparator()
profileAccordion:AddLabel("🏆 Achievements")
profileAccordion:AddButton("View Achievements", function()
	print("Showing achievements...")
end)

-- Advanced Accordion with Many Items
local advancedAccordion = accordionTab:AddAccordion({
	Title = "Advanced Features",
	Icon = "🚀",
	Expanded = false,
	Callback = function(expanded)
		print("Advanced Accordion:", expanded and "🚀 Expanded" or "🛸 Collapsed")
	end
})

-- Add many items to test scrolling
advancedAccordion:AddLabel("🔬 Experimental Features")
for i = 1, 10 do
	advancedAccordion:AddButton("Feature " .. i, function()
		print("Feature " .. i .. " activated!")
	end)
end
advancedAccordion:AddSeparator()
advancedAccordion:AddLabel("📊 Analytics")
advancedAccordion:AddButton("View Statistics", function()
	print("Showing statistics...")
end)
advancedAccordion:AddButton("Export Data", function()
	print("Exporting data...")
end)
advancedAccordion:AddLabel("More content to test scrolling...")
advancedAccordion:AddLabel("This accordion should scroll!")

accordionTab:AddLabel("")
accordionTab:AddLabel("Accordion Control Buttons:")

-- Control buttons for demonstration
accordionTab:AddButton("Expand All Accordions", function()
	basicAccordion.Expand()
	wait(0.1)
	settingsAccordion.Expand()
	wait(0.1)
	fileAccordion.Expand()
	wait(0.1)
	profileAccordion.Expand()
	wait(0.1)
	advancedAccordion.Expand()
	print("🔄 All accordions expanded!")
end)

accordionTab:AddButton("Collapse All Accordions", function()
	basicAccordion.Collapse()
	wait(0.1)
	settingsAccordion.Collapse()
	wait(0.1)
	fileAccordion.Collapse()
	wait(0.1)
	profileAccordion.Collapse()
	wait(0.1)
	advancedAccordion.Collapse()
	print("📁 All accordions collapsed!")
end)

accordionTab:AddButton("Toggle Basic Accordion", function()
	local expanded = basicAccordion.Toggle()
	print("Basic accordion toggled:", expanded and "📂 Expanded" or "📁 Collapsed")
end)

accordionTab:AddButton("Check Accordion States", function()
	print("=== ACCORDION STATES ===")
	print("Basic:", basicAccordion.IsExpanded() and "📂 Expanded" or "📁 Collapsed")
	print("Settings:", settingsAccordion.IsExpanded() and "⚙️ Expanded" or "🔧 Collapsed")
	print("File Ops:", fileAccordion.IsExpanded() and "💾 Expanded" or "📁 Collapsed")
	print("Profile:", profileAccordion.IsExpanded() and "👤 Expanded" or "👥 Collapsed")
	print("Advanced:", advancedAccordion.IsExpanded() and "🚀 Expanded" or "🛸 Collapsed")
	print("========================")
end)

accordionTab:AddButton("Change Accordion Titles", function()
	basicAccordion.SetTitle("Updated Basic Title")
	settingsAccordion.SetTitle("New Settings Title")
	fileAccordion.SetTitle("Modified File Ops")
	print("📝 Accordion titles updated!")
end)

accordionTab:AddButton("Change Accordion Icons", function()
	basicAccordion.SetIcon("🎁")
	settingsAccordion.SetIcon("🎮")
	fileAccordion.SetIcon("🎯")
	profileAccordion.SetIcon("🎨")
	advancedAccordion.SetIcon("🎪")
	print("🎨 Accordion icons updated!")
end)

accordionTab:AddLabel("")
accordionTab:AddLabel("💡 Tips:")
accordionTab:AddLabel("• Click accordion headers to expand/collapse")
accordionTab:AddLabel("• Accordions can contain buttons, labels, and separators")
accordionTab:AddLabel("• Content area is scrollable for many items")
accordionTab:AddLabel("• Smooth animations for better UX")