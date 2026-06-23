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

  h.it("guiName: random GUID at runtime", function()
    resetEnv()
    h.expect(Mount.guiName({}, false)).toBe("guid") -- mock HttpService:GenerateGUID returns "guid"
  end)

  h.it("guiName: readable EzUI in studio", function()
    resetEnv()
    h.expect(Mount.guiName({}, true)).toBe("EzUI")
  end)

  h.it("guiName: readable EzUI when Stealth=false", function()
    resetEnv()
    h.expect(Mount.guiName({ Stealth = false }, false)).toBe("EzUI")
  end)

  h.it("guiName: explicit GuiName wins", function()
    resetEnv()
    h.expect(Mount.guiName({ GuiName = "MyHub" }, true)).toBe("MyHub")
  end)

  h.it("anonName: random at runtime, readable label in Studio", function()
    resetEnv()
    h.expect(Mount.anonName("OverlayRoot")).toBe("guid") -- runtime → GUID (mock GenerateGUID)
    h.mock.isStudio = true
    h.expect(Mount.anonName("OverlayRoot")).toBe("OverlayRoot")
  end)

  h.it("finalize: marks the gui and dedupes prior EzUI roots only", function()
    resetEnv()
    local parent = h.roblox.Instance.new("Folder")
    local old = h.roblox.Instance.new("ScreenGui"); old.Parent = parent; old:SetAttribute("__ezui", true)
    local other = h.roblox.Instance.new("ScreenGui"); other.Parent = parent -- not an EzUI root
    local gui = h.roblox.Instance.new("ScreenGui"); gui.Parent = parent
    Mount.finalize(gui, {})
    h.expect(gui:GetAttribute("__ezui")).toBe(true)
    local present = {}
    for _, c in ipairs(parent:GetChildren()) do present[c] = true end
    h.expect(present[old]).toBeNil()  -- destroyed
    h.expect(present[other]).toBe(true)
    h.expect(present[gui]).toBe(true)
  end)

  h.it("finalize: applies protect outside studio, skips in studio", function()
    resetEnv()
    local p1 = h.roblox.Instance.new("Folder")
    local gui1 = h.roblox.Instance.new("ScreenGui"); gui1.Parent = p1
    local got1
    Mount.finalize(gui1, { protect = function(g) got1 = g end, studio = false })
    h.expect(got1).toBe(gui1)

    local p2 = h.roblox.Instance.new("Folder")
    local gui2 = h.roblox.Instance.new("ScreenGui"); gui2.Parent = p2
    local got2
    Mount.finalize(gui2, { protect = function(g) got2 = g end, studio = true })
    h.expect(got2).toBeNil()
  end)
end)

h.run()
