local Create = require("core/create")

local Overlay = {}
local root = nil

function Overlay.get(parentGui)
  if root and not root._destroyed then return root end
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
