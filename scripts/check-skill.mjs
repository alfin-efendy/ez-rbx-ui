import { readFileSync, readdirSync, existsSync } from 'node:fs'
import { join } from 'node:path'

const CONTAINER_METHODS = ['AddTab', 'AddTabGroup', 'AddAccordion']

export function extractSourceInventory(repoRoot) {
  const componentsDir = join(repoRoot, 'components')

  // Guard: ensure components/ directory exists
  if (!existsSync(componentsDir)) {
    throw new Error(`components/ dir not found under ${repoRoot}`)
  }

  // 1) Control methods = keys of the SIMPLE table in host.lua
  const host = readFileSync(join(componentsDir, 'host.lua'), 'utf8')
  // Note: this assumes each SIMPLE table entry is on a single line (e.g. "AddButton = { mod = "Button" }").
  // Multi-line entry values would cause truncation at the first "\n}".
  const simple = host.match(/local SIMPLE = \{([\s\S]*?)\n\}/)
  if (!simple) throw new Error('SIMPLE table not found in components/host.lua')
  const controls = new Set([...simple[1].matchAll(/^\s*(Add\w+)\s*=/gm)].map((m) => m[1]))

  // 2) Container methods = AddTab/AddTabGroup/AddAccordion defined anywhere in components/
  const containers = new Set()
  for (const file of readdirSync(componentsDir).filter((f) => f.endsWith('.lua')).sort()) {
    const src = readFileSync(join(componentsDir, file), 'utf8')
    for (const m of src.matchAll(/function\s+\w+[:.](\w+)/g)) {
      if (CONTAINER_METHODS.includes(m[1])) containers.add(m[1])
    }
  }

  // 3) Entry points = EzUI:Method in main.lua
  const main = readFileSync(join(repoRoot, 'main.lua'), 'utf8')
  const entries = new Set([...main.matchAll(/function\s+EzUI:(\w+)/g)].map((m) => m[1]))

  const all = new Set([...controls, ...containers, ...entries])
  return { controls, containers, entries, all }
}

// METHOD_RE intentionally uses /g flag because it is consumed via line.matchAll(...),
// which resets lastIndex each call; do not switch to RegExp.exec in a loop.
const METHOD_RE = /\b(Add\w+|CreateWindow|NewConfig)\b/g

export function extractSkillInventory(skillDir) {
  const documented = new Set()
  const controlsMdAdds = new Set()
  for (const rel of ['reference/controls.md', 'reference/window.md']) {
    let text
    try {
      text = readFileSync(join(skillDir, rel), 'utf8')
    } catch (e) {
      if (e.code === 'ENOENT') continue
      throw e
    }
    for (const line of text.split('\n')) {
      if (!/^#{1,6}\s/.test(line)) continue
      for (const m of line.matchAll(METHOD_RE)) {
        documented.add(m[1])
        // controls.md Add* names only; CreateWindow/NewConfig (also matched by METHOD_RE) are excluded here
        if (rel.endsWith('controls.md') && m[1].startsWith('Add')) controlsMdAdds.add(m[1])
      }
    }
  }
  return { documented, controlsMdAdds }
}

export function diffInventories(source, skill) {
  const missingInSkill = [...source.all].filter((n) => !skill.documented.has(n)).sort()
  const allowed = new Set([...source.controls, ...source.containers])
  const hallucinated = [...skill.controlsMdAdds].filter((n) => !allowed.has(n)).sort()
  return { missingInSkill, hallucinated, ok: missingInSkill.length === 0 && hallucinated.length === 0 }
}
