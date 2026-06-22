local h = require("tests.helper")
local R = h.loadLib()
local Button, Create = R.Button, R.Create

h.describe("button", function()
  h.it("default variant uses primary bg, fires Callback on click", function()
    local p = Create("Frame", {})
    local clicks = 0
    local b = Button.new({ Parent = p, Text = "Go", Callback = function() clicks = clicks + 1 end, LayoutOrder = 2 })
    h.expect(b.Frame:FindFirstChild("Surface").BackgroundColor3.R8).toBe(250)  -- primary mono
    h.expect(b.Frame.LayoutOrder).toBe(2)
    b.Frame.MouseButton1Click:Fire()
    h.expect(clicks).toBe(1)
  end)
  h.it("Action=ResetConfig calls Window:ResetConfiguration", function()
    local reset = 0
    local fakeWindow = { ResetConfiguration = function() reset = reset + 1 end }
    local b = Button.new({ Text = "Reset", Variant = "destructive", Action = "ResetConfig", Window = fakeWindow })
    b.Frame.MouseButton1Click:Fire()
    h.expect(reset).toBe(1)
  end)
  h.it("ghost variant is invisible at rest but reveals a surface wash on hover", function()
    local b = Button.new({ Parent = Create("Frame", {}), Text = "Ghost", Variant = "ghost" })
    local surface = b.Frame:FindFirstChild("Surface")
    h.expect(surface.BackgroundColor3.R8).toBe(R.Theme.Colors.surface.R8)  -- muted wash, not card (was invisible)
    h.expect(surface.BackgroundTransparency).toBe(1)                       -- fully transparent at rest
    b.Frame.MouseEnter:Fire()
    h.expect(surface.BackgroundTransparency).toBe(0.4)                     -- visible hover fill
    b.Frame.MouseLeave:Fire()
    h.expect(surface.BackgroundTransparency).toBe(1)                       -- back to invisible
  end)
  h.it("presses in on MouseButton1Down and springs back on MouseButton1Up", function()
    local b = Button.new({ Parent = Create("Frame", {}), Text = "Go" })
    -- the press UIScale lives on the inner Surface (not the laid-out Button) so siblings never reflow
    local sc = b.Frame:FindFirstChild("Surface"):FindFirstChildOfClass("UIScale")
    b.Frame.MouseButton1Down:Fire()
    h.expect(sc.Scale).toBe(0.97)
    b.Frame.MouseButton1Up:Fire()
    h.expect(sc.Scale).toBe(1)
  end)
end)

h.run()
