-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local Tab = {}
local Create, DefaultTheme, Animate, Maid, Icons, Accordion, Host, REG, Safe

function Tab.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate
  Maid = R.Maid; Icons = R.Icons; Accordion = R.Accordion; Host = R.Host; REG = R; Safe = R.Safe
end

function Tab.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local order = 0
  local selected = false

  -- sidebar button
  local button = Create("TextButton", {
    Name = "TabButton",
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = theme.Colors.surface,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 34),
    LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.SidebarParent,
    Create.corner(theme.Radius.md),
    Create.padding({ left = 10, right = 10 }),
  })
  local icon = Create("ImageLabel", {
    Name = "Icon",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(0, 4, 0.5, -8),
    Parent = button,
  })
  if opts.Icon then Icons.apply(icon, opts.Icon, theme.Colors.mutedForeground) else icon.Visible = false end
  local label = Create("TextLabel", {
    Name = "Label",
    BackgroundTransparency = 1,
    Text = opts.Name or "Tab",
    TextColor3 = theme.Colors.mutedForeground,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = theme.Font.label.Size,
    Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, opts.Icon and -30 or -6, 1, 0),
    Position = UDim2.new(0, opts.Icon and 30 or 6, 0, 0),
    Parent = button,
  })

  -- content (plain Frame + slide transition; NOT a CanvasGroup, so a focused TextBox's
  -- caret/selection renders — CanvasGroups composite children to a buffer that omits
  -- the caret overlay, which made text cursors invisible/non-blinking).
  local content = Create("Frame", {
    Name = "TabContent",
    BackgroundTransparency = 1,
    Visible = false,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = opts.ContentParent,
    Create.listLayout({ Padding = theme.Spacing.gap }),
    Create.padding({ all = theme.Spacing.pad }),
  })

  -- Drive the parent ScrollingFrame's CanvasSize explicitly from this tab's content height.
  -- AutomaticCanvasSize is unreliable here because the CanvasGroup starts hidden (measured 0).
  local contentLayout = content:FindFirstChildOfClass("UIListLayout")
  local contentPad = theme.Spacing.pad
  -- carousel travel distance = the visible panel height (so a switch reads as a full page swap);
  -- fall back to a sensible constant before the scroll frame has an AbsoluteSize (first paint / headless)
  local function panelH()
    local sf = content.Parent
    local s = sf and sf.AbsoluteSize
    return (s and s.Y and s.Y > 0 and s.Y) or 360
  end
  local function syncCanvas()
    local sf = content.Parent
    if selected and sf then
      local acs = contentLayout.AbsoluteContentSize
      sf.CanvasSize = UDim2.new(0, 0, 0, ((acs and acs.Y) or 0) + contentPad * 2)
    end
  end
  maid:Give(contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncCanvas))

  local api = { Button = button, Content = content, Maid = maid }

  function api:IsSelected() return selected end

  -- vertical carousel: the incoming page slides in from sign*panelH, the outgoing exits to
  -- -sign*panelH, both in sync — so the two pages move as one filmstrip, never colliding.
  -- dir +1 = navigating to a later tab (filmstrip scrolls up); -1 = earlier tab (scrolls down).
  function api:Select(dir)
    selected = true
    local sign = (dir == -1) and -1 or 1
    content.Position = UDim2.new(0, 0, 0, sign * panelH())
    content.Visible = true
    if content.Parent then content.Parent.CanvasPosition = Vector2.new(0, 0) end
    syncCanvas()
    Animate.to(content, "slow", { Position = UDim2.new(0, 0, 0, 0) }, Animate.EASING.smooth)
    button.BackgroundTransparency = 0
    Animate.to(button, "fast", { BackgroundColor3 = theme.Colors.surface })
    label.TextColor3 = theme.Colors.foreground
    if opts.Icon then Icons.apply(icon, opts.Icon, theme.Colors.foreground) end
  end

  function api:Deselect(dir)
    if not selected then content.Visible = false; return end  -- already inactive: nothing to animate out
    selected = false
    local sign = (dir == -1) and -1 or 1
    Animate.toThen(content, "slow", { Position = UDim2.new(0, 0, 0, -sign * panelH()) }, function()
      if not selected then content.Visible = false; content.Position = UDim2.new(0, 0, 0, 0) end
    end)
    button.BackgroundTransparency = 1
    label.TextColor3 = theme.Colors.mutedForeground
    if opts.Icon then Icons.apply(icon, opts.Icon, theme.Colors.mutedForeground) end
  end

  function api.MountRow(child)
    order = order + 1
    child.LayoutOrder = order
    child.Parent = content
    return order
  end

  -- AddLabel/AddParagraph/AddSection/AddSeparator/AddButton/AddToggle/AddTextBox/
  -- AddNumberBox/AddSelectBox are provided by the Host mixin (below).
  Host.attach(api, {
    R = REG, content = content, theme = theme, config = opts.Config, window = opts.Window,
    registerSearchable = opts.RegisterSearchable, accentThemer = opts.AccentThemer,
    registerControl = opts.RegisterControl,
    nextOrder = function() order = order + 1; return order end,
  })

  if opts.AccentThemer then maid:Give(opts.AccentThemer.register(function()
    if selected then
      label.TextColor3 = theme.Colors.foreground
      Animate.to(button, "fast", { BackgroundColor3 = theme.Colors.surface })
      if opts.Icon then Icons.apply(icon, opts.Icon, theme.Colors.foreground) end
    else
      label.TextColor3 = theme.Colors.mutedForeground
      if opts.Icon then Icons.apply(icon, opts.Icon, theme.Colors.mutedForeground) end
    end
  end)) end

  function api:AddAccordion(accOpts)
    accOpts = accOpts or {}
    order = order + 1
    accOpts.Parent = content
    accOpts.LayoutOrder = order
    accOpts.Theme = theme
    accOpts.Config = opts.Config
    accOpts.Window = opts.Window
    accOpts.RegisterSearchable = opts.RegisterSearchable
    accOpts.AccentThemer = opts.AccentThemer
    accOpts.RegisterControl = opts.RegisterControl
    return Accordion.new(accOpts)
  end

  function api:SetIcon(name) opts.Icon = name; Safe.mutate(function() Icons.apply(icon, name, selected and theme.Colors.foreground or theme.Colors.mutedForeground); icon.Visible = true end) end
  function api:SetTitle(s) Safe.mutate(function() label.Text = s end) end

  maid:Give(button.MouseEnter:Connect(function()
    if not selected then Animate.to(button, "fast", { BackgroundTransparency = 0.92 }) end
  end))
  maid:Give(button.MouseLeave:Connect(function()
    if not selected then Animate.to(button, "fast", { BackgroundTransparency = 1 }) end
  end))
  maid:Give(button.MouseButton1Click:Connect(function() if opts.OnActivate then opts.OnActivate(api) end end))
  maid:Give(button)
  maid:Give(content)
  function api.Destroy() maid:DoCleanup() end

  return api
end

return Tab
