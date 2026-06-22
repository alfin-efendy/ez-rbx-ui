return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "TextBox", Icon = "type" })

  tab:AddSection("Basic")
  tab:AddTextBox({ Text = "Name", Placeholder = "Type your name…" })
  tab:AddTextBox({ Text = "With description", Description = "Helper text under the label.", Placeholder = "…" })
  tab:AddTextBox({ Text = "Key", Default = "EZUI-DEMO", Copyable = true })

  tab:AddSection("Input group — icons & affixes")
  -- leading decorative icon
  tab:AddTextBox({ Text = "Search", LeadingIcon = "search", Placeholder = "Filter…" })
  -- text prefix + suffix (FullWidth gives the addons room: label on top, box below)
  tab:AddTextBox({ Text = "Website", FullWidth = true, LeadingIcon = "link",
    Prefix = "https://", Suffix = ".com", Placeholder = "your-site" })
  tab:AddTextBox({ Text = "Price", Prefix = "$", Suffix = "USD", Placeholder = "0.00" })

  tab:AddSection("Input group — buttons")
  -- clearable (✕ appears when non-empty) + a copy icon-button; Callback gets the current text
  tab:AddTextBox({ Text = "Token", Default = "sk-demo-123", Clearable = true,
    Buttons = { { Icon = "copy", Tooltip = "Copy", Callback = function(text)
      if setclipboard then pcall(setclipboard, text) end
      window:ShowSuccess({ Title = "Copied", Message = text })
    end } } })
  -- text button; ctl is the control table (Clear/SetText/SetLoading/…)
  tab:AddTextBox({ Text = "Message", FullWidth = true, LeadingIcon = "mail", Placeholder = "Say something…",
    Buttons = { { Text = "Send", Variant = "default", Callback = function(text, ctl)
      window:ShowSuccess({ Title = "Sent", Message = text ~= "" and text or "(empty)" })
      ctl.Clear()
    end } } })

  tab:AddSection("Password")
  -- masked value + eye/eye-off toggle; GetText() still returns the real value
  tab:AddTextBox({ Text = "Password", LeadingIcon = "lock", Password = true, Placeholder = "••••••••" })

  tab:AddSection("States")
  -- live validation: Validate(text) -> (ok, message); shows a red border + message when invalid
  tab:AddTextBox({ Text = "Email", FullWidth = true, LeadingIcon = "mail", Placeholder = "you@example.com",
    Validate = function(t) return t:match("^[^@%s]+@[^@%s]+%.[^@%s]+$") ~= nil, "Enter a valid email address" end })
  -- loading spinner + invalid/valid driven from a button callback
  tab:AddTextBox({ Text = "Username", LeadingIcon = "user", Placeholder = "pick a handle",
    Buttons = { { Icon = "check", Tooltip = "Check availability", Callback = function(text, ctl)
      ctl.SetLoading(true)
      task.delay(0.8, function()
        ctl.SetLoading(false)
        if #text > 2 then ctl.SetValid() else ctl.SetInvalid("Too short") end
      end)
    end } } })
  -- disabled: non-editable + muted
  tab:AddTextBox({ Text = "Locked", Default = "read-only", Disabled = true })

  tab:AddSection("Persistence (Flag)")
  tab:AddTextBox({ Text = "Saved note", Flag = "ex_textbox", Default = "hello" })
  tab:AddParagraph("Flag-bound controls auto-save to the config file and restore on next load.")

  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddTextBox({ Text = "Nested", Placeholder = "…" })
  acc:AddTextBox({ Text = "Nested search", LeadingIcon = "search", Clearable = true, Placeholder = "…" })
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddTextBox({ Text = "Nested", Placeholder = "…" })
end
