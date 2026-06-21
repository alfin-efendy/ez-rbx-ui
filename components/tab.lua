-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local Tab = {}
local Create, DefaultTheme, Animate, Maid, Icons, Accordion, Host, REG

function Tab.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate
  Maid = R.Maid; Icons = R.Icons; Accordion = R.Accordion; Host = R.Host; REG = R
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
  local indicator = Create("Frame", {
    Name = "Active", BackgroundColor3 = theme.Colors.primary, BorderSizePixel = 0,
    Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, -4, 0.5, -9), Visible = false, ZIndex = 2,
    Parent = button, Create.corner(2),
  })
  local icon = Create("ImageLabel", {
    Name = "Icon",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(0, 0, 0.5, -8),
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
    Size = UDim2.new(1, opts.Icon and -26 or 0, 1, 0),
    Position = UDim2.new(0, opts.Icon and 26 or 0, 0, 0),
    Parent = button,
  })

  -- content (CanvasGroup for cross-fade)
  local content = Create("CanvasGroup", {
    Name = "TabContent",
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Visible = false,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = opts.ContentParent,
    Create.listLayout({ Padding = theme.Spacing.gap }),
    Create.padding({ all = theme.Spacing.pad }),
  })

  local api = { Button = button, Content = content, Maid = maid }

  function api:IsSelected() return selected end

  function api:Select()
    selected = true
    indicator.Visible = true
    -- slide up + fade in (visible tab-switch transition)
    content.GroupTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 10)
    content.Visible = true
    Animate.to(content, "base", { GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0) })
    button.BackgroundTransparency = 0
    Animate.to(button, "fast", { BackgroundColor3 = theme.Colors.surface })
    label.TextColor3 = theme.Colors.foreground
    if opts.Icon then Icons.apply(icon, opts.Icon, theme.Colors.foreground) end
  end

  function api:Deselect()
    selected = false
    indicator.Visible = false
    local tw = Animate.to(content, "fast", { GroupTransparency = 1 })
    tw.Completed:Connect(function() if not selected then content.Visible = false end end)
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
    nextOrder = function() order = order + 1; return order end,
  })

  if opts.AccentThemer then maid:Give(opts.AccentThemer.register(function() indicator.BackgroundColor3 = theme.Colors.primary end)) end

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
    return Accordion.new(accOpts)
  end

  function api:SetIcon(name) opts.Icon = name; Icons.apply(icon, name, selected and theme.Colors.foreground or theme.Colors.mutedForeground); icon.Visible = true end
  function api:SetTitle(s) label.Text = s end

  maid:Give(button.MouseButton1Click:Connect(function() if opts.OnActivate then opts.OnActivate(api) end end))
  maid:Give(button)
  maid:Give(content)
  function api.Destroy() maid:DoCleanup() end

  return api
end

return Tab
