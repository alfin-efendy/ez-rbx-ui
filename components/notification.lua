-- Deps injected via Init(R). Sonner-style toasts: slide in from the right, stack
-- bottom-right (newest in front), older ones peek behind (scaled + faded); hover the
-- stack to expand into a full list. Each toast is a CanvasGroup so it can fade.
local Notification = {}
local Create, DefaultTheme, Maid, Overlay, Animate, Icons, Safe
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local container
local order = {}   -- array of entries (oldest first, newest last)
local seq = 0
local expanded = false
local stepConn

function Notification.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Overlay = R.Overlay; Animate = R.Animate; Icons = R.Icons
  Safe = R.Safe
  container = nil
end

local enabled = true
function Notification.setEnabled(b) enabled = b ~= false end

local TYPE_COLOR = { info = "info", success = "success", warning = "warning", error = "destructive", loading = "info" }
local TYPE_ICON = { info = "info", success = "circle-check", warning = "triangle-alert", error = "circle-alert", loading = "loader" }
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
        if e.frame and e.total and not e.paused then
          e.remaining = e.remaining - dt
          -- Heartbeat handlers lack the GUI capability on strict executors, so a raw write throws.
          -- pcall (not Safe.mutate) because this is a per-frame cosmetic write -- skip it cleanly when
          -- there's no capability rather than deferring 60 writes/sec. The countdown + dismiss below
          -- run on plain Lua state / Safe.mutate, so the toast still expires correctly.
          if e.bar then pcall(function() e.bar.Size = UDim2.new(math.max(0, e.remaining / e.total), 0, 0, 3) end) end
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
    if not e.frame then
      -- GUI deferred to a later Heartbeat; skip until built (it relayouts itself when ready)
    else
      local i = n - idx -- 0 = newest (bottom-front)
      local scale, transp, visible, yoff
      if expanded then
        visible, scale, transp, yoff = true, 1, 0, y
        -- Use the toast's intrinsic content height (UIListLayout content + its all=10 padding),
        -- which is scale-independent -- so expanded gaps stay uniform even while the per-toast
        -- collapse scale is still animating to 1. Reading AbsoluteSize mid-animation gave the
        -- scaled (smaller) height and made the gaps jitter/overlap on hover.
        local lay = e.frame:FindFirstChildOfClass("UIListLayout")
        local acs = lay and lay.AbsoluteContentSize
        local h = (acs and acs.Y and acs.Y > 0 and acs.Y + 20) or (e.frame.AbsoluteSize and e.frame.AbsoluteSize.Y) or 60
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
end

local function indexOf(id) for i, e in ipairs(order) do if e.id == id then return i end end end

local function startCountdown(entry, total, accent, theme)
  local bar = Create("Frame", { Name = "Progress", BackgroundColor3 = accent, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 3), LayoutOrder = 99, Parent = entry.frame, Create.corner(2) })
  entry.total = total; entry.remaining = total; entry.paused = false; entry.bar = bar
end

local function createMsgLabel(text, theme, parent)
  return Create("TextLabel", { Name = "Message", BackgroundTransparency = 1, Text = text,
    TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
    TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, Parent = parent })
end

local applyUpdate  -- forward declaration; applyUpdate is assigned after Notification.loading, show's pendingUpdate hook closes over it

