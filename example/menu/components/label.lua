return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Label", Icon = "type" })
  tab:AddSection("Variants")
  tab:AddLabel("Default label")
  tab:AddSection("Section heading (uppercased)")
  local dyn = tab:AddLabel("Click the button to change me")
  tab:AddButton({ Text = "Set text", Callback = function() dyn.SetText("Updated at runtime!") end })
  tab:AddParagraph("Labels support default + section variants and a SetText API for dynamic text.")
end
