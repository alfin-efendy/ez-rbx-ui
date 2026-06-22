local HttpService = game:GetService("HttpService")

local Config = {}
Config.__index = Config

local function hasFS()
  return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

function Config.new(opts)
  opts = opts or {}
  return setmetatable({
    folder = opts.FolderName or "EzUI",
    file = opts.FileName or "Settings",
    autoSave = opts.AutoSave ~= false,
    autoLoad = opts.AutoLoad ~= false,
    profile = "Default",
    values = {},
    defaults = {},
    setters = {},
  }, Config)
end

function Config:_dir() return self.folder .. "/" .. self.file end
function Config:_path() return self:_dir() .. "/" .. self.profile .. ".json" end
function Config:_legacyPath() return self.folder .. "/" .. self.file .. ".json" end

function Config:ActiveProfile() return self.profile end

function Config:SwitchProfile(name)
  self.profile = name or "Default"
  self:Load()
  return self.profile
end

function Config:ListProfiles()
  local names = { Default = true }
  if type(listfiles) == "function" then
    local ok, files = pcall(listfiles, self:_dir())
    if ok and type(files) == "table" then
      for _, f in ipairs(files) do
        local n = tostring(f):match("([^/\\]+)%.json$")
        if n then names[n] = true end
      end
    end
  end
  local out = {}
  for n in pairs(names) do out[#out + 1] = n end
  return out
end

function Config:DeleteProfile(name)
  if type(delfile) == "function" and type(isfile) == "function" then
    local p = self:_dir() .. "/" .. name .. ".json"
    if isfile(p) then pcall(delfile, p) end
  end
end

function Config:Register(flag, default, setValue)
  self.defaults[flag] = default
  self.setters[flag] = setValue
  if self.values[flag] == nil then self.values[flag] = default end
end

function Config:Get(flag) return self.values[flag] end

function Config:Set(flag, value)
  self.values[flag] = value
  if self.autoSave then self:Save() end
end

function Config:GetAllKeys()
  local keys = {}
  for k in pairs(self.values) do keys[#keys + 1] = k end
  return keys
end

function Config:Save()
  if not hasFS() then return false end
  local ok, encoded = pcall(function() return HttpService:JSONEncode(self.values) end)
  if not ok then return false end
  if type(makefolder) == "function" then pcall(makefolder, self.folder); pcall(makefolder, self:_dir()) end
  return pcall(writefile, self:_path(), encoded)
end

function Config:Load()
  if not hasFS() then return false end
  local path = self:_path()
  if not isfile(path) and self.profile == "Default" and isfile(self:_legacyPath()) then path = self:_legacyPath() end
  if not isfile(path) then return false end
  local ok, content = pcall(readfile, path)
  if not ok then return false end
  local ok2, decoded = pcall(function() return HttpService:JSONDecode(content) end)
  if not ok2 or type(decoded) ~= "table" then return false end
  for flag, value in pairs(decoded) do
    self.values[flag] = value
    if self.setters[flag] then pcall(self.setters[flag], value) end
  end
  return true
end

function Config:ResetFlag(flag)
  local d = self.defaults[flag]
  self.values[flag] = d
  if self.setters[flag] then pcall(self.setters[flag], d) end
  if self.autoSave then self:Save() end
end

function Config:Reset(opts)
  opts = opts or {}
  for flag, d in pairs(self.defaults) do
    self.values[flag] = d
    if self.setters[flag] then pcall(self.setters[flag], d) end
  end
  if opts.ClearFile and type(delfile) == "function" and hasFS() and isfile(self:_path()) then
    pcall(delfile, self:_path())
  else
    self:Save()
  end
end

return Config
