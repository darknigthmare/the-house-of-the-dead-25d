#!/usr/bin/env node

import { existsSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
const manifestPath = join(root, "data", "assets", "gameplay_support_manifest.json");
const campaignPath = join(root, "data", "runtime", "campaign_timeline.json");
const failures = [];
let checks = 0;
const check = (condition, message) => {
  checks += 1;
  if (!condition) failures.push(message);
};

check(existsSync(manifestPath), "gameplay support manifest exists");
const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
check(manifest.schema_version === 1, "gameplay support schema is 1");

const expectedProjectiles = [
  "thrown_axe",
  "thrown_dagger",
  "thrown_barrel",
  "organic_spit",
  "iron_claw",
  "hermit_web_ball",
  "magician_fireball",
];
const expectedUi = ["life_torch", "bullet_round", "reload_offscreen_icon"];
const expectedBosses = ["chariot", "hangedman", "hermit", "magician"];

const verifyPng = (entry, id, expectedWidth, expectedHeight) => {
  const relative = entry?.path?.replace("res://", "").replaceAll("\\", "/") ?? "";
  const full = join(root, relative);
  check(relative.length > 0 && existsSync(full), `asset exists: ${id}`);
  if (!existsSync(full)) return;
  const png = readFileSync(full);
  check(png.subarray(1, 4).toString() === "PNG", `valid PNG: ${id}`);
  check(png.readUInt32BE(16) === expectedWidth, `width ${expectedWidth}: ${id}`);
  check(png.readUInt32BE(20) === expectedHeight, `height ${expectedHeight}: ${id}`);
  check(png[25] === 6, `RGBA PNG: ${id}`);
};

check(Object.keys(manifest.projectiles ?? {}).length === 7, "seven dedicated projectiles");
for (const id of expectedProjectiles) verifyPng(manifest.projectiles?.[id], id, 512, 512);
check(Object.keys(manifest.ui ?? {}).length === 3, "three HUD asset families");
verifyPng(manifest.ui?.life_torch, "life_torch", 2048, 256);
check(manifest.ui?.life_torch?.hframes === 8, "life torch has eight frames");
for (const id of expectedUi.slice(1)) verifyPng(manifest.ui?.[id], id, 256, 256);
check(Object.keys(manifest.weakpoints ?? {}).length === 4, "four boss weakpoint diagrams");
for (const id of expectedBosses) verifyPng(manifest.weakpoints?.[id], `weakpoint_${id}`, 384, 384);

const campaign = JSON.parse(readFileSync(campaignPath, "utf8"));
const civilianIds = [];
const breakableIds = [];
for (const chapter of campaign.chapters ?? []) {
  for (const node of chapter.nodes ?? []) {
    if (node.civilian) civilianIds.push(node.civilian.actor_id);
    if (node.breakable) breakableIds.push(node.breakable.asset);
  }
}
check(civilianIds.length === 20, "twenty campaign civilian placements have visuals");
check(civilianIds.every((id) => typeof id === "string" && id.length > 0), "every civilian placement has actor_id");
for (const id of ["scientist_male_blue", "scientist_male_gray", "scientist_female_lab", "sophie"]) {
  check(civilianIds.includes(id), `civilian visual is used: ${id}`);
}
check(new Set(breakableIds).size === 6 && breakableIds.length === 6, "six unique destructible visuals are wired");

console.log(`GAMEPLAY SUPPORT OK: ${checks - failures.length}/${checks} checks`);
if (failures.length) {
  console.error(failures.map((failure) => `FAIL: ${failure}`).join("\n"));
  process.exit(1);
}
