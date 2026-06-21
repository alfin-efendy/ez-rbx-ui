-- Deps injected via Init(R).
local Acrylic = {}
local Create

function Acrylic.Init(R) Create = R.Create end

-- 2D frosted paint stack (NO Lighting/Workspace mutation): translucent card fill +
-- tiled noise grain + opaque color sheen + 1px stroke. Readable over any background,
-- transparency tunable. (A Transparency UIGradient would multiply the bg transparency
-- and make the panel see-through — so the sheen is a COLOR gradient only.)
local NOISE_ID = "rbxassetid://9968344105" -- subtle grain; verify in Studio, set "" to disable

function Acrylic.decorate(frame, theme, opts)
  opts = opts or {}
  frame.BackgroundColor3 = opts.base or theme.Colors.card
  frame.BackgroundTransparency = opts.solid and 0 or (opts.transparency or 0.12)

  if not frame:FindFirstChildOfClass("UIStroke") then
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Transparency = 0.3, Parent = frame })
  end

  if not opts.solid then
    if NOISE_ID ~= "" and not frame:FindFirstChild("AcrylicNoise") then
      Create("ImageLabel", { Name = "AcrylicNoise", BackgroundTransparency = 1, Image = NOISE_ID,
        ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.new(0, 128, 0, 128), ImageTransparency = 0.92,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 0, Parent = frame })
    end
    if not frame:FindFirstChildOfClass("UIGradient") then
      Create("UIGradient", { Rotation = 90, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, opts.gradientTop or theme.Colors.surface),
        ColorSequenceKeypoint.new(1, opts.gradientBottom or theme.Colors.card),
      }), Parent = frame })
    end
  end
  return frame
end

-- Real frosted blur: a Lighting BlurEffect toggled with window visibility. Headless-safe
-- (when Lighting is unavailable the BlurEffect is simply left unparented).
function Acrylic.blur(opts)
  opts = opts or {}
  local target = opts.size or 18
  local blur = Create("BlurEffect", { Name = "EzUIAcrylicBlur", Size = target, Enabled = true })
  local ok, Lighting = pcall(function() return game:GetService("Lighting") end)
  if ok and Lighting then blur.Parent = Lighting end
  return {
    Instance = blur,
    SetEnabled = function(on) blur.Enabled = on and true or false; blur.Size = on and target or 0 end,
    Destroy = function() pcall(function() blur:Destroy() end) end,
  }
end

return Acrylic
