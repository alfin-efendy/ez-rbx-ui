# EzUI - Easy Roblox UI Library

A modern, modular, and feature-rich UI library for Roblox game development. Build beautiful, dark-themed interfaces with ease.

## ✨ Features

- 🎨 **Dark Mode Design** - Professional dark theme with customizable colors
- 🧩 **Modular Architecture** - All components in separate files for easy maintenance
- 💾 **Configuration System** - Auto-save/load with JSON file persistence
- 🎯 **Flag-Based State** - Automatic component synchronization
- 📱 **Responsive Design** - Adapts to different screen resolutions
- 🖱️ **Drag & Resize** - Movable and resizable windows
- 🔄 **Dynamic Content** - Support for function-based dynamic text
- ⚡ **Smooth Animations** - TweenService-powered transitions
- 🔔 **Toast Notifications** - Sonner-style notifications with stacking and animations
- 🎭 **Multiple Types** - Info, Success, Warning, Error notification types
- 📦 **12 Components** - Complete set of UI elements
- 🛠️ **2 Utility Modules** - Color palette and configuration management
- 🔔 **Toast Notifications** - Sonner-style notification system with stacking

---

## 📦 Components

### Core Components
- **Label** - Text display with dynamic function support
- **Button** - Clickable buttons with hover effects
- **Toggle** - On/off switches with animations
- **TextBox** - Text input with character counter
- **NumberBox** - Numeric input with increment/decrement
- **SelectBox** - Dropdown selection with search
- **Separator** - Visual dividers
- **Popup** - Modal dialogs and non-modal windows
- **Notification** - Toast notifications with stacking, animations, and different types (Sonner-style)

### Container Components
- **Window** - Main draggable window container
- **Tab** - Tab system with icons
- **Accordion** - Collapsible expandable sections

---

## 🛠️ Utilities

- **colors.lua** - Complete dark mode color palette with utility functions (all components use this)
- **config.lua** - Configuration management with save/load and flag system

---

## 📚 Documentation

- **[Components Guide](components/README.md)** - Detailed component documentation
- **[Color Palette Usage](COLOR_PALETTE_USAGE.md)** - Color system and theming guide
- **[Configuration Guide](CONFIGURATION_GUIDE.md)** - Configuration system documentation
- **[Custom Directory Guide](CUSTOM_DIRECTORY_GUIDE.md)** - Custom folder configuration
- **[Architecture](ARCHITECTURE.md)** - Visual architecture diagrams
- **[Modular Refactor](MODULAR_REFACTOR.md)** - Refactoring details
- **[Components Index](COMPONENTS_INDEX.md)** - Quick reference
- **[Window Config Guide](WINDOW_CONFIG_GUIDE.md)** - Window configuration options
- **[SelectBox Values Guide](SELECTBOX_VALUES_GUIDE.md)** - SelectBox usage guide
- **[Popup Component Guide](POPUP_COMPONENT_GUIDE.md)** - Popup/dialog component guide

---

## 🚀 Quick Start

### Installation

**Method 1: ModuleScript in Roblox Studio**
```lua
-- Place the library in ReplicatedStorage
local EzUI = require(game.ReplicatedStorage.main)
```

**Method 2: Loadstring (for executor)**
```lua
local EzUI = loadstring(game:HttpGet('https://github.com/alfin-efendy/ez-rbx-ui/releases/latest/download/ez-rbx-ui.lua'))()
```

### Basic Usage

```lua
-- Create a window
local window = EzUI.CreateWindow({
	Name = "My UI",
	Size = {
		Width = 500,
		Height = 400
	},
	Opacity = 1.0,
	AutoShow = true,
	ConfigurationSaving = {
		Enabled = true,
		FileName = "MyConfig",
		AutoSave = true,
		AutoLoad = true
	}
})

-- Add a tab
local tab = window:AddTab({
	Name = "Home",
	Icon = "🏠"
})

-- Add components
tab:AddLabel("Welcome to EzUI!")

tab:AddButton("Click Me", function()
	print("Button clicked!")
end)

tab:AddToggle({
	Text = "Enable Feature",
	Flag = "FeatureEnabled",
	Default = false,
	Callback = function(value)
		print("Feature:", value)
	end
})

tab:AddTextBox({
	Text = "Username",
	Flag = "Username",
	Default = "Player",
	MaxLength = 20
})

tab:AddNumberBox({
	Text = "Volume",
	Flag = "Volume",
	Default = 50,
	Min = 0,
	Max = 100
})

-- Show notifications
window:ShowNotification({
	Title = "Welcome!",
	Message = "EzUI is ready to use",
	Type = "success",
	Duration = 3000
})

window:ShowError({
	Title = "Error",
	Message = "Something went wrong"
})
```

---

## ⚙️ Configuration System

### Window Configuration

```lua
local window = EzUI.CreateWindow({
	Name = "Settings",
	ConfigurationSaving = {
		Enabled = true,
		FileName = "AppSettings",
		FolderName = "MyApp",
		AutoSave = true,
		AutoLoad = true
	}
})

-- Components with flags auto-save
tab:AddToggle({
	Text = "Dark Mode",
	Flag = "DarkMode",
	Default = true
})

-- Manual save/load
window:SaveConfiguration()
window:LoadConfiguration()
```

### Custom Configuration

```lua
-- Create independent config (default directory)
local config = EzUI.NewConfig("PlayerData")

-- Create config with custom directory
local customConfig = EzUI.NewConfig("PlayerData", "MyGame/SaveData")

-- Set values
config.SetValue("Level", 45)
config.SetValue("Coins", 1000)
config.SetValue("Username", "Player123")

-- Get values
local level = config.GetValue("Level")
local coins = config.GetValue("Coins")

-- Get all
local all = config.GetAll()
for key, value in pairs(all) do
	print(key, "=", value)
end

-- Get configuration info
local info = config.GetInfo()
print("Saved to:", info.FilePath)
print("Using custom directory:", info.IsCustomDirectory)
```

