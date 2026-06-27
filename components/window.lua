-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local UserInputService = game:GetService("UserInputService")

local Window = {}
local Create, DefaultTheme, Animate, Maid, Icons, Overlay, Acrylic, Tab, ConfigMod, DialogMod, Notif, Asset, Themer, Mount, Safe, Drag, Device

function Window.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid
  Icons = R.Icons; Overlay = R.Overlay; Acrylic = R.Acrylic; Tab = R.Tab; ConfigMod = R.Config; DialogMod = R.Dialog
  Notif = R.Notification; Asset = R.Asset; Themer = R.Themer
  Mount = R.Mount; Safe = R.Safe; Drag = R.Drag; Device = R.Device
end

local TITLE_H = 40
local TITLE_H_TALL = 56
local SIDEBAR_W = 150
local SIDEBAR_MIN, SIDEBAR_MAX = 110, 260
local MIN_W, MIN_H = 380, 260
local VP_MARGIN = 0.92                  -- never exceed 92% of the viewport on either axis
local DEF_WF, DEF_HF = 0.45, 0.6       -- default window size as a fraction of the viewport (W x H)
local FALLBACK_VP = { X = 1280, Y = 720 }
local FAB_MARGIN = 16
local FAB_ANCHORS = { TopLeft = true, MidLeft = true, BottomLeft = true, TopRight = true, MidRight = true, BottomRight = true }
-- Map a named anchor + the FAB kind/size to a Position UDim2.
-- simple = a docked edge tab (left peeks at -15; right starts near the edge so the on-show
-- magnet settles it); circle/square = fully visible at the anchor with a margin. Vertical
-- band (Top/Mid/Bottom) is the same for both.
local function fabAnchorPos(name, kind, w, h)
  local yScale, yOff
  if name:find("Top") then yScale, yOff = 0, FAB_MARGIN
  elseif name:find("Mid") then yScale, yOff = 0.5, -h / 2
  else yScale, yOff = 1, -(h + FAB_MARGIN) end
  local isLeft = name:find("Left") ~= nil
  if kind == "simple" then
    if isLeft then return UDim2.new(0, -15, yScale, yOff) end
    return UDim2.new(1, -(w - 15), yScale, yOff)
  end
  if isLeft then return UDim2.new(0, FAB_MARGIN, yScale, yOff) end
  return UDim2.new(1, -(w + FAB_MARGIN), yScale, yOff)
end -- headless / no CurrentCamera

