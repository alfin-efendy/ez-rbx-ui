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
  tab:AddSection("Search + disabled")
  -- long list -> search box appears automatically; flips up near the screen bottom
  tab:AddSelectBox({ Text = "Country", Options = { "ID", "US", "JP", "DE", "FR", "BR", "IN" }, Default = "ID" })
  tab:AddSelectBox({ Text = "Locked", Options = { "X", "Y" }, Default = "X", Disabled = true })
  tab:AddSection("Data-driven (async + OnOpen)")
  local WEAPON_DB = { wpn_001 = "Bow", wpn_002 = "Shield", wpn_003 = "Sword" }
  local function weaponOptions()
    local out = {}
    for id, name in pairs(WEAPON_DB) do out[#out + 1] = { Value = id, Text = name } end
    return out
  end
  -- the Value (wpn_xxx) persists to the flag; the Text (name) is shown in the UI.
  -- OnOpen refreshes the options every time the dropdown opens.
  local wsel = tab:AddSelectBox({ Text = "Weapon", Flag = "weapon_id", Loading = true, Options = {},
    OnOpen = function(api) api.SetOptions(weaponOptions()) end })
  local function loadWeapons()
    wsel.SetLoading(true)
    task.delay(1.5, function() wsel.SetOptions(weaponOptions()); wsel.SetLoading(false) end)
  end
  loadWeapons() -- initial async load
  -- click any time to re-trigger loading: spinner shows on the field; open the Weapon
  -- select to see the "Loading…" row, then options appear ~1.5s later
  tab:AddButton({ Text = "Reload weapons (loading demo)", Variant = "secondary", Callback = loadWeapons })
  local big = {}; for i = 1, 24 do big[i] = "Item " .. i end
  tab:AddSelectBox({ Text = "Long list", Options = big, Default = "Item 1" })
  tab:AddSelectBox({ Text = "Notify", Options = { "Red", "Green", "Blue" }, Default = "Red",
    Callback = function(v) window:ShowSuccess({ Title = "Picked", Message = tostring(v) }) end })
  tab:AddSection("Persistence (Flag)")
  tab:AddSelectBox({ Text = "Saved choice", Flag = "ex_select", Options = { "One", "Two", "Three" }, Default = "One" })
  tab:AddParagraph("Single, multi+search, per-item icon/desc/divider, AllowNone, dynamic SetOptions, and a Flag-bound select.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddSelectBox({ Text = "Nested", Options = { "A", "B" }, Default = "A" })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddSelectBox({ Text = "Nested", Options = { "A", "B" }, Default = "A" })
end
