import { access, readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(scriptDirectory, "..");
const rosterPath = resolve(projectRoot, "data/enemies/enemy_profiles.json");
const requiredTypes = ["A-1","A-2","A-3","B-1","B-2","B-3","B-4","C-1","C-2","C-3","D-1","D-2","D-3","D-4","E-1","E-2","E-3","E-4","F-1","F-2","F-3","F-4","G-1","G-2","G-3"];
const errors = [];
const fail = (message) => errors.push(message);
const isNonEmptyString = (value) => typeof value === "string" && value.trim().length > 0;

let roster;
try {
  roster = JSON.parse(await readFile(rosterPath, "utf8"));
} catch (error) {
  console.error(`ENEMY ROSTER INVALID: cannot read JSON (${error.message})`);
  process.exit(1);
}

if (!Array.isArray(roster.profiles)) fail("profiles must be an array");
else if (roster.profiles.length !== 25) fail(`expected 25 profiles, received ${roster.profiles.length}`);

const ids = new Set();
const types = new Set();
const visualPaths = new Set();
if (roster.schema_version !== 3) fail("schema_version must be 3");
for (const [index, profile] of (roster.profiles ?? []).entries()) {
  const label = profile?.id ?? `profile[${index}]`;
  if (!isNonEmptyString(profile.id)) fail(`${label}: id is required`);
  else if (ids.has(profile.id)) fail(`${label}: duplicate id`);
  else ids.add(profile.id);
  if (!isNonEmptyString(profile.canonical_name)) fail(`${label}: canonical_name is required`);
  if (!isNonEmptyString(profile.type)) fail(`${label}: type is required`);
  else if (types.has(profile.type)) fail(`${label}: duplicate type ${profile.type}`);
  else types.add(profile.type);
  if (!Array.isArray(profile.chapters) || profile.chapters.length === 0 || profile.chapters.some((chapter) => !Number.isInteger(chapter) || chapter < 1 || chapter > 4)) fail(`${label}: chapters must contain chapter numbers 1..4`);
  if (!isNonEmptyString(profile.archetype)) fail(`${label}: archetype is required`);
  if (!Number.isFinite(profile.health) || profile.health <= 0) fail(`${label}: health must be positive`);
  if (!Number.isFinite(profile.relative_hp) || profile.relative_hp <= 0) fail(`${label}: relative_hp must be positive`);
  if (!Number.isFinite(profile.speed) || profile.speed <= 0) fail(`${label}: speed must be positive`);
  if (!Array.isArray(profile.attacks) || profile.attacks.length === 0 || profile.attacks.some((attack) => !isNonEmptyString(attack))) fail(`${label}: attacks must be a non-empty string array`);
  if (!(profile.weapon === null || (typeof profile.weapon === "object" && isNonEmptyString(profile.weapon.kind)))) fail(`${label}: weapon must be null or an object with kind`);
  if (!(profile.projectile === null || (typeof profile.projectile === "object" && isNonEmptyString(profile.projectile.kind) && typeof profile.projectile.destructible === "boolean"))) fail(`${label}: projectile must be null or an object with kind and destructible`);
  if (typeof profile.weakness !== "object" || !isNonEmptyString(profile.weakness.primary_zone) || !isNonEmptyString(profile.weakness.rule)) fail(`${label}: weakness must define primary_zone and rule`);
  if (typeof profile.dismemberment !== "boolean") fail(`${label}: dismemberment must be boolean`);
  if (typeof profile.dismemberment_profile !== "object" || !Array.isArray(profile.dismemberment_profile.parts) || !isNonEmptyString(profile.dismemberment_profile.behavior_change)) fail(`${label}: dismemberment_profile must define parts and behavior_change`);
  if (!Number.isInteger(profile.score) || profile.score < 0) fail(`${label}: score must be a non-negative integer`);
  if (!isNonEmptyString(profile.visual_base) || !profile.visual_base.startsWith("res://assets/sprites_v2/enemies/") || !profile.visual_base.endsWith("__v2__action_cycle__8dirx8f.png")) fail(`${label}: visual_base must reference its dedicated v2 enemy atlas`);
  else visualPaths.add(profile.visual_base);
  if (profile.atlas_id !== profile.id) fail(`${label}: atlas_id must equal the canonical enemy id`);
  if (profile.visual_status !== "dedicated_fan_made_v2") fail(`${label}: visual_status must be dedicated_fan_made_v2`);
  for (const field of ["identity","chapters","behavior","relative_hp","visual"]) if (!isNonEmptyString(profile.verification_status?.[field])) fail(`${label}: verification_status.${field} is required`);
}

if (visualPaths.size !== 25) fail(`expected 25 unique dedicated visual paths, received ${visualPaths.size}`);
for (const type of requiredTypes) if (!types.has(type)) fail(`missing canonical type ${type}`);
for (const type of types) if (!requiredTypes.includes(type)) fail(`unexpected canonical type ${type}`);
for (const visualPath of visualPaths) {
  try {
    await access(resolve(projectRoot, visualPath.slice("res://".length)));
  } catch {
    fail(`missing visual_base asset ${visualPath}`);
  }
}

if (errors.length > 0) {
  console.error(`ENEMY ROSTER INVALID (${errors.length} issue${errors.length === 1 ? "" : "s"})`);
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}
console.log(`ENEMY ROSTER OK: ${roster.profiles.length} profiles, ${types.size} unique types, ${visualPaths.size} dedicated directional atlases.`);
