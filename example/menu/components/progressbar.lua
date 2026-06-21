return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "ProgressBar", Icon = "activity" })
  tab:AddSection("Basic")
  local pb = tab:AddProgressBar({ Default = 0.4 })
  local p = 0.4
  tab:AddButton({ Text = "+20%", Callback = function() p = math.min(1, p + 0.2); pb.Set(p) end })
  tab:AddButton({ Text = "Reset", Variant = "secondary", Callback = function() p = 0; pb.Set(0) end })
  tab:AddParagraph("Set(0..1) animates the fill; pass Color to override the accent.")
end
