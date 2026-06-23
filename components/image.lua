-- Deps injected via Init(R).
local Image = {}
local Create, DefaultTheme, Icons, Safe
function Image.Init(R) Create = R.Create; DefaultTheme = R.Theme; Icons = R.Icons; Safe = R.Safe end
function Image.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local img = Create("ImageLabel", {
    Name = "Image", BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit,
    Image = opts.Image or "", ImageColor3 = opts.Color or Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(1, 0, 0, opts.Height or 80), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent,
  })
  if opts.Lucide then Icons.apply(img, opts.Lucide, opts.Color or theme.Colors.foreground) end
  return {
    Frame = img,
    SetImage = function(v) Safe.mutate(function() img.Image = v end) end,
    Destroy = function() img:Destroy() end,
  }
end
return Image
