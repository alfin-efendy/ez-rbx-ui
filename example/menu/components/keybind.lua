return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Keybind", Icon = "keyboard" })
  tab:AddSection("Basic")
  tab:AddKeybind({ Text = "Action key", Default = Enum.KeyCode.E, Callback = function() print("keybind pressed") end })
  tab:AddSection("Persistence (Flag)")
  tab:AddKeybind({ Text = "Saved bind", Flag = "ex_keybind", Default = Enum.KeyCode.F })
  tab:AddParagraph("Click to rebind; Flag-bound keybinds auto-save and restore.")
end