function Notification.show(opts)
  if not enabled then return nil end
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  seq = seq + 1
  local id = seq
  local entry = { id = id, onDismiss = opts.OnDismiss }
  order[#order + 1] = entry           -- reserve FIFO slot synchronously
  Safe.mutate(function()
    local accent = theme.Colors[TYPE_COLOR[opts.Type or "info"]] or theme.Colors.info
    ensureContainer()
    local toast = Create("CanvasGroup", {
      Name = "Toast", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0, GroupTransparency = 1,
      AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 320, 1, 0),
      Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = container,
      Create.corner(theme.Radius.md), Create.padding({ all = 10 }),
      Create.listLayout({ Padding = 4 }),
    })
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = toast })
    local scale = Instance.new("UIScale"); scale.Parent = toast
    toast:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
      -- property-changed handler -> engine thread without GUI capability on strict executors; relayout
      -- reads AbsoluteContentSize/AbsoluteSize raw, so marshal it through Safe.mutate.
      if expanded then Safe.mutate(Notification.relayout) end
    end)
    local titleRow = Create("Frame", { Name = "TitleRow", BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = toast })
    local tIcon = Create("ImageLabel", { Name = "Icon", BackgroundTransparency = 1,
      Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), Parent = titleRow })
    Icons.apply(tIcon, TYPE_ICON[opts.Type or "info"] or "info", accent)
    local titleLabel = Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title or "",
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.label.Size,
      Font = Enum.Font.BuilderSans, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 24, 0, 0), Parent = titleRow })
    local closeBtn = Create("ImageButton", { Name = "Close", AutoButtonColor = false, BackgroundTransparency = 1,
      Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -14, 0, 0), Parent = titleRow })
    Icons.apply(closeBtn, "x", theme.Colors.primary)
    closeBtn.MouseButton1Click:Connect(function() Notification.dismiss(id) end)
    local msgLabel
    if opts.Message then
      msgLabel = createMsgLabel(opts.Message, theme, toast)
    end
    if opts.Action then
      local act = opts.Action
      local aBtn = Create("TextButton", { Name = "Action", AutoButtonColor = false,
        BackgroundColor3 = theme.Colors.surface, Text = act.Text or act.Label or "Action",
        TextColor3 = theme.Colors.foreground, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
        Size = UDim2.new(0, 96, 0, 24), LayoutOrder = 3, Parent = toast, Create.corner(theme.Radius.sm) })
      aBtn.MouseButton1Click:Connect(function() if act.Callback then pcall(act.Callback) end; Notification.dismiss(id) end)
    end
    entry.frame = toast; entry.scale = scale
    entry.icon = tIcon; entry.titleLabel = titleLabel; entry.theme = theme
    entry.type = opts.Type or "info"; entry.accent = accent
    entry.msgLabel = msgLabel
    if entry.type == "loading" then
      entry.spinTween = TweenService:Create(tIcon,
        TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 })
      entry.spinTween:Play()
    end
    if entry.type ~= "loading" and (opts.Duration or 4000) > 0 then
      startCountdown(entry, (opts.Duration or 4000) / 1000, accent, theme)
    end
    Animate.pop(toast, "base")
    Notification.relayout()
    if entry.pendingUpdate then applyUpdate(entry, entry.pendingUpdate); entry.pendingUpdate = nil end
  end)
  return id
end

function Notification.loading(opts)
  opts = opts or {}
  opts.Type = "loading"; opts.Duration = 0
  return Notification.show(opts)
end

applyUpdate = function(entry, opts)
  local theme = entry.theme
  local newType = opts.Type or entry.type
  local accent = theme.Colors[TYPE_COLOR[newType]] or theme.Colors.info
  entry.type = newType; entry.accent = accent
  if entry.spinTween then entry.spinTween:Cancel(); entry.spinTween = nil end
  if entry.icon then
    entry.icon.Rotation = 0
    Icons.apply(entry.icon, TYPE_ICON[newType] or "info", accent)
  end
  if opts.Title ~= nil and entry.titleLabel then entry.titleLabel.Text = opts.Title end
  if opts.Message ~= nil then
    if entry.msgLabel then
      entry.msgLabel.Text = opts.Message
    else
      entry.msgLabel = createMsgLabel(opts.Message, theme, entry.frame)
    end
  end
  if opts.Duration and opts.Duration > 0 then
    if entry.bar then entry.bar:Destroy(); entry.bar = nil end
    startCountdown(entry, opts.Duration / 1000, accent, theme)
  elseif opts.Duration == 0 then
    if entry.bar then entry.bar:Destroy(); entry.bar = nil end
    entry.total = nil; entry.remaining = nil; entry.bar = nil
  end
  Notification.relayout()
end

function Notification.update(id, opts)
  local i = indexOf(id); if not i then return end
  local entry = order[i]
  opts = opts or {}
  Safe.mutate(function()
    if not entry.frame then entry.pendingUpdate = opts; return end
    applyUpdate(entry, opts)
  end)
end

function Notification.dismiss(id)
  local i = indexOf(id)
  if not i then return end
  local entry = table.remove(order, i)
  if entry.onDismiss then pcall(entry.onDismiss) end
  Safe.mutate(function()
    if entry.spinTween then entry.spinTween:Cancel(); entry.spinTween = nil end
    if entry.frame then entry.frame:Destroy() end
    Notification.relayout()
  end)
end

function Notification.clearAll()
  for i = #order, 1, -1 do Notification.dismiss(order[i].id) end
end

function Notification.count() return #order end

return Notification
