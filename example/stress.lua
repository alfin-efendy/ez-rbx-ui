-- Require the BUILT bundle (run `make build` first / `make stress` does it).
local EzUI = require("../output/bundle")

local window = EzUI:CreateWindow({
  Title = "EzUI Stress Test",
  Ratio = 16/10,
  Transparency = 0.12,
  FloatingToggle = { Type = "simple", AutoHide = true },
  Config = { FileName = "EzUIStress", AutoSave = false },
})

local function buildTab(tab, i)
  tab:AddSection("Controls")
  tab:AddParagraph("Every control type, mounted via the host mixin.")
  tab:AddToggle({ Text = "Enable " .. i, Default = (i % 2 == 0), Flag = "enable_" .. i, Tooltip = "Toggles feature " .. i })
  tab:AddSlider({ Text = "Speed", Min = 0, Max = 100, Default = 50, Flag = "speed_" .. i })
  tab:AddNumberBox({ Text = "Amount", Default = 10, Min = 0, Max = 100, Flag = "amount_" .. i })
  tab:AddSelectBox({ Text = "Mode", Options = { "Alpha", "Beta", "Gamma" }, Default = "Alpha", Flag = "mode_" .. i })
  tab:AddKeybind({ Text = "Hotkey", Default = Enum.KeyCode.E, Flag = "key_" .. i,
    Callback = (i == 1) and function() window:ShowSuccess({ Title = "Hotkey", Message = "Bound key pressed." }) end or nil })
  tab:AddColorPicker({ Text = "ESP Color", Default = Color3.fromRGB(255, 80, 80), Flag = "color_" .. i })
  tab:AddProgressBar({ Default = 0.4 })
  tab:AddTextBox({ Text = "Key", Default = "ABC-123", Copyable = true })
  tab:AddTable({ Columns = { "Player", "Score" }, Rows = { { "Alpha", "120" }, { "Beta", "98" } } })
  tab:AddButton({ Text = "Save", Variant = "default", Icon = "check", Callback = function()
    window:ShowSuccess({ Title = "Saved", Message = "Settings persisted." })
  end })
  tab:AddSeparator()
  tab:AddButton({ Text = "Reset to Defaults", Variant = "destructive", Action = "ResetConfig" })

  for j = 1, 8 do
    local acc = tab:AddAccordion({ Title = "Accordion " .. j, Icon = "settings-2", Expanded = (j == 1) })
    acc:AddToggle({ Text = "Feature " .. j, Default = false })
    acc:AddSlider({ Text = "Level", Min = 1, Max = 10, Default = 3 })
  end
end

local mainGroup = window:AddTabGroup("Main")
for i = 1, 10 do buildTab(mainGroup:AddTab({ Name = "Tab " .. i, Icon = "home" }), i) end

local extraGroup = window:AddTabGroup("Extra")
for i = 11, 20 do buildTab(extraGroup:AddTab({ Name = "Tab " .. i, Icon = "star" }), i) end

window:ShowInfo({ Title = "Welcome", Message = "EzUI stress test loaded.", Duration = 5000 })
