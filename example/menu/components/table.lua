return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Table", Icon = "table" })
  tab:AddSection("Data table")
  local t = tab:AddTable({ Columns = { "Player", "Kills", "Deaths" }, Rows = {
    { "Alpha", "12", "3" }, { "Bravo", "8", "5" } } })
  local n = 2
  tab:AddButton({ Text = "Add row", Callback = function() n = n + 1; t.AddRow({ "P" .. n, tostring(n), "0" }) end })
  tab:AddParagraph("Columns + rows with AddRow/SetData/Clear; scrolls when tall.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddTable({ Columns = { "A", "B" }, Rows = { { "1", "2" } } })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddTable({ Columns = { "A", "B" }, Rows = { { "1", "2" } } })
end
