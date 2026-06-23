-- Deps injected via Init(R). Resolves where/how to parent the root ScreenGui (robustness
-- fallback chain) and applies stealth (random name, cloneref, dedupe, protect).
-- Executor globals are read at CALL time so tests and late-injecting executors see current values.
local Mount = {}

function Mount.Init(R) end -- no deps

-- Feature-detected, GC-safe service getter. cloneref hides the reference from game traps.
function Mount.service(name)
  local ok, s = pcall(function() return game:GetService(name) end)
  if not ok or not s then return nil end
  local okcr, cr = pcall(function() return cloneref or clonereference end)
  if okcr and type(cr) == "function" then
    local ok2, ref = pcall(cr, s)
    if ok2 and ref then return ref end
  end
  return s
end

-- Resolve where/how to parent. Returns { parent, protect, studio }.
function Mount.resolve(config)
  config = config or {}
  if config.Parent ~= nil then return { parent = config.Parent } end

  local studio = false
  local rs = Mount.service("RunService")
  if rs then local ok, v = pcall(function() return rs:IsStudio() end); studio = ok and v or false end

  -- 1) gethui(): not enumerable via CoreGui/PlayerGui
  local ok, hui = pcall(function() return gethui and gethui() end)
  if ok and hui then return { parent = hui, studio = studio } end

  -- 2) protect_gui family -> CoreGui (protect applied in finalize)
  local protect = nil
  if type(protectgui) == "function" then
    protect = protectgui
  elseif type(syn) == "table" and type(syn.protect_gui) == "function" then
    protect = syn.protect_gui
  end
  local cg = Mount.service("CoreGui")
  if cg then return { parent = cg, protect = protect, studio = studio } end

  -- 3) PlayerGui: universal safety net (Studio & weak executors)
  local players = Mount.service("Players")
  local lp = players and players.LocalPlayer
  if lp then
    local pg = lp:FindFirstChildOfClass("PlayerGui")
    if not pg then
      local ok3, w = pcall(function() return lp:WaitForChild("PlayerGui", 5) end)
      pg = ok3 and w or nil
    end
    if pg then return { parent = pg, studio = studio } end
  end

  return { parent = nil, studio = studio }
end

-- Readable in Studio / when overridden; random at runtime.
function Mount.guiName(config, studio)
  config = config or {}
  if type(config.GuiName) == "string" and config.GuiName ~= "" then return config.GuiName end
  if config.Stealth == false or studio then return "EzUI" end
  local hs = Mount.service("HttpService")
  if hs then
    local ok, guid = pcall(function() return hs:GenerateGUID(false) end)
    if ok and guid then return guid end
  end
  return "_" .. tostring(math.random(100000, 999999999))
end

-- After the ScreenGui exists: dedupe prior EzUI roots (by attribute, since names may be
-- random) and apply protect. Studio skips protect (protect functions don't exist there).
-- Runs synchronously on the caller's thread to keep executor capability (do not defer).
function Mount.finalize(gui, ctx)
  ctx = ctx or {}
  gui:SetAttribute("__ezui", true)
  local parent = gui.Parent
  if parent then
    for _, inst in ipairs(parent:GetChildren()) do
      if inst ~= gui and inst:GetAttribute("__ezui") then inst:Destroy() end
    end
  end
  if ctx.protect and not ctx.studio then pcall(ctx.protect, gui) end
  return gui
end

return Mount
