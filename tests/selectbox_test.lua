local h = require("tests.helper")
local R = h.loadLib()
local SelectBox, Create, Overlay, Config = R.SelectBox, R.Create, R.Overlay, R.Config

h.describe("selectbox", function()
  h.it("single select reflects default and SetValue persists", function()
    local cfg = Config.new({ FileName = "SB", AutoSave = false })
    local s = SelectBox.new({ Parent = Create("Frame", {}), Text = "Mode",
      Options = { "A", "B", "C" }, Default = "A", Flag = "mode", Config = cfg })
    h.expect(s.GetValue()).toBe("A")
    s.SetValue("C")
    h.expect(s.GetValue()).toBe("C")
    h.expect(cfg:Get("mode")).toBe("C")
  end)
  h.it("Open mounts the dropdown into the overlay (not clipped)", function()
    local gui = h.roblox.Instance.new("ScreenGui")
    Overlay.get(gui)
    local s = SelectBox.new({ Parent = Create("Frame", {}), Options = { "X", "Y" }, Default = "X" })
    s.Open()
    local root = Overlay.get(gui)
    local found = false
    for _, c in ipairs(root:GetChildren()) do if c.Name == "SelectDropdown" then found = true end end
    h.expect(found).toBeTruthy()
  end)
  h.it("clicking the overlay catcher (outside) closes the dropdown", function()
    R.Overlay.reset()
    local gui = h.roblox.Instance.new("ScreenGui")
    Overlay.get(gui)
    local sb = SelectBox.new({ Parent = Create("Frame", {}), Options = { "X", "Y" }, Default = "X" })
    sb.Open()
    local root = Overlay.get(gui)
    local catcher; for _, c in ipairs(root:GetChildren()) do if c.Name == "EzUI_OverlayCatcher" then catcher = c end end
    h.expect(catcher ~= nil).toBeTruthy()
    catcher.MouseButton1Click:Fire()
    local stillOpen = false
    for _, c in ipairs(root:GetChildren()) do if c.Name == "SelectDropdown" then stillOpen = true end end
    h.expect(stillOpen).toBe(false)
  end)
  h.it("dropdown has a search box that filters options", function()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    local s = SelectBox.new({ Parent = Create("Frame", {}), Options = { "Alpha", "Beta", "Gamma" }, Default = "Alpha" })
    s.Open()
    local dd; for _, c in ipairs(R.Overlay.get(gui):GetChildren()) do if c.Name == "SelectDropdown" then dd = c end end
    h.expect(dd:FindFirstChild("Search") ~= nil).toBeTruthy()
    s.Filter("be")
    local function optVisible(text)
      for _, o in ipairs(dd:GetChildren()) do
        if o.Name == "Opt" then
          for _, l in ipairs(o:GetChildren()) do
            if l.ClassName == "TextLabel" and l.Text == text then return o.Visible end
          end
        end
      end
    end
    h.expect(optVisible("Beta")).toBe(true)
    h.expect(optVisible("Alpha")).toBe(false)
  end)
  h.it("multi select returns an array and toggles", function()
    local s = SelectBox.new({ Options = { "A", "B", "C" }, Multi = true, Default = { "A" } })
    h.expect(#s.GetValue()).toBe(1)
    s.SetValue({ "A", "C" })
    h.expect(#s.GetValue()).toBe(2)
  end)
  h.it("renders opts.Text as a Title (and omits it when absent)", function()
    local s = SelectBox.new({ Parent = Create("Frame", {}), Text = "Mode", Options = { "A", "B" }, Default = "A" })
    local ti = s.Frame:FindFirstChild("Title")
    h.expect(ti ~= nil).toBeTruthy()
    h.expect(ti.Text).toBe("Mode")
    local s2 = SelectBox.new({ Parent = Create("Frame", {}), Options = { "A" } })
    h.expect(s2.Frame:FindFirstChild("Title")).toBe(nil)
  end)
  h.it("selected option uses a surface highlight + foreground text (not accent)", function()
    local ov = Overlay.get(h.roblox.Instance.new("ScreenGui"))
    local sb = SelectBox.new({ Parent = Create("Frame", {}), Options = { "A", "B" }, Default = "A" })
    sb.Open()
    local dd; for _, c in ipairs(ov:GetChildren()) do if c.Name == "SelectDropdown" then dd = c end end
    local optA; for _, c in ipairs(dd:GetChildren()) do if c.Name == "Opt" and c:GetAttribute("OptValue") == "A" then optA = c end end
    h.expect(optA.BackgroundTransparency).toBe(0)
    h.expect(optA.BackgroundColor3).toBe(R.Theme.Colors.surface)
    h.expect(optA:FindFirstChild("OptLabel").TextColor3).toBe(R.Theme.Colors.foreground)
  end)
  h.it("per-item options without Default show the first value, not a table address", function()
    local sb = SelectBox.new({ Parent = Create("Frame", {}),
      Options = { { Value = "Bow", Icon = "target", Desc = "Ranged" }, { Value = "Shield" } } })
    h.expect(sb.GetValue()).toBe("Bow")
    local field = sb.Frame:FindFirstChild("Field")
    h.expect(field:FindFirstChild("Value").Text).toBe("Bow")
  end)
  h.it("multi shows truncated 'A, B +N' with a clear button", function()
    local sb = SelectBox.new({ Parent = Create("Frame", {}), Options = { "A", "B", "C", "D" },
      Multi = true, Default = { "A", "B", "C", "D" } })
    local field = sb.Frame:FindFirstChild("Field")
    h.expect(field:FindFirstChild("Value").Text).toBe("A, B +2")
    local clear = field:FindFirstChild("Clear")
    h.expect(clear.Visible).toBe(true)
    clear.MouseButton1Click:Fire()
    h.expect(#sb.GetValue()).toBe(0)
    h.expect(field:FindFirstChild("Value").Text).toBe("None")
    h.expect(clear.Visible).toBe(false)
  end)
  h.it("single per-item shows the selected option icon in the field", function()
    local sb = SelectBox.new({ Parent = Create("Frame", {}),
      Options = { { Value = "Bow", Icon = "target" }, { Value = "Shield", Icon = "shield" } } })
    h.expect(sb.Frame:FindFirstChild("Field"):FindFirstChild("FieldIcon").Visible).toBe(true)
  end)
  h.it("SetOptions drops values no longer present", function()
    local sb = SelectBox.new({ Parent = Create("Frame", {}), Options = { "A", "B", "C" }, Default = "A" })
    sb.SetOptions({ "X", "Y", "Z" })
    h.expect(sb.GetValue()).toBe("X")
    local m = SelectBox.new({ Options = { "A", "B", "C" }, Multi = true, Default = { "A", "B" } })
    m.SetOptions({ "B", "D" })
    h.expect(#m.GetValue()).toBe(1)
    h.expect(m.GetValue()[1]).toBe("B")
  end)
  h.it("renders per-item icon/desc and a divider, and AllowNone deselects", function()
    local ov = Overlay.get(h.roblox.Instance.new("ScreenGui"))
    local sb = SelectBox.new({ Parent = Create("Frame", {}),
      Options = { { Value = "A", Icon = "star", Desc = "alpha" }, { Divider = true }, { Value = "B" } },
      Default = "A", AllowNone = true })
    sb.Open()
    local dd; for _, c in ipairs(ov:GetChildren()) do if c.Name == "SelectDropdown" then dd = c end end
    local hasLead, hasDivider, optA = false, false, nil
    for _, c in ipairs(dd:GetChildren()) do
      if c.Name == "Opt" and c:FindFirstChild("Lead") then hasLead = true end
      if c.Name == "Divider" then hasDivider = true end
      if c.Name == "Opt" and c:GetAttribute("OptValue") == "A" then optA = c end
    end
    h.expect(hasLead).toBe(true)
    h.expect(hasDivider).toBe(true)
    optA.MouseButton1Click:Fire() -- A is selected + AllowNone => deselect
    h.expect(sb.GetValue()).toBe(nil)
  end)
end)

h.run()
