import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { inflateSync } from 'node:zlib';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const readJson = (path) => JSON.parse(readFileSync(resolve(root, path), 'utf8'));
const ensure = (condition, message) => { if (!condition) throw new Error(message); };
const initial = readJson('docs/dossier_curien/CATALOGUE_VISUEL.json');
const saga = readJson('docs/dossier_curien/saga/CATALOGUE_VISUEL_SAGA.json');
const additions = readJson('data/assets/dossier_curien_additions.json');
const catalog = [
  ...initial.assets.map((x) => ({ path: 'assets/dossier_curien/' + x.file, dimensions: x.size_px, sha256: x.sha256 })),
  ...saga.fichiers.map((x) => ({ path: 'assets/dossier_curien/saga/' + x.fichier, dimensions: x.dimensions, sha256: x.sha256 })),
];
ensure(saga.nombre_de_png === saga.fichiers.length, 'Saga catalogue count differs from its entries');
ensure(new Set(catalog.map((x) => x.path)).size === catalog.length, 'Duplicate catalogue path');
const checked = new Map();
for (const entry of catalog) {
  const data = readFileSync(resolve(root, entry.path));
  ensure(data.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10])), 'Invalid PNG: ' + entry.path);
  ensure(data.readUInt32BE(16) === entry.dimensions[0] && data.readUInt32BE(20) === entry.dimensions[1], 'Wrong dimensions: ' + entry.path);
  ensure(createHash('sha256').update(data).digest('hex') === entry.sha256, 'SHA-256 mismatch: ' + entry.path);
  checked.set(entry.path, { entry, data });
}

function alphaMetrics(data, asset) {
  const width = data.readUInt32BE(16), height = data.readUInt32BE(20);
  ensure(data[24] === 8 && data[25] === 6 && data[28] === 0, 'Expected non-interlaced 8-bit RGBA PNG');
  const idat = [];
  let sawEnd = false;
  for (let at = 8; at < data.length;) {
    ensure(at + 12 <= data.length, 'Truncated PNG chunk');
    const length = data.readUInt32BE(at);
    ensure(at + length + 12 <= data.length, 'PNG chunk outside file');
    const type = data.toString('ascii', at + 4, at + 8);
    if (type === 'IDAT') idat.push(data.subarray(at + 8, at + 8 + length));
    at += length + 12;
    if (type === 'IEND') { sawEnd = true; break; }
  }
  ensure(sawEnd && idat.length, 'Missing PNG image data');
  const stride = width * 4;
  const expected = (stride + 1) * height;
  const raw = inflateSync(Buffer.concat(idat), { maxOutputLength: expected });
  ensure(raw.length === expected, 'Unexpected inflated PNG size');
  let previous = Buffer.alloc(stride), current = Buffer.alloc(stride), offset = 0;
  let transparent = 0, visible = 0, centreVisible = 0, combatBandAlphaMax = 0;
  const band = asset.combat_band_normalized;
  if (band) {
    ensure(band.length === 4 && band.every((v) => Number.isFinite(v) && v >= 0 && v <= 1)
      && band[0] < band[2] && band[1] < band[3], 'Invalid combat band: ' + asset.path);
  }
  let minX = width, minY = height, maxX = -1, maxY = -1;
  const paeth = (a, b, c) => {
    const p = a + b - c, pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c);
    return pa <= pb && pa <= pc ? a : pb <= pc ? b : c;
  };
  for (let y = 0; y < height; y++) {
    const filter = raw[offset++];
    ensure(filter <= 4, 'Unsupported PNG row filter');
    for (let i = 0; i < stride; i++) {
      const left = i >= 4 ? current[i - 4] : 0;
      const above = previous[i];
      const upperLeft = i >= 4 ? previous[i - 4] : 0;
      const add = filter === 0 ? 0 : filter === 1 ? left : filter === 2 ? above : filter === 3 ? ((left + above) >> 1) : paeth(left, above, upperLeft);
      current[i] = (raw[offset++] + add) & 255;
    }
    for (let x = 0; x < width; x++) {
      const alpha = current[x * 4 + 3];
      if (band && x >= Math.floor(width * band[0]) && x < Math.ceil(width * band[2])
        && y >= Math.floor(height * band[1]) && y < Math.ceil(height * band[3])) {
        combatBandAlphaMax = Math.max(combatBandAlphaMax, alpha);
      }
      if (alpha === 0) transparent++;
      if (alpha >= additions.alpha_threshold) {
        visible++;
        minX = Math.min(minX, x); minY = Math.min(minY, y);
        maxX = Math.max(maxX, x); maxY = Math.max(maxY, y);
        if (x >= Math.floor(width * 0.18) && x <= Math.ceil(width * 0.84)) centreVisible++;
      }
    }
    [previous, current] = [current, previous];
  }
  ensure(visible > 0 && transparent > width * height * 0.01, 'Alpha image must contain both visible art and genuine transparency');
  return { bounds: [minX, minY, maxX - minX + 1, maxY - minY + 1], transparent, centreVisible, combatBandAlphaMax };
}

ensure(additions.alpha_threshold === 16, 'Unexpected alpha registration threshold');
ensure(new Set(additions.assets.map((x) => x.path)).size === additions.assets.length, 'Duplicate addition path');
for (const asset of additions.assets) {
  const match = checked.get(asset.path);
  ensure(match, 'Addition missing from visual catalogue: ' + asset.path);
  const { data, entry } = match;
  ensure(data.length === asset.bytes && entry.sha256 === asset.sha256, 'Addition receipt mismatch: ' + asset.path);
  ensure(JSON.stringify(entry.dimensions) === JSON.stringify(asset.dimensions), 'Addition dimensions mismatch: ' + asset.path);
  if (!asset.transparent) continue;
  const metrics = alphaMetrics(data, asset);
  ensure(JSON.stringify(metrics.bounds) === JSON.stringify(asset.bounds_px), 'Alpha registration mismatch: ' + asset.path + ' actual ' + JSON.stringify(metrics.bounds));
  if (asset.role === 'stage_mid' || asset.role === 'stage_front') {
    if (asset.combat_band_normalized) {
      ensure(asset.combat_band_alpha_max === 1, 'Unexpected combat band alpha limit: ' + asset.path);
      ensure(metrics.combatBandAlphaMax <= 1, 'Parallax layer obstructs fighting band: ' + asset.path);
    } else {
      ensure(metrics.centreVisible === 0, 'Parallax layer obstructs central fighting corridor: ' + asset.path);
    }
  }
  if (asset.role === 'fighter_pose' || asset.role === 'prop') {
    const [x, y, w, h] = metrics.bounds;
    ensure(x > 0 && y > 0 && x + w < asset.dimensions[0] && y + h < asset.dimensions[1], 'Individual asset touches canvas edge: ' + asset.path);
  }
}
console.log('DOSSIER CURIEN ART: ' + catalog.length + ' catalogue PNGs verified; ' + additions.assets.length + ' additions, native dimensions, SHA-256 and alpha bounds verified.');
