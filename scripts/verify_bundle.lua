-- Faithful bundle smoke: run output/bundle.lua the way Roblox would.
-- Roblox's global require() takes a ModuleScript Instance, not a string, so we
-- install a require that THROWS on strings. If the bundle leaked any native
-- module require (the bundler only rewrites the entry file), this fails loudly
-- instead of silently resolving files off disk like PUC Lua's require does.
-- Run: lua scripts/verify_bundle.lua   (after `make build`)

local mockmod = require("tests.mock_roblox")
local env, mock = {}, {}
mockmod.installInto(env, mock, true) -- strict: validate cross-class property writes like Roblox
for k, v in pairs(env) do _G[k] = v end

_G.require = function(x)
  error("native require() called with a " .. type(x) ..
    " — the bundle leaked a module-to-module require (expected an Instance in Roblox)", 2)
end

-- Faithful Color3: real Roblox exposes ONLY .R/.G/.B (0-1) and THROWS on any other
-- member (e.g. the mock-only .R8). This catches production code that reads mock-only
-- Color3 fields, which the lenient test mock would silently allow.
local function faithfulColor(r, g, b)
  return setmetatable({ R = r, G = g, B = b }, {
    __index = function(_, k) error(tostring(k) .. " is not a valid member of Color3", 2) end,
  })
end
_G.Color3 = {
  fromRGB = function(r, g, b) return faithfulColor((r or 0) / 255, (g or 0) / 255, (b or 0) / 255) end,
  new = function(r, g, b) return faithfulColor(r or 0, g or 0, b or 0) end,
  fromHSV = function() return faithfulColor(0, 0, 0) end,
}

local chunk = assert(loadfile("output/bundle.lua"))
local ok, EzUI = pcall(chunk)
assert(ok, "bundle runtime error: " .. tostring(EzUI))

local screen = _G.Instance.new("ScreenGui")
local w = EzUI:CreateWindow({ Title = "Verify", Parent = screen, FloatingToggle = true,
  Config = { FileName = "Verify", AutoSave = false } })
assert(type(w.AddTab) == "function", "no AddTab")
local t = w:AddTab({ Name = "Home", Icon = "home" })
assert(t:IsSelected(), "first tab not auto-selected")

