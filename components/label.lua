-- Deps injected via Init(R).
local Label = {}
local Create, DefaultTheme

function Label.Init(R) Create = R.Create; DefaultTheme = R.Theme end

function Label.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local variant = opts.Variant or "default"
  local text = opts.Text or ""
  if variant == "section" then text = string.upper(text) end

  local color = (variant == "default") and theme.Colors.foreground or theme.Colors.mutedForeground
  local size = (variant == "section") and 11 or theme.Font.body.Size

  local frame = Create("TextLabel", {
    Name = "Label",
    BackgroundTransparency = 1,
    Text = text,
    TextColor3 = color,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextSize = size,
    TextWrapped = variant == "paragraph",
    Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, 0, 0, size + 6),
    AutomaticSize = (variant == "paragraph") and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
    LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent,
  })

  return {
    Frame = frame,
    SetText = function(s) frame.Text = (variant == "section") and string.upper(s) or s end,
    Destroy = function() frame:Destroy() end,
  }
end

return Label
