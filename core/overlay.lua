-- Deps injected via Init(R).
local Overlay = {}
local Create
local root = nil

function Overlay.Init(R) Create = R.Create end

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

function Overlay.reset() root = nil end

return Overlay
