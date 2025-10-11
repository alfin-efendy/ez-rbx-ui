--[[
	EzUI Color Palette Module
	Dark Mode Color Scheme for Roblox GUI
	
	Author: EzUI Library
	Version: 1.0.0
	
	Usage:
		local m = require(path.to.color)
		myFrame.BackgroundColor3 = Colors.Background.Primary
		myButton.BackgroundColor3 = Colors.Button.Default
]]

local Colors = {}

-- ============================================
-- BACKGROUND COLORS
-- ============================================
Colors.Background = {
	Primary = Color3.fromRGB(30, 30, 35),      -- Main background
	Secondary = Color3.fromRGB(40, 40, 45),    -- Secondary panels
	Tertiary = Color3.fromRGB(50, 50, 55),     -- Elevated elements
	Overlay = Color3.fromRGB(20, 20, 25),      -- Modal overlays
	Transparent = Color3.fromRGB(0, 0, 0),     -- For transparent elements
}

-- ============================================
-- SURFACE COLORS (Components)
-- ============================================
Colors.Surface = {
	Default = Color3.fromRGB(45, 45, 50),      -- Default surface
	Elevated = Color3.fromRGB(55, 55, 60),     -- Elevated surface
	Hover = Color3.fromRGB(60, 60, 65),        -- Hover state
	Active = Color3.fromRGB(65, 65, 70),       -- Active/Pressed state
	Disabled = Color3.fromRGB(35, 35, 40),     -- Disabled state
}

-- ============================================
-- TEXT COLORS
-- ============================================
Colors.Text = {
	Primary = Color3.fromRGB(255, 255, 255),   -- Primary text (high contrast)
	Secondary = Color3.fromRGB(200, 200, 205), -- Secondary text (medium contrast)
	Tertiary = Color3.fromRGB(150, 150, 155),  -- Tertiary text (low contrast)
	Disabled = Color3.fromRGB(100, 100, 105),  -- Disabled text
	Placeholder = Color3.fromRGB(120, 120, 125), -- Placeholder text
	Link = Color3.fromRGB(100, 150, 255),      -- Link text
	LinkHover = Color3.fromRGB(120, 170, 255), -- Link hover
}

-- ============================================
-- BORDER COLORS
-- ============================================
Colors.Border = {
	Default = Color3.fromRGB(80, 80, 85),      -- Default border
	Light = Color3.fromRGB(100, 100, 105),     -- Light border
	Dark = Color3.fromRGB(60, 60, 65),         -- Dark border
	Focus = Color3.fromRGB(100, 150, 255),     -- Focused border
	Error = Color3.fromRGB(255, 100, 100),     -- Error border
	Success = Color3.fromRGB(100, 255, 150),   -- Success border
}

-- ============================================
-- BUTTON COLORS
-- ============================================
Colors.Button = {
	-- Primary Button
	Primary = Color3.fromRGB(100, 150, 255),
	PrimaryHover = Color3.fromRGB(120, 170, 255),
	PrimaryActive = Color3.fromRGB(80, 130, 235),
	PrimaryDisabled = Color3.fromRGB(60, 90, 150),
	
	-- Secondary Button
	Secondary = Color3.fromRGB(80, 80, 90),
	SecondaryHover = Color3.fromRGB(100, 100, 110),
	SecondaryActive = Color3.fromRGB(70, 70, 80),
	SecondaryDisabled = Color3.fromRGB(50, 50, 60),
	
	-- Success Button
	Success = Color3.fromRGB(76, 175, 80),
	SuccessHover = Color3.fromRGB(96, 195, 100),
	SuccessActive = Color3.fromRGB(56, 155, 60),
	SuccessDisabled = Color3.fromRGB(46, 115, 50),
	
	-- Danger Button
	Danger = Color3.fromRGB(244, 67, 54),
	DangerHover = Color3.fromRGB(255, 87, 74),
	DangerActive = Color3.fromRGB(224, 47, 34),
	DangerDisabled = Color3.fromRGB(150, 40, 35),
	
	-- Warning Button
	Warning = Color3.fromRGB(255, 193, 7),
	WarningHover = Color3.fromRGB(255, 213, 27),
	WarningActive = Color3.fromRGB(235, 173, 0),
	WarningDisabled = Color3.fromRGB(150, 120, 10),
}

