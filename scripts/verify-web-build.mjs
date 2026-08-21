import { existsSync, readFileSync, statSync } from 'node:fs';
import { resolve, join } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const web = join(root, 'build', 'web');
const required = ['index.html', 'index.js', 'index.wasm', 'index.pck'];
const maxPckBytes = 100_000_000;
for (const file of required) {
  const path = join(web, file);
  if (!existsSync(path) || statSync(path).size === 0) throw new Error(`Missing or empty web export: ${file}`);
}
const pckBytes = statSync(join(web, 'index.pck')).size;
if (pckBytes >= maxPckBytes) {
  throw new Error(`Web export index.pck is ${pckBytes} bytes; it must remain below ${maxPckBytes} bytes.`);
}
const html = readFileSync(join(web, 'index.html'), 'utf8');
if (!html.includes('The House of the Dead 2.5D')) throw new Error('Web title marker missing');
if (html.includes('user-scalable=no')) throw new Error('Web viewport must keep browser zoom enabled');
console.log('Web export verified.');
