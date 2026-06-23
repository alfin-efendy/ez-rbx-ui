-- Deps injected via Init(R).
local Table = {}
local Create, DefaultTheme, Maid, Safe
function Table.Init(R) Create = R.Create; DefaultTheme = R.Theme; Maid = R.Maid; Safe = R.Safe end

function Table.new(opts)
  opts = opts or {}
  local theme = opts.Theme or DefaultTheme
  local maid = Maid.new()
  local cols = opts.Columns or {}

  local root = Create("Frame", { Name = "Table", BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, (opts.Height or 120) + 26), LayoutOrder = opts.LayoutOrder or 0, Parent = opts.Parent })

  local function makeRow(parent, cells, header, order)
    local row = Create("Frame", { Name = header and "Header" or "Row",
      BackgroundColor3 = theme.Colors.surface, BackgroundTransparency = header and 1 or 0,
      Size = UDim2.new(1, 0, 0, 24), LayoutOrder = order or 0, Parent = parent,
      Create.corner(header and 0 or theme.Radius.sm),
      Create.listLayout({ Padding = 4, FillDirection = Enum.FillDirection.Horizontal }) })
    for i, text in ipairs(cells) do
      local cell = Create("TextLabel", { Name = "Cell", BackgroundTransparency = 1, Text = tostring(text),
        TextColor3 = header and theme.Colors.mutedForeground or theme.Colors.foreground,
        TextXAlignment = Enum.TextXAlignment.Left, TextSize = theme.Font.muted.Size, Font = Enum.Font.BuilderSans,
        Size = UDim2.new(0, 0, 1, 0), LayoutOrder = i, Parent = row })
      Create("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = cell })
    end
    return row
  end

  makeRow(root, cols, true, 0)
  local body = Create("ScrollingFrame", { Name = "Body", BackgroundColor3 = theme.Colors.surface,
    BackgroundTransparency = 0.5, BorderSizePixel = 0,
    ScrollBarThickness = 3, Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(1, 0, 1, -26),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), Parent = root,
    Create.corner(theme.Radius.sm), Create.padding({ all = 4 }), Create.listLayout({ Padding = 2 }) })

  local order = 0
  local api = { Frame = root, Body = body }
  function api.AddRow(cells)
    order = order + 1
    local o = order
    local row
    Safe.mutate(function() row = makeRow(body, cells, false, o) end)
    return row
  end
  function api.Clear()
    order = 0
    Safe.mutate(function()
      for _, c in ipairs(body:GetChildren()) do if c.Name == "Row" then c:Destroy() end end
    end)
  end
  function api.SetData(rows) api.Clear(); for _, r in ipairs(rows or {}) do api.AddRow(r) end end
  function api.Destroy() maid:DoCleanup(); root:Destroy() end

  api.SetData(opts.Rows)
  maid:Give(root)

  if opts.AccentReg then maid:Give(opts.AccentReg(function()
    body.BackgroundColor3 = theme.Colors.surface
    local header = root:FindFirstChild("Header")
    if header then for _, c in ipairs(header:GetChildren()) do if c.Name == "Cell" then c.TextColor3 = theme.Colors.mutedForeground end end end
    for _, row in ipairs(body:GetChildren()) do
      if row.Name == "Row" then
        row.BackgroundColor3 = theme.Colors.surface
        for _, c in ipairs(row:GetChildren()) do if c.Name == "Cell" then c.TextColor3 = theme.Colors.foreground end end
      end
    end
  end)) end

  return api
end

return Table
