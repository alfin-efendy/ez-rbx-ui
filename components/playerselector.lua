-- Deps injected via Init(R). Wraps SelectBox with the live player list.
local PlayerSelector = {}
local SelectBox, Maid
local Players = game:GetService("Players")
function PlayerSelector.Init(R) SelectBox = R.SelectBox; Maid = R.Maid end

local function names(exclude)
  local t = {}
  for _, p in ipairs(Players:GetPlayers()) do
    if p ~= exclude then t[#t + 1] = p.Name end -- PlayerRemoving fires while the player is still in GetPlayers()
  end
  return t
end

local function contains(list, v) for _, x in ipairs(list) do if x == v then return true end end return false end

function PlayerSelector.new(opts)
  opts = opts or {}
  local maid = Maid.new()
  local current = names()
  local sb = SelectBox.new({
    Parent = opts.Parent, LayoutOrder = opts.LayoutOrder, Theme = opts.Theme, Config = opts.Config,
    Flag = opts.Flag, Multi = opts.Multi, Text = opts.Text, Options = current,
    Default = opts.Multi and {} or current[1], Callback = opts.Callback, AccentReg = opts.AccentReg,
  })
  local function refresh(exclude)
    current = names(exclude)
    sb.SetOptions(current)
    -- prune a selection that points at a player who left
    local v = sb.GetValue()
    if opts.Multi then
      local keep = {}
      for _, x in ipairs(v or {}) do if contains(current, x) then keep[#keep + 1] = x end end
      sb.SetValue(keep)
    elseif v ~= nil and not contains(current, v) then
      sb.SetValue(current[1])
    end
  end
  maid:Give(Players.PlayerAdded:Connect(function() refresh() end))
  maid:Give(Players.PlayerRemoving:Connect(function(p) refresh(p) end))
  maid:Give(function() sb.Destroy() end)
  return {
    Frame = sb.Frame,
    GetValue = sb.GetValue,
    SetValue = sb.SetValue,
    GetOptions = function() return current end,
    Refresh = refresh,
    Destroy = function() maid:DoCleanup() end,
  }
end

return PlayerSelector
