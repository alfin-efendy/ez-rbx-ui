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

return Animate
