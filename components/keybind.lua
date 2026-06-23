-- Deps injected via Init(R).
local Keybind = {}
local Create, DefaultTheme, Maid, Flag
local UserInputService = game:GetService("UserInputService")
function Keybind.Init(R) Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Flag = R.Flag end

-- A real Enum.KeyCode is an EnumItem (userdata), NOT a table — so type(k)=="table"
-- is false in Roblox and the key would always read as "Unknown". Read .Name directly
-- (works for EnumItem userdata, the mock's enum tables, and plain strings).
local function keyName(k)
  if type(k) == "string" then return k end
  if k ~= nil then
    local ok, name = pcall(function() return k.Name end)
    if ok and type(name) == "string" then return name end
  end
  return "Unknown"
end

-- Indexing Enum.KeyCode with an invalid/free-form string THROWS in real Roblox
-- ("X is not a valid member of Enum.KeyCode") — and this runs on every keypress.
-- Resolve once through a pcall so a bad name degrades to Unknown instead of erroring.
local function toKeyCode(name)
  local ok, kc = pcall(function() return Enum.KeyCode[name] end)
  if ok and kc then return kc end
  return Enum.KeyCode.Unknown
end

function Keybind.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local listening = false
  local keyCode = "Unknown"
  local onPressed

  local hasDesc = opts.Description ~= nil and opts.Description ~= ""
  local btn = Create("TextButton", { Name = "Keybind", AutoButtonColor = false, Text = "",
    BackgroundColor3 = theme.Colors.surface, Size = UDim2.new(1, 0, 0, hasDesc and 50 or 34), LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent, Create.corner(theme.Radius.md), Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }) })
  Create("TextLabel", { Name = "Label", BackgroundTransparency = 1, Text = opts.Text or "Keybind",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.label.Size,
    TextYAlignment = hasDesc and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center, Font = Enum.Font.BuilderSans,
    Position = UDim2.new(0, 0, 0, hasDesc and 8 or 0), Size = UDim2.new(1, -80, hasDesc and 0 or 1, hasDesc and 18 or 0), Parent = btn })
  if hasDesc then
    Create("TextLabel", { Name = "Description", BackgroundTransparency = 1, Text = opts.Description,
      TextColor3 = theme.Colors.mutedForeground, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
      TextYAlignment = Enum.TextYAlignment.Top, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
      Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(1, -80, 0, 18), Parent = btn })
  end
  local keyBox = Create("TextLabel", { Name = "Key", BackgroundColor3 = theme.Colors.input,
    Text = "...", TextColor3 = theme.Colors.foreground, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
    Size = UDim2.new(0, 70, 0, 22), Position = UDim2.new(1, -70, 0.5, -11), Parent = btn, Create.corner(theme.Radius.sm) })

  local function apply(name)
    keyCode = keyName(name)
    keyBox.Text = listening and "..." or keyCode
  end
  local commit = Flag.bind(opts, keyName(opts.Default or "Unknown"), apply)

  -- Rebind the key and notify via OnChanged. Use this (not opts.Callback) to react to
  -- the user *choosing a different key* — e.g. driving Window:SetToggleKey so the window's
  -- built-in toggle handler stays the single source of truth instead of adding a second one.
  local function setKey(k)
    commit(keyName(k))
    if opts.OnChanged then opts.OnChanged(toKeyCode(keyCode)) end
  end

  local api = { Frame = btn }
  function api.GetKey() return toKeyCode(keyCode) end
  function api.SetKey(k) setKey(k) end
  function api.OnPressed(fn) onPressed = fn end
  function api.Destroy() maid:DoCleanup() end

  maid:Give(btn.MouseButton1Click:Connect(function() listening = true; keyBox.Text = "..." end))
  maid:Give(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if listening then
      listening = false
      setKey(input.KeyCode)
    elseif not gameProcessed and input.KeyCode == toKeyCode(keyCode) then
      if opts.Callback then opts.Callback() end
      if onPressed then onPressed() end
    end
  end))
  maid:Give(btn)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    btn.BackgroundColor3 = theme.Colors.surface
    local lab = btn:FindFirstChild("Label"); if lab then lab.TextColor3 = theme.Colors.foreground end
    local de = btn:FindFirstChild("Description"); if de then de.TextColor3 = theme.Colors.mutedForeground end
    keyBox.BackgroundColor3 = theme.Colors.input; keyBox.TextColor3 = theme.Colors.foreground
  end)) end

  return api
end
return Keybind
