import { test } from 'node:test'
import assert from 'node:assert/strict'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { mkdtempSync, mkdirSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { extractSourceInventory, extractSkillInventory, diffInventories } from './check-skill.mjs'

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), '..')

test('extractSourceInventory finds all 17 control methods', () => {
  const { controls } = extractSourceInventory(repoRoot)
  assert.equal(controls.size, 17)
  const expectedControls = ['AddLabel', 'AddParagraph', 'AddSection', 'AddSeparator', 'AddButton',
                            'AddToggle', 'AddTextBox', 'AddNumberBox', 'AddSelectBox', 'AddSlider',
                            'AddKeybind', 'AddColorPicker', 'AddImage', 'AddTable', 'AddProgressBar',
                            'AddResizable', 'AddCard']
  for (const m of expectedControls) {
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

function makeSkill(controlsMd, windowMd) {
  const dir = mkdtempSync(join(tmpdir(), 'ezui-skill-'))
  mkdirSync(join(dir, 'reference'))
  writeFileSync(join(dir, 'reference', 'controls.md'), controlsMd)
  writeFileSync(join(dir, 'reference', 'window.md'), windowMd)
  return dir
}

test('diff is clean when the skill documents the full inventory', () => {
  const source = {
    all: new Set(['AddToggle', 'AddTab', 'CreateWindow']),
    controls: new Set(['AddToggle']),
    containers: new Set(['AddTab']),
  }
  const dir = makeSkill('## AddToggle\n', '## AddTab\n## CreateWindow\n')
  const d = diffInventories(source, extractSkillInventory(dir))
  assert.deepEqual(d, { missingInSkill: [], hallucinated: [], ok: true })
})

test('diff flags a control missing from the skill', () => {
  const source = {
    all: new Set(['AddToggle', 'AddSlider']),
    controls: new Set(['AddToggle', 'AddSlider']),
    containers: new Set(),
  }
  const dir = makeSkill('## AddToggle\n', '')
  const d = diffInventories(source, extractSkillInventory(dir))
  assert.deepEqual(d.missingInSkill, ['AddSlider'])
  assert.equal(d.ok, false)
})

test('diff flags a hallucinated control in controls.md', () => {
  const source = { all: new Set(['AddToggle']), controls: new Set(['AddToggle']), containers: new Set() }
  const dir = makeSkill('## AddToggle\n## AddDropdown\n', '')
  const d = diffInventories(source, extractSkillInventory(dir))
  assert.deepEqual(d.hallucinated, ['AddDropdown'])
  assert.equal(d.ok, false)
})

test('extractSkillInventory tolerates a missing reference file', () => {
  const dir = mkdtempSync(join(tmpdir(), 'ezui-empty-'))
  const skill = extractSkillInventory(dir) // no reference/ dir at all
  assert.equal(skill.documented.size, 0)
})

test('extractSkillInventory skips a single missing reference file', () => {
  const dir = mkdtempSync(join(tmpdir(), 'ezui-single-file-'))
  mkdirSync(join(dir, 'reference'))
  writeFileSync(join(dir, 'reference', 'controls.md'), '## AddToggle\n')
  // window.md is intentionally not created
  const skill = extractSkillInventory(dir)
  assert.doesNotThrow(() => extractSkillInventory(dir))
  assert.ok(skill.documented.has('AddToggle'), 'AddToggle should be in documented')
  assert.ok(skill.controlsMdAdds.has('AddToggle'), 'AddToggle should be in controlsMdAdds')
})
