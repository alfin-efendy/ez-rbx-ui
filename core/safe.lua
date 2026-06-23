-- Deps injected via Init(R). Runs GUI mutations in a capability-bearing context: inline when the
-- current thread already holds the GUI ("Plugin") capability, otherwise deferred to the next
-- RunService.Heartbeat (whose callback holds the capability). This is the Roblox-executor analogue
-- of runOnUiThread/Dispatcher.Invoke -- it marshals work to a privileged context; it is NOT state
-- management. See components/selectbox.lua runLoader for the original Heartbeat:Once pattern.
local Safe = {}
local Overlay
local RunService = game:GetService("RunService")

local queue = {}          -- FIFO of deferred jobs
local flushConn = nil

function Safe.Init(R) Overlay = R.Overlay end

-- Does the CURRENT thread hold the GUI capability? Probe with a harmless, signature-free,
-- idempotent same-value write to the protected overlay root. The write is capability-gated: it
-- succeeds on the main thread / a signal handler and throws on a task.spawn/coroutine thread.
-- No attribute/name is added, so no EzUI signature leaks. No protected root yet -> assume true
-- (runtime mutators are only reached once a window exists; init runs on the main thread anyway).
local function defaultHasCapability()
  -- The whole probe runs inside ONE pcall: Overlay.peek() reads root.Parent, and READING a
  -- protected Instance property ALSO throws "lacking capability" on a thread without it (not just
  -- writes). So peek() must be inside the pcall too -- previously it ran outside, so its throw
  -- escaped the probe and Safe.mutate never reached the Heartbeat fallback. Semantics preserved:
  -- no root yet -> peek short-circuits and reads nothing -> no throw -> true (assume capability);
  -- root + capability -> read+write succeed -> true; root + no capability -> read throws -> false.
  return (pcall(function()
    local root = Overlay and Overlay.peek and Overlay.peek()
    if root then root.BackgroundTransparency = root.BackgroundTransparency end
  end))
end

local hasCapability = defaultHasCapability
function Safe._setCapabilityCheck(fn) hasCapability = fn or defaultHasCapability end

local function flush()
  flushConn = nil
  -- Runs inside a Heartbeat callback => capability present. Drain FIFO; isolate each job so one
  -- failure does not abort the drain.
  local i = 1
  while i <= #queue do local job = queue[i]; i = i + 1; pcall(job) end
  for k = #queue, 1, -1 do queue[k] = nil end
end

-- Run fn in a capability-bearing context. Inline (synchronous) if the current thread has the
-- capability; otherwise enqueue and flush on the next Heartbeat (FIFO preserved).
function Safe.mutate(fn)
  if hasCapability() then return fn() end
  queue[#queue + 1] = fn
  if not flushConn then flushConn = RunService.Heartbeat:Once(flush) end
end

return Safe
