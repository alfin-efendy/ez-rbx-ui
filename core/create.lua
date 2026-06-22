-- Callable table: Create("Frame", {...}) builds an instance; Create.corner/padding/... are helpers.
local Create = {}

local function build(className, props)
  local inst = Instance.new(className)
  props = props or {}
  local parent
  for k, v in pairs(props) do
    if type(k) == "number" then
      v.Parent = inst                 -- child
    elseif k == "Parent" then
      parent = v                      -- defer
    else
      inst[k] = v
    end
  end
  if parent then inst.Parent = parent end
  return inst
end

setmetatable(Create, { __call = function(_, className, props) return build(className, props) end })

function Create.corner(radius)
  return Create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

function Create.padding(t)
  t = t or {}
  return Create("UIPadding", {
    PaddingTop = UDim.new(0, t.top or t.all or 0),
    PaddingBottom = UDim.new(0, t.bottom or t.all or 0),
    PaddingLeft = UDim.new(0, t.left or t.all or 0),
    PaddingRight = UDim.new(0, t.right or t.all or 0),
  })
end

function Create.listLayout(opts)
  opts = opts or {}
  return Create("UIListLayout", {
    Padding = UDim.new(0, opts.Padding or 0),
    FillDirection = opts.FillDirection or Enum.FillDirection.Vertical,
    SortOrder = opts.SortOrder or Enum.SortOrder.LayoutOrder,
  })
end

function Create.stroke(color, thickness)
  return Create("UIStroke", { Color = color, Thickness = thickness or 1 })
end

return Create
