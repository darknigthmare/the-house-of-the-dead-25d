#!/usr/bin/env python3
"""Catalogue native lot-6 outputs and reconcile named gaps; never edits pixels."""
import hashlib
import json
from collections import Counter
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[5]
DOC = Path(__file__).resolve().parent
ART = Path("assets/dossier_curien/motion_2026-11-20_lot6")
BASELINE = Path("docs/dossier_curien/saga/production/motion_2026-11-19/MANQUANTS.json")
CALIBRATION = json.loads((DOC / "calibration.json").read_text())
CONSUMPTION = {
    "jump_rise": "action empty; altitude > 0 or vy > 0; vy > 0",
    "jump_fall": "action empty; altitude > 0; vy <= 0",
    "crouch": "action empty; grounded; crouching; not guarding",
    "crouch_guard": "action empty; grounded; crouching and guarding",
    "block": "action empty; grounded; not crouching; block_ticks > 0 or stationary guard",
    "throw": "action == throw; dedicated art precedes generic attack keyframes",
    "victory": "arena winner in finish, round or result phase (including its paused equivalent)",
    "taunt": "action empty; grounded; not crouching, moving or guarding; taunt_ticks > 0",
    "finish": "arena winner in cinematic phase (including its paused equivalent)",
}


def read(path):
    return json.loads((ROOT / path).read_text())


