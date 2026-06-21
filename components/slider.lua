-- Deps injected via Init(R).
local Slider = {}
local Create, DefaultTheme, Animate, Maid, Flag
local UserInputService = game:GetService("UserInputService")
function Slider.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid; Flag = R.Flag
end
function Slider.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local minV = opts.Min or 0
  local maxV = opts.Max or 100
  local step = opts.Step or 1
  local value = minV
  local onChanged

  local function snap(n)
    n = tonumber(n) or value
    if step and step > 0 then n = math.floor((n - minV) / step + 0.5) * step + minV end
    if n < minV then n = minV elseif n > maxV then n = maxV end
    return n
  end

  local hasDesc = opts.Description ~= nil and opts.Description ~= ""
  local root = Create("Frame", { Name = "SliderRow", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, opts.Text and (hasDesc and 58 or 44) or 24), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent })
  local valueLabel
  if opts.Text then
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Text,
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
      TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans, Size = UDim2.new(1, -40, 0, 16), Parent = root })
    valueLabel = Create("TextLabel", { Name = "Value", BackgroundTransparency = 1, Text = "0",
      TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Right,
      TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans, Size = UDim2.new(0, 40, 0, 16),
      Position = UDim2.new(1, -40, 0, 0), Parent = root })
    if hasDesc then
      Create("TextLabel", { Name = "Description", BackgroundTransparency = 1, Text = opts.Description,
        TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
        Position = UDim2.new(0, 0, 0, 18), Size = UDim2.new(1, -40, 0, 18), Parent = root })
    end
  end
  local track = Create("Frame", { Name = "Track", BackgroundColor3 = theme.Colors.surface, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 1, -10), Parent = root, Create.corner(3) })
  local fill = Create("Frame", { Name = "Fill", BackgroundColor3 = theme.Colors.primary, BorderSizePixel = 0,
    Size = UDim2.new(0, 0, 1, 0), Parent = track, Create.corner(3) })
  local handle = Create("Frame", { Name = "Handle", BackgroundColor3 = theme.Colors.foreground, BorderSizePixel = 0,
    Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, -6, 0.5, -6), Parent = track, Create.corner(6) })

  local function apply(v)
    value = snap(v)
    local scale = (maxV > minV) and (value - minV) / (maxV - minV) or 0
    fill.Size = UDim2.new(scale, 0, 1, 0)
    handle.Position = UDim2.new(scale, -6, 0.5, -6)
    if valueLabel then valueLabel.Text = tostring(value) end
  end
  local commit = Flag.bind(opts, snap(opts.Default or minV), apply)

  local api = { Frame = root }
  function api.GetValue() return value end
  function api.SetValue(v) commit(snap(v)); if opts.Callback then opts.Callback(value) end; if onChanged then onChanged(value) end end
  function api.OnChanged(fn) onChanged = fn end
  function api.Destroy() maid:DoCleanup() end

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    track.BackgroundColor3 = theme.Colors.surface
    fill.BackgroundColor3 = theme.Colors.primary
    handle.BackgroundColor3 = theme.Colors.foreground
    local ti = root:FindFirstChild("Title"); if ti then ti.TextColor3 = theme.Colors.foreground end
    local de = root:FindFirstChild("Description"); if de then de.TextColor3 = theme.Colors.mutedForeground end
    if valueLabel then valueLabel.TextColor3 = theme.Colors.mutedForeground end
  end)) end

  local dragging = false
  local function fromX(px)
    local ap, sz = track.AbsolutePosition, track.AbsoluteSize
    local x0 = ap and ap.X or 0
    local w = (sz and sz.X) or 1
    local t = (px - x0) / (w > 0 and w or 1)
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
    api.SetValue(minV + t * (maxV - minV))
  end
  maid:Give(track.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true; fromX(input.Position.X)
    end
  end))
  maid:Give(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
      fromX(input.Position.X)
    end
  end))
  maid:Give(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
  end))
  maid:Give(root)
  return api
end
return Slider
