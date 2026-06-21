local h = require("tests.helper")
local R = h.loadLib()
local Flag, Config = R.Flag, R.Config

h.describe("flag", function()
  h.it("initializes apply with default when unbound", function()
    local applied
    local commit = Flag.bind({}, 7, function(v) applied = v end)
    h.expect(applied).toBe(7)
    commit(9); h.expect(applied).toBe(9)
  end)
  h.it("registers, restores saved value, and persists on commit", function()
    local cfg = Config.new({ FileName = "F", AutoSave = false })
    cfg:Register("x", 1, function() end); cfg:Set("x", 42)
    local applied
    local commit = Flag.bind({ Config = cfg, Flag = "x" }, 1, function(v) applied = v end)
    h.expect(applied).toBe(42)        -- restored saved value
    commit(5)
    h.expect(cfg:Get("x")).toBe(5)    -- persisted
    h.expect(applied).toBe(5)
  end)
end)

h.run()
