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
  h.it("timed toast auto-dismisses", function()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    w:Notify({ Title = "Bye", Duration = 100 }) -- mock task.delay runs synchronously -> immediate dismiss
    h.expect(toastCount(gui)).toBe(0)
  end)
end)
h.run()
