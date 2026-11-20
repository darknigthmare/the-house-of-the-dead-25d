import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { isDeepStrictEqual } from 'node:util';
import { validate } from './verify_dossier_curien_expansion.mjs';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const BASE_MANIFEST = 'data/assets/dossier_curien_expansion.json';
const ART_ROOT = 'assets/dossier_curien/gallery_2026-11-20';
const LOT2_ART_ROOT = 'assets/dossier_curien/gallery_2026-11-20_lot2';
const COLLECTIONS = [
  { path: 'data/assets/dossier_curien_gallery_2026-11-20.json', artRoot: ART_ROOT },
  { path: 'data/assets/dossier_curien_gallery_2026-11-20_lot2.json', artRoot: LOT2_ART_ROOT },
];
const CATEGORIES = new Set(['character_base', 'npc_base', 'costume_variant', 'boss_base', 'enemy_base', 'dialogue_portrait']);
const GAMES = new Set(['hotd', 'hotd2', 'hotd3', 'hotd4', 'hotd4_special', 'overkill', 'scarlet_dawn', 'zombie_revenge', 'hotd_ex', 'typing', 'typing2', 'english', 'pinball']);
const ensure = (condition, message) => { if (!condition) throw new Error(message); };

function validateGallery(manifest, root, existingIds, artRoot = ART_ROOT) {
  ensure(manifest && Array.isArray(manifest.assets), 'Gallery assets must be an array');
  for (const asset of manifest.assets) {
    ensure(asset && typeof asset === 'object', 'Gallery entry must be an object');
    const label = String(asset.id ?? '(unnamed)');
    ensure(!existingIds.has(asset.id), `${label}: identity already belongs to an earlier collection`);
    ensure(asset.gallery === true, `${label}: gallery-only entry must explicitly use gallery:true`);
    ensure(asset.playable === false, `${label}: static gallery art cannot add a playable fighter or costume`);
    ensure(asset.animation_complete === false, `${label}: static gallery art cannot claim complete animation`);
    ensure(asset.runtime_role === 'bestiary', `${label}: static gallery art must use the bestiary runtime role`);
  }
  const result = validate(manifest, root, { artRoot, categories: CATEGORIES, games: GAMES });
  ensure(manifest.summary && typeof manifest.summary === 'object', 'Gallery summary is required');
  for (const [key, expected] of Object.entries({ assets: result.assets, gallery_entries: result.gallery, bytes: result.bytes, playable_added: 0, animation_complete: 0 })) {
    ensure(manifest.summary[key] === expected, `Gallery summary.${key} is missing or stale`);
  }
  if (manifest.production_receipts !== undefined) {
    ensure(Array.isArray(manifest.production_receipts) && manifest.production_receipts.length > 0, 'Gallery production receipts must be a nonempty array');
    const provenance = new Set(manifest.assets.map(asset => asset.provenance));
    const declared = new Map(manifest.assets.map(asset => [asset.id, asset]));
    const covered = new Set();
    for (const receipt of manifest.production_receipts) {
      // validate() already checked every declared provenance path and real path.
      ensure(receipt && provenance.has(receipt.path), 'Gallery receipt must identify a declared production source');
      const bytes = readFileSync(join(root, receipt.path));
      ensure(createHash('sha256').update(bytes).digest('hex') === receipt.sha256, `Gallery receipt SHA-256 mismatch: ${receipt.path}`);
      const source = JSON.parse(bytes.toString('utf8'));
      ensure(source && Array.isArray(source.assets) && source.assets.length > 0 && receipt.assets === source.assets.length, `Gallery receipt asset count is invalid: ${receipt.path}`);
      for (const asset of source.assets) {
        ensure(asset && !covered.has(asset.id) && declared.get(asset.id)?.provenance === receipt.path && isDeepStrictEqual(declared.get(asset.id), asset), `Gallery receipt row differs from the delivered subject: ${String(asset?.id)}`);
        covered.add(asset.id);
      }
    }
    ensure(covered.size === manifest.assets.length, 'Gallery production receipts must cover every delivered subject');
  }
  return result;
}

