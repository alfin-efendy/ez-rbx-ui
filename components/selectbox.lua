-- Deps injected via Init(R).
local SelectBox = {}
local Create, DefaultTheme, Animate, Maid, Icons, Overlay, Flag

function SelectBox.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate; Maid = R.Maid
  Icons = R.Icons; Overlay = R.Overlay; Flag = R.Flag
end

local function contains(arr, v) for _, x in ipairs(arr) do if x == v then return true end end return false end

local function normOpt(o)
  if type(o) == "table" then return { value = o.Value or o.value, icon = o.Icon, desc = o.Desc, divider = o.Divider == true } end
  return { value = o }
end

function SelectBox.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local options = opts.Options or {}
  local multi = opts.Multi == true
  local value = multi and (opts.Default or {}) or (opts.Default or options[1])
  local dropdown
  local optButtons = {} -- { { btn = TextButton, text = optionName } } for live search
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
  if opts.Text then
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Text,
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
      TextSize = theme.Font.label.Size, Font = Enum.Font.BuilderSans, Size = UDim2.new(0.5, -8, 1, 0), Parent = btn })
  end
  local valueLabel = Create("TextLabel", { Name = "Value", BackgroundTransparency = 1, Text = display(),
    TextColor3 = opts.Text and theme.Colors.mutedForeground or theme.Colors.foreground,
    TextXAlignment = opts.Text and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
    TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans,
    Size = opts.Text and UDim2.new(0.5, -28, 1, 0) or UDim2.new(1, -20, 1, 0),
    Position = opts.Text and UDim2.new(0.5, 8, 0, 0) or UDim2.new(0, 0, 0, 0), Parent = btn })
  local caret = Create("ImageLabel", { Name = "Caret", BackgroundTransparency = 1,
    Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -14, 0.5, -7), Parent = btn })
  Icons.apply(caret, "chevron-down", theme.Colors.mutedForeground)

  local function refresh() valueLabel.Text = display() end
  local function apply(v) value = v; refresh() end
  local commit = Flag.bind(opts, value, apply)

  local api = { Frame = btn }
  function api.GetValue() return value end
  function api.SetValue(v) commit(v); if onChanged then onChanged(value) end end
  function api.SetOptions(o) options = o or {}; refresh() end

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
      if opts.AllowNone and value == opt then
        api.SetValue(nil)
      else
        api.SetValue(opt)
      end
      api.Close()
    end
  end

  local function isSelected(opt) return multi and contains(value, opt) or (value == opt) end

  function api.Filter(query)
    query = (query or ""):lower()
    for _, e in ipairs(optButtons) do
      e.btn.Visible = (query == "" or e.text:lower():find(query, 1, true) ~= nil)
    end
  end

  function api.Open()
    if dropdown then return end
    optButtons = {}
    local pos = btn.AbsolutePosition
    local sz = btn.AbsoluteSize
    dropdown = Create("Frame", {
      Name = "SelectDropdown", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0,
      Position = UDim2.new(0, pos and pos.X or 0, 0, (pos and pos.Y or 0) + 36),
      Size = UDim2.new(0, math.max(140, sz and sz.X or 140), 0, math.min(#options * 28 + 44, 240)),
      ClipsDescendants = true, ZIndex = 1001,
      Create.corner(theme.Radius.md),
      Create.padding({ all = 4 }),
      Create.listLayout({ Padding = 2 }),
    })
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = dropdown })

    -- search box (filters options live)
    local searchBox = Create("Frame", { Name = "Search", BackgroundColor3 = theme.Colors.surface, BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 0, ZIndex = 1002, Parent = dropdown,
      Create.corner(theme.Radius.sm), Create.padding({ left = 8, right = 8 }) })
    local searchInput = Create("TextBox", { Name = "Input", BackgroundTransparency = 1, Text = "",
      PlaceholderText = "Search…", PlaceholderColor3 = theme.Colors.mutedForeground, TextColor3 = theme.Colors.foreground,
      TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      ClearTextOnFocus = false, ZIndex = 1002, Size = UDim2.new(1, 0, 1, 0), Parent = searchBox })
    searchInput:GetPropertyChangedSignal("Text"):Connect(function() api.Filter(searchInput.Text) end)

    for i, raw in ipairs(options) do
      local e = normOpt(raw)
      if e.divider then
        Create("Frame", { Name = "Divider", BackgroundColor3 = theme.Colors.border, BorderSizePixel = 0,
          Size = UDim2.new(1, -8, 0, 1), LayoutOrder = i, ZIndex = 1002, Parent = dropdown })
      else
        local rowH = e.desc and 38 or 26
        local sel = isSelected(e.value)
        local o = Create("TextButton", { Name = "Opt", AutoButtonColor = false, Text = "",
          BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = sel and 0 or 1, ZIndex = 1002,
          Size = UDim2.new(1, 0, 0, rowH), LayoutOrder = i, Parent = dropdown, Create.corner(theme.Radius.sm),
          Create.padding({ left = 6, right = 6 }) })
        o:SetAttribute("OptValue", e.value)
        local check = Create("ImageLabel", { Name = "Check", BackgroundTransparency = 1, ZIndex = 1003,
          Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 0, 0.5, -7), Parent = o })
        if sel then Icons.apply(check, "check", theme.Colors.foreground) else check.Visible = false end
        local textX = 20
        if e.icon then
          local lead = Create("ImageLabel", { Name = "Lead", BackgroundTransparency = 1, ZIndex = 1003,
            Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 20, 0.5, -7), Parent = o })
          Icons.apply(lead, e.icon, theme.Colors.foreground)
          textX = 40
        end
        Create("TextLabel", { Name = "OptLabel", BackgroundTransparency = 1, Text = e.value, ZIndex = 1003,
          TextColor3 = theme.Colors.foreground,
          TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans,
          Size = UDim2.new(1, -textX - 4, e.desc and 0 or 1, e.desc and 16 or 0),
          Position = UDim2.new(0, textX, 0, e.desc and 4 or 0), Parent = o })
        if e.desc then
          Create("TextLabel", { Name = "Desc", BackgroundTransparency = 1, Text = e.desc, ZIndex = 1003,
            TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
            Size = UDim2.new(1, -textX - 4, 0, 14), Position = UDim2.new(0, textX, 0, 20), Parent = o })
        end
        o.MouseButton1Click:Connect(function() pick(e.value) end)
        optButtons[#optButtons + 1] = { btn = o, text = tostring(e.value) .. " " .. tostring(e.desc or "") }
      end
    end
    Overlay.mount(dropdown)
    Overlay.trackPopover(api.Close)
  end

  function api.Close()
    if dropdown then dropdown:Destroy(); dropdown = nil end
    optButtons = {}
    Overlay.untrackPopover(api.Close)
  end

  function api.Destroy() api.Close(); maid:DoCleanup() end

  maid:Give(btn.MouseButton1Click:Connect(function() if dropdown then api.Close() else api.Open() end end))
  maid:Give(btn)
  maid:Give(function() api.Close() end)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    btn.BackgroundColor3 = theme.Colors.input
    valueLabel.TextColor3 = opts.Text and theme.Colors.mutedForeground or theme.Colors.foreground
    local ti = btn:FindFirstChild("Title"); if ti then ti.TextColor3 = theme.Colors.foreground end
    Icons.apply(caret, "chevron-down", theme.Colors.mutedForeground)
  end)) end

  return api
end

return SelectBox
