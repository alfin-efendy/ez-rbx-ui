local h = require("tests.helper")

h.describe("mock device surface", function()
  h.it("exposes GuiService, UserInputService capabilities, and a camera", function()
    local gui = h.roblox.game:GetService("GuiService")
    h.expect(type(gui.IsTenFootInterface)).toBe("function")
    h.mock.tenFoot = true
    h.expect(gui:IsTenFootInterface()).toBe(true)
    h.mock.tenFoot = false
    h.expect(gui:IsTenFootInterface()).toBe(false)

    local uis = h.roblox.game:GetService("UserInputService")
    h.expect(uis.MouseEnabled).toBe(true)
    h.expect(type(uis.GetLastInputType)).toBe("function")
    h.expect(type(uis.GetPropertyChangedSignal)).toBe("function")
    h.expect(uis.LastInputTypeChanged ~= nil).toBeTruthy()

    local cam = h.roblox.workspace.CurrentCamera
    h.expect(cam.ViewportSize.X).toBe(1280)
    h.expect(cam.ViewportSize.Y).toBe(720)
    h.expect(h.roblox.Enum.UserInputType.Gamepad1.Name).toBe("Gamepad1")
  end)
end)

h.run()
