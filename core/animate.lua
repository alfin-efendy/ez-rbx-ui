local Theme = require("core/theme")
local TweenService = game:GetService("TweenService")

local Animate = { Motion = Theme.Motion }

function Animate.info(duration, style, dir)
  return TweenInfo.new(duration, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
end

local function resolve(duration)
  if type(duration) == "string" then return Theme.Motion[duration] or Theme.Motion.base end
  return duration
end

function Animate.to(instance, duration, goalProps, style, dir)
  local tween = TweenService:Create(instance, Animate.info(resolve(duration), style, dir), goalProps)
  tween:Play()
  return tween
end

return Animate
