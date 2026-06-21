-- Deps injected via Init(R).
local TextBox = {}
local Create, DefaultTheme, Maid, Icons, Flag

function TextBox.Init(R)
  Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Icons = R.Icons; Flag = R.Flag
end

function TextBox.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local hasLabel = opts.Text ~= nil and opts.Text ~= ""
  local hasDesc = opts.Description ~= nil and opts.Description ~= ""
  local rowH = (not hasLabel) and 30 or (hasDesc and 56 or 46)

  local root = Create("Frame", {
    Name = "TextBoxRow", BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = 0,
    Size = UDim2.new(1, 0, 0, rowH), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent,
    Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }),
  })
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
  local box = Create("Frame", {
    Name = "Box", BackgroundColor3 = theme.Colors.input, BorderSizePixel = 0,
    Position = hasLabel and UDim2.new(0.5, 4, 0.5, -15) or UDim2.new(0, 0, 0, 0),
    Size = hasLabel and UDim2.new(0.5, -4, 0, 30) or UDim2.new(1, 0, 0, 30),
    Parent = root, Create.corner(theme.Radius.md),
    Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }),
  })
  Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Parent = box })
  local input = Create("TextBox", {
    Name = "Input", BackgroundTransparency = 1, Text = opts.Default or "",
    PlaceholderText = opts.Placeholder or "", PlaceholderColor3 = theme.Colors.mutedForeground,
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = theme.Font.body.Size, Font = Enum.Font.BuilderSans, ClearTextOnFocus = false,
    TextEditable = not opts.Copyable, Size = UDim2.new(1, opts.Copyable and -26 or 0, 1, 0),
    Parent = box,
  })

  if opts.Copyable then
    local copy = Create("ImageButton", { Name = "Copy", BackgroundTransparency = 1,
      Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -16, 0.5, -8), Parent = box })
    Icons.apply(copy, "copy", theme.Colors.primary)
    maid:Give(copy.MouseButton1Click:Connect(function()
      if setclipboard then pcall(setclipboard, input.Text) end
    end))
  end

  local function apply(s) input.Text = tostring(s or "") end
  local commit = Flag.bind(opts, opts.Default or "", apply)

  maid:Give(input.FocusLost:Connect(function()
    if opts.MaxLength and #input.Text > opts.MaxLength then input.Text = input.Text:sub(1, opts.MaxLength) end
    commit(input.Text)
    if opts.Callback then opts.Callback(input.Text) end
  end))
  maid:Give(root)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    root.BackgroundColor3 = theme.Colors.surface
    box.BackgroundColor3 = theme.Colors.input
    local bs = box:FindFirstChildOfClass("UIStroke"); if bs then bs.Color = theme.Colors.border end
    input.TextColor3 = theme.Colors.foreground; input.PlaceholderColor3 = theme.Colors.mutedForeground
    local ti = root:FindFirstChild("Title"); if ti then ti.TextColor3 = theme.Colors.foreground end
    local de = root:FindFirstChild("Description"); if de then de.TextColor3 = theme.Colors.mutedForeground end
    local cp = box:FindFirstChild("Copy"); if cp then Icons.apply(cp, "copy", theme.Colors.primary) end
  end)) end

  return {
    Frame = root,
    GetText = function() return input.Text end,
    SetText = function(s) commit(tostring(s)); if opts.Callback then opts.Callback(input.Text) end end,
    Focus = function() input:CaptureFocus() end,
    Clear = function() commit("") end,
    Destroy = function() maid:DoCleanup() end,
  }
end

return TextBox