-- ============================================
-- INPUT COLORS (TextBox, SelectBox, etc)
-- ============================================
Colors.Input = {
	Background = Color3.fromRGB(60, 60, 65),
	BackgroundHover = Color3.fromRGB(70, 70, 75),
	BackgroundFocus = Color3.fromRGB(65, 65, 70),
	BackgroundDisabled = Color3.fromRGB(45, 45, 50),
	Border = Color3.fromRGB(100, 100, 105),
	BorderFocus = Color3.fromRGB(100, 150, 255),
	BorderError = Color3.fromRGB(255, 100, 100),
	Text = Color3.fromRGB(255, 255, 255),
	Placeholder = Color3.fromRGB(150, 150, 155),
}

-- ============================================
-- TOGGLE/SWITCH COLORS
-- ============================================
Colors.Toggle = {
	On = Color3.fromRGB(76, 175, 80),
	Off = Color3.fromRGB(100, 100, 100),
	Handle = Color3.fromRGB(255, 255, 255),
	Disabled = Color3.fromRGB(70, 70, 75),
}

-- ============================================
-- SLIDER COLORS
-- ============================================
Colors.Slider = {
	Track = Color3.fromRGB(80, 80, 85),
	TrackFilled = Color3.fromRGB(100, 150, 255),
	Handle = Color3.fromRGB(255, 255, 255),
	HandleHover = Color3.fromRGB(245, 245, 245),
	HandleActive = Color3.fromRGB(230, 230, 230),
	HandleDisabled = Color3.fromRGB(150, 150, 155),
}

-- ============================================
-- DROPDOWN COLORS
-- ============================================
Colors.Dropdown = {
	Background = Color3.fromRGB(45, 45, 50),
	Option = Color3.fromRGB(50, 50, 55),
	OptionHover = Color3.fromRGB(70, 70, 75),
	OptionSelected = Color3.fromRGB(70, 120, 70),
	OptionActive = Color3.fromRGB(100, 150, 255),
	Border = Color3.fromRGB(150, 150, 155),
	Arrow = Color3.fromRGB(200, 200, 205),
}

-- ============================================
-- SCROLLBAR COLORS
-- ============================================
Colors.Scrollbar = {
	Background = Color3.fromRGB(40, 40, 45),
	Thumb = Color3.fromRGB(120, 120, 125),
	ThumbHover = Color3.fromRGB(140, 140, 145),
	ThumbActive = Color3.fromRGB(160, 160, 165),
}

-- ============================================
-- STATUS COLORS (Semantic m)
-- ============================================
Colors.Status = {
	Success = Color3.fromRGB(76, 175, 80),
	Warning = Color3.fromRGB(255, 193, 7),
	Error = Color3.fromRGB(244, 67, 54),
	Info = Color3.fromRGB(33, 150, 243),
}

-- ============================================
-- ACCENT COLORS
-- ============================================
Colors.Accent = {
	Primary = Color3.fromRGB(100, 150, 255),   -- Blue
	Secondary = Color3.fromRGB(156, 39, 176),  -- Purple
	Success = Color3.fromRGB(76, 175, 80),     -- Green
	Warning = Color3.fromRGB(255, 193, 7),     -- Yellow
	Danger = Color3.fromRGB(244, 67, 54),      -- Red
	Info = Color3.fromRGB(33, 150, 243),       -- Light Blue
}

-- ============================================
-- SPECIAL COLORS
-- ============================================
Colors.Special = {
	Shadow = Color3.fromRGB(0, 0, 0),          -- For shadows
	Highlight = Color3.fromRGB(255, 255, 255), -- For highlights
	Overlay = Color3.fromRGB(0, 0, 0),         -- For modal overlays (use with transparency)
	Divider = Color3.fromRGB(80, 80, 85),      -- For separators/dividers
}

-- ============================================
-- TAB COLORS
-- ============================================
Colors.Tab = {
	Background = Color3.fromRGB(50, 50, 50),
	BackgroundHover = Color3.fromRGB(60, 60, 60),
	BackgroundActive = Color3.fromRGB(70, 70, 75),
	Text = Color3.fromRGB(255, 255, 255),
	TextInactive = Color3.fromRGB(180, 180, 185),
	Indicator = Color3.fromRGB(100, 150, 255),
}