function Window.new(config)
  config = config or {}
  -- merge a partial Theme override onto the defaults (verbatim use would crash on missing tokens)
  local theme = DefaultTheme.new(config.Theme or {})
  if config.Mode == "light" then DefaultTheme.applyMode(theme, "light") else theme.Mode = "dark" end
  -- reduced-motion toggle. Process-wide by design (single-window norm; last writer wins) —
  -- see api:SetAnimationsEnabled. Don't "fix" into per-window state without revisiting the spec.
  if config.Animations ~= nil then Animate.setEnabled(config.Animations ~= false) end
  if config.NotificationPosition then Notif.setPosition(config.NotificationPosition) end
  theme.AccentName = "Adaptive"
  local maid = Maid.new()
  -- Ratio = the window size as a fraction of the viewport (per axis):
  --   { Width = 0.4, Height = 0.55 } -> 40% of viewport width x 55% of viewport height
  --   a single number n             -> the same fraction n on both axes
  -- omitted -> the default (DEF_WF x DEF_HF). Values are floored only by MIN_W/MIN_H and
  -- capped at VP_MARGIN of the viewport (see computeSize).
  local function fractionsFromRatio(r)
    local wf, hf
    if type(r) == "table" then
      wf = tonumber(r.Width or r[1]); hf = tonumber(r.Height or r[2])
    elseif type(r) == "number" then
      wf = r; hf = r
    end
    if not (wf and wf > 0) then wf = DEF_WF end
    if not (hf and hf > 0) then hf = DEF_HF end
    return wf, hf
  end
  local widthFrac, heightFrac = fractionsFromRatio(config.Ratio)
  local function viewportSize()
    local cam = workspace and workspace.CurrentCamera
    local vp = cam and cam.ViewportSize
    if vp and vp.X and vp.X > 0 then return vp end
    return FALLBACK_VP
  end
  local function computeSize()
    local vp = viewportSize()
    local w = vp.X * widthFrac
    local h = vp.Y * heightFrac
    local maxW, maxH = vp.X * VP_MARGIN, vp.Y * VP_MARGIN
    if w > maxW then w = maxW end
    if h > maxH then h = maxH end
    w = math.max(w, MIN_W)
    h = math.max(h, MIN_H)
    return math.floor(w), math.floor(h)
  end
  local width, height = computeSize()
  local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
  local tabs = {}
  local selectedIndex = 0  -- index of the active tab; drives the carousel direction on switch
  local visible = true
  local fab, fabScale, fabFullSize, fabSnap, fabMaid, showFab, hideFab
  local fabEnabled, autoHide
  local sidebarW = SIDEBAR_W
  local closed = false
  local startHidden = config.StartHidden == true  -- start collapsed to just the FAB; open via the FAB/toggle key
  local userMoved = false  -- set when the user drags/resizes; viewport changes then clamp instead of re-centering
  local userResized = false  -- set when the user drags the grip; AdaptToViewport then preserves the manual size
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

  local mountCtx = config._mountCtx or { parent = config.Parent }
  local gui = Create("ScreenGui", {
    Name = Mount.guiName(config, mountCtx.studio),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior and Enum.ZIndexBehavior.Sibling or nil,
    DisplayOrder = config.DisplayOrder or 1000000,
    Parent = config.Parent,
  })
  Mount.finalize(gui, mountCtx)

  local main = Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, width, 0, height),
    Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
    BorderSizePixel = 0,
    Parent = gui,
    Create.corner(theme.Radius.window),
  })
  local transp = type(config.Transparency) == "number" and config.Transparency or 0.12
  Acrylic.decorate(main, theme, { transparency = transp,
    base = theme.Colors.background, gradientTop = theme.Colors.card, gradientBottom = theme.Colors.background })
  local winScale = Create("UIScale", { Scale = 1, Parent = main })
  local userScale = 1

  -- A logo source is either a string (one image, optionally ImageAdaptive-tinted) or a
  -- { dark = ..., light = ... } table that swaps per color mode -- for full-color tiles that ship a
  -- baked-in background per mode. `srcFor` picks the variant for the active mode (or the string itself).
  local function srcFor(value, mode)
    if type(value) == "table" then return value[mode] or value.dark or value.light end
    return value
  end

  -- title bar (grows to fit a subtitle and/or image)
  local titleSrc = config.Image
  local imageIsModal = type(titleSrc) == "table"
  -- Adaptive = tint a monochrome glyph (currentColor SVG) to the foreground token so it follows
  -- dark/light. Modal tiles are full-color, so ImageAdaptive is ignored for them (tinting would wreck
  -- the baked-in colors). Both are re-applied on SetMode by the window-shell reskin closure below.
  local imageAdaptive = config.ImageAdaptive == true and not imageIsModal
  local hasTitleImg = Asset.resolvable(srcFor(titleSrc, theme.Mode))
  local hasSubtitle = type(config.Subtitle) == "string" and config.Subtitle ~= ""
  local titleH = (hasTitleImg or hasSubtitle) and TITLE_H_TALL or TITLE_H
  local titleBar = Create("Frame", {
    Name = "TitleBar",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, titleH),
    Parent = main,
    Create.padding({ left = theme.Spacing.pad, right = theme.Spacing.pad }),
  })
  local titleTextX = 0
  local titleImg
  local applyTitleImage   -- (re)resolves the current-mode variant and writes it; set when the image exists
  if hasTitleImg then
    local imgSize = 36
    titleImg = Create("ImageLabel", {
      -- Glyphs (adaptive) and self-contained tiles (modal) use Fit so the whole mark shows; Crop
      -- (cover) would scale up and clip a padded/centered mark. Plain full-bleed logos keep Crop.
      Name = "TitleImage", BackgroundTransparency = 1,
      ScaleType = (imageAdaptive or imageIsModal) and Enum.ScaleType.Fit or Enum.ScaleType.Crop,
      AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
      Size = UDim2.new(0, imgSize, 0, imgSize), Image = "", Parent = titleBar,
      Create.corner(theme.Radius.md),
    })
    if imageAdaptive then titleImg.ImageColor3 = theme.Colors.foreground
    elseif imageIsModal then titleImg.ImageColor3 = Color3.fromRGB(255, 255, 255) end -- render the tile's own colors
    -- Fill it (and re-fill on mode change) with the active variant. URLs download off the construction
    -- thread, so the window never blocks on game:HttpGet; the write is marshalled to a capability ctx.
    applyTitleImage = function()
      Asset.imageAsync(srcFor(titleSrc, theme.Mode), function(id)
        Safe.mutate(function() if titleImg.Parent then titleImg.Image = id end end)
      end)
    end
    applyTitleImage()
    titleTextX = imgSize + 8
  end
  local titleLabel = Create("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Text = config.Title or "EzUI",
    TextColor3 = theme.Colors.foreground,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = hasSubtitle and Enum.TextYAlignment.Bottom or Enum.TextYAlignment.Center,
    TextSize = theme.Font.title.Size,
    Font = Enum.Font.BuilderSans,
    Position = UDim2.new(0, titleTextX, 0, 0),
    Size = hasSubtitle and UDim2.new(1, -(titleTextX + 60), 0.5, 0) or UDim2.new(1, -(titleTextX + 60), 1, 0),
    Parent = titleBar,
  })
  if hasSubtitle then
    Create("TextLabel", {
      Name = "Subtitle",
      BackgroundTransparency = 1,
      Text = config.Subtitle,
      TextColor3 = theme.Colors.mutedForeground,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
      TextSize = theme.Font.muted.Size,
      Font = Enum.Font.BuilderSans,
      Position = UDim2.new(0, titleTextX, 0.5, 0),
      Size = UDim2.new(1, -(titleTextX + 60), 0.5, 0),
      Parent = titleBar,
    })
  end
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
    Position = UDim2.new(0, 0, 0, titleH),
    Size = UDim2.new(1, 0, 1, -titleH),
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
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = theme.Colors.border,
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
    Name = "ContentPanel", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0,
    Position = UDim2.new(0, sidebarW + cgap, 0, cgap),
    Size = UDim2.new(1, -(sidebarW + cgap * 2), 1, -cgap * 2),
    Parent = body, ClipsDescendants = true, Create.corner(theme.Radius.lg),
  })
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
  if Device.IsTouch() then sidebarHandle.Size = UDim2.new(0, 44, 1, 0) end
  Drag.bind(sidebarHandle, {
    onBegin = function() sbDrag = true; Overlay.closeAll() end,
    onChange = function(_, _, pos)
      local bp = body.AbsolutePosition
      applySidebarWidth(pos.X - (bp and bp.X or 0))
    end,
    onEnd = function() sbDrag = false end,
  }, maid)

  -- single active-tab indicator that slides between sidebar buttons (lives in Body so the
  -- sidebar's UIListLayout does not lay it out; Body positions its children manually).
  local activeIndicator = Create("Frame", {
    Name = "ActiveIndicator", BackgroundColor3 = theme.Colors.primary, BorderSizePixel = 0,
    Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 2, 0, 0), Visible = false, ZIndex = 5,
    Parent = body, Create.corner(2),
  })
  local activeTabButton
  local function moveIndicatorTo(btn, instant)
    activeTabButton = btn
    if not btn or btn.Visible == false then activeIndicator.Visible = false; return end
    local bp, sp = btn.AbsolutePosition, body.AbsolutePosition
    local by = (bp and sp and (bp.Y - sp.Y)) or 0
    local bh = (btn.AbsoluteSize and btn.AbsoluteSize.Y) or 34
    -- Clip to the sidebar's visible vertical band (body-relative): hide when the selected
    -- button is scrolled out of view so the indicator never drifts over the search box or
    -- off the window edge.
    local sTop = (sidebar.AbsolutePosition and sp and (sidebar.AbsolutePosition.Y - sp.Y)) or 0
    local sBot = sTop + ((sidebar.AbsoluteSize and sidebar.AbsoluteSize.Y) or 0)
    local center = by + bh / 2
    if sBot > sTop and (center < sTop or center > sBot) then activeIndicator.Visible = false; return end
    activeIndicator.Visible = true
    local target = UDim2.new(0, 2, 0, by + bh / 2 - 9)
    if instant then activeIndicator.Position = target else Animate.springTo(activeIndicator, "base", { Position = target }) end
  end
  -- Keep the window-owned indicator glued to the selected button: its Y is a body-relative
  -- offset from the button's AbsolutePosition, so recompute it (instantly, no spring) whenever
  -- the button moves on screen -- sidebar scroll (CanvasPosition), sidebar/body resize
  -- (AbsoluteSize), or a list reflow (AbsoluteContentSize). Without these it desyncs on scroll
  -- or resize and can drift right out of the window.
  -- Driven by property-changed signals (engine thread, no GUI capability on strict executors), so
  -- moveIndicatorTo's protected reads/writes must be marshalled (inline when capable).
  local function reanchorIndicator() if activeTabButton then Safe.mutate(function() moveIndicatorTo(activeTabButton, true) end) end end
  maid:Give(sidebar:GetPropertyChangedSignal("CanvasPosition"):Connect(reanchorIndicator))
  maid:Give(sidebar:GetPropertyChangedSignal("AbsoluteSize"):Connect(reanchorIndicator))
  maid:Give(body:GetPropertyChangedSignal("AbsoluteSize"):Connect(reanchorIndicator))
  do
    local sbLayout = sidebar:FindFirstChildOfClass("UIListLayout")
    if sbLayout then maid:Give(sbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(reanchorIndicator)) end
  end

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
      local newIndex = selectedIndex
      for i, t in ipairs(tabs) do if t == selectedTab then newIndex = i break end end
      -- carousel direction: +1 going to a lower/later tab, -1 going to a higher/earlier one
      local dir = (selectedIndex == 0 or newIndex >= selectedIndex) and 1 or -1
      selectedIndex = newIndex
      for _, t in ipairs(tabs) do
        if t == selectedTab then t:Select(dir) else t:Deselect(dir) end
      end
      moveIndicatorTo(selectedTab.Button)
    end
    local tab = Tab.new(tabOpts)
    entry.tab = tab
    entry.button = tab.Button
    tabs[#tabs + 1] = tab
    tabEntries[#tabEntries + 1] = entry
    if #tabs == 1 then tab:Select(1); selectedIndex = 1; moveIndicatorTo(tab.Button) end
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
    if activeTabButton then moveIndicatorTo(activeTabButton) end
  end

  maid:Give(searchInput:GetPropertyChangedSignal("Text"):Connect(function()
    -- Text-changed fires on an engine thread; SearchTabs toggles many .Visible (protected) -> marshal.
    Safe.mutate(function() api:SearchTabs(searchInput.Text) end)
  end))

  function api:IsVisible() return visible end
  function api:Show()
    if closed then return end
    visible = true
    Safe.mutate(function()
      main.Visible = true
      winScale.Scale = userScale * 0.92
      Animate.springTo(winScale, "base", { Scale = userScale })
    end)
    if autoHide and hideFab then hideFab() end
  end
  function api:Hide()
    if closed then return end
    visible = false
    Safe.mutate(function()
      Animate.toThen(winScale, "base", { Scale = userScale * 0.92 }, function()
        if not visible then main.Visible = false; winScale.Scale = userScale end
      end)
    end)
    if showFab then showFab() end
  end
  function api:Toggle() if closed then return end; if visible then api:Hide() else api:Show() end end
  function api:SetTitle(s) Safe.mutate(function() titleLabel.Text = s end) end
  function api:SetSubtitle(s)
    Safe.mutate(function()
      local sub = titleBar:FindFirstChild("Subtitle")
      if sub then sub.Text = s end
    end)
  end
  function api:SetImage(v)
    -- v is a string or a { dark, light } table; keep the source so SetMode can keep swapping variants.
    titleSrc = v
    imageIsModal = type(v) == "table"
    imageAdaptive = config.ImageAdaptive == true and not imageIsModal
    Safe.mutate(function()
      local img = titleImg or titleBar:FindFirstChild("TitleImage")
      if img then
        img.ScaleType = (imageAdaptive or imageIsModal) and Enum.ScaleType.Fit or Enum.ScaleType.Crop
        img.ImageColor3 = imageAdaptive and theme.Colors.foreground or Color3.fromRGB(255, 255, 255)
      end
    end)
    if applyTitleImage then applyTitleImage() return end
    Asset.imageAsync(srcFor(v, theme.Mode), function(id)
      Safe.mutate(function()
        local img = titleBar:FindFirstChild("TitleImage")
        if img then img.Image = id end
      end)
    end)
  end
  function api:Dialog(o) o = o or {}; o.Theme = theme; o.Window = api; return DialogMod.open(o) end
  function api:Notify(o) o = o or {}; o.Theme = theme; return Notif.show(o) end
  function api:SetNotificationsEnabled(b) Notif.setEnabled(b); return b end
  function api:SetTransparency(n) Safe.mutate(function() main.BackgroundTransparency = n end); return n end
  function api:SetAnimationsEnabled(b) Animate.setEnabled(b and true or false); return b end
  function api:SetToggleKey(k) toggleKey = k; return k end
  function api:SetUIScale(n)
    userScale = n
    Safe.mutate(function() winScale.Scale = n end)
    return n
  end
  function api:ShowSuccess(o) o = o or {}; o.Type = "success"; return api:Notify(o) end
  function api:ShowWarning(o) o = o or {}; o.Type = "warning"; return api:Notify(o) end
  function api:ShowError(o) o = o or {}; o.Type = "error"; return api:Notify(o) end
  function api:ShowInfo(o) o = o or {}; o.Type = "info"; return api:Notify(o) end
  function api:ShowLoading(o) o = o or {}; o.Theme = theme; return Notif.loading(o) end
  function api:Promise(fn, o) o = o or {}; o.Theme = theme; return Notif.promise(fn, o) end
  function api:SetNotificationPosition(p) return Notif.setPosition(p) end
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
    return { SetText = function(s) Safe.mutate(function() txt.Text = s end) end, Destroy = function() unreg(); pill:Destroy() end }
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
    Safe.mutate(function() themer.reskin() end)
  end
  function api:GetMode() return theme.Mode end
  function api:SetMode(mode)
    DefaultTheme.applyMode(theme, mode)
    if theme.AccentName == "Adaptive" then
      local p = DefaultTheme.PALETTES[mode] or DefaultTheme.PALETTES.dark
      theme.Colors.primary = p.primary
      theme.Colors.primaryForeground = p.primaryForeground
    end
    Safe.mutate(function() themer.reskin() end)
  end

  -- window-shell live re-skin (mode/accent)
  themer.register(function()
    main.BackgroundColor3 = theme.Colors.background
    titleLabel.TextColor3 = theme.Colors.foreground
    if titleImg and imageAdaptive then titleImg.ImageColor3 = theme.Colors.foreground end
    if applyTitleImage and imageIsModal then applyTitleImage() end   -- swap to the active-mode tile
    local sub = titleBar:FindFirstChild("Subtitle")
    if sub then sub.TextColor3 = theme.Colors.mutedForeground end
    Icons.apply(closeBtn, "x", theme.Colors.mutedForeground)
    Icons.apply(minBtn, "minus", theme.Colors.mutedForeground)
    searchBox.BackgroundColor3 = theme.Colors.input
    local si = searchBox:FindFirstChild("SearchInput")
    if si then si.TextColor3 = theme.Colors.foreground; si.PlaceholderColor3 = theme.Colors.mutedForeground end
    contentPanel.BackgroundColor3 = theme.Colors.card
    activeIndicator.BackgroundColor3 = theme.Colors.primary
    local grad = main:FindFirstChildOfClass("UIGradient")
    if grad then
      grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Colors.card),
        ColorSequenceKeypoint.new(1, theme.Colors.background),
      })
    end
    local mstroke = main:FindFirstChildOfClass("UIStroke")
    if mstroke then mstroke.Color = theme.Colors.border end
    local noise = main:FindFirstChild("AcrylicNoise")
    if noise then noise.ImageTransparency = (theme.Mode == "light") and 0.97 or 0.92 end
  end)

  fabEnabled = config.FloatingToggle ~= false
  local fabOpts = (type(config.FloatingToggle) == "table") and config.FloatingToggle or {}
  autoHide = fabOpts.AutoHide ~= false   -- default true: hide the FAB while the window is shown
  local function ensureFab()
    if fab then return fab end
    if fabMaid then fabMaid:DoCleanup() end
    fabMaid = Maid.new(); maid:Give(fabMaid)
    local kind = fabOpts.Type or "simple"
    -- The FAB logo source mirrors the title: a string, or a { dark, light } table that swaps per mode.
    local fabImageModal = type(fabOpts.Image) == "table"
    local hasImage = fabImageModal or (type(fabOpts.Image) == "string" and fabOpts.Image ~= "")
    -- Adaptive tints a monochrome glyph to foreground (re-tinted on SetMode). Modal tiles are
    -- full-color and swap per mode instead, so Adaptive is ignored for them.
    local fabAdaptive = fabOpts.Adaptive == true and not fabImageModal
    local fabImg
    -- Fill the FAB with the configured logo edge-to-edge (no background frame showing around it), once
    -- the asset resolves (URLs fetch off-thread so the FAB never blocks). Reset the glyph's sprite crop
    -- and tint so a full image renders clean. The write is marshalled to a capability-bearing context.
    -- No-op when no Image is configured (the gamepad placeholder stays).
    local function applyFabImage(img)
      Asset.imageAsync(srcFor(fabOpts.Image, theme.Mode), function(id)
        Safe.mutate(function()
          if not img.Parent then return end
          img.Image = id
          img.ImageRectOffset = Vector2.new(0, 0)
          img.ImageRectSize = Vector2.new(0, 0)
          img.ImageColor3 = fabAdaptive and theme.Colors.foreground or Color3.fromRGB(255, 255, 255)
        end)
      end)
    end
    -- A logo fills the whole FAB (rounded to the FAB shape); the gamepad placeholder is a small
    -- centered glyph. `radius` clips the fill to match the FAB's own corner.
    local function makeFabImg(radius)
      if hasImage then
        return Create("ImageLabel", { Name = "Img", BackgroundTransparency = 1,
          -- glyph (adaptive) or self-contained tile (modal): Fit (show whole mark); plain logo: Crop (fill)
          ScaleType = (fabAdaptive or fabImageModal) and Enum.ScaleType.Fit or Enum.ScaleType.Crop,
          Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), Image = "", Parent = fab, Create.corner(radius) })
      end
      local img = Create("ImageLabel", { Name = "Img", BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, -12, 0.5, -12), Parent = fab })
      Icons.apply(img, "gamepad-2", theme.Colors.primary)
      return img
    end
    local chev, chevDir = nil, "chevron-right"
    fab = Create("ImageButton", { Name = "FloatingToggle", AutoButtonColor = false, BackgroundTransparency = 0,
      Visible = false, Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 16, 1, -60), ZIndex = 1700, Parent = Overlay.get(gui) })
    fab:SetAttribute("FabType", kind)
    fabScale = Create("UIScale", { Scale = 1, Parent = fab })
    if kind == "square" then
      fab.BackgroundColor3 = theme.Colors.surface
      Create("UICorner", { CornerRadius = UDim.new(0, theme.Radius.lg), Parent = fab })
      fabImg = makeFabImg(theme.Radius.lg); applyFabImage(fabImg)
    elseif kind == "circle" then
      fab.BackgroundColor3 = theme.Colors.primary
      Create("UICorner", { CornerRadius = UDim.new(0, 22), Parent = fab })
      fabImg = makeFabImg(22); applyFabImage(fabImg)
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
    -- Size override (accept UDim2 or {Width,Height} table)
    if fabOpts.Size then
      if type(fabOpts.Size) == "table" and type(fabOpts.Size.Width) == "number" then
        fab.Size = UDim2.new(0, fabOpts.Size.Width, 0, fabOpts.Size.Height or 44)
      else fab.Size = fabOpts.Size end
    end
    -- Position: a named anchor ("TopLeft".."BottomRight"), a raw UDim2, or default per kind
    local defaultAnchor = (kind == "simple") and "MidLeft" or "TopLeft"
    local pos = fabOpts.Position
    if type(pos) == "string" then
      if not FAB_ANCHORS[pos] then pos = defaultAnchor end
      fab.Position = fabAnchorPos(pos, kind, fab.Size.X.Offset, fab.Size.Y.Offset)
    elseif pos ~= nil then
      fab.Position = pos -- raw UDim2
    else
      fab.Position = fabAnchorPos(defaultAnchor, kind, fab.Size.X.Offset, fab.Size.Y.Offset)
    end
    fabFullSize = fab.Size

    -- Only the "simple" slide-out tab magnets to an edge. circle/square FABs are free-floating:
    -- they stay wherever the user drops them (no snap), so this is a no-op for them.
    fabSnap = function()
      if kind ~= "simple" then return end
      local vp = Overlay.get(gui).AbsoluteSize
      if not vp or vp.X <= 0 then return end
      local w2 = (fabFullSize and fabFullSize.X.Offset) or 50
      local cx = fab.Position.X.Scale * vp.X + fab.Position.X.Offset + w2 / 2
      local ys, yo = fab.Position.Y.Scale, fab.Position.Y.Offset
      local peek = 15 -- slide-out tab: dock to the edge, peeking ~15px
      if cx < vp.X / 2 then
        chevDir = "chevron-right"; if chev then Icons.apply(chev, chevDir, theme.Colors.primary) end
        Animate.to(fab, 0.3, { Position = UDim2.new(0, -peek, ys, yo) }, Enum.EasingStyle.Quad)
      else
        chevDir = "chevron-left"; if chev then Icons.apply(chev, chevDir, theme.Colors.primary) end
        Animate.to(fab, 0.3, { Position = UDim2.new(0, vp.X - w2 + peek, ys, yo) }, Enum.EasingStyle.Quad)
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
          -- Always magnet to the nearest edge on release, based on the knob's current
          -- position -- not on whether/how fast it moved. `moved` only gates the click-vs-drag
          -- distinction in the MouseButton1Click handler; gating the snap on it made slow drags
          -- (where the click fires first and clears `moved`) skip the magnet.
          if fabSnap then fabSnap() end
        end
      end))
    end
    fabMaid:Give(fab.MouseButton1Click:Connect(function()
      if moved then moved = false; return end
      api:Toggle()
    end))
    fabMaid:Give(themer.register(function()
      if kind == "circle" then
        fab.BackgroundColor3 = theme.Colors.primary
      else -- square + simple are neutral surface
        fab.BackgroundColor3 = theme.Colors.surface
        local st = fab:FindFirstChildOfClass("UIStroke"); if st then st.Color = theme.Colors.border end
        if chev then Icons.apply(chev, chevDir, theme.Colors.primary) end
      end
      if fabImg and fabAdaptive and hasImage then fabImg.ImageColor3 = theme.Colors.foreground end
      if fabImg and fabImageModal then applyFabImage(fabImg) end   -- swap to the active-mode tile
    end))
    local fabHover = false
    fabMaid:Give(fab.MouseEnter:Connect(function() fabHover = true; Animate.to(fabScale, "fast", { Scale = 1.06 }) end))
    fabMaid:Give(fab.MouseLeave:Connect(function() fabHover = false; Animate.to(fabScale, "fast", { Scale = 1 }) end))
    fabMaid:Give(fab.MouseButton1Down:Connect(function() Animate.to(fabScale, "fast", { Scale = 0.92 }) end))
    fabMaid:Give(fab.MouseButton1Up:Connect(function() Animate.springTo(fabScale, "base", { Scale = fabHover and 1.06 or 1 }) end))
    fabMaid:Give(fab)
    return fab
  end

  showFab = function()
    if not fabEnabled then return end
    Safe.mutate(function()
      ensureFab()
      fab.Visible = true
      fabScale.Scale = 0.6
      Animate.toThen(fabScale, "slow", { Scale = 1 }, function()
        if fabSnap and fab:GetAttribute("FabType") == "simple" then fabSnap() end
      end, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
  end
  hideFab = function()
    Safe.mutate(function()
      if not fab or not fab.Visible then return end
      Animate.toThen(fabScale, "fast", { Scale = 0.6 }, function()
        fab.Visible = false; fabScale.Scale = 1
      end)
    end)
  end

  function api:SetFloatingToggle(opts)
    local wasHidden = not visible
    if fab then fab:Destroy(); fab = nil end
    -- Merge over the current options so changing one field (e.g. Type, from the Settings selector)
    -- keeps the rest -- otherwise switching type would drop a configured Image/Size/Position.
    local merged = {}
    for k, v in pairs(fabOpts) do merged[k] = v end
    for k, v in pairs(opts or {}) do merged[k] = v end
    fabOpts = merged
    fabEnabled = true
    autoHide = fabOpts.AutoHide ~= false
    ensureFab()
    if wasHidden or not autoHide then showFab() end
  end
  function api:GetFloatingToggleType() return fabOpts.Type or "simple" end

  function api:Minimize()
    Overlay.closeAll()
    api:Hide()
  end
  maid:Give(minBtn.MouseButton1Click:Connect(function() api:Minimize() end))

  -- drag by title bar
  local dragging, dragStartPos
  Drag.bind(titleBar, {
    onBegin = function() dragging = true; dragStartPos = main.Position; Overlay.closeAll() end,
    onChange = function(dx, dy)
      main.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + dx, dragStartPos.Y.Scale, dragStartPos.Y.Offset + dy)
      userMoved = true
    end,
    onEnd = function() dragging = false end,
  }, maid)

  -- resize via bottom-right grip. The small icon stays put; a transparent hit target sits
  -- on top of it, finger-sized on touch, so the corner is actually grabbable on mobile.
  local grip = Create("ImageButton", {
    Name = "ResizeGrip", AutoButtonColor = false, BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1), Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -2, 1, -2),
    ZIndex = 50, Parent = main,
  })
  Icons.apply(grip, "move-diagonal-2", theme.Colors.mutedForeground)
  local gripHitPx = Device.IsTouch() and 44 or 22
  local resizeHit = Create("ImageButton", {
    Name = "ResizeHit", AutoButtonColor = false, BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1), Size = UDim2.new(0, gripHitPx, 0, gripHitPx), Position = UDim2.new(1, 0, 1, 0),
    ZIndex = 51, Parent = main,
  })
  maid:Give(resizeHit.MouseEnter:Connect(function() Icons.apply(grip, "move-diagonal-2", theme.Colors.foreground) end))
  maid:Give(resizeHit.MouseLeave:Connect(function() Icons.apply(grip, "move-diagonal-2", theme.Colors.mutedForeground) end))
  local resizing = false
  local rSize
  Drag.bind(resizeHit, {
    onBegin = function() resizing = true; rSize = { X = width, Y = height }; Overlay.closeAll() end,
    onChange = function(dx, dy)
      width = math.max(MIN_W, rSize.X + dx)
      height = math.max(MIN_H, rSize.Y + dy)
      local vp = viewportSize()
      width = math.min(width, vp.X); height = math.min(height, vp.Y)
      main.Size = UDim2.new(0, width, 0, height)
      widthFrac = width / vp.X      -- keep proportions current; only used when not userResized
      heightFrac = height / vp.Y
      userMoved = true
      userResized = true
    end,
    onEnd = function() resizing = false end,
  }, maid)

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

  -- responsive: always re-fit to the viewport, preserving the configured Ratio
  function api:AdaptToViewport()
    if dragging or resizing or sbDrag then return end  -- don't fight an active drag/resize
    local vp = viewportSize()
    if userResized then
      -- honor the user's manual size; only shrink to fit a smaller viewport
      width = math.max(MIN_W, math.min(width, math.floor(vp.X * VP_MARGIN)))
      height = math.max(MIN_H, math.min(height, math.floor(vp.Y * VP_MARGIN)))
    else
      width, height = computeSize()
    end
    main.Size = UDim2.new(0, width, 0, height)
    if userMoved then
      -- honor the user's placement; just keep it on-screen in the new viewport
      local absX = main.Position.X.Scale * vp.X + main.Position.X.Offset
      local absY = main.Position.Y.Scale * vp.Y + main.Position.Y.Offset
      absX = math.max(0, math.min(absX, vp.X - width))
      absY = math.max(0, math.min(absY, vp.Y - height))
      main.Position = UDim2.new(0, absX, 0, absY)
    else
      main.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
    end
  end
  api:AdaptToViewport()
  do
    local cam = workspace and workspace.CurrentCamera
    if cam and cam.GetPropertyChangedSignal then
      maid:Give(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() Safe.mutate(function() api:AdaptToViewport() end) end))
    end
  end

  -- mobile/touch floating toggle button
  if fabEnabled then
    ensureFab() -- reopen button; hidden until the window hides (unless AutoHide = false or StartHidden)
    if not autoHide or startHidden then showFab() end
  end
  function api:SetFloatingToggleVisible(b) if b then showFab() else hideFab() end end

  if startHidden then
    -- start collapsed to just the FAB: no entrance animation; pre-set the final scale/transparency
    -- so the first api:Show() (FAB tap or toggle key) reveals a correctly-rendered window.
    visible = false
    main.Visible = false
    winScale.Scale = userScale
    main.BackgroundTransparency = transp
  else
    -- entrance: scale-pop + background fade-in
    winScale.Scale = userScale * 0.9
    main.BackgroundTransparency = 1
    Animate.springTo(winScale, "slow", { Scale = userScale })
    Animate.to(main, "slow", { BackgroundTransparency = transp })
  end

  maid:Give(gui)

  function api:SetCloseCallback(fn) closeCallback = fn end
  function api:Close()
    if closed then return end
    closed = true
    visible = false
    Animate.to(main, "fast", { BackgroundTransparency = 1 })
    Animate.toThen(winScale, "fast", { Scale = userScale * 0.9 }, function()
      if config.OnClose then pcall(config.OnClose) end
      if closeCallback then pcall(closeCallback) end
      if cfg then pcall(function() cfg:Save() end) end
      Overlay.closeAll()
      if Notif then Notif.clearAll() end
      maid:DoCleanup()       -- disconnects EVERY connection (drag, resize, toggle-key, close, ...)
      gui:Destroy()
      Overlay.reset()
    end, Enum.EasingStyle.Back, Enum.EasingDirection.In)
  end
  function api.Destroy() api:Close() end

  return api
end

return Window
