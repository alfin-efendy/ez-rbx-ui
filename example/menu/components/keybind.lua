return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Keybind", Icon = "keyboard" })
  tab:AddSection("Basic")
  tab:AddKeybind({ Text = "Action key", Default = Enum.KeyCode.E, Callback = function() print("keybind pressed") end })
  tab:AddKeybind({ Text = "With description", Description = "Click then press a key.", Default = Enum.KeyCode.Q })
  tab:AddSection("Persistence (Flag)")
  tab:AddKeybind({ Text = "Saved bind", Flag = "ex_keybind", Default = Enum.KeyCode.F })
  tab:AddParagraph("Click to rebind; Flag-bound keybinds auto-save and restore.")
  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddKeybind({ Text = "Nested", Default = Enum.KeyCode.G })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddKeybind({ Text = "Nested", Default = Enum.KeyCode.G })
end
