import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, renameSync, unlinkSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, isAbsolute, join, relative, resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const sourceRoot = join(root, 'reports', 'runtime', 'directional-sources-v3', 'sam_a1');
const outputRoot = join(root, 'assets', 'sprites_v3', 'enemies', 'sam_a1');
const sharpPath = join(root, '.tools', 'image-pipeline', 'node_modules', 'sharp');

const JOBS = {
  locomotion: [
    { file: 'sam_a1__v3__locomotion__8dirx8f.openai.png', directionOffset: 0, directionCount: 8 },
  ],
  idle: [
    {
      file: 'sam_a1__v3__idle__front_half__4dirx8f.openai.png',
      directionOffset: 0,
      directionCount: 4,
    },
    {
      file: 'sam_a1__v3__idle__back_half__4dirx8f.openai.png',
      directionOffset: 4,
      directionCount: 4,
    },
  ],
  attack: [
    { file: 'sam_a1__v3__attack__8dirx8f.openai-v2.png', directionOffset: 0, directionCount: 8 },
  ],
  hit_recoil: [
    { file: 'sam_a1__v3__hit_recoil__8dirx8f.openai-v2.png', directionOffset: 0, directionCount: 8 },
  ],
  death_fall: [
    {
      file: 'sam_a1__v3__death_fall__front_half__4dirx8f.openai.png',
      directionOffset: 0,
      directionCount: 4,
    },
    {
      file: 'sam_a1__v3__death_fall__back_half__4dirx8f.openai.png',
      directionOffset: 4,
      directionCount: 4,
    },
  ],
};
const ACCEPTED_CLIPS = ['locomotion', 'idle', 'attack', 'hit_recoil', 'death_fall'];

const GRID = 8;
const CELL_SIZE = 256;
const TRANSPARENT_GUTTER = 12;
const ART_MARGIN = 2;
const ART_INSET = TRANSPARENT_GUTTER + ART_MARGIN;
const FOOT_ANCHOR_Y = CELL_SIZE - ART_INSET - 1;
const USABLE_SIZE = CELL_SIZE - ART_INSET * 2;
const BACKGROUND_MIN_CHANNEL = 210;
const BACKGROUND_MAX_SPREAD = 30;
const MIN_VISIBLE_SOURCE_PIXELS = 80;
const MIN_ACTOR_COMPONENT_PIXELS = 600;
const MIN_ACTOR_COMPONENT_HEIGHT = 20;
const NEUTRAL_FRINGE_MIN_CHANNEL = 165;
const NEUTRAL_FRINGE_MAX_SPREAD = 50;
const NEUTRAL_FRINGE_PASSES = 2;
const NEUTRAL_FRINGE_MAX_OUTPUT_CHANNEL = 104;

if (!existsSync(sharpPath)) {
  throw new Error(`Missing local Sharp art dependency: ${sharpPath}`);
}

const require = createRequire(import.meta.url);
const sharp = require(sharpPath);

function projectRelative(path) {
  const value = relative(root, path);
  if (value.startsWith('..') || isAbsolute(value)) {
    throw new Error(`Sprite V3 path must stay inside the project: ${path}`);
  }
  return value.replaceAll('\\', '/');
}

async function replaceAtomically(tempPath, outputPath) {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    try {
      renameSync(tempPath, outputPath);
      return;
    } catch (error) {
      const retryable = error instanceof Error
        && ['EBUSY', 'EACCES', 'EPERM'].includes(error.code);
      if (!retryable || attempt === 4) throw error;
      await new Promise((resolveDelay) => setTimeout(resolveDelay, 80 * (attempt + 1)));
    }
  }
}

