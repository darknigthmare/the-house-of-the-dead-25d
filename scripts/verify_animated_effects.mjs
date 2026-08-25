#!/usr/bin/env node

import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { inflateSync } from "node:zlib";


const root = resolve(import.meta.dirname, "..");
const provenancePath = join(root, "data", "assets", "animated_effect_generation_provenance.json");
const frameSize = 256;
const frameCount = 8;
const expected = {
  drips: {
    source: "reports/runtime/environment-sources/animated_effect_drips.png",
    sourceSha256: "be479dce13c5ead45de9cde191de63ad6f72d6f20fee603c23cb29de228d82d0",
    output: "assets/environments_v2/effects/drips/drips_strip.png",
    generationReference: "01a00811-e655-7262-8c79-852788f57b9b/exec-4fc2df33-f942-4336-b121-9a1068b26e72.png",
  },
  water_flow: {
    source: "reports/runtime/environment-sources/animated_effect_water_flow.png",
    sourceSha256: "ff60dc56504ebed96216c4bd9c9b14c08360e9ce716bd695f0cf2f92ee30d384",
    output: "assets/environments_v2/effects/water_flow/water_flow_strip.png",
    generationReference: "01a00811-e655-7262-8c79-852788f57b9b/exec-ba9ad960-9b27-43d4-8056-a79b64fcad44.png",
  },
  electrical_arc: {
    source: "reports/runtime/environment-sources/animated_effect_electrical_arc.png",
    sourceSha256: "5c62ed7d11b7ac14ddb0aac8a8ccd599d042dad195a7ad10c68b134e8d4a8544",
    output: "assets/environments_v2/effects/electrical_arc/electrical_arc_strip.png",
    generationReference: "01a00811-e655-7262-8c79-852788f57b9b/exec-0b7ed69d-2226-4d21-aa7d-dafbefd11ba8.png",
  },
  monitor_scan: {
    source: "reports/runtime/environment-sources/animated_effect_monitor_scan.png",
    sourceSha256: "bc2364901ffd8c9bc490fe1384331a0b5f4f706bf8e0741b647a7747465cf00f",
    output: "assets/environments_v2/effects/monitor_scan/monitor_scan_strip.png",
    generationReference: "01a00811-e655-7262-8c79-852788f57b9b/exec-d18efd19-b490-453d-94c5-9c21c1932c1e.png",
  },
};

const failures = [];
let checks = 0;
const check = (condition, message) => {
  checks += 1;
  if (!condition) failures.push(message);
};

const digest = (path) => createHash("sha256").update(readFileSync(path)).digest("hex");

const paeth = (left, up, upLeft) => {
  const prediction = left + up - upLeft;
  const leftDistance = Math.abs(prediction - left);
  const upDistance = Math.abs(prediction - up);
  const diagonalDistance = Math.abs(prediction - upLeft);
  if (leftDistance <= upDistance && leftDistance <= diagonalDistance) return left;
  if (upDistance <= diagonalDistance) return up;
  return upLeft;
};

