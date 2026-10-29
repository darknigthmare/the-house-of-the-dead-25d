import fs from "node:fs";

let errors = 0;
for (let chapterNumber = 1; chapterNumber <= 4; chapterNumber += 1) {
  const id = `chapter_${String(chapterNumber).padStart(2, "0")}`;
  const graph = JSON.parse(fs.readFileSync(`data/routes/${id}_route_graph.json`, "utf8"));
  const nodes = new Map();
  for (const node of graph.nodes ?? []) {
    if (!node.id || nodes.has(node.id)) {
      console.error(`${id}: duplicate or empty node ID: ${node.id}`);
      errors++;
    }
    nodes.set(node.id, node);
  }
  const edges = new Map();
  for (const node of nodes.values()) {
    const targets = (node.next ?? []).map(item => typeof item === "string" ? item : item?.node);
    edges.set(node.id, targets);
    for (const target of targets) {
      if (target !== graph.terminal && !nodes.has(target)) {
        console.error(`${id}/${node.id}: missing target ${target}`);
        errors++;
      }
    }
  }
  if (!nodes.has(graph.start)) {
    console.error(`${id}: missing start ${graph.start}`);
    errors++;
    continue;
  }
  const seen = new Set();
  const visiting = new Set();
  let terminalReached = false;
  const walk = (id) => {
    if (id === graph.terminal) { terminalReached = true; return; }
    if (visiting.has(id)) { console.error(`${graph.chapter_id}: cycle at ${id}`); errors++; return; }
    if (seen.has(id) || !nodes.has(id)) return;
    visiting.add(id);
    for (const target of edges.get(id) ?? []) walk(target);
    visiting.delete(id);
    seen.add(id);
  };
  walk(graph.start);
  if (!terminalReached) { console.error(`${id}: terminal unreachable`); errors++; }
  for (const id of nodes.keys()) if (!seen.has(id)) { console.error(`${graph.chapter_id}: unreachable node ${id}`); errors++; }
  console.log(`${graph.chapter_id}: ${nodes.size} nodes, ${seen.size} reachable`);
}
if (errors) {
  console.error(`Route graph integrity: ${errors} error(s)`);
  process.exitCode = 1;
} else {
  console.log("Route graph integrity passed.");
}