function parseArguments(argv) {
  let clip = 'locomotion';
  let clipExplicit = false;
  let sourceOverride = '';
  let buildAll = false;
  let buildAccepted = false;
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === '--clip') {
      clip = argv[index + 1] ?? '';
      clipExplicit = true;
      index += 1;
    } else if (argument === '--source') {
      sourceOverride = argv[index + 1] ?? '';
      index += 1;
    } else if (argument === '--all') {
      buildAll = true;
    } else if (argument === '--accepted') {
      buildAccepted = true;
    } else {
      throw new Error(`Unknown Sprite V3 build argument: ${argument}`);
    }
  }
  if (!/^[a-z][a-z0-9_]*$/.test(clip)) {
    throw new Error(`Invalid Sprite V3 clip ID: ${clip}`);
  }
  if (buildAll && buildAccepted) {
    throw new Error('Sprite V3 --all and --accepted are mutually exclusive');
  }
  if ((buildAll || buildAccepted) && clipExplicit) {
    throw new Error('Sprite V3 --clip cannot be combined with --all or --accepted');
  }
  if ((buildAll || buildAccepted) && sourceOverride !== '') {
    throw new Error('Sprite V3 --source cannot be combined with --all or --accepted');
  }
  return { clip, sourceOverride, buildAll, buildAccepted };
}

function resolveJob(clip, sourceOverride = '') {
  if (sourceOverride !== '') {
    return [{
      path: resolve(root, sourceOverride),
      directionOffset: 0,
      directionCount: GRID,
    }];
  }
  const definition = JOBS[clip];
  if (definition == null) {
    throw new Error(`Unknown Sprite V3 clip job: ${clip}`);
  }
  return definition.map((source) => ({
    path: join(sourceRoot, source.file),
    directionOffset: source.directionOffset,
    directionCount: source.directionCount,
  }));
}

function sha256(bytes) {
  return createHash('sha256').update(bytes).digest('hex');
}

function isCheckerboardBackground(red, green, blue) {
  const minimum = Math.min(red, green, blue);
  const maximum = Math.max(red, green, blue);
  return minimum >= BACKGROUND_MIN_CHANNEL && maximum - minimum <= BACKGROUND_MAX_SPREAD;
}

function floodFillBorderBackground(rgb, width, height) {
  const pixelCount = width * height;
  const removed = new Uint8Array(pixelCount);
  const queued = new Uint8Array(pixelCount);
  const queue = new Int32Array(pixelCount);
  let head = 0;
  let tail = 0;

  const enqueue = (index) => {
    if (queued[index] !== 0) return;
    const offset = index * 3;
    if (!isCheckerboardBackground(rgb[offset], rgb[offset + 1], rgb[offset + 2])) return;
    queued[index] = 1;
    queue[tail] = index;
    tail += 1;
  };

  for (let x = 0; x < width; x += 1) {
    enqueue(x);
    enqueue((height - 1) * width + x);
  }
  for (let y = 1; y < height - 1; y += 1) {
    enqueue(y * width);
    enqueue(y * width + width - 1);
  }

  while (head < tail) {
    const index = queue[head];
    head += 1;
    removed[index] = 1;
    const x = index % width;
    const y = Math.floor(index / width);
    if (x > 0) enqueue(index - 1);
    if (x + 1 < width) enqueue(index + 1);
    if (y > 0) enqueue(index - width);
    if (y + 1 < height) enqueue(index + width);
  }

  const rgba = Buffer.alloc(width * height * 4);
  let visible = 0;
  let removedCount = 0;
  let minimumX = width;
  let minimumY = height;
  let maximumX = -1;
  let maximumY = -1;
  for (let index = 0; index < pixelCount; index += 1) {
    const sourceOffset = index * 3;
    const targetOffset = index * 4;
    rgba[targetOffset] = rgb[sourceOffset];
    rgba[targetOffset + 1] = rgb[sourceOffset + 1];
    rgba[targetOffset + 2] = rgb[sourceOffset + 2];
    if (removed[index] !== 0) {
      rgba[targetOffset + 3] = 0;
      removedCount += 1;
      continue;
    }
    rgba[targetOffset + 3] = 255;
    visible += 1;
    const x = index % width;
    const y = Math.floor(index / width);
    minimumX = Math.min(minimumX, x);
    minimumY = Math.min(minimumY, y);
    maximumX = Math.max(maximumX, x);
    maximumY = Math.max(maximumY, y);
  }

  if (visible < MIN_VISIBLE_SOURCE_PIXELS || maximumX < minimumX || maximumY < minimumY) {
    throw new Error(`Flood-fill produced an empty source cell (${width}x${height}, visible=${visible})`);
  }
  if (visible > pixelCount * 0.82) {
    throw new Error(`Flood-fill left too much checkerboard (${visible}/${pixelCount} pixels remain)`);
  }

  return {
    rgba,
    width,
    height,
    bbox: {
      x: minimumX,
      y: minimumY,
      width: maximumX - minimumX + 1,
      height: maximumY - minimumY + 1,
    },
    visible,
    removed: removedCount,
  };
}

