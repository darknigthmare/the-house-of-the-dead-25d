import { createHash } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const readJson = (relative) => JSON.parse(readFileSync(join(root, relative), 'utf8'));
const writeJson = (relative, value) => writeFileSync(join(root, relative), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
const today = '2026-08-21';

const enemies = readJson('data/enemies/enemy_profiles.json');
const legacyManifest = readJson('data/assets/sprite_manifest.json');
const legacyVisuals = readJson('data/assets/actor_visual_profiles.json');
const assembly = readJson('reports/runtime/directional-atlas-assembly.json');
const assemblyById = new Map(assembly.actors.map((record) => [record.id, record]));
const legacyById = new Map((legacyManifest.assets ?? []).map((asset) => [asset.id, asset]));


const generationById = new Map();
for (const relative of [
  'reports/runtime/group_humans_bosses.json',
  'reports/runtime/group_enemies_ad.json',
  'reports/runtime/group_enemies_eg.json',
  'reports/runtime/group_scientists_v2.json',
]) {
  const group = readJson(relative);
  const grouped = group.assets ?? group.actors ?? [];
  const records = Array.isArray(grouped)
    ? grouped
    : Object.entries(grouped).map(([id, record]) => ({ id, ...record }));
  for (const record of records) {
    if (generationById.has(record.id)) throw new Error(`Duplicate ImageGen provenance ID: ${record.id}`);
    generationById.set(record.id, record);
  }
}
generationById.set('sam_a1', {
  id: 'sam_a1',
  generated_original_path: '01a00811-e655-7262-8c79-852788f57b9b/exec-f8918b33-b026-4935-acdc-c1c76c5e2d9b.png',
  selected_source_path: 'reports/runtime/directional-sources/sam_a1.png',
  observed_rows: 7,
  observed_columns: 8,
  selected_rows: 7,
  selected_columns: 8,
  derived_state_columns: [],
  accepted: true,
  notes: 'Directional production pilot retained after visual inspection and atlas validation.',
});

function generationReference(path) {
  const parts = String(path).replaceAll('\\', '/').split('/').filter(Boolean);
  return parts.slice(-2).join('/');
}

const fixed = [
  { id: 'thomas_rogan', role: 'hero', folder: 'heroes' },
  { id: 'agent_g', role: 'hero', folder: 'heroes' },
  { id: 'sophie_richards', role: 'npc', folder: 'npcs' },
  { id: 'dbr_scientist', role: 'civilian', folder: 'npcs' },
  { id: 'dr_curien', role: 'npc', folder: 'npcs' },
  { id: 'mutant_bat', role: 'enemy', folder: 'enemies' },
  { id: 'chariot', role: 'boss', folder: 'bosses' },
  { id: 'hangedman', role: 'boss', folder: 'bosses' },
  { id: 'hermit', role: 'boss', folder: 'bosses' },
  { id: 'magician', role: 'boss', folder: 'bosses' },
  { id: 'scientist_male_blue', role: 'civilian', folder: 'npcs' },
  { id: 'scientist_male_gray', role: 'civilian', folder: 'npcs' },
  { id: 'scientist_female_lab', role: 'civilian', folder: 'npcs' },
];
const actors = [
  ...fixed,
  ...enemies.profiles.map((profile) => ({ id: profile.id, role: 'enemy', folder: 'enemies' })),
];
const ids = new Set();
for (const actor of actors) {
  if (ids.has(actor.id)) throw new Error(`Duplicate sprite-contract ID: ${actor.id}`);
  ids.add(actor.id);
}
if (actors.length !== 38) throw new Error(`Expected 38 dedicated organic identities, got ${actors.length}`);

const oldVisualPath = new Map(enemies.profiles.map((profile) => [profile.id, profile.visual_base]));
const airborne = new Set(['mutant_bat', 'devilon_f4', 'hangedman']);
const manifestAssets = actors.map((actor) => {
  const record = assemblyById.get(actor.id);
  if (!record) throw new Error(`Assembly report is missing ${actor.id}`);
  const path = `res://assets/sprites_v2/${actor.folder}/${actor.id}/${actor.id}__v2__action_cycle__8dirx8f.png`;
  const absolute = join(root, path.slice('res://'.length));
  if (!existsSync(absolute)) throw new Error(`Final atlas is missing: ${path}`);
  const previousAsset = legacyById.get(actor.id);
  const legacy = previousAsset?.legacy_path
    ?? previousAsset?.path
    ?? (actor.id === 'cyril_a3' ? legacyById.get('axe_creature')?.path : undefined)
    ?? oldVisualPath.get(actor.id)
    ?? null;
  return {
    id: actor.id,
    role: actor.role,
    path,
    legacy_path: legacy,
    source: 'openai_imagegen_fan_made_directional_v2',
    source_sheet_path: record.source,
    source_sheet_sha256: record.source_sha256,
    generation_reference: generationReference(generationById.get(actor.id)?.generated_original_path),
    source_direction_rows: record.source_direction_rows,
    source_state_columns: record.source_state_columns,
    derived_state_columns: record.derived_state_columns,
    state_column_map: record.state_column_map,
    ...(record.source_group_manifest ? {
      source_state_names: record.source_state_names,
      direction_provenance: record.direction_provenance,
    } : {}),
    generated: today,
    contract_version: 2,
    status: 'dedicated_fan_made_v2',
    clip: 'action_cycle',
    base_pixel_size: 0.0075,
    origin_y: 0.95,
    billboard: airborne.has(actor.id) ? 'full' : 'fixed_y',
    back_right_source: record.back_right,
    right_profile_source: 'mirrored_left_profile',
    sha256: createHash('sha256').update(readFileSync(absolute)).digest('hex'),
  };
});

const manifest = {
  schema_version: 2,
  atlas_layout: {
    columns: 8,
    rows: 8,
    cell_px: 256,
    cell_count: 64,
    frames_per_direction: 8,
    direction_axis: 'rows',
    frame_axis: 'columns',
    direction_order: ['front', 'front_left', 'left', 'back_left', 'back', 'back_right', 'right', 'front_right'],
    frame_states: ['idle', 'move_contact_a', 'move_passing', 'move_contact_b', 'action_windup', 'action_strike', 'hit_recoil', 'death_fall'],
  },
  aliases: {
    scientist: 'dbr_scientist',
    sophie: 'sophie_richards',
    curien: 'dr_curien',
    axe_creature: 'cyril_a3',
  },
  assets: manifestAssets,
};
writeJson('data/assets/sprite_manifest.json', manifest);

const provenanceAssets = actors.map((actor) => {
  const assemblyRecord = assemblyById.get(actor.id);
  const generation = generationById.get(actor.id);
  if (!generation || generation.accepted !== true) throw new Error(`Missing accepted ImageGen provenance: ${actor.id}`);
  if (generation.selected_source_path !== assemblyRecord.source) {
    throw new Error(`Selected source diverges from assembly report: ${actor.id}`);
  }
  if (generation.sha256 && generation.sha256 !== assemblyRecord.source_sha256) {
    throw new Error(`Selected source hash diverges from assembly report: ${actor.id}`);
  }
  const generatedDerivedStates = generation.derived_state_columns ?? [];
  return {
    id: actor.id,
    provider: 'openai_imagegen',
    generation_reference: generationReference(generation.generated_original_path),
    selected_source_path: assemblyRecord.source,
    selected_source_sha256: assemblyRecord.source_sha256,
    observed_rows: generation.observed_rows,
    observed_columns: generation.observed_columns,
    selected_rows: generation.selected_rows ?? generation.observed_rows,
    selected_columns: generation.selected_columns ?? generation.observed_columns,
    relaunch_count: generation.relaunch_count ?? null,
    derived_state_columns: generatedDerivedStates.length > 0
      ? generatedDerivedStates
      : assemblyRecord.derived_state_columns,
    derived_directions: {
      right: assemblyRecord.right_profile,
      back_right: assemblyRecord.back_right,
    },
    final_atlas_path: assemblyRecord.output,
    final_atlas_sha256: manifestAssets.find((asset) => asset.id === actor.id).sha256,
    notes: generation.notes ?? '',
  };
});
if (provenanceAssets.length !== 38) throw new Error(`Expected 38 provenance records, got ${provenanceAssets.length}`);
writeJson('data/assets/sprite_generation_provenance.json', {
  schema_version: 1,
  generated_on: today,
  policy: {
    source_originals_in_public_repository: false,
    final_transparent_atlases_in_public_repository: true,
    no_rom_or_video_extraction: true,
    note: 'Generation references are preserved without publishing machine-local absolute paths.',
  },
  assets: provenanceAssets,
});

const priorProfiles = legacyVisuals.profiles ?? {};
const scientistVisualDefaults = {
  scientist_male_blue: {
    palette: ['pale blue', 'white', 'navy'],
    fixed_costume: 'worn pale-blue laboratory coat, white shirt, navy trousers, black shoes and thin eyeglasses',
    forbidden: ['weapons', 'hazmat suit', 'modern PPE'],
  },
  scientist_male_gray: {
    palette: ['medium gray', 'burgundy', 'charcoal'],
    fixed_costume: 'wrinkled medium-gray laboratory coat, dark burgundy turtleneck, charcoal trousers and brown shoes',
    forbidden: ['weapons', 'hazmat suit', 'modern PPE'],
  },
  scientist_female_lab: {
    palette: ['aged ivory', 'muted teal', 'charcoal'],
    fixed_costume: 'worn off-white laboratory coat, muted teal blouse, charcoal trousers, black shoes and dark low bun',
    forbidden: ['weapons', 'hazmat suit', 'modern PPE'],
  },
};
const visualProfiles = {};
for (const actor of actors) {
  const enemy = enemies.profiles.find((profile) => profile.id === actor.id);
  const inherited = priorProfiles[actor.id]
    ?? (actor.id === 'cyril_a3' ? priorProfiles.axe_creature : undefined)
    ?? (actor.id === 'devilon_f4' ? priorProfiles.mutant_bat : undefined)
    ?? scientistVisualDefaults[actor.id]
    ?? {};
  const weapon = enemy?.weapon?.kind ? ` with ${enemy.weapon.kind.replaceAll('_', ' ')}` : '';
  visualProfiles[actor.id] = {
    canonical_name: enemy?.canonical_name ?? actor.id,
    palette: inherited.palette ?? ['desaturated flesh', 'charcoal', 'oxidized material'],
    fixed_costume: inherited.fixed_costume ?? `distinct ${enemy?.archetype?.replaceAll('_', ' ') ?? actor.role} silhouette${weapon}`,
    forbidden: inherited.forbidden ?? ['modern tactical gear', 'unlisted firearms', 'copied arcade pixels'],
    atlas_id: actor.id,
    visual_status: 'dedicated_fan_made_v2',
    directions: manifest.atlas_layout.direction_order,
    frame_states: manifest.atlas_layout.frame_states,
  };
}
writeJson('data/assets/actor_visual_profiles.json', {
  schema_version: 2,
  global: {
    style: 'hand-painted 1990s arcade horror sprite art',
    directions: manifest.atlas_layout.direction_order,
    frame_states: manifest.atlas_layout.frame_states,
    render_modes: ['arcade_25d', 'hd_25d'],
    filter_arcade: true,
    filter_hd: false,
    feet_grounded: true,
    billboard_default: 'fixed_y',
    right_profile_policy: 'mirrored_left_profile_with_documented_provenance',
  },
  profiles: visualProfiles,
});

for (const profile of enemies.profiles) {
  const asset = manifestAssets.find((entry) => entry.id === profile.id);
  profile.atlas_id = profile.id;
  profile.visual_base = asset.path;
  profile.visual_status = 'dedicated_fan_made_v2';
  profile.verification_status.visual = 'dedicated_fan_made_directional_v2';
}
enemies.schema_version = 3;
enemies.visual_policy = {
  kind: 'dedicated_fan_made_directional_atlases_v2',
  note: 'Every enemy type has a unique 8-direction x 8-state fan-made atlas. No ROM or video-extracted pixels are used.',
};
writeJson('data/enemies/enemy_profiles.json', enemies);

console.log(`SPRITE CONTRACT BUILT: ${manifestAssets.length} dedicated atlases and ${enemies.profiles.length} unique enemy bindings.`);
