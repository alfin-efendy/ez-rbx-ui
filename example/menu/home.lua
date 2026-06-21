-- One tab per file. Each returns function(window) that builds its tab.
return function(window)
  local tab = window:AddTab({ Name = "Home", Icon = "home" })
  tab:AddSection("General")
  tab:AddParagraph("Welcome to EzUI. Controls with a Flag auto-save and restore.")
  tab:AddToggle({ Text = "Auto Farm", Flag = "autofarm", Default = false,
    Callback = function(on) print("Auto Farm:", on) end })
  tab:AddSlider({ Text = "Walk Speed", Min = 16, Max = 200, Default = 16, Flag = "walkspeed" })
  tab:AddSection("Actions")
  tab:AddButton({ Text = "Execute", Variant = "default", Icon = "play",
    Callback = function() window:ShowSuccess({ Title = "Executed", Message = "Script ran." }) end })
  tab:AddSeparator()
  tab:AddButton({ Text = "Reset to Defaults", Variant = "destructive", Action = "ResetConfig" })
end
