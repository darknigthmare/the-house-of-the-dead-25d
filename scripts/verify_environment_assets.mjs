#!/usr/bin/env node

import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { join, relative, resolve } from 'node:path';
import { inflateSync } from 'node:zlib';

const root = resolve(import.meta.dirname, '..');
const manifestPath = join(root, 'data', 'assets', 'environment_manifest.json');
const provenancePath = join(root, 'data', 'assets', 'environment_generation_provenance.json');
const outputRoot = join(root, 'assets', 'environments_v2');

const EXPECTED_MATERIALS = [
  'garden_mud_moss', 'garden_flagstone', 'estate_weathered_stone',
  'mansion_damp_plaster', 'mansion_dark_wood_panel', 'mansion_marble_floor',
  'mansion_worn_red_carpet', 'mansion_oak_door', 'library_dark_oak_shelf',
  'sewer_wet_brick', 'sewer_slick_stone', 'sewer_rusted_iron',
  'roof_weathered_slate', 'roof_gothic_stone', 'lab_painted_metal',
  'lab_grated_floor', 'lab_rusted_pipe', 'lab_grimy_glass',
  'lab_bio_machine_panel', 'hermit_web_membrane',
];
const EXPECTED_NODES = [
  'garden_rescue', 'mansion_entrance', 'under_bridge', 'foyer_choice',
  'upper_stairs', 'ground_hall', 'sophie_antechamber', 'sophie_corridor',
  'chariot_battle', 'chain_plate', 'underground_passage', 'great_doors',
  'library_rescue', 'raised_bridge', 'lower_stairs', 'roof_approach',
  'roof_rescue', 'hangedman_battle', 'elevator_switch', 'left_elevator',
  'right_elevator', 'back_attack_rescue', 'security_door', 'vent_key_route',
  'curien_tunnel', 'hermit_battle', 'chariot_rematch', 'hangedman_rematch',
  'bonus_gate', 'bonus_room', 'final_waves', 'curien_confrontation',
  'magician_battle',
];
const EXPECTED_DESTRUCTIBLES = [
  'c01_foyer_door_lock', 'c02_chained_hatch_plate',
  'c03_elevator_route_switch', 'c03_vent_key_container',
  'c04_bonus_gate_seal', 'c04_emergency_supply_crate',
];
const EXPECTED_PROPS = [
  'mansion_chandelier', 'mansion_sconce', 'mansion_double_door',
  'library_bookcase', 'mansion_portrait', 'lab_control_console',
  'estate_gate', 'garden_lamp', 'dead_tree', 'stone_bridge_arch',
  'roof_gargoyle', 'lab_specimen_tank', 'lab_pipe_cluster', 'lab_vent_fan',
];
const EXPECTED_ANIMATED_EFFECTS = [
  'drips', 'water_flow', 'electrical_arc', 'monitor_scan',
];
const MATTE_REPAIR_PROPS = new Set([
  'estate_gate', 'garden_lamp', 'mansion_chandelier', 'mansion_sconce',
]);

let assertions = 0;
const failures = [];

function check(condition, message) {
  assertions += 1;
  if (!condition) failures.push(message);
}

function checkExactKeys(actualObject, expected, label) {
  const actual = Object.keys(actualObject ?? {}).sort();
  const wanted = [...expected].sort();
  check(JSON.stringify(actual) === JSON.stringify(wanted), `${label}: expected ${wanted.join(', ')}, got ${actual.join(', ')}`);
}

function projectPath(resourcePath) {
  check(typeof resourcePath === 'string' && resourcePath.startsWith('res://'), `invalid resource path: ${resourcePath}`);
  const relativePath = String(resourcePath).replace(/^res:\/\//, '').replaceAll('\\', '/');
  return join(root, relativePath);
}

function listFiles(directory) {
  if (!existsSync(directory)) return [];
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? listFiles(path) : [path];
  });
}