function findForegroundComponents(rgba, width, height) {
  const pixelCount = width * height;
  const visited = new Uint8Array(pixelCount);
  const queue = new Int32Array(pixelCount);
  const components = [];

  for (let seed = 0; seed < pixelCount; seed += 1) {
    if (visited[seed] !== 0 || rgba[seed * 4 + 3] === 0) continue;
    let head = 0;
    let tail = 0;
    let sumX = 0;
    let sumY = 0;
    let minimumX = width;
    let minimumY = height;
    let maximumX = -1;
    let maximumY = -1;
    const pixels = [];
    visited[seed] = 1;
    queue[tail] = seed;
    tail += 1;

    while (head < tail) {
      const index = queue[head];
      head += 1;
      pixels.push(index);
      const x = index % width;
      const y = Math.floor(index / width);
      sumX += x;
      sumY += y;
      minimumX = Math.min(minimumX, x);
      minimumY = Math.min(minimumY, y);
      maximumX = Math.max(maximumX, x);
      maximumY = Math.max(maximumY, y);

      const minimumNeighborX = Math.max(0, x - 1);
      const maximumNeighborX = Math.min(width - 1, x + 1);
      const minimumNeighborY = Math.max(0, y - 1);
      const maximumNeighborY = Math.min(height - 1, y + 1);
      for (let neighborY = minimumNeighborY; neighborY <= maximumNeighborY; neighborY += 1) {
        for (let neighborX = minimumNeighborX; neighborX <= maximumNeighborX; neighborX += 1) {
          const neighbor = neighborY * width + neighborX;
          if (visited[neighbor] !== 0 || rgba[neighbor * 4 + 3] === 0) continue;
          visited[neighbor] = 1;
          queue[tail] = neighbor;
          tail += 1;
        }
      }
    }

    components.push({
      pixels,
      pixelCount: pixels.length,
      bbox: {
        x: minimumX,
        y: minimumY,
        width: maximumX - minimumX + 1,
        height: maximumY - minimumY + 1,
      },
      centerX: sumX / pixels.length,
      centerY: sumY / pixels.length,
    });
  }
  return components;
}

