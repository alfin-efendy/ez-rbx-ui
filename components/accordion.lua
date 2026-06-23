-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local Accordion = {}
local Create, DefaultTheme, Animate, Maid, Icons, Host, REG, Safe
local RunService = game:GetService("RunService")

function Accordion.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid; Icons = R.Icons
  Host = R.Host; REG = R; Safe = R.Safe
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
  Icons.apply(caret, "chevron-right", theme.Colors.primary)
  caret.Rotation = expanded and 90 or 0

  local leadIcon
  if opts.Icon then
    leadIcon = Create("ImageLabel", { Name = "Icon", BackgroundTransparency = 1,
      Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 24, 0.5, -8), Parent = header })
    Icons.apply(leadIcon, opts.Icon, theme.Colors.primary)
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
      Animate.rotateTo(caret, "base", expanded and 90 or 0)
      if expanded then
        -- spring the height open (slight overshoot) and slide the content down into place
        content.Position = UDim2.new(0, 0, 0, HEADER_H + theme.Spacing.gap + 8)
        Animate.springTo(container, "base", { Size = UDim2.new(1, 0, 0, target) })
        Animate.to(content, "base", { Position = UDim2.new(0, 0, 0, HEADER_H + theme.Spacing.gap) })
      else
        Animate.toThen(container, "base", { Size = UDim2.new(1, 0, 0, target) }, function()
          if not expanded then content.Visible = false; divider.Visible = false end
        end)
      end
    else
      container.Size = UDim2.new(1, 0, 0, target)
      content.Visible = expanded
      divider.Visible = expanded
      caret.Rotation = expanded and 90 or 0
    end
  end

  -- The container height is fixed (AutomaticSize=None), so it must be re-derived whenever the content
  -- size changes. A child's height settles a render step AFTER it is added -- a TextLabel's
  -- AutomaticSize.Y, and especially a wrapped/reactive paragraph -- so a height measured on the
  -- add-frame is stale and ClipsDescendants crops the lower rows. reflow() re-applies the height from
  -- the CURRENT content size; scheduleReflow() defers it one Heartbeat (when AutomaticSize has
  -- landed) via Heartbeat:Once, which keeps the GUI write in a capability-bearing context (never
  -- task.defer/spawn -- those drop executor capability). Debounced so rapid AddX calls do one pass.
  local reflowPending = false
  local function reflow()
    if expanded then container.Size = UDim2.new(1, 0, 0, HEADER_H + theme.Spacing.gap + contentHeight()) end
  end
  local function scheduleReflow()
    if reflowPending then return end
    reflowPending = true
    RunService.Heartbeat:Once(function() reflowPending = false; reflow() end)
  end

  function api:Toggle() expanded = not expanded; applyHeight(true); return expanded end
  function api:Expand() if not expanded then expanded = true; applyHeight(true) end end
  function api:Collapse() if expanded then expanded = false; applyHeight(true) end end
  function api:IsExpanded() return expanded end
  function api:SetTitle(s) Safe.mutate(function() title.Text = s end) end
  function api:SetIcon(name) if leadIcon then Safe.mutate(function() Icons.apply(leadIcon, name, theme.Colors.primary) end) end end

  function api.MountRow(child)
    order = order + 1
    child.LayoutOrder = order
    child.Parent = content
    scheduleReflow()                    -- the child's AutomaticSize settles next frame; re-measure then
    return order
  end

  -- AddX control methods (Label/Button/Toggle/TextBox/NumberBox/SelectBox/...)
  Host.attach(api, {
    R = REG, content = content, theme = theme, config = opts.Config, window = opts.Window,
    registerSearchable = opts.RegisterSearchable, accentThemer = opts.AccentThemer,
    registerControl = opts.RegisterControl,
    -- AddX controls parent straight to `content` (not via MountRow), so re-measure here too: a
    -- freshly added paragraph/button's height settles next frame and would otherwise be clipped.
    nextOrder = function() order = order + 1; scheduleReflow(); return order end,
  })

  if opts.AccentThemer then maid:Give(opts.AccentThemer.register(function()
    container.BackgroundColor3 = theme.Colors.card
    local st = container:FindFirstChildOfClass("UIStroke"); if st then st.Color = theme.Colors.border end
    title.TextColor3 = theme.Colors.foreground
    Icons.apply(caret, "chevron-right", theme.Colors.primary)
    caret.Rotation = expanded and 90 or 0
    if leadIcon then Icons.apply(leadIcon, opts.Icon, theme.Colors.primary) end
    divider.BackgroundColor3 = theme.Colors.border
  end)) end

  -- Re-apply height when content grows. The immediate reflow handles add/remove (content size already
  -- updated when this fires); scheduleReflow re-measures one step later, after a just-added child's
  -- AutomaticSize has settled -- the signal can first fire while the child is still un-grown.
  maid:Give(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    reflow()
    scheduleReflow()
  end))

  maid:Give(header.MouseButton1Click:Connect(function() api:Toggle() end))
  maid:Give(container)

  function api.Destroy() maid:DoCleanup() end

  applyHeight(false)
  scheduleReflow()   -- Expanded=true content (paragraphs/buttons) settles next frame; re-measure then
  return api
end

return Accordion
