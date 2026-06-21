-- Faithful bundle smoke: run output/bundle.lua the way Roblox would.
-- Roblox's global require() takes a ModuleScript Instance, not a string, so we
-- install a require that THROWS on strings. If the bundle leaked any native
-- module require (the bundler only rewrites the entry file), this fails loudly
-- instead of silently resolving files off disk like PUC Lua's require does.
-- Run: lua scripts/verify_bundle.lua   (after `make build`)

local mockmod = require("tests.mock_roblox")
local env, mock = {}, {}
mockmod.installInto(env, mock)
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
local w = EzUI:CreateWindow({ Title = "Verify", Parent = screen })
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
t:AddSelectBox({ Text = "S", Options = { "a", "b" }, Default = "a" })
t:AddSlider({ Text = "Sl", Min = 0, Max = 10, Default = 5 })
t:AddKeybind({ Text = "K", Default = _G.Enum.KeyCode.E })
t:AddColorPicker({ Text = "C", Default = _G.Color3.fromRGB(255, 80, 80) })
t:AddProgressBar({ Default = 0.5 })
t:AddImage({ Lucide = "home" })
t:AddTable({ Columns = { "A", "B" }, Rows = { { "1", "2" } } })
t:AddPlayerSelector({ Text = "P" })

local acc = t:AddAccordion({ Title = "Adv" })
acc:Toggle()
assert(acc:IsExpanded(), "accordion did not expand")
acc:AddColorPicker({ Text = "C2", Default = _G.Color3.fromRGB(10, 20, 30) })

print("VERIFY-BUNDLE OK: faithful require+Color3; all controls construct; window/tab/accordion work")
