local h = require("tests.helper")
local R = h.loadLib()
local Separator, Create = R.Separator, R.Create

h.describe("separator", function()
  h.it("is a thin bordered frame parented with layout order", function()
    local p = Create("Frame", {})
    local s = Separator.new({ Parent = p, LayoutOrder = 4 })
    h.expect(s.Frame.Parent).toBe(p)
    h.expect(s.Frame.LayoutOrder).toBe(4)
    h.expect(s.Frame.BackgroundColor3.R8).toBe(63)  -- border
    h.expect(s.Frame.Size.Y.Offset).toBe(1)
  end)
end)

h.run()
