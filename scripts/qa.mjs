import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

const root = resolve(import.meta.dirname, '..');
const args = new Set(process.argv.slice(2));
const failures = [];
const checks = [];
const check = (condition, message) => {
  checks.push(message);
  if (!condition) failures.push(message);
};
const json = (path) => JSON.parse(readFileSync(join(root, path), 'utf8'));

const required = [
  'project.godot', 'scenes/main.tscn', 'scenes/gameplay/gameplay.tscn',
  'data/assets/sprite_manifest.json', 'data/assets/actor_visual_profiles.json',
  'data/assets/environment_manifest.json', 'data/assets/gameplay_support_manifest.json',
  'data/audio/audio_cues.json',
  'docs/REFERENCE_MATRIX.md', 'docs/ROUTE_GRAPH.md', 'docs/GAMEPLAY_RULES.md',
  'docs/FIDELITY_REPORT.md', 'docs/SPRITE_PRODUCTION_BIBLE.md',
  'docs/ASSET_LICENSE_MANIFEST.md', 'docs/MISSING_LICENSED_ASSETS.md',
  'docs/CONTENT_ASSET_CATALOG.md',
  'scripts/smoke_curien_finale.gd', 'scripts/smoke_gameplay.gd',
  'scripts/smoke_campaign.gd', 'scripts/smoke_score_qa.gd', 'scripts/smoke_initials.gd',
  'scripts/smoke_hud_text.gd', 'scripts/smoke_sequence_pacing.gd', 'scripts/smoke_route_decisions.gd', 'scripts/smoke_spawn_density.gd'
];
for (const file of required) check(existsSync(join(root, file)), `required file: ${file}`);

const manifest = json('data/assets/sprite_manifest.json');
check(manifest.schema_version === 2, 'sprite manifest schema is 2');
check(manifest.atlas_layout?.columns === 8 && manifest.atlas_layout?.rows === 8, 'directional atlas layout is 8x8');
check(manifest.atlas_layout?.cell_count === 64, 'directional atlas contains 64 cells');
check(manifest.assets.length === 38, 'all thirty-eight organic identities have dedicated atlases');
for (const asset of manifest.assets) {
  const relative = asset.path.replace('res://', '');
  const full = join(root, relative);
  check(existsSync(full), `directional sprite exists: ${asset.id}`);
  if (!existsSync(full)) continue;
  const png = readFileSync(full);
  check(png.subarray(1, 4).toString() === 'PNG', `valid PNG signature: ${asset.id}`);
  const width = png.readUInt32BE(16);
  const height = png.readUInt32BE(20);
  const colorType = png[25];
  check(width === 2048 && height === 2048, `atlas is 2048x2048: ${asset.id}`);
  check(width % 8 === 0 && height % 8 === 0, `atlas divides into 8x8: ${asset.id}`);
  check(colorType === 6, `PNG is RGBA: ${asset.id}`);
}

const chapters = [];
for (let index = 1; index <= 4; index += 1) {
  const id = String(index).padStart(2, '0');
  const chapterPath = `data/chapters/chapter_${id}.json`;
  const routePath = `data/routes/chapter_${id}_route_graph.json`;
  check(existsSync(join(root, chapterPath)), `chapter data exists: ${id}`);
  check(existsSync(join(root, routePath)), `route graph exists: ${id}`);
  if (existsSync(join(root, chapterPath))) chapters.push(json(chapterPath));
  if (existsSync(join(root, routePath))) {
    const graph = json(routePath);
    check(Array.isArray(graph.nodes) && graph.nodes.length >= 3, `chapter ${id} has playable route nodes`);
    const ids = new Set(graph.nodes.map((node) => node.id));
    check(ids.size === graph.nodes.length, `chapter ${id} route ids are unique`);
    for (const node of graph.nodes) {
      for (const next of node.next ?? []) {
        const nextId = typeof next === 'string' ? next : next.node;
        check(ids.has(nextId) || nextId === 'chapter_complete', `route target ${nextId} resolves in chapter ${id}`);
      }
    }
  }
}
check(chapters.length === 4, 'four chapters parse');
if (chapters.length === 4) {
  check(chapters.map((entry) => entry.boss?.id).join(',') === 'chariot,hangedman,hermit,magician', 'canonical boss order');
}

