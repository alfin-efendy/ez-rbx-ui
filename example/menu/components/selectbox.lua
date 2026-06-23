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
  -- multi-select with a long list: sticky search stays pinned, and picking an option
  -- keeps your scroll position instead of jumping back to the top
  local fruits = { "Apple", "Apricot", "Avocado", "Banana", "Blackberry", "Blueberry", "Cherry", "Coconut",
    "Cranberry", "Date", "Dragonfruit", "Fig", "Grape", "Guava", "Kiwi", "Lemon", "Lime", "Mango",
    "Melon", "Nectarine", "Orange", "Papaya", "Peach", "Pear", "Pineapple", "Plum", "Pomegranate",
    "Raspberry", "Strawberry", "Watermelon" }
  tab:AddSelectBox({ Text = "Fruits", Options = fruits, Multi = true, Default = { "Apple", "Mango" } })
  tab:AddSection("Per-item + AllowNone")
  tab:AddSelectBox({ Text = "Weapon", AllowNone = true, Options = {
    { Value = "Bow", Icon = "target", Desc = "Ranged" }, { Divider = true },
    { Value = "Shield", Icon = "shield", Desc = "Defense" } } })
  tab:AddSelectBox({ Text = "With description", Description = "Choose a difficulty.", Options = { "Easy", "Hard" }, Default = "Easy" })
  tab:AddSection("Search + disabled")
  -- long list -> search box appears automatically; flips up near the screen bottom
  tab:AddSelectBox({ Text = "Country", Options = { "ID", "US", "JP", "DE", "FR", "BR", "IN" }, Default = "ID" })
  tab:AddSelectBox({ Text = "Locked", Options = { "X", "Y" }, Default = "X", Disabled = true })
  tab:AddSection("Data-driven (async LoadOptions)")
  local WEAPON_DB = {
    wpn_001 = "Bow", wpn_002 = "Shield", wpn_003 = "Sword", wpn_004 = "Dagger",
    wpn_005 = "Katana", wpn_006 = "Spear", wpn_007 = "Mace", wpn_008 = "Axe",
    wpn_009 = "Crossbow", wpn_010 = "Staff", wpn_011 = "Wand", wpn_012 = "Hammer",
    wpn_013 = "Scythe", wpn_014 = "Rapier", wpn_015 = "Halberd", wpn_016 = "Gauntlet",
  }
  -- ONE function builds the options. It can take a few seconds (HTTP, datastore, etc.).
  -- While it hasn't returned, the select shows its loading state automatically — no manual
  -- SetLoading — and it runs async so it never blocks the other controls. If it never
  -- returns, the loading state clears after Timeout seconds (default 60).
  local function weaponOptions()
    task.wait(math.random(3, 5)) -- simulate slow async work
    local out = {}
    for id, name in pairs(WEAPON_DB) do out[#out + 1] = { Value = id, Text = name } end
    table.sort(out, function(a, b) return a.Value < b.Value end)
    return out
  end
  -- the Value (wpn_xxx) persists to the flag; the Text (name) is shown in the UI. Default
  -- pre-selects a value (its name appears once LoadOptions resolves); Flag persists the choice.
  tab:AddSelectBox({ Text = "Weapon", Flag = "weapon_id", Default = "wpn_005", LoadOptions = weaponOptions })

  -- same async pattern for a MULTI select: Default pre-selects several values, Flag persists them.
  local ROLE_DB = { role_dps = "DPS", role_tank = "Tank", role_heal = "Healer", role_supp = "Support",
    role_scout = "Scout", role_mage = "Mage", role_rogue = "Rogue", role_bard = "Bard" }
  local function roleOptions()
    task.wait(math.random(3, 5)) -- simulate slow async work
    local out = {}
    for id, name in pairs(ROLE_DB) do out[#out + 1] = { Value = id, Text = name } end
    table.sort(out, function(a, b) return a.Value < b.Value end)
    return out
  end
  tab:AddSelectBox({ Text = "Roles", Multi = true, Flag = "roles",
    Default = { "role_dps", "role_heal" }, LoadOptions = roleOptions })

  -- options that change on every open: OnOpen re-runs the async loader, so the list (and the
  -- live player counts) are different each time the dropdown opens. Flag persists the pick.
  local function liveServers()
    task.wait(math.random(1, 2)) -- quick refetch
    local out = {}
    for i = 1, math.random(3, 7) do
      out[#out + 1] = { Value = "srv_" .. i, Text = ("Server %d — %d/30"):format(i, math.random(0, 30)) }
    end
    return out
  end
  tab:AddSelectBox({ Text = "Server (live)", Flag = "server_id",
    LoadOptions = liveServers, OnOpen = function(api) api.Reload() end })

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
