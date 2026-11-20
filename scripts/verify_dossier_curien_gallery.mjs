import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { validate } from './verify_dossier_curien_expansion.mjs';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const MANIFEST = 'data/assets/dossier_curien_gallery_2026-11-20.json';
const BASE_MANIFEST = 'data/assets/dossier_curien_expansion.json';
const ART_ROOT = 'assets/dossier_curien/gallery_2026-11-20';
const CATEGORIES = new Set(['character_base', 'npc_base', 'costume_variant', 'boss_base', 'enemy_base', 'dialogue_portrait']);
const GAMES = new Set(['hotd', 'hotd2', 'hotd3', 'hotd4', 'hotd4_special', 'overkill', 'scarlet_dawn', 'zombie_revenge', 'hotd_ex', 'typing', 'typing2', 'english', 'pinball']);
const ensure = (condition, message) => { if (!condition) throw new Error(message); };

function validateGallery(manifest, root, existingIds) {
  ensure(manifest && Array.isArray(manifest.assets), 'Gallery assets must be an array');
  for (const asset of manifest.assets) {
    ensure(asset && typeof asset === 'object', 'Gallery entry must be an object');
    const label = String(asset.id ?? '(unnamed)');
    ensure(!existingIds.has(asset.id), `${label}: identity already belongs to the expansion collection`);
    ensure(asset.gallery === true, `${label}: gallery-only entry must explicitly use gallery:true`);
    ensure(asset.playable === false, `${label}: static gallery art cannot add a playable fighter or costume`);
    ensure(asset.animation_complete === false, `${label}: static gallery art cannot claim complete animation`);
    ensure(asset.runtime_role === 'bestiary', `${label}: static gallery art must use the bestiary runtime role`);
  }
  const result = validate(manifest, root, { artRoot: ART_ROOT, categories: CATEGORIES, games: GAMES });
  ensure(manifest.summary && typeof manifest.summary === 'object', 'Gallery summary is required');
  for (const [key, expected] of Object.entries({ assets: result.assets, gallery_entries: result.gallery, bytes: result.bytes, animation_complete: 0 })) {
    ensure(manifest.summary[key] === expected, `Gallery summary.${key} is missing or stale`);
  }
  return result;
}

function selfTest() {
  const base = JSON.parse(readFileSync(join(ROOT, BASE_MANIFEST), 'utf8'));
  const original = base.assets.find(asset => asset.id === 'linda_rotta');
  const sample = readFileSync(join(ROOT, original.path));
  const fixture = mkdtempSync(join(tmpdir(), 'hotd-gallery-'));
  const asset = structuredClone(original);
  Object.assign(asset, {
    id: 'test_gallery_npc', name: 'Test PNJ', game: 'overkill', game_label: 'The House of the Dead: Overkill',
    category: 'npc_base', path: ART_ROOT + '/test_gallery_npc.png', gallery: true,
    playable: false, animation_complete: false, runtime_role: 'bestiary',
    provenance: 'proof/production.json', references: ['proof/reference.png'],
  });
  mkdirSync(join(fixture, ART_ROOT), { recursive: true });
  mkdirSync(join(fixture, 'proof'));
  writeFileSync(join(fixture, asset.path), sample);
  writeFileSync(join(fixture, asset.references[0]), sample);
  writeFileSync(join(fixture, asset.provenance), '{}\n');
  const existingIds = new Set(base.assets.map(entry => entry.id));
  const valid = { schema_version: 1, assets: [asset], summary: { assets: 1, gallery_entries: 1, bytes: sample.length, animation_complete: 0 } };
  let cases = 0;
  const rejects = (name, mutate, expected) => {
    const candidate = structuredClone(valid);
    mutate(candidate);
    assert.throws(() => validateGallery(candidate, fixture, existingIds), expected, name);
    cases++;
  };
  try {
    assert.equal(validateGallery(valid, fixture, existingIds).gallery, 1); cases++;
    const costume = structuredClone(valid);
    costume.assets[0].category = 'costume_variant'; costume.assets[0].game = 'hotd3';
    assert.equal(validateGallery(costume, fixture, existingIds).gallery, 1); cases++;
    rejects('existing gallery identity', data => { data.assets[0].id = 'linda_rotta'; }, /already belongs/);
    rejects('playable static image', data => { data.assets[0].playable = true; }, /cannot add a playable/);
    rejects('unmarked gallery image', data => { delete data.assets[0].gallery; }, /gallery:true/);
    rejects('false complete animation', data => { data.assets[0].animation_complete = true; }, /cannot claim complete/);
    rejects('combat runtime role', data => { data.assets[0].runtime_role = 'fighter'; }, /bestiary runtime role/);
    rejects('unsafe image path', data => { data.assets[0].path = ART_ROOT + '/../escape.png'; }, /unsafe path segment/);
    rejects('foreign art collection', data => { data.assets[0].path = original.path; }, /path must stay inside/);
    rejects('unknown game', data => { data.assets[0].game = 'invented_game'; }, /unsupported gallery game/);
    rejects('stale gallery total', data => { data.summary.gallery_entries = 2; }, /gallery_entries/);
    rejects('changed image bytes', data => { data.assets[0].sha256 = '0'.repeat(64); }, /SHA-256 mismatch/);
    rejects('missing production receipt', data => { data.assets[0].provenance = 'proof/missing.json'; }, /missing file/);
    writeFileSync(join(fixture, ART_ROOT, 'uncatalogued.png'), sample);
    assert.throws(() => validateGallery(valid, fixture, existingIds), /Uncatalogued expansion PNG/); cases++;
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
  console.log(`DOSSIER CURIEN GALLERY SELF-TEST: ${cases} cases passed.`);
}

const args = process.argv.slice(2);
ensure(args.length === 0 || (args.length === 1 && args[0] === '--self-test'), 'Usage: node scripts/verify_dossier_curien_gallery.mjs [--self-test]');
if (args[0] === '--self-test') selfTest();
else {
  const existing = JSON.parse(readFileSync(join(ROOT, BASE_MANIFEST), 'utf8'));
  const manifest = JSON.parse(readFileSync(join(ROOT, MANIFEST), 'utf8'));
  const result = validateGallery(manifest, ROOT, new Set(existing.assets.map(asset => asset.id)));
  console.log(`DOSSIER CURIEN GALLERY VERIFIED: ${result.assets} PNGs, ${result.gallery} non-playable gallery entries, ${result.bytes} bytes; hashes, RGBA bounds, provenance, distinct identities and paths verified.`);
}
