-- Deps injected via Init(R). Dialog.open(opts) builds a modal alert dialog in the overlay.
-- Mirrors shadcn AlertDialog: modal, non-dismissible (no backdrop-click dismissal, no X button) --
-- the user picks a footer button. Optional header icon (inline / badge), a device-aware footer, and
-- open/close motion are layered on by the builders below.
local Dialog = {}
local Create, DefaultTheme, Maid, Overlay, Button, Acrylic, Animate, Icons, Device
function Dialog.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Overlay = R.Overlay; Button = R.Button; Acrylic = R.Acrylic
  Animate = R.Animate; Icons = R.Icons; Device = R.Device
end

local MARGIN = 24 -- min gap between the card and the edge of its container when clamping width

-- Card width: opts.Width (default 320), clamped to the container width minus margins when known.
local function resolveWidth(opts)
  local want = opts.Width or 320
  local avail
  if opts.Window and opts.Window.Main then
    local s = opts.Window.Main.AbsoluteSize; avail = s and s.X
  else
    local vp = Overlay.viewport(); avail = vp and vp.X
  end
  if avail and avail > 0 then
    local max = avail - MARGIN * 2
    if max > 0 and want > max then want = max end
  end
  return want
end

-- Header: one of three shapes -- badge (icon square above a centred title), inline (small icon left
-- of the title), or a plain left-aligned title. Returns whether the header is centred so the
-- message can match its alignment.
local function buildHeader(card, theme, opts)
  local iconColor = opts.IconColor or theme.Colors.foreground
  if opts.Icon and opts.IconBadge then
    local header = Create("Frame", { Name = "Header", BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, ZIndex = 1502, Parent = card })
    Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, theme.Spacing.gap),
      HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Parent = header })
    local badge = Create("Frame", { Name = "IconBadge", BackgroundColor3 = theme.Colors.surface,
      Size = UDim2.new(0, 40, 0, 40), LayoutOrder = 1, ZIndex = 1502, Parent = header, Create.corner(theme.Radius.md) })
    local img = Create("ImageLabel", { Name = "Icon", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 20, 0, 20), ZIndex = 1503, Parent = badge })
    Icons.apply(img, opts.Icon, iconColor)
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title or "Dialog",
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Center, TextSize = theme.Font.title.Size,
      Font = Enum.Font.BuilderSans, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 2, ZIndex = 1502, Parent = header })
    return true
  elseif opts.Icon then
    local gap = theme.Spacing.icon
    local header = Create("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
      LayoutOrder = 1, ZIndex = 1502, Parent = card })
    local img = Create("ImageLabel", { Name = "Icon", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5),
      Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 16, 0, 16), ZIndex = 1502, Parent = header })
    Icons.apply(img, opts.Icon, iconColor)
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title or "Dialog",
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.title.Size,
      Font = Enum.Font.BuilderSans, Position = UDim2.new(0, 16 + gap, 0, 0), Size = UDim2.new(1, -(16 + gap), 1, 0),
      ZIndex = 1502, Parent = header })
    return false
  else
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title or "Dialog",
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.title.Size,
      Font = Enum.Font.BuilderSans, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, ZIndex = 1502, Parent = card })
    return false
  end
end

-- Footer: a horizontal row of buttons. Each button fires its descriptor callback then closes.
-- (Device-aware layout added in Task 4; `touch` is accepted now so the signature is stable.)
local function buildFooter(card, theme, buttons, touch, handle, maid)
  local row = Create("Frame", { Name = "Buttons", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34),
    LayoutOrder = 3, ZIndex = 1502, Parent = card,
    Create.listLayout({ Padding = theme.Spacing.gap, FillDirection = Enum.FillDirection.Horizontal }) })
  for i, b in ipairs(buttons) do
    local btn = Button.new({ Parent = row, LayoutOrder = i, Theme = theme, Text = b.Text or "OK", Variant = b.Variant,
      Callback = function() if b.Callback then b.Callback() end; handle.Close() end })
    btn.Frame.Size = UDim2.new(0, 96, 1, 0)
    maid:Give(btn)
  end
end

function Dialog.open(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local buttons = opts.Buttons or { { Text = "OK" } }
  local handle = {}
  local touch = Device and Device.IsTouch() or false
  local width = resolveWidth(opts)

  local dim = Create("TextButton", { Name = "Dialog", AutoButtonColor = false, Text = "",
    BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = (opts.Modal == false) and 1 or 0.5,
    Size = UDim2.new(1, 0, 1, 0), ZIndex = 1500, Modal = opts.Modal ~= false })
  local card = Create("Frame", { Name = "Card", Size = UDim2.new(0, width, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 1501, Parent = dim,
    Create.corner(theme.Radius.lg), Create.padding({ all = theme.Spacing.pad }),
    Create.listLayout({ Padding = theme.Spacing.gap }) })
  Acrylic.decorate(card, theme, { solid = true })

  local centered = buildHeader(card, theme, opts)
  if opts.Message then
    Create("TextLabel", { Name = "Message", BackgroundTransparency = 1, Text = opts.Message,
      TextColor3 = theme.Colors.mutedForeground,
      TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left, TextWrapped = true,
      TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans,
      Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 1502, Parent = card })
  end

  function handle.Close() maid:DoCleanup(); dim:Destroy() end
  buildFooter(card, theme, buttons, touch, handle, maid)

  maid:Give(dim)
  -- Scope the backdrop to the owning window when one is given (its api exposes .Main), so the
  -- scrim covers only the window frame (rounded to match it). Standalone dialogs fall back to the
  -- global screen overlay, shared with dropdowns/colorpickers that want the full screen.
  local winFrame = opts.Window and opts.Window.Main
  if winFrame then
    Create.corner(theme.Radius.window).Parent = dim
    dim.Parent = winFrame
  else
    Overlay.mount(dim)
  end
  Animate.pop(card, "base") -- pop the card in
  return handle
end

return Dialog
