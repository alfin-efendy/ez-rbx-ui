return function(window)
  local tab = window:AddTab({ Name = "Settings", Icon = "settings" })

  tab:AddSection("Appearance")
  tab:AddSelectBox({ Text = "Accent theme", Options = { "Mono", "Indigo", "Violet", "Emerald", "Sky", "Rose" },
    Default = "Mono", Callback = function(name) window:SetAccent(name) end })
  tab:AddSelectBox({ Text = "Floating button", Options = { "simple", "square", "circle" }, Default = "simple",
    Callback = function(t) window:SetFloatingToggle({ Type = t }) end })
  tab:AddSlider({ Text = "UI scale (%)", Min = 80, Max = 130, Default = 100,
    Callback = function(v) window:SetUIScale(v / 100) end })
  tab:AddSlider({ Text = "Acrylic transparency (%)", Min = 0, Max = 60, Default = 12,
    Callback = function(v) window:SetAcrylicTransparency(v / 100) end })

  tab:AddSection("Behavior")
  tab:AddToggle({ Text = "Enable notifications", Flag = "notif", Default = true,
    Description = "Show toast notifications for in-game events.",
    Callback = function(on) window:SetNotificationsEnabled(on) end })
  tab:AddKeybind({ Text = "Toggle UI key", Default = Enum.KeyCode.RightControl,
    Callback = function() window:Toggle() end })

  tab:AddSection("Profiles")
  tab:AddSelectBox({ Text = "Config profile", Options = window:ConfigProfiles(), Default = "Default",
    Callback = function(name) window:UseConfigProfile(name) end })

  tab:AddSection("Danger zone")
  tab:AddButton({ Text = "Reset all settings", Variant = "destructive",
    Callback = function() window:ResetConfiguration({ Confirm = true }) end })
end
