-- Deps injected via Init(R).
local ProgressBar = {}
local Create, DefaultTheme, Animate
function ProgressBar.Init(R) Create = R.Create; DefaultTheme = R.Theme; Animate = R.Animate end
local function clamp01(n) n = tonumber(n) or 0; if n < 0 then return 0 elseif n > 1 then return 1 end return n end
function ProgressBar.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local value = clamp01(opts.Default or 0)
  local root = Create("Frame", { Name = "ProgressBar", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 8), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent })
  local track = Create("Frame", { Name = "Track", BackgroundColor3 = theme.Colors.surface, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0), Parent = root, Create.corner(4) })
  local fill = Create("Frame", { Name = "Fill", BackgroundColor3 = opts.Color or theme.Colors.primary, BorderSizePixel = 0,
    Size = UDim2.new(value, 0, 1, 0), Parent = track, Create.corner(4) })
  return {
    Frame = root,
    Get = function() return value end,
    Set = function(p) value = clamp01(p); Animate.to(fill, "fast", { Size = UDim2.new(value, 0, 1, 0) }) end,
    Destroy = function() root:Destroy() end,
  }
end
return ProgressBar
