-- Deps injected via Init(R).
local Acrylic = {}
local Create

function Acrylic.Init(R) Create = R.Create end

-- An OPAQUE dark panel with a subtle vertical color sheen + 1px stroke. Earlier this used
-- a Transparency gradient (0.85->1.0) which multiplied the frame's bg transparency and made
-- the whole panel see-through over the game. The "acrylic" feel now comes from the color
-- sheen + stroke, NOT see-through — readable over any background.
function Acrylic.decorate(frame, theme, opts)
  opts = opts or {}
  frame.BackgroundColor3 = theme.Colors.card
  frame.BackgroundTransparency = opts.transparency or 0

  if not frame:FindFirstChildOfClass("UIStroke") then
    Create("UIStroke", { Color = theme.Colors.border, Thickness = 1, Transparency = 0.3, Parent = frame })
  end

  if not opts.solid and not frame:FindFirstChildOfClass("UIGradient") then
    Create("UIGradient", {
      Rotation = 90,
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Colors.surface), -- slightly lighter at top
        ColorSequenceKeypoint.new(1, theme.Colors.card),
      }),
      Parent = frame,
    })
  end
  return frame
end

return Acrylic
