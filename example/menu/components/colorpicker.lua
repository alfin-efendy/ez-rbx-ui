return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "ColorPicker", Icon = "palette" })
  tab:AddSection("Basic")
  tab:AddColorPicker({ Text = "Box color", Default = Color3.fromRGB(120, 160, 255),
    Callback = function(c) print("color", c) end })
  tab:AddSection("Persistence (Flag)")
  tab:AddColorPicker({ Text = "Saved color", Flag = "ex_color", Default = Color3.fromRGB(255, 80, 80) })
  tab:AddParagraph("Flag-bound color pickers auto-save and restore.")
end
