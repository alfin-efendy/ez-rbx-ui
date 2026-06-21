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
  h.it("adds a type-tinted countdown bar for timed toasts, none for persistent", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local realDelay = h.roblox.task.delay
    h.roblox.task.delay = function() end -- keep timed toast alive so we can inspect it
    R.Notification.show({ Title = "timed", Type = "success", Duration = 3000, Theme = R.Theme })
    R.Notification.show({ Title = "sticky", Type = "info", Duration = 0, Theme = R.Theme })
    h.roblox.task.delay = realDelay
    local bars, tintOk = 0, false
    for _, c in ipairs(root:GetChildren()) do
      if c.Name == "ToastContainer" then
        for _, t in ipairs(c:GetChildren()) do
          if t.Name == "Toast" then
            local p = t:FindFirstChild("Progress")
            if p then bars = bars + 1; if p.BackgroundColor3 == R.Theme.Colors.success then tintOk = true end end
          end
        end
      end
    end
    h.expect(bars).toBe(1)
    h.expect(tintOk).toBe(true)
  end)
  h.it("timed toast auto-dismisses", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    w:Notify({ Title = "Bye", Duration = 100 }) -- mock task.delay runs synchronously -> immediate dismiss
    h.expect(toastCount(gui)).toBe(0)
  end)
end)
h.run()
