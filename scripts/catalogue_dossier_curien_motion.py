#!/usr/bin/env python3
"""Measure untouched native PNGs and reconcile the existing named-pose backlog."""
from collections import Counter
from hashlib import sha256
from pathlib import Path
import argparse
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ART = Path("assets/dossier_curien/motion_2026-11-19")
DOC = Path("docs/dossier_curien/saga/production/motion_2026-11-19")

def read(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))

def write(path, data):
    (ROOT / path).parent.mkdir(parents=True, exist_ok=True)
    (ROOT / path).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--allow-pending", action="store_true")
    args = parser.parse_args()
    settings = read(DOC / "calibration.json")
    recipes = {}
    for name in ["linda_production.json", "ex_production.json", "zr_walk_production.json", "ex_walk_corrections.json"]:
        if not (ROOT / DOC / name).exists():
            continue
        for item in read(DOC / name)["assets"]:
            key = item.get("id") or item.get("art_id", item.get("fighter_id", "")) + "_" + item["pose"]
            recipes[key] = {**item, "provenance": str(DOC / name)}
    expansion = {x["id"]: x for x in read(Path("data/assets/dossier_curien_expansion.json"))["assets"]}
    entries, pending = [], []
    for file in sorted((ROOT / ART).glob("*.png")):
        key = file.stem
        fighter, pose = key.split("_", 1)
        recipe = recipes.get(key, {})
        calibration = settings["assets"].get(key, {})
        origin = calibration.get("origin", "generated_this_wave")
        if origin == "existing_corrected_guard":
            base = expansion[fighter + "_ex_guard_v2"]
            recipe = {"sources": base["sources"], "references": [base["path"]],
                      "provenance": base["provenance"], "prompts": base["prompts"],
                      "limitations": base["limitations"]}
        elif origin == "recovered_local":
            recipe = {"provenance": str(DOC / "calibration.json"),
                      "references": calibration["references"], "source_file": calibration["source_file"],
                      "prompt_recovered": False,
                      "limitations": ["Original prompt unavailable. Native PNG recovered byte-for-byte and visually reviewed; not a new generation."]}
        elif not recipe:
            pending.append(key)
            recipe = {"provenance_pending": True, "references": [f"assets/dossier_curien/saga/{fighter}_guard.png"]}
        im = Image.open(file)
        if im.mode != "RGBA":
            raise ValueError(f"{key}: native RGBA required")
        alpha = im.getchannel("A")
        visible = alpha.point(lambda a: 255 if a >= 128 else 0)
        bbox = visible.getbbox()
        if not bbox:
            raise ValueError(f"{key}: empty silhouette")
        pixels = visible.load()
        edges = [sum(pixels[x,0] > 0 for x in range(im.width)),
                 sum(pixels[im.width-1,y] > 0 for y in range(im.height)),
                 sum(pixels[x,im.height-1] > 0 for x in range(im.width)),
                 sum(pixels[0,y] > 0 for y in range(im.height))]
        raw = file.read_bytes()
        entry = {k:v for k,v in recipe.items() if k not in ["source_generation_path","source_path","output_path"]}
        if any(isinstance(ref,dict) for ref in entry.get("references",[])):
            entry["reference_roles"] = entry["references"]
            entry["references"] = [ref["path"] if isinstance(ref,dict) else ref for ref in entry["references"]]
        entry.update({"id":key,"fighter_id":fighter,"art_id":fighter,"pose":pose,
                      "path":str(file.relative_to(ROOT)),"dimensions":list(im.size),
                      "mode":im.mode,"bytes":len(raw),"sha256":sha256(raw).hexdigest(),
                      "alpha_extrema":list(alpha.getextrema()),"alpha_bbox":list(alpha.getbbox()),
                      "visible_bbox":list(bbox),"visible_alpha_threshold":127,"opaque_edge_pixels":edges,
                      "origin":origin,"animation_complete":False,"canonical_1_to_1_certified":False,
                      "status":"visual_reviewed_runtime_calibration" if key not in pending else "provenance_pending"})
        entry["pivot_px"] = calibration.get("pivot_px", recipe.get("pivot_px",[(bbox[0]+bbox[2])//2,bbox[3]]))
        entry["standing_height_px"] = calibration.get("standing_height_px",recipe.get("standing_height_px",settings["standing_heights"].get(fighter,bbox[3]-bbox[1])))
        entry["calibration_notes"] = calibration.get("calibration_notes",recipe.get("calibration_notes","Ground pivot and standing-equivalent anatomical scale; native pixels remain unchanged."))
        for field in ["emitter_px","anchors_px"]:
            if field in calibration:
                entry[field] = calibration[field]
        entries.append(entry)
    if pending and not args.allow_pending:
        raise ValueError("Missing production provenance: " + ", ".join(pending))
    write(Path("data/assets/dossier_curien_motion.json"),
          {"schema_version":1,"date":"2026-11-19","repository":"darknigthmare/the-house-of-the-dead-25d",
           "scope":"Individual combat poses. Intermediate animation frames remain; no canonical 1:1 certification.",
           "provisional":bool(pending),"summary":{"assets":len(entries),"bytes":sum(x["bytes"] for x in entries),
           "by_origin":dict(Counter(x["origin"] for x in entries)),"unique_sha256":len({x["sha256"] for x in entries})},"assets":entries})
    old = read(Path("docs/dossier_curien/saga/production/MANQUANTS_2026-11-19.json"))
    available = {x["id"]:x for x in entries}
    characters,resolved = [],[]
    for character in old["characters"]:
        char = dict(character)
        gaps = []
        for gap in character["missing_poses"]:
            key = character["id"] + "_" + gap["pose"]
            if key in available:
                resolved.append({"fighter_id":character["id"],"pose":gap["pose"],"legacy_path":gap["path"],"runtime_path":available[key]["path"]})
            else:
                gaps.append(gap)
        char["missing_poses"] = gaps
        char["motion_pose_paths"] = {x["pose"]:x["path"] for x in entries if x["fighter_id"] == character["id"]}
        char["present_poses"] = sorted(set(character.get("present_poses", [])) | set(char["motion_pose_paths"]))
        characters.append(char)
    linda_gaps = []
    for pose in ["jump_rise","jump_fall","block","throw","victory","taunt","finish","reload"]:
        key = "linda_" + pose
        if key in available:
            resolved.append({"fighter_id":"linda","pose":pose,"runtime_path":available[key]["path"]})
        else:
            linda_gaps.append({"pose":pose,"path":str(ART/(key+".png"))})
    linda_motion = {x["pose"]:x["path"] for x in entries if x["fighter_id"] == "linda"}
    linda_previous = {x["pose"] for x in expansion.values() if x["id"].startswith("linda_") and x.get("pose")}
    characters.append({"id":"linda","name":"Linda Rotta","game":"zombie_revenge",
                       "present_poses":sorted(linda_previous | set(linda_motion) | {"guard"}),
                       "motion_pose_paths":linda_motion,"missing_poses":linda_gaps})
    counts = Counter(gap["pose"] for char in characters for gap in char["missing_poses"])
    write(DOC/"MANQUANTS.json",
          {"schema_version":1,"date":"2026-11-19","baseline_named_pose_gaps":299,
           "remaining_named_pose_gaps":sum(counts.values()),"resolved_named_pose_gaps":len(resolved),
           "by_pose":dict(sorted(counts.items())),"resolved":resolved,"characters":characters,
           "historical_masters_unrecovered":204,"existing_arenas":18,"missing_existing_arena_layers":0,
           "scope_note":"Minimum named poses only. Intermediate frames, additional moves, bestiary animation, new stages and unverified costumes are separate work."})
    print(json.dumps({"motion_assets":len(entries),"pending_provenance":pending,
                      "remaining_minimum":sum(counts.values()),"resolved_minimum":len(resolved)}))

if __name__ == "__main__":
    main()
