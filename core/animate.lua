-- Deps injected via Init(R) (the bundler cannot rewrite require() inside embedded modules).
local TweenService = game:GetService("TweenService")

local Animate = {}
local Theme

function Animate.Init(R)
  Theme = R.Theme
  Animate.Motion = Theme.Motion
end

function Animate.info(duration, style, dir)
  return TweenInfo.new(duration, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
end

local function resolve(duration)
  if type(duration) == "string" then return (Theme and Theme.Motion[duration]) or 0.18 end
  return duration
end

function Animate.to(instance, duration, goalProps, style, dir)
  local tween = TweenService:Create(instance, Animate.info(resolve(duration), style, dir), goalProps)
  tween:Play()
  return tween
end

Animate.EASING = { pop = Enum.EasingStyle.Back, smooth = Enum.EasingStyle.Quint }

-- pop-in: scale a UIScale child from 0.9 -> 1 with a Back/Out overshoot.
function Animate.pop(inst, duration)
  local us = inst:FindFirstChildOfClass("UIScale")
  if not us then us = Instance.new("UIScale"); us.Parent = inst end
  us.Scale = 0.9
  return Animate.to(us, duration or "base", { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

return Animate
