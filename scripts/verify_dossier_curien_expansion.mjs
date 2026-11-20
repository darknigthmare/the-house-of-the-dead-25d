import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, isAbsolute, join, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { inflateSync } from 'node:zlib';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const MANIFEST = 'data/assets/dossier_curien_expansion.json';
const ART_ROOT = 'assets/dossier_curien/expansion';
const CATEGORIES = new Set(['character_base', 'dialogue_portrait', 'boss_base', 'enemy_base', 'fighter_pose', 'animation_pose']);
const POSE_CATEGORIES = new Set(['fighter_pose', 'animation_pose']);
const GAMES = new Set(['zombie_revenge', 'hotd_ex']);
const STATUSES = new Set([
  'static_reference_reviewed', 'static_needs_visual_reference_qa', 'static_needs_provenance_review',
  'static_needs_framing_review', 'static_needs_alpha_cleanup', 'generated_reference_reviewed',
  'generated_needs_visual_reference_qa', 'generated_needs_framing_review', 'reference_reviewed',
]);
const PNG_SIGNATURE = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const ensure = (condition, message) => { if (!condition) throw new Error(message); };
const record = value => value !== null && typeof value === 'object' && !Array.isArray(value);
const text = value => typeof value === 'string' && value.trim().length > 0;
const hash = data => createHash('sha256').update(data).digest('hex');
const equal = (a, b) => JSON.stringify(a) === JSON.stringify(b);

function checkedPath(root, value, label, prefix = '') {
  ensure(text(value) && !isAbsolute(value) && !value.includes('\\') && !value.includes('\0')
    && !/^[A-Za-z][A-Za-z0-9+.-]*:/.test(value), `${label}: expected a repository-relative path`);
  ensure(value.split('/').every(part => part && part !== '.' && part !== '..'), `${label}: unsafe path segment`);
  if (prefix) ensure(value.startsWith(prefix + '/'), `${label}: path must stay inside ${prefix}`);
  const path = resolve(root, value);
  ensure(path.startsWith(root + sep), `${label}: path escapes repository`);
  ensure(existsSync(path), `${label}: missing file ${value}`);
  const real = realpathSync(path);
  const boundary = resolve(root, prefix);
  ensure(real.startsWith(boundary + sep), `${label}: symbolic link escapes allowed directory`);
  ensure(statSync(path).isFile(), `${label}: expected a file ${value}`);
  return path;
}

function pngFiles(root, directory = ART_ROOT) {
  const base = resolve(root, directory);
  ensure(existsSync(base), `Missing expansion art directory: ${directory}`);
  const result = [];
  for (const entry of readdirSync(base, { withFileTypes: true })) {
    const path = directory + '/' + entry.name;
    ensure(!entry.isSymbolicLink(), `Expansion art must be a regular file/directory: ${path}`);
    if (entry.isDirectory()) result.push(...pngFiles(root, path));
    else if (entry.name.toLowerCase().endsWith('.png')) result.push(path);
  }
  return result.sort();
}

function stringArray(value, label, optional = false) {
  if (optional && value === undefined) return [];
  ensure(Array.isArray(value) && value.every(text), `${label}: expected an array of nonempty strings`);
  return value;
}

