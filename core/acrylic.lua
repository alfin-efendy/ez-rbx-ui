-- Deps injected via Init(R).
local Acrylic = {}
local Create

function Acrylic.Init(R) Create = R.Create end

function Acrylic.decorate(frame, theme, opts)
  opts = opts or {}
  frame.BackgroundColor3 = theme.Colors.card
  frame.BackgroundTransparency = opts.solid and 0 or (opts.transparency or 0.18)

  -- stroke (idempotent)
  if not frame:FindFirstChildOfClass("UIStroke") then
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Transparency = 0.4, Parent = frame })
  end

  -- sheen gradient (skip for solid)
  if not opts.solid and not frame:FindFirstChildOfClass("UIGradient") then
    Create("UIGradient", {
      Rotation = 90,
      Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(1, 1),
      }),
      Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
      Parent = frame,
    })
  end
  return frame
end

return Acrylic
