return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "NumberBox", Icon = "hash" })
  tab:AddSection("Basic")
  tab:AddNumberBox({ Text = "Amount", Default = 10, Min = 0, Max = 100, Step = 5 })
  tab:AddSection("Persistence (Flag)")
  tab:AddNumberBox({ Text = "Saved count", Flag = "ex_number", Default = 3, Min = 0, Max = 99 })
  tab:AddParagraph("Flag-bound controls auto-save to the config file and restore on next load.")
end
