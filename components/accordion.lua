-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local Accordion = {}
local Create, DefaultTheme, Animate, Maid, Icons, Host, REG

function Accordion.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid; Icons = R.Icons
  Host = R.Host; REG = R
end

local HEADER_H = 34

function Accordion.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local expanded = opts.Expanded == true
  local order = 0

  local container = Create("Frame", {
    Name = "Accordion",
    BackgroundColor3 = theme.Colors.card,
    BackgroundTransparency = 0,
    ClipsDescendants = true,
    AutomaticSize = Enum.AutomaticSize.None,
    Size = UDim2.new(1, 0, 0, HEADER_H),
    LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent,
  })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = container })
  Create("UICorner", { CornerRadius = UDim.new(0, theme.Radius.md), Parent = container })

  local header = Create("TextButton", {
    Name = "Header",
    Text = "",
    AutoButtonColor = false,
    BackgroundColor3 = theme.Colors.card,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, HEADER_H),
    Parent = container,
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }),
  })

  local caret = Create("ImageLabel", {
    Name = "Caret",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(0, 0, 0.5, -8),
    Parent = header,
  })
  Icons.apply(caret, "chevron-right", theme.Colors.mutedForeground)

  local leadIcon
  if opts.Icon then
    leadIcon = Create("ImageLabel", { Name = "Icon", BackgroundTransparency = 1,
      Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 24, 0.5, -8), Parent = header })
    Icons.apply(leadIcon, opts.Icon, theme.Colors.foreground)
  end
  local titleX = opts.Icon and 46 or 24
  local title = Create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Text = opts.Title or "Section",
    TextColor3 = theme.Colors.foreground,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = theme.Font.label.Size,
    Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, -titleX, 1, 0),
    Position = UDim2.new(0, titleX, 0, 0),
    Parent = header,
  })

  local content = Create("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.Y,
    Size = UDim2.new(1, 0, 0, 0),
    Position = UDim2.new(0, 0, 0, HEADER_H + theme.Spacing.gap),
    Visible = expanded,
    Parent = container,
    Create.listLayout({ Padding = theme.Spacing.gap }),
    Create.padding({ left = theme.Spacing.inputY, right = theme.Spacing.inputY, bottom = theme.Spacing.inputY }),
  })
  local layout = content:FindFirstChildOfClass("UIListLayout")

  local divider = Create("Frame", {
    Name = "Divider", BackgroundColor3 = theme.Colors.border, BorderSizePixel = 0,
    Size = UDim2.new(1, -theme.Spacing.inputX * 2, 0, 1), Position = UDim2.new(0, theme.Spacing.inputX, 0, HEADER_H),
    Visible = expanded, ZIndex = 2, Parent = container,
  })

  local api = { Container = container, Header = header, Content = content, Maid = maid }

  local function contentHeight()
    -- real Roblox: UIListLayout.AbsoluteContentSize.Y; mock returns nil -> 0
    local acs = layout.AbsoluteContentSize
    local y = (acs and acs.Y) or 0
    return y + theme.Spacing.inputY
  end

  local function applyHeight(animated)
    local target = HEADER_H + (expanded and (theme.Spacing.gap + contentHeight()) or 0)
    if expanded then content.Visible = true; divider.Visible = true end
    if animated then
      local tw = Animate.to(container, "base", { Size = UDim2.new(1, 0, 0, target) })
      tw.Completed:Connect(function()
        if not expanded then content.Visible = false; divider.Visible = false end
      end)
    else
      container.Size = UDim2.new(1, 0, 0, target)
      content.Visible = expanded
      divider.Visible = expanded
    end
    Icons.apply(caret, expanded and "chevron-down" or "chevron-right", theme.Colors.mutedForeground)
  end

  function api:Toggle() expanded = not expanded; applyHeight(true); return expanded end
  function api:Expand() if not expanded then expanded = true; applyHeight(true) end end
  function api:Collapse() if expanded then expanded = false; applyHeight(true) end end
  function api:IsExpanded() return expanded end
  function api:SetTitle(s) title.Text = s end
  function api:SetIcon(name) if leadIcon then Icons.apply(leadIcon, name, theme.Colors.foreground) end end

  function api.MountRow(child)
    order = order + 1
    child.LayoutOrder = order
    child.Parent = content
    return order
  end

  -- AddX control methods (Label/Button/Toggle/TextBox/NumberBox/SelectBox/...)
  Host.attach(api, {
    R = REG, content = content, theme = theme, config = opts.Config, window = opts.Window,
    registerSearchable = opts.RegisterSearchable, accentThemer = opts.AccentThemer,
    registerControl = opts.RegisterControl,
    nextOrder = function() order = order + 1; return order end,
  })

  -- Re-apply height when content grows (engine drives sibling reflow via parent UIListLayout).
  maid:Give(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    if expanded then container.Size = UDim2.new(1, 0, 0, HEADER_H + theme.Spacing.gap + contentHeight()) end
  end))

  maid:Give(header.MouseButton1Click:Connect(function() api:Toggle() end))
  maid:Give(header.MouseEnter:Connect(function() Animate.to(container, "fast", { BackgroundColor3 = theme.Colors.surface }) end))
  maid:Give(header.MouseLeave:Connect(function() Animate.to(container, "fast", { BackgroundColor3 = theme.Colors.card }) end))
  maid:Give(container)

  function api.Destroy() maid:DoCleanup() end

  applyHeight(false)
  return api
end

return Accordion
