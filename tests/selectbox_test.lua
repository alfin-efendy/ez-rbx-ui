local h = require("tests.helper")
local R = h.loadLib()
local SelectBox, Create, Overlay, Config = R.SelectBox, R.Create, R.Overlay, R.Config

h.describe("selectbox", function()
  h.it("single select reflects default and SetValue persists", function()
    local cfg = Config.new({ FileName = "SB", AutoSave = false })
    local s = SelectBox.new({ Parent = Create("Frame", {}), Text = "Mode",
      Options = { "A", "B", "C" }, Default = "A", Flag = "mode", Config = cfg })
    h.expect(s.GetValue()).toBe("A")
    s.SetValue("C")
    h.expect(s.GetValue()).toBe("C")
    h.expect(cfg:Get("mode")).toBe("C")
  end)
  h.it("Open mounts the dropdown into the overlay (not clipped)", function()
    local gui = h.roblox.Instance.new("ScreenGui")
    Overlay.get(gui)
    local s = SelectBox.new({ Parent = Create("Frame", {}), Options = { "X", "Y" }, Default = "X" })
    s.Open()
    local root = Overlay.get(gui)
    local found = false
    for _, c in ipairs(root:GetChildren()) do if c.Name == "SelectDropdown" then found = true end end
    h.expect(found).toBeTruthy()
  end)
  h.it("multi select returns an array and toggles", function()
    local s = SelectBox.new({ Options = { "A", "B", "C" }, Multi = true, Default = { "A" } })
    h.expect(#s.GetValue()).toBe(1)
    s.SetValue({ "A", "C" })
    h.expect(#s.GetValue()).toBe(2)
  end)
end)

h.run()
