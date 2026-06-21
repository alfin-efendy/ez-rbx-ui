local h = require("tests.helper")
local Overlay = h.loadLib().Overlay
Overlay.reset()

h.describe("overlay", function()
  h.it("creates one root and reuses it", function()
    local gui = h.roblox.Instance.new("ScreenGui")
    local r1 = Overlay.get(gui)
    local r2 = Overlay.get(gui)
    h.expect(r1).toBe(r2)
    h.expect(r1.ClipsDescendants).toBe(false)
  end)
  h.it("closeAll invokes tracked popover closers once", function()
    Overlay.reset()
    local gui = h.roblox.Instance.new("ScreenGui"); Overlay.get(gui)
    local closed = 0
    local fn = function() closed = closed + 1 end
    Overlay.trackPopover(fn)
    Overlay.closeAll()
    h.expect(closed).toBe(1)
    Overlay.closeAll() -- cleared, not called again
    h.expect(closed).toBe(1)
  end)
  h.it("mount parents element to overlay root", function()
    local gui = h.roblox.Instance.new("ScreenGui")
    local root = Overlay.get(gui)
    local popup = h.roblox.Instance.new("Frame")
    Overlay.mount(popup)
    h.expect(popup.Parent).toBe(root)
  end)
end)

h.run()
