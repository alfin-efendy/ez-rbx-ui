return function(window)
  local tab = window:AddTab({ Name = "Credits", Icon = "heart" })
  tab:AddImage({ Lucide = "gamepad-2", Height = 64 })
  tab:AddParagraph("EzUI — a modern Roblox UI library. shadcn-inspired, Fluent acrylic, Lucide icons.")
  tab:AddButton({ Text = "Notify Me", Variant = "ghost",
    Callback = function() window:Notify({ Title = "Hello", Message = "Thanks for using EzUI!", Type = "info" }) end })
  tab:AddButton({ Text = "Notify with Action", Variant = "ghost", Callback = function()
    window:Notify({ Title = "Item deleted", Message = "Removed from inventory.", Type = "warning",
      Action = { Text = "Undo", Callback = function() window:ShowSuccess({ Title = "Restored" }) end } })
  end })
end
