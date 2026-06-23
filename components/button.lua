-- Deps injected via Init(R).
local Button = {}
local Create, DefaultTheme, Animate, Maid, Icons, Safe

function Button.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid; Icons = R.Icons; Safe = R.Safe
end

local function palette(theme, variant)
  if variant == "destructive" then return theme.Colors.destructive, theme.Colors.primaryForeground, nil end
  if variant == "secondary" then return theme.Colors.surface, theme.Colors.foreground, nil end
  if variant == "outline" then return theme.Colors.card, theme.Colors.foreground, theme.Colors.border end
  if variant == "ghost" then return theme.Colors.surface, theme.Colors.foreground, nil end
  return theme.Colors.primary, theme.Colors.primaryForeground, nil -- default
end

function Button.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local variant = opts.Variant or "default"
  local maid = Maid.new()
  local bg, fg, stroke = palette(theme, variant)
  local transparent = (variant == "ghost")

  -- btn: fixed-size hit area, laid out by UIListLayout. It never scales, so the press
  -- animation can't change its AbsoluteSize and siblings never reflow.
  local btn = Create("TextButton", {
    Name = "Button", AutoButtonColor = false, Text = "",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 34), LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent,
  })
  -- surface: the visible button. Centred (AnchorPoint 0.5) so the press UIScale shrinks
  -- toward the middle; Active=false so clicks fall through to btn.
  local surface = Create("Frame", {
    Name = "Surface", BackgroundColor3 = bg, BackgroundTransparency = transparent and 1 or 0,
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 0, 1, 0), Active = false, Parent = btn,
    Create.corner(theme.Radius.md),
  })
  local scale = Create("UIScale", { Scale = 1, Parent = surface })
  if stroke then Create("UIStroke", { Color = stroke, Thickness = 1, Parent = surface }) end

  local hovering = false
  local bgNormal = transparent and 1 or 0
  -- ghost rests fully transparent; on hover/press it reveals a clearly-visible muted 'surface'
  -- wash (its palette bg is surface, not card -- card matched the panel behind it and looked
  -- dead). Kept lighter than 'secondary' (a full opaque surface fill) so it still reads as ghost.
  local bgHover = transparent and 0.4 or 0.12
  local bgPressed = transparent and 0.25 or 0.2

  local hasIcon = opts.Icon ~= nil
  if hasIcon then
    local img = Create("ImageLabel", {
      Name = "Icon", BackgroundTransparency = 1,
      Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.5, -44, 0.5, -8),
      Parent = surface,
    })
    Icons.apply(img, opts.Icon, fg)
  end
  local label = Create("TextLabel", {
    Name = "Label", BackgroundTransparency = 1,
    Text = opts.Text or "Button", TextColor3 = fg, TextSize = theme.Font.label.Size,
    Font = Enum.Font.BuilderSans, Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, hasIcon and 12 or 0, 0, 0),
    Parent = surface,
  })

  maid:Give(btn.MouseEnter:Connect(function()
    hovering = true
    Animate.to(surface, "fast", { BackgroundTransparency = bgHover })
  end))
  maid:Give(btn.MouseLeave:Connect(function()
    hovering = false
    Animate.to(surface, "fast", { BackgroundTransparency = bgNormal })
    Animate.to(scale, "fast", { Scale = 1 })
  end))
  maid:Give(btn.MouseButton1Down:Connect(function()
    Animate.to(scale, "fast", { Scale = 0.97 })
    Animate.to(surface, "fast", { BackgroundTransparency = bgPressed })
  end))
  maid:Give(btn.MouseButton1Up:Connect(function()
    Animate.to(scale, "base", { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Animate.to(surface, "fast", { BackgroundTransparency = hovering and bgHover or bgNormal })
  end))
  maid:Give(btn.MouseButton1Click:Connect(function()
    if opts.Action == "ResetConfig" and opts.Window and opts.Window.ResetConfiguration then opts.Window:ResetConfiguration() end
    if opts.Callback then opts.Callback() end
  end))
  maid:Give(btn)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    local nbg, nfg, nstroke = palette(theme, variant)
    if not transparent then surface.BackgroundColor3 = nbg end
    label.TextColor3 = nfg
    if hasIcon then Icons.apply(surface:FindFirstChild("Icon"), opts.Icon, nfg) end
    local st = surface:FindFirstChildOfClass("UIStroke"); if st and nstroke then st.Color = nstroke end
  end)) end

  return {
    Frame = btn,
    SetText = function(s) Safe.mutate(function() label.Text = s end) end,
    SetEnabled = function(en)
      btn.Active = en
      Safe.mutate(function() label.TextColor3 = en and fg or theme.Colors.mutedForeground end)
    end,
    Destroy = function() maid:DoCleanup() end,
  }
end

return Button
