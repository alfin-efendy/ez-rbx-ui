return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "ColorPicker", Icon = "palette" })
  tab:AddSection("Basic")
  tab:AddColorPicker({ Text = "Box color", Default = Color3.fromRGB(120, 160, 255),
    Callback = function(c) print("color", c) end })
  tab:AddColorPicker({ Text = "With description", Description = "Click to open the picker.", Default = Color3.fromRGB(80, 200, 120) })
  tab:AddSection("Persistence (Flag)")
  tab:AddColorPicker({ Text = "Saved color", Flag = "ex_color", Default = Color3.fromRGB(255, 80, 80) })
  tab:AddParagraph("Flag-bound color pickers auto-save and restore.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddColorPicker({ Text = "Nested", Default = Color3.fromRGB(120, 160, 255) })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddColorPicker({ Text = "Nested", Default = Color3.fromRGB(120, 160, 255) })
end
