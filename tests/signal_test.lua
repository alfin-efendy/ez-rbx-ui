local h = require("tests.helper")
local Signal = h.requireModule("core.signal")

h.describe("signal", function()
  h.it("fires connected handlers with args", function()
    local s = Signal.new(); local got
    s:Connect(function(x) got = x end)
    s:Fire(42)
    h.expect(got).toBe(42)
  end)
  h.it("disconnect stops delivery", function()
    local s = Signal.new(); local n = 0
    local c = s:Connect(function() n = n + 1 end)
    s:Fire(); c:Disconnect(); s:Fire()
    h.expect(n).toBe(1)
  end)
  h.it("once fires a single time", function()
    local s = Signal.new(); local n = 0
    s:Once(function() n = n + 1 end)
    s:Fire(); s:Fire()
    h.expect(n).toBe(1)
  end)
end)

h.run()
