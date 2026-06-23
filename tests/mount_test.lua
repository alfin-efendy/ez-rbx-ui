local h = require("tests.helper")
local Mount = h.requireModule("core/mount")
Mount.Init({})

local function resetEnv()
  h.roblox.gethui = nil
  h.roblox.protectgui = nil
  h.roblox.syn = nil
  h.roblox.cloneref = nil
  h.mock.isStudio = false
  h.mock.hidden = nil
end

h.describe("mount", function()
  h.it("service: applies cloneref when available, identity fallback otherwise", function()
    resetEnv()
    local seen = {}
    h.roblox.cloneref = function(o) seen[#seen + 1] = o; return o end
    h.expect(Mount.service("CoreGui")).toBe(h.mock.coreGui)
    h.expect(#seen >= 1).toBeTruthy()
    resetEnv()
    h.expect(Mount.service("CoreGui")).toBe(h.mock.coreGui) -- no cloneref -> identity
  end)

  h.it("tier 1: gethui() wins when present", function()
    resetEnv()
    local container = h.roblox.Instance.new("Folder")
    h.roblox.gethui = function() return container end
    local ctx = Mount.resolve({})
    h.expect(ctx.parent).toBe(container)
    h.expect(ctx.protect).toBeNil()
  end)

  h.it("tier 2: protect + CoreGui when gethui absent", function()
    resetEnv()
    h.roblox.protectgui = function() end
    local ctx = Mount.resolve({})
    h.expect(ctx.parent).toBe(h.mock.coreGui)
    h.expect(type(ctx.protect)).toBe("function")
  end)

  h.it("tier 3: bare CoreGui when no gethui/protect", function()
    resetEnv()
    local ctx = Mount.resolve({})
    h.expect(ctx.parent).toBe(h.mock.coreGui)
    h.expect(ctx.protect).toBeNil()
  end)

  h.it("tier 4: PlayerGui when gethui/protect/CoreGui unavailable", function()
    resetEnv()
    h.mock.hidden = { CoreGui = true }
    local ctx = Mount.resolve({})
    h.expect(ctx.parent).toBe(h.mock.playerGui)
  end)

  h.it("explicit Parent bypasses the chain", function()
    resetEnv()
    local p = h.roblox.Instance.new("ScreenGui")
    local ctx = Mount.resolve({ Parent = p })
    h.expect(ctx.parent).toBe(p)
  end)

  h.it("studio flag reflects RunService:IsStudio()", function()
    resetEnv()
    h.mock.isStudio = true
    local ctx = Mount.resolve({})
    h.expect(ctx.studio).toBe(true)
  end)
end)

h.run()
