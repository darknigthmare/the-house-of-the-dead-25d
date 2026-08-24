import { createHash } from 'node:crypto';
import { existsSync, readFileSync } from 'node:fs';
import { resolve, join } from 'node:path';
import { inflateSync } from 'node:zlib';

const root = resolve(import.meta.dirname, '..');
const expectedDirections = ['front', 'front_left', 'left', 'back_left', 'back', 'back_right', 'right', 'front_right'];
const expectedStates = ['idle', 'move_contact_a', 'move_passing', 'move_contact_b', 'action_windup', 'action_strike', 'hit_recoil', 'death_fall'];
const scientistActors = ['scientist_male_blue', 'scientist_male_gray', 'scientist_female_lab'];
const fixedActors = ['thomas_rogan', 'agent_g', 'sophie_richards', 'dbr_scientist', 'dr_curien', 'mutant_bat', 'chariot', 'hangedman', 'hermit', 'magician', ...scientistActors];
const scientistSourceStates = ['idle', 'alarm', 'flee_a', 'flee_b', 'cower', 'rescue_wave', 'hit', 'death'];

function fail(message) {
  throw new Error(`SPRITE V2: ${message}`);
}

function json(relative) {
  return JSON.parse(readFileSync(join(root, relative), 'utf8'));
}

function paeth(a, b, c) {
  const p = a + b - c;
  const pa = Math.abs(p - a);
  const pb = Math.abs(p - b);
  const pc = Math.abs(p - c);
  return pa <= pb && pa <= pc ? a : (pb <= pc ? b : c);
}

function decodeRgbaPng(path) {
  const png = readFileSync(path);
  if (png.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') fail(`invalid PNG signature: ${path}`);
  let offset = 8;
  let width = 0;
  let height = 0;
  const idat = [];
  while (offset < png.length) {
    const length = png.readUInt32BE(offset);
    const type = png.subarray(offset + 4, offset + 8).toString('ascii');
    const data = png.subarray(offset + 8, offset + 8 + length);
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      if (data[8] !== 8 || data[9] !== 6 || data[12] !== 0) fail(`expected non-interlaced 8-bit RGBA: ${path}`);
    } else if (type === 'IDAT') {
      idat.push(data);
    } else if (type === 'IEND') {
      break;
    }
    offset += length + 12;
  }
  const bytesPerPixel = 4;
  const stride = width * bytesPerPixel;
  const packed = inflateSync(Buffer.concat(idat));
  if (packed.length !== (stride + 1) * height) fail(`unexpected scanline payload: ${path}`);
  const rgba = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y += 1) {
    const sourceOffset = y * (stride + 1);
    const targetOffset = y * stride;
    const filter = packed[sourceOffset];
    for (let x = 0; x < stride; x += 1) {
      const raw = packed[sourceOffset + 1 + x];
      const left = x >= bytesPerPixel ? rgba[targetOffset + x - bytesPerPixel] : 0;
      const up = y > 0 ? rgba[targetOffset - stride + x] : 0;
      const upLeft = y > 0 && x >= bytesPerPixel ? rgba[targetOffset - stride + x - bytesPerPixel] : 0;
      let value;
      if (filter === 0) value = raw;
      else if (filter === 1) value = raw + left;
      else if (filter === 2) value = raw + up;
      else if (filter === 3) value = raw + Math.floor((left + up) / 2);
      else if (filter === 4) value = raw + paeth(left, up, upLeft);
      else fail(`unsupported PNG filter ${filter}: ${path}`);
      rgba[targetOffset + x] = value & 0xff;
    }
  }
  return { width, height, rgba };
}