function selectAndOrderActorComponents(components, sourceWidth, sourceHeight, directionCount) {
  const candidates = components
    .filter((component) => (
      component.pixelCount >= MIN_ACTOR_COMPONENT_PIXELS
      && component.bbox.height >= MIN_ACTOR_COMPONENT_HEIGHT
    ))
    .sort((left, right) => right.pixelCount - left.pixelCount);
  const expectedCount = directionCount * GRID;
  if (candidates.length < expectedCount) {
    throw new Error(`Detected only ${candidates.length}/${expectedCount} substantial actor silhouettes`);
  }

  const selected = candidates.slice(0, expectedCount);
  const rejectedLargest = candidates[expectedCount];
  const selectedSmallest = selected.at(-1);
  if (rejectedLargest != null && selectedSmallest.pixelCount < rejectedLargest.pixelCount * 1.5) {
    throw new Error(
      `Ambiguous actor segmentation: selected minimum=${selectedSmallest.pixelCount}, rejected maximum=${rejectedLargest.pixelCount}`,
    );
  }

  selected.sort((left, right) => left.centerY - right.centerY);
  const ordered = [];
  const rowCenters = [];
  for (let row = 0; row < directionCount; row += 1) {
    const rowComponents = selected.slice(row * GRID, (row + 1) * GRID)
      .sort((left, right) => left.centerX - right.centerX);
    const centerYs = rowComponents.map((component) => component.centerY);
    const rowSpread = Math.max(...centerYs) - Math.min(...centerYs);
    if (rowSpread > sourceHeight / directionCount * 0.45) {
      throw new Error(`Direction row ${row} is spatially ambiguous (vertical spread=${rowSpread.toFixed(2)})`);
    }
    for (let column = 1; column < GRID; column += 1) {
      const gap = rowComponents[column].centerX - rowComponents[column - 1].centerX;
      if (gap < sourceWidth / GRID * 0.45) {
        throw new Error(`Direction row ${row} has overlapping frame centers at columns ${column - 1}/${column}`);
      }
    }
    rowCenters.push(centerYs.reduce((sum, value) => sum + value, 0) / GRID);
    ordered.push(...rowComponents.map((component, column) => ({ ...component, row, column })));
  }
  for (let row = 1; row < directionCount; row += 1) {
    if (rowCenters[row] - rowCenters[row - 1] < sourceHeight / directionCount * 0.45) {
      throw new Error(`Direction row centers ${row - 1}/${row} are too close`);
    }
  }
  return { ordered, candidateCount: candidates.length, rowCenters };
}

function componentToCell(globalCell, component) {
  const { bbox } = component;
  const rgba = Buffer.alloc(bbox.width * bbox.height * 4);
  for (const sourceIndex of component.pixels) {
    const sourceX = sourceIndex % globalCell.width;
    const sourceY = Math.floor(sourceIndex / globalCell.width);
    const targetX = sourceX - bbox.x;
    const targetY = sourceY - bbox.y;
    const sourceOffset = sourceIndex * 4;
    const targetOffset = (targetY * bbox.width + targetX) * 4;
    rgba[targetOffset] = globalCell.rgba[sourceOffset];
    rgba[targetOffset + 1] = globalCell.rgba[sourceOffset + 1];
    rgba[targetOffset + 2] = globalCell.rgba[sourceOffset + 2];
    rgba[targetOffset + 3] = globalCell.rgba[sourceOffset + 3];
  }
  return {
    row: component.row,
    column: component.column,
    rgba,
    width: bbox.width,
    height: bbox.height,
    bbox: { x: 0, y: 0, width: bbox.width, height: bbox.height },
    sourceBbox: bbox,
    visible: component.pixelCount,
    removed: bbox.width * bbox.height - component.pixelCount,
  };
}

function samplePremultipliedBilinear(cell, sourceX, sourceY) {
  const x0 = Math.max(0, Math.min(cell.width - 1, Math.floor(sourceX)));
  const y0 = Math.max(0, Math.min(cell.height - 1, Math.floor(sourceY)));
  const x1 = Math.min(cell.width - 1, x0 + 1);
  const y1 = Math.min(cell.height - 1, y0 + 1);
  const fractionX = sourceX - Math.floor(sourceX);
  const fractionY = sourceY - Math.floor(sourceY);
  const weights = [
    [(1 - fractionX) * (1 - fractionY), x0, y0],
    [fractionX * (1 - fractionY), x1, y0],
    [(1 - fractionX) * fractionY, x0, y1],
    [fractionX * fractionY, x1, y1],
  ];
  let alpha = 0;
  let red = 0;
  let green = 0;
  let blue = 0;
  for (const [weight, x, y] of weights) {
    const offset = (y * cell.width + x) * 4;
    const normalizedAlpha = cell.rgba[offset + 3] / 255;
    const weightedAlpha = weight * normalizedAlpha;
    alpha += weightedAlpha;
    red += cell.rgba[offset] * weightedAlpha;
    green += cell.rgba[offset + 1] * weightedAlpha;
    blue += cell.rgba[offset + 2] * weightedAlpha;
  }
  if (alpha <= 0.000001) return [0, 0, 0, 0];
  return [
    Math.max(0, Math.min(255, Math.round(red / alpha))),
    Math.max(0, Math.min(255, Math.round(green / alpha))),
    Math.max(0, Math.min(255, Math.round(blue / alpha))),
    Math.max(0, Math.min(255, Math.round(alpha * 255))),
  ];
}

