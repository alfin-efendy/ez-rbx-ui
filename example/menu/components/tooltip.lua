return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Tooltip", Icon = "info" })
  tab:AddSection("Hover hints")
  tab:AddButton({ Text = "Hover me", Tooltip = "I'm a tooltip on a button." })
  tab:AddToggle({ Text = "Toggle with hint", Tooltip = "Tooltips attach to any control via Tooltip='…'." })
  tab:AddParagraph("Pass Tooltip='…' to any AddX control to show a hover hint.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddButton({ Text = "Hover", Tooltip = "Tooltip inside an accordion." })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddButton({ Text = "Hover", Tooltip = "Tooltip inside an accordion." })
end
