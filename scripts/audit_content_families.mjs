import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, extname, join, normalize, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const readJson = (path) => JSON.parse(readFileSync(join(root, path), "utf8"));
const fromResourcePath = (path) => join(root, ...String(path).replace(/^res:\/\//, "").split("/"));
const projectPath = (path) => relative(root, path).replaceAll("\\", "/");

const environment = readJson("data/assets/environment_manifest.json");
const gameplay = readJson("data/assets/gameplay_support_manifest.json");
const sprites = readJson("data/assets/sprite_manifest.json");
const enemiesPayload = readJson("data/enemies/enemy_profiles.json");
const campaign = readJson("data/runtime/campaign_timeline.json");
const bossesPayload = readJson("data/bosses/boss_profiles.json");
const combatSource = readFileSync(join(root, "src/gameplay/gameplay_runtime_combat.gd"), "utf8");
const flowSource = readFileSync(join(root, "src/gameplay/gameplay_runtime_flow.gd"), "utf8");
const environmentLibrarySource = readFileSync(join(root, "src/gameplay/environment_asset_library.gd"), "utf8");
const gameplaySupportLibrarySource = readFileSync(join(root, "src/gameplay/gameplay_support_library.gd"), "utf8");
const propStateControllerPath = join(root, "src/gameplay/environment_prop_state_controller.gd");
const propStateControllerSource = existsSync(propStateControllerPath) ? readFileSync(propStateControllerPath, "utf8") : "";
const curienSmokePath = join(root, "scripts/smoke_curien_finale.gd");
const curienSmokeSource = existsSync(curienSmokePath) ? readFileSync(curienSmokePath, "utf8") : "";


const errors = [];
const warnings = [];
let checks = 0;

function check(condition, message) {
  checks += 1;
  if (!condition) errors.push(message);
}

function warn(condition, message) {
  checks += 1;
  if (!condition) warnings.push(message);
}

function validateResource(path, label) {
  check(typeof path === "string" && path.startsWith("res://"), `${label}: invalid resource path ${path}`);
  if (typeof path !== "string" || !path.startsWith("res://")) return null;
  const diskPath = fromResourcePath(path);
  check(existsSync(diskPath), `${label}: missing file ${path}`);
  return diskPath;
}

function walkFiles(directory) {
  if (!existsSync(directory)) return [];
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? walkFiles(path) : [path];
  });
}

const spriteAssets = new Map(sprites.assets.map((asset) => [asset.id, asset]));
const spriteAliases = new Map(Object.entries(sprites.aliases ?? {}));
const enemyProfiles = new Map(enemiesPayload.profiles.map((profile) => [profile.id, profile]));
const bossProfiles = new Map(bossesPayload.bosses.map((profile) => [profile.id, profile]));
const resolveActor = (id) => spriteAliases.get(id) ?? id;

const campaignNodes = [];
const campaignNodeData = new Map();
const enemySpawnCounts = new Map();
const civilianCounts = new Map();
const breakableUses = [];
const pickupUses = [];
const propStateEvents = [];
const propStateEventCounts = new Map();
const pendingReferenceSpawns = [];
const effectiveProjectileUses = new Map();
const projectileAliases = {
  vomit_burst: "organic_spit",
  short_flame_jet: "magician_fireball",
  launched_iron_claw: "iron_claw",
  laser_dagger: "thrown_dagger",
};

function defaultBehavior(profile) {
  if (profile?.projectile && Boolean(profile.projectile.destructible)) return "throw_projectile";
  const archetype = String(profile?.archetype ?? "");
  if (archetype.includes("aquatic")) return "aquatic_weave";
  if (archetype.includes("ceiling_drop") || archetype.includes("wall_crawling")) return "ceiling_drop";
  if (archetype.includes("flying") || archetype.includes("swarming")) return "flight_swarm";
  if (archetype.includes("leaping") || archetype.includes("rolling")) return "jump";
  if (archetype.includes("charge") || archetype.includes("raider")) return "charge";
  if (archetype.includes("heavy") || archetype.includes("brute") || archetype.includes("chainsaw")) return "heavy_weapon";
  return "walk";
}

