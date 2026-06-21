return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Resizable", Icon = "columns-2" })
  tab:AddSection("Split panes")
  local rz = tab:AddResizable({ Direction = "Horizontal", Panes = { { Default = 0.4 }, { Default = 0.6 } }, Height = 140 })
  rz.Panes[1]:AddLabel("Left pane")
  rz.Panes[1]:AddButton({ Text = "Action" })
  rz.Panes[2]:AddLabel("Right pane")
  rz.Panes[2]:AddToggle({ Text = "Option" })
  tab:AddParagraph("Drag the centre grip to resize; each pane hosts its own controls.")
end
