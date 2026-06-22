return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Card", Icon = "credit-card" })
  tab:AddSection("Rich card")
  tab:AddCard({ Title = "Announcement", Body = "A rich card with a banner image and action buttons.",
    Banner = "rbxassetid://0", Buttons = {
      { Text = "Confirm", Callback = function() window:ShowSuccess({ Title = "Confirmed" }) end },
      { Text = "Dismiss", Variant = "ghost" } } })
  tab:AddParagraph("Card = banner (optional) + title + body + an action-button row.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddCard({ Title = "Nested", Body = "Card inside an accordion." })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddCard({ Title = "Nested", Body = "Card inside an accordion." })
end
