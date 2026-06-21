local mockmod = require("tests.mock_roblox")

local H = { roblox = {}, _tests = {}, _suite = "" }
local mock = {}
mockmod.installInto(H.roblox, mock)
H.mock = mock

-- require a project module ("core/signal" or "core.signal") with Roblox globals injected
local cache = {}
function H.requireModule(path)
  local key = path:gsub("/", ".")
  if cache[key] then return cache[key] end
  local file = key:gsub("%.", "/") .. ".lua"
  local chunk, err = loadfile(file)
  if not chunk then error("cannot load " .. file .. ": " .. tostring(err)) end

  local env = setmetatable({}, { __index = function(_, k)
    if H.roblox[k] ~= nil then return H.roblox[k] end
    return _G[k]
  end })
  -- project modules use require("a/b"); route those through requireModule
  env.require = function(p) return H.requireModule(p) end

  setfenv(chunk, env) -- Lua 5.1 / LuaJIT
  local ok, mod = pcall(chunk)
  if not ok then error("error running " .. file .. ": " .. tostring(mod)) end
  cache[key] = mod
  return mod
end

function H.describe(name, fn) H._suite = name; fn(); H._suite = "" end
function H.it(name, fn)
  H._tests[#H._tests + 1] = { name = (H._suite ~= "" and H._suite .. " > " or "") .. name, fn = fn }
end

function H.expect(v)
  local E = {}
  function E.toBe(x) if v ~= x then error("expected " .. tostring(x) .. " got " .. tostring(v), 2) end end
  function E.toBeNil() if v ~= nil then error("expected nil got " .. tostring(v), 2) end end
  function E.toBeTruthy() if not v then error("expected truthy got " .. tostring(v), 2) end end
  function E.toHaveLength(n) if #v ~= n then error("expected length " .. n .. " got " .. #v, 2) end end
  function E.toEqual(x)
    local function deep(a, b)
      if type(a) ~= "table" or type(b) ~= "table" then return a == b end
      for k, av in pairs(a) do if not deep(av, b[k]) then return false end end
      for k in pairs(b) do if a[k] == nil then return false end end
      return true
    end
    if not deep(v, x) then error("tables not equal", 2) end
  end
  function E.toThrow(substr)
    local ok, err = pcall(v)
    if ok then error("expected function to throw", 2) end
    if substr and not tostring(err):find(substr, 1, true) then
      error("threw '" .. tostring(err) .. "', expected to contain '" .. substr .. "'", 2)
    end
  end
  return E
end

function H.run()
  local passed, failed = 0, 0
  for _, t in ipairs(H._tests) do
    local ok, err = pcall(t.fn)
    if ok then
      passed = passed + 1; print("PASS  " .. t.name)
    else
      failed = failed + 1; print("FAIL  " .. t.name .. "\n      " .. tostring(err))
    end
  end
  print(string.format("TOTAL: %d passed, %d failed", passed, failed))
  if failed > 0 then os.exit(1) end
end

return H
