-- Deps injected via Init(R) (the bundler cannot rewrite require() inside embedded modules).
local TweenService = game:GetService("TweenService")

local Animate = {}
local Theme
local enabled = true

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

function Animate.setEnabled(b) enabled = b and true or false end
function Animate.isEnabled() return enabled end

-- Stub returned when motion is disabled: the goal is already applied and any
-- Completed handler runs immediately (mirrors the synchronous test mock).
local function instantTween()
  return { Completed = { Connect = function(_, fn) if fn then fn() end; return { Disconnect = function() end } end } }
end

function Animate.to(instance, duration, goalProps, style, dir)
  if not enabled then
    for k, v in pairs(goalProps) do instance[k] = v end
    return instantTween()
  end
  local tween = TweenService:Create(instance, Animate.info(resolve(duration), style, dir), goalProps)
  tween:Play()
  return tween
end

-- Tween, then run onComplete. Connects Completed BEFORE Play so the handler still
-- fires under the synchronous test mock (and runs immediately when motion is off).
function Animate.toThen(instance, duration, goalProps, onComplete, style, dir)
  if not enabled then
    for k, v in pairs(goalProps) do instance[k] = v end
    if onComplete then onComplete() end
    return instantTween()
  end
  local tween = TweenService:Create(instance, Animate.info(resolve(duration), style, dir), goalProps)
  if onComplete then tween.Completed:Connect(onComplete) end
  tween:Play()
  return tween
end

Animate.EASING = { pop = Enum.EasingStyle.Back, smooth = Enum.EasingStyle.Quint }

-- spring: a tween with a Back/Out overshoot (the library's "expressive" feel).
function Animate.springTo(instance, duration, goalProps)
  return Animate.to(instance, duration, goalProps, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- rotate convenience (defaults to a Back/Out overshoot).
function Animate.rotateTo(instance, duration, deg, style, dir)
  return Animate.to(instance, duration, { Rotation = deg },
    style or Enum.EasingStyle.Back, dir or Enum.EasingDirection.Out)
end

-- pop-in: scale a UIScale child from 0.9 -> 1 with a Back/Out overshoot.
function Animate.pop(inst, duration)
  local us = inst:FindFirstChildOfClass("UIScale")
  if not us then us = Instance.new("UIScale"); us.Parent = inst end
  us.Scale = 0.9
  return Animate.to(us, duration or "base", { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

return Animate
