-- Minimal Roblox API surface for headless logic tests.
local M = {}

local function enumNs(names)
  local ns = {}
  for _, n in ipairs(names) do ns[n] = { Name = n, EnumType = true } end
  return ns
end

local function makeSignal()
  local handlers = {}
  local sig = {}
  -- tagged so mock typeof() reports "RBXScriptConnection" (real events return userdata)
  function sig:Connect(fn) handlers[fn] = true; return { __isConnection = true, Disconnect = function() handlers[fn] = nil end } end
  function sig:Once(fn) local c; c = sig:Connect(function(...) c.Disconnect(); fn(...) end); return c end
  function sig:Fire(...) for fn in pairs(handlers) do fn(...) end end
  return sig
end
M.makeSignal = makeSignal

local function newInstance(cls)
  local children = {}
  local props = { ClassName = cls }
  local signals = {}
  local inst
  inst = setmetatable({}, {
    __index = function(_, k)
      if props[k] ~= nil then return props[k] end
      if k == "GetChildren" then return function() local t = {} for i, c in ipairs(children) do t[i] = c end return t end end
      if k == "FindFirstChild" then return function(_, name) for _, c in ipairs(children) do if c.Name == name then return c end end end end
      if k == "FindFirstChildOfClass" then return function(_, c2) for _, c in ipairs(children) do if c.ClassName == c2 then return c end end end end
      if k == "IsA" then return function(_, c2) return props.ClassName == c2 end end
      if k == "Destroy" then return function() props._destroyed = true; for i = #children, 1, -1 do children[i] = nil end end end
      if k == "SetAttribute" then return function(_, ak, av) props["_attr_" .. ak] = av end end
      if k == "GetAttribute" then return function(_, ak) return props["_attr_" .. ak] end end
      if k == "GetPropertyChangedSignal" then return function(_, p) signals["chg_" .. p] = signals["chg_" .. p] or makeSignal(); return signals["chg_" .. p] end end
      -- event fields created on demand
      local ev = { MouseButton1Click = true, MouseEnter = true, MouseLeave = true, InputBegan = true, InputEnded = true, InputChanged = true, Activated = true, Completed = true, MouseButton1Down = true, MouseButton1Up = true, Changed = true }
      if ev[k] then signals[k] = signals[k] or makeSignal(); return signals[k] end
      -- Roblox throws when reading an invalid member. Underscore-prefixed names are
      -- never valid Roblox members, so reading an UNSET one is a mock-ism leaking into
      -- production code (e.g. root._destroyed). Throw to catch it, like Roblox would.
      if type(k) == "string" and k:sub(1, 1) == "_" then
        error(tostring(k) .. " is not a valid member (mock strict: unset internal field read)", 2)
      end
      return nil
    end,
    __newindex = function(_, k, v)
      if k == "Parent" then
        props.Parent = v
        if v and v.__addChild then v.__addChild(inst) end
      else
        props[k] = v
      end
    end,
  })
  rawset(inst, "__addChild", function(c) children[#children + 1] = c end)
  rawset(inst, "__isInstance", true) -- so mock typeof() reports "Instance"
  return inst
end

function M.installInto(env, mock)
  env.Color3 = {
    fromRGB = function(r, g, b) return { R = r / 255, G = g / 255, B = b / 255, R8 = r, G8 = g, B8 = b } end,
    new = function(r, g, b) return { R = r, G = g, B = b, R8 = math.floor((r or 0) * 255), G8 = math.floor((g or 0) * 255), B8 = math.floor((b or 0) * 255) } end,
    fromHSV = function(h, s, v) return { H = h, S = s, V = v } end,
  }
  env.Vector2 = { new = function(x, y) return { X = x or 0, Y = y or 0 } end }
  env.UDim = { new = function(s, o) return { Scale = s or 0, Offset = o or 0 } end }
  env.UDim2 = { new = function(xs, xo, ys, yo) return { X = { Scale = xs or 0, Offset = xo or 0 }, Y = { Scale = ys or 0, Offset = yo or 0 } } end }
  env.Enum = {
    Font = enumNs({ "BuilderSans", "SourceSans", "Gotham" }),
    FontWeight = enumNs({ "Regular", "Medium", "SemiBold", "Bold" }),
    EasingStyle = enumNs({ "Quart", "Quint", "Linear", "Sine" }),
    EasingDirection = enumNs({ "In", "Out", "InOut" }),
    AutomaticSize = enumNs({ "None", "X", "Y", "XY" }),
    SortOrder = enumNs({ "LayoutOrder", "Name" }),
    TextXAlignment = enumNs({ "Left", "Center", "Right" }),
    FillDirection = enumNs({ "Horizontal", "Vertical" }),
    KeyCode = enumNs({ "RightControl", "E", "P", "Insert", "Unknown" }),
    UserInputType = enumNs({ "MouseButton1", "MouseMovement", "Touch", "Keyboard" }),
    ZIndexBehavior = enumNs({ "Sibling", "Global" }),
  }
  env.Instance = { new = newInstance }
  -- Roblox typeof(): Instances/connections are userdata in real Roblox. The mock tags
  -- them so maid.lua's typeof-based cleanup exercises the SAME branch it will in Roblox.
  env.typeof = function(v)
    if type(v) == "table" then
      if rawget(v, "__isInstance") then return "Instance" end
      if rawget(v, "__isConnection") then return "RBXScriptConnection" end
    end
    return type(v)
  end
  env.task = {
    spawn = function(fn, ...) fn(...) end,
    defer = function(fn, ...) fn(...) end,
    delay = function(_, fn, ...) fn(...) end,
    wait = function() return 0 end,
  }
  env.wait = function() return 0 end
  env.tick = function() return 0 end

  -- in-memory filesystem
  mock.fs = {}
  env.writefile = function(p, c) mock.fs[p] = c end
  env.readfile = function(p) return mock.fs[p] end
  env.isfile = function(p) return mock.fs[p] ~= nil end
  env.isfolder = function(p) for k in pairs(mock.fs) do if k:sub(1, #p) == p then return true end end return false end
  env.makefolder = function() end
  env.delfile = function(p) mock.fs[p] = nil end

  -- services
  local HttpService = {
    JSONEncode = function(_, t) return M.jsonEncode(t) end,
    JSONDecode = function(_, s) return M.jsonDecode(s) end,
    GenerateGUID = function() return "guid" end,
  }
  local TweenService = {
    Create = function(_, inst, info, goal)
      local tw = { Instance = inst, Info = info, Goal = goal, played = false, Completed = makeSignal() }
      function tw:Play() self.played = true; for k, v in pairs(goal) do inst[k] = v end; self.Completed:Fire() end
      function tw:Cancel() end
      mock.lastTween = tw
      return tw
    end,
  }
  local UserInputService = { InputBegan = makeSignal(), InputChanged = makeSignal(), InputEnded = makeSignal(), TouchEnabled = false }
  local Players = {
    LocalPlayer = { Name = "Tester", UserId = 1 },
    GetPlayers = function() return { { Name = "Tester", UserId = 1 } } end,
    PlayerAdded = makeSignal(),
    PlayerRemoving = makeSignal(),
    GetUserThumbnailAsync = function() return "rbxassetid://0" end,
  }
  local RunService = { RenderStepped = makeSignal(), Heartbeat = makeSignal() }
  local services = { HttpService = HttpService, TweenService = TweenService, UserInputService = UserInputService, Players = Players, RunService = RunService }
  env.game = { GetService = function(_, name) return services[name] end, HttpGet = function() return "" end }
  env.TweenInfo = { new = function(t, style, dir) return { Time = t, EasingStyle = style, EasingDirection = dir } end }
  env.NumberSequence = { new = function(a) return { keypoints = a } end }
  env.NumberSequenceKeypoint = { new = function(t, v) return { Time = t, Value = v } end }
  env.ColorSequence = { new = function(c) return { color = c } end }
  env.mock = mock
end

-- tiny JSON (objects/arrays/strings/numbers/bools/nil) — sufficient for config tests
function M.jsonEncode(t)
  local function enc(v)
    local tv = type(v)
    if tv == "string" then return '"' .. v:gsub('"', '\\"') .. '"' end
    if tv == "number" or tv == "boolean" then return tostring(v) end
    if tv == "table" then
      local isArr, n = true, 0
      for k in pairs(v) do n = n + 1; if type(k) ~= "number" then isArr = false end end
      local parts = {}
      if isArr then
        for _, e in ipairs(v) do parts[#parts + 1] = enc(e) end
        return "[" .. table.concat(parts, ",") .. "]"
      end
      for k, e in pairs(v) do parts[#parts + 1] = '"' .. tostring(k) .. '":' .. enc(e) end
      return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null"
  end
  return enc(t)
end

function M.jsonDecode(s)
  -- delegate to a Lua chunk eval after converting JSON to a Lua table literal (test-only, trusted input).
  -- ORDER MATTERS: convert array brackets [ ] -> { } FIRST, otherwise the [ ] we introduce for
  -- string keys (`"k":` -> `["k"]=`) get clobbered by the array substitution.
  local lua = s
    :gsub("%[", "{")
    :gsub("%]", "}")
    :gsub('"([^"]-)"%s*:', '["%1"]=')
    :gsub("null", "nil")
  local loadstr = loadstring or load -- 5.1 uses loadstring; 5.2+/LuaJIT accept string via load
  local f = loadstr("return " .. lua)
  return f and f() or {}
end

return M
