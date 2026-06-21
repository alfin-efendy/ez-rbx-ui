return function(window)
  local tab = window:AddTab({ Name = "Settings", Icon = "settings" })
  tab:AddSection("Preferences")
  tab:AddToggle({ Text = "Share across devices", Flag = "share", Default = false,
    Description = "Focus is shared across devices, and turns off when you leave the app." })
  tab:AddToggle({ Text = "Enable notifications", Flag = "notif", Default = true,
    Description = "Receive notifications when focus mode is enabled or disabled." })
  tab:AddSection("Layout")
  local rz = tab:AddResizable({ Direction = "Horizontal", Panes = { { Default = 0.3 }, { Default = 0.7 } }, Height = 120 })
  rz.Panes[1]:AddLabel("Sidebar")
  rz.Panes[2]:AddLabel("Content")
end
