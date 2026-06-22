-- Deps injected via Init(R).
local NumberBox = {}
local Create, DefaultTheme, Maid, Icons, Flag, Numfmt

function NumberBox.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Icons = R.Icons; Flag = R.Flag; Numfmt = R.Numfmt
end

function NumberBox.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local minV, maxV, step = opts.Min, opts.Max, opts.Step or 1
  local value = opts.Default or 0
  local hasLabel = opts.Text ~= nil and opts.Text ~= ""
  local hasDesc = opts.Description ~= nil and opts.Description ~= ""
  local rowH = (not hasLabel) and 30 or (hasDesc and 56 or 46)

  local function clamp(n)
    n = tonumber(n) or value
    if minV then n = math.max(minV, n) end
    if maxV then n = math.min(maxV, n) end
    return n
  end

  local root = Create("Frame", { Name = "NumberBoxRow", BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = 0,
    Size = UDim2.new(1, 0, 0, rowH), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent,
    Create.corner(theme.Radius.md), Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }) })
  if hasLabel then
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Text,
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = hasDesc and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
      TextSize = theme.Font.label.Size, Font = Enum.Font.BuilderSans,
      Position = UDim2.new(0, 0, 0, hasDesc and 6 or 0),
      Size = UDim2.new(0.5, -8, hasDesc and 0 or 1, hasDesc and 18 or 0), Parent = root })
    if hasDesc then
      Create("TextLabel", { Name = "Description", BackgroundTransparency = 1, Text = opts.Description,
        TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
        Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(0.5, -8, 0, 26), Parent = root })
    end
  end
  local box = Create("Frame", { Name = "Box", BackgroundColor3 = theme.Colors.background, BorderSizePixel = 0,
    Position = hasLabel and UDim2.new(0.5, 4, 0.5, -15) or UDim2.new(0, 0, 0, 0),
    Size = hasLabel and UDim2.new(0.5, -4, 0, 30) or UDim2.new(1, 0, 0, 30),
    Parent = root, Create.corner(theme.Radius.md) })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = box })
  local function stepBtn(name, icon, x)
    local b = Create("ImageButton", { Name = name, AutoButtonColor = false, BackgroundColor3 = theme.Colors.surface,
      Size = UDim2.new(0, 26, 1, -6), Position = x, Parent = box, Create.corner(theme.Radius.sm) })
    local img = Create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14),
      Position = UDim2.new(0.5, -7, 0.5, -7), Parent = b })
    Icons.apply(img, icon, theme.Colors.primary)
    return b
  end
  local minus = stepBtn("Minus", "minus", UDim2.new(0, 3, 0.5, -12))
  local plus = stepBtn("Plus", "plus", UDim2.new(1, -29, 0.5, -12))
  local input = Create("TextBox", { Name = "Input", BackgroundTransparency = 1, Text = tostring(value),
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Center,
    TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans, ClearTextOnFocus = false,
    Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -64, 1, 0), Parent = box })

  local atMin, atMax = false, false
  local function dim(btn, off)
    local img = btn:FindFirstChildOfClass("ImageLabel")
    if img then img.ImageColor3 = off and theme.Colors.mutedForeground or theme.Colors.primary end
  end
  local function updateBounds()
    atMin = minV ~= nil and value <= minV
    atMax = maxV ~= nil and value >= maxV
    dim(minus, atMin); minus.Active = not atMin
    dim(plus, atMax); plus.Active = not atMax
  end

  local function fmt(n)
    return Numfmt.format(n, { Format = opts.Format, Decimals = opts.Decimals, Prefix = opts.Prefix, Suffix = opts.Suffix })
  end
  local focused = false
  local function render() input.Text = focused and tostring(value) or fmt(value) end
  local function apply(n) value = clamp(n); render(); updateBounds() end
  local commit = Flag.bind(opts, clamp(opts.Default or 0), apply)
  local function set(n) commit(clamp(n)); if opts.Callback then opts.Callback(value) end end

  maid:Give(minus.MouseButton1Click:Connect(function() if atMin then return end; set(value - step) end))
  maid:Give(plus.MouseButton1Click:Connect(function() if atMax then return end; set(value + step) end))
  maid:Give(input.Focused:Connect(function() focused = true; input.Text = tostring(value) end))
  maid:Give(input.FocusLost:Connect(function()
    focused = false
    local parsed = Numfmt.parse(input.Text, { Prefix = opts.Prefix, Suffix = opts.Suffix })
    if parsed ~= nil then set(parsed) else render() end
  end))
  maid:Give(root)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    root.BackgroundColor3 = theme.Colors.surface
    box.BackgroundColor3 = theme.Colors.background
    local bs = box:FindFirstChildOfClass("UIStroke"); if bs then bs.Color = theme.Colors.border end
    input.TextColor3 = theme.Colors.foreground
    local ti = root:FindFirstChild("Title"); if ti then ti.TextColor3 = theme.Colors.foreground end
    local de = root:FindFirstChild("Description"); if de then de.TextColor3 = theme.Colors.mutedForeground end
    for _, c in ipairs(box:GetChildren()) do
      if c:IsA("ImageButton") then c.BackgroundColor3 = theme.Colors.surface
        local g = c:FindFirstChildOfClass("ImageLabel"); if g then g.ImageColor3 = theme.Colors.primary end end
    end
    updateBounds()
  end)) end

  return {
    Frame = root,
    GetValue = function() return value end,
    SetValue = function(n) set(n) end,
    SetMin = function(n) minV = n; set(value) end,
    SetMax = function(n) maxV = n; set(value) end,
    Destroy = function() maid:DoCleanup() end,
  }
end

return NumberBox
