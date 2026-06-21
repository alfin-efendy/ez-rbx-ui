return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Image", Icon = "image" })
  tab:AddSection("Lucide + asset")
  tab:AddImage({ Lucide = "gamepad-2", Height = 64 })
  tab:AddImage({ Image = "rbxassetid://0", Height = 80 })
  tab:AddParagraph("Image renders a Lucide glyph (Lucide=name) or a raw asset (Image=rbxassetid://…).")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddImage({ Lucide = "gamepad-2", Height = 48 })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddImage({ Lucide = "gamepad-2", Height = 48 })
end