for (const chapter of campaign.chapters) {
  const graph = readJson(`data/routes/${chapter.id}_route_graph.json`);
  const runtimeIds = new Set(chapter.nodes.map((node) => node.id));
  const graphIds = new Set(graph.nodes.map((node) => node.id));
  const activeOnly = [...runtimeIds].filter((id) => !graphIds.has(id));
  const graphOnly = [...graphIds].filter((id) => !runtimeIds.has(id));
  warn(activeOnly.length === 0 && graphOnly.length === 0, `${chapter.id}: runtime/route graph drift; active-only=${activeOnly.join(",") || "none"}; graph-only=${graphOnly.join(",") || "none"}`);

  for (const node of chapter.nodes) {
    const location = `${chapter.id}/${node.id}`;
    campaignNodes.push(node.id);
    campaignNodeData.set(node.id, node);
    check(Object.hasOwn(environment.nodes, node.id), `${location}: no environment node profile`);

    if (node.civilian) {
      const requestedId = String(node.civilian.actor_id ?? "");
      const resolvedId = resolveActor(requestedId);
      civilianCounts.set(resolvedId, (civilianCounts.get(resolvedId) ?? 0) + 1);
      check(spriteAssets.has(resolvedId), `${location}: missing civilian actor ${requestedId} -> ${resolvedId}`);
    }

    if (node.breakable) {
      const assetId = String(node.breakable.asset ?? "");
      const pickupId = String(node.breakable.pickup ?? "");
      breakableUses.push({ location, assetId, pickupId });
      check(Object.hasOwn(environment.destructibles, assetId), `${location}: missing destructible ${assetId}`);
      check(Object.hasOwn(gameplay.pickups ?? {}, pickupId), `${location}: unsupported pickup ${pickupId}`);
    }

    for (const pickup of node.pickups ?? []) {
      const pickupId = String(pickup.id ?? "");
      const pickupType = String(pickup.pickup ?? "");
      pickupUses.push({ location, pickupId, pickupType });
      check(pickupId.length > 0, `${location}: pickup id is missing`);
      check(Object.hasOwn(gameplay.pickups ?? {}, pickupType), `${location}: unsupported pickup ${pickupType}`);
    }

    if (node.type === "boss") {
      const bossId = String(node.boss ?? "");
      check(bossProfiles.has(bossId), `${location}: missing boss profile ${bossId}`);
      check(spriteAssets.has(bossId), `${location}: missing boss sprite ${bossId}`);
      if (bossId === "hermit") effectiveProjectileUses.set("hermit_web_ball", (effectiveProjectileUses.get("hermit_web_ball") ?? 0) + 1);
      if (bossId === "magician") effectiveProjectileUses.set("magician_fireball", (effectiveProjectileUses.get("magician_fireball") ?? 0) + 1);
    }

    for (const spawn of node.spawns ?? []) {
      const actorId = String(spawn.actor ?? "");
      const profile = enemyProfiles.get(actorId);
      enemySpawnCounts.set(actorId, (enemySpawnCounts.get(actorId) ?? 0) + 1);
      const referenceStatus = String(spawn.reference_status ?? "");
      if (referenceStatus.endsWith("_placement_pending")) {
        pendingReferenceSpawns.push({ location, actorId, referenceStatus });
      }
      check(Boolean(profile), `${location}: missing enemy profile ${actorId}`);
      check(spriteAssets.has(actorId), `${location}: missing enemy sprite ${actorId}`);
      if (!profile) continue;
      const behavior = String(spawn.behavior ?? defaultBehavior(profile));
      if (behavior !== "throw_projectile") continue;
      const kind = Boolean(profile.projectile?.destructible) ? String(profile.projectile?.kind ?? "") : "";
      const projectileId = projectileAliases[kind] ?? kind;
      check(projectileId.length > 0, `${location}: ${actorId} uses throw_projectile without a projectile id`);
      if (!projectileId) continue;
      check(Object.hasOwn(gameplay.projectiles, projectileId), `${location}: ${actorId} resolves absent projectile ${projectileId}`);
      effectiveProjectileUses.set(projectileId, (effectiveProjectileUses.get(projectileId) ?? 0) + 1);
    }
  }
}

