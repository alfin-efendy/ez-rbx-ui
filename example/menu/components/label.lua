return function(window, host)
  host = host or window
  local tab = host:AddTab({ Name = "Label", Icon = "type" })
  tab:AddSection("Variants")
  tab:AddLabel("Default label")
  tab:AddSection("Section heading (uppercased)")
  local dyn = tab:AddLabel("Click the button to change me")
  tab:AddButton({ Text = "Set text", Callback = function() dyn.SetText("Updated at runtime!") end })
  tab:AddParagraph("Labels support default + section variants and a SetText API for dynamic text.")
  tab:AddSection("Multi-line")
  tab:AddLabel("Default labels are single-line (extra lines get clipped).")
  -- For multiple lines in a label, use the paragraph variant: it wraps and auto-sizes its height,
  -- and honors explicit \n breaks.
  local multi = tab:AddLabel({ Variant = "paragraph",
    Text = "First line\nSecond line\nThird line — explicit \\n breaks plus automatic wrapping when a line is too long to fit on screen." })
  tab:AddButton({ Text = "Append a line", Callback = function()
    multi.SetText(multi.Frame.Text .. "\nAdded at runtime!")
  end })

  tab:AddSection("Live value (function-valued, auto-updating)")
  -- Pass a FUNCTION instead of a string: EzUI re-evaluates it on an interval (default 1s) and
  -- updates the label itself -- no manual loop, no SetText calls. One shared scheduler drives every
  -- reactive label, and it's capability-safe. Ideal for clocks, countdowns, timers, score/FPS, etc.
  tab:AddLabel(function() return "Clock: " .. os.date("%H:%M:%S") end)
  local started = os.time()
  tab:AddLabel(function()
    local left = 10 - (os.time() - started) % 11      -- counts 10 -> 0, then loops
    return left > 0 and ("Countdown: " .. left .. "s") or "Countdown: liftoff!"
  end)
  -- The opts form lets you pick the cadence with Interval (seconds):
  tab:AddLabel({ Text = function() return "Uptime: " .. (os.time() - started) .. "s" end, Interval = 1 })

  local acc = tab:AddAccordion({ Title = "Inside an accordion", Icon = "rows-3", Expanded = false })
  acc:AddLabel("Nested label")
  local acc2 = tab:AddAccordion({ Title = "Expanded by default", Icon = "rows-3", Expanded = true })
  acc2:AddLabel("Nested label")
end