-- ============================================
-- NOTIFICATION COLORS
-- ============================================
Colors.Notification = {
	Success = {
		Background = Color3.fromRGB(46, 125, 50),
		Text = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(76, 175, 80),
	},
	Warning = {
		Background = Color3.fromRGB(245, 127, 23),
		Text = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(255, 193, 7),
	},
	Error = {
		Background = Color3.fromRGB(211, 47, 47),
		Text = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(244, 67, 54),
	},
	Info = {
		Background = Color3.fromRGB(25, 118, 210),
		Text = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(33, 150, 243),
	},
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Convert Color3 to hex string
function Colors:ToHex(color3)
	local r = math.floor(color3.R * 255)
	local g = math.floor(color3.G * 255)
	local b = math.floor(color3.B * 255)
	return string.format("#%02X%02X%02X", r, g, b)
end

-- Convert hex string to Color3
function Colors:FromHex(hex)
	hex = hex:gsub("#", "")
	local r = tonumber("0x" .. hex:sub(1, 2)) / 255
	local g = tonumber("0x" .. hex:sub(3, 4)) / 255
	local b = tonumber("0x" .. hex:sub(5, 6)) / 255
	return Color3.new(r, g, b)
end

-- Lighten a color by a percentage (0-1)
function Colors:Lighten(color3, amount)
	amount = math.clamp(amount, 0, 1)
	local h, s, v = color3:ToHSV()
	v = math.clamp(v + amount, 0, 1)
	return Color3.fromHSV(h, s, v)
end

-- Darken a color by a percentage (0-1)
function Colors:Darken(color3, amount)
	amount = math.clamp(amount, 0, 1)
	local h, s, v = color3:ToHSV()
	v = math.clamp(v - amount, 0, 1)
	return Color3.fromHSV(h, s, v)
end

-- Adjust saturation of a color
function Colors:Saturate(color3, amount)
	amount = math.clamp(amount, -1, 1)
	local h, s, v = color3:ToHSV()
	s = math.clamp(s + amount, 0, 1)
	return Color3.fromHSV(h, s, v)
end

-- Mix two colors with a ratio (0 = color1, 1 = color2)
function Colors:Mix(color1, color2, ratio)
	ratio = math.clamp(ratio, 0, 1)
	return Color3.new(
		color1.R + (color2.R - color1.R) * ratio,
		color1.G + (color2.G - color1.G) * ratio,
		color1.B + (color2.B - color1.B) * ratio
	)
end

-- Get contrasting text color (black or white) based on background
function Colors:GetContrastText(backgroundColor)
	local luminance = (0.299 * backgroundColor.R + 0.587 * backgroundColor.G + 0.114 * backgroundColor.B)
	return luminance > 0.5 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
end

-- Apply alpha/transparency to a color (returns color and transparency value)
function Colors:WithAlpha(color3, alpha)
	alpha = math.clamp(alpha, 0, 1)
	return color3, 1 - alpha
end

-- Create a gradient of colors
function Colors:CreateGradient(startColor, endColor, steps)
	local gradient = {}
	for i = 0, steps - 1 do
		local ratio = i / (steps - 1)
		table.insert(gradient, Colors.Mix(startColor, endColor, ratio))
	end
	return gradient
end

-- ============================================
-- PRESET THEMES
-- ============================================
Colors.Themes = {
	-- Default Dark Theme (already defined above)
	Dark = {
		Name = "Dark",
		Primary = Color3.fromRGB(100, 150, 255),
		Background = Color3.fromRGB(30, 30, 35),
		Surface = Color3.fromRGB(45, 45, 50),
		Text = Color3.fromRGB(255, 255, 255),
	},
	
	-- Darker Theme
	Darker = {
		Name = "Darker",
		Primary = Color3.fromRGB(100, 150, 255),
		Background = Color3.fromRGB(15, 15, 20),
		Surface = Color3.fromRGB(25, 25, 30),
		Text = Color3.fromRGB(255, 255, 255),
	},
	
	-- Blue Dark Theme
	BlueDark = {
		Name = "Blue Dark",
		Primary = Color3.fromRGB(33, 150, 243),
		Background = Color3.fromRGB(18, 32, 47),
		Surface = Color3.fromRGB(28, 42, 57),
		Text = Color3.fromRGB(255, 255, 255),
	},
	
	-- Purple Dark Theme
	PurpleDark = {
		Name = "Purple Dark",
		Primary = Color3.fromRGB(156, 39, 176),
		Background = Color3.fromRGB(30, 20, 35),
		Surface = Color3.fromRGB(45, 30, 50),
		Text = Color3.fromRGB(255, 255, 255),
	},
	
	-- Green Dark Theme
	GreenDark = {
		Name = "Green Dark",
		Primary = Color3.fromRGB(76, 175, 80),
		Background = Color3.fromRGB(20, 30, 20),
		Surface = Color3.fromRGB(30, 45, 30),
		Text = Color3.fromRGB(255, 255, 255),
	},
}

-- ============================================
-- RETURN MODULE
-- ============================================
return Colors
