return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "SelectBox", Icon = "list" })
  tab:AddSection("Single + multi")
  local sel = tab:AddSelectBox({ Text = "Mode", Options = { "Auto", "Manual", "Hybrid" }, Default = "Auto" })
  -- Shuffle drives the Mode select above, so it sits right beneath it
  local pool, rot = { "Apple", "Banana", "Cherry", "Date", "Fig" }, 0
  tab:AddButton({ Text = "Shuffle options", Variant = "secondary", Callback = function()
    rot = rot + 1
    sel.SetOptions({ pool[(rot % 5) + 1], pool[((rot + 1) % 5) + 1], pool[((rot + 2) % 5) + 1] })
  end })
  tab:AddSelectBox({ Text = "Tags", Options = { "A", "B", "C" }, Multi = true, Default = { "A" } })
  tab:AddSection("Per-item + AllowNone")
  tab:AddSelectBox({ Text = "Weapon", AllowNone = true, Options = {
    { Value = "Bow", Icon = "target", Desc = "Ranged" }, { Divider = true },
    { Value = "Shield", Icon = "shield", Desc = "Defense" } } })
  tab:AddSelectBox({ Text = "With description", Description = "Choose a difficulty.", Options = { "Easy", "Hard" }, Default = "Easy" })
  tab:AddSection("Persistence (Flag)")
  tab:AddSelectBox({ Text = "Saved choice", Flag = "ex_select", Options = { "One", "Two", "Three" }, Default = "One" })
  tab:AddParagraph("Single, multi+search, per-item icon/desc/divider, AllowNone, dynamic SetOptions, and a Flag-bound select.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddSelectBox({ Text = "Nested", Options = { "A", "B" }, Default = "A" })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddSelectBox({ Text = "Nested", Options = { "A", "B" }, Default = "A" })
end
