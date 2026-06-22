local h = require("tests.helper")
local R = h.loadLib()
h.describe("tooltip", function()
  h.it("shows on hover into overlay and hides on leave", function()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    local target = h.roblox.Instance.new("TextButton")
    R.Tooltip.attach(target, "Hello")
    target.MouseEnter:Fire()
    local root = R.Overlay.get(gui); local shown = false
    for _, c in ipairs(root:GetChildren()) do if c.Name == "Tooltip" then shown = true end end
    h.expect(shown).toBeTruthy()
    target.MouseLeave:Fire()
    local still = false
    for _, c in ipairs(root:GetChildren()) do if c.Name == "Tooltip" then still = true end end
    h.expect(still).toBe(false)
  end)
end)
h.run()
