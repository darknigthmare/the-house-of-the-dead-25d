#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const timelinePath = path.join(root, "data", "runtime", "campaign_timeline.json");
const spriteManifestPath = path.join(root, "data", "assets", "sprite_manifest.json");

const civilianActors = {
  garden_rescue: "scientist_male_blue",
  mansion_entrance: "scientist_male_gray",
  under_bridge: "scientist_female_lab",
  foyer_choice: "scientist_male_blue",
  upper_stairs: "scientist_male_gray",
  ground_hall: "scientist_female_lab",
  sophie_antechamber: "scientist_male_blue",
  sophie_corridor: "sophie",
  chain_plate: "scientist_male_gray",
  underground_passage: "scientist_female_lab",
  great_doors: "scientist_male_blue",
  library_rescue: "scientist_male_gray",
  raised_bridge: "scientist_female_lab",
  lower_stairs: "scientist_male_blue",
  roof_approach: "scientist_male_gray",
  roof_rescue: "scientist_female_lab",
  left_elevator: "scientist_male_blue",
  right_elevator: "scientist_male_gray",
  back_attack_rescue: "scientist_female_lab",
  curien_tunnel: "scientist_male_blue",
};

const breakableAssets = {
  foyer_choice: "c01_foyer_door_lock",
  chain_plate: "c02_chained_hatch_plate",
  elevator_switch: "c03_elevator_route_switch",
  vent_key_route: "c03_vent_key_container",
};

const timeline = JSON.parse(fs.readFileSync(timelinePath, "utf8"));
const spriteManifest = JSON.parse(fs.readFileSync(spriteManifestPath, "utf8"));
const spriteIds = new Set(spriteManifest.assets.map((asset) => asset.id));
for (const [alias] of Object.entries(spriteManifest.aliases ?? {})) spriteIds.add(alias);

const seenCivilians = new Set();
const seenBreakables = new Set();
for (const chapter of timeline.chapters ?? []) {
  for (const node of chapter.nodes ?? []) {
    if (node.civilian) {
      const actorId = civilianActors[node.id];
      if (!actorId) throw new Error(`No civilian visual assigned for node ${node.id}`);
      if (!spriteIds.has(actorId)) throw new Error(`Unknown civilian sprite ${actorId}`);
      node.civilian.actor_id = actorId;
      seenCivilians.add(node.id);
    }
    if (node.breakable) {
      const assetId = breakableAssets[node.id];
      if (!assetId) throw new Error(`No destructible asset assigned for node ${node.id}`);
      node.breakable.asset = assetId;
      seenBreakables.add(node.id);
    }
  }
}

for (const nodeId of Object.keys(civilianActors)) {
  if (!seenCivilians.has(nodeId)) throw new Error(`Missing civilian node ${nodeId}`);
}
for (const nodeId of Object.keys(breakableAssets)) {
  if (!seenBreakables.has(nodeId)) throw new Error(`Missing breakable node ${nodeId}`);
}

fs.writeFileSync(timelinePath, `${JSON.stringify(timeline, null, 2)}\n`, "utf8");
console.log(
  `CAMPAIGN ASSET ENRICHMENT: ${seenCivilians.size} civilian visuals, ` +
    `${seenBreakables.size} destructible assets`,
);