function isNeutralFringe(red, green, blue) {
  const minimum = Math.min(red, green, blue);
  const maximum = Math.max(red, green, blue);
  return minimum >= NEUTRAL_FRINGE_MIN_CHANNEL && maximum - minimum <= NEUTRAL_FRINGE_MAX_SPREAD;
}

function decontaminateNeutralBoundaryFringe(rgba, width, height) {
  let decontaminated = 0;
  const passCounts = [];
  const virtualTransparency = new Uint8Array(width * height);
  for (let index = 0; index < width * height; index += 1) {
    virtualTransparency[index] = rgba[index * 4 + 3] === 0 ? 1 : 0;
  }
  for (let pass = 0; pass < NEUTRAL_FRINGE_PASSES; pass += 1) {
    const candidates = [];
    for (let y = 0; y < height; y += 1) {
      for (let x = 0; x < width; x += 1) {
        const pixelIndex = y * width + x;
        const offset = pixelIndex * 4;
        if (rgba[offset + 3] === 0) continue;
        if (virtualTransparency[pixelIndex] !== 0) continue;
        if (!isNeutralFringe(rgba[offset], rgba[offset + 1], rgba[offset + 2])) continue;

        let touchesTransparency = x === 0 || y === 0 || x + 1 === width || y + 1 === height;
        for (let neighborY = Math.max(0, y - 1); !touchesTransparency && neighborY <= Math.min(height - 1, y + 1); neighborY += 1) {
          for (let neighborX = Math.max(0, x - 1); neighborX <= Math.min(width - 1, x + 1); neighborX += 1) {
            if (neighborX === x && neighborY === y) continue;
            if (virtualTransparency[neighborY * width + neighborX] !== 0) {
              touchesTransparency = true;
              break;
            }
          }
        }
        if (touchesTransparency) candidates.push(pixelIndex);
      }
    }

    for (const pixelIndex of candidates) {
      const offset = pixelIndex * 4;
      const maximum = Math.max(rgba[offset], rgba[offset + 1], rgba[offset + 2]);
      const scale = Math.min(1, NEUTRAL_FRINGE_MAX_OUTPUT_CHANNEL / Math.max(1, maximum));
      rgba[offset] = Math.round(rgba[offset] * scale);
      rgba[offset + 1] = Math.round(rgba[offset + 1] * scale);
      rgba[offset + 2] = Math.round(rgba[offset + 2] * scale);
      virtualTransparency[pixelIndex] = 1;
    }
    passCounts.push(candidates.length);
    decontaminated += candidates.length;
    if (candidates.length === 0) break;
  }
  return { decontaminated, passCounts };
}

