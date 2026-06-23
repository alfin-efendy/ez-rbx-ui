-- Deps injected via Init(R).
local TweenService = game:GetService("TweenService")
local TextBox = {}
local Create, DefaultTheme, Maid, Icons, Flag, Animate, Safe

function TextBox.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Icons = R.Icons; Flag = R.Flag; Animate = R.Animate; Safe = R.Safe
end

-- compact inline-button palette (mirrors components/button.lua)
local function btnPalette(theme, variant)
  if variant == "destructive" then return theme.Colors.destructive, theme.Colors.primaryForeground end
  if variant == "secondary" then return theme.Colors.surface, theme.Colors.foreground end
  if variant == "outline" then return theme.Colors.card, theme.Colors.foreground, theme.Colors.border end
  if variant == "ghost" then return theme.Colors.card, theme.Colors.foreground end
  return theme.Colors.primary, theme.Colors.primaryForeground -- default
end

function TextBox.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local hasLabel = opts.Text ~= nil and opts.Text ~= ""
  local hasDesc = opts.Description ~= nil and opts.Description ~= ""
  local fullWidth = (opts.FullWidth and hasLabel) and true or false

  -- ---- geometry -------------------------------------------------------------
  -- FullWidth boxes are taller (36) with breathing room above and below the box;
  -- compact boxes stay 30 and vertically centered in their fixed row.
  local boxH = fullWidth and 36 or 30
  local boxX, boxW, boxTop, baseH, titleTop, descTop
  if not hasLabel then
    boxX, boxW, boxTop, baseH = UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, boxH), 0, boxH
  elseif fullWidth then
    -- top margin so the label doesn't hug the row's top edge
    titleTop = 12
    descTop = titleTop + 22
    boxTop = titleTop + (hasDesc and 44 or 26)
    boxX, boxW, baseH = UDim2.new(0, 0, 0, boxTop), UDim2.new(1, 0, 0, boxH), boxTop + boxH + 12
  else
    baseH = hasDesc and 56 or 46
    boxTop = math.floor((baseH - boxH) / 2)
    boxX, boxW = UDim2.new(0.5, 4, 0, boxTop), UDim2.new(0.5, -4, 0, boxH)
  end

  -- ---- shared state ---------------------------------------------------------
  local real = opts.Default or ""
  local masked = opts.Password and true or false
  local revealed = false
  local suppress = false
  local state = { focused = false, invalid = false }
  local themed = {}                    -- recolor closures, replayed on accent change
  local function reTheme() for _, fn in ipairs(themed) do fn() end end
  local api = {}                       -- returned control; buttons capture it for the ctl arg

  -- ---- root + label ---------------------------------------------------------
  local root = Create("Frame", {
    Name = "TextBoxRow", BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = 0,
    Size = UDim2.new(1, 0, 0, baseH), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent,
    Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }),
  })
  themed[#themed + 1] = function() root.BackgroundColor3 = theme.Colors.surface end

  if hasLabel then
    local title = Create("TextLabel", { Name = "Title", BackgroundTransparency = 1, Text = opts.Text,
      TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = (hasDesc or fullWidth) and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
      TextSize = theme.Font.label.Size, Font = Enum.Font.BuilderSans,
      Position = fullWidth and UDim2.new(0, 0, 0, titleTop) or UDim2.new(0, 0, 0, hasDesc and 6 or 0),
      Size = fullWidth and UDim2.new(1, 0, 0, 18)
        or UDim2.new(0.5, -8, hasDesc and 0 or 1, hasDesc and 18 or 0),
      Parent = root })
    themed[#themed + 1] = function() title.TextColor3 = theme.Colors.foreground end
    if hasDesc then
      local desc = Create("TextLabel", { Name = "Description", BackgroundTransparency = 1, Text = opts.Description,
        TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
        Position = fullWidth and UDim2.new(0, 0, 0, descTop) or UDim2.new(0, 0, 0, 26),
        Size = fullWidth and UDim2.new(1, 0, 0, 18) or UDim2.new(0.5, -8, 0, 26), Parent = root })
      themed[#themed + 1] = function() desc.TextColor3 = theme.Colors.mutedForeground end
    end
  end

  -- ---- box (horizontal flex row) -------------------------------------------
  local box = Create("Frame", {
    Name = "Box", BackgroundColor3 = theme.Colors.background, BorderSizePixel = 0,
    Position = boxX, Size = boxW, Parent = root, Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }),
    Create.listLayout({ FillDirection = Enum.FillDirection.Horizontal, Padding = 6 }),
  })
  themed[#themed + 1] = function() box.BackgroundColor3 = theme.Colors.background end
  box:FindFirstChildOfClass("UIListLayout").VerticalAlignment = Enum.VerticalAlignment.Center

  local stroke = Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = box })
  local function strokeColor()
    if state.invalid then return theme.Colors.destructive end
    if state.focused then return theme.Colors.ring end
    return theme.Colors.border
  end
  themed[#themed + 1] = function() stroke.Color = strokeColor() end

  -- ---- input (flex-fills) ---------------------------------------------------
  local input = Create("TextBox", {
    Name = "Input", BackgroundTransparency = 1, Text = real,
    PlaceholderText = opts.Placeholder or "", PlaceholderColor3 = theme.Colors.mutedForeground,
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans, ClearTextOnFocus = false,
    -- LayoutOrder 3 sits between leading addons (icon=1, prefix=2) and all trailing
    -- addons (suffix=4, trailing icon=5, buttons=6+, eye/clear/copy, spinner). The
    -- UIFlexItem makes it grow to fill the gap, pushing trailing addons to the right.
    TextEditable = not opts.Copyable, LayoutOrder = 3, Size = UDim2.new(0, 0, 1, 0), Parent = box,
    Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }),
  })
  themed[#themed + 1] = function()
    input.TextColor3 = theme.Colors.foreground; input.PlaceholderColor3 = theme.Colors.mutedForeground
  end

  -- ---- value machinery ------------------------------------------------------
  local function display() return (masked and not revealed) and string.rep("*", #real) or real end
  -- Only reassign Input.Text when the rendered value actually differs from what's
  -- already shown. Reassigning on every keystroke resets the caret and makes it
  -- flicker/jump; with this guard, ordinary (unmasked) typing never touches Text.
  local function render()
    local d = display()
    if input.Text == d then return end
    Safe.mutate(function()
      suppress = true
      input.Text = d
      if masked and not revealed then input.CursorPosition = #d + 1 end
      suppress = false
    end)
  end
  local function apply(v)
    real = tostring(v or "")
    if opts.MaxLength and #real > opts.MaxLength then real = real:sub(1, opts.MaxLength) end
    render()
  end
  local commit = Flag.bind(opts, opts.Default or "", apply)

  maid:Give(input:GetPropertyChangedSignal("Text"):Connect(function()
    if suppress then return end
    local vis = input.Text
    if masked and not revealed then
      if #vis > #real then real = real .. vis:sub(#real + 1)
      elseif #vis < #real then real = real:sub(1, #vis) end
    else
      real = vis
    end
    if opts.MaxLength and #real > opts.MaxLength then real = real:sub(1, opts.MaxLength) end
    render()
  end))

  maid:Give(input.FocusLost:Connect(function()
    commit(real)
    if opts.Callback then opts.Callback(real, api) end
  end))

  -- ---- inline icon-button helper -------------------------------------------
  local function mkIconButton(name, icon, colorRole, order, onClick)
    local function color() return colorRole == "muted" and theme.Colors.mutedForeground or theme.Colors.primary end
    local btn = Create("ImageButton", { Name = name, BackgroundTransparency = 1,
      Size = UDim2.new(0, 16, 0, 16), LayoutOrder = order, Parent = box })
    Icons.apply(btn, icon, color())
    themed[#themed + 1] = function() Icons.apply(btn, icon, color()) end
    if onClick then maid:Give(btn.MouseButton1Click:Connect(onClick)) end
    return btn
  end

  -- @addons (Tasks 2,3,6,7 insert addon builders + their option blocks here)
  local function mkAffix(name, text, order)
    local lbl = Create("TextLabel", { Name = name, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
      Text = text, TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Center,
      TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans,
      Size = UDim2.new(0, 0, 1, 0), LayoutOrder = order, Parent = box })
    themed[#themed + 1] = function() lbl.TextColor3 = theme.Colors.mutedForeground end
    return lbl
  end
  local function mkDecorIcon(name, icon, order)
    local img = Create("ImageLabel", { Name = name, BackgroundTransparency = 1,
      Size = UDim2.new(0, 16, 0, 16), LayoutOrder = order, Parent = box })
    Icons.apply(img, icon, theme.Colors.mutedForeground)
    themed[#themed + 1] = function() Icons.apply(img, icon, theme.Colors.mutedForeground) end
    return img
  end
  if opts.LeadingIcon then mkDecorIcon("LeadingIcon", opts.LeadingIcon, 1) end
  if opts.Prefix then mkAffix("Prefix", opts.Prefix, 2) end
  if opts.Suffix then mkAffix("Suffix", opts.Suffix, 4) end
  if opts.TrailingIcon then mkDecorIcon("TrailingIcon", opts.TrailingIcon, 5) end

  local function mkTextButton(spec, order)
    local bg, fg, line = btnPalette(theme, spec.Variant or "default")
    local btn = Create("TextButton", { Name = "Button" .. order, AutoButtonColor = false,
      BackgroundColor3 = bg, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 22),
      Text = spec.Text, TextColor3 = fg, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      LayoutOrder = order, Parent = box, Create.corner(theme.Radius.sm),
      Create.padding({ left = 8, right = 8 }) })
    if line then Create("UIStroke", { Color = line, Thickness = 1, Parent = btn }) end
    themed[#themed + 1] = function()
      local b2, f2, l2 = btnPalette(theme, spec.Variant or "default")
      btn.BackgroundColor3 = b2; btn.TextColor3 = f2
      local s = btn:FindFirstChildOfClass("UIStroke"); if s and l2 then s.Color = l2 end
    end
    return btn
  end
  if opts.Buttons then
    for i, spec in ipairs(opts.Buttons) do
      local order = 5 + i
      if spec.Icon then
        mkIconButton("Button" .. i, spec.Icon, "primary", order,
          spec.Callback and function() spec.Callback(real, api) end or nil)
      else
        local btn = mkTextButton(spec, order)
        btn.Name = "Button" .. i
        if spec.Callback then maid:Give(btn.MouseButton1Click:Connect(function() spec.Callback(real, api) end)) end
      end
    end
  end
  if opts.Clearable then
    local clear = mkIconButton("Clear", "x", "muted", 29, function()
      commit(""); if opts.Callback then opts.Callback(real, api) end
      if input.CaptureFocus then input:CaptureFocus() end
    end)
    local function sync() clear.Visible = #real > 0 end
    sync()
    maid:Give(input:GetPropertyChangedSignal("Text"):Connect(sync))
  end

  local spinner, spinTween
  local function mkSpinner()
    if spinner then return spinner end
    spinner = Create("ImageLabel", { Name = "Spinner", BackgroundTransparency = 1, Visible = false,
      Size = UDim2.new(0, 16, 0, 16), LayoutOrder = 40, Parent = box })
    Icons.apply(spinner, "loader", theme.Colors.mutedForeground)
    themed[#themed + 1] = function() Icons.apply(spinner, "loader", theme.Colors.mutedForeground) end
    return spinner
  end
  local function setLoading(b)
    Safe.mutate(function()
      local s = mkSpinner()
      s.Visible = b and true or false
      if spinTween then spinTween:Cancel(); spinTween = nil end
      if b then
        spinTween = TweenService:Create(s,
          TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
          { Rotation = 360 })
        spinTween:Play()
      else
        s.Rotation = 0
      end
    end)
  end
  if opts.Loading then setLoading(true) end

  if opts.Password then
    local eye = mkIconButton("Eye", "eye", "muted", 28, nil)
    maid:Give(eye.MouseButton1Click:Connect(function()
      revealed = not revealed
      Icons.apply(eye, revealed and "eye-off" or "eye", theme.Colors.mutedForeground)
      render()
    end))
  end

  if opts.Copyable then
    mkIconButton("Copy", "copy", "primary", 30, function()
      if setclipboard then pcall(setclipboard, real) end
    end)
  end

  -- @states (Tasks 4,5 insert focus-ring / validation wiring here)
  maid:Give(input.Focused:Connect(function()
    state.focused = true; Animate.to(stroke, "fast", { Color = strokeColor() })
  end))
  maid:Give(input.FocusLost:Connect(function()
    state.focused = false; Animate.to(stroke, "fast", { Color = strokeColor() })
  end))
  local function setDisabled(b)
    b = b and true or false
    Safe.mutate(function()
      input.TextEditable = not b and not opts.Copyable
      input.TextColor3 = b and theme.Colors.mutedForeground or theme.Colors.foreground
    end)
  end
  if opts.Disabled then setDisabled(true) end

  local message
  local function mkMessage()
    if message then return message end
    message = Create("TextLabel", { Name = "Error", BackgroundTransparency = 1, Visible = false,
      Text = "", TextColor3 = theme.Colors.destructive, TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
      TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      Position = UDim2.new(boxX.X.Scale, boxX.X.Offset, 0, boxTop + boxH + 2),
      Size = UDim2.new(boxW.X.Scale, boxW.X.Offset, 0, 16), Parent = root })
    themed[#themed + 1] = function() message.TextColor3 = theme.Colors.destructive end
    return message
  end
  local function setInvalid(msg)
    state.invalid = true
    Safe.mutate(function()
      local m = mkMessage(); m.Text = msg or ""; m.Visible = true
      root.Size = UDim2.new(1, 0, 0, baseH + 18)
      stroke.Color = strokeColor()
    end)
  end
  local function setValid()
    state.invalid = false
    Safe.mutate(function()
      if message then message.Visible = false end
      root.Size = UDim2.new(1, 0, 0, baseH)
      stroke.Color = strokeColor()
    end)
  end
  local function runValidate()
    if not opts.Validate then return end
    local ok, msg = opts.Validate(real)
    if ok then setValid() else setInvalid(msg) end
  end
  maid:Give(input.FocusLost:Connect(runValidate))

  if opts.AccentReg then maid:Give(opts.AccentReg(reTheme)) end
  maid:Give(function() if spinTween then spinTween:Cancel(); spinTween = nil end end)
  maid:Give(root)

  -- ---- public api -----------------------------------------------------------
  api.Frame = root
  api.GetText = function() return real end
  api.SetText = function(s) commit(tostring(s)); runValidate(); if opts.Callback then opts.Callback(real, api) end end
  api.Focus = function() input:CaptureFocus() end
  api.Clear = function() commit("") end
  -- @api-extra (Tasks 4,5,6 add SetInvalid/SetValid/SetLoading/SetDisabled here)
  api.SetDisabled = function(b) setDisabled(b) end
  api.SetInvalid = function(msg) setInvalid(msg) end
  api.SetValid = function() setValid() end
  api.SetLoading = function(b) setLoading(b) end
  api.Destroy = function() maid:DoCleanup() end
  return api
end

return TextBox
