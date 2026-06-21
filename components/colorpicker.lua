-- Deps injected via Init(R). Swatch row + an overlay HSV popover (minimal interaction;
-- full drag-to-pick is a polish follow-up). Value persists as an {r,g,b} array (JSON-safe).
local ColorPicker = {}
local Create, DefaultTheme, Maid, Overlay, Flag
function ColorPicker.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Overlay = R.Overlay; Flag = R.Flag
end

local function toArr(c) return { c.R8 or math.floor(c.R * 255), c.G8 or math.floor(c.G * 255), c.B8 or math.floor(c.B * 255) } end
local function toColor(v)
  if type(v) == "table" and v[1] then return Color3.fromRGB(v[1], v[2], v[3]) end
  return v
end

function ColorPicker.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local color = opts.Default or Color3.fromRGB(255, 255, 255)
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
      Position = UDim2.new(0, ap and ap.X or 0, 0, (ap and ap.Y or 0) + 36), Size = UDim2.new(0, 180, 0, 150),
      ZIndex = 1001, Create.corner(theme.Radius.md), Create.padding({ all = 8 }) })
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = popover })
    local sv = Create("ImageButton", { Name = "SV", AutoButtonColor = false, Text = "",
      BackgroundColor3 = color, ZIndex = 1002, Size = UDim2.new(1, 0, 0, 110), Parent = popover, Create.corner(theme.Radius.sm) })
    local hue = Create("ImageButton", { Name = "Hue", AutoButtonColor = false, Text = "",
      BackgroundColor3 = theme.Colors.surface, ZIndex = 1002, Size = UDim2.new(1, 0, 0, 18),
      Position = UDim2.new(0, 0, 0, 116), Parent = popover, Create.corner(theme.Radius.sm) })
    local h0 = 0
    sv.MouseButton1Click:Connect(function() api.SetColor(Color3.fromHSV(h0, 0.8, 1)); sv.BackgroundColor3 = color end)
    hue.MouseButton1Click:Connect(function() h0 = (h0 + 0.1) % 1; api.SetColor(Color3.fromHSV(h0, 0.8, 1)); sv.BackgroundColor3 = color end)
    Overlay.mount(popover)
  end
  function api.Close() if popover then popover:Destroy(); popover = nil end end
  function api.Destroy() api.Close(); maid:DoCleanup() end

  maid:Give(btn.MouseButton1Click:Connect(function() if popover then api.Close() else api.Open() end end))
  maid:Give(btn)
  maid:Give(function() api.Close() end)
  return api
end

return ColorPicker
