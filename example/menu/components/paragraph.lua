return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Paragraph", Icon = "align-left" })
  tab:AddSection("Paragraph")
  tab:AddParagraph("Paragraphs wrap long text across multiple lines and auto-size their height. Use them for descriptions, changelogs, and help text within a tab.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddParagraph("Nested paragraph text.")
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddParagraph("Nested paragraph text.")
end