function validateCells(actorId, image) {
  const cell = image.width / 8;
  const gutter = 12;
  for (let row = 0; row < 8; row += 1) {
    for (let column = 0; column < 8; column += 1) {
      let visible = 0;
      let transparent = 0;
      let gutterVisible = 0;
      let innerCutRisk = 0;
      let greenFringe = 0;
      for (let y = 0; y < cell; y += 1) {
        for (let x = 0; x < cell; x += 1) {
          const px = column * cell + x;
          const py = row * cell + y;
          const offset = (py * image.width + px) * 4;
          const red = image.rgba[offset];
          const green = image.rgba[offset + 1];
          const blue = image.rgba[offset + 2];
          const alpha = image.rgba[offset + 3];
          if (alpha > 0) visible += 1;
          else transparent += 1;
          if ((x < gutter || y < gutter || x >= cell - gutter || y >= cell - gutter) && alpha > 0) gutterVisible += 1;
          if ((x === gutter || y === gutter || x === cell - gutter - 1 || y === cell - gutter - 1) && alpha > 0) innerCutRisk += 1;
          if (alpha > 0 && alpha < 245 && green > red * 1.18 + 8 && green > blue * 1.18 + 8) greenFringe += 1;
        }
      }
      if (visible < 80) fail(`${actorId} has an empty cell at row ${row}, column ${column}`);
      if (transparent < cell * cell * 0.2) fail(`${actorId} cell lacks transparent breathing room at row ${row}, column ${column}`);
      if (gutterVisible !== 0) fail(`${actorId} violates the ${gutter}px transparent gutter at row ${row}, column ${column}`);
      if (innerCutRisk !== 0) fail(`${actorId} has a likely clipped silhouette at row ${row}, column ${column}`);
      if (greenFringe !== 0) fail(`${actorId} retains keyed green fringe at row ${row}, column ${column}`);
    }
  }
}


function visibleCellHeight(image, row, column) {
  const cell = image.width / 8;
  let minimumY = cell;
  let maximumY = -1;
  for (let y = 0; y < cell; y += 1) {
    for (let x = 0; x < cell; x += 1) {
      const px = column * cell + x;
      const py = row * cell + y;
      const alpha = image.rgba[(py * image.width + px) * 4 + 3];
      if (alpha > 0) {
        minimumY = Math.min(minimumY, y);
        maximumY = Math.max(maximumY, y);
      }
    }
  }
  return maximumY >= minimumY ? maximumY - minimumY + 1 : 0;
}

function validateMoodyBodyScale(image) {
  for (let row = 0; row < 8; row += 1) {
    const normalHeights = [0, 1, 2, 3]
      .map((column) => visibleCellHeight(image, row, column))
      .sort((a, b) => a - b);
    const baseline = (normalHeights[1] + normalHeights[2]) / 2;
    for (const column of [4, 5]) {
      const actionHeight = visibleCellHeight(image, row, column);
      const ratio = actionHeight / baseline;
      if (ratio < 0.75 || ratio > 1.1) {
        fail(`moody_e3 body scale is unstable at row ${row}, column ${column}: ${actionHeight}px vs ${baseline}px (${ratio.toFixed(3)})`);
      }
    }
  }
}


