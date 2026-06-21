return function(window)
  local tab = window:AddTab({ Name = "Players", Icon = "users" })
  tab:AddSection("Target")
  tab:AddPlayerSelector({ Text = "Player", Flag = "target" })
  tab:AddTextBox({ Text = "Your Key", Default = "EZUI-DEMO-KEY", Copyable = true })
  tab:AddTable({ Columns = { "Player", "Kills", "Deaths" }, Rows = {
    { "Alpha", "12", "3" }, { "Bravo", "8", "5" }, { "Charlie", "20", "1" },
  } })
end
