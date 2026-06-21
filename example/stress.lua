-- Require the BUILT bundle (run `make build` first / `make stress` does it).
-- The built bundle has no internal require() calls, so re-bundling it is safe.
local EzUI = require("../output/bundle")

local window = EzUI:CreateWindow({
  Title = "EzUI Stress Test",
  Size = { Width = 600, Height = 440 },
  Acrylic = true,
  Config = { FileName = "EzUIStress", AutoSave = false },
})

for i = 1, 20 do
  local tab = window:AddTab({ Name = "Tab " .. i, Icon = "home" })
  tab:AddSection("Section " .. i)
  tab:AddParagraph("Demonstrates real controls mounted via the host mixin.")
  tab:AddToggle({ Text = "Enable " .. i, Default = (i % 2 == 0), Flag = "enable_" .. i })
  tab:AddButton({ Text = "Run " .. i, Variant = "default", Icon = "play", Callback = function() end })
  tab:AddTextBox({ Text = "Name", Default = "Player", Flag = "name_" .. i })
  tab:AddNumberBox({ Text = "Value", Default = 10, Min = 0, Max = 100, Flag = "value_" .. i })
  tab:AddSelectBox({ Text = "Mode", Options = { "Alpha", "Beta", "Gamma" }, Default = "Alpha", Flag = "mode_" .. i })
  tab:AddSeparator()
  tab:AddButton({ Text = "Reset to Defaults", Variant = "destructive", Action = "ResetConfig" })

  for j = 1, 10 do
    local acc = tab:AddAccordion({ Title = "Accordion " .. j, Icon = "settings-2", Expanded = (j == 1) })
    acc:AddToggle({ Text = "Feature " .. j, Default = false })
    acc:AddNumberBox({ Text = "Amount", Default = 5, Min = 0, Max = 50 })
    acc:AddSelectBox({ Text = "Target", Options = { "A", "B", "C" }, Multi = true, Default = { "A" } })
  end
end
