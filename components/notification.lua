-- Deps injected via Init(R). Sonner-style toasts: slide in from the right, stack
-- bottom-right (newest in front), older ones peek behind (scaled + faded); hover the
-- stack to expand into a full list. Each toast is a CanvasGroup so it can fade.
local Notification = {}
local Create, DefaultTheme, Maid, Overlay, Animate, Icons
local RunService = game:GetService("RunService")
local container
local order = {}   -- array of entries (oldest first, newest last)
local seq = 0
local expanded = false
local stepConn

function Notification.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Overlay = R.Overlay; Animate = R.Animate; Icons = R.Icons
end

local enabled = true
function Notification.setEnabled(b) enabled = b ~= false end

local TYPE_COLOR = { info = "info", success = "success", warning = "warning", error = "destructive" }
local TYPE_ICON = { info = "info", success = "circle-check", warning = "triangle-alert", error = "circle-alert" }
local GAP, PEEK = 8, 10

local function ensureContainer()
  if container and container.Parent ~= nil then return container end
  container = Create("Frame", {
    Name = "ToastContainer", BackgroundTransparency = 1, ZIndex = 1800,
    AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.new(0, 300, 1, -32),
  })
  container.MouseEnter:Connect(function()
    expanded = true
    for _, e in ipairs(order) do e.paused = true end
    Notification.relayout()
  end)
  container.MouseLeave:Connect(function()
    expanded = false
    for _, e in ipairs(order) do e.paused = false end
    Notification.relayout()
  end)
  Overlay.mount(container)
  if not stepConn then
    stepConn = RunService.Heartbeat:Connect(function(dt)
      for i = #order, 1, -1 do
        local e = order[i]
        if e.total and not e.paused then
          e.remaining = e.remaining - dt
          if e.bar then e.bar.Size = UDim2.new(math.max(0, e.remaining / e.total), 0, 0, 3) end
          if e.remaining <= 0 then Notification.dismiss(e.id) end
        end
      end
    end)
  end
  return container
end

-- position/scale/fade each toast based on its index from the bottom (newest = 0)
function Notification.relayout()
  local n = #order
  local y = 0
  for idx = n, 1, -1 do
    local e = order[idx]
    local i = n - idx -- 0 = newest (bottom-front)
    local scale, transp, visible, yoff
    if expanded then
      visible, scale, transp, yoff = true, 1, 0, y
      local h = (e.frame.AbsoluteSize and e.frame.AbsoluteSize.Y) or 60
      y = y + h + GAP
    else
      visible = i < 3
      scale = 1 - i * 0.05
      transp = i * 0.18
      yoff = i * PEEK
    end
    e.frame.Visible = visible
    Animate.to(e.frame, "base", { Position = UDim2.new(1, 0, 1, -yoff), GroupTransparency = transp }, Animate.EASING.smooth)
    Animate.to(e.scale, "base", { Scale = scale }, Animate.EASING.smooth)
  end
end

local function indexOf(id) for i, e in ipairs(order) do if e.id == id then return i end end end

function Notification.show(opts)
  if not enabled then return nil end
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  ensureContainer()
  seq = seq + 1
  local id = seq
  local accent = theme.Colors[TYPE_COLOR[opts.Type or "info"]] or theme.Colors.info

  local toast = Create("CanvasGroup", {
    Name = "Toast", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0, GroupTransparency = 1,
    AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 320, 1, 0), -- start off-screen right
    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = container,
    Create.corner(theme.Radius.md), Create.padding({ all = 10 }),
    Create.listLayout({ Padding = 4 }),
  })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = toast })
  local scale = Instance.new("UIScale"); scale.Parent = toast

  local titleRow = Create("Frame", { Name = "TitleRow", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = toast })
  local tIcon = Create("ImageLabel", { Name = "Icon", BackgroundTransparency = 1,
    Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), Parent = titleRow })
  Icons.apply(tIcon, TYPE_ICON[opts.Type or "info"] or "info", accent)
  Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title or "",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.label.Size,
    Font = Enum.Font.BuilderSans, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 24, 0, 0), Parent = titleRow })
  local closeBtn = Create("ImageButton", { Name = "Close", AutoButtonColor = false, BackgroundTransparency = 1,
    Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -14, 0, 0), Parent = titleRow })
  Icons.apply(closeBtn, "x", theme.Colors.primary)
  closeBtn.MouseButton1Click:Connect(function() Notification.dismiss(id) end)

  if opts.Message then
    Create("TextLabel", { Name = "Message", BackgroundTransparency = 1, Text = opts.Message,
      TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
      TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = toast })
  end
  if opts.Action then
    local act = opts.Action
    local aBtn = Create("TextButton", { Name = "Action", AutoButtonColor = false,
      BackgroundColor3 = theme.Colors.surface, Text = act.Text or act.Label or "Action",
      TextColor3 = theme.Colors.foreground, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      Size = UDim2.new(0, 96, 0, 24), LayoutOrder = 3, Parent = toast, Create.corner(theme.Radius.sm) })
    aBtn.MouseButton1Click:Connect(function() if act.Callback then pcall(act.Callback) end; Notification.dismiss(id) end)
  end

  order[#order + 1] = { id = id, frame = toast, scale = scale, onDismiss = opts.OnDismiss }
  Animate.pop(toast, "base")      -- subtle scale pop
  Notification.relayout()         -- slides it from off-screen to its slot + fades in

  if (opts.Duration or 4000) > 0 then
    local total = (opts.Duration or 4000) / 1000
    local bar = Create("Frame", { Name = "Progress", BackgroundColor3 = accent, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 3), LayoutOrder = 99, Parent = toast, Create.corner(2) })
    local e = order[#order]
    e.total = total; e.remaining = total; e.paused = false; e.bar = bar
  end
  return id
end

function Notification.dismiss(id)
  local i = indexOf(id)
  if not i then return end
  local entry = table.remove(order, i)
  if entry.onDismiss then pcall(entry.onDismiss) end
  if entry.frame then entry.frame:Destroy() end
  Notification.relayout()
end

function Notification.clearAll()
  for i = #order, 1, -1 do Notification.dismiss(order[i].id) end
end

function Notification.count() return #order end

return Notification
