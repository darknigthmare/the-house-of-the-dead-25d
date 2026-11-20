import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { dirname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const artRoot = join(root, 'assets/dossier_curien/saga');
const catalogue = JSON.parse(readFileSync(join(root, 'docs/dossier_curien/saga/CATALOGUE_VISUEL_SAGA.json'), 'utf8'));
const additions = JSON.parse(readFileSync(join(root, 'data/assets/dossier_curien_additions.json'), 'utf8'));
let checks = 0;
function check(condition, label) { checks++; assert.ok(condition, label); }
function filesIn(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? filesIn(path) : [path];
  });
}
const files = filesIn(artRoot).filter(path => path.endsWith('.png'));
const names = new Set();
const metadata = new Map();
check(catalogue.nombre_de_png === files.length, 'Catalogue count matches actual PNGs');
check(catalogue.fichiers.length === files.length, 'No missing or extra catalogue entries');
for (const entry of catalogue.fichiers) {
  check(!names.has(entry.fichier), `Unique catalogue path: ${entry.fichier}`);
  names.add(entry.fichier);
  const path = resolve(artRoot, entry.fichier);
  check(path.startsWith(artRoot + sep), `Asset remains inside the art directory: ${entry.fichier}`);
  const bytes = readFileSync(path);
  check(bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])), `PNG signature: ${entry.fichier}`);
  const dimensions = [bytes.readUInt32BE(16), bytes.readUInt32BE(20)];
  check(dimensions.every((value, index) => value === entry.dimensions[index]), `Native dimensions: ${entry.fichier}`);
  check(createHash('sha256').update(bytes).digest('hex') === entry.sha256, `SHA-256: ${entry.fichier}`);
  metadata.set(entry.fichier, dimensions);
  if (entry.lot === '2026-11-19_reprise') {
    check(bytes[25] === 6, `New asset has RGBA channels: ${entry.fichier}`);
    check(existsSync(path + '.import'), `Godot import is committed: ${entry.fichier}`);
    check(existsSync(join(root, entry.source_production)), `Production reference exists: ${entry.fichier}`);
  }
  if (['2026-11-20_stages', '2026-11-20_lot2_stages', '2026-11-20_lot3_stages'].includes(entry.lot)) {
    check(['back', 'mid', 'front'].includes(entry.usage), `New stage layer is identified: ${entry.fichier}`);
    check(bytes[25] === (entry.usage === 'back' ? 2 : 6), `Native RGB backdrop or RGBA overlay: ${entry.fichier}`);
    check(existsSync(path + '.import'), `New stage import is committed: ${entry.fichier}`);
    check(existsSync(join(root, entry.source_production)), `New stage production reference exists: ${entry.fichier}`);
    check(entry.statut === 'adaptation_2d_documentee', `New stage retains its documented adaptation status: ${entry.fichier}`);
  }
}
for (const path of files) check(names.has(relative(artRoot, path).split(sep).join('/')), `PNG catalogued: ${path}`);
for (const [id, pose] of Object.entries(additions.poses)) {
  const dimensions = metadata.get(id + '.png');
  check(dimensions?.every((value, index) => value === pose.source_size[index]), `Pose source dimensions: ${id}`);
  check(pose.pivot.length === 2 && pose.pivot.every(value => Number.isFinite(value) && value >= 0 && value <= 1), `Normalized foot pivot: ${id}`);
  check(pose.body_fraction > 0 && pose.body_fraction <= 1, `Body scale: ${id}`);
}
for (const item of [...additions.stage_props, ...additions.parts]) {
  check(item.path.startsWith('res://assets/dossier_curien/saga/'), `Registered asset path: ${item.id}`);
  check(existsSync(join(root, item.path.slice(6))), `Registered asset exists: ${item.id}`);
}
console.log(`DOSSIER CURIEN ART VERIFIED: ${checks} checks, ${files.length} Saga PNGs, ${Object.keys(additions.poses).length} calibrated poses.`);
