return function(window)
  local tab = window:AddTab({ Name = "Components", Icon = "shapes" })

  tab:AddSection("Dynamic options")
  local sel = tab:AddSelectBox({ Text = "Fruit", Options = { "Apple", "Banana", "Cherry" }, Default = "Apple" })
  local pool = { "Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape" }
  local rot = 0
  tab:AddButton({ Text = "Shuffle options", Variant = "secondary", Callback = function()
    rot = rot + 1
    local pick = {}
    for i = 1, 3 do pick[i] = pool[((rot + i) % #pool) + 1] end
    sel.SetOptions(pick)
    window:ShowInfo({ Title = "Options updated", Duration = 2500 })
  end })

  tab:AddSection("Multiple select")
  tab:AddSelectBox({ Text = "Modes", Options = { "Auto", "Manual", "Hybrid" }, Multi = true, Default = { "Auto" } })
  tab:AddSelectBox({ Text = "Quality", Options = { "Low", "Med", "High" }, Default = "Med" })

  tab:AddSection("Dynamic value label")
  local readout = tab:AddLabel("Speed: 16")
  local speed = tab:AddSlider({ Text = "Speed", Min = 16, Max = 200, Default = 16 })
  speed.OnChanged(function(v) readout.SetText("Speed: " .. tostring(v)) end)

  tab:AddSection("Live counter")
  local count = 0
  local counter = tab:AddLabel("Clicks: 0")
  tab:AddButton({ Text = "Increment", Callback = function() count = count + 1; counter.SetText("Clicks: " .. count) end })

  tab:AddSection("Locked + advanced dropdown")
  tab:AddButton({ Text = "Locked button", Locked = true })
  tab:AddSelectBox({ Text = "Weapon", AllowNone = true, Options = {
    { Value = "Bow", Icon = "target", Desc = "Ranged" }, { Divider = true },
    { Value = "Shield", Icon = "shield", Desc = "Defense" } } })

  tab:AddSection("Dependent select")
  local detail = tab:AddSelectBox({ Text = "Detail", Options = { "Sword", "Axe" }, Default = "Sword" })
  tab:AddSelectBox({ Text = "Category", Options = { "Weapon", "Armor" }, Default = "Weapon",
    Callback = function(v)
      if v == "Weapon" then detail.SetOptions({ "Sword", "Axe", "Bow" }) else detail.SetOptions({ "Helmet", "Shield" }) end
    end })
end