function validateCollections(collections, root, existingIds) {
  const ids = new Set(existingIds);
  return collections.map(({ manifest, artRoot }) => {
    const result = validateGallery(manifest, root, ids, artRoot);
    for (const asset of manifest.assets) ids.add(asset.id);
    return result;
  });
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
  const valid = { schema_version: 1, assets: [asset], summary: { assets: 1, gallery_entries: 1, bytes: sample.length, playable_added: 0, animation_complete: 0 } };
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
    rejects('false playable summary', data => { data.summary.playable_added = 1; }, /playable_added/);
    rejects('changed image bytes', data => { data.assets[0].sha256 = '0'.repeat(64); }, /SHA-256 mismatch/);
    rejects('missing production receipt', data => { data.assets[0].provenance = 'proof/missing.json'; }, /missing file/);
    const later = structuredClone(valid);
    Object.assign(later.assets[0], { id: 'later_gallery_costume', category: 'costume_variant', game: 'typing', path: LOT2_ART_ROOT + '/later_gallery_costume.png' });
    mkdirSync(join(fixture, LOT2_ART_ROOT), { recursive: true });
    writeFileSync(join(fixture, later.assets[0].path), sample);
    const batches = [{ manifest: valid, artRoot: ART_ROOT }, { manifest: later, artRoot: LOT2_ART_ROOT }];
    assert.equal(validateCollections(batches, fixture, existingIds).reduce((sum, result) => sum + result.gallery, 0), 2); cases++;
    const collision = structuredClone(batches);
    collision[1].manifest.assets[0].id = valid.assets[0].id;
    assert.throws(() => validateCollections(collision, fixture, existingIds), /already belongs/, 'Duplicate across successive gallery batches'); cases++;
    const wrongRoot = structuredClone(batches);
    wrongRoot[1].manifest.assets[0].path = valid.assets[0].path;
    assert.throws(() => validateCollections(wrongRoot, fixture, existingIds), /path must stay inside/, 'Later batch cannot borrow a previous art root'); cases++;
    const proof = Buffer.from(JSON.stringify({ assets: valid.assets }));
    writeFileSync(join(fixture, asset.provenance), proof);
    const withReceipt = structuredClone(valid);
    withReceipt.production_receipts = [{ path: asset.provenance, sha256: createHash('sha256').update(proof).digest('hex'), assets: 1 }];
    assert.equal(validateGallery(withReceipt, fixture, existingIds).gallery, 1); cases++;
    const staleReceipt = structuredClone(withReceipt);
    staleReceipt.production_receipts[0].sha256 = '0'.repeat(64);
    assert.throws(() => validateGallery(staleReceipt, fixture, existingIds), /receipt SHA-256 mismatch/, 'Changed production receipt bytes'); cases++;
    const divergentSubject = structuredClone(withReceipt);
    divergentSubject.assets[0].name = 'Different delivered identity';
    assert.throws(() => validateGallery(divergentSubject, fixture, existingIds), /receipt row differs/, 'Merged manifest must preserve the source receipt row'); cases++;
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
  const collections = COLLECTIONS.map(({ path, artRoot }) => ({ manifest: JSON.parse(readFileSync(join(ROOT, path), 'utf8')), artRoot }));
  const results = validateCollections(collections, ROOT, new Set(existing.assets.map(asset => asset.id)));
  for (let index = 0; index < results.length; index++) {
    const result = results[index];
    console.log(`DOSSIER CURIEN GALLERY VERIFIED (${COLLECTIONS[index].path}): ${result.assets} PNGs, ${result.gallery} non-playable gallery entries, ${result.bytes} bytes; hashes, RGBA bounds, provenance, distinct identities and paths verified.`);
  }
  console.log(`DOSSIER CURIEN GALLERY COLLECTIONS: ${results.length} batches, ${results.reduce((sum, result) => sum + result.gallery, 0)} distinct non-playable entries.`);
}
