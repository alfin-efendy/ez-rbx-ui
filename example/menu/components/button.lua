return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Button", Icon = "square" })
  tab:AddSection("Variants")
  tab:AddButton({ Text = "Default", Callback = function() window:ShowSuccess({ Title = "Clicked" }) end })
  tab:AddButton({ Text = "Secondary", Variant = "secondary" })
  tab:AddButton({ Text = "Outline", Variant = "outline" })
  tab:AddButton({ Text = "Ghost", Variant = "ghost" })
  tab:AddButton({ Text = "Destructive", Variant = "destructive" })
  tab:AddButton({ Text = "With icon", Icon = "play" })
  tab:AddButton({ Text = "Reset config", Variant = "destructive", Action = "ResetConfig" })
  tab:AddParagraph("Button variants: default/secondary/outline/ghost/destructive, optional Icon, and Action='ResetConfig'.")
end