function renderNormalizedCell(cell, globalScale) {
  const scaledWidth = Math.max(1, Math.round(cell.bbox.width * globalScale));
  const scaledHeight = Math.max(1, Math.round(cell.bbox.height * globalScale));
  if (scaledWidth > USABLE_SIZE || scaledHeight > USABLE_SIZE) {
    throw new Error(`Normalized silhouette exceeds ${USABLE_SIZE}px: ${scaledWidth}x${scaledHeight}`);
  }
  const destinationX = Math.round((CELL_SIZE - scaledWidth) / 2);
  const destinationY = FOOT_ANCHOR_Y - scaledHeight + 1;
  if (destinationX < ART_INSET || destinationY < ART_INSET) {
    throw new Error(`Normalized silhouette violates the ${ART_INSET}px art inset`);
  }

  const output = Buffer.alloc(CELL_SIZE * CELL_SIZE * 4);
  for (let y = 0; y < scaledHeight; y += 1) {
    const sourceY = cell.bbox.y + ((y + 0.5) / globalScale) - 0.5;
    for (let x = 0; x < scaledWidth; x += 1) {
      const sourceX = cell.bbox.x + ((x + 0.5) / globalScale) - 0.5;
      const [red, green, blue, alpha] = samplePremultipliedBilinear(cell, sourceX, sourceY);
      if (alpha === 0) continue;
      const offset = ((destinationY + y) * CELL_SIZE + destinationX + x) * 4;
      output[offset] = red;
      output[offset + 1] = green;
      output[offset + 2] = blue;
      output[offset + 3] = alpha;
    }
  }
  const fringe = decontaminateNeutralBoundaryFringe(output, CELL_SIZE, CELL_SIZE);
  return { output, scaledWidth, scaledHeight, destinationX, destinationY, fringe };
}

function compositeCell(atlas, cell, row, column) {
  const atlasWidth = CELL_SIZE * GRID;
  for (let y = 0; y < CELL_SIZE; y += 1) {
    const sourceStart = y * CELL_SIZE * 4;
    const targetStart = ((row * CELL_SIZE + y) * atlasWidth + column * CELL_SIZE) * 4;
    cell.copy(atlas, targetStart, sourceStart, sourceStart + CELL_SIZE * 4);
  }
}

async function loadSource(source) {
  projectRelative(source.path);
  if (!existsSync(source.path)) {
    throw new Error(`Missing Sam V3 source: ${source.path}`);
  }
  if (
    !Number.isInteger(source.directionOffset)
    || !Number.isInteger(source.directionCount)
    || source.directionOffset < 0
    || source.directionCount <= 0
    || source.directionOffset + source.directionCount > GRID
  ) {
    throw new Error(`Invalid direction range for ${source.path}`);
  }

  const sourceBytes = readFileSync(source.path);
  const sourceMetadata = await sharp(sourceBytes).metadata();
  if (sourceMetadata.width == null || sourceMetadata.height == null) {
    throw new Error(`Sam V3 source dimensions are unavailable: ${source.path}`);
  }
  if (sourceMetadata.channels !== 3 || sourceMetadata.hasAlpha) {
    throw new Error(
      `Sam V3 source must be RGB without alpha: ${source.path} (channels=${sourceMetadata.channels}, alpha=${sourceMetadata.hasAlpha})`,
    );
  }
  const decoded = await sharp(sourceBytes).raw().toBuffer({ resolveWithObject: true });
  if (decoded.info.channels !== 3) {
    throw new Error(`Decoded Sam V3 source must have three channels: ${source.path}`);
  }

  const globalForeground = floodFillBorderBackground(decoded.data, decoded.info.width, decoded.info.height);
  const allComponents = findForegroundComponents(globalForeground.rgba, decoded.info.width, decoded.info.height);
  const actorSelection = selectAndOrderActorComponents(
    allComponents,
    decoded.info.width,
    decoded.info.height,
    source.directionCount,
  );
  const cells = actorSelection.ordered.map((component) => {
    const cell = componentToCell(globalForeground, component);
    cell.row += source.directionOffset;
    cell.sourcePath = projectRelative(source.path);
    return cell;
  });
  return {
    cells,
    report: {
      path: projectRelative(source.path),
      sha256: sha256(sourceBytes),
      bytes: sourceBytes.length,
      size: [decoded.info.width, decoded.info.height],
      direction_offset: source.directionOffset,
      direction_count: source.directionCount,
      foreground_components_total: allComponents.length,
      actor_component_candidates: actorSelection.candidateCount,
      detected_row_centers: actorSelection.rowCenters.map((value) => Number(value.toFixed(3))),
    },
  };
}

