import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, isAbsolute, join, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { inflateSync } from 'node:zlib';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const MANIFEST = 'data/assets/dossier_curien_motion.json';
const ART_ROOT = 'assets/dossier_curien/motion_2026-11-19';
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
  ensure(existsSync(base), `Missing motion art directory: ${directory}`);
  const result = [];
  for (const entry of readdirSync(base, { withFileTypes: true })) {
    const path = directory + '/' + entry.name;
    ensure(!entry.isSymbolicLink(), `Motion art must be a regular file/directory: ${path}`);
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

const POSES = new Set(['guard','windup','contact','recoil','recovery','jump_rise','jump_fall','crouch','crouch_guard','block','throw','victory','taunt','finish','reload','walk1','walk2','slide_contact']);
const point = value => Array.isArray(value) && value.length === 2 && value.every(Number.isFinite);
const within = (value, dimensions) => point(value) && value.every((n,i) => n >= 0 && n <= dimensions[i]);

function validate(data, root, allowProvisional = false) {
  ensure(record(data) && data.schema_version === 1 && Array.isArray(data.assets) && data.assets.length, 'Motion manifest must contain nonempty schema-1 assets');
  ensure(allowProvisional || data.provisional !== true, 'Provisional motion manifest is not a release validation');
  const keys = new Set(), paths = new Set();
  let totalBytes = 0;
  for (const asset of data.assets) {
    ensure(record(asset), 'Motion asset must be an object');
    ensure(allowProvisional || asset.provenance_pending !== true, 'Pending provenance cannot pass the release gate');
    const artId = asset.art_id ?? asset.fighter_id;
    ensure(/^[a-z0-9_]+$/.test(asset.fighter_id ?? '') && /^[a-z0-9_]+$/.test(artId ?? '') && POSES.has(asset.pose), 'Invalid fighter, art identity or pose');
    const key = artId + '_' + asset.pose;
    ensure(!keys.has(key), `Duplicate pose: ${key}`); keys.add(key);
    ensure(!paths.has(asset.path), `Duplicate path: ${asset.path}`); paths.add(asset.path);
    ensure(typeof asset.path === 'string' && asset.path.endsWith('.png'), `${key}: expected PNG path`);
    const bytes = readFileSync(checkedPath(root, asset.path, key, ART_ROOT));
    ensure(Number.isSafeInteger(asset.bytes) && asset.bytes === bytes.length, `${key}: byte count mismatch`);
    ensure(typeof asset.sha256 === 'string' && /^[a-f0-9]{64}$/.test(asset.sha256) && hash(bytes) === asset.sha256, `${key}: SHA-256 mismatch`);
    const metrics = rgbaMetrics(bytes, key, 127);
    ensure(point(asset.dimensions) && asset.dimensions.every((n,i) => n === metrics.dimensions[i]), `${key}: dimensions mismatch`);
    ensure(within(asset.pivot_px, asset.dimensions), `${key}: pivot outside image`);
    ensure(Number.isFinite(asset.standing_height_px) && asset.standing_height_px > 0, `${key}: invalid standing anatomical height`);
    if (asset.emitter_px !== undefined) ensure(within(asset.emitter_px, asset.dimensions), `${key}: emitter outside image`);
    if (asset.anchors_px !== undefined) {
      ensure(record(asset.anchors_px), `${key}: anchors must be an object`);
      for (const [name, value] of Object.entries(asset.anchors_px)) ensure(within(value, asset.dimensions), `${key}: anchor ${name} outside image`);
    }
    for (const field of ['visible_bbox','alpha_extrema']) if (asset[field] !== undefined) ensure(equal(asset[field], metrics[field]), `${key}: stale ${field}`);
    if (asset.provenance !== undefined) checkedPath(root, asset.provenance, `${key} provenance`);
    if (asset.references !== undefined) {
      ensure(Array.isArray(asset.references), `${key}: references must be an array`);
      for (const reference of asset.references) checkedPath(root, reference, `${key} reference`);
    }
    totalBytes += bytes.length;
  }
  const actual = pngFiles(root);
  ensure(actual.length === paths.size && actual.every(path => paths.has(path)), 'Uncatalogued motion PNG or stale manifest count');
  if (data.summary?.assets !== undefined) ensure(data.summary.assets === keys.size, 'Stale summary.assets');
  if (data.summary?.bytes !== undefined) ensure(data.summary.bytes === totalBytes, 'Stale summary.bytes');
  return { assets: keys.size, bytes: totalBytes };
}

function selfTest() {
  const fixture = mkdtempSync(join(tmpdir(), 'hotd-motion-'));
  const path = ART_ROOT + '/linda_block.png';
  const sample = readFileSync(join(ROOT, 'assets/dossier_curien/expansion/zombie_revenge_characters/linda_rotta_base.png'));
  const metrics = rgbaMetrics(sample, 'fixture', 127);
  mkdirSync(join(fixture, ART_ROOT), { recursive: true }); writeFileSync(join(fixture, path), sample);
  const valid = { schema_version: 1, assets: [{ fighter_id:'linda', pose:'block', path, bytes:sample.length, sha256:hash(sample), dimensions:metrics.dimensions, pivot_px:[500,1000], standing_height_px:1000 }] };
  let cases = 0;
  const rejects = (mutate, pattern) => { const candidate = structuredClone(valid); mutate(candidate); assert.throws(() => validate(candidate, fixture), pattern); cases++; };
  try {
    assert.equal(validate(valid, fixture).assets, 1); cases++;
    rejects(data => { data.assets[0].path = ART_ROOT + '/../escape.png'; }, /unsafe path segment/);
    rejects(data => { data.assets[0].sha256 = '0'.repeat(64); }, /SHA-256 mismatch/);
    rejects(data => { data.assets[0].dimensions = [1,1]; }, /dimensions mismatch/);
    rejects(data => { data.assets[0].pivot_px = [-1,1]; }, /pivot outside/);
    rejects(data => { data.assets[0].standing_height_px = 0; }, /anatomical height/);
    rejects(data => { data.assets[0].emitter_px = [0,-1]; }, /emitter outside/);
    rejects(data => { data.assets.push(structuredClone(data.assets[0])); }, /Duplicate pose/);
    rejects(data => { data.provisional = true; }, /Provisional motion manifest/);
    rejects(data => { data.assets[0].provenance_pending = true; }, /Pending provenance/);
    writeFileSync(join(fixture, ART_ROOT, 'undeclared.png'), sample);
    assert.throws(() => validate(valid, fixture), /Uncatalogued motion PNG/); cases++;
  } finally { rmSync(fixture, { recursive: true, force: true }); }
  console.log(`SAGA MOTION MANIFEST SELF-TEST: ${cases} cases passed.`);
}

const args = process.argv.slice(2);
ensure(args.length === 0 || (args.length === 1 && ['--self-test','--preview'].includes(args[0])), 'Usage: node scripts/verify_dossier_curien_motion.mjs [--self-test | --preview]');
if (args[0] === '--self-test') selfTest();
else console.log((args[0] === '--preview' ? 'SAGA MOTION DEVELOPMENT PREVIEW (not a release gate): ' : 'SAGA MOTION MANIFEST: ') + JSON.stringify(validate(JSON.parse(readFileSync(join(ROOT, MANIFEST), 'utf8')), ROOT, args[0] === '--preview')));
