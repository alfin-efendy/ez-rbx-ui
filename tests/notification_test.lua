local h = require("tests.helper")
local R = h.loadLib()
local function toastCount(gui)
  local root = R.Overlay.get(gui)
  local n = 0
  for _, c in ipairs(root:GetChildren()) do
    if c.Name == "ToastContainer" then for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then n = n + 1 end end end
  end
  return n
end
h.describe("notification", function()
  h.it("persistent toast mounts; dismiss removes it", function()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    local id = w:Notify({ Title = "Hi", Type = "success", Duration = 0 })
    h.expect(toastCount(gui)).toBe(1)
    w:DismissNotification(id)
    h.expect(toastCount(gui)).toBe(0)
  end)
  h.it("two persistent toasts stack (both present)", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    w:Notify({ Title = "A", Duration = 0 }); w:Notify({ Title = "B", Duration = 0 })
    h.expect(toastCount(gui)).toBe(2)
  end)
  h.it("countdown bar shrinks, pauses on hover, dismisses at zero", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    w:Notify({ Title = "t", Type = "success", Duration = 1000 }) -- total = 1s
    local function cont() for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then return c end end end
    local function bar() local c = cont(); for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then local p = t:FindFirstChild("Progress"); if p then return p end end end end
    h.expect(bar() ~= nil).toBeTruthy()
    h.expect(bar().BackgroundColor3).toBe(R.Theme.Colors.success)
    h.mock.stepHeartbeat(0.5)
    h.expect(math.abs(bar().Size.X.Scale - 0.5) < 0.12).toBeTruthy()
    cont().MouseEnter:Fire()              -- pause
    h.mock.stepHeartbeat(1.0)             -- would have dismissed if not paused
    h.expect(bar() ~= nil).toBeTruthy()   -- still alive, bar frozen
    cont().MouseLeave:Fire()              -- resume
    h.mock.stepHeartbeat(1.0)             -- past remaining -> dismiss
    h.expect(toastCount(gui)).toBe(0)
  end)
  h.it("persistent toast has no countdown bar", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    w:Notify({ Title = "x", Duration = 0 })
    local has = false
    for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then
      for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" and t:FindFirstChild("Progress") then has = true end end end end
    h.expect(has).toBe(false)
  end)
end)
h.run()
