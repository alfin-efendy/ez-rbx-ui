local h = require("tests.helper")
local R = h.loadLib()
-- Returns (card, dim) for the most-recently-opened Dialog in the overlay, or (nil, nil).
local function dialogCard(R, gui)
  local root = R.Overlay.get(gui); local dim
  for _, c in ipairs(root:GetChildren()) do if c.Name == "Dialog" then dim = c end end
  return dim and dim:FindFirstChild("Card") or nil, dim
end
h.describe("dialog", function()
  h.it("opens into overlay and a button closes + fires callback", function()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    local picked
    R.Dialog.open({ Title = "Sure?", Message = "Confirm.", Buttons = {
      { Text = "Yes", Callback = function() picked = "yes" end },
      { Text = "No", Callback = function() picked = "no" end },
    } })
    local root = R.Overlay.get(gui)
    local card
    for _, c in ipairs(root:GetChildren()) do if c.Name == "Dialog" then card = c end end
    h.expect(card ~= nil).toBeTruthy()
    local row = card:FindFirstChild("Card"):FindFirstChild("Buttons")
    local firstBtn
    for _, c in ipairs(row:GetChildren()) do if c.ClassName == "TextButton" then firstBtn = c; break end end
    firstBtn.MouseButton1Click:Fire()
    h.expect(picked).toBe("yes")
    local stillOpen = false
    for _, c in ipairs(root:GetChildren()) do if c.Name == "Dialog" then stillOpen = true end end
    h.expect(stillOpen).toBe(false)
  end)
  h.it("Window:Dialog forwards to Dialog.open", function()
    local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    local w = R.Window.new({ Title = "W", Parent = gui })
    local handle = w:Dialog({ Title = "Hi", Buttons = { { Text = "OK" } } })
    h.expect(type(handle.Close)).toBe("function")
  end)
  h.it("uses opts.Width for the card width", function()
    local R = h.loadLib(); local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    R.Dialog.open({ Title = "W", Width = 480, Buttons = { { Text = "OK" } } })
    local card = dialogCard(R, gui)
    h.expect(card.Size.X.Offset).toBe(480)
  end)
  h.it("clamps the card width to the viewport when wider than available", function()
    local R = h.loadLib(); local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    R.Dialog.open({ Title = "W", Width = 5000, Buttons = { { Text = "OK" } } })
    local card = dialogCard(R, gui)
    h.expect(card.Size.X.Offset).toBe(1872)  -- viewport fallback 1920 - 2*24 margin
  end)
  h.it("renders an inline header icon left of the title", function()
    local R = h.loadLib(); local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    R.Dialog.open({ Title = "Delete", Icon = "trash-2", Buttons = { { Text = "OK" } } })
    local card = dialogCard(R, gui)
    local header = card:FindFirstChild("Header")
    h.expect(header ~= nil).toBeTruthy()
    h.expect(header:FindFirstChild("Icon") ~= nil).toBeTruthy()
    h.expect(header:FindFirstChild("Title").TextXAlignment.Name).toBe("Left")
    h.expect(header:FindFirstChild("IconBadge")).toBeNil()
  end)
  h.it("renders a centered icon badge and centers the message when IconBadge is set", function()
    local R = h.loadLib(); local gui = h.roblox.Instance.new("ScreenGui"); R.Overlay.get(gui)
    R.Dialog.open({ Title = "Delete", Icon = "trash-2", IconBadge = true, Message = "Gone forever.",
      Buttons = { { Text = "OK" } } })
    local card = dialogCard(R, gui)
    local header = card:FindFirstChild("Header")
    h.expect(header:FindFirstChild("IconBadge") ~= nil).toBeTruthy()
    h.expect(header:FindFirstChild("Title").TextXAlignment.Name).toBe("Center")
    h.expect(card:FindFirstChild("Message").TextXAlignment.Name).toBe("Center")
  end)
end)
h.run()
