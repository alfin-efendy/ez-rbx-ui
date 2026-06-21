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

function Keybind.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local listening = false
  local keyCode = "Unknown"
  local onPressed

  local btn = Create("TextButton", { Name = "Keybind", AutoButtonColor = false, Text = "",
    BackgroundColor3 = theme.Colors.surface, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent, Create.corner(theme.Radius.md), Create.padding({ left = theme.Spacing.inputX, right = theme.Spacing.inputX }) })
  Create("TextLabel", { Name = "Label", BackgroundTransparency = 1, Text = opts.Text or "Keybind",
    TextColor3 = theme.Colors.foreground, TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.label.Size,
    Font = Enum.Font.BuilderSans, Size = UDim2.new(1, -80, 1, 0), Parent = btn })
  local keyBox = Create("TextLabel", { Name = "Key", BackgroundColor3 = theme.Colors.input,
    Text = "...", TextColor3 = theme.Colors.foreground, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
    Size = UDim2.new(0, 70, 0, 22), Position = UDim2.new(1, -70, 0.5, -11), Parent = btn, Create.corner(theme.Radius.sm) })

  local function apply(name)
    keyCode = keyName(name)
    keyBox.Text = listening and "..." or keyCode
  end
  local commit = Flag.bind(opts, keyName(opts.Default or "Unknown"), apply)

  local api = { Frame = btn }
  function api.GetKey() return Enum.KeyCode[keyCode] end
  function api.SetKey(k) commit(keyName(k)) end
  function api.OnPressed(fn) onPressed = fn end
  function api.Destroy() maid:DoCleanup() end

  maid:Give(btn.MouseButton1Click:Connect(function() listening = true; keyBox.Text = "..." end))
  maid:Give(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if listening then
      listening = false
      commit(keyName(input.KeyCode))
    elseif not gameProcessed and input.KeyCode == Enum.KeyCode[keyCode] then
      if opts.Callback then opts.Callback() end
      if onPressed then onPressed() end
    end
  end))
  maid:Give(btn)
  return api
end
return Keybind
