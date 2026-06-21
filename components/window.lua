-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
local UserInputService = game:GetService("UserInputService")

local Window = {}
local Create, DefaultTheme, Animate, Maid, Icons, Overlay, Acrylic, Tab

function Window.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid
  Icons = R.Icons; Overlay = R.Overlay; Acrylic = R.Acrylic; Tab = R.Tab
end

local TITLE_H = 40
local SIDEBAR_W = 150

function Window.new(config)
  config = config or {}
  local theme = config.Theme or DefaultTheme
  local maid = Maid.new()
  local width = (config.Size and config.Size.Width) or 560
  local height = (config.Size and config.Size.Height) or 420
  local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
  local tabs = {}
  local visible = true

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
  local sidebar = Create("ScrollingFrame", {
    Name = "Sidebar",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    Size = UDim2.new(0, SIDEBAR_W, 1, 0),
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

  local api = { Gui = gui, Main = main, ContentScroll = contentScroll, Overlay = Overlay.get(gui), Maid = maid }

  function api:AddTab(tabOpts)
    tabOpts = tabOpts or {}
    tabOpts.SidebarParent = sidebar
    tabOpts.ContentParent = contentScroll
    tabOpts.Theme = theme
    tabOpts.LayoutOrder = #tabs + 1
    tabOpts.OnActivate = function(selectedTab)
      for _, t in ipairs(tabs) do
        if t == selectedTab then t:Select() else t:Deselect() end
      end
    end
    local tab = Tab.new(tabOpts)
    tabs[#tabs + 1] = tab
    if #tabs == 1 then tab:Select() end
    return tab
  end

  function api:IsVisible() return visible end
  function api:Show()
    visible = true; main.Visible = true
    Animate.to(main, "fast", { BackgroundTransparency = config.Acrylic == false and 0 or 0.18 })
  end
  function api:Hide() visible = false; main.Visible = false end
  function api:Toggle() if visible then api:Hide() else api:Show() end end
  function api:SetTitle(s) titleLabel.Text = s end

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
  maid:Give(gui)
  function api.Destroy() maid:DoCleanup() end

  return api
end

return Window
