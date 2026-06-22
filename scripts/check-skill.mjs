import { readFileSync, readdirSync } from 'node:fs'
import { join } from 'node:path'

const CONTAINER_METHODS = ['AddTab', 'AddTabGroup', 'AddAccordion']

export function extractSourceInventory(repoRoot) {
  const componentsDir = join(repoRoot, 'components')

  // 1) Control methods = keys of the SIMPLE table in host.lua
  const host = readFileSync(join(componentsDir, 'host.lua'), 'utf8')
  const simple = host.match(/local SIMPLE = \{([\s\S]*?)\n\}/)
  if (!simple) throw new Error('SIMPLE table not found in components/host.lua')
  const controls = new Set([...simple[1].matchAll(/^\s*(Add\w+)\s*=/gm)].map((m) => m[1]))

  // 2) Container methods = AddTab/AddTabGroup/AddAccordion defined anywhere in components/
  const containers = new Set()
  for (const file of readdirSync(componentsDir).filter((f) => f.endsWith('.lua'))) {
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
