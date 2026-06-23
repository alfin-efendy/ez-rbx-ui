return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Paragraph", Icon = "align-left" })
  tab:AddSection("Paragraph")
  tab:AddParagraph("Paragraphs wrap long text across multiple lines and auto-size their height. Use them for descriptions, changelogs, and help text within a tab.")
  tab:AddSection("Multi-line (explicit breaks)")
  tab:AddParagraph("Changelog v3.1\n• Ratio is now a fraction of the screen (e.g. { Width = 0.4, Height = 0.55 })\n• New StartHidden option to load collapsed to the floating toggle\n• Bug fixes and polish")
  local notes = tab:AddParagraph("Notes: a paragraph honors explicit \\n line breaks and also wraps automatically — combine both for changelogs and release notes.")
  tab:AddButton({ Text = "Add a note line", Callback = function()
    notes.SetText(notes.Frame.Text .. "\n• Appended at runtime")
  end })

  tab:AddSection("Live status (function-valued, auto-updating)")
  -- A paragraph whose text is a FUNCTION: EzUI re-evaluates it every interval and updates itself.
  -- Being multi-line, it's a natural live status block (clock + uptime + countdown) -- no manual
  -- loop, capability-safe, one shared scheduler. Use { Text = fn, Interval = n } to set the cadence.
  local started = os.time()
  tab:AddParagraph(function()
    local up = os.time() - started
    local left = 30 - up % 31                       -- counts 30 -> 0, then loops
    return "Clock:     " .. os.date("%H:%M:%S")
      .. "\nUptime:    " .. up .. "s"
      .. "\nCountdown: " .. (left > 0 and (left .. "s") or "done, restarting")
  end)

  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddParagraph("Nested paragraph text.")
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddParagraph("Nested paragraph text.")
end
