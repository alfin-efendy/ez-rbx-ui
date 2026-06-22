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

local function countOptions(arr)
  local n = 0
  for _, raw in ipairs(arr) do if not normOpt(raw).divider then n = n + 1 end end
  return n
end

function SelectBox.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local options = opts.Options or {}
  local multi = opts.Multi == true
  -- For per-item options the entries are tables ({ Value, Icon, ... }); the stored
  -- value must be the option's value, not the raw option table (else display() would
  -- tostring a table address and isSelected/Flag would never match).
  local function firstValue() return options[1] ~= nil and normOpt(options[1]).value or nil end
  local value = multi and (opts.Default or {}) or (opts.Default ~= nil and opts.Default or firstValue())
  local dropdown
  local optButtons = {} -- { { btn = TextButton, text = optionName } } for live search
  local onChanged = opts.Callback

  local function display()
    if multi then
      if #value == 0 then return "None" end
      local shown = {}
      for i = 1, math.min(2, #value) do shown[i] = tostring(value[i]) end
      local s = table.concat(shown, ", ")
      if #value > 2 then s = s .. " +" .. (#value - 2) end
      return s
    end
    return tostring(value or "Select")
  end

  local hasDesc = opts.Description ~= nil and opts.Description ~= ""
  local btn = Create("TextButton", {
    Name = "SelectBox", AutoButtonColor = false, Text = "",
    BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = 0,
    Size = UDim2.new(1, 0, 0, hasDesc and 52 or 38), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent,
    Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }),
  })
  if opts.Text then
    Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Text,
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = hasDesc and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
      TextSize = theme.Font.label.Size, Font = Enum.Font.BuilderSans,
      Position = UDim2.new(0, 0, 0, hasDesc and 8 or 0),
      Size = UDim2.new(0.5, -8, hasDesc and 0 or 1, hasDesc and 18 or 0), Parent = btn })
    if hasDesc then
      Create("TextLabel", { Name = "Description", BackgroundTransparency = 1, Text = opts.Description,
        TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
        Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(0.5, -8, 0, 18), Parent = btn })
    end
  end
  local field = Create("Frame", { Name = "Field", BackgroundColor3 = theme.Colors.background, BorderSizePixel = 0, Active = false,
    Size = opts.Text and UDim2.new(0.5, -4, 0, 26) or UDim2.new(1, 0, 0, 26),
    Position = opts.Text and UDim2.new(0.5, 4, 0.5, -13) or UDim2.new(0, 0, 0.5, -13),
    Parent = btn, Create.corner(theme.Radius.sm) })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = field })
  local valueLabel = Create("TextLabel", { Name = "Value", BackgroundTransparency = 1, Text = display(),
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 8, 0, 0), Parent = field })
  local caret = Create("ImageLabel", { Name = "Caret", BackgroundTransparency = 1,
    Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -20, 0.5, -7), Parent = field })
  Icons.apply(caret, "chevron-down", theme.Colors.primary)

  local fieldIcon = Create("ImageLabel", { Name = "FieldIcon", BackgroundTransparency = 1, Visible = false,
    Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7), Parent = field })
  local clearBtn = Create("ImageButton", { Name = "Clear", BackgroundTransparency = 1, Visible = false,
    Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -38, 0.5, -7), Parent = field })
  Icons.apply(clearBtn, "x", theme.Colors.mutedForeground)

  local function selectedIcon()
    if multi then return nil end
    for _, raw in ipairs(options) do local e = normOpt(raw); if e.value == value then return e.icon end end
    return nil
  end
  local function relayout()
    local left = fieldIcon.Visible and 26 or 8
    local right = clearBtn.Visible and 38 or 24
    valueLabel.Position = UDim2.new(0, left, 0, 0)
    valueLabel.Size = UDim2.new(1, -(left + right), 1, 0)
  end

  local disabled = false
  local function setDisabled(b)
    disabled = b and true or false
    valueLabel.TextColor3 = disabled and theme.Colors.mutedForeground or theme.Colors.foreground
    Icons.apply(caret, "chevron-down", disabled and theme.Colors.mutedForeground or theme.Colors.primary)
    field.BackgroundTransparency = disabled and 0.4 or 0
  end

  local function refresh()
    local ic = selectedIcon()
    if ic then Icons.apply(fieldIcon, ic, theme.Colors.foreground); fieldIcon.Visible = true
    else fieldIcon.Visible = false end
    clearBtn.Visible = multi and #value > 0
    relayout()
    valueLabel.Text = display()
  end
  local function apply(v) value = v; refresh() end
  local commit = Flag.bind(opts, value, apply)

  local api = { Frame = btn }
  function api.GetValue() return value end
  function api.SetValue(v) commit(v); if onChanged then onChanged(value) end end
  function api.SetOptions(o)
    options = o or {}
    local function present(v)
      for _, raw in ipairs(options) do
        local e = normOpt(raw)
        if not e.divider and e.value == v then return true end
      end
      return false
    end
    if multi then
      local nv = {}
      for _, v in ipairs(value) do if present(v) then nv[#nv + 1] = v end end
      value = nv
    elseif value ~= nil and not present(value) then
      value = opts.AllowNone and nil or firstValue()
    end
    refresh()
  end
  function api.SetDisabled(b) setDisabled(b) end

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
    local searchable
    if opts.Searchable ~= nil then searchable = opts.Searchable == true
    else searchable = countOptions(options) > 5 end
    local pos = btn.AbsolutePosition or { X = 0, Y = 0 }
    local sz = btn.AbsoluteSize or { X = 140, Y = 38 }
    local vp = Overlay.viewport()
    local width = math.max(140, sz.X or 140)
    local ddH = math.min(#options * 28 + (searchable and 44 or 8), 240)
    local below = (pos.Y or 0) + (sz.Y or 38) + 4
    local openUp = (below + ddH > (vp.Y or 1080)) and ((pos.Y or 0) - 4 - ddH >= 0)
    local y = openUp and ((pos.Y or 0) - 4 - ddH) or below
    local x = math.max(0, math.min(pos.X or 0, (vp.X or 1920) - width - 4))
    dropdown = Create("Frame", {
      Name = "SelectDropdown", BackgroundColor3 = theme.Colors.card, BorderSizePixel = 0,
      Position = UDim2.new(0, x, 0, y),
      Size = UDim2.new(0, width, 0, ddH),
      ClipsDescendants = true, ZIndex = 1001,
      Create.corner(theme.Radius.md),
      Create.padding({ all = 4 }),
      Create.listLayout({ Padding = 2 }),
    })
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = dropdown })

    -- search box (filters options live) — only for longer lists, or when forced
    if searchable then
      local searchBox = Create("Frame", { Name = "Search", BackgroundColor3 = theme.Colors.surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 0, ZIndex = 1002, Parent = dropdown,
        Create.corner(theme.Radius.sm), Create.padding({ left = 8, right = 8 }) })
      local searchInput = Create("TextBox", { Name = "Input", BackgroundTransparency = 1, Text = "",
        PlaceholderText = "Search…", PlaceholderColor3 = theme.Colors.mutedForeground, TextColor3 = theme.Colors.foreground,
        TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
        ClearTextOnFocus = false, ZIndex = 1002, Size = UDim2.new(1, 0, 1, 0), Parent = searchBox })
      searchInput:GetPropertyChangedSignal("Text"):Connect(function() api.Filter(searchInput.Text) end)
    end

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

  maid:Give(btn.MouseButton1Click:Connect(function()
    if disabled then return end
    if dropdown then api.Close() else api.Open() end
  end))
  maid:Give(clearBtn.MouseButton1Click:Connect(function() if multi then api.SetValue({}) end end))
  maid:Give(btn)
  maid:Give(function() api.Close() end)
  if opts.Disabled then setDisabled(true) end

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    btn.BackgroundColor3 = theme.Colors.surface
    field.BackgroundColor3 = theme.Colors.background
    local fs = field:FindFirstChildOfClass("UIStroke"); if fs then fs.Color = theme.Colors.border end
    valueLabel.TextColor3 = theme.Colors.foreground
    local ti = btn:FindFirstChild("Title"); if ti then ti.TextColor3 = theme.Colors.foreground end
    local de = btn:FindFirstChild("Description"); if de then de.TextColor3 = theme.Colors.mutedForeground end
    Icons.apply(caret, "chevron-down", theme.Colors.primary)
    Icons.apply(clearBtn, "x", theme.Colors.mutedForeground)
    if fieldIcon.Visible then local ic = selectedIcon(); if ic then Icons.apply(fieldIcon, ic, theme.Colors.foreground) end end
    setDisabled(disabled)
  end)) end

  return api
end

return SelectBox
