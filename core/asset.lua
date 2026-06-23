-- Deps injected via Init(R) (none needed). Resolves an Image value to a usable
-- content id. URLs are downloaded once to the executor workspace and exposed via
-- getcustomasset; every executor call is feature-detected + pcall-guarded so this
-- is a safe no-op (nil) under Studio / headless / restricted executors.
local Asset = {}
local cache = {}

function Asset.Init(_) end

local function customAssetFn()
  -- Executors expose getcustomasset/getsynasset as a BARE global (the script environment), and some
  -- ALSO mirror it on _G. Read the bare global FIRST -- it matches how writefile/isfile/game are read
  -- below and is what executor docs use; many sandboxes never populate the raw _G table, so the old
  -- rawget(_G,...)-only probe returned nil and silently disabled every URL image. Fall back to
  -- rawget(_G,...) for the executors that only mirror their API there.
  local fn = getcustomasset or getsynasset or get_custom_asset
    or rawget(_G, "getcustomasset") or rawget(_G, "getsynasset") or rawget(_G, "get_custom_asset")
  if type(fn) == "function" then return fn end
  return nil
end

local function getCustomAsset(path)
  local fn = customAssetFn()
  if not fn then return nil end
  local ok, res = pcall(fn, path)
  if ok and type(res) == "string" then return res end
  return nil
end

local function djb2(s)
  local h = 5381
  for i = 1, #s do h = (h * 33 + string.byte(s, i)) % 2147483647 end
  return h
end

local function fetchUrl(url)
  if cache[url] ~= nil then return cache[url] or nil end
  local hasFS = type(writefile) == "function" and type(isfile) == "function"
  if not hasFS then cache[url] = false; return nil end
  local ext = url:match("%.(%w%w%w%w?)$") or "png"
  local path = "EzUI/assets/" .. djb2(url) .. "." .. ext
  if type(makefolder) == "function" then pcall(makefolder, "EzUI"); pcall(makefolder, "EzUI/assets") end
  if not isfile(path) then
    local body
    if type(game.HttpGet) == "function" then
      local ok, data = pcall(function() return game:HttpGet(url) end)
      if ok then body = data end
    end
    if not body and type(request) == "function" then
      local ok, resp = pcall(request, { Url = url, Method = "GET" })
      if ok and type(resp) == "table" then body = resp.Body end
    end
    if not body then cache[url] = false; return nil end
    local okw = pcall(writefile, path, body)
    if not okw then cache[url] = false; return nil end
  end
  local content = getCustomAsset(path)
  cache[url] = content or false
  return content
end

function Asset.image(value)
  if type(value) ~= "string" or value == "" then return nil end
  if value:match("^rbxassetid://") or value:match("^rbxasset://") or value:match("^rbxthumb://") then return value end
  if value:match("^https?://") then return fetchUrl(value) end
  if value:match("^%d+$") then return "rbxassetid://" .. value end
  return nil
end

-- True if `value` can become an image content id in THIS environment without guessing: a Roblox
-- asset/thumb/numeric id (always), or an http(s) URL when the executor exposes the download+cache
-- globals (writefile/isfile/getcustomasset). Lets callers reserve UI space before the fetch lands.
function Asset.resolvable(value)
  if type(value) ~= "string" or value == "" then return false end
  if value:match("^rbxassetid://") or value:match("^rbxasset://")
      or value:match("^rbxthumb://") or value:match("^%d+$") then return true end
  if value:match("^https?://") then
    if cache[value] then return true end
    return type(writefile) == "function" and type(isfile) == "function" and customAssetFn() ~= nil
  end
  return false
end

-- Resolve an image value WITHOUT blocking the caller. Instant ids invoke `cb` synchronously;
-- http(s) URLs download on a background thread (game:HttpGet yields) and `cb` runs once the content
-- id is ready -- so a title bar / FAB never stalls window construction on the network. `cb` is only
-- ever called with a non-nil id. For URL fetches `cb` runs on a non-privileged thread, so any GUI
-- write inside it must be marshalled through Safe.mutate by the caller.
function Asset.imageAsync(value, cb)
  if type(value) ~= "string" or value == "" then return end
  if value:match("^rbxassetid://") or value:match("^rbxasset://") or value:match("^rbxthumb://") then
    cb(value); return
  end
  if value:match("^%d+$") then cb("rbxassetid://" .. value); return end
  if value:match("^https?://") then
    if cache[value] ~= nil then if cache[value] then cb(cache[value]) end; return end
    local spawn = (type(task) == "table" and task.spawn) or function(fn) fn() end
    spawn(function() local id = fetchUrl(value); if id then cb(id) end end)
  end
end

return Asset
