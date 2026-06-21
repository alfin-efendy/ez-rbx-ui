return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Card", Icon = "credit-card" })
  tab:AddSection("Rich card")
  tab:AddCard({ Title = "Announcement", Body = "A rich card with a banner image and action buttons.",
    Banner = "rbxassetid://0", Buttons = {
      { Text = "Confirm", Callback = function() window:ShowSuccess({ Title = "Confirmed" }) end },
      { Text = "Dismiss", Variant = "ghost" } } })
  tab:AddParagraph("Card = banner (optional) + title + body + an action-button row.")
end
