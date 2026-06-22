-- Bind a control's value to a Config flag: register default, restore saved value,
-- initialize the control, and return commit(v) which applies + persists.
local Flag = {}

function Flag.bind(opts, default, apply)
  opts = opts or {}
  local config, flag = opts.Config, opts.Flag
  local value = default
  if config and flag then
    config:Register(flag, default, apply)
    local saved = config:Get(flag)
    if saved ~= nil then value = saved end
  end
  apply(value)
  return function(v)
    apply(v)
    if config and flag then config:Set(flag, v) end
  end
end

return Flag
