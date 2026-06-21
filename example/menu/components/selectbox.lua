return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "SelectBox", Icon = "list" })
  tab:AddSection("Single + multi")
  local sel = tab:AddSelectBox({ Text = "Mode", Options = { "Auto", "Manual", "Hybrid" }, Default = "Auto" })
  tab:AddSelectBox({ Text = "Tags", Options = { "A", "B", "C" }, Multi = true, Default = { "A" } })
  tab:AddSection("Per-item + AllowNone")
  tab:AddSelectBox({ Text = "Weapon", AllowNone = true, Options = {
    { Value = "Bow", Icon = "target", Desc = "Ranged" }, { Divider = true },
    { Value = "Shield", Icon = "shield", Desc = "Defense" } } })
  local pool, rot = { "Apple", "Banana", "Cherry", "Date", "Fig" }, 0
  tab:AddButton({ Text = "Shuffle options", Variant = "secondary", Callback = function()
    rot = rot + 1
    sel.SetOptions({ pool[(rot % 5) + 1], pool[((rot + 1) % 5) + 1], pool[((rot + 2) % 5) + 1] })
  end })
  tab:AddSection("Persistence (Flag)")
  tab:AddSelectBox({ Text = "Saved choice", Flag = "ex_select", Options = { "One", "Two", "Three" }, Default = "One" })
  tab:AddParagraph("Single, multi+search, per-item icon/desc/divider, AllowNone, dynamic SetOptions, and a Flag-bound select.")
end
