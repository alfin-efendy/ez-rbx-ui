local h = require("tests.helper")
local R = h.loadLib(); local Tbl, Create = R.Table, R.Create
h.describe("table", function()
  h.it("renders header + data rows; SetData rebuilds", function()
    local t = Tbl.new({ Parent = Create("Frame", {}), Columns = { "Name", "Score" },
      Rows = { { "A", "10" }, { "B", "20" } } })
    local rows0 = 0
    for _, c in ipairs(t.Body:GetChildren()) do if c.Name == "Row" then rows0 = rows0 + 1 end end
    h.expect(rows0).toBe(2)
    t.SetData({ { "C", "30" } })
    local rows = 0
    for _, c in ipairs(t.Body:GetChildren()) do if c.Name == "Row" then rows = rows + 1 end end
    h.expect(rows).toBe(1)
  end)
end)
h.run()