const scientistGroupPath = 'reports/runtime/group_scientists_v2.json';
const scientistGroupAvailable = existsSync(join(root, scientistGroupPath));
let scientistGroupAssets = {};
if (!scientistGroupAvailable) {
  console.log('SPRITE V2 NOTE: private scientist source reports are absent; validating tracked manifest and provenance contracts.');
}
if (scientistGroupAvailable) {
  const scientistGroup = json(scientistGroupPath);
  scientistGroupAssets = scientistGroup.assets ?? {};
  if (scientistGroup.asset_count !== scientistActors.length) fail('scientist source group count mismatch');
  if (JSON.stringify(Object.keys(scientistGroupAssets)) !== JSON.stringify(scientistActors)) fail('scientist source group IDs or order mismatch');
  for (const scientistId of scientistActors) {
    const record = scientistGroupAssets[scientistId];
    if (!record || record.accepted !== true) fail(`scientist source is not accepted: ${scientistId}`);
    if (record.observed_columns !== 8 || record.observed_rows !== 6) fail(`scientist source layout mismatch: ${scientistId}`);
    if (JSON.stringify(record.observed_state_columns) !== JSON.stringify(scientistSourceStates)) fail(`scientist source-state order mismatch: ${scientistId}`);
    if (JSON.stringify(record.observed_direction_rows) !== JSON.stringify(['front', 'front_left', 'left', 'back_left', 'back', 'front_right'])) fail(`scientist source-direction order mismatch: ${scientistId}`);
    if (!String(record.selected_source_path).startsWith('reports/runtime/directional-sources/scientists/')) fail(`scientist selected source path mismatch: ${scientistId}`);
    if (!/^[a-f0-9]{64}$/.test(record.sha256)) fail(`scientist selected source hash is invalid: ${scientistId}`);
    if (!existsSync(join(root, record.selected_source_path))) fail(`scientist selected source is missing: ${scientistId}`);
    const sourceHash = createHash('sha256').update(readFileSync(join(root, record.selected_source_path))).digest('hex');
    if (sourceHash !== record.sha256) fail(`scientist selected source hash mismatch: ${scientistId}`);
  }
}

const manifest = json('data/assets/sprite_manifest.json');
if (manifest.schema_version !== 2) fail('manifest schema must be 2');
const layout = manifest.atlas_layout ?? {};
if (layout.columns !== 8 || layout.rows !== 8 || layout.frames_per_direction !== 8 || layout.cell_count !== 64 || layout.cell_px !== 256) fail('manifest layout must be 8x8, 64 cells, 256 px per cell');
if (JSON.stringify(layout.direction_order) !== JSON.stringify(expectedDirections)) fail('direction order mismatch');
if (JSON.stringify(layout.frame_states) !== JSON.stringify(expectedStates)) fail('frame-state order mismatch');

const enemyProfiles = json('data/enemies/enemy_profiles.json').profiles;
const expectedIds = new Set([...enemyProfiles.map((profile) => profile.id), ...fixedActors]);
const assets = manifest.assets ?? [];
if (assets.length !== expectedIds.size) fail(`expected ${expectedIds.size} dedicated organic atlases, got ${assets.length}`);
const ids = new Set();
const paths = new Set();
for (const asset of assets) {
  if (!expectedIds.has(asset.id)) fail(`unexpected organic atlas ID: ${asset.id}`);
  if (ids.has(asset.id)) fail(`duplicate atlas ID: ${asset.id}`);
  if (paths.has(asset.path)) fail(`shared atlas path is forbidden in v2: ${asset.path}`);
  ids.add(asset.id);
  paths.add(asset.path);
  if (asset.contract_version !== 2 || asset.status !== 'dedicated_fan_made_v2') fail(`asset is not dedicated v2: ${asset.id}`);
  if (asset.right_profile_source !== 'mirrored_left_profile') fail(`right-profile provenance missing: ${asset.id}`);
  if (scientistActors.includes(asset.id)) {
    if (asset.role !== 'civilian') fail(`scientist role mismatch: ${asset.id}`);
    if (!String(asset.source_sheet_path).startsWith('reports/runtime/directional-sources/scientists/')) fail(`scientist manifest source path mismatch: ${asset.id}`);
    if (!/^[a-f0-9]{64}$/.test(asset.source_sheet_sha256)) fail(`scientist manifest source hash is invalid: ${asset.id}`);
    if (asset.source_direction_rows !== 6 || asset.source_state_columns !== 8) fail(`scientist source dimensions diverge: ${asset.id}`);
    if (JSON.stringify(asset.source_state_names) !== JSON.stringify(scientistSourceStates)) fail(`scientist source-state provenance diverges: ${asset.id}`);
    if (scientistGroupAvailable) {
      const sourceRecord = scientistGroupAssets[asset.id];
      if (!sourceRecord) fail(`scientist source record is missing: ${asset.id}`);
      if (asset.source_sheet_path !== sourceRecord.selected_source_path) fail(`scientist source path diverges: ${asset.id}`);
      if (asset.source_sheet_sha256 !== sourceRecord.sha256) fail(`scientist source hash diverges: ${asset.id}`);
    }
    if ((asset.derived_state_columns ?? []).length !== 0) fail(`scientist states must not be synthesized: ${asset.id}`);
    if (asset.back_right_source !== 'mirrored_from_back_left') fail(`scientist back-right provenance missing: ${asset.id}`);
    const directionProvenance = asset.direction_provenance ?? {};
    if (directionProvenance.right?.operation !== 'mirror_horizontal' || directionProvenance.right?.source_direction !== 'left') fail(`scientist right mirror provenance mismatch: ${asset.id}`);
    if (directionProvenance.back_right?.operation !== 'mirror_horizontal' || directionProvenance.back_right?.source_direction !== 'back_left') fail(`scientist back-right mirror provenance mismatch: ${asset.id}`);
  }
  if (String(asset.path).includes('/sprites/')) fail(`legacy atlas is active: ${asset.id}`);
  const relative = String(asset.path).replace('res://', '');
  const absolute = join(root, relative);
  if (!existsSync(absolute)) fail(`atlas file is missing: ${asset.id}`);
  const image = decodeRgbaPng(absolute);
  if (image.width !== 2048 || image.height !== 2048) fail(`atlas must be 2048x2048: ${asset.id}`);
  validateCells(asset.id, image);
  if (asset.id === 'moody_e3') validateMoodyBodyScale(image);
}
for (const expected of expectedIds) if (!ids.has(expected)) fail(`missing atlas ID: ${expected}`);

