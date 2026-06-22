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
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddButton({ Text = "Open", Callback = function() window:Dialog({ Title = "Hi", Buttons = { { Text = "OK" } } }) end })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddButton({ Text = "Open", Callback = function() window:Dialog({ Title = "Hi", Buttons = { { Text = "OK" } } }) end })
end
