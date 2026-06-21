-- Deps injected via Init(R).
local NumberBox = {}
local Create, DefaultTheme, Maid, Icons, Flag

function NumberBox.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Icons = R.Icons; Flag = R.Flag
end

function NumberBox.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local minV, maxV, step = opts.Min, opts.Max, opts.Step or 1
  local value = opts.Default or 0
  local hasLabel = opts.Text ~= nil and opts.Text ~= ""

  local function clamp(n)
    n = tonumber(n) or value
    if minV then n = math.max(minV, n) end
    if maxV then n = math.min(maxV, n) end
    return n
  end

  local root = Create("Frame", { Name = "NumberBoxRow", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, hasLabel and 50 or 30), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent })
  if hasLabel then
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Text,
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
      TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      Size = UDim2.new(1, 0, 0, 18), Parent = root })
  end
  local box = Create("Frame", { Name = "Box", BackgroundColor3 = theme.Colors.input, BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, hasLabel and 20 or 0), Size = UDim2.new(1, 0, 0, 30),
    Parent = root, Create.corner(theme.Radius.md) })
  local function stepBtn(name, icon, x)
    local b = Create("ImageButton", { Name = name, AutoButtonColor = false, BackgroundColor3 = theme.Colors.surface,
      Size = UDim2.new(0, 26, 1, -6), Position = x, Parent = box, Create.corner(theme.Radius.sm) })
    local img = Create("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14),
      Position = UDim2.new(0.5, -7, 0.5, -7), Parent = b })
    Icons.apply(img, icon, theme.Colors.foreground)
    return b
  end
  local minus = stepBtn("Minus", "minus", UDim2.new(0, 3, 0.5, -12))
  local plus = stepBtn("Plus", "plus", UDim2.new(1, -29, 0.5, -12))
  local input = Create("TextBox", { Name = "Input", BackgroundTransparency = 1, Text = tostring(value),
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Center,
    TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans, ClearTextOnFocus = false,
    Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -64, 1, 0), Parent = box })

  local function apply(n) value = clamp(n); input.Text = tostring(value) end
  local commit = Flag.bind(opts, clamp(opts.Default or 0), apply)
  local function set(n) commit(clamp(n)); if opts.Callback then opts.Callback(value) end end

  maid:Give(minus.MouseButton1Click:Connect(function() set(value - step) end))
  maid:Give(plus.MouseButton1Click:Connect(function() set(value + step) end))
  maid:Give(input.FocusLost:Connect(function() set(input.Text) end))
  maid:Give(root)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    box.BackgroundColor3 = theme.Colors.input
    input.TextColor3 = theme.Colors.foreground
    local ti = root:FindFirstChild("Title"); if ti then ti.TextColor3 = theme.Colors.foreground end
    for _, c in ipairs(box:GetChildren()) do
      if c:IsA("ImageButton") then c.BackgroundColor3 = theme.Colors.surface
        local g = c:FindFirstChildOfClass("ImageLabel"); if g then g.ImageColor3 = theme.Colors.foreground end end
    end
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
