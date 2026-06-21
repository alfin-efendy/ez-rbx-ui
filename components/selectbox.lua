-- Deps injected via Init(R).
local SelectBox = {}
local Create, DefaultTheme, Animate, Maid, Icons, Overlay, Flag

function SelectBox.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid
  Icons = R.Icons; Overlay = R.Overlay; Flag = R.Flag
end

local function contains(arr, v) for _, x in ipairs(arr) do if x == v then return true end end return false end

function SelectBox.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local options = opts.Options or {}
  local multi = opts.Multi == true
  local value = multi and (opts.Default or {}) or (opts.Default or options[1])
  local dropdown
  local onChanged = opts.Callback

  local function display()
    if multi then return (#value == 0) and "None" or table.concat(value, ", ") end
    return tostring(value or "Select")
  end

  local btn = Create("TextButton", {
    Name = "SelectBox", AutoButtonColor = false, Text = "",
    BackgroundColor3 = theme.Colors.input, BackgroundTransparency = 0,
    Size = UDim2.new(1, 0, 0, 32), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent,
    Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }),
  })
  local valueLabel = Create("TextLabel", { Name = "Value", BackgroundTransparency = 1, Text = display(),
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans, Size = UDim2.new(1, -20, 1, 0), Parent = btn })
  local caret = Create("ImageLabel", { Name = "Caret", BackgroundTransparency = 1,
    Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -14, 0.5, -7), Parent = btn })
  Icons.apply(caret, "chevron-down", theme.Colors.mutedForeground)

  local function refresh() valueLabel.Text = display() end
  local function apply(v) value = v; refresh() end
  local commit = Flag.bind(opts, value, apply)

  local api = { Frame = btn }
  function api.GetValue() return value end
  function api.SetValue(v) commit(v); if onChanged then onChanged(value) end end
  function api.SetOptions(o) options = o or {} end

  local function pick(opt)
    if multi then
      local nv = {}
      for _, x in ipairs(value) do nv[#nv + 1] = x end
      if contains(nv, opt) then
        for i, x in ipairs(nv) do if x == opt then table.remove(nv, i) break end end
      else
        nv[#nv + 1] = opt
      end
      api.SetValue(nv)
      if dropdown then api.Close(); api.Open() end -- rebuild to re-tint
    else
      api.SetValue(opt)
      api.Close()
    end
  end

  function api.Open()
    if dropdown then return end
    local pos = btn.AbsolutePosition
    local sz = btn.AbsoluteSize
    dropdown = Create("Frame", {
      Name = "SelectDropdown", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0,
      Position = UDim2.new(0, pos and pos.X or 0, 0, (pos and pos.Y or 0) + 36),
      Size = UDim2.new(0, math.max(120, sz and sz.X or 120), 0, math.min(#options * 28 + 8, 200)),
      ClipsDescendants = true, ZIndex = 1001,
      Create.corner(theme.Radius.md),
      Create.padding({ all = 4 }),
      Create.listLayout({ Padding = 2 }),
    })
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = dropdown })
    for i, opt in ipairs(options) do
      local o = Create("TextButton", { Name = "Opt", AutoButtonColor = false, Text = "",
        BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = 1, ZIndex = 1002,
        Size = UDim2.new(1, 0, 0, 26), LayoutOrder = i, Parent = dropdown, Create.corner(theme.Radius.sm),
        Create.padding({ left = 8, right = 8 }) })
      local selected = multi and contains(value, opt) or (value == opt)
      Create("TextLabel", { BackgroundTransparency = 1, Text = opt, ZIndex = 1002,
        TextColor3 = selected and theme.Colors.foreground or theme.Colors.mutedForeground,
        TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.body.Size,
        Font = Enum.Font.BuilderSans, Size = UDim2.new(1, 0, 1, 0), Parent = o })
      o.MouseButton1Click:Connect(function() pick(opt) end)
    end
    Overlay.mount(dropdown)
  end

  function api.Close()
    if dropdown then dropdown:Destroy(); dropdown = nil end
  end

  function api.Destroy() api.Close(); maid:DoCleanup() end

  maid:Give(btn.MouseButton1Click:Connect(function() if dropdown then api.Close() else api.Open() end end))
  maid:Give(btn)
  maid:Give(function() api.Close() end)
  return api
end

return SelectBox
