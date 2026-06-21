-- Require the BUILT bundle (run `make build` first / `make stress` does it).
-- The built bundle has no internal require() calls, so re-bundling it is safe;
-- requiring ../main directly would leave main's requires unrewritten (the bundler
-- only rewrites the entry file).
local EzUI = require("../output/bundle")

local window = EzUI:CreateWindow({
  Title = "EzUI Stress Test",
  Size = { Width = 600, Height = 440 },
  Acrylic = true,
})

for i = 1, 20 do
  local tab = window:AddTab({ Name = "Tab " .. i, Icon = "home" })
  tab:AddSection("Section " .. i)
  for j = 1, 10 do
    local acc = tab:AddAccordion({ Title = "Accordion " .. j, Icon = "settings-2", Expanded = (j == 1) })
    -- placeholder rows; real controls arrive in Plan 3
    for k = 1, 4 do
      local row = Instance.new("Frame")
      row.Size = UDim2.new(1, 0, 0, 28)
      row.BackgroundColor3 = EzUI.Theme.Colors.surface
      acc.MountRow(row)
    end
  end
end
