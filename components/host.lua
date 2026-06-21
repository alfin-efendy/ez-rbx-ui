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
  AddSlider = { mod = "Slider" },
  AddKeybind = { mod = "Keybind" },
  AddColorPicker = { mod = "ColorPicker" },
  AddImage = { mod = "Image" },
  AddTable = { mod = "Table" },
  AddPlayerSelector = { mod = "PlayerSelector" },
  AddProgressBar = { mod = "ProgressBar" },
  AddResizable = { mod = "Resizable" },
  AddCard = { mod = "Card" },
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
      opts.AccentReg = ctx.accentThemer and ctx.accentThemer.register
      local control = ctx.R[spec.mod].new(opts)
      if opts.Tooltip and ctx.R.Tooltip and control and control.Frame then
        ctx.R.Tooltip.attach(control.Frame, opts.Tooltip, ctx.theme)
      end
      if ctx.registerSearchable and control and control.Frame then
        ctx.registerSearchable(control.Frame, opts.Text or opts.Title or opts.Name or "")
      end
      if control and control.Frame then
        local C = ctx.R.Create
        local scrim = C("Frame", { Name = "LockScrim", BackgroundColor3 = ctx.theme.Colors.background,
          BackgroundTransparency = 0.45, BorderSizePixel = 0, Visible = false, ZIndex = 50,
          Size = UDim2.new(1, 0, 1, 0), Parent = control.Frame, C.corner(ctx.theme.Radius.md) })
        local shield = C("ImageButton", { Name = "LockShield", AutoButtonColor = false, BackgroundTransparency = 1,
          Active = true, Visible = false, ZIndex = 51, Size = UDim2.new(1, 0, 1, 0), Parent = control.Frame })
        control.SetLocked = function(b) local v = b and true or false; scrim.Visible = v; shield.Visible = v end
        if opts.Locked then control.SetLocked(true) end
        if ctx.registerControl then ctx.registerControl(control) end
      end
      return control
    end
  end
end

return Host