-- Construct every control under the faithful Color3 (catches mock-only member reads
-- like .R8 at build, e.g. ColorPicker's toArr).
t:AddLabel({ Text = "L" })
t:AddButton({ Text = "B" })
t:AddToggle({ Text = "T", Default = true })
t:AddTextBox({ Text = "TB", Default = "x" })
t:AddNumberBox({ Text = "N", Default = 1, Min = 0, Max = 10 })
local sb = t:AddSelectBox({ Text = "S", Options = { "alpha", "beta" }, Default = "alpha" })
sb.Open(); sb.Filter("be"); sb.Close()  -- search box + filter under strict mock
t:AddSlider({ Text = "Sl", Min = 0, Max = 10, Default = 5 })
t:AddKeybind({ Text = "K", Default = _G.Enum.KeyCode.E })
local cp = t:AddColorPicker({ Text = "C", Default = _G.Color3.fromRGB(255, 80, 80) })
cp.Open()  -- exercises the SV/Hue ImageButtons + gradients under strict validation
cp.Close()
t:AddProgressBar({ Default = 0.5 })
t:AddImage({ Lucide = "home" })
t:AddTable({ Columns = { "A", "B" }, Rows = { { "1", "2" } } })
t:AddPlayerSelector({ Text = "P" })

local acc = t:AddAccordion({ Title = "Adv" })
acc:Toggle()
assert(acc:IsExpanded(), "accordion did not expand")

-- Plan 5 surfaces: notifications, reset, tab groups, search, dialog
w:ShowSuccess({ Title = "Saved", Message = "ok", Duration = 0 })
w:Notify({ Title = "Info", Duration = 100 })
w:ResetConfiguration({ Confirm = false })
local g = w:AddTabGroup("Group")
g:AddTab({ Name = "Grouped" })
w:SearchTabs("grouped"); w:SearchTabs("")
w:Dialog({ Title = "Q", Message = "m", Buttons = { { Text = "OK" } } })

-- Round-2: switch with description, resizable, action toast, minimize→hide
t:AddToggle({ Text = "Desc", Default = true, Description = "a description line" })
local rz = t:AddResizable({ Panes = { { Default = 0.5 }, { Default = 0.5 } } })
rz.Panes[1]:AddButton({ Text = "L" }); rz.Panes[2]:AddButton({ Text = "R" })
w:Notify({ Title = "Undo me", Type = "warning", Duration = 0, Action = { Text = "Undo", Callback = function() end } })
-- R3 Plan A: square FAB with image, card accordion divider, header separator
local w2 = EzUI:CreateWindow({ Title = "FAB", Parent = screen,
  FloatingToggle = { Type = "square", Image = "rbxassetid://1", Draggable = false },
  Config = { FileName = "Verify2", AutoSave = false } })
assert(w2.Main:FindFirstChild("HeaderSeparator"), "no header separator")
w2:SetFloatingToggle({ Type = "circle", Image = "rbxassetid://2" })
local t2 = w2:AddTab({ Name = "T" })
local accCard = t2:AddAccordion({ Title = "Card" }); accCard:Expand()
assert(accCard.Container:FindFirstChild("Divider"), "no accordion divider")

-- R4 Plan A: sidebar grip, simple pill FAB with size/pos
assert(w.Main:FindFirstChild("Body"):FindFirstChild("SidebarHandle"):FindFirstChild("Grip"), "no sidebar grip")
local w3 = EzUI:CreateWindow({ Title = "Pill", Parent = screen, FloatingToggle = true,
  Config = { FileName = "Verify3", AutoSave = false } })
w3:SetFloatingToggle({ Type = "simple", Size = { Width = 140, Height = 38 }, Position = { X = 20, Y = -70 } })

w:Minimize() -- hides window + shows floating toggle
-- R3 Plan C: lock, advanced dropdown, profiles, tag, card, toast bar
local lockBtn = t:AddButton({ Text = "L", Locked = true })
assert(lockBtn.Frame:FindFirstChild("LockShield"), "no lock shield")
w:LockAll(); w:UnlockAll()
local adv = t:AddSelectBox({ Text = "Adv", AllowNone = true,
  Options = { { Value = "A", Icon = "star", Desc = "a" }, { Divider = true }, { Value = "B" } } })
adv.Open(); adv.Close()
w:UseConfigProfile("PvP"); assert(#w:ConfigProfiles() >= 1, "no profiles")
local tag = w:Tag({ Text = "Beta", Icon = "star" }); tag.SetText("RC"); tag.Destroy()
local card = t:AddCard({ Title = "C", Body = "b", Buttons = { { Text = "OK" } } })
assert(card.Frame:FindFirstChild("Title"), "no card title")
w:Notify({ Title = "timed", Type = "success", Duration = 2000 }) -- progress bar path

-- R3 Plan B: live accent + settings APIs
w:SetAccent("Indigo")
w:SetUIScale(1.1)
w:SetAcrylicTransparency(0.2)
w:SetNotificationsEnabled(false)
assert(w:Notify({ Title = "blocked", Duration = 0 }) == nil, "notify should be gated when disabled")
w:SetNotificationsEnabled(true)

-- R4 Plan B: live light/dark + accent preserved + save/load
w:SetAccent(Color3.fromRGB(120, 80, 200))
w:SetMode("light"); assert(w:GetMode() == "light", "mode not light")
assert(w.Main.BackgroundColor3.R > 0.9, "shell not light")
w:SetMode("dark")
assert(type(w:SaveConfiguration()) == "boolean", "SaveConfiguration")
assert(type(w:LoadConfiguration()) == "boolean", "LoadConfiguration")

-- R5: light-mode acrylic re-skin + reference simple FAB
w:SetMode("light")
assert(w.Main:FindFirstChildOfClass("UIGradient"), "no acrylic gradient")
w:SetMode("dark")
local w4 = EzUI:CreateWindow({ Title = "FabRef", Parent = screen, FloatingToggle = true,
  Config = { FileName = "Verify4", AutoSave = false } })
local fab4; for _, c in ipairs(w4.Overlay:GetChildren()) do if c.Name == "FloatingToggle" then fab4 = c end end
assert(fab4 and fab4:FindFirstChild("Chevron"), "no simple FAB chevron")

-- R6: light-mode table/tag re-skin + simple FAB dock
w:SetMode("light")
do
  local tg = w:Tag({ Text = "L" })
  local tb = w.Main:FindFirstChild("TitleBar"); local pill
  for _, c in ipairs(tb:GetChildren()) do if c.Name == "Tag" then pill = c end end
  assert(pill and pill.BackgroundColor3.R > 0.9, "tag not light")
  tg.Destroy()
end
w:SetMode("dark")
local w5 = EzUI:CreateWindow({ Title = "Dock", Parent = screen, FloatingToggle = true,
  Config = { FileName = "Verify5", AutoSave = false } })
local fab5; for _, c in ipairs(w5.Overlay:GetChildren()) do if c.Name == "FloatingToggle" then fab5 = c end end
assert(fab5 and fab5.Position.X.Offset == -15, "simple FAB not docked at edge")

w:SetCloseCallback(function() end)
w:Close()
w:AddTab({ Name = "after-close" }) -- must be a no-op, not error

print("VERIFY-BUNDLE OK: faithful require+Color3; controls + enhancements + graceful Close work")
