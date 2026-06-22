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

  local hasDesc = opts.Description ~= nil and opts.Description ~= ""
  local rowH = hasDesc and 50 or 34

  local btn = Create("TextButton", {
    Name = "Toggle", AutoButtonColor = false, Text = "",
    BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = 0,
    Size = UDim2.new(1, 0, 0, rowH), LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent,
    Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX,
      top = hasDesc and 8 or 0, bottom = hasDesc and 8 or 0 }),
  })
  Create("TextLabel", {
    Name = "Label", BackgroundTransparency = 1, Text = opts.Text or "Toggle",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = hasDesc and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
    TextSize = theme.Font.label.Size, Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, -54, hasDesc and 0 or 1, hasDesc and 18 or 0), Parent = btn,
  })
  if hasDesc then
    Create("TextLabel", { Name = "Description", BackgroundTransparency = 1, Text = opts.Description,
      TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
      TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      Position = UDim2.new(0, 0, 0, 18), Size = UDim2.new(1, -54, 0, 18), Parent = btn })
  end
  local track = Create("Frame", {
    Name = "Track", BackgroundColor3 = theme.Colors.switchTrackOff, BorderSizePixel = 0,
    Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -44, 0.5, -12),
    Parent = btn, Create.corner(12),
  })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = track })
  local knob = Create("Frame", {
    Name = "Knob", BackgroundColor3 = theme.Colors.foreground, BorderSizePixel = 0,
    Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 2, 0.5, -10),
    Parent = track, Create.corner(10),
  })

  local function apply(v)
    value = v and true or false
    Animate.to(track, "fast", { BackgroundColor3 = value and theme.Colors.primary or theme.Colors.switchTrackOff })
    Animate.to(knob, "fast", {
      Position = value and UDim2.new(0, 22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
      BackgroundColor3 = value and theme.Colors.primaryForeground or theme.Colors.foreground,
    })
  end

  local commit = Flag.bind(opts, opts.Default == true, apply)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    btn.BackgroundColor3 = theme.Colors.surface
    local lab = btn:FindFirstChild("Label"); if lab then lab.TextColor3 = theme.Colors.foreground end
    local d = btn:FindFirstChild("Description"); if d then d.TextColor3 = theme.Colors.mutedForeground end
    local st = track:FindFirstChildOfClass("UIStroke"); if st then st.Color = theme.Colors.border end
    apply(value)
  end)) end

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
