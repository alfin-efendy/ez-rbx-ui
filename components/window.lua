-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local UserInputService = game:GetService("UserInputService")

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
  local theme = (config.Theme and DefaultTheme.new(config.Theme)) or DefaultTheme
  local maid = Maid.new()
  local width = (config.Size and config.Size.Width) or 560
  local height = (config.Size and config.Size.Height) or 420
  local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
  local tabs = {}
  local visible = true
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

  local main = Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, width, 0, height),
    Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
    BorderSizePixel = 0,
    Parent = gui,
    Create.corner(theme.Radius.window),
  })
  local acrylicT = type(config.Acrylic) == "number" and config.Acrylic or nil
  Acrylic.decorate(main, theme, { solid = config.Acrylic == false, transparency = acrylicT })

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

  -- header elevation: a 1px seam line + a soft downward shadow so content scrolls under the title bar
  local headerShadow = Create("Frame", {
    Name = "HeaderShadow", Active = false, BackgroundColor3 = theme.Colors.background, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, TITLE_H), ZIndex = 4, Parent = main,
  })
  Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1),
  }), Parent = headerShadow })
  Create("Frame", {
    Name = "HeaderSeparator", Active = false, BackgroundColor3 = theme.Colors.border, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, TITLE_H), ZIndex = 5, Parent = main,
  })

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
  local contentScroll = Create("ScrollingFrame", {
    Name = "Content",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = theme.Colors.border,
    Position = UDim2.new(0, sidebarW, 0, 0),
    Size = UDim2.new(1, -sidebarW, 1, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ClipsDescendants = true,
    Parent = body,
  })

  -- draggable sidebar↔content divider (with a centered grip)
  local sidebarHandle = Create("ImageButton", {
    Name = "SidebarHandle", AutoButtonColor = false, BackgroundTransparency = 1,
    ZIndex = 6, Size = UDim2.new(0, 12, 1, 0), Position = UDim2.new(0, sidebarW, 0, 0), Parent = body,
  })
  Create("Frame", { Name = "Line", BackgroundColor3 = theme.Colors.border, BorderSizePixel = 0, ZIndex = 6,
    Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0), Parent = sidebarHandle })
  local sbGrip = Create("Frame", { Name = "Grip", BackgroundColor3 = theme.Colors.surface, BorderSizePixel = 0, ZIndex = 7,
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 14, 0, 22),
    Parent = sidebarHandle, Create.corner(theme.Radius.sm) })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = sbGrip })
  local sbGripIcon = Create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 10, 0, 10),
    Position = UDim2.new(0.5, -5, 0.5, -5), Parent = sbGrip })
  Icons.apply(sbGripIcon, "grip-vertical", theme.Colors.mutedForeground)
  maid:Give(sidebarHandle.MouseEnter:Connect(function() Icons.apply(sbGripIcon, "grip-vertical", theme.Colors.foreground) end))
  maid:Give(sidebarHandle.MouseLeave:Connect(function() Icons.apply(sbGripIcon, "grip-vertical", theme.Colors.mutedForeground) end))
  local function applySidebarWidth(wpx)
    sidebarW = math.max(SIDEBAR_MIN, math.min(SIDEBAR_MAX, wpx))
    sidebar.Size = UDim2.new(0, sidebarW, 1, -36)
    searchBox.Size = UDim2.new(0, sidebarW - 16, 0, 24)
    contentScroll.Position = UDim2.new(0, sidebarW, 0, 0)
    contentScroll.Size = UDim2.new(1, -sidebarW, 1, 0)
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
  end
  function api:Hide() if closed then return end; visible = false; main.Visible = false end
  function api:Toggle() if closed then return end; if visible then api:Hide() else api:Show() end end
  function api:SetTitle(s) titleLabel.Text = s end
  function api:Dialog(o) o = o or {}; o.Theme = theme; return DialogMod.open(o) end
  function api:Notify(o) o = o or {}; o.Theme = theme; return Notif.show(o) end
  function api:SetNotificationsEnabled(b) Notif.setEnabled(b); return b end
  function api:SetAcrylicTransparency(n) main.BackgroundTransparency = n; return n end
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
      Icons.apply(ic, o.Icon, theme.Colors.mutedForeground)
    end
    local txt = Create("TextLabel", { Name = "TagText", BackgroundTransparency = 1, Text = o.Text or "",
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.muted.Size,
      Font = Enum.Font.BuilderSans, Size = UDim2.new(1, hasIcon and -16 or 0, 1, 0),
      Position = UDim2.new(0, hasIcon and 16 or 0, 0, 0), Parent = pill })
    tagX = tagX + width + 8
    return { SetText = function(s) txt.Text = s end, Destroy = function() pill:Destroy() end }
  end
  function api:SetAccent(nameOrColor)
    local a = Themer.accent(nameOrColor)
    if not a and typeof(nameOrColor) == "Color3" then a = { Primary = nameOrColor, Foreground = theme.Colors.primaryForeground } end
    if not a then return end
    theme.Colors.primary = a.Primary
    theme.Colors.primaryForeground = a.Foreground
    themer.setAccent(a.Primary, a.Foreground)
  end

  local fab
  local fabOpts = (type(config.FloatingToggle) == "table") and config.FloatingToggle or {}
  local function ensureFab()
    if fab then return fab end
    local kind = fabOpts.Type or "simple"
    local resolved = Asset.image(fabOpts.Image)
    fab = Create("ImageButton", { Name = "FloatingToggle", AutoButtonColor = false, BackgroundTransparency = 0,
      Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 16, 1, -60), ZIndex = 1700, Parent = Overlay.get(gui) })
    fab:SetAttribute("FabType", kind)
    if kind == "square" then
      fab.BackgroundColor3 = theme.Colors.surface
      Create("UICorner", { CornerRadius = UDim.new(0, theme.Radius.lg), Parent = fab })
      Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = fab })
      local img = Create("ImageLabel", { BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop,
        Size = UDim2.new(1, -6, 1, -6), Position = UDim2.new(0, 3, 0, 3), Parent = fab, Create.corner(theme.Radius.md) })
      if resolved then img.Image = resolved else Icons.apply(img, "gamepad-2", theme.Colors.foreground) end
    elseif kind == "circle" then
      fab.BackgroundColor3 = theme.Colors.primary
      Create("UICorner", { CornerRadius = UDim.new(0, 22), Parent = fab })
      local img = Create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, -12, 0.5, -12), Parent = fab })
      if resolved then img.Image = resolved else Icons.apply(img, "gamepad-2", theme.Colors.primaryForeground) end
    else -- simple
      fab.BackgroundColor3 = theme.Colors.surface
      Create("UICorner", { CornerRadius = UDim.new(0, theme.Radius.md), Parent = fab })
      Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = fab })
      local img = Create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0.5, -11, 0.5, -11), Parent = fab })
      if resolved then img.Image = resolved else Icons.apply(img, "gamepad-2", theme.Colors.foreground) end
    end
    -- a click toggles; a drag (>6px) moves the FAB and suppresses that click's toggle
    local moved = false
    if fabOpts.Draggable ~= false then
      local dragging, startPos, fabStart
      maid:Give(fab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
          dragging = true; moved = false; startPos = input.Position; fabStart = fab.Position
        end
      end))
      maid:Give(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
          local dx, dy = input.Position.X - startPos.X, input.Position.Y - startPos.Y
          if math.abs(dx) > 6 or math.abs(dy) > 6 then moved = true end
          fab.Position = UDim2.new(fabStart.X.Scale, fabStart.X.Offset + dx, fabStart.Y.Scale, fabStart.Y.Offset + dy)
        end
      end))
      maid:Give(fab.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
      end))
    end
    maid:Give(fab.MouseButton1Click:Connect(function()
      if moved then moved = false; return end
      api:Toggle()
    end))
    return fab
  end
  function api:SetFloatingToggle(opts)
    local wasVisible = fab and fab.Visible
    if fab then fab:Destroy(); fab = nil end
    fabOpts = opts or {}
    ensureFab()
    fab.Visible = wasVisible ~= false
  end

  function api:Minimize()
    Overlay.closeAll()
    visible = false
    main.Visible = false
    ensureFab().Visible = true
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
  Icons.apply(grip, "grip", theme.Colors.mutedForeground)
  maid:Give(grip.MouseEnter:Connect(function() Icons.apply(grip, "grip", theme.Colors.foreground) end))
  maid:Give(grip.MouseLeave:Connect(function() Icons.apply(grip, "grip", theme.Colors.mutedForeground) end))
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

  maid:Give(closeBtn.MouseButton1Click:Connect(function() api:Close() end))

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
  if config.FloatingToggle or UserInputService.TouchEnabled then ensureFab() end
  function api:SetFloatingToggleVisible(b) ensureFab().Visible = b end

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
