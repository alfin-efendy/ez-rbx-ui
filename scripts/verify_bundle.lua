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

local chunk = assert(loadfile("output/bundle.lua"))
local ok, EzUI = pcall(chunk)
assert(ok, "bundle runtime error: " .. tostring(EzUI))

local screen = _G.Instance.new("ScreenGui")
local w = EzUI:CreateWindow({ Title = "Verify", Parent = screen })
assert(type(w.AddTab) == "function", "no AddTab")
local t = w:AddTab({ Name = "Home", Icon = "home" })
assert(t:IsSelected(), "first tab not auto-selected")
local acc = t:AddAccordion({ Title = "Adv" })
acc:Toggle()
assert(acc:IsExpanded(), "accordion did not expand")

print("VERIFY-BUNDLE OK: no native require leaked; CreateWindow + AddTab + AddAccordion work")
