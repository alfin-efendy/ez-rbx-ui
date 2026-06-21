-- Mixin: adds AddX control methods to any container (Tab/Accordion) via the registry R.
-- No Init (mixin only); Host.attach(api, ctx) wires the methods.
local Host = {}

local SIMPLE = {
  AddLabel = { mod = "Label" },
  AddParagraph = { mod = "Label", preset = { Variant = "paragraph" } },
  AddSection = { mod = "Label", preset = { Variant = "section" } },
  AddSeparator = { mod = "Separator" },
  AddButton = { mod = "Button" },
  AddToggle = { mod = "Toggle" },
  AddTextBox = { mod = "TextBox" },
  AddNumberBox = { mod = "NumberBox" },
  AddSelectBox = { mod = "SelectBox" },
}

-- ctx = { R, content, theme, config, window, nextOrder }
function Host.attach(api, ctx)
  for method, spec in pairs(SIMPLE) do
    api[method] = function(_, arg)
      local opts = {}
      if type(arg) == "string" then
        opts.Text = arg
      elseif type(arg) == "table" then
        for k, v in pairs(arg) do opts[k] = v end
      end
      if spec.preset then
        for k, v in pairs(spec.preset) do if opts[k] == nil then opts[k] = v end end
      end
      opts.Parent = ctx.content
      opts.LayoutOrder = ctx.nextOrder()
      opts.Theme = ctx.theme
      opts.Config = ctx.config
      opts.Window = ctx.window
      return ctx.R[spec.mod].new(opts)
    end
  end
end

return Host
