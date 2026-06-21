local h = require("tests.helper")
local EzUI = h.requireModule("main")

h.describe("stress (headless integration)", function()
  h.it("builds 20 tabs x 10 accordions without error", function()
    local screen = h.roblox.Instance.new("ScreenGui")
    local w = EzUI:CreateWindow({ Title = "Stress", Parent = screen })
    local tabs = 0
    for i = 1, 20 do
      local tab = w:AddTab({ Name = "Tab " .. i, Icon = "home" })
      tabs = tabs + 1
      tab:AddSection("Group " .. i)
      for j = 1, 10 do
        local acc = tab:AddAccordion({ Title = "Acc " .. j })
        acc.MountRow(h.roblox.Instance.new("Frame"))
      end
    end
    h.expect(tabs).toBe(20)
    -- content scroll auto-sizes; only first tab visible
    h.expect(w.ContentScroll.AutomaticCanvasSize.Name).toBe("Y")
  end)
  h.it("switching tabs is constant work (one selected at a time)", function()
    local screen = h.roblox.Instance.new("ScreenGui")
    local w = EzUI:CreateWindow({ Title = "S", Parent = screen })
    local a = w:AddTab({ Name = "A" })
    local b = w:AddTab({ Name = "B" })
    b.Button.MouseButton1Click:Fire()
    h.expect(a:IsSelected()).toBe(false)
    h.expect(b:IsSelected()).toBe(true)
  end)
end)

h.run()
