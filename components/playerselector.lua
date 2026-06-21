-- Deps injected via Init(R). Wraps SelectBox with the live player list.
local PlayerSelector = {}
local SelectBox, Maid
local Players = game:GetService("Players")
function PlayerSelector.Init(R) SelectBox = R.SelectBox; Maid = R.Maid end

local function names()
  local t = {}
  for _, p in ipairs(Players:GetPlayers()) do t[#t + 1] = p.Name end
  return t
end

function PlayerSelector.new(opts)
  opts = opts or {}
  local maid = Maid.new()
  local current = names()
  local sb = SelectBox.new({
    Parent = opts.Parent, LayoutOrder = opts.LayoutOrder, Theme = opts.Theme, Config = opts.Config,
    Flag = opts.Flag, Multi = opts.Multi, Text = opts.Text, Options = current,
    Default = opts.Multi and {} or current[1], Callback = opts.Callback,
  })
  local function refresh() current = names(); sb.SetOptions(current) end
  maid:Give(Players.PlayerAdded:Connect(refresh))
  maid:Give(Players.PlayerRemoving:Connect(refresh))
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
