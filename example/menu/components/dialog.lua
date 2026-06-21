return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Dialog", Icon = "message-square" })
  tab:AddSection("Modal dialog")
  tab:AddButton({ Text = "Open dialog", Callback = function()
    window:Dialog({ Title = "Delete item?", Message = "This cannot be undone.", Buttons = {
      { Text = "Cancel", Variant = "secondary" },
      { Text = "Delete", Variant = "destructive", Callback = function() window:ShowSuccess({ Title = "Deleted" }) end } } })
  end })
  tab:AddParagraph("window:Dialog{Title,Message,Buttons={{Text,Variant,Callback}}} opens a dimmed modal.")
end
