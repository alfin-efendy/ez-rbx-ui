local Signal = {}
Signal.__index = Signal

function Signal.new()
  return setmetatable({ _handlers = {}, _order = {} }, Signal)
end

function Signal:Connect(fn)
  self._order[#self._order + 1] = fn
  self._handlers[fn] = true
  return { Disconnect = function()
    self._handlers[fn] = nil
    for i, f in ipairs(self._order) do if f == fn then table.remove(self._order, i) break end end
  end }
end

function Signal:Once(fn)
  local conn
  conn = self:Connect(function(...) conn.Disconnect(); fn(...) end)
  return conn
end

function Signal:Fire(...)
  local snapshot = {}
  for i, fn in ipairs(self._order) do snapshot[i] = fn end
  for _, fn in ipairs(snapshot) do if self._handlers[fn] then fn(...) end end
end

function Signal:DisconnectAll()
  self._handlers = {}; self._order = {}
end

return Signal
