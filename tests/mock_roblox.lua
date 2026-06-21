-- Minimal Roblox API surface for headless logic tests.
local M = {}
M.strict = false -- when true (verify-bundle), validate cross-class property writes like Roblox

-- Properties that only exist on certain classes. Writing them on another class throws
-- in real Roblox ("X is not a valid member of <Class>"); the lenient mock would store
-- them. Enabled only in strict mode so unit tests stay terse.
local function set(list) local t = {} for _, n in ipairs(list) do t[n] = true end return t end
local TEXT_PROPS = set({ "Text", "PlaceholderText", "PlaceholderColor3", "TextColor3", "TextSize", "TextWrapped",
  "TextXAlignment", "TextYAlignment", "TextTruncate", "TextEditable", "ClearTextOnFocus", "RichText", "TextScaled",
  "LineHeight", "Font", "FontFace", "TextTransparency", "MaxVisibleGraphemes", "CursorPosition", "MultiLine" })
local TEXT_CLASSES = set({ "TextLabel", "TextButton", "TextBox" })
local IMAGE_PROPS = set({ "Image", "ImageColor3", "ImageTransparency", "ImageRectOffset", "ImageRectSize",
  "ScaleType", "ResampleMode", "SliceCenter", "SliceScale", "TileSize" })
local IMAGE_CLASSES = set({ "ImageLabel", "ImageButton" })
local BTN_PROPS = set({ "AutoButtonColor", "Modal", "Style" })
local BTN_CLASSES = set({ "TextButton", "ImageButton" })

local function validateProp(cls, k)
  if not M.strict or type(k) ~= "string" or not cls then return end
  if TEXT_PROPS[k] and not TEXT_CLASSES[cls] then error(k .. " is not a valid member of " .. cls, 3) end
  if IMAGE_PROPS[k] and not IMAGE_CLASSES[cls] then error(k .. " is not a valid member of " .. cls, 3) end
  if BTN_PROPS[k] and not BTN_CLASSES[cls] then error(k .. " is not a valid member of " .. cls, 3) end
end

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
      if k == "Destroy" then return function()
        props._destroyed = true
        if props.Parent and props.Parent.__removeChild then props.Parent.__removeChild(inst) end
        props.Parent = nil
        for i = #children, 1, -1 do children[i] = nil end
      end end
      if k == "SetAttribute" then return function(_, ak, av) props["_attr_" .. ak] = av end end
      if k == "GetAttribute" then return function(_, ak) return props["_attr_" .. ak] end end
      if k == "GetPropertyChangedSignal" then return function(_, p) signals["chg_" .. p] = signals["chg_" .. p] or makeSignal(); return signals["chg_" .. p] end end
      -- event fields created on demand
      local ev = { MouseButton1Click = true, MouseEnter = true, MouseLeave = true, InputBegan = true, InputEnded = true, InputChanged = true, Activated = true, Completed = true, MouseButton1Down = true, MouseButton1Up = true, Changed = true, FocusLost = true, Focused = true }
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
      validateProp(props.ClassName, k)
      if k == "Parent" then
        if props.Parent and props.Parent.__removeChild then props.Parent.__removeChild(inst) end
        props.Parent = v
        if v and v.__addChild then v.__addChild(inst) end
      else
        props[k] = v
      end
    end,
  })
  rawset(inst, "__addChild", function(c) children[#children + 1] = c end)
  rawset(inst, "__removeChild", function(c)
    for i = #children, 1, -1 do if children[i] == c then table.remove(children, i) end end
  end)
  rawset(inst, "__isInstance", true) -- so mock typeof() reports "Instance"
  return inst
end

function M.installInto(env, mock, strict)
  M.strict = strict or false
  env.Color3 = {
    fromRGB = function(r, g, b) return { R = r / 255, G = g / 255, B = b / 255, R8 = r, G8 = g, B8 = b } end,
    new = function(r, g, b) return { R = r, G = g, B = b, R8 = math.floor((r or 0) * 255), G8 = math.floor((g or 0) * 255), B8 = math.floor((b or 0) * 255) } end,
    fromHSV = function(h, s, v)
      -- real Roblox returns an RGB Color3; compute it so .R/.G/.B exist
      local r, g, b
      local i = math.floor(h * 6); local f = h * 6 - i
      local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
      i = i % 6
      if i == 0 then r, g, b = v, t, p elseif i == 1 then r, g, b = q, v, p elseif i == 2 then r, g, b = p, v, t
      elseif i == 3 then r, g, b = p, q, v elseif i == 4 then r, g, b = t, p, v else r, g, b = v, p, q end
      return { R = r, G = g, B = b, R8 = math.floor(r * 255 + 0.5), G8 = math.floor(g * 255 + 0.5), B8 = math.floor(b * 255 + 0.5) }
    end,
  }
  env.Vector2 = { new = function(x, y) return { X = x or 0, Y = y or 0 } end }
  env.UDim = { new = function(s, o) return { Scale = s or 0, Offset = o or 0 } end }
  env.UDim2 = { new = function(xs, xo, ys, yo) return { X = { Scale = xs or 0, Offset = xo or 0 }, Y = { Scale = ys or 0, Offset = yo or 0 } } end }
  env.Enum = {
    Font = enumNs({ "BuilderSans", "SourceSans", "Gotham" }),
    FontWeight = enumNs({ "Regular", "Medium", "SemiBold", "Bold" }),
    EasingStyle = enumNs({ "Quart", "Quint", "Linear", "Sine", "Back" }),
    EasingDirection = enumNs({ "In", "Out", "InOut" }),
    AutomaticSize = enumNs({ "None", "X", "Y", "XY" }),
    SortOrder = enumNs({ "LayoutOrder", "Name" }),
    TextXAlignment = enumNs({ "Left", "Center", "Right" }),
    TextYAlignment = enumNs({ "Top", "Center", "Bottom" }),
    VerticalAlignment = enumNs({ "Top", "Center", "Bottom" }),
    HorizontalAlignment = enumNs({ "Left", "Center", "Right" }),
    FillDirection = enumNs({ "Horizontal", "Vertical" }),
    KeyCode = enumNs({ "RightControl", "E", "P", "Insert", "Unknown" }),
    UserInputType = enumNs({ "MouseButton1", "MouseMovement", "Touch", "Keyboard" }),
    ZIndexBehavior = enumNs({ "Sibling", "Global" }),
    ScaleType = enumNs({ "Stretch", "Fit", "Crop", "Tile", "Slice" }),
    UIFlexMode = enumNs({ "None", "Grow", "Shrink", "Fill" }),
    UIFlexAlignment = enumNs({ "None", "Fill", "Center", "Start", "End" }),
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
  env.listfiles = function(dir)
    local out = {}
    for k in pairs(mock.fs) do if k:sub(1, #dir + 1) == dir .. "/" then out[#out + 1] = k end end
    return out
  end

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
      function tw:Pause() end
      function tw:Cancel() end
      mock.lastTween = tw
      return tw
    end,
  }
  local UserInputService = { InputBegan = makeSignal(), InputChanged = makeSignal(), InputEnded = makeSignal(), TouchEnabled = false }
  local playerList = { { Name = "Tester", UserId = 1 } }
  local Players = {
    LocalPlayer = { Name = "Tester", UserId = 1 },
    GetPlayers = function() return playerList end, -- persistent list; tests mutate the returned ref
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
  env.ColorSequenceKeypoint = { new = function(t, c) return { Time = t, Value = c } end }
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
