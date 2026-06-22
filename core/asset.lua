-- Deps injected via Init(R) (none needed). Resolves an Image value to a usable
-- content id. URLs are downloaded once to the executor workspace and exposed via
-- getcustomasset; every executor call is feature-detected + pcall-guarded so this
-- is a safe no-op (nil) under Studio / headless / restricted executors.
local Asset = {}
local cache = {}

function Asset.Init(_) end

local function getCustomAsset(path)
  local fn = rawget(_G, "getcustomasset") or rawget(_G, "getsynasset") or rawget(_G, "get_custom_asset")
  if type(fn) ~= "function" then return nil end
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

return Asset
