-- Require the BUILT bundle (run `make build` first / `make stress` does it).
local EzUI = require("../output/bundle")

local window = EzUI:CreateWindow({
  Title = "EzUI Stress Test",
  Size = { Width = 600, Height = 440 },
  Acrylic = true,
  Config = { FileName = "EzUIStress", AutoSave = false },
})

for i = 1, 20 do
  local tab = window:AddTab({ Name = "Tab " .. i, Icon = "home" })
  tab:AddSection("Controls")
  tab:AddParagraph("Every control type, mounted via the host mixin.")
  tab:AddToggle({ Text = "Enable " .. i, Default = (i % 2 == 0), Flag = "enable_" .. i, Tooltip = "Toggles feature " .. i })
  tab:AddSlider({ Text = "Speed", Min = 0, Max = 100, Default = 50, Flag = "speed_" .. i })
  tab:AddNumberBox({ Text = "Amount", Default = 10, Min = 0, Max = 100, Flag = "amount_" .. i })
  tab:AddSelectBox({ Text = "Mode", Options = { "Alpha", "Beta", "Gamma" }, Default = "Alpha", Flag = "mode_" .. i })
  tab:AddKeybind({ Text = "Hotkey", Default = Enum.KeyCode.E, Flag = "key_" .. i,
    Callback = (i == 1) and function()
      window:Dialog({ Title = "Hotkey fired", Message = "Your bound key was pressed.", Buttons = { { Text = "OK" } } })
    end or nil })
  tab:AddColorPicker({ Text = "ESP Color", Default = Color3.fromRGB(255, 80, 80), Flag = "color_" .. i })
  tab:AddProgressBar({ Default = 0.4 })
  tab:AddTextBox({ Text = "Key", Default = "ABC-123", Copyable = true })
  tab:AddTable({ Columns = { "Player", "Score" }, Rows = { { "Alpha", "120" }, { "Beta", "98" } } })
  tab:AddButton({ Text = "Confirm", Variant = "default", Icon = "play", Callback = function()
    window:Dialog({ Title = "Confirm", Message = "Run this action?", Buttons = {
      { Text = "Cancel", Variant = "secondary" },
      { Text = "Run", Variant = "default" },
    } })
  end })
  tab:AddSeparator()
  tab:AddButton({ Text = "Reset to Defaults", Variant = "destructive", Action = "ResetConfig" })

  for j = 1, 10 do
    local acc = tab:AddAccordion({ Title = "Accordion " .. j, Icon = "settings-2", Expanded = (j == 1) })
    acc:AddToggle({ Text = "Feature " .. j, Default = false })
    acc:AddSlider({ Text = "Level", Min = 1, Max = 10, Default = 3 })
  end
end
