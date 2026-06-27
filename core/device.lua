-- Deps injected via Init(R) (bundler cannot rewrite require() inside embedded modules).
-- Centralized device/platform detection. Phone-vs-tablet is a best-effort viewport
-- heuristic (Roblox exposes no physical-size/DPI), driven primarily by aspect ratio so
-- it is DPI-independent; tune via Device.Configure. Console/Desktop/Touch are reliable.
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Device = {}
local Signal
local DEFAULTS = { TabletMaxAspect = 1.55, TabletMinDiagonal = math.huge }
local cfg = { TabletMaxAspect = DEFAULTS.TabletMaxAspect, TabletMinDiagonal = DEFAULTS.TabletMinDiagonal }

local function viewport()
  local cam = workspace and workspace.CurrentCamera
  local vp = cam and cam.ViewportSize
  if vp and vp.X and vp.X > 0 then return vp end
  return { X = 1280, Y = 720 }
end

function Device.GetType()
  if GuiService and GuiService.IsTenFootInterface and GuiService:IsTenFootInterface() then
    return "Console"
  end
  local touch = UserInputService.TouchEnabled
  local mouse = UserInputService.MouseEnabled
  if touch and not mouse then
    local vp = viewport()
    local a, b = math.max(vp.X, vp.Y), math.min(vp.X, vp.Y)
    local aspect = (b > 0) and (a / b) or 1
    local diag = math.sqrt(vp.X * vp.X + vp.Y * vp.Y)
    if aspect <= cfg.TabletMaxAspect or diag >= cfg.TabletMinDiagonal then return "Tablet" end
    return "Mobile"
  end
  return "Desktop"
end

function Device.IsMobile() return Device.GetType() == "Mobile" end
function Device.IsTablet() return Device.GetType() == "Tablet" end
function Device.IsDesktop() return Device.GetType() == "Desktop" end
function Device.IsConsole() return Device.GetType() == "Console" end
function Device.IsTouch() return UserInputService.TouchEnabled == true end

function Device.Init(R)
  Signal = R.Signal
  cfg.TabletMaxAspect = DEFAULTS.TabletMaxAspect
  cfg.TabletMinDiagonal = DEFAULTS.TabletMinDiagonal
end

return Device