for (const spawn of pendingReferenceSpawns) {
  warn(false, `${spawn.location}: ${spawn.actorId} placement is not arcade-exact (${spawn.referenceStatus})`);
}

const environmentNodeIds = Object.keys(environment.nodes);
const bonusRoom = campaign.chapters.flatMap((chapter) => chapter.nodes).find((node) => node.id === "bonus_room");
check(Boolean(bonusRoom), "chapter_04/bonus_room is missing");
if (bonusRoom) {
  const bonusPickups = bonusRoom.pickups ?? [];
  const bonusIds = bonusPickups.map((pickup) => String(pickup.id ?? ""));
  check(bonusPickups.length === 12, `bonus_room requires 12 pickups, found ${bonusPickups.length}`);
  check(new Set(bonusIds).size === 12, "bonus_room pickup ids must be 12 unique values");
  for (const [pickupType, expected] of Object.entries({ life: 4, frog: 3, medal: 5 })) {
    const observed = bonusPickups.filter((pickup) => pickup.pickup === pickupType).length;
    check(observed === expected, `bonus_room requires ${expected} ${pickupType}, found ${observed}`);
  }
  check((bonusRoom.spawns ?? []).length === 0, "bonus_room must not contain hostiles");
  check(!Object.hasOwn(bonusRoom, "breakable"), "bonus_room must not contain a breakable proxy");
  const pickupScore = bonusPickups.reduce((total, pickup) => total + Number(gameplay.pickups?.[pickup.pickup]?.score ?? 0), 0);
  check(pickupScore === 4000, `bonus_room score pickup total must be 4000, found ${pickupScore}`);
}
check(new Set(campaignNodes).size === campaignNodes.length, "campaign node ids are duplicated");
warn(environmentNodeIds.every((id) => campaignNodes.includes(id)), `environment-only node profiles: ${environmentNodeIds.filter((id) => !campaignNodes.includes(id)).join(",")}`);

const propPlacementCounts = new Map();
for (const [nodeId, node] of Object.entries(environment.nodes)) {
  for (const placement of node.props ?? []) {
    const propId = String(placement.id ?? "");
    propPlacementCounts.set(propId, (propPlacementCounts.get(propId) ?? 0) + 1);
    check(Object.hasOwn(environment.props, propId), `environment ${nodeId}: missing prop ${propId}`);
    const stateEvent = placement.state_event;
    if (stateEvent && typeof stateEvent === "object" && !Array.isArray(stateEvent)) {
      const eventId = String(stateEvent.id ?? "");
      const trigger = String(stateEvent.trigger ?? "");
      const targetFrame = Number(stateEvent.target_frame);
      const propProfile = environment.props[propId] ?? {};
      const frameCount = Math.max(1, Number(propProfile.hframes ?? 1));
      propStateEvents.push({ nodeId, propId, eventId, trigger, targetFrame });
      propStateEventCounts.set(propId, (propStateEventCounts.get(propId) ?? 0) + 1);
      check(eventId.length > 0, `environment ${nodeId}/${propId}: state event id is missing`);
      check(["node_enter", "elapsed", "encounter_clear", "node_complete_success", "breakable_destroyed", "boss_phase"].includes(trigger), `environment ${nodeId}/${propId}: unsupported state trigger ${trigger}`);
      check(Number.isInteger(targetFrame) && targetFrame >= 0 && targetFrame < frameCount, `environment ${nodeId}/${propId}: state target frame ${targetFrame} is outside 0..${frameCount - 1}`);
      if (trigger === "elapsed") check(Number(stateEvent.at) >= 0, `environment ${nodeId}/${propId}: elapsed trigger requires a non-negative at value`);
      if (trigger === "boss_phase") check(Number.isInteger(Number(stateEvent.phase)) && Number(stateEvent.phase) >= 0, `environment ${nodeId}/${propId}: boss_phase requires a non-negative integer phase`);
      if (trigger === "breakable_destroyed") {
        const breakableId = String(stateEvent.breakable_id ?? "");
        check(Object.hasOwn(environment.destructibles, breakableId), `environment ${nodeId}/${propId}: missing state-event breakable ${breakableId}`);
        check(String(campaignNodeData.get(nodeId)?.breakable?.asset ?? "") === breakableId, `environment ${nodeId}/${propId}: state-event breakable ${breakableId} does not match the active timeline interaction`);
      }
    }
  }
}

