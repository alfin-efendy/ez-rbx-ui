local h = require("tests.helper")
local R = h.loadLib()
local Acrylic, Theme, Create = R.Acrylic, R.Theme, R.Create

h.describe("acrylic", function()
  h.it("decorate sets translucent card + adds gradient and stroke", function()
    local f = Create("Frame", {})
    Acrylic.decorate(f, Theme)
    h.expect(f.BackgroundColor3.R8).toBe(24)          -- card
    h.expect(f.BackgroundTransparency).toBe(0.18)
    h.expect(f:FindFirstChildOfClass("UIGradient") ~= nil).toBeTruthy()
    h.expect(f:FindFirstChildOfClass("UIStroke") ~= nil).toBeTruthy()
  end)
  h.it("solid option is opaque with no gradient", function()
    local f = Create("Frame", {})
    Acrylic.decorate(f, Theme, { solid = true })
    h.expect(f.BackgroundTransparency).toBe(0)
    h.expect(f:FindFirstChildOfClass("UIGradient")).toBeNil()
  end)
  h.it("decorate twice does not duplicate stroke", function()
    local f = Create("Frame", {})
    Acrylic.decorate(f, Theme); Acrylic.decorate(f, Theme)
    local strokes = 0
    for _, c in ipairs(f:GetChildren()) do if c.ClassName == "UIStroke" then strokes = strokes + 1 end end
    h.expect(strokes).toBe(1)
  end)
end)

h.run()
