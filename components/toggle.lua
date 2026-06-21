-- Deps injected via Init(R).
local Toggle = {}
local Create, DefaultTheme, Animate, Maid, Flag

function Toggle.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid; Flag = R.Flag
end

function Toggle.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local value = false
  local onChanged

  local btn = Create("TextButton", {
    Name = "Toggle", AutoButtonColor = false, Text = "",
    BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = 0,
    Size = UDim2.new(1, 0, 0, 34), LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent,
    Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }),
  })
  Create("TextLabel", {
    Name = "Label", BackgroundTransparency = 1, Text = opts.Text or "Toggle",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = theme.Font.label.Size, Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, -50, 1, 0), Parent = btn,
  })
  local track = Create("Frame", {
    Name = "Track", BackgroundColor3 = theme.Colors.switchTrackOff,
    Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -36, 0.5, -10),
    Parent = btn, Create.corner(10),
  })
  local knob = Create("Frame", {
    Name = "Knob", BackgroundColor3 = theme.Colors.foreground,
    Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8),
    Parent = track, Create.corner(8),
  })

  local function apply(v)
    value = v and true or false
    Animate.to(track, "fast", { BackgroundColor3 = value and theme.Colors.primary or theme.Colors.switchTrackOff })
    Animate.to(knob, "fast", { Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) })
  end

  local commit = Flag.bind(opts, opts.Default == true, apply)

  local api = { Frame = btn }
  function api.Get() return value end
  function api.Set(v)
    commit(v and true or false)
    if opts.Callback then opts.Callback(value) end
    if onChanged then onChanged(value) end
  end
  function api.OnChanged(fn) onChanged = fn end
  function api.Destroy() maid:DoCleanup() end

  maid:Give(btn.MouseButton1Click:Connect(function() api.Set(not value) end))
  maid:Give(btn)
  return api
end

return Toggle
