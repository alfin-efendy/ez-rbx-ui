local h = require("tests.helper")

local function ctx()
  local R = h.loadLib()
  local uis = h.roblox.game:GetService("UserInputService")
  local cam = h.roblox.workspace.CurrentCamera
  -- reset to a clean desktop baseline for each test
  uis.TouchEnabled = false; uis.MouseEnabled = true; uis.KeyboardEnabled = true
  h.mock.tenFoot = false
  cam.ViewportSize = h.roblox.Vector2.new(1280, 720)
  return R.Device, uis, cam
end

h.describe("device type", function()
  h.it("is Desktop by default (mouse, no touch, not ten-foot)", function()
    local D = ctx()
    h.expect(D.GetType()).toBe("Desktop")
    h.expect(D.IsDesktop()).toBe(true)
    h.expect(D.IsTouch()).toBe(false)
  end)
  h.it("is Console when GuiService reports a ten-foot interface", function()
    local D = ctx()
    h.mock.tenFoot = true
    h.expect(D.GetType()).toBe("Console")
    h.expect(D.IsConsole()).toBe(true)
  end)
  h.it("is Mobile for a touch-only elongated viewport", function()
    local D, uis, cam = ctx()
    uis.TouchEnabled = true; uis.MouseEnabled = false
    cam.ViewportSize = h.roblox.Vector2.new(320, 640) -- aspect 2.0 (phone)
    h.expect(D.GetType()).toBe("Mobile")
    h.expect(D.IsMobile()).toBe(true)
    h.expect(D.IsTouch()).toBe(true)
  end)
  h.it("is Tablet for a touch-only squarish viewport", function()
    local D, uis, cam = ctx()
    uis.TouchEnabled = true; uis.MouseEnabled = false
    cam.ViewportSize = h.roblox.Vector2.new(1024, 768) -- aspect 1.33 (tablet)
    h.expect(D.GetType()).toBe("Tablet")
    h.expect(D.IsTablet()).toBe(true)
  end)
end)

h.describe("device input modality", function()
  h.it("defaults to KeyboardMouse", function()
    local R = h.loadLib(); h.mock.lastInputType = nil
    h.expect(R.Device.GetInput()).toBe("KeyboardMouse")
  end)
  h.it("reports Touch", function()
    local R = h.loadLib(); h.mock.lastInputType = h.roblox.Enum.UserInputType.Touch
    h.expect(R.Device.GetInput()).toBe("Touch")
  end)
  h.it("reports Gamepad", function()
    local R = h.loadLib(); h.mock.lastInputType = h.roblox.Enum.UserInputType.Gamepad1
    h.expect(R.Device.GetInput()).toBe("Gamepad")
  end)
end)

h.run()
