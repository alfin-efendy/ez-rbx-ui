return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Notification", Icon = "bell" })
  tab:AddSection("Toasts")
  tab:AddButton({ Text = "Success", Callback = function() window:ShowSuccess({ Title = "Saved", Message = "All good." }) end })
  tab:AddButton({ Text = "Warning", Variant = "secondary", Callback = function() window:ShowWarning({ Title = "Careful" }) end })
  tab:AddButton({ Text = "Error", Variant = "destructive", Callback = function() window:ShowError({ Title = "Failed" }) end })
  tab:AddButton({ Text = "Info", Variant = "outline", Callback = function() window:ShowInfo({ Title = "Heads up" }) end })
  tab:AddButton({ Text = "With action", Variant = "ghost", Callback = function()
    window:Notify({ Title = "Item deleted", Type = "warning", Action = { Text = "Undo", Callback = function() window:ShowSuccess({ Title = "Restored" }) end } })
  end })
  tab:AddParagraph("ShowSuccess/Warning/Error/Info + Notify{Action=…}; toasts have a countdown that pauses on hover.")
end
