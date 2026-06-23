local h = require("tests.helper")
local Asset = h.loadLib().Asset
h.describe("asset", function()
  h.it("passes through rbxasset content ids", function()
    h.expect(Asset.image("rbxassetid://42")).toBe("rbxassetid://42")
    h.expect(Asset.image("rbxthumb://type=Asset&id=1&w=150&h=150")).toBe("rbxthumb://type=Asset&id=1&w=150&h=150")
  end)
  h.it("coerces a bare numeric id", function()
    h.expect(Asset.image("99")).toBe("rbxassetid://99")
  end)
  h.it("returns nil for a URL when no executor globals exist, without erroring", function()
    h.expect(Asset.image("https://example.com/x.png")).toBe(nil)
  end)
  h.it("returns nil for nil / non-string", function()
    h.expect(Asset.image(nil)).toBe(nil)
    h.expect(Asset.image(123)).toBe(nil)
  end)
  h.it("imageAsync resolves instant ids via the callback (no fetch)", function()
    local got
    Asset.imageAsync("rbxassetid://7", function(v) got = v end)
    h.expect(got).toBe("rbxassetid://7")
    got = nil
    Asset.imageAsync("42", function(v) got = v end)
    h.expect(got).toBe("rbxassetid://42")
  end)
  h.it("imageAsync fetches a URL to a content id when the executor can", function()
    _G.getcustomasset = function(p) return "rbxasset://" .. p end
    h.roblox.game.HttpGet = function(_, _url) return "PNGBODY" end
    local got = "unset"
    Asset.imageAsync("https://example.com/async-ok.png", function(v) got = v end)
    _G.getcustomasset = nil
    h.roblox.game.HttpGet = function() return "" end
    h.expect(type(got)).toBe("string")
    h.expect(got:match("^rbxasset://") ~= nil).toBeTruthy()
  end)
  h.it("imageAsync never invokes the callback when nothing resolves", function()
    local calls = 0
    Asset.imageAsync("https://example.com/no-executor.png", function() calls = calls + 1 end)
    Asset.imageAsync(nil, function() calls = calls + 1 end)
    h.expect(calls).toBe(0)
  end)
  h.it("detects getcustomasset as an ENV global (not just raw _G) -- common executor sandbox", function()
    -- Executor injects its API into the script environment (bare global), NOT the raw _G table.
    h.roblox.getcustomasset = function(p) return "rbxasset://" .. p end
    h.roblox.game.HttpGet = function(_, _u) return "PNGBODY" end
    local resolvable = Asset.resolvable("https://example.com/env-global.png")
    local got = "unset"
    Asset.imageAsync("https://example.com/env-global.png", function(v) got = v end)
    h.roblox.getcustomasset = nil
    h.roblox.game.HttpGet = function() return "" end
    h.expect(resolvable).toBe(true)
    h.expect(type(got)).toBe("string")
    h.expect(got:match("^rbxasset://") ~= nil).toBeTruthy()
  end)
  h.it("resolvable: true for ids, false for a URL without executor globals", function()
    h.expect(Asset.resolvable("rbxassetid://1")).toBe(true)
    h.expect(Asset.resolvable("99")).toBe(true)
    h.expect(Asset.resolvable("https://example.com/x.png")).toBe(false)
    h.expect(Asset.resolvable(nil)).toBe(false)
  end)
end)
h.run()
