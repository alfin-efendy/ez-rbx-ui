return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Image", Icon = "image" })
  tab:AddSection("Lucide + asset")
  tab:AddImage({ Lucide = "gamepad-2", Height = 64 })
  tab:AddImage({ Image = "rbxassetid://0", Height = 80 })
  tab:AddParagraph("Image renders a Lucide glyph (Lucide=name) or a raw asset (Image=rbxassetid://…).")
end