function rgbaMetrics(data, label, visibleThreshold) {
  ensure(data.length >= 45 && data.subarray(0, 8).equals(PNG_SIGNATURE), `${label}: invalid PNG signature/header`);
  ensure(data.toString('ascii', 12, 16) === 'IHDR' && data.readUInt32BE(8) === 13, `${label}: invalid IHDR`);
  const width = data.readUInt32BE(16), height = data.readUInt32BE(20);
  ensure(width > 0 && height > 0 && width * height <= 32_000_000, `${label}: invalid or excessive image dimensions`);
  ensure(data[24] === 8 && data[25] === 6 && data[26] === 0 && data[27] === 0 && data[28] === 0,
    `${label}: expected non-interlaced 8-bit RGBA PNG`);
  const compressed = [];
  let ended = false;
  for (let offset = 8; offset < data.length;) {
    ensure(offset + 12 <= data.length, `${label}: truncated PNG chunk`);
    const length = data.readUInt32BE(offset);
    ensure(offset + length + 12 <= data.length, `${label}: PNG chunk exceeds file size`);
    const type = data.toString('ascii', offset + 4, offset + 8);
    if (type === 'IDAT') compressed.push(data.subarray(offset + 8, offset + 8 + length));
    offset += length + 12;
    if (type === 'IEND') { ended = true; break; }
  }
  ensure(ended && compressed.length > 0, `${label}: incomplete PNG image data`);
  const stride = width * 4, expected = (stride + 1) * height;
  const raw = inflateSync(Buffer.concat(compressed), { maxOutputLength: expected });
  ensure(raw.length === expected, `${label}: unexpected inflated PNG size`);
  let previous = Buffer.alloc(stride), current = Buffer.alloc(stride), offset = 0;
  let transparent = 0, alphaMin = 255, alphaMax = 0;
  const bounds = [1, visibleThreshold + 1].map(() => [width, height, -1, -1]);
  const paeth = (a, b, c) => {
    const p = a + b - c, pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c);
    return pa <= pb && pa <= pc ? a : pb <= pc ? b : c;
  };
  for (let y = 0; y < height; y++) {
    const filter = raw[offset++];
    ensure(filter <= 4, `${label}: invalid PNG row filter`);
    for (let i = 0; i < stride; i++) {
      const left = i >= 4 ? current[i - 4] : 0, above = previous[i], upperLeft = i >= 4 ? previous[i - 4] : 0;
      const add = filter === 0 ? 0 : filter === 1 ? left : filter === 2 ? above : filter === 3 ? ((left + above) >> 1) : paeth(left, above, upperLeft);
      current[i] = (raw[offset++] + add) & 255;
    }
    for (let x = 0; x < width; x++) {
      const alpha = current[x * 4 + 3];
      alphaMin = Math.min(alphaMin, alpha); alphaMax = Math.max(alphaMax, alpha);
      if (alpha === 0) transparent++;
      for (let index = 0; index < bounds.length; index++) {
        if (alpha < (index === 0 ? 1 : visibleThreshold + 1)) continue;
        const box = bounds[index];
        box[0] = Math.min(box[0], x); box[1] = Math.min(box[1], y);
        box[2] = Math.max(box[2], x + 1); box[3] = Math.max(box[3], y + 1);
      }
    }
    [previous, current] = [current, previous];
  }
  ensure(transparent > 0 && alphaMax > visibleThreshold, `${label}: expected visible artwork and true transparency`);
  return { dimensions: [width, height], alpha_extrema: [alphaMin, alphaMax], alpha_bbox: bounds[0], visible_bbox: bounds[1] };
}

function counts(assets, field) {
  const result = {};
  for (const asset of assets) result[asset[field]] = (result[asset[field]] ?? 0) + 1;
  return result;
}