function assertCanonicalCellCoverage(cells, clip) {
  if (cells.length !== GRID * GRID) {
    throw new Error(`Sprite V3 ${clip} produced ${cells.length}/${GRID * GRID} cells`);
  }
  const occupied = new Set();
  for (const cell of cells) {
    if (cell.row < 0 || cell.row >= GRID || cell.column < 0 || cell.column >= GRID) {
      throw new Error(`Sprite V3 ${clip} produced an out-of-range cell ${cell.row}:${cell.column}`);
    }
    const key = `${cell.row}:${cell.column}`;
    if (occupied.has(key)) {
      throw new Error(`Sprite V3 ${clip} produced duplicate cell ${key}`);
    }
    occupied.add(key);
  }
  for (let row = 0; row < GRID; row += 1) {
    for (let column = 0; column < GRID; column += 1) {
      if (!occupied.has(`${row}:${column}`)) {
        throw new Error(`Sprite V3 ${clip} is missing canonical cell ${row}:${column}`);
      }
    }
  }
}

async function buildClip(clip, sourceOverride = '') {
  const sourceDefinitions = resolveJob(clip, sourceOverride);
  const loadedSources = [];
  for (const source of sourceDefinitions) {
    loadedSources.push(await loadSource(source));
  }
  const cells = loadedSources.flatMap((source) => source.cells)
    .sort((left, right) => left.row - right.row || left.column - right.column);
  assertCanonicalCellCoverage(cells, clip);

  const maximumWidth = Math.max(...cells.map((cell) => cell.bbox.width));
  const maximumHeight = Math.max(...cells.map((cell) => cell.bbox.height));
  const globalScale = Math.min(USABLE_SIZE / maximumWidth, USABLE_SIZE / maximumHeight);
  if (!Number.isFinite(globalScale) || globalScale <= 0) {
    throw new Error(`Invalid global normalization scale for ${clip}: ${globalScale}`);
  }

  const atlas = Buffer.alloc(CELL_SIZE * GRID * CELL_SIZE * GRID * 4);
  const normalized = [];
  for (const cell of cells) {
    const rendered = renderNormalizedCell(cell, globalScale);
    compositeCell(atlas, rendered.output, cell.row, cell.column);
    normalized.push({
      row: cell.row,
      column: cell.column,
      source: cell.sourcePath,
      source_component_bbox: cell.sourceBbox,
      source_bbox: cell.bbox,
      source_visible: cell.visible,
      background_removed: cell.removed,
      normalized_size: [rendered.scaledWidth, rendered.scaledHeight],
      normalized_origin: [rendered.destinationX, rendered.destinationY],
      neutral_fringe_decontaminated: rendered.fringe.decontaminated,
      neutral_fringe_passes: rendered.fringe.passCounts,
    });
  }

  const outputPath = join(outputRoot, `sam_a1__v3__${clip}__8dirx8f.png`);
  mkdirSync(dirname(outputPath), { recursive: true });
  const tempPath = join(
    outputRoot,
    `.tmp-sprite-v3-${clip}-${process.pid}-${Date.now()}.png`,
  );
  try {
    await sharp(atlas, {
      raw: { width: CELL_SIZE * GRID, height: CELL_SIZE * GRID, channels: 4 },
    }).png({ compressionLevel: 9, adaptiveFiltering: false, palette: false }).toFile(tempPath);
    const stagedBytes = readFileSync(tempPath);
    if (
      stagedBytes.length < 33
      || stagedBytes.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a'
      || stagedBytes.readUInt32BE(16) !== CELL_SIZE * GRID
      || stagedBytes.readUInt32BE(20) !== CELL_SIZE * GRID
    ) {
      throw new Error(`Staged Sprite V3 ${clip} output failed PNG integrity checks`);
    }
    await replaceAtomically(tempPath, outputPath);
  } finally {
    if (existsSync(tempPath)) unlinkSync(tempPath);
  }

  const outputBytes = readFileSync(outputPath);
  const visibleValues = normalized.map((cell) => cell.source_visible);
  const sourceReports = loadedSources.map((source) => source.report);
  return {
    actor_id: 'sam_a1',
    contract_version: 3,
    clip,
    source: sourceReports.length === 1 ? sourceReports[0].path : sourceReports.map((source) => source.path),
    output: projectRelative(outputPath),
    source_sha256: sourceReports.length === 1 ? sourceReports[0].sha256 : sourceReports.map((source) => source.sha256),
    output_sha256: sha256(outputBytes),
    source_size: sourceReports.length === 1 ? sourceReports[0].size : sourceReports.map((source) => source.size),
    sources: sourceReports,
    output_size: [CELL_SIZE * GRID, CELL_SIZE * GRID],
    grid: [GRID, GRID],
    cell_size: CELL_SIZE,
    transparent_gutter: TRANSPARENT_GUTTER,
    art_inset: ART_INSET,
    foot_anchor_y: FOOT_ANCHOR_Y,
    checkerboard_threshold: {
      minimum_channel: BACKGROUND_MIN_CHANNEL,
      maximum_channel_spread: BACKGROUND_MAX_SPREAD,
    },
    neutral_fringe_contract: {
      minimum_channel: NEUTRAL_FRINGE_MIN_CHANNEL,
      maximum_channel_spread: NEUTRAL_FRINGE_MAX_SPREAD,
      passes: NEUTRAL_FRINGE_PASSES,
      maximum_output_channel: NEUTRAL_FRINGE_MAX_OUTPUT_CHANNEL,
      pixels_decontaminated: normalized.reduce((sum, cell) => sum + cell.neutral_fringe_decontaminated, 0),
    },
    foreground_components_total: sourceReports.reduce((sum, source) => sum + source.foreground_components_total, 0),
    actor_component_candidates: sourceReports.reduce((sum, source) => sum + source.actor_component_candidates, 0),
    maximum_source_bbox: [maximumWidth, maximumHeight],
    global_scale: Number(globalScale.toFixed(8)),
    source_visible_min: Math.min(...visibleValues),
    source_visible_max: Math.max(...visibleValues),
    source_visible_average: Math.round(visibleValues.reduce((sum, value) => sum + value, 0) / visibleValues.length),
    output_bytes: outputBytes.length,
    write_mode: 'temp_then_atomic_rename',
    cells: normalized,
  };
}

