return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Toggle", Icon = "toggle-left" })
  tab:AddSection("Basic")
  tab:AddToggle({ Text = "Enable feature", Default = false, Callback = function(on) print("toggle", on) end })
  tab:AddToggle({ Text = "With description", Description = "Extra context shown under the label.", Default = true })
  tab:AddSection("Persistence (Flag)")
  tab:AddToggle({ Text = "Remember me", Flag = "ex_toggle", Default = true })
  tab:AddParagraph("Flag-bound controls auto-save to the config file and restore on next load.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddToggle({ Text = "Nested toggle", Default = true })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddToggle({ Text = "Nested toggle", Default = false })
end
