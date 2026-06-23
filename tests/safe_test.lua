local h = require("tests.helper")

h.describe("safe", function()
  local function fresh()
    local R = h.loadLib()
    R.Safe._setCapabilityCheck(nil)  -- default probe (mock has no protected root -> inline)
    return R.Safe
  end

  h.it("runs inline and returns the value when capability is present", function()
    local Safe = fresh()
    local ran = false
    local ret = Safe.mutate(function() ran = true; return 42 end)
    h.expect(ran).toBe(true)        -- synchronous, no Heartbeat needed
    h.expect(ret).toBe(42)
  end)

  h.it("defers to Heartbeat when capability is absent, preserving FIFO order", function()
    local Safe = fresh()
    Safe._setCapabilityCheck(function() return false end)
    local log = {}
    Safe.mutate(function() log[#log + 1] = "a" end)
    Safe.mutate(function() log[#log + 1] = "b" end)
    Safe.mutate(function() log[#log + 1] = "c" end)
    h.expect(#log).toBe(0)                 -- nothing ran yet
    h.mock.stepHeartbeat(0)                -- flush
    h.expect(table.concat(log)).toBe("abc")
    Safe._setCapabilityCheck(nil)
  end)

  h.it("drains fully: a second Heartbeat is a no-op", function()
    local Safe = fresh()
    Safe._setCapabilityCheck(function() return false end)
    local n = 0
    Safe.mutate(function() n = n + 1 end)
    h.mock.stepHeartbeat(0)
    h.mock.stepHeartbeat(0)               -- queue already drained
    h.expect(n).toBe(1)
    Safe._setCapabilityCheck(nil)
  end)

  h.it("default probe treats a throwing peek (protected read without capability) as no-capability, deferring not erroring", function()
    -- On a thread without the "Plugin" capability, the probe READS the protected overlay root
    -- (Overlay.peek -> root.Parent), which itself throws "lacking capability". The whole probe
    -- must swallow that and report "no capability" so Safe.mutate falls back to the Heartbeat --
    -- it must NOT let the throw escape (the original bug: peek() was called outside the pcall).
    local R = h.loadLib()
    R.Safe._setCapabilityCheck(nil)                    -- real default probe
    local realPeek = R.Overlay.peek
    R.Overlay.peek = function()
      error("The current thread cannot access 'Instance' (lacking capability Plugin)")
    end
    local ran = false
    local ok = pcall(function() R.Safe.mutate(function() ran = true end) end)
    R.Overlay.peek = realPeek                          -- restore shared singleton before asserting
    h.expect(ok).toBe(true)                            -- probe swallowed the throw; mutate did not error
    h.expect(ran).toBe(false)                          -- deferred, not run inline
    h.mock.stepHeartbeat(0)                            -- flush in a capability-bearing context
    h.expect(ran).toBe(true)
    R.Safe._setCapabilityCheck(nil)
  end)
end)

h.run()
