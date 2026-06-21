return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Separator", Icon = "minus" })
  tab:AddLabel("Above the separator")
  tab:AddSeparator()
  tab:AddLabel("Below the separator")
  tab:AddParagraph("A 1px divider used to group related rows.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddLabel("Above"); acc:AddSeparator(); acc:AddLabel("Below")
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddLabel("Above"); acc2:AddSeparator(); acc2:AddLabel("Below")
end
