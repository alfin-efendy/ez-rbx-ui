-- One tab per file. Each returns function(window) that builds its tab.
return function(window)
  local tab = window:AddTab({ Name = "Home", Icon = "home" })

  tab:AddSection("About")
  tab:AddParagraph("EzUI is a modern Roblox UI library — shadcn-inspired, Fluent acrylic, and Lucide icons. Controls with a Flag auto-save to the config file and restore on next load.")

  tab:AddSection("Examples")
  tab:AddParagraph("Inputs — Button, Toggle, TextBox, NumberBox, SelectBox, Slider, Keybind, ColorPicker.")
  tab:AddParagraph("Display — Label, Paragraph, Separator, Image, ProgressBar, Table, Card.")
  tab:AddParagraph("Containers — Accordion, Resizable.")
  tab:AddParagraph("Overlays — Tooltip, Dialog, Notification.")
  tab:AddParagraph("Settings — theme mode, accent, floating button, UI scale, acrylic, and config profiles.")
  tab:AddParagraph("Tip: use the sidebar search, press RightControl to toggle the window, or use the floating button.")

  tab:AddSection("Credits")
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
