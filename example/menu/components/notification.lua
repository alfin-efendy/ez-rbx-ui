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
  tab:AddButton({ Text = "Test promise toast", Icon = "loader", Callback = function()
    -- Promise(): a loading toast that auto-morphs into success/error when the yielding fn settles.
    window:Promise(function() task.wait(1.5); return true end,
      { Loading = "Saving…", Success = "Saved!", Error = "Failed to save" })
  end })
  tab:AddParagraph("ShowSuccess/Warning/Error/Info + Notify{Action=…} + Promise{Loading/Success/Error}; toasts have a countdown that pauses on hover.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddButton({ Text = "Notify", Callback = function() window:ShowInfo({ Title = "Hi" }) end })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddButton({ Text = "Notify", Callback = function() window:ShowInfo({ Title = "Hi" }) end })
end
