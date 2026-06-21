-- Deps injected via Init(R). shadcn-style resizable split panes with draggable handles.
local Resizable = {}
local Create, DefaultTheme, Maid, Icons, Host, REG
local UserInputService = game:GetService("UserInputService")

function Resizable.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Icons = R.Icons; Host = R.Host; REG = R
end

local HANDLE = 12

function Resizable.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local horizontal = (opts.Direction or "Horizontal") == "Horizontal"
  local defs = opts.Panes or { {}, {} }
  local n = #defs
  local fr, total = {}, 0
  for i = 1, n do fr[i] = defs[i].Default or (1 / n); total = total + fr[i] end
  for i = 1, n do fr[i] = fr[i] / total end

  local container = Create("Frame", { Name = "Resizable", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, opts.Height or (horizontal and 160 or 200)),
    LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent })

  local paneFrames, panes, handles = {}, {}, {}

  local function applyLayout()
    local cum = 0
    for i = 1, n do
      local f = paneFrames[i]
      if horizontal then
        f.Position = UDim2.new(cum, (i > 1) and HANDLE / 2 or 0, 0, 0)
        f.Size = UDim2.new(fr[i], (n > 1) and -HANDLE or 0, 1, 0)
      else
        f.Position = UDim2.new(0, 0, cum, (i > 1) and HANDLE / 2 or 0)
        f.Size = UDim2.new(1, 0, fr[i], (n > 1) and -HANDLE or 0)
      end
      cum = cum + fr[i]
      if i < n and handles[i] then
        if horizontal then
          handles[i].Position = UDim2.new(cum, -HANDLE / 2, 0, 0); handles[i].Size = UDim2.new(0, HANDLE, 1, 0)
        else
          handles[i].Position = UDim2.new(0, 0, cum, -HANDLE / 2); handles[i].Size = UDim2.new(1, 0, 0, HANDLE)
        end
      end
    end
  end

  for i = 1, n do
    local pane = Create("Frame", { Name = "Pane", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0,
      ClipsDescendants = true, Parent = container, Create.corner(theme.Radius.md), Create.padding({ all = 8 }),
      Create.listLayout({ Padding = theme.Spacing.gap }) })
    paneFrames[i] = pane
    local order = 0
    local paneApi = { Frame = pane }
    Host.attach(paneApi, { R = REG, content = pane, theme = theme, accentThemer = opts.AccentThemer,
      nextOrder = function() order = order + 1; return order end })
    panes[i] = paneApi
  end

  for k = 1, n - 1 do
    local handle = Create("ImageButton", { Name = "Handle", AutoButtonColor = false,
      BackgroundTransparency = 1, ZIndex = 5, Parent = container })
    Create("Frame", { Name = "Line", BackgroundColor3 = theme.Colors.border, BorderSizePixel = 0, ZIndex = 5,
      Parent = handle,
      Size = horizontal and UDim2.new(0, 1, 1, 0) or UDim2.new(1, 0, 0, 1),
      Position = horizontal and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0.5, 0),
      AnchorPoint = horizontal and Vector2.new(0.5, 0) or Vector2.new(0, 0.5) })
    local grip = Create("Frame", { Name = "Grip", BackgroundColor3 = theme.Colors.surface, BorderSizePixel = 0,
      ZIndex = 6, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
      Size = horizontal and UDim2.new(0, 14, 0, 22) or UDim2.new(0, 22, 0, 14),
      Parent = handle, Create.corner(theme.Radius.sm) })
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = grip })
    local gi = Create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 10, 0, 10),
      Position = UDim2.new(0.5, -5, 0.5, -5), Parent = grip })
    Icons.apply(gi, horizontal and "grip-vertical" or "grip-horizontal", theme.Colors.mutedForeground)
    maid:Give(handle.MouseEnter:Connect(function() Icons.apply(gi, horizontal and "grip-vertical" or "grip-horizontal", theme.Colors.foreground) end))
    maid:Give(handle.MouseLeave:Connect(function() Icons.apply(gi, horizontal and "grip-vertical" or "grip-horizontal", theme.Colors.mutedForeground) end))
    handles[k] = handle
    local drag
    maid:Give(handle.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = input.Position end
    end))
    maid:Give(UserInputService.InputChanged:Connect(function(input)
      if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local sz = container.AbsoluteSize
        local span = (sz and (horizontal and sz.X or sz.Y)) or 1
        if span <= 0 then span = 1 end
        local d = ((horizontal and input.Position.X or input.Position.Y) - (horizontal and drag.X or drag.Y)) / span
        local minL, minR = (defs[k].Min or 0.1), (defs[k + 1].Min or 0.1)
        local nl, nr = fr[k] + d, fr[k + 1] - d
        if nl >= minL and nr >= minR then fr[k] = nl; fr[k + 1] = nr; applyLayout(); drag = input.Position end
      end
    end))
    maid:Give(handle.InputEnded:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag = nil end
    end))
  end

  applyLayout()

  if opts.AccentThemer then maid:Give(opts.AccentThemer.register(function()
    for _, f in ipairs(paneFrames) do f.BackgroundColor3 = theme.Colors.card end
    for _, hd in ipairs(handles) do
      local line = hd:FindFirstChild("Line"); if line then line.BackgroundColor3 = theme.Colors.border end
      local grip = hd:FindFirstChild("Grip"); if grip then grip.BackgroundColor3 = theme.Colors.surface end
    end
  end)) end

  maid:Give(container)
  return { Frame = container, Panes = panes, Destroy = function() maid:DoCleanup() end }
end

return Resizable