const propStateRuntimeWired = (
  propStateControllerSource.includes("apply_pending_event")
  && propStateControllerSource.includes("event_is_triggered")
  && flowSource.includes("_configure_environment_prop_state_events")
  && flowSource.includes("_update_environment_prop_state_events")
);
check(propStateRuntimeWired, "environment prop state events are not wired into the active runtime flow");

const resolvedEffects = new Set();
for (const node of Object.values(environment.nodes)) {
  const style = environment.styles[node.style] ?? {};
  for (const effect of node.effects ?? style.effects ?? []) resolvedEffects.add(effect);
}

const hashedAssets = [];
for (const [id, profile] of Object.entries(environment.props)) {
  const path = validateResource(profile.path, `prop ${id}`);
  if (path) hashedAssets.push({ family: "prop", id, path });
  warn((propPlacementCounts.get(id) ?? 0) > 0, `prop ${id} is never placed`);
  const hasRuntimeBinding = Boolean(profile.animate) || ((propStateEventCounts.get(id) ?? 0) > 0 && propStateRuntimeWired);
  warn(!(Number(profile.hframes ?? 1) > 1 && !hasRuntimeBinding), `prop ${id} has ${profile.hframes} frames but no runtime animation/state binding`);
}
for (const [id, profile] of Object.entries(environment.destructibles)) {
  for (const state of ["intact", "broken"]) {
    const path = validateResource(profile[state], `destructible ${id}/${state}`);
    if (path) hashedAssets.push({ family: `destructible_${state}`, id, path });
  }
  warn(breakableUses.some((use) => use.assetId === id), `destructible ${id} is never used`);
}
for (const [id, profile] of Object.entries(gameplay.projectiles)) {
  const path = validateResource(profile.path, `projectile ${id}`);
  if (path) hashedAssets.push({ family: "projectile", id, path });
  warn((effectiveProjectileUses.get(id) ?? 0) > 0, `projectile ${id} has no effective campaign spawn`);
}
const animatedEffectRuntimeWired = (
  environmentLibrarySource.includes("get_animated_effect")
  && combatSource.includes("_spawn_animated_environment_effect")
  && combatSource.includes('configure_target(sprite, "effect_strip")')
);
check(animatedEffectRuntimeWired, "dedicated animated environment effects are not wired into the active runtime");
for (const [id, profile] of Object.entries(environment.animated_effects ?? {})) {
  const path = validateResource(profile.path, `animated effect ${id}`);
  if (path) hashedAssets.push({ family: "animated_effect", id, path });
  check(Number(profile.hframes ?? 0) >= 2, `animated effect ${id}: requires at least two frames`);
  check(Number(profile.fps ?? 0) > 0, `animated effect ${id}: requires a positive fps`);
  warn(resolvedEffects.has(id), `animated effect ${id} is not requested by any active scene/style`);
}
for (const [id, profile] of Object.entries(gameplay.ui)) validateResource(profile.path, `ui ${id}`);
for (const [id, profile] of Object.entries(gameplay.weakpoints)) validateResource(profile.path, `weakpoint ${id}`);
for (const [id, profile] of spriteAssets) {
  const path = validateResource(profile.path, `actor ${id}`);
  if (path) hashedAssets.push({ family: "actor", id, path });
}

