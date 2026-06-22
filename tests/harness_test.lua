local h = require("tests.helper")

h.describe("harness", function()
  h.it("creates and parents instances", function()
    local Instance = h.roblox.Instance
    local parent = Instance.new("Frame")
    local child = Instance.new("TextLabel")
    child.Parent = parent
    h.expect(#parent:GetChildren()).toBe(1)
    h.expect(parent:GetChildren()[1]).toBe(child)
  end)

  h.it("Color3.fromRGB stores channels", function()
    local c = h.roblox.Color3.fromRGB(9, 9, 11)
    h.expect(c.R8).toBe(9)
    h.expect(c.B8).toBe(11)
  end)

  h.it("expect.toThrow catches errors", function()
    h.expect(function() error("boom") end).toThrow("boom")
  end)

  h.it("mocked file fns round-trip", function()
    h.roblox.writefile("a/b.json", "hi")
    h.expect(h.roblox.isfile("a/b.json")).toBeTruthy()
    h.expect(h.roblox.readfile("a/b.json")).toBe("hi")
  end)
end)

h.run()