export function validate(manifest, root, options = {}) {
  const artRoot = options.artRoot ?? ART_ROOT;
  const categories = options.categories ?? CATEGORIES;
  const games = options.games ?? GAMES;
  root = realpathSync(root);
  ensure(record(manifest) && manifest.schema_version === 1, 'Expected expansion schema_version 1');
  ensure(Array.isArray(manifest.assets) && manifest.assets.length > 0, 'Expansion assets must be a nonempty array');
  const ids = new Set(), paths = new Set(), physicalPaths = new Set();
  let totalBytes = 0, galleryCount = 0;
  for (const asset of manifest.assets) {
    ensure(record(asset), 'Expansion entry must be an object');
    const label = String(asset.id ?? '(unnamed)');
    ensure(typeof asset.id === 'string' && /^[a-z][a-z0-9_]*$/.test(asset.id), `Invalid asset id: ${label}`);
    ensure(!ids.has(asset.id), `Duplicate asset id: ${asset.id}`); ids.add(asset.id);
    ensure(text(asset.name) && text(asset.game_label), `${label}: missing gallery name/game label`);
    ensure(games.has(asset.game), `${label}: unsupported gallery game`);
    ensure(categories.has(asset.category), `${label}: unsupported asset category`);
    ensure(STATUSES.has(asset.status), `${label}: unsupported quality status ${asset.status}`);
    ensure(asset.gallery === undefined || typeof asset.gallery === 'boolean', `${label}: gallery flag must be boolean`);
    ensure(asset.playable === undefined || typeof asset.playable === 'boolean', `${label}: playable flag must be boolean`);
    ensure(asset.animation_complete === undefined || typeof asset.animation_complete === 'boolean', `${label}: animation_complete must be boolean`);
    if (POSE_CATEGORIES.has(asset.category)) ensure(asset.gallery === false, `${label}: animation poses must explicitly use gallery:false`);
    if (asset.gallery !== false) galleryCount++;
    if (asset.playable === true) ensure(asset.category === 'character_base' || asset.category === 'boss_base', `${label}: portraits and pose frames are not playable gallery entries`);
    const limitations = stringArray(asset.limitations, `${label} limitations`);
    ensure(limitations.length > 0, `${label}: artwork limitations must be documented`);
    const sourceNotes = stringArray(asset.source_notes, `${label} source_notes`, true);
    const sources = stringArray(asset.sources, `${label} sources`);
    const references = stringArray(asset.references, `${label} references`);
    ensure(sources.length > 0 || (sourceNotes.length > 0 && references.length > 0), `${label}: missing sources require documented provenance and a saved reference`);
    for (const source of sources) {
      let url;
      try { url = new URL(source); } catch { throw new Error(`${label}: invalid source URL ${source}`); }
      ensure(['http:', 'https:'].includes(url.protocol) && !url.username && !url.password, `${label}: unsafe source URL`);
    }
    const prompts = stringArray(asset.prompts, `${label} prompts`);
    ensure(prompts.length > 0 || limitations.some(value => /prompt/i.test(value)), `${label}: missing original prompt must be documented`);
    for (const reference of references) checkedPath(root, reference, `${label} reference`);
    checkedPath(root, asset.provenance, `${label} provenance`);
    const path = checkedPath(root, asset.path, `${label} asset`, artRoot);
    ensure(asset.path.endsWith('.png'), `${label}: artwork must be a PNG`);
    ensure(!paths.has(asset.path), `Duplicate asset path: ${asset.path}`); paths.add(asset.path);
    const real = realpathSync(path);
    ensure(!physicalPaths.has(real), `Duplicate physical asset file: ${asset.path}`); physicalPaths.add(real);
    const data = readFileSync(path);
    ensure(Number.isSafeInteger(asset.bytes) && asset.bytes === data.length, `${label}: byte-size mismatch`);
    ensure(typeof asset.sha256 === 'string' && /^[a-f0-9]{64}$/.test(asset.sha256) && hash(data) === asset.sha256, `${label}: SHA-256 mismatch`);
    const threshold = asset.visible_alpha_threshold ?? 127;
    ensure(Number.isInteger(threshold) && threshold >= 0 && threshold < 255, `${label}: invalid visible alpha threshold`);
    const metrics = rgbaMetrics(data, label, threshold);
    ensure(equal(asset.dimensions, metrics.dimensions), `${label}: dimensions mismatch`);
    if (asset.mode !== undefined) ensure(asset.mode === 'RGBA', `${label}: invalid recorded image mode`);
    for (const field of ['alpha_extrema', 'alpha_bbox', 'visible_bbox']) {
      if (asset[field] !== undefined) ensure(equal(asset[field], metrics[field]), `${label}: ${field} mismatch; actual ${JSON.stringify(metrics[field])}`);
    }
    totalBytes += data.length;
  }
  const pngs = pngFiles(root, artRoot);
  for (const path of pngs) ensure(paths.has(path), `Uncatalogued expansion PNG: ${path}`);
  ensure(paths.size === pngs.length, 'Every expansion PNG must have exactly one manifest entry');
  if (manifest.summary !== undefined) {
    ensure(record(manifest.summary), 'Expansion summary must be an object');
    const expected = { assets: manifest.assets.length, bytes: totalBytes, animation_complete: manifest.assets.filter(asset => asset.animation_complete === true).length };
    for (const [key, value] of Object.entries(expected)) if (manifest.summary[key] !== undefined) ensure(manifest.summary[key] === value, `Expansion summary.${key} is stale`);
    for (const [key, field] of [['by_game', 'game'], ['by_category', 'category'], ['by_status', 'status']]) {
      if (manifest.summary[key] === undefined) continue;
      const actual = counts(manifest.assets, field), recorded = manifest.summary[key];
      ensure(record(recorded) && Object.keys(recorded).length === Object.keys(actual).length
        && Object.keys(actual).every(name => actual[name] === recorded[name]), `Expansion summary.${key} is stale`);
    }
  }
  return { assets: paths.size, gallery: galleryCount, bytes: totalBytes };
}

