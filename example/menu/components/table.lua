return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Table", Icon = "table" })
  tab:AddSection("Data table")
  local t = tab:AddTable({ Columns = { "Player", "Kills", "Deaths" }, Rows = {
    { "Alpha", "12", "3" }, { "Bravo", "8", "5" } } })
  local n = 2
  tab:AddButton({ Text = "Add row", Callback = function() n = n + 1; t.AddRow({ "P" .. n, tostring(n), "0" }) end })
  tab:AddParagraph("Columns + rows with AddRow/SetData/Clear; scrolls when tall.")
end
