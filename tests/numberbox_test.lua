local h = require("tests.helper")
local R = h.loadLib()
local NumberBox, Create, Config = R.NumberBox, R.Create, R.Config

h.describe("numberbox", function()
  h.it("clamps to range and persists", function()
    local cfg = Config.new({ FileName = "NB", AutoSave = false })
    local nb = NumberBox.new({ Parent = Create("Frame", {}), Text = "Vol", Default = 50, Min = 0, Max = 100, Flag = "vol", Config = cfg })
    h.expect(nb.GetValue()).toBe(50)
    nb.SetValue(150)
    h.expect(nb.GetValue()).toBe(100)   -- clamped to Max
    h.expect(cfg:Get("vol")).toBe(100)
    nb.SetValue(-5)
    h.expect(nb.GetValue()).toBe(0)     -- clamped to Min
  end)
end)

h.run()
