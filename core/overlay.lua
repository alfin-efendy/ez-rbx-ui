-- Deps injected via Init(R).
local Overlay = {}
local Create
local root = nil
local catcher = nil -- full-screen click-catcher behind open popovers (closes them on outside click)
local popovers = {} -- set of close functions for open popovers (dropdowns, color pickers)

function Overlay.Init(R) Create = R.Create end

-- A transparent full-screen button mounted under the popover (ZIndex 1000, the popover
-- is 1001+). A click anywhere outside the popover lands on it and closes everything.
local function ensureCatcher()
  if catcher and catcher.Parent ~= nil then return end
  if not root then return end
  catcher = Create("ImageButton", {
    Name = "EzUI_OverlayCatcher", AutoButtonColor = false, BackgroundTransparency = 1,
    Active = true, Size = UDim2.new(1, 0, 1, 0), ZIndex = 1000, Parent = root,
  })
  catcher.MouseButton1Click:Connect(function() Overlay.closeAll() end)
end

local function removeCatcher()
  if catcher then catcher:Destroy(); catcher = nil end
end

function Overlay.get(parentGui)
  -- Roblox-safe liveness check: reading a non-existent member (e.g. a mock-only
  -- "_destroyed" flag) THROWS on real Instances. A destroyed Instance has Parent=nil.
  if root and root.Parent ~= nil then return root end
  root = Create("Frame", {
    Name = "EzUI_OverlayRoot",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 1000,
    ClipsDescendants = false,
    Parent = parentGui,
  })
  return root
end

function Overlay.mount(element)
  assert(root, "Overlay.get(parentGui) must be called before mount")
  element.Parent = root
  return element
end

-- Popover registry: components register their Close fn so the window can close
-- every open popover at once (e.g. on drag/resize/minimize/shutdown).
function Overlay.trackPopover(closeFn) popovers[closeFn] = true; ensureCatcher(); return closeFn end
function Overlay.untrackPopover(closeFn)
  popovers[closeFn] = nil
  if next(popovers) == nil then removeCatcher() end
end
function Overlay.closeAll()
  local fns = popovers; popovers = {}
  for fn in pairs(fns) do pcall(fn) end
  removeCatcher()
end

-- Screen size for popover placement; falls back when unmeasured (mock / first frame).
function Overlay.viewport()
  if root then
    local s = root.AbsoluteSize
    if s and (s.X or 0) > 0 and (s.Y or 0) > 0 then return s end
  end
  return { X = 1920, Y = 1080 }
end

function Overlay.reset() root = nil; catcher = nil; popovers = {} end

return Overlay
