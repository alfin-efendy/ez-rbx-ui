-- Deps injected via Init(R). A rich content card: optional banner image, title,
-- body paragraph, and an optional row of action buttons. Built from primitives.
local Card = {}
local Create, DefaultTheme, Maid, Asset, Button

function Card.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Asset = R.Asset; Button = R.Button
end

function Card.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()

  local card = Create("Frame", { Name = "Card", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0,
    AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent, Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX, top = theme.Spacing.inputY, bottom = theme.Spacing.inputY }),
    Create.listLayout({ Padding = theme.Spacing.gap }) })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = card })

  local lo = 0
  local resolved = Asset.image(opts.Banner)
  if resolved then
    lo = lo + 1
    Create("ImageLabel", { Name = "Banner", BackgroundColor3 = theme.Colors.surface, BorderSizePixel = 0,
      Image = resolved, ScaleType = Enum.ScaleType.Crop, Size = UDim2.new(1, 0, 0, 80), LayoutOrder = lo,
      Parent = card, Create.corner(theme.Radius.sm) })
  end
  if opts.Title then
    lo = lo + 1
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title, TextColor3 = theme.Colors.foreground,
      TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.label.Size, Font = Enum.Font.BuilderSans,
      Size = UDim2.new(1, 0, 0, 18), LayoutOrder = lo, Parent = card })
  end
  if opts.Body then
    lo = lo + 1
    Create("TextLabel", { Name = "Body", BackgroundTransparency = 1, Text = opts.Body, TextColor3 = theme.Colors.mutedForeground,
      TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
      AutomaticSize = Enum.AutomaticSize.Y, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      Size = UDim2.new(1, 0, 0, 0), LayoutOrder = lo, Parent = card })
  end
  if opts.Buttons and #opts.Buttons > 0 then
    lo = lo + 1
    local row = Create("Frame", { Name = "Actions", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34),
      LayoutOrder = lo, Parent = card,
      Create.listLayout({ Padding = theme.Spacing.gap, FillDirection = Enum.FillDirection.Horizontal }) })
    for i, b in ipairs(opts.Buttons) do
      local control = Button.new({ Parent = row, Text = b.Text, Variant = b.Variant, Callback = b.Callback,
        Theme = theme, LayoutOrder = i })
      control.Frame.Size = UDim2.new(0, 96, 1, 0)
      maid:Give(control.Frame)
    end
  end

  maid:Give(card)
  return { Frame = card, Destroy = function() maid:DoCleanup() end }
end

return Card
