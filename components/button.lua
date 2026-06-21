-- Deps injected via Init(R).
local Button = {}
local Create, DefaultTheme, Animate, Maid, Icons

function Button.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid; Icons = R.Icons
end

local function palette(theme, variant)
  if variant == "destructive" then return theme.Colors.destructive, theme.Colors.primaryForeground, nil end
  if variant == "secondary" then return theme.Colors.surface, theme.Colors.foreground, nil end
  if variant == "outline" then return theme.Colors.card, theme.Colors.foreground, theme.Colors.border end
  if variant == "ghost" then return theme.Colors.card, theme.Colors.foreground, nil end
  return theme.Colors.primary, theme.Colors.primaryForeground, nil -- default
end

function Button.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local variant = opts.Variant or "default"
  local maid = Maid.new()
  local bg, fg, stroke = palette(theme, variant)
  local transparent = (variant == "ghost")

  local btn = Create("TextButton", {
    Name = "Button",
    AutoButtonColor = false,
    Text = "",
    BackgroundColor3 = bg,
    BackgroundTransparency = transparent and 1 or 0,
    Size = UDim2.new(1, 0, 0, 34),
    LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent,
    Create.corner(theme.Radius.md),
  })
  if stroke then Create("UIStroke", { Color = stroke, Thickness = 1, Parent = btn }) end

  local hasIcon = opts.Icon ~= nil
  if hasIcon then
    local img = Create("ImageLabel", {
      Name = "Icon", BackgroundTransparency = 1,
      Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.5, -44, 0.5, -8),
      Parent = btn,
    })
    Icons.apply(img, opts.Icon, fg)
  end
  local label = Create("TextLabel", {
    Name = "Label", BackgroundTransparency = 1,
    Text = opts.Text or "Button", TextColor3 = fg, TextSize = theme.Font.label.Size,
    Font = Enum.Font.BuilderSans, Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, hasIcon and 12 or 0, 0, 0),
    Parent = btn,
  })

  maid:Give(btn.MouseEnter:Connect(function()
    Animate.to(btn, "fast", { BackgroundTransparency = transparent and 0.92 or 0.12 })
  end))
  maid:Give(btn.MouseLeave:Connect(function()
    Animate.to(btn, "fast", { BackgroundTransparency = transparent and 1 or 0 })
  end))
  maid:Give(btn.MouseButton1Click:Connect(function()
    if opts.Action == "ResetConfig" and opts.Window then opts.Window:ResetConfiguration() end
    if opts.Callback then opts.Callback() end
  end))
  maid:Give(btn)

  return {
    Frame = btn,
    SetText = function(s) label.Text = s end,
    SetEnabled = function(en) btn.Active = en; label.TextColor3 = en and fg or theme.Colors.mutedForeground end,
    Destroy = function() maid:DoCleanup() end,
  }
end

return Button
