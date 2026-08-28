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
const expectedPickups = ["medal", "frog", "life"];
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
check(Object.keys(manifest.pickups ?? {}).length === 3, "three pickup visuals");
for (const id of expectedPickups) verifyPng(manifest.pickups?.[id], `pickup_${id}`, 512, 512);
check(new Set(expectedPickups.map((id) => manifest.pickups?.[id]?.sha256)).size === 3, "pickup hashes are distinct");
check(Object.keys(manifest.ui ?? {}).length === 3, "three HUD asset families");
verifyPng(manifest.ui?.life_torch, "life_torch", 2048, 256);
check(manifest.ui?.life_torch?.hframes === 8, "life torch has eight frames");
for (const id of expectedUi.slice(1)) verifyPng(manifest.ui?.[id], id, 256, 256);
check(Object.keys(manifest.weakpoints ?? {}).length === 4, "four boss weakpoint diagrams");
for (const id of expectedBosses) verifyPng(manifest.weakpoints?.[id], `weakpoint_${id}`, 384, 384);

const campaign = JSON.parse(readFileSync(campaignPath, "utf8"));
const civilianIds = [];
const breakableIds = [];
let bonusRoom = null;
for (const chapter of campaign.chapters ?? []) {
  for (const node of chapter.nodes ?? []) {
    if (node.civilian) civilianIds.push(node.civilian.actor_id);
    if (node.breakable) breakableIds.push(node.breakable.asset);
    if (node.id === "bonus_room") bonusRoom = node;
  }
}
check(civilianIds.length === 20, "twenty campaign civilian placements have visuals");
check(civilianIds.every((id) => typeof id === "string" && id.length > 0), "every civilian placement has actor_id");
for (const id of ["dbr_scientist", "scientist_male_blue", "scientist_male_gray", "scientist_female_lab", "sophie"]) {
  check(civilianIds.includes(id), `civilian visual is used: ${id}`);
}
check(new Set(breakableIds).size === 8 && breakableIds.length === 8, "eight distinct route and hidden-cache breakables are wired before the conditional final supplies");
check(!breakableIds.includes("c04_bonus_gate_seal"), "bonus gate no longer uses a shootable seal proxy");
check(!breakableIds.includes("c04_emergency_supply_crate"), "bonus room no longer uses the emergency-crate proxy");
check(Boolean(bonusRoom), "bonus room exists");
const bonusPickups = bonusRoom?.pickups ?? [];
const bonusPickupIds = bonusPickups.map((pickup) => pickup.id);
check(bonusPickups.length === 12, "bonus room contains twelve pickups");
check(new Set(bonusPickupIds).size === 12 && bonusPickupIds.every((id) => typeof id === "string" && id.length > 0), "bonus pickup ids are unique and non-empty");
check(bonusPickups.every((pickup) => expectedPickups.includes(pickup.pickup)), "every bonus pickup resolves through the validated manifest");
check(bonusPickups.filter((pickup) => pickup.pickup === "life").length === 4, "bonus room contains four life pickups");
check(bonusPickups.filter((pickup) => pickup.pickup === "frog").length === 3, "bonus room contains three frogs");
check(bonusPickups.filter((pickup) => pickup.pickup === "medal").length === 5, "bonus room contains five medals");
check((bonusRoom?.spawns ?? []).length === 0, "bonus room contains no hostile spawns");
check(!Object.hasOwn(bonusRoom ?? {}, "breakable"), "bonus room contains no breakable proxy");
const bonusPickupScore = bonusPickups.reduce((total, pickup) => total + ({ frog: 1000, medal: 200, life: 0 }[pickup.pickup] ?? 0), 0);
check(bonusPickupScore === 4000, "bonus room score-bearing pickups total 4000 points");

console.log(`GAMEPLAY SUPPORT OK: ${checks - failures.length}/${checks} checks`);
if (failures.length) {
  console.error(failures.map((failure) => `FAIL: ${failure}`).join("\n"));
  process.exit(1);
}
