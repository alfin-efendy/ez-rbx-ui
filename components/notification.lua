-- Deps injected via Init(R). Sonner-style toasts stacked in a bottom-right overlay container.
local Notification = {}
local Create, DefaultTheme, Maid, Overlay, Animate, Icons
local container
local toasts = {}
local seq = 0

function Notification.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Overlay = R.Overlay; Animate = R.Animate; Icons = R.Icons
end

local TYPE_COLOR = { info = "info", success = "success", warning = "warning", error = "destructive" }
local TYPE_ICON = { info = "info", success = "circle-check", warning = "triangle-alert", error = "circle-alert" }

local function ensureContainer()
  if container and container.Parent ~= nil then return container end
  container = Create("Frame", {
    Name = "ToastContainer", BackgroundTransparency = 1, ZIndex = 1800,
    AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.new(0, 300, 1, -32),
    Create.listLayout({ Padding = 8 }),
  })
  local layout = container:FindFirstChildOfClass("UIListLayout")
  layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
  layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
  Overlay.mount(container)
  return container
end

function Notification.show(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  ensureContainer()
  seq = seq + 1
  local id = seq
  local accent = theme.Colors[TYPE_COLOR[opts.Type or "info"]] or theme.Colors.info

  local toast = Create("Frame", {
    Name = "Toast", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = id, Parent = container,
    Create.corner(theme.Radius.md), Create.padding({ all = 10 }),
    Create.listLayout({ Padding = 4 }),
  })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = toast })
  -- title row: fixed-height (NOT a scale-height child, which would fight AutomaticSize.Y
  -- and blow the toast up to full height). Colored dot indicates the toast type.
  local titleRow = Create("Frame", { Name = "TitleRow", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 1, Parent = toast })
  local tIcon = Create("ImageLabel", { Name = "Icon", BackgroundTransparency = 1,
    Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), Parent = titleRow })
  Icons.apply(tIcon, TYPE_ICON[opts.Type or "info"] or "info", accent)
  Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Title or "",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.label.Size,
    Font = Enum.Font.BuilderSans, Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 24, 0, 0), Parent = titleRow })
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
      Size = UDim2.new(0, 96, 0, 24), LayoutOrder = 3, Parent = toast,
      Create.corner(theme.Radius.sm) })
    aBtn.MouseButton1Click:Connect(function()
      if act.Callback then pcall(act.Callback) end
      Notification.dismiss(id)
    end)
  end

  toasts[id] = { id = id, frame = toast, onDismiss = opts.OnDismiss }
  toast.BackgroundTransparency = 1
  Animate.to(toast, "base", { BackgroundTransparency = 0 })

  if (opts.Duration or 4000) > 0 then
    task.delay((opts.Duration or 4000) / 1000, function() Notification.dismiss(id) end)
  end
  return id
end

function Notification.dismiss(id)
  local entry = toasts[id]
  if not entry then return end
  toasts[id] = nil
  if entry.onDismiss then pcall(entry.onDismiss) end
  if entry.frame then entry.frame:Destroy() end
end

function Notification.clearAll()
  for id in pairs(toasts) do Notification.dismiss(id) end
end

function Notification.count()
  local n = 0; for _ in pairs(toasts) do n = n + 1 end; return n
end

return Notification
