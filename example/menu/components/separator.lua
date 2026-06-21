return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Separator", Icon = "minus" })
  tab:AddLabel("Above the separator")
  tab:AddSeparator()
  tab:AddLabel("Below the separator")
  tab:AddParagraph("A 1px divider used to group related rows.")
end