function warnUnmanifestedPngs(directory, declaredPaths, label) {
  const declared = new Set(declaredPaths.map((path) => normalize(path)));
  for (const path of walkFiles(join(root, directory)).filter((entry) => extname(entry).toLowerCase() === ".png")) {
    warn(declared.has(normalize(path)), `unreferenced ${label} file ${projectPath(path)}`);
  }
}
warnUnmanifestedPngs(
  "assets/environments_v2/props",
  Object.values(environment.props).map((profile) => fromResourcePath(profile.path)),
  "prop",
);
warnUnmanifestedPngs(
  "assets/environments_v2/destructibles",
  Object.values(environment.destructibles).flatMap((profile) => [fromResourcePath(profile.intact), fromResourcePath(profile.broken)]),
  "destructible",
);
warnUnmanifestedPngs(
  "assets/gameplay_v2/projectiles",
  Object.values(gameplay.projectiles).map((profile) => fromResourcePath(profile.path)),
  "projectile",
);
warnUnmanifestedPngs(
  "assets/environments_v2/effects",
  Object.values(environment.animated_effects ?? {}).map((profile) => fromResourcePath(profile.path)),
  "animated effect",
);

const mirroredRightProfiles = sprites.assets.filter((asset) => asset.right_profile_source === "mirrored_left_profile").length;
const mirroredBackRightProfiles = sprites.assets.filter((asset) => asset.back_right_source === "mirrored_from_back_left").length;
warn(mirroredRightProfiles === 0, `${mirroredRightProfiles}/${sprites.assets.length} actor right profiles are mirrored from the left profile`);
warn(mirroredBackRightProfiles === 0, `${mirroredBackRightProfiles}/${sprites.assets.length} actor back-right rows are mirrored from back-left`);
warn(
  Number(sprites.atlas_layout?.frames_per_direction ?? 0) > Number(sprites.atlas_layout?.frame_states?.length ?? 0),
  `atlas contract exposes ${sprites.atlas_layout?.frame_states?.length ?? 0} semantic state cells per direction, not multi-frame clips per state`,
);

for (const [id, profile] of Object.entries(gameplay.pickups ?? {})) {
  const diskPath = validateResource(profile.path, `pickup ${id}`);
  if (diskPath) hashedAssets.push({ family: "pickup", id, path: diskPath });
}
const itemFiles = walkFiles(join(root, "assets/sprites/items")).filter((path) => extname(path).toLowerCase() === ".png");
const declaredItemFiles = new Set(Object.values(gameplay.pickups ?? {}).map((profile) => normalize(fromResourcePath(profile.path))));
for (const path of itemFiles) warn(declaredItemFiles.has(normalize(path)), `unreferenced item/collectible file ${projectPath(path)}`);

const digestOwners = new Map();
for (const asset of hashedAssets) {
  if (!existsSync(asset.path)) continue;
  const digest = createHash("sha256").update(readFileSync(asset.path)).digest("hex");
  const owners = digestOwners.get(digest) ?? [];
  owners.push(`${asset.family}:${asset.id}`);
  digestOwners.set(digest, owners);
}
for (const [digest, owners] of digestOwners) warn(owners.length === 1, `binary asset proxy/duplicate ${digest}: ${owners.join(", ")}`);

