local h = require("tests.helper")
local R = h.loadLib()
local Toggle, Create, Config = R.Toggle, R.Create, R.Config

h.describe("toggle", function()
  h.it("reflects default and toggles on click", function()
    local p = Create("Frame", {})
    local changed
    local t = Toggle.new({ Parent = p, Text = "Auto", Default = false, Callback = function(v) changed = v end })
    h.expect(t.Get()).toBe(false)
    t.Frame.MouseButton1Click:Fire()
    h.expect(t.Get()).toBe(true)
    h.expect(changed).toBe(true)
  end)
  h.it("uses shadcn switch proportions and supports a description", function()
    local t = Toggle.new({ Parent = Create("Frame", {}), Text = "Share",
      Description = "Focus is shared across devices." })
    local track = t.Frame:FindFirstChild("Track")
    h.expect(track.Size.X.Offset).toBe(44)
    h.expect(track.Size.Y.Offset).toBe(24)
    h.expect(t.Frame.Size.Y.Offset).toBe(50)
    h.expect(t.Frame:FindFirstChild("Description") ~= nil).toBeTruthy()
  end)
  h.it("persists to config flag and restores", function()
    local cfg = Config.new({ FileName = "TG", AutoSave = false })
    local t = Toggle.new({ Text = "X", Default = false, Flag = "x", Config = cfg })
    t.Set(true)
    h.expect(cfg:Get("x")).toBe(true)
    local t2 = Toggle.new({ Text = "X", Default = false, Flag = "x", Config = cfg })
    h.expect(t2.Get()).toBe(true)  -- restored
  end)
end)

h.run()
