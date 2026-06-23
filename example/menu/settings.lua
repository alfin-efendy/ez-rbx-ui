return function(window)
  local tab = window:AddTab({ Name = "Settings", Icon = "settings" })

  tab:AddSection("Appearance")
  tab:AddSelectBox({ Text = "Mode", Options = { "Dark", "Light" }, Default = "Dark",
    Callback = function(m) window:SetMode(m == "Light" and "light" or "dark") end })
  local accentPicker
  tab:AddSelectBox({ Text = "Accent", Options = { "Adaptive", "Indigo", "Violet", "Emerald", "Sky", "Rose", "Custom" },
    Default = "Adaptive", Callback = function(name)
      if name == "Custom" then
        if accentPicker then accentPicker.Frame.Visible = true; window:SetAccent(accentPicker.GetColor()) end
      else
        if accentPicker then accentPicker.Frame.Visible = false end
        window:SetAccent(name)
      end
    end })
  accentPicker = tab:AddColorPicker({ Text = "Custom accent", Default = Color3.fromRGB(99, 102, 241),
    Callback = function(c) window:SetAccent(c) end })
  accentPicker.Frame.Visible = false
  tab:AddSelectBox({ Text = "Floating button", Options = { "simple", "square", "circle" }, Default = "simple",
    Callback = function(t) window:SetFloatingToggle({ Type = t }) end })
  tab:AddSlider({ Text = "UI scale (%)", Min = 80, Max = 130, Default = 100,
    Callback = function(v) window:SetUIScale(v / 100) end })
  tab:AddSlider({ Text = "Window transparency (%)", Min = 0, Max = 60, Default = 12,
    Callback = function(v) window:SetTransparency(v / 100) end })

  tab:AddSection("Behavior")
  tab:AddToggle({ Text = "Enable notifications", Flag = "notif", Default = true,
    Description = "Show toast notifications for in-game events.",
    Callback = function(on) window:SetNotificationsEnabled(on) end })
  -- Rebind the window's built-in toggle key. Use OnChanged (not Callback) so we don't add a
  -- SECOND toggle handler on the same key — that would fire alongside the window's own one
  -- and just make the window blink (hide+show) instead of toggling.
  tab:AddKeybind({ Text = "Toggle UI key", Default = Enum.KeyCode.RightControl,
    OnChanged = function(key) window:SetToggleKey(key) end })

  local cfg = tab:AddAccordion({ Title = "Configuration", Icon = "settings-2" })
  cfg:AddSelectBox({ Text = "Profile", Options = window:ConfigProfiles(), Default = "Default",
    Callback = function(name) window:UseConfigProfile(name) end })
  cfg:AddButton({ Text = "Save", Icon = "save",
    Callback = function() window:SaveConfiguration(); window:ShowSuccess({ Title = "Saved" }) end })
  cfg:AddButton({ Text = "Load", Variant = "secondary",
    Callback = function() window:LoadConfiguration(); window:ShowInfo({ Title = "Loaded" }) end })
  cfg:AddButton({ Text = "Reset all settings", Variant = "destructive",
    Callback = function() window:ResetConfiguration({ Confirm = true }) end })
end