const decodeRgbaPng = (path) => {
  const png = readFileSync(path);
  check(png.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10])), `valid PNG signature: ${path}`);
  let offset = 8;
  let width = 0;
  let height = 0;
  let bitDepth = 0;
  let colorType = 0;
  let interlace = 0;
  const compressed = [];
  while (offset + 12 <= png.length) {
    const length = png.readUInt32BE(offset);
    const type = png.subarray(offset + 4, offset + 8).toString("ascii");
    const data = png.subarray(offset + 8, offset + 8 + length);
    if (type === "IHDR") {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      bitDepth = data[8];
      colorType = data[9];
      interlace = data[12];
    } else if (type === "IDAT") {
      compressed.push(data);
    } else if (type === "IEND") {
      break;
    }
    offset += length + 12;
  }
  check(bitDepth === 8, `8-bit PNG: ${path}`);
  check(colorType === 6, `RGBA PNG: ${path}`);
  check(interlace === 0, `non-interlaced PNG: ${path}`);
  if (bitDepth !== 8 || colorType !== 6 || interlace !== 0) return { width, height, pixels: Buffer.alloc(0) };
  const bytesPerPixel = 4;
  const stride = width * bytesPerPixel;
  const filtered = inflateSync(Buffer.concat(compressed));
  const pixels = Buffer.alloc(width * height * bytesPerPixel);
  let sourceOffset = 0;
  for (let y = 0; y < height; y += 1) {
    const filter = filtered[sourceOffset];
    sourceOffset += 1;
    const rowOffset = y * stride;
    for (let x = 0; x < stride; x += 1) {
      const raw = filtered[sourceOffset + x];
      const left = x >= bytesPerPixel ? pixels[rowOffset + x - bytesPerPixel] : 0;
      const up = y > 0 ? pixels[rowOffset + x - stride] : 0;
      const upLeft = y > 0 && x >= bytesPerPixel ? pixels[rowOffset + x - stride - bytesPerPixel] : 0;
      let value = raw;
      if (filter === 1) value = (raw + left) & 0xff;
      else if (filter === 2) value = (raw + up) & 0xff;
      else if (filter === 3) value = (raw + Math.floor((left + up) / 2)) & 0xff;
      else if (filter === 4) value = (raw + paeth(left, up, upLeft)) & 0xff;
      else if (filter !== 0) throw new Error(`unsupported PNG filter ${filter} in ${path}`);
      pixels[rowOffset + x] = value;
    }
    sourceOffset += stride;
  }
  return { width, height, pixels };
};

const inspectFrame = (image, frameIndex) => {
  let visible = 0;
  let strong = 0;
  let partial = 0;
  let keyGreenFringe = 0;
  let gutterPixels = 0;
  let minX = frameSize;
  let minY = frameSize;
  let maxX = -1;
  let maxY = -1;
  const signature = createHash("sha256");
  const frameBytes = Buffer.alloc(frameSize * frameSize * 4);
  let frameOffset = 0;
  for (let y = 0; y < frameSize; y += 1) {
    for (let x = 0; x < frameSize; x += 1) {
      const sourceX = frameIndex * frameSize + x;
      const sourceOffset = (y * image.width + sourceX) * 4;
      const red = image.pixels[sourceOffset];
      const green = image.pixels[sourceOffset + 1];
      const blue = image.pixels[sourceOffset + 2];
      const alpha = image.pixels[sourceOffset + 3];
      frameBytes[frameOffset] = red;
      frameBytes[frameOffset + 1] = green;
      frameBytes[frameOffset + 2] = blue;
      frameBytes[frameOffset + 3] = alpha;
      frameOffset += 4;
      if (alpha > 12) {
        visible += 1;
        minX = Math.min(minX, x);
        minY = Math.min(minY, y);
        maxX = Math.max(maxX, x);
        maxY = Math.max(maxY, y);
      }
      if (alpha > 127) strong += 1;
      if (alpha > 0 && alpha < 248) {
        partial += 1;
        if (green > 150 && green - red > 70 && green - blue > 70) keyGreenFringe += 1;
      }
      if ((x < 4 || x >= frameSize - 4 || y < 4 || y >= frameSize - 4) && alpha > 2) gutterPixels += 1;
    }
  }
  signature.update(frameBytes);
  return {
    visible,
    strong,
    partial,
    keyGreenFringe,
    gutterPixels,
    width: maxX >= minX ? maxX - minX + 1 : 0,
    height: maxY >= minY ? maxY - minY + 1 : 0,
    signature: signature.digest("hex"),
  };
};

check(existsSync(provenancePath), "animated-effect provenance exists");
const provenance = existsSync(provenancePath) ? JSON.parse(readFileSync(provenancePath, "utf8")) : {};
check(provenance.schema_version === 1, "animated-effect provenance schema is 1");
check(String(provenance.generated_asset_policy ?? "").includes("fan-made"), "provenance declares fan-made replacements");
check(String(provenance.generated_asset_policy ?? "").includes("non-Sega-exact"), "provenance declares non-Sega-exact status");
check(provenance.output_contract?.layout === "8x1", "provenance declares an 8x1 output layout");
check(JSON.stringify(provenance.output_contract?.dimensions) === JSON.stringify([2048, 256]), "provenance declares 2048x256 output");

