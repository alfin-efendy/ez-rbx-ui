local Theme = {}

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local DEFAULT = {
  Colors = {
    background = rgb(9, 9, 11),
    card = rgb(24, 24, 27),
    surface = rgb(39, 39, 42),
    border = rgb(63, 63, 70),
    input = rgb(39, 39, 42),
    ring = rgb(212, 212, 216),
    mutedForeground = rgb(161, 161, 170),
    foreground = rgb(250, 250, 250),
    primary = rgb(250, 250, 250),
    primaryForeground = rgb(24, 24, 27),
    destructive = rgb(239, 68, 68),
    success = rgb(34, 197, 94),
    warning = rgb(234, 179, 8),
    info = rgb(59, 130, 246),
    switchTrackOff = rgb(39, 39, 42),
  },
  Radius = { sm = 6, md = 8, lg = 10, xl = 14, window = 12 },
  Spacing = { pad = 16, padLg = 24, inputX = 12, inputY = 8, gap = 8, section = 16, major = 24, icon = 8 },
  Font = {
    title = { Weight = Enum.FontWeight.Bold, Size = 18 },
    header = { Weight = Enum.FontWeight.Medium, Size = 16 },
    label = { Weight = Enum.FontWeight.Medium, Size = 14 },
    body = { Weight = Enum.FontWeight.Regular, Size = 14 },
    muted = { Weight = Enum.FontWeight.Regular, Size = 12 },
  },
  Motion = { fast = 0.12, base = 0.18, slow = 0.28 },
}

local function deepMerge(base, over)
  local out = {}
  for k, v in pairs(base) do
    if type(v) == "table" then out[k] = deepMerge(v, (over and over[k]) or {}) else out[k] = v end
  end
  if over then for k, v in pairs(over) do if out[k] == nil then out[k] = v elseif type(v) ~= "table" then out[k] = v end end end
  return out
end

-- expose defaults directly
for k, v in pairs(DEFAULT) do Theme[k] = v end

-- BuilderSans has no weight 600; map medium->500, semibold->700
function Theme.FontFace(weight)
  -- in Roblox: return Font.fromEnum(Enum.Font.BuilderSans, weight)
  -- mock-safe: return the weight token; real impl swapped in during make run verification
  return weight
end

function Theme.new(overrides)
  overrides = overrides or {}
  local t = deepMerge(DEFAULT, overrides)
  t.FontFace = Theme.FontFace
  t.new = Theme.new
  return t
end

return Theme
