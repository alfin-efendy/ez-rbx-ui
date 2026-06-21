--[[
  EzUI — usage playground.

  Build + serve:  make run    (bundles this against ../output/bundle and serves on :8081)
  In Roblox:      load the released ez-rbx-ui.lua via loadstring + HttpGet, then EzUI:CreateWindow{...}
]]
local EzUI = require("../output/bundle")

local window = EzUI:CreateWindow({
  Title = "EzUI Demo",
  Size = { Width = 560, Height = 420 },
  Acrylic = true,
  ToggleKey = Enum.KeyCode.RightControl,
  FloatingToggle = true,
  Config = { Enabled = true, FileName = "EzUIDemo", AutoSave = true, AutoLoad = true },
  OnClose = function() print("EzUI closed — settings saved.") end,
})

-- ── Home ──────────────────────────────────────────────────────────────────
local main = window:AddTabGroup("Main")
local home = main:AddTab({ Name = "Home", Icon = "home" })

home:AddSection("General")
home:AddParagraph("Toggles, sliders and inputs. Values with a Flag auto-save and restore.")
home:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false, Tooltip = "Farm resources automatically",
  Callback = function(on) print("Auto Farm:", on) end })
home:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 16, Flag = "walkspeed" })
home:AddNumberBox({ Text = "Volume", Min = 0, Max = 100, Default = 50, Flag = "volume" })
home:AddSelectBox({ Text = "Mode", Options = { "Legit", "Rage", "Custom" }, Default = "Legit", Flag = "mode" })
home:AddKeybind({ Text = "Panic Key", Default = Enum.KeyCode.P, Flag = "panic",
  Callback = function() window:ShowWarning({ Title = "Panic", Message = "Panic key pressed." }) end })

home:AddSection("Actions")
home:AddButton({ Text = "Execute", Variant = "default", Icon = "play", Callback = function()
  window:ShowSuccess({ Title = "Executed", Message = "Script ran." })
end })
home:AddButton({ Text = "Open Dialog", Variant = "secondary", Callback = function()
  window:Dialog({ Title = "Confirm", Message = "Run the risky action?", Buttons = {
    { Text = "Cancel", Variant = "secondary" },
    { Text = "Run", Variant = "destructive", Callback = function() window:ShowInfo({ Title = "Running…" }) end },
  } })
end })
home:AddSeparator()
home:AddButton({ Text = "Reset to Defaults", Variant = "destructive", Action = "ResetConfig" })

-- ── Visuals ───────────────────────────────────────────────────────────────
local visuals = main:AddTab({ Name = "Visuals", Icon = "eye" })
visuals:AddSection("ESP")
visuals:AddToggle({ Text = "Enable ESP", Flag = "esp", Default = false })
visuals:AddColorPicker({ Text = "Box Color", Default = Color3.fromRGB(255, 80, 80), Flag = "espcolor" })
visuals:AddSlider({ Text = "Thickness", Min = 1, Max = 10, Default = 2, Flag = "espthickness" })
local prog = visuals:AddProgressBar({ Default = 0.3 })
visuals:AddButton({ Text = "Fill", Variant = "outline", Callback = function() prog.Set(1) end })

local adv = visuals:AddAccordion({ Title = "Advanced", Icon = "settings-2", Expanded = false })
adv:AddToggle({ Text = "Chams", Default = false })
adv:AddSelectBox({ Text = "Targets", Options = { "Players", "NPCs", "Both" }, Multi = true, Default = { "Players" } })

-- ── Players ───────────────────────────────────────────────────────────────
local tools = window:AddTabGroup("Tools")
local players = tools:AddTab({ Name = "Players", Icon = "users" })
players:AddSection("Target")
players:AddPlayerSelector({ Text = "Player", Flag = "target" })
players:AddTextBox({ Text = "Note", Placeholder = "Reason…", Default = "", Flag = "note" })
players:AddTextBox({ Text = "Your Key", Default = "EZUI-DEMO-KEY", Copyable = true })
players:AddTable({ Columns = { "Player", "Kills", "Deaths" }, Rows = {
  { "Alpha", "12", "3" }, { "Bravo", "8", "5" }, { "Charlie", "20", "1" },
} })

-- ── Credits ───────────────────────────────────────────────────────────────
local credits = tools:AddTab({ Name = "Credits", Icon = "heart" })
credits:AddImage({ Lucide = "gamepad-2", Height = 64 })
credits:AddParagraph("EzUI — a modern Roblox UI library. shadcn-inspired, Fluent acrylic, Lucide icons.")
credits:AddButton({ Text = "Notify Me", Variant = "ghost", Callback = function()
  window:Notify({ Title = "Hello", Message = "Thanks for using EzUI!", Type = "info" })
end })
credits:AddButton({ Text = "Notify with Action", Variant = "ghost", Callback = function()
  window:Notify({ Title = "Item deleted", Message = "Removed from inventory.", Type = "warning",
    Action = { Text = "Undo", Callback = function() window:ShowSuccess({ Title = "Restored" }) end } })
end })

window:ShowInfo({ Title = "Welcome", Message = "EzUI demo loaded. Press RightControl to toggle.", Duration = 5000 })
