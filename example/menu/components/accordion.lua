return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Accordion", Icon = "rows-3" })
  tab:AddSection("Collapsible")
  local acc = tab:AddAccordion({ Title = "Advanced settings", Icon = "settings-2", Expanded = false })
  acc:AddToggle({ Text = "Nested toggle", Default = true })
  acc:AddSlider({ Text = "Nested slider", Min = 0, Max = 10, Default = 5 })
  acc:AddButton({ Text = "Nested button" })
  tab:AddSection("Expanded by default")
  local acc2 = tab:AddAccordion({ Title = "Open on load", Icon = "settings-2", Expanded = true })
  acc2:AddToggle({ Text = "Nested toggle", Default = false })
  acc2:AddButton({ Text = "Nested button" })
  tab:AddParagraph("Accordion is a card that hosts any controls and expands/collapses on click; Expanded=true starts open.")
end
