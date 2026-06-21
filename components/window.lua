-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local UserInputService = game:GetService("UserInputService")

local Window = {}
local Create, DefaultTheme, Animate, Maid, Icons, Overlay, Acrylic, Tab, ConfigMod, DialogMod, Notif

function Window.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid
  Icons = R.Icons; Overlay = R.Overlay; Acrylic = R.Acrylic; Tab = R.Tab; ConfigMod = R.Config; DialogMod = R.Dialog
  Notif = R.Notification
end

local TITLE_H = 40
local SIDEBAR_W = 150

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
  Acrylic.decorate(main, theme, { solid = config.Acrylic == false })

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
    Position = UDim2.new(0, 8, 0, 6), Size = UDim2.new(0, SIDEBAR_W - 16, 0, 24), Parent = body,
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
    Size = UDim2.new(0, SIDEBAR_W, 1, -36),
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
    Position = UDim2.new(0, SIDEBAR_W, 0, 0),
    Size = UDim2.new(1, -SIDEBAR_W, 1, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ClipsDescendants = true,
    Parent = body,
  })

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
    -- controls register their searchable text here (full-text search across components)
    tabOpts.RegisterSearchable = function(frame, text)
      searchIndex[#searchIndex + 1] = { entry = entry, frame = frame, text = (text or ""):lower() }
    end
    tabOpts.OnActivate = function(selectedTab)
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
    visible = true; main.Visible = true
  end
  function api:Hide() visible = false; main.Visible = false end
  function api:Toggle() if visible then api:Hide() else api:Show() end end
  function api:SetTitle(s) titleLabel.Text = s end
  function api:Dialog(o) o = o or {}; o.Theme = theme; return DialogMod.open(o) end
  function api:Notify(o) o = o or {}; o.Theme = theme; return Notif.show(o) end
  function api:ShowSuccess(o) o = o or {}; o.Type = "success"; return api:Notify(o) end
  function api:ShowWarning(o) o = o or {}; o.Type = "warning"; return api:Notify(o) end
  function api:ShowError(o) o = o or {}; o.Type = "error"; return api:Notify(o) end
  function api:ShowInfo(o) o = o or {}; o.Type = "info"; return api:Notify(o) end
  function api:DismissNotification(id) Notif.dismiss(id) end
  function api:ClearNotifications() Notif.clearAll() end

  function api:ResetFlag(flag) if cfg then cfg:ResetFlag(flag) end end
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

  local minimized = false
  function api:Minimize()
    minimized = not minimized
    body.Visible = not minimized
    Animate.to(main, "base", { Size = UDim2.new(0, width, 0, minimized and TITLE_H or height) })
  end

  -- drag by title bar
  local dragging, dragStart, startPos
  maid:Give(titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true; dragStart = input.Position; startPos = main.Position
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

  -- toggle key
  maid:Give(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == toggleKey then api:Toggle() end
  end))

  maid:Give(closeBtn.MouseButton1Click:Connect(function() api:Hide() end))

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
  local fab
  if config.FloatingToggle or UserInputService.TouchEnabled then
    fab = Create("ImageButton", { Name = "FloatingToggle", AutoButtonColor = false, BackgroundColor3 = theme.Colors.primary,
      Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 16, 1, -60), ZIndex = 1700,
      Parent = Overlay.get(gui), Create.corner(22) })
    local fi = Create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 22, 0, 22),
      Position = UDim2.new(0.5, -11, 0.5, -11), Parent = fab })
    Icons.apply(fi, "gamepad-2", theme.Colors.primaryForeground)
    maid:Give(fab.MouseButton1Click:Connect(function() api:Toggle() end))
  end
  function api:SetFloatingToggleVisible(b) if fab then fab.Visible = b end end

  maid:Give(gui)
  function api.Destroy() maid:DoCleanup() end

  return api
end

return Window
