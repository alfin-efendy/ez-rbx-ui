-- Deps injected via Init(R). Swatch row + an overlay HSV picker (SV square + hue slider,
-- click/drag). Value persists as an {r,g,b} array (JSON-safe).
local ColorPicker = {}
local Create, DefaultTheme, Maid, Overlay, Flag, Animate
local UserInputService = game:GetService("UserInputService")
function ColorPicker.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Overlay = R.Overlay; Flag = R.Flag; Animate = R.Animate
end

-- Color3 channels are .R/.G/.B (0-1 floats) in real Roblox.
local function toArr(c) return { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) } end
local function toColor(v)
  if type(v) == "table" and v[1] then return Color3.fromRGB(v[1], v[2], v[3]) end
  return v
end
local function rgbToHsv(c)
  local r, g, b = c.R, c.G, c.B
  local mx, mn = math.max(r, g, b), math.min(r, g, b)
  local d = mx - mn
  local hh = 0
  if d > 0 then
    if mx == r then hh = ((g - b) / d) % 6
    elseif mx == g then hh = (b - r) / d + 2
    else hh = (r - g) / d + 4 end
    hh = hh / 6
  end
  return hh, (mx == 0) and 0 or d / mx, mx
end
local function clamp01(n) if n < 0 then return 0 elseif n > 1 then return 1 end return n end

function ColorPicker.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local color = opts.Default or Color3.fromRGB(255, 255, 255)
  local hsvH, hsvS, hsvV = rgbToHsv(color)
  local popover
  local onChanged = opts.Callback

  local btn = Create("TextButton", { Name = "ColorPicker", AutoButtonColor = false, Text = "",
    BackgroundColor3 = theme.Colors.surface, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent, Create.corner(theme.Radius.md), Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }) })
  Create("TextLabel", { Name = "Label", BackgroundTransparency = 1, Text = opts.Text or "Color",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.label.Size,
    Font = Enum.Font.BuilderSans, Size = UDim2.new(1, -40, 1, 0), Parent = btn })
  local swatch = Create("Frame", { Name = "Swatch", BackgroundColor3 = color, BorderSizePixel = 0,
    Size = UDim2.new(0, 28, 0, 18), Position = UDim2.new(1, -28, 0.5, -9), Parent = btn, Create.corner(theme.Radius.sm) })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = swatch })

  local function apply(v) color = toColor(v); swatch.BackgroundColor3 = color end
  local commit = Flag.bind(opts, toArr(color), apply)

  local api = { Frame = btn }
  function api.GetColor() return color end
  function api.SetColor(c) commit(toArr(c)); if onChanged then onChanged(color) end end

  function api.Open()
    if popover then return end
    local ap = btn.AbsolutePosition
    popover = Create("Frame", { Name = "ColorPopover", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0,
      Position = UDim2.new(0, ap and ap.X or 0, 0, (ap and ap.Y or 0) + 36), Size = UDim2.new(0, 180, 0, 152),
      ZIndex = 1001, Create.corner(theme.Radius.md), Create.padding({ all = 8 }) })
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = popover })

    -- SV square: hue-colored base + white(sat) overlay + black(value) overlay
    local sv = Create("ImageButton", { Name = "SV", AutoButtonColor = false,
      BackgroundColor3 = Color3.fromHSV(hsvH, 1, 1), ZIndex = 1002, Size = UDim2.new(1, 0, 0, 110),
      Parent = popover, Create.corner(theme.Radius.sm), ClipsDescendants = true })
    local satOverlay = Create("Frame", { Name = "Sat", BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      Size = UDim2.new(1, 0, 1, 0), ZIndex = 1003, Parent = sv,
      Create("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) }) })
    local valOverlay = Create("Frame", { Name = "Val", BackgroundColor3 = Color3.fromRGB(0, 0, 0),
      Size = UDim2.new(1, 0, 1, 0), ZIndex = 1004, Parent = sv,
      Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }) })
    local svDot = Create("Frame", { Name = "Dot", BackgroundColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 1005,
      Size = UDim2.new(0, 8, 0, 8), AnchorPoint = Vector2.new(0.5, 0.5), Parent = sv, Create.corner(4) })

    -- hue slider with rainbow gradient
    local hue = Create("ImageButton", { Name = "Hue", AutoButtonColor = false, ZIndex = 1002,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(1, 0, 0, 16),
      Position = UDim2.new(0, 0, 0, 120), Parent = popover, Create.corner(theme.Radius.sm) })
    Create("UIGradient", { Parent = hue, Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
      ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
      ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
      ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    }) })
    local hueDot = Create("Frame", { Name = "HueDot", BackgroundColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 1003,
      Size = UDim2.new(0, 4, 1, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(hsvH, 0, 0.5, 0), Parent = hue, Create.corner(2) })

    local function refreshUI()
      sv.BackgroundColor3 = Color3.fromHSV(hsvH, 1, 1)
      svDot.Position = UDim2.new(hsvS, 0, 1 - hsvV, 0)
      hueDot.Position = UDim2.new(hsvH, 0, 0.5, 0)
      api.SetColor(Color3.fromHSV(hsvH, hsvS, hsvV))
    end
    refreshUI()

    local dragTarget
    local function updateFromSV(px, py)
      local p, sz = sv.AbsolutePosition, sv.AbsoluteSize
      hsvS = clamp01(((px - (p and p.X or 0)) / ((sz and sz.X) or 1)))
      hsvV = 1 - clamp01(((py - (p and p.Y or 0)) / ((sz and sz.Y) or 1)))
      refreshUI()
    end
    local function updateFromHue(px)
      local p, sz = hue.AbsolutePosition, hue.AbsoluteSize
      hsvH = clamp01(((px - (p and p.X or 0)) / ((sz and sz.X) or 1)))
      refreshUI()
    end
    maid:Give(sv.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragTarget = "sv"; updateFromSV(input.Position.X, input.Position.Y)
      end
    end))
    maid:Give(hue.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragTarget = "hue"; updateFromHue(input.Position.X)
      end
    end))
    maid:Give(UserInputService.InputChanged:Connect(function(input)
      if not dragTarget then return end
      if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragTarget == "sv" then updateFromSV(input.Position.X, input.Position.Y) else updateFromHue(input.Position.X) end
      end
    end))
    maid:Give(UserInputService.InputEnded:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragTarget = nil end
    end))

    Overlay.mount(popover)
    Overlay.trackPopover(api.Close)
    Animate.pop(popover, "base")
  end
  function api.Close()
    if popover then popover:Destroy(); popover = nil end
    Overlay.untrackPopover(api.Close)
  end
  function api.Destroy() api.Close(); maid:DoCleanup() end

  maid:Give(btn.MouseButton1Click:Connect(function() if popover then api.Close() else api.Open() end end))
  maid:Give(btn)
  maid:Give(function() api.Close() end)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    btn.BackgroundColor3 = theme.Colors.surface
    local lab = btn:FindFirstChild("Label"); if lab then lab.TextColor3 = theme.Colors.foreground end
    local st = swatch:FindFirstChildOfClass("UIStroke"); if st then st.Color = theme.Colors.border end
  end)) end

  return api
end

return ColorPicker
