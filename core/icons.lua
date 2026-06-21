-- Curated Lucide 48px subset. Entry: name = { id, w, h, x, y }.
-- Seed values below are PLACEHOLDER COORDINATES sourced from latte-soft/lucide-roblox
-- and MUST be replaced by the generated table from `make icons` (Task 8) before visual use.
-- The known-good proven sheet in this repo is assetId 16898613613 (see old window.lua:311).
local DATA = {
  ["house"]         = { id = 16898613613, w = 48, h = 48, x = 0,   y = 0 },
  ["settings-2"]    = { id = 16898613613, w = 48, h = 48, x = 48,  y = 0 },
  ["target"]        = { id = 16898613613, w = 48, h = 48, x = 96,  y = 0 },
  ["chevron-right"] = { id = 16898613613, w = 48, h = 48, x = 144, y = 0 },
  ["chevron-down"]  = { id = 16898613613, w = 48, h = 48, x = 192, y = 0 },
  ["play"]          = { id = 16898613613, w = 48, h = 48, x = 240, y = 0 },
  ["x"]             = { id = 16898613613, w = 48, h = 48, x = 288, y = 0 },
  ["search"]        = { id = 16898613613, w = 48, h = 48, x = 336, y = 0 },
  ["user"]          = { id = 16898613613, w = 48, h = 48, x = 384, y = 0 },
  ["check"]         = { id = 16898613613, w = 48, h = 48, x = 432, y = 0 },
  ["plus"]          = { id = 16898613613, w = 48, h = 48, x = 480, y = 0 },
  ["minus"]         = { id = 16898613613, w = 48, h = 48, x = 528, y = 0 },
  ["copy"]          = { id = 16898613613, w = 48, h = 48, x = 576, y = 0 },
}

local Icons = { data = DATA }

function Icons.get(name)
  local e = DATA[name]
  if not e then return nil end
  return {
    Id = "rbxassetid://" .. e.id,
    ImageRectSize = Vector2.new(e.w, e.h),
    ImageRectOffset = Vector2.new(e.x, e.y),
  }
end

function Icons.apply(imageLabel, name, color3)
  local a = Icons.get(name)
  if not a then
    if warn then warn("[EzUI] unknown icon: " .. tostring(name)) end
    return false
  end
  imageLabel.Image = a.Id
  imageLabel.ImageRectSize = a.ImageRectSize
  imageLabel.ImageRectOffset = a.ImageRectOffset
  if color3 then imageLabel.ImageColor3 = color3 end
  return true
end

return Icons
