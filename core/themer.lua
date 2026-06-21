-- Deps injected via Init(R) (none needed). A per-window registry of accent
-- re-appliers. Accent-using components register a closure that recolors their
-- accent parts reading theme.Colors live; Window:SetAccent fires them all.
local Themer = {}
function Themer.Init(_) end

Themer.ACCENTS = {
  { Name = "Mono",    Primary = Color3.fromRGB(250, 250, 250), Foreground = Color3.fromRGB(24, 24, 27) },
  { Name = "Indigo",  Primary = Color3.fromRGB(99, 102, 241),  Foreground = Color3.fromRGB(250, 250, 250) },
  { Name = "Violet",  Primary = Color3.fromRGB(139, 92, 246),  Foreground = Color3.fromRGB(250, 250, 250) },
  { Name = "Emerald", Primary = Color3.fromRGB(16, 185, 129),  Foreground = Color3.fromRGB(250, 250, 250) },
  { Name = "Sky",     Primary = Color3.fromRGB(56, 189, 248),  Foreground = Color3.fromRGB(24, 24, 27) },
  { Name = "Rose",    Primary = Color3.fromRGB(244, 63, 94),   Foreground = Color3.fromRGB(250, 250, 250) },
}

function Themer.accent(name)
  for _, a in ipairs(Themer.ACCENTS) do if a.Name == name then return a end end
  return nil
end

function Themer.names()
  local out = {}
  for _, a in ipairs(Themer.ACCENTS) do out[#out + 1] = a.Name end
  return out
end

function Themer.new()
  local fns = {}
  local self = {}
  function self.register(fn)
    fns[fn] = true
    return function() fns[fn] = nil end
  end
  function self.reskin()
    for fn in pairs(fns) do pcall(fn) end
  end
  function self.setAccent(primary, foreground)
    self.reskin() -- closures read theme.Colors live; caller mutated it before calling
  end
  return self
end

return Themer
