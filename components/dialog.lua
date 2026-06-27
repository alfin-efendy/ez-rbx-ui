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

-- Header: a left-aligned Title. (Icon shapes added in Task 3.) Returns whether the header is
-- centred so the message can match its alignment.
local function buildHeader(card, theme, opts)
  Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title or "Dialog",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.title.Size,
    Font = Enum.Font.BuilderSans, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, ZIndex = 1502, Parent = card })
  return false
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
