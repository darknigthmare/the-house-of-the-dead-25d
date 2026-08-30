import { createHash } from 'node:crypto';
import { existsSync, readFileSync } from 'node:fs';
import { isAbsolute, join, relative, resolve } from 'node:path';
import { inflateSync } from 'node:zlib';

const root = resolve(import.meta.dirname, '..');
const GRID = 8;
const CELL_SIZE = 256;
const TRANSPARENT_GUTTER = 12;
const EXPECTED_SIZE = GRID * CELL_SIZE;
const MIRROR_PAIRS = [
  { name: 'front_diagonal', leftRow: 1, rightRow: 7 },
  { name: 'profile', leftRow: 2, rightRow: 6 },
  { name: 'back_diagonal', leftRow: 3, rightRow: 5 },
];
const NEUTRAL_FRINGE_MIN_CHANNEL = 165;
const NEUTRAL_FRINGE_MAX_SPREAD = 50;
const MAX_NEUTRAL_FRINGE_PIXELS_PER_CELL = 24;
const PROFILE_ID = 'sam_a1';
const DEFAULT_MANIFEST_PATH = join(root, 'data', 'assets', 'sprite_manifest_v3.json');

function projectRelative(path) {
  const value = relative(root, path);
  if (value.startsWith('..') || isAbsolute(value)) {
    throw new Error(`Sprite V3 path must stay inside the project: ${path}`);
  }
  return value.replaceAll('\\', '/');
}

function parseArguments(argv) {
  let clip = 'locomotion';
  let clipExplicit = false;
  let atlasOverride = '';
  let manifestOverride = '';
  let allExplicit = false;
  let selfTestManifest = false;
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === '--clip') {
      clip = argv[index + 1] ?? '';
      clipExplicit = true;
      index += 1;
    } else if (argument === '--atlas') {
      atlasOverride = argv[index + 1] ?? '';
      index += 1;
    } else if (argument === '--manifest') {
      manifestOverride = argv[index + 1] ?? '';
      index += 1;
    } else if (argument === '--all' || argument === '--accepted') {
      allExplicit = true;
    } else if (argument === '--self-test-manifest') {
      selfTestManifest = true;
    } else {
      throw new Error(`Unknown Sprite V3 verification argument: ${argument}`);
    }
  }
  if (!/^[a-z][a-z0-9_]*$/.test(clip)) {
    throw new Error(`Invalid Sprite V3 clip ID: ${clip}`);
  }
  if (allExplicit && clipExplicit) {
    throw new Error('Sprite V3 --clip cannot be combined with --all or --accepted');
  }
  if (allExplicit && atlasOverride !== '') {
    throw new Error('Sprite V3 --atlas cannot be combined with --all or --accepted');
  }
  if (manifestOverride !== '' && (clipExplicit || atlasOverride !== '')) {
    throw new Error('Sprite V3 --manifest can only be used with manifest-driven all verification');
  }
  if (selfTestManifest && (clipExplicit || atlasOverride !== '' || manifestOverride !== '' || allExplicit)) {
    throw new Error('Sprite V3 --self-test-manifest cannot be combined with other arguments');
  }
  const verifyAll = allExplicit || (!clipExplicit && atlasOverride === '');
  return {
    clip,
    atlasOverride,
    manifestOverride,
    verifyAll,
    selfTestManifest,
  };
}

function resolveAtlasPath(clip, atlasOverride = '') {
  const atlasPath = atlasOverride === ''
    ? join(root, 'assets', 'sprites_v3', 'enemies', 'sam_a1', `sam_a1__v3__${clip}__8dirx8f.png`)
    : resolve(root, atlasOverride);
  projectRelative(atlasPath);
  return atlasPath;
}

function resolveManifestPath(manifestOverride = '') {
  const manifestPath = manifestOverride === ''
    ? DEFAULT_MANIFEST_PATH
    : resolve(root, manifestOverride);
  projectRelative(manifestPath);
  return manifestPath;
}

