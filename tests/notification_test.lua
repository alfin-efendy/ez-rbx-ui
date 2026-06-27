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
    h.expect(bar().BackgroundColor3.G8).toBe(R.Theme.Colors.success.G8) -- success tint (compare by value; window deep-copies its theme)
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
  h.it("loading toast: spinner started, no countdown bar, persists", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    local function findToast()
      for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then
        for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then return t end end end end
    end
    local id = w:ShowLoading({ Title = "Saving" })
    local toast = findToast()
    h.expect(toast ~= nil).toBeTruthy()
    h.expect(toast:FindFirstChild("Progress")).toBeNil()             -- loading has no countdown bar
    local icon = toast:FindFirstChild("TitleRow"):FindFirstChild("Icon")
    h.expect(icon.Rotation).toBe(360)                                -- spin tween created + played (mock applies goal)
    h.mock.stepHeartbeat(5)                                          -- a timed toast would dismiss here
    h.expect(findToast() ~= nil).toBeTruthy()                        -- still alive: persistent
    w:DismissNotification(id)
    h.expect(findToast()).toBeNil()
  end)
  h.it("show returns id synchronously and defers GUI when capability is absent (FIFO)", function()
    local R = h.loadLib(); local screen = h.roblox.Instance.new("ScreenGui"); local ov = R.Overlay.get(screen)
    R.Notification.clearAll()
    R.Safe._setCapabilityCheck(function() return false end)
    local function toasts() local n = 0 for _, c in ipairs(ov:GetChildren()) do
      if c.Name == "ToastContainer" then for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then n = n + 1 end end end
    end return n end
    local id1 = R.Notification.show({ Title = "A", Duration = 0 })
    local id2 = R.Notification.show({ Title = "B", Duration = 0 })
    h.expect(type(id1)).toBe("number")          -- id available synchronously
    h.expect(id2).toBe(id1 + 1)                 -- seq is synchronous + FIFO
    h.expect(R.Notification.count()).toBe(2)    -- order slots reserved synchronously
    h.expect(toasts()).toBe(0)                  -- GUI not built yet (deferred)
    h.mock.stepHeartbeat(0)                     -- flush Safe queue
    h.expect(toasts()).toBe(2)                  -- toasts built in a capability context
    R.Safe._setCapabilityCheck(nil)
    R.Notification.clearAll()
  end)
  h.it("update morphs loading -> success: bar + color + title, spinner reset", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    local function findToast()
      for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then
        for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then return t end end end end
    end
    local id = w:ShowLoading({ Title = "Saving" })
    R.Notification.update(id, { Type = "success", Title = "Saved", Duration = 1000 })
    local toast = findToast()
    local title = toast:FindFirstChild("TitleRow"):FindFirstChild("Title")
    h.expect(title.Text).toBe("Saved")
    local bar = toast:FindFirstChild("Progress")
    h.expect(bar ~= nil).toBeTruthy()
    h.expect(bar.BackgroundColor3.G8).toBe(R.Theme.Colors.success.G8)  -- compare by value (window deep-copies theme)
    local icon = toast:FindFirstChild("TitleRow"):FindFirstChild("Icon")
    h.expect(icon.Rotation).toBe(0)                                    -- spinner stopped + reset
    h.mock.stepHeartbeat(1.2)                                          -- countdown expires
    h.expect(findToast()).toBeNil()
  end)

  h.it("promise resolves: loading -> success, message fn gets result, finally runs", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    local function findToast()
      for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then
        for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then return t end end end end
    end
    local finallyRan = false
    w:Promise(function() return 7 end, {
      Loading = "Working", Success = function(n) return "Got " .. n end,
      Error = "nope", Finally = function() finallyRan = true end, Duration = 1000 })
    h.expect(findToast():FindFirstChild("Progress")).toBeNil()    -- loading state: no bar yet
    h.mock.stepHeartbeat(0)                                       -- fire the Heartbeat:Once runner
    local toast = findToast()
    h.expect(toast:FindFirstChild("TitleRow"):FindFirstChild("Title").Text).toBe("Got 7")
    h.expect(toast:FindFirstChild("Progress") ~= nil).toBeTruthy()
    h.expect(finallyRan).toBe(true)
  end)

  h.it("promise rejects: morphs to error, err passed to Error fn", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    local function findToast()
      for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then
        for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then return t end end end end
    end
    w:Promise(function() error("boom") end, {
      Loading = "Working", Success = "ok", Error = function(e) return "Failed: " .. tostring(e) end })
    h.mock.stepHeartbeat(0)
    local toast = findToast()
    h.expect(toast:FindFirstChild("TitleRow"):FindFirstChild("Title").Text:find("Failed:") ~= nil).toBeTruthy()
    h.expect(toast:FindFirstChild("Progress").BackgroundColor3.G8).toBe(R.Theme.Colors.destructive.G8)
  end)

  h.it("promise without capability: build + morph deferred, ends in success (pendingUpdate branch)", function()
    local R = h.loadLib(); local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    R.Notification.clearAll()
    R.Safe._setCapabilityCheck(function() return false end)   -- force deferral, like notification_test.lua:58
    local w = R.Window.new({ Title = "W", Parent = gui })
    local function findToast()
      for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then
        for _, t in ipairs(c:GetChildren()) do if t.Name == "Toast" then return t end end end end
    end
    w:Promise(function() return 1 end, { Loading = "Working", Success = "Done", Error = "nope", Duration = 1000 })
    h.expect(findToast()).toBeNil()              -- nothing built yet: show's build + runner are both deferred
    -- Two steps settle the deferred build + morph regardless of mock handler-fire order
    -- (real Roblox Heartbeat is FIFO and settles in one frame; the mock's pairs() order is not,
    -- so step once to flush the build and once more to guarantee the morph is applied).
    h.mock.stepHeartbeat(0)
    h.mock.stepHeartbeat(0)
    local toast = findToast()
    h.expect(toast ~= nil).toBeTruthy()
    h.expect(toast:FindFirstChild("TitleRow"):FindFirstChild("Title").Text).toBe("Done")  -- pendingUpdate applied
    h.expect(toast:FindFirstChild("Progress") ~= nil).toBeTruthy()
    R.Safe._setCapabilityCheck(nil)
    R.Notification.clearAll()
  end)

  h.it("default position bottom-right; setPosition re-anchors live container (normalizes)", function()
    R.Notification.clearAll(); R.Notification.setPosition("bottom-right")
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    w:Notify({ Title = "x", Duration = 0 })
    local function cont() for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then return c end end end
    h.expect(cont().AnchorPoint.X).toBe(1); h.expect(cont().AnchorPoint.Y).toBe(1)
    w:SetNotificationPosition("Top Left")
    h.expect(cont().AnchorPoint.X).toBe(0); h.expect(cont().AnchorPoint.Y).toBe(0)
    R.Notification.setPosition("bottom-right")   -- restore process-wide state
  end)

  h.it("CreateWindow NotificationPosition sets initial position", function()
    R.Notification.clearAll()
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui, NotificationPosition = "top-center" })
    w:Notify({ Title = "x", Duration = 0 })
    local cont; for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then cont = c end end
    h.expect(cont.AnchorPoint.X).toBe(0.5); h.expect(cont.AnchorPoint.Y).toBe(0)
    R.Notification.setPosition("bottom-right")   -- restore process-wide state
  end)
  h.it("hover hit-area tracks content height, not full screen (no center-screen false hover)", function()
    R.Notification.clearAll(); R.Notification.setPosition("top-center")
    local gui = h.roblox.Instance.new("ScreenGui"); local root = R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    w:ShowLoading({ Title = "Loading" })
    local cont; for _, c in ipairs(root:GetChildren()) do if c.Name == "ToastContainer" then cont = c end end
    h.expect(cont ~= nil).toBeTruthy()
    -- Container is the MouseEnter/Leave hit-area. It must be sized to the toast stack, NOT the
    -- full screen height (was UDim2.new(0,300,1,-32)) — otherwise resting the mouse anywhere in
    -- the centre column of a top-center/bottom-center stack falsely triggers hover/expand.
    h.expect(cont.Size.Y.Scale).toBe(0)                 -- content-sized, not 1 (full height)
    h.expect(cont.Size.Y.Offset > 0).toBeTruthy()       -- a real (small) hit area exists
    h.expect(cont.Size.Y.Offset < 600).toBeTruthy()     -- nowhere near full viewport height
    R.Notification.setPosition("bottom-right")           -- restore process-wide state
    R.Notification.clearAll()
  end)
end)
h.run()
