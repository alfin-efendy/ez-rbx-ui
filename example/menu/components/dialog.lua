return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Dialog", Icon = "message-square" })
  tab:AddSection("Modal dialog")
  tab:AddButton({ Text = "Open dialog", Callback = function()
    window:Dialog({ Title = "Delete item?", Message = "This cannot be undone.", Icon = "trash-2", Buttons = {
      { Text = "Cancel", Variant = "secondary" },
      { Text = "Delete", Variant = "destructive", Icon = "trash-2",
        Callback = function() window:ShowSuccess({ Title = "Deleted" }) end } } })
  end })
  tab:AddButton({ Text = "Open (icon badge)", Callback = function()
    window:Dialog({ Title = "Heads up", Message = "This uses the centered badge style.", Icon = "triangle-alert",
      IconBadge = true, Width = 360, Buttons = {
        { Text = "Cancel", Variant = "secondary" }, { Text = "Got it" } } })
  end })
  tab:AddParagraph("window:Dialog{Title,Message,Icon,IconBadge,Width,Buttons={{Text,Variant,Icon,Callback}}} opens a dimmed modal.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddButton({ Text = "Open", Callback = function() window:Dialog({ Title = "Hi", Buttons = { { Text = "OK" } } }) end })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddButton({ Text = "Open", Callback = function() window:Dialog({ Title = "Hi", Buttons = { { Text = "OK" } } }) end })
end
