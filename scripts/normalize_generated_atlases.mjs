import { rename, unlink } from 'node:fs/promises';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const sharp = require('../.tools/image-pipeline/node_modules/sharp');

const atlases = [
  'assets/sprites/npcs/dbr-scientist.png',
  'assets/sprites/npcs/dr-curien.png',
  'assets/sprites/enemies/axe-creature.png',
  'assets/sprites/enemies/mutant-bat.png',
  'assets/sprites/bosses/hermit-type-6803.png'
];

const isChecker = (data, offset) => {
  const r = data[offset];
  const g = data[offset + 1];
  const b = data[offset + 2];
  return Math.min(r, g, b) >= 218 && Math.max(r, g, b) - Math.min(r, g, b) <= 18;
};

for (const path of atlases) {
  const { data, info } = await sharp(path).raw().toBuffer({ resolveWithObject: true });
  if (info.channels !== 3) throw new Error(`${path}: expected generated RGB input`);
  const pixels = info.width * info.height;
  const background = new Uint8Array(pixels);
  const queue = new Int32Array(pixels);
  let head = 0;
  let tail = 0;

  const enqueue = (index) => {
    if (background[index] || !isChecker(data, index * 3)) return;
    background[index] = 1;
    queue[tail++] = index;
  };
  for (let x = 0; x < info.width; x += 1) {
    enqueue(x);
    enqueue((info.height - 1) * info.width + x);
  }
  for (let y = 0; y < info.height; y += 1) {
    enqueue(y * info.width);
    enqueue(y * info.width + info.width - 1);
  }
  while (head < tail) {
    const index = queue[head++];
    const x = index % info.width;
    const y = Math.floor(index / info.width);
    if (x > 0) enqueue(index - 1);
    if (x + 1 < info.width) enqueue(index + 1);
    if (y > 0) enqueue(index - info.width);
    if (y + 1 < info.height) enqueue(index + info.width);
  }

  const rgba = Buffer.allocUnsafe(pixels * 4);
  for (let index = 0; index < pixels; index += 1) {
    const input = index * 3;
    const output = index * 4;
    rgba[output] = data[input];
    rgba[output + 1] = data[input + 1];
    rgba[output + 2] = data[input + 2];
    rgba[output + 3] = background[index] ? 0 : 255;
  }
  const temporary = `${path}.normalized.tmp`;
  await sharp(rgba, { raw: { width: info.width, height: info.height, channels: 4 } })
    .resize(1024, 1024, { fit: 'fill', kernel: sharp.kernel.lanczos3 })
    .png({ compressionLevel: 9, adaptiveFiltering: true, palette: false })
    .toFile(temporary);
  await unlink(path);
  await rename(temporary, path);
  console.log(`normalized ${path}: ${info.width}x${info.height} RGB -> 1024x1024 RGBA`);
}
