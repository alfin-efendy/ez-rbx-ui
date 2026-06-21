return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Paragraph", Icon = "align-left" })
  tab:AddSection("Paragraph")
  tab:AddParagraph("Paragraphs wrap long text across multiple lines and auto-size their height. Use them for descriptions, changelogs, and help text within a tab.")
end
