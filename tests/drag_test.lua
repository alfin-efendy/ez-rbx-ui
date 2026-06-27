local h = require("tests.helper")
local R = h.loadLib()
local Drag = R.Drag
local UIT = h.roblox.Enum.UserInputType

local function btn() return h.roblox.Instance.new("ImageButton") end
local function uis() return h.roblox.game:GetService("UserInputService") end

h.describe("drag helper", function()
  h.it("mouse: MouseButton1 begin + MouseMovement reports the delta", function()
    local b, maid = btn(), R.Maid.new()
    local dx, dy, pos
    Drag.bind(b, { onChange = function(a, c, p) dx, dy, pos = a, c, p end }, maid)
    b.InputBegan:Fire({ UserInputType = UIT.MouseButton1, Position = h.roblox.Vector2.new(100, 100) })
    uis().InputChanged:Fire({ UserInputType = UIT.MouseMovement, Position = h.roblox.Vector2.new(140, 120) })
    h.expect(dx).toBe(40); h.expect(dy).toBe(20)
    h.expect(pos.X).toBe(140); h.expect(pos.Y).toBe(120)
    maid:DoCleanup()
  end)
  h.it("touch: only the originating finger drives the drag", function()
    local b, maid = btn(), R.Maid.new()
    local calls, lastdx = 0, nil
    Drag.bind(b, { onChange = function(a) calls = calls + 1; lastdx = a end }, maid)
    local touch = { UserInputType = UIT.Touch, Position = h.roblox.Vector2.new(0, 0) }
    local other = { UserInputType = UIT.Touch, Position = h.roblox.Vector2.new(999, 999) }
    b.InputBegan:Fire(touch)
    uis().InputChanged:Fire(other)               -- a different finger -> ignored
    h.expect(calls).toBe(0)
    touch.Position = h.roblox.Vector2.new(30, 0)
    uis().InputChanged:Fire(touch)               -- the originating finger -> counted
    h.expect(calls).toBe(1); h.expect(lastdx).toBe(30)
    maid:DoCleanup()
  end)
  h.it("onEnd fires and stops further onChange", function()
    local b, maid = btn(), R.Maid.new()
    local ended, changes = false, 0
    Drag.bind(b, { onChange = function() changes = changes + 1 end, onEnd = function() ended = true end }, maid)
    b.InputBegan:Fire({ UserInputType = UIT.MouseButton1, Position = h.roblox.Vector2.new(0, 0) })
    uis().InputEnded:Fire({ UserInputType = UIT.MouseButton1, Position = h.roblox.Vector2.new(0, 0) })
    h.expect(ended).toBe(true)
    uis().InputChanged:Fire({ UserInputType = UIT.MouseMovement, Position = h.roblox.Vector2.new(50, 50) })
    h.expect(changes).toBe(0)
    maid:DoCleanup()
  end)
  h.it("touch: a different finger's InputEnded does not end the active drag", function()
    local b, maid = btn(), R.Maid.new()
    local changes, ended = 0, false
    Drag.bind(b, { onChange = function() changes = changes + 1 end, onEnd = function() ended = true end }, maid)
    local touch = { UserInputType = UIT.Touch, Position = h.roblox.Vector2.new(0, 0) }
    local other = { UserInputType = UIT.Touch, Position = h.roblox.Vector2.new(5, 5) }
    b.InputBegan:Fire(touch)
    uis().InputEnded:Fire(other)                 -- a different finger lifts -> must NOT end our drag
    h.expect(ended).toBe(false)
    touch.Position = h.roblox.Vector2.new(20, 0)
    uis().InputChanged:Fire(touch)               -- originating finger still drives the drag
    h.expect(changes).toBe(1)
    uis().InputEnded:Fire(touch)                 -- originating finger lifts -> ends
    h.expect(ended).toBe(true)
    maid:DoCleanup()
  end)
end)

h.run()
