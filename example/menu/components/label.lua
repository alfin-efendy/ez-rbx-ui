return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Label", Icon = "type" })
  tab:AddSection("Variants")
  tab:AddLabel("Default label")
  tab:AddSection("Section heading (uppercased)")
  local dyn = tab:AddLabel("Click the button to change me")
  tab:AddButton({ Text = "Set text", Callback = function() dyn.SetText("Updated at runtime!") end })
  tab:AddParagraph("Labels support default + section variants and a SetText API for dynamic text.")
  tab:AddSection("Multi-line")
  tab:AddLabel("Default labels are single-line (extra lines get clipped).")
  -- For multiple lines in a label, use the paragraph variant: it wraps and auto-sizes its height,
  -- and honors explicit \n breaks.
  local multi = tab:AddLabel({ Variant = "paragraph",
    Text = "First line\nSecond line\nThird line — explicit \\n breaks plus automatic wrapping when a line is too long to fit on screen." })
  tab:AddButton({ Text = "Append a line", Callback = function()
    multi.SetText(multi.Frame.Text .. "\nAdded at runtime!")
  end })
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddLabel("Nested label")
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddLabel("Nested label")
end
