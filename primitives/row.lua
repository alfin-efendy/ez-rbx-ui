-- Deps injected via Init(R).
local Row = {}
local Create, Theme, Animate, Maid

function Row.Init(R)
  Create = R.Create; Theme = R.Theme; Animate = R.Animate; Maid = R.Maid
end

function Row.new(opts)
  opts = opts or {}
  local maid = Maid.new()

  local frame = Create("Frame", {
    Name = "Row",
    BackgroundColor3 = Theme.Colors.surface,
    BackgroundTransparency = 0.0,
    BorderSizePixel = 0,
    LayoutOrder = opts.LayoutOrder or 0,
    AutomaticSize = opts.Height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
    Size = opts.Height and UDim2.new(1, 0, 0, opts.Height) or UDim2.new(1, 0, 0, 0),
    Parent = opts.Parent,
    Create.corner(Theme.Radius.md),
    Create.padding({ left = Theme.Spacing.inputX, right = Theme.Spacing.inputX, top = Theme.Spacing.inputY, bottom = Theme.Spacing.inputY }),
  })

  local content = Create("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = frame,
  })

  local api = { Frame = frame, Content = content, Maid = maid }

  function api.SetHovered(hovered)
    -- hover lightens the surface row; finalized visually during make run
    Animate.to(frame, "fast", { BackgroundTransparency = hovered and 0.0 or 0.0 })
  end

  function api.Destroy()
    maid:DoCleanup()
    frame:Destroy()
  end

  maid:Give(frame)
  return api
end

return Row
