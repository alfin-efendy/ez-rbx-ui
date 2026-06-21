return function(window)
  local tab = window:AddTab({ Name = "Credits", Icon = "heart" })
  tab:AddCard({
    Title = "EzUI",
    Body = "A modern Roblox UI library. shadcn-inspired, Fluent acrylic, Lucide icons.",
    Buttons = {
      { Text = "Notify", Variant = "secondary",
        Callback = function() window:Notify({ Title = "Hello", Message = "Thanks for using EzUI!", Type = "info" }) end },
      { Text = "Undo demo", Variant = "ghost", Callback = function()
        window:Notify({ Title = "Item deleted", Message = "Removed from inventory.", Type = "warning",
          Action = { Text = "Undo", Callback = function() window:ShowSuccess({ Title = "Restored" }) end } })
      end },
    },
  })
end
