-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Window = {}
local Create, DefaultTheme, Animate, Maid, Icons, Overlay, Acrylic, Tab, ConfigMod, DialogMod, Notif, Asset, Themer

function Window.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid
  Icons = R.Icons; Overlay = R.Overlay; Acrylic = R.Acrylic; Tab = R.Tab; ConfigMod = R.Config; DialogMod = R.Dialog
  Notif = R.Notification; Asset = R.Asset; Themer = R.Themer
end

local TITLE_H = 40
local SIDEBAR_W = 150
local SIDEBAR_MIN, SIDEBAR_MAX = 110, 260
local MIN_W, MIN_H = 380, 260

function Window.new(config)
  config = config or {}
  -- merge a partial Theme override onto the defaults (verbatim use would crash on missing tokens)
  local theme = DefaultTheme.new(config.Theme or {})
  if config.Mode == "light" then DefaultTheme.applyMode(theme, "light") else theme.Mode = "dark" end
  theme.AccentName = "Adaptive"
  local maid = Maid.new()
  local width = (config.Size and config.Size.Width) or 560
  local height = (config.Size and config.Size.Height) or 420
  local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
  local tabs = {}
  local visible = true
  local fab, fabFullSize, fabSnap, fabMaid, showFab, hideFab
  local sidebarW = SIDEBAR_W
  local closed = false
  local closeCallback
  local themer = Themer.new()
  local lockables = {}
  local function registerControl(c) lockables[#lockables + 1] = c end

  -- optional config persistence (controls register their flags against this)
  local cfg = nil
  local cfgOpts = config.Config
  if cfgOpts and cfgOpts.Enabled ~= false and (cfgOpts.FileName or cfgOpts.Enabled) then
    cfg = ConfigMod.new({
      FolderName = cfgOpts.FolderName, FileName = cfgOpts.FileName,
      AutoSave = cfgOpts.AutoSave, AutoLoad = cfgOpts.AutoLoad,
    })
  end

  local gui = Create("ScreenGui", {
    Name = "EzUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior and Enum.ZIndexBehavior.Sibling or nil,
    Parent = config.Parent,
  })

  local acrylicT = type(config.Acrylic) == "number" and config.Acrylic or nil
  -- acrylic transparency: content panel lighter+more see-through; window/chrome darker+more solid (~0.6x)
  local baseT = (config.Acrylic == false) and 0 or (acrylicT or 0.12)
  local chromeT = (config.Acrylic == false) and 0 or baseT * 0.35

  local main = Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, width, 0, height),
    Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
    BackgroundColor3 = theme.Colors.background, BackgroundTransparency = chromeT,
    BorderSizePixel = 0, ClipsDescendants = true,
    Parent = gui,
    Create.corner(theme.Radius.window),
  })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Transparency = 0.3, Parent = main })

  -- title bar
  local titleBar = Create("Frame", {
    Name = "TitleBar",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, TITLE_H),
    Parent = main,
    Create.padding({ left = theme.Spacing.pad, right = theme.Spacing.pad }),
  })
  local titleLabel = Create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Text = config.Title or "EzUI",
    TextColor3 = theme.Colors.foreground,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = theme.Font.title.Size,
    Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, -60, 1, 0),
    Parent = titleBar,
  })
  local closeBtn = Create("ImageButton", {
    Name = "Close",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(1, -18, 0.5, -9),
    Parent = titleBar,
  })
  Icons.apply(closeBtn, "x", theme.Colors.mutedForeground)
  local minBtn = Create("ImageButton", {
    Name = "Minimize", AutoButtonColor = false, BackgroundTransparency = 1,
    Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -44, 0.5, -9), Parent = titleBar,
  })
  Icons.apply(minBtn, "minus", theme.Colors.mutedForeground)
  maid:Give(closeBtn.MouseEnter:Connect(function() Icons.apply(closeBtn, "x", theme.Colors.destructive) end))
  maid:Give(closeBtn.MouseLeave:Connect(function() Icons.apply(closeBtn, "x", theme.Colors.mutedForeground) end))
  maid:Give(minBtn.MouseEnter:Connect(function() Icons.apply(minBtn, "minus", theme.Colors.primary) end))
  maid:Give(minBtn.MouseLeave:Connect(function() Icons.apply(minBtn, "minus", theme.Colors.mutedForeground) end))

  -- body: sidebar + content
  local body = Create("Frame", {
    Name = "Body",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, TITLE_H),
    Size = UDim2.new(1, 0, 1, -TITLE_H),
    Parent = main,
  })
  -- sidebar search box (pinned above the tab list)
  local searchBox = Create("Frame", {
    Name = "Search", BackgroundColor3 = theme.Colors.input, BorderSizePixel = 0,
    Position = UDim2.new(0, 8, 0, 6), Size = UDim2.new(0, sidebarW - 16, 0, 24), Parent = body,
    Create.corner(theme.Radius.sm), Create.padding({ left = 8, right = 8 }),
  })
  local searchInput = Create("TextBox", {
    Name = "SearchInput", BackgroundTransparency = 1, Text = "", PlaceholderText = "Search…",
    PlaceholderColor3 = theme.Colors.mutedForeground, TextColor3 = theme.Colors.foreground,
    TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
    ClearTextOnFocus = false, Size = UDim2.new(1, 0, 1, 0), Parent = searchBox,
  })

  local sidebar = Create("ScrollingFrame", {
    Name = "Sidebar",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    Position = UDim2.new(0, 0, 0, 36),
    Size = UDim2.new(0, sidebarW, 1, -36),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Parent = body,
    Create.listLayout({ Padding = 4 }),
    Create.padding({ all = 8 }),
  })
  local cgap = theme.Spacing.gap
  local contentPanel = Create("Frame", {
    Name = "ContentPanel", BorderSizePixel = 0,
    Position = UDim2.new(0, sidebarW + cgap, 0, cgap),
    Size = UDim2.new(1, -(sidebarW + cgap * 2), 1, -cgap * 2),
    Parent = body, ClipsDescendants = true, Create.corner(theme.Radius.lg),
  })
  Acrylic.decorate(contentPanel, theme, { solid = config.Acrylic == false, transparency = baseT, noStroke = true,
    base = theme.Colors.card, gradientTop = theme.Colors.surface, gradientBottom = theme.Colors.card })
  local contentScroll = Create("ScrollingFrame", {
    Name = "Content",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = theme.Colors.border,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.None,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ClipsDescendants = true,
    Parent = contentPanel,
  })

  -- draggable sidebar↔content divider (with a centered grip)
  local sidebarHandle = Create("ImageButton", {
    Name = "SidebarHandle", AutoButtonColor = false, BackgroundTransparency = 1,
    ZIndex = 6, Size = UDim2.new(0, 12, 1, 0), Position = UDim2.new(0, sidebarW, 0, 0), Parent = body,
  })
  local function applySidebarWidth(wpx)
    sidebarW = math.max(SIDEBAR_MIN, math.min(SIDEBAR_MAX, wpx))
    sidebar.Size = UDim2.new(0, sidebarW, 1, -36)
    searchBox.Size = UDim2.new(0, sidebarW - 16, 0, 24)
    contentPanel.Position = UDim2.new(0, sidebarW + cgap, 0, cgap)
    contentPanel.Size = UDim2.new(1, -(sidebarW + cgap * 2), 1, -cgap * 2)
    sidebarHandle.Position = UDim2.new(0, sidebarW, 0, 0)
  end
  local sbDrag
  maid:Give(sidebarHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sbDrag = true; Overlay.closeAll() end
  end))
  maid:Give(UserInputService.InputChanged:Connect(function(input)
    if sbDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
      local bp = body.AbsolutePosition
      applySidebarWidth(input.Position.X - (bp and bp.X or 0))
    end
  end))
  maid:Give(sidebarHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sbDrag = false end
  end))

  Overlay.get(gui)

  local api = { Gui = gui, Main = main, ContentScroll = contentScroll, Overlay = Overlay.get(gui), Config = cfg, Maid = maid }

  local tabEntries = {}
  local groups = {}
  local searchIndex = {} -- { entry = tabEntry, frame = controlFrame, text = lowercased }
  local sidebarOrder = 0
  local function nextSidebarOrder() sidebarOrder = sidebarOrder + 1; return sidebarOrder end

  local function addTab(tabOpts)
    tabOpts = tabOpts or {}
    local entry = { name = tabOpts.Name or "Tab" }
    tabOpts.SidebarParent = sidebar
    tabOpts.ContentParent = contentScroll
    tabOpts.Theme = theme
    tabOpts.Config = cfg
    tabOpts.Window = api
    tabOpts.AccentThemer = themer
    tabOpts.RegisterControl = registerControl
    -- controls register their searchable text here (full-text search across components)
    tabOpts.RegisterSearchable = function(frame, text)
      searchIndex[#searchIndex + 1] = { entry = entry, frame = frame, text = (text or ""):lower() }
    end
    tabOpts.OnActivate = function(selectedTab)
      Overlay.closeAll()
      for _, t in ipairs(tabs) do
        if t == selectedTab then t:Select() else t:Deselect() end
      end
    end
    local tab = Tab.new(tabOpts)
    entry.tab = tab
    entry.button = tab.Button
    tabs[#tabs + 1] = tab
    tabEntries[#tabEntries + 1] = entry
    if #tabs == 1 then tab:Select() end
    return tab
  end

  function api:AddTab(o)
    if closed then return end
    o = o or {}
    o.LayoutOrder = nextSidebarOrder()
    return addTab(o)
  end

  function api:AddTabGroup(name)
    local header = Create("TextLabel", {
      Name = "GroupHeader", BackgroundTransparency = 1, Text = string.upper(name or "Group"),
      TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left,
      TextSize = 10, Font = Enum.Font.BuilderSans, Size = UDim2.new(1, 0, 0, 16),
      LayoutOrder = nextSidebarOrder(), Parent = sidebar,
    })
    local group = { _header = header, _entries = {} }
    groups[#groups + 1] = group
    function group:AddTab(o)
      o = o or {}
      o.LayoutOrder = nextSidebarOrder()
      local tab = addTab(o)
      self._entries[#self._entries + 1] = tabEntries[#tabEntries]
      return tab
    end
    return group
  end

  function api:SearchTabs(query)
    query = (query or ""):lower()
    -- 1) component-level (full text): show only matching control rows
    for _, s in ipairs(searchIndex) do
      s.frame.Visible = (query == "" or (s.text ~= "" and s.text:find(query, 1, true) ~= nil))
    end
    -- 2) tab buttons: visible if the tab name matches OR any of its components match
    for _, e in ipairs(tabEntries) do
      local match = (query == "" or e.name:lower():find(query, 1, true) ~= nil)
      if not match then
        for _, s in ipairs(searchIndex) do
          if s.entry == e and s.frame.Visible then match = true break end
        end
      end
      e.button.Visible = match
    end
    -- 3) group headers: visible if any grouped tab is visible
    for _, g in ipairs(groups) do
      local anyVisible = false
      for _, e in ipairs(g._entries) do if e.button.Visible then anyVisible = true break end end
      g._header.Visible = anyVisible
    end
  end

  maid:Give(searchInput:GetPropertyChangedSignal("Text"):Connect(function()
    api:SearchTabs(searchInput.Text)
  end))

  function api:IsVisible() return visible end
  function api:Show()
    if closed then return end
    visible = true; main.Visible = true
    if hideFab then hideFab() end
  end
  function api:Hide()
    if closed then return end
    visible = false; main.Visible = false
    if showFab then showFab() end
  end
  function api:Toggle() if closed then return end; if visible then api:Hide() else api:Show() end end
  function api:SetTitle(s) titleLabel.Text = s end
  function api:Dialog(o) o = o or {}; o.Theme = theme; return DialogMod.open(o) end
  function api:Notify(o) o = o or {}; o.Theme = theme; return Notif.show(o) end
  function api:SetNotificationsEnabled(b) Notif.setEnabled(b); return b end
  function api:SetAcrylicTransparency(n)
    contentPanel.BackgroundTransparency = n
    main.BackgroundTransparency = n * 0.35
    return n
  end
  function api:SetToggleKey(k) toggleKey = k; return k end
  local uiScale
  function api:SetUIScale(n)
    if not uiScale then uiScale = Instance.new("UIScale"); uiScale.Parent = main end
    uiScale.Scale = n
    return n
  end
  function api:ShowSuccess(o) o = o or {}; o.Type = "success"; return api:Notify(o) end
  function api:ShowWarning(o) o = o or {}; o.Type = "warning"; return api:Notify(o) end
  function api:ShowError(o) o = o or {}; o.Type = "error"; return api:Notify(o) end
  function api:ShowInfo(o) o = o or {}; o.Type = "info"; return api:Notify(o) end
  function api:DismissNotification(id) Notif.dismiss(id) end
  function api:ClearNotifications() Notif.clearAll() end

  function api:ResetFlag(flag) if cfg then cfg:ResetFlag(flag) end end
  function api:ConfigProfiles() return cfg and cfg:ListProfiles() or { "Default" } end
  function api:UseConfigProfile(name) if cfg then cfg:SwitchProfile(name) end end
  function api:SaveConfiguration() return cfg and cfg:Save() or false end
  function api:LoadConfiguration() return cfg and cfg:Load() or false end

  function api:ResetConfiguration(o)
    o = o or {}
    if not cfg then return end
    local function doReset()
      cfg:Reset({ ClearFile = o.ClearFile })
      api:ShowSuccess({ Title = "Reset", Message = "Settings restored to defaults." })
    end
    if o.Confirm == false then
      doReset()
    else
      api:Dialog({ Title = "Reset settings?", Message = "This restores all options to their defaults.", Buttons = {
        { Text = "Cancel", Variant = "secondary" },
        { Text = "Reset", Variant = "destructive", Callback = doReset },
      } })
    end
  end

  function api:GetThemer() return themer end
  function api:LockAll() for _, c in ipairs(lockables) do if c.SetLocked then c.SetLocked(true) end end end
  function api:UnlockAll() for _, c in ipairs(lockables) do if c.SetLocked then c.SetLocked(false) end end end

  local tagX = 70 -- offset from the right, left of the min/close buttons
  function api:Tag(o)
    o = o or {}
    local hasIcon = o.Icon ~= nil
    local width = (hasIcon and 22 or 8) + (#tostring(o.Text or "") * 7) + 8
    local pill = Create("Frame", { Name = "Tag", BackgroundColor3 = o.Color or theme.Colors.surface, BorderSizePixel = 0,
      AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -tagX, 0.5, 0), Size = UDim2.new(0, width, 0, 20),
      Parent = titleBar, Create.corner(theme.Radius.sm), Create.padding({ left = 6, right = 6 }) })
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = pill })
    if hasIcon then
      local ic = Create("ImageLabel", { Name = "TagIcon", BackgroundTransparency = 1, Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 0, 0.5, -6), Parent = pill })
      Icons.apply(ic, o.Icon, theme.Colors.primary)
    end
    local txt = Create("TextLabel", { Name = "TagText", BackgroundTransparency = 1, Text = o.Text or "",
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.muted.Size,
      Font = Enum.Font.BuilderSans, Size = UDim2.new(1, hasIcon and -16 or 0, 1, 0),
      Position = UDim2.new(0, hasIcon and 16 or 0, 0, 0), Parent = pill })
    tagX = tagX + width + 8
    local unreg = themer.register(function()
      pill.BackgroundColor3 = o.Color or theme.Colors.surface
      local st = pill:FindFirstChildOfClass("UIStroke"); if st then st.Color = theme.Colors.border end
      txt.TextColor3 = theme.Colors.foreground
      local ic = pill:FindFirstChild("TagIcon"); if ic then Icons.apply(ic, o.Icon, theme.Colors.primary) end
    end)
    return { SetText = function(s) txt.Text = s end, Destroy = function() unreg(); pill:Destroy() end }
  end
  local function fgForColor(c)
    local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
    return (lum > 0.55) and Color3.fromRGB(24, 24, 27) or Color3.fromRGB(250, 250, 250)
  end
  function api:SetAccent(nameOrColor)
    if type(nameOrColor) ~= "string" then -- a Color3 (typeof is unreliable under the mock)
      theme.AccentName = "Custom"
      theme.Colors.primary = nameOrColor
      theme.Colors.primaryForeground = fgForColor(nameOrColor)
    elseif nameOrColor == "Adaptive" then
      theme.AccentName = "Adaptive"
      local p = DefaultTheme.PALETTES[theme.Mode] or DefaultTheme.PALETTES.dark
      theme.Colors.primary = p.primary
      theme.Colors.primaryForeground = p.primaryForeground
    else
      local a = Themer.accent(nameOrColor)
      if not a then return end
      theme.AccentName = nameOrColor
      theme.Colors.primary = a.Primary
      theme.Colors.primaryForeground = a.Foreground
    end
    themer.reskin()
  end
  function api:GetMode() return theme.Mode end
  function api:SetMode(mode)
    DefaultTheme.applyMode(theme, mode)
    if theme.AccentName == "Adaptive" then
      local p = DefaultTheme.PALETTES[mode] or DefaultTheme.PALETTES.dark
      theme.Colors.primary = p.primary
      theme.Colors.primaryForeground = p.primaryForeground
    end
    themer.reskin()
  end

  -- window-shell live re-skin (mode/accent)
  themer.register(function()
    local ms = main:FindFirstChildOfClass("UIStroke"); if ms then ms.Color = theme.Colors.border end
    main.BackgroundColor3 = theme.Colors.background
    titleLabel.TextColor3 = theme.Colors.foreground
    Icons.apply(closeBtn, "x", theme.Colors.mutedForeground)
    Icons.apply(minBtn, "minus", theme.Colors.mutedForeground)
    searchBox.BackgroundColor3 = theme.Colors.input
    local si = searchBox:FindFirstChild("SearchInput")
    if si then si.TextColor3 = theme.Colors.foreground; si.PlaceholderColor3 = theme.Colors.mutedForeground end
    contentPanel.BackgroundColor3 = theme.Colors.card
    local grad = contentPanel:FindFirstChildOfClass("UIGradient")
    if grad then grad.Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, theme.Colors.surface), ColorSequenceKeypoint.new(1, theme.Colors.card) }) end
    local cstroke = contentPanel:FindFirstChildOfClass("UIStroke"); if cstroke then cstroke.Color = theme.Colors.border end
    local noise = contentPanel:FindFirstChild("AcrylicNoise"); if noise then noise.ImageTransparency = (theme.Mode == "light") and 0.97 or 0.92 end
  end)

  local fabOpts = (type(config.FloatingToggle) == "table") and config.FloatingToggle or {}
  local function ensureFab()
    if fab then return fab end
    if fabMaid then fabMaid:DoCleanup() end
    fabMaid = Maid.new(); maid:Give(fabMaid)
    local kind = fabOpts.Type or "simple"
    local resolved = Asset.image(fabOpts.Image)
    local chev, chevDir = nil, "chevron-right"
    fab = Create("ImageButton", { Name = "FloatingToggle", AutoButtonColor = false, BackgroundTransparency = 0,
      Visible = false, Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 16, 1, -60), ZIndex = 1700, Parent = Overlay.get(gui) })
    fab:SetAttribute("FabType", kind)
    if kind == "square" then
      fab.BackgroundColor3 = theme.Colors.surface
      Create("UICorner", { CornerRadius = UDim.new(0, theme.Radius.lg), Parent = fab })
      Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = fab })
      local img = Create("ImageLabel", { Name = "Img", BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop,
        Size = UDim2.new(1, -6, 1, -6), Position = UDim2.new(0, 3, 0, 3), Parent = fab, Create.corner(theme.Radius.md) })
      if resolved then img.Image = resolved else Icons.apply(img, "gamepad-2", theme.Colors.primary) end
    elseif kind == "circle" then
      fab.BackgroundColor3 = theme.Colors.primary
      Create("UICorner", { CornerRadius = UDim.new(0, 22), Parent = fab })
      local img = Create("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, -12, 0.5, -12), Parent = fab })
      if resolved then img.Image = resolved else Icons.apply(img, "gamepad-2", theme.Colors.primary) end
    else -- simple: 50x50 chevron square, neutral surface (follows the mode)
      fab.Size = UDim2.new(0, 50, 0, 50)
      fab.Position = UDim2.new(0, -15, 0.5, -25) -- dock at the left edge, peeking ~15px (magnet)
      fab.BackgroundColor3 = theme.Colors.surface
      Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = fab })
      Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = fab })
      chev = Create("ImageLabel", { Name = "Chevron", BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, -12, 0.5, -12), Parent = fab })
      Icons.apply(chev, "chevron-right", theme.Colors.primary)
    end
    -- Size/Position overrides (accept UDim2 or {Width,Height}/{X,Y} offset tables)
    if fabOpts.Size then
      if type(fabOpts.Size) == "table" and type(fabOpts.Size.Width) == "number" then
        fab.Size = UDim2.new(0, fabOpts.Size.Width, 0, fabOpts.Size.Height or 44)
      else fab.Size = fabOpts.Size end
    end
    if fabOpts.Position then
      if type(fabOpts.Position) == "table" and type(fabOpts.Position.X) == "number" then
        fab.Position = UDim2.new(0, fabOpts.Position.X, 1, fabOpts.Position.Y or -60)
      else fab.Position = fabOpts.Position end
    end
    fabFullSize = fab.Size

    fabSnap = function()
      local vp = Overlay.get(gui).AbsoluteSize
      if not vp or vp.X <= 0 then return end
      local w2 = (fabFullSize and fabFullSize.X.Offset) or 50
      local cx = fab.Position.X.Scale * vp.X + fab.Position.X.Offset + w2 / 2
      local peek = 15
      if cx < vp.X / 2 then
        chevDir = "chevron-right"; if chev then Icons.apply(chev, chevDir, theme.Colors.primary) end
        Animate.to(fab, 0.3, { Position = UDim2.new(0, -peek, fab.Position.Y.Scale, fab.Position.Y.Offset) }, Enum.EasingStyle.Quad)
      else
        chevDir = "chevron-left"; if chev then Icons.apply(chev, chevDir, theme.Colors.primary) end
        Animate.to(fab, 0.3, { Position = UDim2.new(0, vp.X - w2 + peek, fab.Position.Y.Scale, fab.Position.Y.Offset) }, Enum.EasingStyle.Quad)
      end
    end

    local moved = false
    if fabOpts.Draggable ~= false then
      local dragging, startPos, fabStart
      fabMaid:Give(fab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
          dragging = true; moved = false; startPos = input.Position; fabStart = fab.Position
        end
      end))
      fabMaid:Give(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
          local dx, dy = input.Position.X - startPos.X, input.Position.Y - startPos.Y
          if math.abs(dx) > 6 or math.abs(dy) > 6 then moved = true end
          fab.Position = UDim2.new(fabStart.X.Scale, fabStart.X.Offset + dx, fabStart.Y.Scale, fabStart.Y.Offset + dy)
        end
      end))
      fabMaid:Give(UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
          dragging = false
          if moved and fabSnap then fabSnap() end
        end
      end))
    end
    fabMaid:Give(fab.MouseButton1Click:Connect(function()
      if moved then moved = false; return end
      api:Show()
    end))
    fabMaid:Give(themer.register(function()
      if kind == "circle" then
        fab.BackgroundColor3 = theme.Colors.primary
      else -- square + simple are neutral surface
        fab.BackgroundColor3 = theme.Colors.surface
        local st = fab:FindFirstChildOfClass("UIStroke"); if st then st.Color = theme.Colors.border end
        if chev then Icons.apply(chev, chevDir, theme.Colors.primary) end
      end
    end))
    fabMaid:Give(fab)
    return fab
  end

  showFab = function()
    ensureFab()
    fab.Visible = true
    local target = fabFullSize or fab.Size
    fab.Size = UDim2.new(target.X.Scale, 0, target.Y.Scale, target.Y.Offset)
    local tw = Animate.to(fab, 0.3, { Size = target }, Enum.EasingStyle.Quad)
    tw.Completed:Connect(function() if fabSnap then fabSnap() end end)
  end
  hideFab = function()
    if not fab or not fab.Visible then return end
    local target = fabFullSize or fab.Size
    -- connect BEFORE Play so the Completed handler runs even under the synchronous test mock
    local tw = TweenService:Create(fab, Animate.info(0.3, Enum.EasingStyle.Quad),
      { Size = UDim2.new(target.X.Scale, 0, target.Y.Scale, target.Y.Offset) })
    tw.Completed:Connect(function() fab.Visible = false; fab.Size = target end)
    tw:Play()
  end

  function api:SetFloatingToggle(opts)
    local wasHidden = not visible
    if fab then fab:Destroy(); fab = nil end
    fabOpts = opts or {}
    ensureFab()
    if wasHidden then showFab() end
  end

  function api:Minimize()
    Overlay.closeAll()
    api:Hide()
  end
  maid:Give(minBtn.MouseButton1Click:Connect(function() api:Minimize() end))

  -- drag by title bar
  local dragging, dragStart, startPos
  maid:Give(titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true; dragStart = input.Position; startPos = main.Position; Overlay.closeAll()
    end
  end))
  maid:Give(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
      local delta = { X = input.Position.X - dragStart.X, Y = input.Position.Y - dragStart.Y }
      main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
  end))
  maid:Give(titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
  end))

  -- resize via bottom-right grip
  local grip = Create("ImageButton", {
    Name = "ResizeGrip", AutoButtonColor = false, BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1), Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -2, 1, -2),
    ZIndex = 50, Parent = main,
  })
  Icons.apply(grip, "move-diagonal-2", theme.Colors.mutedForeground)
  maid:Give(grip.MouseEnter:Connect(function() Icons.apply(grip, "move-diagonal-2", theme.Colors.foreground) end))
  maid:Give(grip.MouseLeave:Connect(function() Icons.apply(grip, "move-diagonal-2", theme.Colors.mutedForeground) end))
  local resizing, rStart, rSize
  maid:Give(grip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      resizing = true; rStart = input.Position; rSize = { X = width, Y = height }; Overlay.closeAll()
    end
  end))
  maid:Give(UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
      width = math.max(MIN_W, rSize.X + (input.Position.X - rStart.X))
      height = math.max(MIN_H, rSize.Y + (input.Position.Y - rStart.Y))
      local cam = workspace and workspace.CurrentCamera
      if cam and cam.ViewportSize then
        width = math.min(width, cam.ViewportSize.X); height = math.min(height, cam.ViewportSize.Y)
      end
      main.Size = UDim2.new(0, width, 0, height)
    end
  end))
  maid:Give(grip.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
  end))

  -- toggle key
  maid:Give(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == toggleKey then api:Toggle() end
  end))

  maid:Give(closeBtn.MouseButton1Click:Connect(function()
    if config.ConfirmClose == false then api:Close(); return end
    api:Dialog({ Title = "Close window?", Message = "You can reopen it with the toggle key or the floating button.",
      Buttons = {
        { Text = "Cancel", Variant = "secondary" },
        { Text = "Close", Variant = "destructive", Callback = function() api:Close() end },
      } })
  end))

  -- responsive: clamp to viewport (best-effort; no-op headless where workspace is nil)
  function api:AdaptToViewport()
    local cam = workspace and workspace.CurrentCamera
    local vp = cam and cam.ViewportSize
    if vp then
      width = math.min(width, vp.X - 40)
      height = math.min(height, vp.Y - 40)
      main.Size = UDim2.new(0, width, 0, height)
      main.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
    end
  end
  if config.AutoAdapt ~= false then api:AdaptToViewport() end

  -- mobile/touch floating toggle button
  ensureFab() -- always available as the reopen button; hidden until the window hides
  function api:SetFloatingToggleVisible(b) if b then showFab() else hideFab() end end

  maid:Give(gui)

  function api:SetCloseCallback(fn) closeCallback = fn end
  function api:Close()
    if closed then return end
    closed = true
    visible = false
    Animate.to(main, "fast", { BackgroundTransparency = 1 })
    if config.OnClose then pcall(config.OnClose) end
    if closeCallback then pcall(closeCallback) end
    if cfg then pcall(function() cfg:Save() end) end
    Overlay.closeAll()
    if Notif then Notif.clearAll() end
    maid:DoCleanup()       -- disconnects EVERY connection (drag, resize, toggle-key, close, ...)
    gui:Destroy()
    Overlay.reset()
  end
  function api.Destroy() api:Close() end

  return api
end

return Window