function selfTest() {
  const original = JSON.parse(readFileSync(join(ROOT, MANIFEST), 'utf8')).assets[0];
  const fixture = mkdtempSync(join(tmpdir(), 'hotd-expansion-'));
  const asset = structuredClone(original);
  asset.id = 'test_subject'; asset.gallery = true; asset.playable = false;
  asset.path = ART_ROOT + '/test_subject.png'; asset.provenance = 'proof/production.json'; asset.references = ['proof/reference.png'];
  const sample = readFileSync(join(ROOT, original.path));
  mkdirSync(join(fixture, ART_ROOT), { recursive: true }); mkdirSync(join(fixture, 'proof'));
  writeFileSync(join(fixture, asset.path), sample); writeFileSync(join(fixture, asset.references[0]), sample);
  writeFileSync(join(fixture, asset.provenance), '{}\n');
  const valid = { schema_version: 1, assets: [asset] };
  let cases = 0;
  const rejects = (name, mutate, expected) => {
    const candidate = structuredClone(valid); mutate(candidate);
    assert.throws(() => validate(candidate, fixture), expected, name); cases++;
  };
  try {
    assert.equal(validate(valid, fixture).assets, 1); cases++;
    rejects('path traversal', data => { data.assets[0].path = ART_ROOT + '/../escape.png'; }, /unsafe path segment/);
    rejects('absolute reference', data => { data.assets[0].references = ['/etc/passwd']; }, /repository-relative path/);
    rejects('duplicate identity', data => { data.assets.push(structuredClone(data.assets[0])); }, /Duplicate asset id/);
    rejects('missing artwork', data => { data.assets[0].path = ART_ROOT + '/missing.png'; }, /missing file/);
    rejects('missing reference', data => { data.assets[0].references = ['proof/missing.png']; }, /missing file/);
    rejects('changed bytes', data => { data.assets[0].sha256 = '0'.repeat(64); }, /SHA-256 mismatch/);
    rejects('undocumented missing source', data => { data.assets[0].sources = []; data.assets[0].source_notes = []; }, /missing sources require/);
    rejects('mislabelled pose gallery row', data => { data.assets[0].category = 'fighter_pose'; }, /gallery:false/);
    writeFileSync(join(fixture, ART_ROOT, 'unlisted.png'), sample);
    assert.throws(() => validate(valid, fixture), /Uncatalogued expansion PNG/); cases++;
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
  console.log(`DOSSIER CURIEN EXPANSION SELF-TEST: ${cases} cases passed.`);
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2);
  ensure(args.length === 0 || (args.length === 1 && args[0] === '--self-test'), 'Usage: node scripts/verify_dossier_curien_expansion.mjs [--self-test]');
  if (args[0] === '--self-test') selfTest();
  else {
    const result = validate(JSON.parse(readFileSync(join(ROOT, MANIFEST), 'utf8')), ROOT);
    console.log(`DOSSIER CURIEN EXPANSION VERIFIED: ${result.assets} PNGs, ${result.gallery} gallery entries, ${result.bytes} bytes; hashes, RGBA bounds, provenance and paths verified.`);
  }
}
