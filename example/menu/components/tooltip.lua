return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Tooltip", Icon = "info" })
  tab:AddSection("Hover hints")
  tab:AddButton({ Text = "Hover me", Tooltip = "I'm a tooltip on a button." })
  tab:AddToggle({ Text = "Toggle with hint", Tooltip = "Tooltips attach to any control via Tooltip='…'." })
  tab:AddParagraph("Pass Tooltip='…' to any AddX control to show a hover hint.")
end
