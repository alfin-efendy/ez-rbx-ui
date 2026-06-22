import { test } from 'node:test'
import assert from 'node:assert/strict'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { extractSourceInventory } from './check-skill.mjs'

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..')

test('extractSourceInventory finds all 17 control methods', () => {
  const { controls } = extractSourceInventory(repoRoot)
  assert.equal(controls.size, 17)
  for (const m of ['AddLabel', 'AddButton', 'AddToggle', 'AddSlider', 'AddSelectBox',
                   'AddNumberBox', 'AddColorPicker', 'AddCard', 'AddResizable']) {
    assert.ok(controls.has(m), `controls missing ${m}`)
  }
})

test('extractSourceInventory finds containers and entry points', () => {
  const { containers, entries, all } = extractSourceInventory(repoRoot)
  for (const m of ['AddTab', 'AddTabGroup', 'AddAccordion']) {
    assert.ok(containers.has(m), `containers missing ${m}`)
  }
  for (const m of ['CreateWindow', 'NewConfig']) {
    assert.ok(entries.has(m), `entries missing ${m}`)
  }
  // union has 17 + 3 + 2 = 22 distinct names
  assert.equal(all.size, 22)
})
