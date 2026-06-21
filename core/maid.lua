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
  if type(t) == "function" then t()
  elseif type(t) == "table" and type(t.Disconnect) == "function" then t:Disconnect()
  elseif type(t) == "table" and type(t.Destroy) == "function" then t:Destroy()
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
