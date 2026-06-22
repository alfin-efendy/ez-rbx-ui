local h = require("tests.helper")
local R = h.loadLib()
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
end)
h.run()