for (const profile of enemyProfiles) {
  const manifestAsset = assets.find((asset) => asset.id === profile.id);
  if (profile.atlas_id !== profile.id) fail(`enemy atlas_id mismatch: ${profile.id}`);
  if (profile.visual_base !== manifestAsset.path) fail(`enemy visual path diverges from manifest: ${profile.id}`);
  if (profile.visual_status !== 'dedicated_fan_made_v2') fail(`enemy still uses a visual proxy: ${profile.id}`);
}

const privateAssemblyPath = join(root, 'reports/runtime/directional-atlas-assembly.json');
if (existsSync(privateAssemblyPath)) {
  const assembly = json('reports/runtime/directional-atlas-assembly.json');
  if (assembly.schema_version !== 2 || assembly.extraction_method !== 'whole_connected_components_aspect_fit_ground_anchor') fail('assembly report must describe the v2 component extractor');
  if ((assembly.actors ?? []).length !== expectedIds.size) fail('assembly report must cover every organic identity');
  const assemblyById = new Map(assembly.actors.map((record) => [record.id, record]));
  for (const expected of expectedIds) {
    const record = assemblyById.get(expected);
    if (!record) fail(`assembly report is missing ${expected}`);
    if (record.output_size?.[0] !== 2048 || record.output_size?.[1] !== 2048) fail(`assembly output size mismatch: ${expected}`);
    if (record.extraction_method !== assembly.extraction_method || record.transparent_gutter_px !== 12 || record.art_margin_px < 1) fail(`assembly extraction contract mismatch: ${expected}`);
    if (scientistActors.includes(expected)) {
      const sourceRecord = scientistGroupAssets[expected];
      if (!sourceRecord) fail(`scientist assembly source record is unavailable: ${expected}`);
      if (record.source_group_manifest !== 'reports/runtime/group_scientists_v2.json') fail(`scientist assembly group provenance mismatch: ${expected}`);
      if (record.source !== sourceRecord.selected_source_path || record.source_sha256 !== sourceRecord.sha256) fail(`scientist assembly source diverges: ${expected}`);
      if (JSON.stringify(record.source_state_names) !== JSON.stringify(scientistSourceStates)) fail(`scientist assembly source states diverge: ${expected}`);
      if (JSON.stringify(record.source_direction_names) !== JSON.stringify(sourceRecord.observed_direction_rows)) fail(`scientist assembly source directions diverge: ${expected}`);
      if (record.direction_provenance?.right?.source_direction !== 'left') fail(`scientist assembly right provenance mismatch: ${expected}`);
      if (record.direction_provenance?.back_right?.source_direction !== 'back_left') fail(`scientist assembly back-right provenance mismatch: ${expected}`);
    }
  }
  if (assemblyById.get('chariot')?.source !== 'reports/runtime/directional-sources/chariot_compact_v2.png') fail('Chariot compact source selection is not recorded');
  if (!assemblyById.get('samson_c1')?.derived_cells?.includes('front_right/death_fall_from_right/death_fall')) fail('Samson death-cell derivation is not recorded');
  if (!assemblyById.get('dr_curien')?.derived_state_columns?.includes('hit_recoil_from_action_strike')) fail('Curien seven-state derivation is not recorded');
  if ((assemblyById.get('moody_e3')?.localized_cells ?? []).length !== 14) fail('Moody chain-localisation policy must cover both action states in seven source rows');
  const chariotDiscard = assemblyById.get('chariot')?.discarded_components ?? [];
  if (!chariotDiscard.some((record) => record.source_row === 4 && record.state === 'death_fall' && record.visible_pixels > 0)) fail('Chariot back/death_fall fragment cleanup is not recorded');
}

