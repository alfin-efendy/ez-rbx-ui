-- Deps injected via Init(R). Dialog.open(opts) builds a modal/non-modal dialog in the overlay.
local Dialog = {}
local Create, DefaultTheme, Maid, Overlay, Button, Acrylic, Animate
function Dialog.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Overlay = R.Overlay; Button = R.Button; Acrylic = R.Acrylic
  Animate = R.Animate
end

function Dialog.open(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local buttons = opts.Buttons or { { Text = "OK" } }
  local handle = {}

  local dim = Create("TextButton", { Name = "Dialog", AutoButtonColor = false, Text = "",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = (opts.Modal == false) and 1 or 0.5,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = 1500, Modal = opts.Modal ~= false })
  local card = Create("Frame", { Name = "Card", Size = UDim2.new(0, 320, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.new(0.5, -160, 0.5, -80), ZIndex = 1501, Parent = dim,
    Create.corner(theme.Radius.lg), Create.padding({ all = theme.Spacing.pad }),
    Create.listLayout({ Padding = theme.Spacing.gap }) })
  Acrylic.decorate(card, theme, { solid = true })
  Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title or "Dialog",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.title.Size,
    Font = Enum.Font.BuilderSans, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, ZIndex = 1502, Parent = card })
  if opts.Message then
    Create("TextLabel", { Name = "Message", BackgroundTransparency = 1, Text = opts.Message,
      TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
      TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans,
      Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 1502, Parent = card })
  end
  local row = Create("Frame", { Name = "Buttons", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34),
    LayoutOrder = 3, ZIndex = 1502, Parent = card,
    Create.listLayout({ Padding = theme.Spacing.gap, FillDirection = Enum.FillDirection.Horizontal }) })

  function handle.Close() maid:DoCleanup(); dim:Destroy() end
  for i, b in ipairs(buttons) do
    local btn = Button.new({ Parent = row, LayoutOrder = i, Theme = theme, Text = b.Text or "OK", Variant = b.Variant,
      Callback = function() if b.Callback then b.Callback() end; handle.Close() end })
    btn.Frame.Size = UDim2.new(0, 96, 1, 0)
    maid:Give(btn)
  end
  maid:Give(dim)
  Overlay.mount(dim)
  Animate.pop(card, "base") -- pop the card in
  return handle
end

return Dialog
