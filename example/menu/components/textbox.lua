return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "TextBox", Icon = "type" })
  tab:AddSection("Basic")
  tab:AddTextBox({ Text = "Name", Placeholder = "Type your name…" })
  tab:AddTextBox({ Text = "Key", Default = "EZUI-DEMO", Copyable = true })
  tab:AddSection("Persistence (Flag)")
  tab:AddTextBox({ Text = "Saved note", Flag = "ex_textbox", Default = "hello" })
  tab:AddParagraph("Flag-bound controls auto-save to the config file and restore on next load.")
end