const records = new Map((provenance.assets ?? []).map((entry) => [entry.id, entry]));
check(records.size === Object.keys(expected).length, "provenance contains exactly four animated effects");
check([...records.keys()].sort().join("|") === Object.keys(expected).sort().join("|"), "animated-effect ids match the expected contract");

let optionalSourcesPresent = 0;
for (const [id, contract] of Object.entries(expected)) {
  const record = records.get(id) ?? {};
  const sourcePath = join(root, contract.source);
  const outputPath = join(root, contract.output);
  check(record.source === contract.source, `${id} source path is exact`);
  check(record.output === contract.output, `${id} output path is exact`);
  check(record.generation_reference === contract.generationReference, `${id} generation reference is exact`);
  check(record.status === "original_fan_made_non_sega_exact", `${id} is marked fan-made and non-Sega-exact`);
  check(record.fidelity_status === "not_verified_against_authorized_sega_arcade_reference", `${id} has an honest fidelity boundary`);
  check(existsSync(outputPath), `${id} output strip exists`);
  check(record.source_sha256 === contract.sourceSha256, `${id} provenance records the selected source hash`);
  if (existsSync(sourcePath)) {
    optionalSourcesPresent += 1;
    const sourceDigest = digest(sourcePath);
    check(sourceDigest === contract.sourceSha256, `${id} optional private source hash matches the selected generation`);
    check(record.source_sha256 === sourceDigest, `${id} provenance source hash matches the optional private source`);
  }
  if (!existsSync(outputPath)) continue;
  const outputDigest = digest(outputPath);
  check(record.output_sha256 === outputDigest, `${id} provenance output hash matches`);
  check(JSON.stringify(record.source_grid) === JSON.stringify([4, 2]), `${id} records its 4x2 source grid`);
  check(record.frame_order === "row_major", `${id} records row-major frame order`);
  check(record.hframes === frameCount, `${id} records eight horizontal frames`);
  check(JSON.stringify(record.frame_size) === JSON.stringify([frameSize, frameSize]), `${id} records 256x256 cells`);

  const image = decodeRgbaPng(outputPath);
  check(image.width === frameSize * frameCount, `${id} width is 2048`);
  check(image.height === frameSize, `${id} height is 256`);
  if (image.pixels.length === 0) continue;
  const frames = [];
  for (let frameIndex = 0; frameIndex < frameCount; frameIndex += 1) {
    const frame = inspectFrame(image, frameIndex);
    frames.push(frame);
    check(frame.visible >= 100, `${id} frame ${frameIndex} is non-empty (${frame.visible} visible pixels)`);
    check(frame.strong >= 40, `${id} frame ${frameIndex} retains solid effect pixels`);
    check(frame.visible < frameSize * frameSize * 0.85, `${id} frame ${frameIndex} retains useful transparency`);
    check(frame.partial > 0, `${id} frame ${frameIndex} retains antialiased alpha`);
    check(frame.gutterPixels === 0, `${id} frame ${frameIndex} has a transparent four-pixel gutter`);
    check(frame.width >= 8 && frame.height >= 8, `${id} frame ${frameIndex} has useful visible bounds`);
    check(frame.keyGreenFringe <= 2, `${id} frame ${frameIndex} has no green-key edge spill (${frame.keyGreenFringe})`);
    check(record.frame_visible_pixels?.[frameIndex] === frame.visible, `${id} frame ${frameIndex} visible-pixel provenance matches`);
  }
  check(new Set(frames.map((frame) => frame.signature)).size === frameCount, `${id} contains eight distinct animation cells`);
}

console.log(`ANIMATED EFFECTS OK: ${checks - failures.length}/${checks} checks; optional private sources ${optionalSourcesPresent}/4 present`);
if (failures.length) {
  console.error(failures.map((failure) => `FAIL: ${failure}`).join("\n"));
  process.exit(1);
}