if (existsSync(join(root, 'data/bosses/boss_profiles.json'))) {
  const bosses = json('data/bosses/boss_profiles.json');
  const list = bosses.bosses ?? bosses;
  check(Array.isArray(list) && list.length >= 4, 'four boss profiles');
  for (const boss of list) check((boss.phases?.length ?? 0) >= 2, `boss phases: ${boss.id}`);
}

if (args.has('--web-only')) {
  const web = join(root, 'build', 'web');
  check(existsSync(join(web, 'index.html')), 'web export index exists');
  check(existsSync(join(web, 'index.wasm')), 'web export wasm exists');
  const webIndex = join(web, 'index.html');
  check(!existsSync(webIndex) || !readFileSync(webIndex, 'utf8').includes('user-scalable=no'), 'web viewport keeps browser zoom enabled');
  check(!existsSync(webIndex) || readFileSync(webIndex, 'utf8').includes('<canvas id="canvas" role="main" aria-label="The House of the Dead 2.5D game canvas">'), 'web canvas has accessible landmark and name');
}

if (!args.has('--data-only') && !args.has('--web-only')) {
  const exe = join(root, '.tools', 'godot-4.7.1', 'Godot_v4.7.1-stable_win64_console.exe');
  check(existsSync(exe), 'local Godot 4.7.1 console exists');
  if (existsSync(exe)) {
    const importRun = spawnSync(exe, ['--headless', '--path', root, '--import'], { encoding: 'utf8', timeout: 120000 });
    check(importRun.status === 0, 'Godot headless import/editor parse');
    if (importRun.status !== 0) process.stderr.write(`${importRun.stdout ?? ''}${importRun.stderr ?? ''}`);
    if (existsSync(join(root, 'tests', 'test_runner.gd'))) {
      const testRun = spawnSync(exe, ['--headless', '--path', root, '--script', 'res://tests/test_runner.gd'], { encoding: 'utf8', timeout: 120000 });
      check(testRun.status === 0, 'Godot deterministic test suite');
      process.stdout.write(testRun.stdout ?? '');
      if (testRun.status !== 0) process.stderr.write(testRun.stderr ?? '');
    }
    const runtimeRuns = [
      ['res://tests/test_sprite_atlas_library_atomic.gd', 'transactional sprite manifest test'],
      ['res://tests/test_environment_asset_library.gd', 'environment asset library test'],
      ['res://tests/test_gameplay_support_library.gd', 'gameplay support library test'],
      ['res://tests/test_enemy_profile_library.gd', 'enemy profile runtime contract test'],
      ['res://tests/test_procedural_audio.gd', 'procedural audio content test'],
      ['res://scripts/smoke_directional_sprites.gd', 'directional sprite runtime smoke'],
      ['res://scripts/smoke_curien_finale.gd', 'Curien finale narrative smoke'],
      ['res://scripts/smoke_gameplay.gd', 'gameplay interaction smoke'],
      ['res://scripts/smoke_campaign.gd', 'full campaign smoke'],
      ['res://scripts/smoke_score_qa.gd', 'score audit smoke'],
      ['res://scripts/smoke_initials.gd', 'initials and credits smoke'],
      ['res://scripts/smoke_hud_text.gd', 'HUD texture and glyph smoke'],
      ['res://scripts/smoke_sequence_pacing.gd', 'sequence pacing and camera continuity smoke'],
      ['res://scripts/smoke_route_decisions.gd', 'physical route-decision smoke'],
      ['res://scripts/smoke_spawn_density.gd', 'ordinary encounter spawn-density smoke'],
    ];
    for (const [script, label] of runtimeRuns) {
      const run = spawnSync(exe, ['--headless', '--path', root, '--script', script], { encoding: 'utf8', timeout: 120000 });
      check(run.status === 0, label);
      process.stdout.write(run.stdout ?? '');
      if (run.status !== 0) process.stderr.write(run.stderr ?? '');
    }
  }
}

console.log(`QA checks: ${checks.length - failures.length}/${checks.length} passed`);
if (failures.length) {
  console.error(failures.map((failure) => `FAIL: ${failure}`).join('\n'));
  process.exit(1);
}
