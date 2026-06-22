local h = require("tests.helper")
local R = h.loadLib(); local ColorPicker, Create, Overlay, Config = R.ColorPicker, R.Create, R.Overlay, R.Config
h.describe("colorpicker", function()
  h.it("SetColor/GetColor round-trip and persist as rgb array", function()
    local cfg = Config.new({ FileName = "CP", AutoSave = false })
    local cp = ColorPicker.new({ Parent = Create("Frame", {}), Text = "ESP", Default = h.roblox.Color3.fromRGB(255,0,0), Flag = "esp", Config = cfg })
    h.expect(cp.GetColor().R8).toBe(255)
    cp.SetColor(h.roblox.Color3.fromRGB(0,128,255))
    h.expect(cp.GetColor().B8).toBe(255)
    local saved = cfg:Get("esp")
    h.expect(saved[1]).toBe(0)    -- r
    h.expect(saved[3]).toBe(255)  -- b
  end)
  h.it("Open mounts a picker popover into the overlay", function()
    local gui = h.roblox.Instance.new("ScreenGui"); Overlay.get(gui)
    local cp = ColorPicker.new({ Parent = Create("Frame", {}), Default = h.roblox.Color3.fromRGB(255,255,255) })
    cp.Open()
    local root = Overlay.get(gui); local found = false
    for _, c in ipairs(root:GetChildren()) do if c.Name == "ColorPopover" then found = true end end
    h.expect(found).toBeTruthy()
  end)
  h.it("scrolling the control closes the color popover", function()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.reset(); R.Overlay.get(gui)
    local cp = ColorPicker.new({ Parent = Create("Frame", {}), Default = h.roblox.Color3.fromRGB(255,255,255) })
    cp.Open()
    local function open()
      for _, c in ipairs(R.Overlay.get(gui):GetChildren()) do if c.Name == "ColorPopover" then return true end end
      return false
    end
    h.expect(open()).toBe(true)
    cp.Frame.AbsolutePosition = h.roblox.Vector2.new(10, 10)
    cp.Frame:GetPropertyChangedSignal("AbsolutePosition"):Fire()
    h.expect(open()).toBe(false)
  end)
end)
h.run()