**Read more:** [Custom Directory Guide](CUSTOM_DIRECTORY_GUIDE.md)

---

## 🎨 Color System

```lua
local Colors = require(game.ReplicatedStorage.utils.color)

-- Use predefined colors
frame.BackgroundColor3 = Colors.Background.Primary
label.TextColor3 = Colors.Text.Primary

-- Color utilities
local lighter = Colors.Lighten(color, 0.2)
local darker = Colors.Darken(color, 0.3)
local mixed = Colors.Mix(color1, color2, 0.5)

-- Themes
local theme = Colors.Themes.Dark
frame.BackgroundColor3 = theme.Background
label.TextColor3 = theme.Text
```

---

## 📁 Project Structure

```
ez-rbx-ui/
├── ui.lua                      # Main library entry point
├── components/                 # Modular components
│   ├── label.lua
│   ├── button.lua
│   ├── toggle.lua
│   ├── textbox.lua
│   ├── numberbox.lua
│   ├── selectbox.lua
│   ├── separator.lua
│   ├── notification.lua        # Toast notifications (Sonner-style)
│   ├── window.lua
│   ├── tab.lua
│   ├── accordion.lua
│   └── README.md
├── utils/                      # Utility modules
│   ├── color.lua              # Color palette
│   └── config.lua             # Configuration system
├── example/                    # Usage examples
│   ├── components_usage.lua
│   └── config_usage.lua
└── docs/                       # Documentation
    ├── CONFIGURATION_GUIDE.md
    ├── ARCHITECTURE.md
    ├── MODULAR_REFACTOR.md
    └── COMPONENTS_INDEX.md
```

---

## 🔧 Advanced Features

### Dynamic Text

```lua
local label = tab:AddLabel(function()
	return "Time: " .. os.date("%H:%M:%S")
end)

-- Auto-updates every second
label.StartAutoUpdate()

-- Stop updates
label.StopAutoUpdate()

-- Manual update
label.Update()
```

### Component Control

```lua
-- Toggle
local toggle = tab:AddToggle({Text = "Feature", Flag = "MyFeature"})
toggle.SetValue(true)
local isEnabled = toggle.GetValue()

-- TextBox
local textbox = tab:AddTextBox({Text = "Name", Flag = "Name"})
textbox.SetText("New Name")
local text = textbox.GetText()
textbox.Focus()
textbox.Clear()

-- NumberBox
local numberbox = tab:AddNumberBox({Text = "Value", Flag = "Value"})
numberbox.SetValue(50)
numberbox.SetMin(0)
numberbox.SetMax(100)
local value = numberbox.GetValue()
```

### Window Control

```lua
-- Visibility
window:Show()
window:Hide()
local visible = window:IsVisible()
window:ToggleVisibility()

-- Opacity
window:SetOpacity(0.8)
local opacity = window:GetOpacity()
window:FadeIn(0.5)
window:FadeOut(0.5)

-- Sizing
window:SetSize(800, 600)
window:AdaptToViewport()
local size = window:GetDynamicSize()

-- Close
window:SetCloseCallback(function()
	print("Window closing!")
end)
window:Close()
```

### Notification System

```lua
-- Basic notifications
window:ShowNotification({
	Title = "Information",
	Message = "This is an info notification",
	Type = "info",
	Duration = 4000  -- 4 seconds
})

-- Different notification types
window:ShowSuccess({
	Title = "Success!",
	Message = "Operation completed successfully"
})

window:ShowWarning({
	Title = "Warning",
	Message = "Please check your input"
})

window:ShowError({
	Title = "Error",
	Message = "Something went wrong"
})

-- Advanced notifications with actions
window:ShowNotification({
	Title = "Update Available",
	Message = "A new version is available",
	Type = "info",
	Duration = 0,  -- Persistent notification
	Action = {
		label = "Update",
		callback = function()
			print("Starting update...")
		end
	},
	OnDismiss = function()
		print("Notification dismissed")
	end
})

-- Manual notification control
local id = window:ShowNotification({...})
window:DismissNotification(id)
window:ClearAllNotifications()
```

---

## 🎯 Use Cases

- **Game Settings Menus** - Volume, graphics, keybinds
- **Admin Panels** - Player management, moderation tools
- **Debug Interfaces** - Development tools, stats display
- **Trading Systems** - Item selection, quantity input
- **Inventory UIs** - Item management with search
- **Configuration Editors** - Save/load user preferences
- **Achievement Trackers** - Progress displays
- **Quest Systems** - Dynamic quest information
- **Notification Systems** - Toast messages, alerts, confirmations
- **Status Updates** - Real-time feedback, progress indicators

---

## 🔐 Requirements

- Roblox Executor with file system support:
  - `writefile(path, content)`
  - `readfile(path)`
  - `isfile(path)`
  - `isfolder(path)`
  - `makefolder(path)`

**Note:** Configuration save/load requires these functions. UI works without them, but settings won't persist.

---

## 📝 Examples

Check the `example/` folder for complete usage examples:
- `components_usage.lua` - All component examples
- `config_usage.lua` - Configuration system examples

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation

---

## 📄 License

See [LICENSE](LICENSE) file for details.

---

## 🌟 Credits

Created by **alfin-efendy**

---

## 📊 Status

✅ **Production Ready**
- 12 Components Complete
- 2 Utility Modules
- Full Documentation
- Comprehensive Examples
- Modular Architecture
- Configuration System
- Toast Notification System

---

**Version:** 1.0  
**Branch:** refactor/modular-ui  
**Last Updated:** October 2025