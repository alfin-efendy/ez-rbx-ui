-- Pure number formatting/parsing. No Roblox/UI/theme dependencies.
local Numfmt = {}

local UNITS = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "k" } }

-- round to `dec` decimals, strip trailing zeros and a trailing dot
local function trim(n, dec)
  dec = dec or 0
  local s = string.format("%." .. dec .. "f", n)
  if dec > 0 then
    s = s:gsub("0+$", "")
    s = s:gsub("%.$", "")
  end
  if s == "-0" then s = "0" end
  return s
end

local function compact(n, dec)
  local a = math.abs(n)
  if a < 1e3 then return trim(n, dec) end
  for _, u in ipairs(UNITS) do
    if a >= u[1] then return trim(n / u[1], dec) .. u[2] end
  end
  return trim(n, dec)
end

local function comma(n, dec)
  local neg = n < 0
  local a = math.abs(n)
  local intpart = math.floor(a)
  local frac = ""
  if dec > 0 then
    local f = trim(a - intpart, dec)            -- "0.5" or "0"
    local dot = f:find("%.")
    if dot then frac = f:sub(dot) end           -- ".5"
  end
  local s = tostring(intpart)
  s = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
  s = s:gsub("^,", "")
  return (neg and "-" or "") .. s .. frac
end

function Numfmt.format(n, opts)
  opts = opts or {}
  n = tonumber(n) or 0
  local body
  if opts.Format == "compact" then body = compact(n, opts.Decimals or 1)
  elseif opts.Format == "comma" then body = comma(n, opts.Decimals or 1)
  elseif opts.Decimals ~= nil then body = trim(n, opts.Decimals)
  else body = tostring(n) end
  return (opts.Prefix or "") .. body .. (opts.Suffix or "")
end

return Numfmt