function paeth(a, b, c) {
  const p = a + b - c;
  const pa = Math.abs(p - a);
  const pb = Math.abs(p - b);
  const pc = Math.abs(p - c);
  return pa <= pb && pa <= pc ? a : (pb <= pc ? b : c);
}

function decodePng(path) {
  const file = readFileSync(path);
  check(file.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])), `${relative(root, path)} has a valid PNG signature`);
  let offset = 8;
  let width = 0;
  let height = 0;
  let bitDepth = 0;
  let colorType = 0;
  let interlace = 0;
  const idat = [];
  while (offset + 12 <= file.length) {
    const length = file.readUInt32BE(offset);
    const type = file.toString('ascii', offset + 4, offset + 8);
    const data = file.subarray(offset + 8, offset + 8 + length);
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      bitDepth = data[8];
      colorType = data[9];
      interlace = data[12];
    } else if (type === 'IDAT') {
      idat.push(data);
    } else if (type === 'IEND') {
      break;
    }
    offset += length + 12;
  }
  check(bitDepth === 8, `${relative(root, path)} uses 8-bit channels`);
  check(interlace === 0, `${relative(root, path)} is non-interlaced`);
  const channels = ({ 0: 1, 2: 3, 4: 2, 6: 4 })[colorType];
  check(Boolean(channels), `${relative(root, path)} uses a supported RGB/RGBA color type`);
  if (!channels) throw new Error(`Unsupported PNG color type ${colorType}: ${path}`);
  const packed = inflateSync(Buffer.concat(idat));
  const stride = width * channels;
  const pixels = Buffer.alloc(stride * height);
  let sourceOffset = 0;
  for (let y = 0; y < height; y += 1) {
    const filter = packed[sourceOffset];
    sourceOffset += 1;
    for (let x = 0; x < stride; x += 1) {
      const raw = packed[sourceOffset + x];
      const left = x >= channels ? pixels[y * stride + x - channels] : 0;
      const up = y > 0 ? pixels[(y - 1) * stride + x] : 0;
      const upperLeft = y > 0 && x >= channels ? pixels[(y - 1) * stride + x - channels] : 0;
      let value = raw;
      if (filter === 1) value = raw + left;
      else if (filter === 2) value = raw + up;
      else if (filter === 3) value = raw + Math.floor((left + up) / 2);
      else if (filter === 4) value = raw + paeth(left, up, upperLeft);
      else if (filter !== 0) throw new Error(`Unsupported PNG filter ${filter}: ${path}`);
      pixels[y * stride + x] = value & 255;
    }
    sourceOffset += stride;
  }
  check(sourceOffset === packed.length, `${relative(root, path)} scanlines have the expected length`);
  return { width, height, colorType, channels, pixels };
}

function channelStats(image, channel) {
  let min = 255;
  let max = 0;
  let sum = 0;
  const count = image.width * image.height;
  for (let index = channel; index < image.pixels.length; index += image.channels) {
    const value = image.pixels[index];
    min = Math.min(min, value);
    max = Math.max(max, value);
    sum += value;
  }
  return { min, max, mean: sum / count };
}

function edgeDelta(image) {
  let sum = 0;
  let count = 0;
  const channels = Math.min(image.channels, 3);
  for (let y = 0; y < image.height; y += 1) {
    for (let c = 0; c < channels; c += 1) {
      const left = image.pixels[(y * image.width) * image.channels + c];
      const right = image.pixels[(y * image.width + image.width - 1) * image.channels + c];
      sum += Math.abs(left - right);
      count += 1;
    }
  }
  for (let x = 0; x < image.width; x += 1) {
    for (let c = 0; c < channels; c += 1) {
      const top = image.pixels[x * image.channels + c];
      const bottom = image.pixels[((image.height - 1) * image.width + x) * image.channels + c];
      sum += Math.abs(top - bottom);
      count += 1;
    }
  }
  return sum / Math.max(1, count);
}

