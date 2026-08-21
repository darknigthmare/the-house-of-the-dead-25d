import { readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const indexPath = join(root, 'build', 'web', 'index.html');
const forbidden = 'width=device-width, user-scalable=no, initial-scale=1.0';
const accessible = 'width=device-width, initial-scale=1.0';
const plainCanvas = '<canvas id="canvas">';
const accessibleCanvas = '<canvas id="canvas" role="main" aria-label="The House of the Dead 2.5D game canvas">';
const html = readFileSync(indexPath, 'utf8');
let patched = html;

if (html.includes(forbidden)) {
  patched = html.replace(forbidden, accessible);
  console.log('Web viewport patched: browser zoom remains available.');
} else if (html.includes(accessible)) {
  console.log('Web viewport already allows browser zoom.');
} else {
  throw new Error('Unexpected viewport markup in build/web/index.html');
}
if (patched.includes(plainCanvas)) {
  patched = patched.replace(plainCanvas, accessibleCanvas);
  console.log('Web canvas patched: landmark and accessible name added.');
} else if (patched.includes(accessibleCanvas)) {
  console.log('Web canvas landmark already present.');
} else {
  throw new Error('Unexpected canvas markup in build/web/index.html');
}

writeFileSync(indexPath, `${patched.trimEnd()}\n`, 'utf8');