const argumentsValue = parseArguments(process.argv.slice(2));
const clips = argumentsValue.buildAll
  ? Object.keys(JOBS)
  : argumentsValue.buildAccepted
    ? ACCEPTED_CLIPS
    : [argumentsValue.clip];
const reports = [];
const failures = [];
for (const clip of clips) {
  try {
    reports.push(await buildClip(clip, argumentsValue.sourceOverride));
  } catch (error) {
    failures.push({
      clip,
      error: error instanceof Error ? error.message : String(error),
    });
    if (!argumentsValue.buildAll && !argumentsValue.buildAccepted) throw error;
  }
}
if (argumentsValue.buildAll || argumentsValue.buildAccepted) {
  console.log(JSON.stringify({
    ok: failures.length === 0,
    mode: argumentsValue.buildAll ? 'all' : 'accepted',
    succeeded: reports.map((report) => ({
      clip: report.clip,
      output: report.output,
      output_sha256: report.output_sha256,
      output_bytes: report.output_bytes,
      source: report.source,
      source_sha256: report.source_sha256,
      cell_count: report.cells.length,
    })),
    failed: failures,
  }, null, 2));
  if (failures.length > 0) process.exitCode = 1;
} else {
  console.log(JSON.stringify(reports[0], null, 2));
}
