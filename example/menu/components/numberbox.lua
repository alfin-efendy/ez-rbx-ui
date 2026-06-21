return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "NumberBox", Icon = "hash" })
  tab:AddSection("Basic")
  tab:AddNumberBox({ Text = "Amount", Default = 10, Min = 0, Max = 100, Step = 5 })
  tab:AddNumberBox({ Text = "With description", Description = "Steps of 1.", Default = 5, Min = 0, Max = 50 })
  tab:AddSection("Persistence (Flag)")
  tab:AddNumberBox({ Text = "Saved count", Flag = "ex_number", Default = 3, Min = 0, Max = 99 })
  tab:AddParagraph("Flag-bound controls auto-save to the config file and restore on next load.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddNumberBox({ Text = "Nested", Default = 1, Min = 0, Max = 9 })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddNumberBox({ Text = "Nested", Default = 1, Min = 0, Max = 9 })
end
