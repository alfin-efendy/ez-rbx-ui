return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "PlayerSelector", Icon = "users" })
  tab:AddSection("Basic")
  tab:AddPlayerSelector({ Text = "Target" })
  tab:AddPlayerSelector({ Text = "Targets", Multi = true })
  tab:AddSection("Persistence (Flag)")
  tab:AddPlayerSelector({ Text = "Saved target", Flag = "ex_player" })
  tab:AddParagraph("Auto-updates as players join/leave; Flag-bound selectors auto-save and restore.")
end
