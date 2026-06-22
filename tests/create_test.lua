local h = require("tests.helper")
local Create = h.requireModule("core.create")

h.describe("create", function()
  h.it("sets properties and parents children", function()
    local parent = h.roblox.Instance.new("ScreenGui")
    local frame = Create("Frame", {
      Name = "Root",
      BackgroundTransparency = 0.15,
      Parent = parent,
      Create("UICorner", { CornerRadius = h.roblox.UDim.new(0, 10) }),
      Create("TextLabel", { Name = "Title" }),
    })
    h.expect(frame.Name).toBe("Root")
    h.expect(frame.Parent).toBe(parent)
    h.expect(#frame:GetChildren()).toBe(2)
    h.expect(frame:FindFirstChild("Title").ClassName).toBe("TextLabel")
  end)
  h.it("corner helper builds UICorner", function()
    local c = Create.corner(8)
    h.expect(c.ClassName).toBe("UICorner")
    h.expect(c.CornerRadius.Offset).toBe(8)
  end)
  h.it("listLayout sets vertical padding", function()
    local l = Create.listLayout({ Padding = 8 })
    h.expect(l.ClassName).toBe("UIListLayout")
    h.expect(l.Padding.Offset).toBe(8)
  end)
end)

h.run()
