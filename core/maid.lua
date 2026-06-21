local Maid = {}
Maid.__index = Maid

function Maid.new()
  return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Give(task)
  self._tasks[#self._tasks + 1] = task
  return task
end

local function cleanupTask(t)
  -- Roblox Instances and RBXScriptConnections are userdata (type()=="userdata"),
  -- NOT tables — so type()-based branching silently skips them and leaks UI/connections.
  -- Use typeof() (Roblox global; falls back to type() under the headless mock).
  local kind = (typeof and typeof(t)) or type(t)
  if kind == "function" then
    t()
  elseif kind == "Instance" then
    t:Destroy()
  elseif kind == "RBXScriptConnection" then
    t:Disconnect()
  elseif kind == "table" then
    if type(t.Disconnect) == "function" then t:Disconnect()
    elseif type(t.Destroy) == "function" then t:Destroy()
    end
  end
end

function Maid:DoCleanup()
  local tasks = self._tasks
  self._tasks = {}
  for i = #tasks, 1, -1 do
    local ok, err = pcall(cleanupTask, tasks[i])
    if not ok and warn then warn("Maid task error: " .. tostring(err)) end
  end
end

Maid.Destroy = Maid.DoCleanup

return Maid