const unusedEnemyProfiles = [...enemyProfiles.keys()].filter((id) => !enemySpawnCounts.has(id));
const presentationSource = readFileSync(join(root, "src/gameplay/gameplay_runtime_presentation.gd"), "utf8");
const storyActorIds = [...presentationSource.matchAll(/_spawn_story_actor\("([^"]+)"/g)].map((match) => resolveActor(match[1]));
const runtimeEnemyActorIds = [...combatSource.matchAll(/_spawn_enemy\(\{\s*"actor":\s*"([^"]+)"/g)].map((match) => resolveActor(match[1]));
const usedActorIds = new Set([
  ...enemySpawnCounts.keys(),
  ...civilianCounts.keys(),
  ...storyActorIds,
  ...runtimeEnemyActorIds,
  ...campaign.chapters.flatMap((chapter) => chapter.nodes.filter((node) => node.type === "boss").map((node) => node.boss)),
]);
const unusedRuntimeActors = [...spriteAssets.keys()].filter((id) => !usedActorIds.has(id) && !["thomas_rogan", "agent_g"].includes(id));
warn(unusedEnemyProfiles.length === 0, `enemy profiles absent from campaign spawns: ${unusedEnemyProfiles.join(",")}`);
warn(unusedRuntimeActors.length === 0, `non-hero actor atlases absent from active runtime: ${unusedRuntimeActors.join(",")}`);

for (const effect of ["drips", "water_flow", "electrical_arc", "monitor_scan"]) {
  const profile = environment.animated_effects?.[effect];
  warn(!resolvedEffects.has(effect) || (Boolean(profile) && animatedEffectRuntimeWired), `animated effect ${effect} is active without a dedicated authored runtime strip`);
}

const curienFinaleRuntimeWired = (
  presentationSource.includes('current_node_id == "magician_battle"')
  && presentationSource.includes("_spawn_magician_story_projectile")
  && presentationSource.includes('set_meta("targetable", false)')
  && presentationSource.includes('set_meta("narrative_state", "hit_recoil")')
  && presentationSource.includes('set_meta("narrative_state", "dead_grounded")')
  && presentationSource.includes("CURIEN_MIN_CORPSE_HOLD_SECONDS := 5.0")
);
check(curienFinaleRuntimeWired, "Curien finale staging is incomplete in the active presentation runtime");
check(curienSmokeSource.includes("Magician creates a dedicated visible story projectile"), "Curien finale smoke lacks visible-projectile coverage");
check(curienSmokeSource.includes("minimum five-second hold"), "Curien finale smoke lacks persistent-corpse coverage");

const sourceFiles = walkFiles(join(root, "src")).filter((path) => extname(path) === ".gd");
for (const controller of ["pickup_controller.gd", "breakable_object.gd", "civilian_controller.gd", "enemy_spawn_event.gd"]) {
  const references = sourceFiles.filter((path) => !path.endsWith(controller) && readFileSync(path, "utf8").includes(controller));
  warn(references.length > 0, `${controller} is not instantiated or preloaded by the active runtime`);
}

console.log(`CONTENT FAMILY AUDIT: ${checks} checks, ${warnings.length} warnings, ${errors.length} errors`);
console.log(`inventory props=${Object.keys(environment.props).length}/${[...propPlacementCounts.values()].reduce((a, b) => a + b, 0)} placements/${propStateEvents.length} state events; breakables=${Object.keys(environment.destructibles).length}/${breakableUses.length} uses; pickups=${Object.keys(gameplay.pickups ?? {}).length}/${pickupUses.length} placements; enemies=${enemyProfiles.size}/${enemySpawnCounts.size} timeline active + ${runtimeEnemyActorIds.length} runtime boss-support spawn sites; civilians=${[...civilianCounts.values()].reduce((a, b) => a + b, 0)} placements/${civilianCounts.size} visuals; projectiles=${Object.keys(gameplay.projectiles).length}/${effectiveProjectileUses.size} effective; animated_effects=${Object.keys(environment.animated_effects ?? {}).length}; unique_binary_assets=${digestOwners.size}/${hashedAssets.length}`);
if (warnings.length > 0) {
  console.log("WARNINGS");
  for (const warning of warnings) console.log(`- ${warning}`);
}
if (errors.length > 0) {
  console.error("ERRORS");
  for (const error of errors) console.error(`- ${error}`);
  process.exitCode = 1;
}