const provenance = json('data/assets/sprite_generation_provenance.json');
if (provenance.schema_version !== 1 || provenance.policy?.no_rom_or_video_extraction !== true) fail('generation provenance policy is invalid');
if (provenance.policy?.source_originals_in_public_repository !== false) fail('source-original publication policy must remain explicit');
if ((provenance.assets ?? []).length !== expectedIds.size) fail('generation provenance must cover every organic identity');
const provenanceIds = new Set();
for (const record of provenance.assets) {
  if (!expectedIds.has(record.id) || provenanceIds.has(record.id)) fail(`invalid provenance ID: ${record.id}`);
  provenanceIds.add(record.id);
  const asset = assets.find((value) => value.id === record.id);
  if (!/^[a-f0-9]{64}$/.test(record.selected_source_sha256)) fail(`invalid source hash: ${record.id}`);
  if (record.selected_source_sha256 !== asset.source_sheet_sha256) fail(`source hash diverges from manifest: ${record.id}`);
  if (record.final_atlas_path !== String(asset.path).replace('res://', '')) fail(`final path diverges in provenance: ${record.id}`);
  if (record.final_atlas_sha256 !== asset.sha256) fail(`final hash diverges in provenance: ${record.id}`);
  if (record.generation_reference !== asset.generation_reference) fail(`generation reference diverges: ${record.id}`);
  if (/^[A-Za-z]:|^\//.test(record.generation_reference) || record.generation_reference.includes('\\')) fail(`machine-local generation path leaked: ${record.id}`);
  if (record.derived_directions?.right !== 'mirrored_from_left_profile') fail(`right-view provenance is incomplete: ${record.id}`);
  if (!['generated', 'mirrored_from_back_left'].includes(record.derived_directions?.back_right)) fail(`back-right provenance is invalid: ${record.id}`);
}

const runtimeFiles = [
  'src/gameplay/gameplay_runtime_base.gd',
  'src/gameplay/gameplay_runtime_combat.gd',
  'src/gameplay/gameplay_runtime_presentation.gd',
].map((path) => readFileSync(join(root, path), 'utf8')).join('\n');
for (const forbidden of ['ACTOR_TEXTURES', 'FRAME_SIZE', 'region_rect = Rect2']) {
  if (runtimeFiles.includes(forbidden)) fail(`legacy runtime token remains: ${forbidden}`);
}

console.log(`SPRITE V2 OK: ${assets.length} dedicated atlases, ${assets.length * 64} directional/state cells.`);
