import { existsSync, readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { extname, join, relative, resolve, sep } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const checkOnly = process.argv.includes('--check');

const families = [
  {
    root: join(root, 'assets', 'sprites_v2'),
    select: () => ({ mode: 1, quality: 0.82, mipmaps: false, normalMap: 0 }),
  },
  {
    root: join(root, 'assets', 'environments_v2'),
    select: (path) => {
      const normalized = path.replaceAll(sep, '/');
      if (normalized.includes('/materials/') && normalized.endsWith('_orm.png.import')) {
        return { mode: 0, quality: 0.7, mipmaps: true, normalMap: 0 };
      }
      if (normalized.includes('/materials/') && normalized.endsWith('_normal.png.import')) {
        return { mode: 1, quality: 0.85, mipmaps: true, normalMap: 1 };
      }
      return { mode: 1, quality: 0.8, mipmaps: true, normalMap: 0 };
    },
  },
];

function walk(directory) {
  const paths = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) paths.push(...walk(path));
    else if (entry.isFile() && extname(entry.name) === '.import' && entry.name.endsWith('.png.import')) paths.push(path);
  }
  return paths;
}

function replaceParam(source, key, value) {
  const expression = new RegExp(`^${key.replace('/', '\\/')}=.*$`, 'm');
  if (!expression.test(source)) throw new Error(`Missing Godot import parameter ${key}`);
  return source.replace(expression, `${key}=${value}`);
}

let checked = 0;
let changed = 0;
const mismatches = [];

for (const family of families) {
  if (!existsSync(family.root)) throw new Error(`Missing texture family: ${relative(root, family.root)}`);
  for (const path of walk(family.root)) {
    const profile = family.select(path);
    const original = readFileSync(path, 'utf8');
    let optimized = original;
    optimized = replaceParam(optimized, 'compress/mode', profile.mode);
    optimized = replaceParam(optimized, 'compress/lossy_quality', profile.quality);
    optimized = replaceParam(optimized, 'mipmaps/generate', profile.mipmaps);
    optimized = replaceParam(optimized, 'process/normal_map_invert_y', false);
    optimized = replaceParam(optimized, 'compress/normal_map', profile.normalMap);
    checked += 1;
    if (optimized !== original) {
      changed += 1;
      if (checkOnly) mismatches.push(relative(root, path).replaceAll(sep, '/'));
      else writeFileSync(path, optimized, 'utf8');
    }
  }
}

if (checkOnly && mismatches.length > 0) {
  throw new Error(`Texture import profile mismatch (${mismatches.length}):\n${mismatches.join('\n')}`);
}

console.log(`TEXTURE IMPORT PROFILE ${checkOnly ? 'VERIFIED' : 'APPLIED'}: ${checked} files, ${changed} ${checkOnly ? 'mismatches' : 'updated'}.`);