function alphaCoverage(image, startX = 0, endX = image.width) {
  check(image.channels === 4, 'alpha coverage requires RGBA data');
  let visible = 0;
  let partial = 0;
  const total = (endX - startX) * image.height;
  for (let y = 0; y < image.height; y += 1) {
    for (let x = startX; x < endX; x += 1) {
      const alpha = image.pixels[(y * image.width + x) * image.channels + 3];
      if (alpha > 0) visible += 1;
      if (alpha > 0 && alpha < 255) partial += 1;
    }
  }
  return { visible: visible / total, partial: partial / total };
}

function neutralEdgeFringeRatio(image, startX, endX) {
  check(image.channels === 4, 'neutral fringe detection requires RGBA data');
  let edgeAlpha = 0;
  let fringeAlpha = 0;
  for (let y = 0; y < image.height; y += 1) {
    for (let x = startX; x < endX; x += 1) {
      const pixel = (y * image.width + x) * image.channels;
      const alpha = image.pixels[pixel + 3];
      if (alpha < 8) continue;
      const neighborAlpha = (neighborX, neighborY) => {
        if (neighborX < startX || neighborX >= endX || neighborY < 0 || neighborY >= image.height) return 0;
        return image.pixels[(neighborY * image.width + neighborX) * image.channels + 3];
      };
      const isEdge = neighborAlpha(x - 1, y) === 0
        || neighborAlpha(x + 1, y) === 0
        || neighborAlpha(x, y - 1) === 0
        || neighborAlpha(x, y + 1) === 0;
      if (!isEdge) continue;
      edgeAlpha += alpha;
      const red = image.pixels[pixel];
      const green = image.pixels[pixel + 1];
      const blue = image.pixels[pixel + 2];
      const low = Math.min(red, green, blue);
      const chroma = Math.max(red, green, blue) - low;
      const pale = Math.max(0, Math.min(1, (low - 158) / 97));
      const neutral = Math.max(0, Math.min(1, (48 - chroma) / 48));
      fringeAlpha += alpha * pale * neutral;
    }
  }
  return fringeAlpha / Math.max(1, edgeAlpha);
}

function largestNeutralMatteComponent(image, startX, endX) {
  check(image.channels === 4, 'neutral matte detection requires RGBA data');
  const width = endX - startX;
  const total = width * image.height;
  const visited = new Uint8Array(total);
  const queue = new Int32Array(total);
  const isCandidate = (localIndex) => {
    const localX = localIndex % width;
    const y = Math.floor(localIndex / width);
    const pixel = (y * image.width + startX + localX) * image.channels;
    const alpha = image.pixels[pixel + 3];
    if (alpha === 0) return false;
    const red = image.pixels[pixel];
    const green = image.pixels[pixel + 1];
    const blue = image.pixels[pixel + 2];
    return Math.min(red, green, blue) >= 220 && Math.max(red, green, blue) - Math.min(red, green, blue) <= 32;
  };
  let largest = 0;
  for (let seed = 0; seed < total; seed += 1) {
    if (visited[seed]) continue;
    visited[seed] = 1;
    if (!isCandidate(seed)) continue;
    let head = 0;
    let tail = 0;
    let size = 0;
    queue[tail] = seed;
    tail += 1;
    while (head < tail) {
      const current = queue[head];
      head += 1;
      size += 1;
      const x = current % width;
      const y = Math.floor(current / width);
      const neighbors = [
        x > 0 ? current - 1 : -1,
        x + 1 < width ? current + 1 : -1,
        y > 0 ? current - width : -1,
        y + 1 < image.height ? current + width : -1,
      ];
      for (const neighbor of neighbors) {
        if (neighbor < 0 || visited[neighbor]) continue;
        visited[neighbor] = 1;
        if (!isCandidate(neighbor)) continue;
        queue[tail] = neighbor;
        tail += 1;
      }
    }
    largest = Math.max(largest, size);
  }
  return largest;
}