function isRecord(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function resolveResourcePath(resourcePath, clip) {
  if (typeof resourcePath !== 'string' || !resourcePath.startsWith('res://')) {
    throw new Error(`Manifest clip ${clip} path must use res://`);
  }
  const projectPath = resourcePath.slice('res://'.length);
  const segments = projectPath.split('/');
  if (
    projectPath === ''
    || segments.some((segment) => segment === '' || segment === '.' || segment === '..')
    || /[\\:\u0000-\u001f?#]/u.test(projectPath)
  ) {
    throw new Error(`Manifest clip ${clip} has a non-canonical res:// path: ${resourcePath}`);
  }
  if (!projectPath.toLowerCase().endsWith('.png')) {
    throw new Error(`Manifest clip ${clip} must publish a PNG atlas: ${resourcePath}`);
  }
  const atlasPath = resolve(root, ...segments);
  projectRelative(atlasPath);
  return atlasPath;
}

function parseManifest(manifestPath) {
  if (!existsSync(manifestPath)) {
    throw new Error(`Missing Sprite V3 manifest: ${manifestPath}`);
  }
  let manifest;
  try {
    manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  } catch (error) {
    throw new Error(
      `Invalid Sprite V3 manifest JSON ${manifestPath}: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
  if (!isRecord(manifest) || manifest.schema_version !== 3 || !Array.isArray(manifest.profiles)) {
    throw new Error('Sprite V3 manifest must expose schema_version=3 and a profiles array');
  }
  return manifest;
}

function resolveManifestJobs(manifest) {
  const matchingProfiles = manifest.profiles.filter(
    (profile) => isRecord(profile) && profile.id === PROFILE_ID,
  );
  if (matchingProfiles.length !== 1) {
    throw new Error(
      `Sprite V3 manifest must expose exactly one ${PROFILE_ID} profile, got ${matchingProfiles.length}`,
    );
  }
  const clips = matchingProfiles[0].clips;
  if (!isRecord(clips) || Object.keys(clips).length === 0) {
    throw new Error(`Sprite V3 manifest profile ${PROFILE_ID} must publish at least one clip`);
  }

  const jobs = [];
  const failures = [];
  const seenClips = new Set();
  const seenPaths = new Map();
  for (const [clip, contract] of Object.entries(clips)) {
    try {
      if (!/^[a-z][a-z0-9_]*$/.test(clip) || seenClips.has(clip)) {
        throw new Error(`Manifest contains an invalid or duplicate clip ID: ${clip}`);
      }
      seenClips.add(clip);
      if (!isRecord(contract)) {
        throw new Error(`Manifest clip ${clip} contract must be an object`);
      }
      if (contract.frame_count !== GRID) {
        throw new Error(`Manifest clip ${clip} frame_count must be ${GRID}`);
      }
      if (
        typeof contract.display_scale !== 'number'
        || !Number.isFinite(contract.display_scale)
        || contract.display_scale < 0.75
        || contract.display_scale > 1.35
      ) {
        throw new Error(`Manifest clip ${clip} display_scale must be from 0.75 to 1.35`);
      }
      if (typeof contract.sha256 !== 'string' || !/^[0-9a-f]{64}$/.test(contract.sha256)) {
        throw new Error(`Manifest clip ${clip} sha256 must be 64 lowercase hexadecimal characters`);
      }
      const atlasPath = resolveResourcePath(contract.path, clip);
      const atlasRelative = projectRelative(atlasPath);
      const earlierClip = seenPaths.get(atlasRelative);
      if (earlierClip != null) {
        throw new Error(
          `Manifest clips ${earlierClip} and ${clip} publish the duplicate atlas path ${contract.path}`,
        );
      }
      seenPaths.set(atlasRelative, clip);
      jobs.push({
        clip,
        atlasPath,
        expectedSha256: contract.sha256,
        displayScale: contract.display_scale,
        resourcePath: contract.path,
      });
    } catch (error) {
      failures.push({
        clip,
        path: isRecord(contract) && typeof contract.path === 'string' ? contract.path : '',
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }
  return { jobs, failures };
}

function sha256(bytes) {
  return createHash('sha256').update(bytes).digest('hex');
}

function paeth(left, up, upLeft) {
  const estimate = left + up - upLeft;
  const leftDistance = Math.abs(estimate - left);
  const upDistance = Math.abs(estimate - up);
  const diagonalDistance = Math.abs(estimate - upLeft);
  return leftDistance <= upDistance && leftDistance <= diagonalDistance
    ? left
    : upDistance <= diagonalDistance
      ? up
      : upLeft;
}

function decodeRgbaPng(png, path) {
  if (png.length < 33 || png.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') {
    throw new Error(`V3 atlas has an invalid PNG signature: ${path}`);
  }
  let offset = 8;
  let width = 0;
  let height = 0;
  let sawHeader = false;
  let sawEnd = false;
  const idat = [];
  while (offset + 12 <= png.length) {
    const length = png.readUInt32BE(offset);
    const chunkEnd = offset + length + 12;
    if (chunkEnd > png.length) throw new Error(`V3 atlas has a truncated PNG chunk: ${path}`);
    const type = png.subarray(offset + 4, offset + 8).toString('ascii');
    const data = png.subarray(offset + 8, offset + 8 + length);
    if (type === 'IHDR') {
      if (length !== 13 || sawHeader) throw new Error(`V3 atlas has an invalid PNG header: ${path}`);
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      if (
        width <= 0
        || height <= 0
        || data[8] !== 8
        || data[9] !== 6
        || data[10] !== 0
        || data[11] !== 0
        || data[12] !== 0
      ) {
        throw new Error(`V3 atlas must be non-interlaced 8-bit RGBA PNG: ${path}`);
      }
      sawHeader = true;
    } else if (type === 'IDAT') {
      idat.push(data);
    } else if (type === 'IEND') {
      sawEnd = true;
      break;
    }
    offset = chunkEnd;
  }
  if (!sawHeader || !sawEnd || idat.length === 0) {
    throw new Error(`V3 atlas PNG structure is incomplete: ${path}`);
  }

  const bytesPerPixel = 4;
  const stride = width * bytesPerPixel;
  const packed = inflateSync(Buffer.concat(idat));
  if (packed.length !== (stride + 1) * height) {
    throw new Error(`V3 atlas has an unexpected scanline payload: ${path}`);
  }
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
      else throw new Error(`V3 atlas uses unsupported PNG filter ${filter}: ${path}`);
      rgba[targetOffset + x] = value & 0xff;
    }
  }
  return { width, height, rgba };
}

function extractCell(raw, atlasWidth, channels, row, column) {
  const result = Buffer.allocUnsafe(CELL_SIZE * CELL_SIZE * channels);
  let target = 0;
  for (let y = 0; y < CELL_SIZE; y += 1) {
    const source = ((row * CELL_SIZE + y) * atlasWidth + column * CELL_SIZE) * channels;
    raw.copy(result, target, source, source + CELL_SIZE * channels);
    target += CELL_SIZE * channels;
  }
  return result;
}

function mirrorEquals(left, right) {
  for (let y = 0; y < CELL_SIZE; y += 1) {
    for (let x = 0; x < CELL_SIZE; x += 1) {
      const leftOffset = (y * CELL_SIZE + x) * 4;
      const rightOffset = (y * CELL_SIZE + CELL_SIZE - 1 - x) * 4;
      for (let channel = 0; channel < 4; channel += 1) {
        if (left[leftOffset + channel] !== right[rightOffset + channel]) return false;
      }
    }
  }
  return true;
}

function isNeutralFringe(red, green, blue) {
  const minimum = Math.min(red, green, blue);
  const maximum = Math.max(red, green, blue);
  return minimum >= NEUTRAL_FRINGE_MIN_CHANNEL && maximum - minimum <= NEUTRAL_FRINGE_MAX_SPREAD;
}

function touchesTransparency(cell, x, y) {
  if (x === 0 || y === 0 || x + 1 === CELL_SIZE || y + 1 === CELL_SIZE) return true;
  for (let neighborY = y - 1; neighborY <= y + 1; neighborY += 1) {
    for (let neighborX = x - 1; neighborX <= x + 1; neighborX += 1) {
      if (neighborX === x && neighborY === y) continue;
      if (cell[(neighborY * CELL_SIZE + neighborX) * 4 + 3] === 0) return true;
    }
  }
  return false;
}

function verifyAtlas(clip, atlasPath, expectedSha256 = '', displayScale = 1.0) {
if (!existsSync(atlasPath)) throw new Error(`Missing Sam V3 ${clip} atlas: ${atlasPath}`);
const bytes = readFileSync(atlasPath);
const actualSha256 = sha256(bytes);
if (expectedSha256 !== '' && actualSha256 !== expectedSha256) {
  throw new Error(
    `V3 ${clip} SHA-256 mismatch: manifest=${expectedSha256}, atlas=${actualSha256}`,
  );
}
const decoded = decodeRgbaPng(bytes, atlasPath);
if (decoded.width !== EXPECTED_SIZE || decoded.height !== EXPECTED_SIZE) {
  throw new Error(`V3 atlas must be ${EXPECTED_SIZE}x${EXPECTED_SIZE}, got ${decoded.width}x${decoded.height}`);
}

const cells = [];
let globalTransparent = 0;
let globalOpaque = 0;
let globalPartial = 0;
for (let row = 0; row < GRID; row += 1) {
  for (let column = 0; column < GRID; column += 1) {
    const cell = extractCell(decoded.rgba, decoded.width, 4, row, column);
    let visible = 0;
    let gutterVisible = 0;
    let minimumX = CELL_SIZE;
    let minimumY = CELL_SIZE;
    let maximumX = -1;
    let maximumY = -1;
    let neutralFringe = 0;
    for (let y = 0; y < CELL_SIZE; y += 1) {
      for (let x = 0; x < CELL_SIZE; x += 1) {
        const alpha = cell[(y * CELL_SIZE + x) * 4 + 3];
        if (alpha === 0) {
          globalTransparent += 1;
          continue;
        }
        if (alpha === 255) globalOpaque += 1;
        else globalPartial += 1;
        if (
          isNeutralFringe(
            cell[(y * CELL_SIZE + x) * 4],
            cell[(y * CELL_SIZE + x) * 4 + 1],
            cell[(y * CELL_SIZE + x) * 4 + 2],
          )
          && touchesTransparency(cell, x, y)
        ) {
          neutralFringe += 1;
        }
        visible += 1;
        minimumX = Math.min(minimumX, x);
        minimumY = Math.min(minimumY, y);
        maximumX = Math.max(maximumX, x);
        maximumY = Math.max(maximumY, y);
        if (
          x < TRANSPARENT_GUTTER
          || y < TRANSPARENT_GUTTER
          || x >= CELL_SIZE - TRANSPARENT_GUTTER
          || y >= CELL_SIZE - TRANSPARENT_GUTTER
        ) {
          gutterVisible += 1;
        }
      }
    }
    if (visible < 80 || maximumX < minimumX || maximumY < minimumY) {
      throw new Error(`V3 cell row=${row}, column=${column} is empty or unreadable (${visible} pixels)`);
    }
    if (gutterVisible !== 0) {
      throw new Error(`V3 cell row=${row}, column=${column} violates the ${TRANSPARENT_GUTTER}px gutter (${gutterVisible} pixels)`);
    }
    if (maximumY !== 241) {
      throw new Error(`V3 cell row=${row}, column=${column} foot anchor is ${maximumY}, expected 241`);
    }
    if (neutralFringe > MAX_NEUTRAL_FRINGE_PIXELS_PER_CELL) {
      throw new Error(
        `V3 cell row=${row}, column=${column} retains ${neutralFringe} neutral fringe pixels (maximum ${MAX_NEUTRAL_FRINGE_PIXELS_PER_CELL})`,
      );
    }
    cells.push({
      row,
      column,
      bytes: cell,
      hash: sha256(cell),
      visible,
      neutralFringe,
      bbox: [minimumX, minimumY, maximumX - minimumX + 1, maximumY - minimumY + 1],
    });
  }
}

if (cells.length !== 64) throw new Error(`V3 atlas must expose 64 cells, got ${cells.length}`);
const directionDistinctCounts = [];
for (let row = 0; row < GRID; row += 1) {
  const rowCells = cells.filter((cell) => cell.row === row);
  const distinct = new Set(rowCells.map((cell) => cell.hash)).size;
  if (distinct !== GRID) throw new Error(`V3 ${clip} direction row ${row} has ${distinct}/8 distinct frames`);
  directionDistinctCounts.push(distinct);
}

const mirrorMatches = {};
for (const pair of MIRROR_PAIRS) {
  let matches = 0;
  for (let frame = 0; frame < GRID; frame += 1) {
    const left = cells.find((cell) => cell.row === pair.leftRow && cell.column === frame);
    const right = cells.find((cell) => cell.row === pair.rightRow && cell.column === frame);
    if (left == null || right == null) {
      throw new Error(`Missing ${pair.name} V3 ${clip} frame ${frame}`);
    }
    if (mirrorEquals(left.bytes, right.bytes)) matches += 1;
  }
  if (matches !== 0) {
    throw new Error(`V3 ${clip} ${pair.name} right row contains ${matches}/8 mirrored copies of the left row`);
  }
  mirrorMatches[pair.name] = matches;
}

if (globalTransparent === 0 || globalOpaque === 0 || globalPartial === 0) {
  throw new Error(`V3 alpha contract failed: transparent=${globalTransparent}, partial=${globalPartial}, opaque=${globalOpaque}`);
}

const visibleValues = cells.map((cell) => cell.visible);
const neutralFringeValues = cells.map((cell) => cell.neutralFringe);
const bboxWidthValues = cells.map((cell) => cell.bbox[2]);
const bboxHeightValues = cells.map((cell) => cell.bbox[3]);
const averageRounded = (values) => Math.round(
  values.reduce((sum, value) => sum + value, 0) / values.length,
);
const uniqueAtlasCells = new Set(cells.map((cell) => cell.hash)).size;
const heightAverageByFrame = Array.from({ length: GRID }, (_, column) => averageRounded(
  cells.filter((cell) => cell.column === column).map((cell) => cell.bbox[3]),
));
if (uniqueAtlasCells !== GRID * GRID) {
  throw new Error(`V3 ${clip} atlas has ${uniqueAtlasCells}/${GRID * GRID} unique authored cells`);
}
const report = {
  actor_id: 'sam_a1',
  contract_version: 3,
  clip,
  display_scale: displayScale,
  display_scaled_frame0_height: Math.round(heightAverageByFrame[0] * displayScale),
  path: projectRelative(atlasPath),
  sha256: actualSha256,
  ...(expectedSha256 === '' ? {} : { declared_sha256: expectedSha256 }),
  bytes: bytes.length,
  dimensions: [decoded.width, decoded.height],
  channels: 4,
  has_alpha: true,
  cell_count: cells.length,
  unique_atlas_cells: uniqueAtlasCells,
  distinct_frames_per_direction: directionDistinctCounts,
  mirror_matches: mirrorMatches,
  visible_pixels_min: Math.min(...visibleValues),
  visible_pixels_max: Math.max(...visibleValues),
  visible_pixels_average: averageRounded(visibleValues),
  silhouette_bbox_px: {
    width_min: Math.min(...bboxWidthValues),
    width_max: Math.max(...bboxWidthValues),
    width_average: averageRounded(bboxWidthValues),
    height_min: Math.min(...bboxHeightValues),
    height_max: Math.max(...bboxHeightValues),
    height_average: averageRounded(bboxHeightValues),
    height_average_by_direction: Array.from({ length: GRID }, (_, row) => averageRounded(
      cells.filter((cell) => cell.row === row).map((cell) => cell.bbox[3]),
    )),
    height_average_by_frame: heightAverageByFrame,
  },
  alpha_pixels: {
    transparent: globalTransparent,
    partial: globalPartial,
    opaque: globalOpaque,
  },
  neutral_fringe: {
    minimum_channel: NEUTRAL_FRINGE_MIN_CHANNEL,
    maximum_channel_spread: NEUTRAL_FRINGE_MAX_SPREAD,
    maximum_allowed_per_cell: MAX_NEUTRAL_FRINGE_PIXELS_PER_CELL,
    detected_total: neutralFringeValues.reduce((sum, value) => sum + value, 0),
    detected_max_per_cell: Math.max(...neutralFringeValues),
  },
  transparent_gutter: TRANSPARENT_GUTTER,
  foot_anchor_y: 241,
};
return report;
}

function cloneJson(value) {
  return JSON.parse(JSON.stringify(value));
}

function assertSelfTest(condition, message) {
  if (!condition) throw new Error(`Sprite V3 manifest self-test failed: ${message}`);
}

function runManifestSelfTest() {
  const manifest = parseManifest(DEFAULT_MANIFEST_PATH);
  const baseline = resolveManifestJobs(manifest);
  assertSelfTest(baseline.failures.length === 0, 'the current manifest must be structurally valid');
  assertSelfTest(baseline.jobs.length >= 2, 'at least two published clips are required for duplicate checks');

  const hashManifest = cloneJson(manifest);
  const hashClip = Object.keys(
    hashManifest.profiles.find((profile) => isRecord(profile) && profile.id === PROFILE_ID).clips,
  )[0];
  hashManifest.profiles.find((profile) => isRecord(profile) && profile.id === PROFILE_ID)
    .clips[hashClip].sha256 = '0'.repeat(64);
  const hashJobs = resolveManifestJobs(hashManifest);
  assertSelfTest(hashJobs.failures.length === 0, 'a syntactically valid altered hash must reach byte verification');
  let hashRejected = false;
  try {
    const job = hashJobs.jobs.find((candidate) => candidate.clip === hashClip);
    verifyAtlas(job.clip, job.atlasPath, job.expectedSha256, job.displayScale);
  } catch (error) {
    hashRejected = error instanceof Error && error.message.includes('SHA-256 mismatch');
  }
  assertSelfTest(hashRejected, 'an altered declared hash was not rejected');

  const scaleManifest = cloneJson(manifest);
  const scaleProfile = scaleManifest.profiles.find(
    (profile) => isRecord(profile) && profile.id === PROFILE_ID,
  );
  scaleProfile.clips[hashClip].display_scale = 4;
  const scaleResult = resolveManifestJobs(scaleManifest);
  assertSelfTest(
    scaleResult.failures.some((failure) => failure.error.includes('display_scale')),
    'an unsafe display scale was not rejected',
  );

  const pathManifest = cloneJson(manifest);
  const pathProfile = pathManifest.profiles.find(
    (profile) => isRecord(profile) && profile.id === PROFILE_ID,
  );
  pathProfile.clips[hashClip].path = 'res://../outside.png';
  const pathResult = resolveManifestJobs(pathManifest);
  assertSelfTest(
    pathResult.failures.some(
      (failure) => failure.clip === hashClip && failure.error.includes('non-canonical res:// path'),
    ),
    'a path traversal was not rejected',
  );

  const duplicateManifest = cloneJson(manifest);
  const duplicateProfile = duplicateManifest.profiles.find(
    (profile) => isRecord(profile) && profile.id === PROFILE_ID,
  );
  const duplicateClips = Object.keys(duplicateProfile.clips);
  duplicateProfile.clips[duplicateClips[1]].path = duplicateProfile.clips[duplicateClips[0]].path;
  const duplicateResult = resolveManifestJobs(duplicateManifest);
  assertSelfTest(
    duplicateResult.failures.some((failure) => failure.error.includes('duplicate atlas path')),
    'two published clips sharing one atlas path were not rejected',
  );

  const duplicateProfileManifest = cloneJson(manifest);
  duplicateProfileManifest.profiles.push(cloneJson(
    duplicateProfileManifest.profiles.find(
      (profile) => isRecord(profile) && profile.id === PROFILE_ID,
    ),
  ));
  let duplicateProfileRejected = false;
  try {
    resolveManifestJobs(duplicateProfileManifest);
  } catch (error) {
    duplicateProfileRejected = error instanceof Error && error.message.includes('exactly one');
  }
  assertSelfTest(duplicateProfileRejected, 'a duplicate sam_a1 profile was not rejected');

  console.log(JSON.stringify({
    ok: true,
    manifest: projectRelative(DEFAULT_MANIFEST_PATH),
    profile: PROFILE_ID,
    published_clip_count: baseline.jobs.length,
    checks: {
      altered_sha256_rejected: true,
      unsafe_display_scale_rejected: true,
      path_traversal_rejected: true,
      duplicate_atlas_path_rejected: true,
      duplicate_profile_rejected: true,
    },
  }, null, 2));
}

const argumentsValue = parseArguments(process.argv.slice(2));
if (argumentsValue.selfTestManifest) {
  runManifestSelfTest();
} else {
  const reports = [];
  const failures = [];
  let manifestPath = null;
  let jobs;
  if (argumentsValue.verifyAll) {
    manifestPath = resolveManifestPath(argumentsValue.manifestOverride);
    const manifestJobs = resolveManifestJobs(parseManifest(manifestPath));
    jobs = manifestJobs.jobs;
    failures.push(...manifestJobs.failures);
  } else {
    jobs = [{
      clip: argumentsValue.clip,
      atlasPath: resolveAtlasPath(argumentsValue.clip, argumentsValue.atlasOverride),
      expectedSha256: '',
      displayScale: 1.0,
      resourcePath: '',
    }];
  }

  for (const job of jobs) {
    try {
      const report = verifyAtlas(job.clip, job.atlasPath, job.expectedSha256, job.displayScale);
      reports.push(report);
      console.log(
        `SPRITE V3 OK: Sam ${job.clip} ${report.cell_count} unique cells, 8 distinct frames per direction, 0 mirrored directional pairs.`,
      );
    } catch (error) {
      failures.push({
        clip: job.clip,
        path: job.resourcePath === '' ? projectRelative(job.atlasPath) : job.resourcePath,
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  if (argumentsValue.verifyAll && failures.length === 0 && reports.length > 1) {
    const apparentHeights = reports.map((report) => report.display_scaled_frame0_height);
    const scaleSpread = Math.max(...apparentHeights) - Math.min(...apparentHeights);
    if (scaleSpread > 2) {
      failures.push({
        clip: 'actor_scale_contract',
        path: projectRelative(manifestPath),
        error: `V3 actor-level calibrated frame-0 height spread is ${scaleSpread}px (maximum 2px)`,
      });
    }
  }

  if (argumentsValue.verifyAll) {
    console.log(JSON.stringify({
      ok: failures.length === 0,
      manifest: projectRelative(manifestPath),
      profile: PROFILE_ID,
      published_clip_count: jobs.length + failures.filter(
        (failure) => !jobs.some((job) => job.clip === failure.clip),
      ).length,
      verified: reports,
      failed: failures,
    }, null, 2));
  } else if (reports.length === 1) {
    console.log(JSON.stringify(reports[0], null, 2));
  } else {
    console.log(JSON.stringify({ ok: false, verified: reports, failed: failures }, null, 2));
  }
  if (failures.length > 0) process.exitCode = 1;
}
