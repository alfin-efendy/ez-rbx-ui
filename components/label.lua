-- Deps injected via Init(R).
local Label = {}
local Create, DefaultTheme, Safe
local RunService = game:GetService("RunService")
local warn = warn or function() end   -- Roblox global; no-op fallback under the headless test mock
-- Run a function on its OWN task-scheduler thread (never the caller's). Falls back to inline only if
-- `task` is missing. Used so a yielding label source never touches the construction/Heartbeat thread.
local spawn = (type(task) == "table" and task.spawn) or function(fn) return fn() end

function Label.Init(R) Create = R.Create; DefaultTheme = R.Theme; Safe = R.Safe end

-- ── Shared reactive scheduler ───────────────────────────────────────────────
-- ONE Heartbeat connection drives EVERY function-valued (reactive) label. It exists only while at
-- least one label is registered (zero idle cost) and is dropped when the last one deregisters, so
-- N reactive labels cost O(1) connections, not O(N). Per frame it only accumulates dt; the re-eval +
-- write happen at most once per label-interval. The poll's GUI access (reading frame.Parent, writing
-- frame.Text) is capability-gated and routed through Safe.mutate: NOT every executor grants the GUI
-- capability to a RunService.Heartbeat handler, and a raw access there throws "lacking capability
-- Plugin" every interval (and aborted the whole drain, killing every other reactive label). Safe.mutate
-- writes inline when the capability is present and defers/degrades quietly when it is not.
local entries = {}            -- list of { acc, interval, tick }; tick() returns false when dead
local conn = nil

local function stepAll(dt)
  dt = dt or 0
  local alive, n = {}, 0
  for _, e in ipairs(entries) do
    e.acc = e.acc + dt
    local keep = true
    if e.acc >= e.interval then e.acc = 0; keep = e.tick() end   -- re-eval+write at interval cadence
    if keep then n = n + 1; alive[n] = e end
  end
  entries = alive
  if n == 0 and conn then conn:Disconnect(); conn = nil end
end

local function register(entry)
  entries[#entries + 1] = entry
  if not conn then conn = RunService.Heartbeat:Connect(stepAll) end
end

local function unregister(entry)
  for i = #entries, 1, -1 do if entries[i] == entry then table.remove(entries, i) end end
  if #entries == 0 and conn then conn:Disconnect(); conn = nil end
end

function Label.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local variant = opts.Variant or "default"
  local source = opts.Text or ""          -- string OR function
  local interval = opts.Interval or 1

  local color = (variant == "default") and theme.Colors.foreground or theme.Colors.mutedForeground
  local size = (variant == "section") and 11 or theme.Font.body.Size

  local frame = Create("TextLabel", {
    Name = "Label",
    BackgroundTransparency = 1,
    Text = "",                            -- set by setSource below (static value, or first eval)
    TextColor3 = color,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextSize = size,
    TextWrapped = variant == "paragraph",
    Font = Enum.Font.BuilderSans,
    Size = UDim2.new(1, 0, 0, size + 6),
    AutomaticSize = (variant == "paragraph") and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
    LayoutOrder = opts.LayoutOrder or 0,
    Parent = opts.Parent,
  })

  if opts.AccentReg then opts.AccentReg(function()
    frame.TextColor3 = (variant == "default") and theme.Colors.foreground or theme.Colors.mutedForeground
  end) end

  local lastText, erroring, entry = nil, false, nil

  -- Write a value to the label. direct=true writes inline (label creation runs on the main thread,
  -- which holds the capability); otherwise routes through Safe.mutate so a caller that may lack the
  -- GUI capability (a coroutine/task.spawn thread, OR the reactive poll's Heartbeat handler on
  -- executors that don't grant it there) stays capability-safe. The lastText guard skips redundant
  -- property writes (a value that hasn't changed costs nothing).
  local function applyText(s, direct)
    s = (variant == "section") and string.upper(tostring(s)) or tostring(s)
    if s == lastText then return end
    lastText = s
    if direct then frame.Text = s else Safe.mutate(function() frame.Text = s end) end
  end

  -- Re-evaluate a function source on its OWN scheduler thread, never on the caller's. The caller is UI
  -- construction (initial eval) or the shared Heartbeat tick. A source that yields (a
  -- RemoteFunction:InvokeServer / task.wait getter) called inline would yield the caller -- and on a
  -- capability-strict executor the caller resumes WITHOUT the GUI capability, after which the NEXT
  -- control's write threw "lacking capability Plugin" and aborted the whole section. task.spawn isolates
  -- the source completely, so construction never yields/degrades; the write is always capability-safe
  -- (Safe.mutate). On error, keep the last good value (no per-tick flicker) and warn once per streak.
  local function evaluate()
    if type(source) ~= "function" then return end
    local fn = source
    spawn(function()
      local ok, res = pcall(fn)
      if fn ~= source then return end                   -- source swapped while we ran -> drop stale result
      if ok then
        erroring = false
        applyText(res, false)
      elseif not erroring then
        erroring = true
        warn("[EzUI] Label dynamic text error: " .. tostring(res))
      end
    end)
  end

  local function startReactive()
    if entry then return end
    entry = { acc = 0, interval = interval, tick = function()
      -- Reading frame.Parent and writing frame.Text both touch the protected GUI, which throws on a
      -- Heartbeat thread that lacks the executor capability. pcall the destroyed-probe and route the
      -- write through Safe.mutate so the poll never throws/spams -- it updates when the capability is
      -- present and degrades quietly otherwise (instead of aborting the whole drain).
      local ok, parent = pcall(function() return frame.Parent end)
      if ok and parent == nil then return false end  -- destroyed -> drop from the scheduler
      evaluate()                                      -- runs the source off-thread; write is capability-safe
      return true
    end }
    register(entry)
  end

  local function stopReactive()
    if entry then unregister(entry); entry = nil end
  end

  -- Point the label at a new source. A function -> reactive (poll on the shared scheduler); a
  -- string -> static (stop polling). Evaluates/writes immediately so the value shows at once.
  local function setSource(v, direct)
    source = v
    if type(v) == "function" then
      startReactive()
      evaluate()                  -- function source: evaluated off-thread (a string never yields)
    else
      stopReactive()
      applyText(v, direct)        -- static string: safe to write inline on the caller's thread
    end
  end

  setSource(source, true)                 -- initial render (creation is on a capability-bearing thread)

  return {
    Frame = frame,
    SetText = function(v) setSource(v, false) end,   -- a user call may arrive on a coroutine -> Safe path
    Destroy = function() stopReactive(); frame:Destroy() end,
  }
end

return Label
