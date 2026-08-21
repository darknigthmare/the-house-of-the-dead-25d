import fs from "node:fs";

const CAMPAIGN_PATH = "data/runtime/campaign_timeline.json";
const EXPECTED_SCIENTISTS = Object.freeze({
  chapter_01: 6,
  chapter_02: 6,
  chapter_03: 3,
  chapter_04: 0,
});
const REQUIRED_BOSS_NODES = Object.freeze({
  chapter_01: ["chariot_battle"],
  chapter_02: ["hangedman_battle"],
  chapter_03: ["hermit_battle"],
  chapter_04: ["chariot_rematch", "hangedman_rematch", "magician_battle"],
});

const campaign = JSON.parse(fs.readFileSync(CAMPAIGN_PATH, "utf8"));
let failed = false;

const fail = (message) => {
  console.error(`ERROR: ${message}`);
  failed = true;
};

for (const chapter of campaign.chapters ?? []) {
  const expectedScientists = EXPECTED_SCIENTISTS[chapter.id];
  if (expectedScientists === undefined) {
    fail(`${chapter.id}: no expected scientist count configured`);
    continue;
  }
  if (chapter.rescues_expected !== expectedScientists) {
    fail(`${chapter.id}: rescues_expected=${chapter.rescues_expected}, expected ${expectedScientists}`);
  }

  const nodes = new Map((chapter.nodes ?? []).map((node) => [node.id, node]));
  if (nodes.size !== chapter.nodes.length) fail(`${chapter.id}: duplicate node id`);

  for (const node of chapter.nodes) {
    if (node.type === "boss" && node.civilian) {
      fail(`${chapter.id}/${node.id}: civilian placed in a boss node`);
    }
    if (node.civilian && !(node.spawns ?? []).some((spawn) => spawn.targets_civilian === true)) {
      fail(`${chapter.id}/${node.id}: civilian has no explicitly targeted attacker`);
    }
  }

  const routes = [];
  const globallyVisited = new Set();
  const visit = (nodeId, path, scientistCount) => {
    if (nodeId === "chapter_complete") {
      routes.push({ path, scientistCount });
      return;
    }
    const node = nodes.get(nodeId);
    if (!node) {
      fail(`${chapter.id}: missing node ${nodeId}`);
      return;
    }
    if (path.includes(nodeId)) {
      fail(`${chapter.id}: cycle ${[...path, nodeId].join(" -> ")}`);
      return;
    }

    globallyVisited.add(nodeId);
    const nextPath = [...path, nodeId];
    const nextCount = scientistCount + (node.civilian ? 1 : 0);
    const exits = [...new Set([node.next, node.next_success, node.next_failure].filter(Boolean))];
    if (exits.length === 0) {
      fail(`${chapter.id}/${node.id}: route cannot reach chapter_complete`);
      return;
    }
    for (const exit of exits) visit(exit, nextPath, nextCount);
  };

  visit(chapter.start, [], 0);
  if (routes.length === 0) fail(`${chapter.id}: no complete playable route`);

  const requiredBossNodes = REQUIRED_BOSS_NODES[chapter.id] ?? [];
  for (const route of routes) {
    if (route.scientistCount !== expectedScientists) {
      fail(`${chapter.id}: route has ${route.scientistCount} scientists, expected ${expectedScientists}: ${route.path.join(" -> ")}`);
    }
    const reachesExpectedBoss = route.path.some((nodeId) => {
      const node = nodes.get(nodeId);
      return node?.type === "boss" && node.boss === chapter.boss;
    });
    if (!reachesExpectedBoss) {
      fail(`${chapter.id}: route does not reach expected boss ${chapter.boss}: ${route.path.join(" -> ")}`);
    }
    for (const bossNodeId of requiredBossNodes) {
      if (!route.path.includes(bossNodeId)) {
        fail(`${chapter.id}: route misses required boss node ${bossNodeId}: ${route.path.join(" -> ")}`);
      }
    }
  }

  for (const nodeId of nodes.keys()) {
    if (!globallyVisited.has(nodeId)) fail(`${chapter.id}: unreachable node ${nodeId}`);
  }

  const counts = routes.map((route) => route.scientistCount);
  const minimum = counts.length ? Math.min(...counts) : 0;
  const maximum = counts.length ? Math.max(...counts) : 0;
  console.log(
    `${chapter.id}: paths=${routes.length} scientists min=${minimum} max=${maximum} ` +
      `bosses=${requiredBossNodes.join(",")}`,
  );
}

if (failed) {
  process.exitCode = 1;
} else {
  console.log("Campaign route verification passed.");
}