def write(path, value):
    (ROOT / path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")


assets = []
reference = CALIBRATION["reference"]
for pose, calibration in CALIBRATION["poses"].items():
    identity = "rikiya_" + pose
    path = ART / (identity + ".png")
    receipt_path = DOC.relative_to(ROOT) / (identity + "_generation.json")
    receipt = read(receipt_path)
    raw = (ROOT / path).read_bytes()
    source = Path(receipt["source_generation_path"])
    digest = hashlib.sha256(raw).hexdigest()
    if source.exists():
        assert hashlib.sha256(source.read_bytes()).hexdigest() == digest, identity + " native source differs"
    receipt["native_sha256"] = digest
    receipt["native_bytes"] = len(raw)
    receipt["native_output_copied_without_pixel_changes"] = True
    write(receipt_path, receipt)
    image = Image.open(ROOT / path)
    assert image.mode == "RGBA", identity + " requires native RGBA"
    alpha = image.getchannel("A")
    visible = alpha.point(lambda value: 255 if value > 127 else 0)
    boxes = [(0, 0, image.width, 1), (image.width - 1, 0, image.width, image.height),
             (0, image.height - 1, image.width, image.height), (0, 0, 1, image.height)]
    edges = [sum(visible.crop(box).histogram()[128:]) for box in boxes]
    assert alpha.getextrema()[0] == 0 and not any(edges), identity + " transparency or visible clipping"
    span = calibration["chin_y_px"] - calibration["head_crown_y_px"]
    standing_height = round(reference["standing_height_px"] * span / reference["head_landmark_span_px"], 3)
    assets.append({
        "id": identity, "fighter_id": "rikiya", "art_id": "rikiya", "pose": pose,
        "path": str(path), "dimensions": list(image.size), "mode": image.mode,
        "bytes": len(raw), "sha256": digest, "alpha_extrema": list(alpha.getextrema()),
        "alpha_bbox": list(alpha.getbbox()), "visible_bbox": list(visible.getbbox()),
        "visible_alpha_threshold": 127, "opaque_edge_pixels": edges,
        "pivot_px": calibration["pivot_px"], "standing_height_px": standing_height,
        "anchors_px": calibration["anchors_px"],
        "calibration_notes": "Native head landmark span %d px versus reference %d px; standing-equivalent scale retained for crouched/airborne limbs. No emitter: empty-hand action. See calibration.json for measured support anchors and limitations." % (span, reference["head_landmark_span_px"]),
        "calibration_provenance": str(DOC.relative_to(ROOT) / "calibration.json"),
        "provenance": str(receipt_path), "references": [reference["path"]],
        "origin": "generated_imagegen_native", "animation_complete": False,
        "canonical_1_to_1_certified": False,
        "status": "native_pixels_visually_reviewed_runtime_calibration",
        "runtime_consumption": {"selector": "src/dossier_curien/presentation.gd:pose_suffix", "condition": CONSUMPTION[pose]},
    })

assert len(assets) == 9 and len({a["sha256"] for a in assets}) == 9
manifest = {
    "schema_version": 1, "date": "2026-11-20", "repository": "darknigthmare/the-house-of-the-dead-25d",
    "source_commit": "7f14d7b49dcc8d884629245eef71e65198665b8e",
    "scope": "Nine Rikiya base keyframes consumed by existing combat, taunt and match-end states. Dated additive collection; historical motion manifest, art and initial six lot-6 PNGs preserved. Rikiya's tracked named-pose row is complete; intermediate animation frames remain.",
    "provisional": CALIBRATION["provisional"],
    "summary": {"assets": len(assets), "bytes": sum(a["bytes"] for a in assets), "unique_sha256": len(assets),
                "by_origin": {"generated_imagegen_native": len(assets)}},
    "assets": assets,
}
write(Path("data/assets/dossier_curien_motion_2026-11-20_lot6.json"), manifest)

gaps = read(BASELINE)
prior_count = gaps["remaining_named_pose_gaps"]
resolved = []
by_pose = {a["pose"]: a for a in assets}
for character in gaps["characters"]:
    if character["id"] != "rikiya":
        continue
    prior = {item["pose"]: item for item in character["missing_poses"]}
    assert set(by_pose).issubset(prior), "Only actual baseline gaps may be resolved"
    for pose, asset in by_pose.items():
        record = {"fighter_id": "rikiya", "pose": pose, "legacy_path": prior[pose]["path"],
                  "runtime_path": asset["path"], "runtime_condition": asset["runtime_consumption"]["condition"],
                  "provenance": asset["provenance"]}
        resolved.append(record)
        character["motion_pose_paths"][pose] = asset["path"]
    character["missing_poses"] = [p for p in character["missing_poses"] if p["pose"] not in by_pose]
    character["present_poses"] = sorted(set(character["present_poses"]) | set(by_pose))
    character["named_pose_matrix_complete"] = not character["missing_poses"]
    character["animation_complete"] = False

counter = Counter(item["pose"] for character in gaps["characters"] for item in character["missing_poses"])
gaps["date"] = "2026-11-20"
gaps["source_baseline"] = str(BASELINE)
gaps["source_baseline_sha256"] = hashlib.sha256((ROOT / BASELINE).read_bytes()).hexdigest()
gaps["prior_remaining_named_pose_gaps"] = prior_count
gaps["remaining_named_pose_gaps"] = sum(counter.values())
gaps["resolved_named_pose_gaps"] += len(resolved)
gaps["resolved_this_lot"] = resolved
gaps["resolved"].extend(resolved)
gaps["by_pose"] = dict(sorted(counter.items()))
gaps["delta"] = {"before": prior_count, "after": sum(counter.values()), "resolved": len(resolved)}
gaps["historical_environment_snapshot"] = {"source": str(BASELINE), "existing_arenas": gaps.pop("existing_arenas"),
                                         "missing_existing_arena_layers": gaps.pop("missing_existing_arena_layers")}
gaps["extension_from_initial_lot6"] = {"before": 271, "after": 268, "resolved": 3, "poses": ["victory", "taunt", "finish"], "previous_review": str(DOC.relative_to(ROOT) / "pre_extension/FINAL_REVIEW_6_POSES.json")}
gaps["scope_note"] = "Minimum named combat pose gaps only, reconciled by fighter and reachable action state. Nine new PNGs close nine previously listed Rikiya states, completing his tracked named-pose row. No complete animation, new move, playable fighter, costume, or gallery card is claimed. Intermediate frames, other actions, bestiary animation, stages and unverified costumes remain separate."
assert gaps["delta"] == {"before": 277, "after": 268, "resolved": 9}
write(DOC.relative_to(ROOT) / "MANQUANTS.json", gaps)
print(json.dumps({"assets": len(assets), "bytes": manifest["summary"]["bytes"], "gaps": gaps["delta"], "provisional": manifest["provisional"]}))