function fileDigest(path) {
  const data = readFileSync(path);
  let hash = 2166136261;
  for (const byte of data) {
    hash ^= byte;
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

function meanPixelDelta(first, second) {
  check(first.width === second.width && first.height === second.height && first.channels === second.channels, 'state images share one pixel contract');
  let sum = 0;
  for (let index = 0; index < first.pixels.length; index += 1) sum += Math.abs(first.pixels[index] - second.pixels[index]);
  return sum / Math.max(1, first.pixels.length);
}

function loadJson(path) {
  check(existsSync(path), `${relative(root, path)} exists`);
  return JSON.parse(readFileSync(path, 'utf8'));
}

const manifest = loadJson(manifestPath);
const provenance = loadJson(provenancePath);

check(manifest.schema_version === 1, 'environment manifest schema is 1');
check(provenance.schema_version === 1, 'environment provenance schema is 1');
checkExactKeys(manifest.materials, EXPECTED_MATERIALS, 'material contract');
checkExactKeys(manifest.nodes, EXPECTED_NODES, 'campaign-node contract');
checkExactKeys(manifest.destructibles, EXPECTED_DESTRUCTIBLES, 'destructible contract');
checkExactKeys(manifest.props, EXPECTED_PROPS, 'prop contract');
checkExactKeys(manifest.animated_effects, EXPECTED_ANIMATED_EFFECTS, 'animated-effect contract');
checkExactKeys(manifest.styles, ['garden', 'mansion', 'sewer', 'roof', 'laboratory'], 'style contract');

const referencedMaterials = new Set();
const supportedEffects = new Set([
  'alarm_beacon', 'collapse_dust', 'distant_bats', 'drips', 'dust', 'electrical_arc', 'embers', 'lightning',
  'mist', 'monitor_scan', 'rain', 'sconce_flicker', 'steam', 'water_flow', 'web_drift', 'wind',
]);

for (const [styleId, style] of Object.entries(manifest.styles)) {
  for (const key of ['floor', 'wall', 'column', 'accent']) {
    check(Boolean(manifest.materials[style[key]]), `${styleId}.${key} references a material`);
    if (manifest.materials[style[key]]) referencedMaterials.add(style[key]);
  }
  for (const key of ['ceiling', 'door', 'glass']) {
    if (!style[key]) continue;
    check(Boolean(manifest.materials[style[key]]), `${styleId}.${key} references a material`);
    if (manifest.materials[style[key]]) referencedMaterials.add(style[key]);
  }
  const backdrop = projectPath(style.backdrop);
  check(existsSync(backdrop), `${styleId} backdrop exists`);
  check(typeof style.layout === 'string' && style.layout.length > 0, `${styleId} has a layout`);
  check(Array.isArray(style.effects), `${styleId} effects are data-driven`);
  for (const effect of style.effects ?? []) check(supportedEffects.has(effect), `${styleId} effect ${effect} is supported`);
}

for (const [nodeId, node] of Object.entries(manifest.nodes)) {
  check(Boolean(manifest.styles[node.style]), `${nodeId} references style ${node.style}`);
  check(typeof node.layout === 'string' && node.layout.length > 0, `${nodeId} has a layout`);
  for (const key of ['floor', 'wall', 'column', 'ceiling', 'accent', 'door', 'glass']) {
    if (!node[key]) continue;
    check(Boolean(manifest.materials[node[key]]), `${nodeId}.${key} references a material`);
    if (manifest.materials[node[key]]) referencedMaterials.add(node[key]);
  }
  for (const placement of node.props ?? []) {
    check(Boolean(manifest.props[placement.id]), `${nodeId} prop ${placement.id} exists`);
    check(Array.isArray(placement.position) && placement.position.length === 3 && placement.position.every(Number.isFinite), `${nodeId} prop ${placement.id} has a 3D position`);
  }
  for (const effect of node.effects ?? []) check(supportedEffects.has(effect), `${nodeId} effect ${effect} is supported`);
}

for (const materialId of EXPECTED_MATERIALS) {
  check(referencedMaterials.has(materialId), `${materialId} is referenced by a runtime style or node`);
}

for (const materialId of EXPECTED_MATERIALS) {
  const profile = manifest.materials[materialId];
  const expected = { albedo: [1024, 1024], normal: [512, 512], orm: [256, 256] };
  for (const [kind, dimensions] of Object.entries(expected)) {
    const path = projectPath(profile[kind]);
    check(existsSync(path), `${materialId} ${kind} exists`);
    const image = decodePng(path);
    check(image.width === dimensions[0] && image.height === dimensions[1], `${materialId} ${kind} is ${dimensions.join('x')}`);
    check(image.colorType === 2, `${materialId} ${kind} is RGB`);
    if (kind === 'albedo') check(edgeDelta(image) <= 0.25, `${materialId} albedo closes its tile edges (delta ${edgeDelta(image).toFixed(3)})`);
    if (kind === 'normal') {
      const red = channelStats(image, 0);
      const green = channelStats(image, 1);
      const blue = channelStats(image, 2);
      check(blue.mean >= 220, `${materialId} normal has a valid positive-Z average`);
      check(red.max - red.min >= 2 || green.max - green.min >= 2, `${materialId} normal contains surface variation`);
    }
    if (kind === 'orm') {
      const ao = channelStats(image, 0);
      const roughness = channelStats(image, 1);
      const metallic = channelStats(image, 2);
      check(ao.min >= 115 && ao.max <= 255, `${materialId} AO stays in its authored range`);
      check(Math.abs(roughness.mean / 255 - profile.roughness) <= 0.06, `${materialId} ORM roughness matches the manifest`);
      check(metallic.max - metallic.min <= 1, `${materialId} ORM metallic channel is stable`);
      check(Math.abs(metallic.mean / 255 - profile.metallic) <= 0.01, `${materialId} ORM metallic matches the manifest`);
    }
  }
}

for (const destructibleId of EXPECTED_DESTRUCTIBLES) {
  const profile = manifest.destructibles[destructibleId];
  const images = {};
  for (const state of ['intact', 'broken']) {
    const path = projectPath(profile[state]);
    check(existsSync(path), `${destructibleId} ${state} exists`);
    const image = decodePng(path);
    images[state] = { image, path };
    check(image.width === 1024 && image.height === 1024, `${destructibleId} ${state} is 1024x1024`);
    check(image.colorType === 6, `${destructibleId} ${state} is RGBA`);
    const alpha = alphaCoverage(image);
    check(alpha.visible > 0.005 && alpha.visible < 0.92, `${destructibleId} ${state} has useful transparent coverage`);
    check(alpha.partial > 0, `${destructibleId} ${state} retains antialiased alpha`);
  }
  check(fileDigest(images.intact.path) !== fileDigest(images.broken.path), `${destructibleId} intact and broken states differ`);
  check(meanPixelDelta(images.intact.image, images.broken.image) >= 2.0, `${destructibleId} states have a meaningful visual difference`);
}

for (const propId of EXPECTED_PROPS) {
  const profile = manifest.props[propId];
  const path = projectPath(profile.path);
  check(existsSync(path), `${propId} atlas exists`);
  const image = decodePng(path);
  const frames = Number(profile.hframes);
  check(Number.isInteger(frames) && frames >= 1, `${propId} declares valid hframes`);
  check(image.width === 1024 * frames && image.height === 1024, `${propId} atlas dimensions match hframes`);
  const planeHeight = Number(profile.pixel_size) * Number(profile.world_scale) * 1024;
  check(Number.isFinite(planeHeight) && planeHeight >= 0.8 && planeHeight <= 5.2, `${propId} world height is plausible (${planeHeight.toFixed(3)} m)`);
  check(image.colorType === 6, `${propId} atlas is RGBA`);
  for (let frame = 0; frame < frames; frame += 1) {
    const alpha = alphaCoverage(image, frame * 1024, (frame + 1) * 1024);
    check(alpha.visible > 0.005 && alpha.visible < 0.92, `${propId} frame ${frame} has useful transparent coverage`);
    check(alpha.partial > 0, `${propId} frame ${frame} retains antialiased alpha`);
    if (MATTE_REPAIR_PROPS.has(propId)) {
      const largestMatte = largestNeutralMatteComponent(image, frame * 1024, (frame + 1) * 1024);
      check(largestMatte < 500, `${propId} frame ${frame} has no baked neutral-white matte (largest ${largestMatte}px)`);
      const fringeRatio = neutralEdgeFringeRatio(image, frame * 1024, (frame + 1) * 1024);
      const fringeLimit = propId === 'estate_gate' ? 0.32 : 0.18;
      check(fringeRatio < fringeLimit, `${propId} frame ${frame} neutral fringe ratio stays below ${(fringeLimit * 100).toFixed(0)}% (${(fringeRatio * 100).toFixed(2)}%)`);
    }
  }
}

for (const effectId of EXPECTED_ANIMATED_EFFECTS) {
  const profile = manifest.animated_effects[effectId];
  const path = projectPath(profile.path);
  check(existsSync(path), `${effectId} animated strip exists`);
  const image = decodePng(path);
  check(image.width === 2048 && image.height === 256, `${effectId} animated strip is 2048x256`);
  check(image.colorType === 6, `${effectId} animated strip is RGBA`);
  check(Number(profile.hframes) === 8, `${effectId} declares eight horizontal frames`);
  check(Number(profile.fps) >= 6 && Number(profile.fps) <= 24, `${effectId} frame rate is plausible`);
  check(Number(profile.pixel_size) > 0 && Number(profile.world_scale) > 0, `${effectId} has positive world scale`);
  for (let frame = 0; frame < 8; frame += 1) {
    const alpha = alphaCoverage(image, frame * 256, (frame + 1) * 256);
    check(alpha.visible > 0.001 && alpha.visible < 0.85, `${effectId} frame ${frame} has useful transparency`);
    check(alpha.partial > 0, `${effectId} frame ${frame} retains antialiased alpha`);
  }
}

check(Array.isArray(provenance.assets), 'provenance contains asset records');
check(provenance.assets.length === 40, 'provenance records all 40 generated assets');
check(Array.isArray(provenance.failures) && provenance.failures.length === 0, 'provenance reports zero generation failures');
const provenanceIds = provenance.assets.map((entry) => entry.id).sort();
const allIds = [...EXPECTED_MATERIALS, ...EXPECTED_DESTRUCTIBLES, ...EXPECTED_PROPS].sort();
check(JSON.stringify(provenanceIds) === JSON.stringify(allIds), 'provenance IDs match the environment contract');
for (const entry of provenance.assets) {
  check(entry.status === 'original_fan_made', `${entry.id} records original fan-made status`);
  check(typeof entry.source_sha256 === 'string' && /^[a-f0-9]{64}$/.test(entry.source_sha256), `${entry.id} has a SHA-256 source fingerprint`);
  for (const output of Object.values(entry.outputs ?? {})) {
    const normalizedOutput = String(output).replaceAll('\\', '/');
    check(existsSync(join(root, normalizedOutput)), `${entry.id} provenance output exists: ${output}`);
  }
}

const generatedPngs = listFiles(outputRoot).filter((path) => path.toLowerCase().endsWith('.png'));
check(generatedPngs.length === 90, `generated tree contains exactly 90 PNG files (got ${generatedPngs.length})`);

if (failures.length > 0) {
  console.error(`ENVIRONMENT ASSET VERIFY FAILED: ${failures.length}/${assertions} assertions failed`);
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

const bytes = generatedPngs.reduce((sum, path) => sum + statSync(path).size, 0);
console.log(`ENVIRONMENT ASSET VERIFY PASSED: ${assertions} assertions; 20 materials, 33 nodes, 6 destructibles, 14 props, 4 animated effects; ${(bytes / 1024 / 1024).toFixed(2)} MiB source PNG`);
