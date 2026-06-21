-- Deps injected via Init(R).
local Separator = {}
local Create, DefaultTheme

function Separator.Init(R) Create = R.Create; DefaultTheme = R.Theme end

function Separator.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local frame = Create("Frame", {
    Name = "Separator",
    BackgroundColor3 = theme.Colors.border,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 1),
    LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent,
  })
  return { Frame = frame, Destroy = function() frame:Destroy() end }
end

return Separator
