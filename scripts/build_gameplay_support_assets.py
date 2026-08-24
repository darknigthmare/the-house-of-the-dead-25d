#!/usr/bin/env python3
"""Normalize OpenAI-generated projectiles and HUD art into runtime assets."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_MANIFEST = ROOT / "reports" / "runtime" / "environment-sources" / "projectiles_ui.json"
SOURCE_ROOT = ROOT / "reports" / "runtime" / "environment-sources" / "projectiles_ui"
OUTPUT_ROOT = ROOT / "assets" / "gameplay_v2"
RUNTIME_MANIFEST = ROOT / "data" / "assets" / "gameplay_support_manifest.json"
BUILD_REPORT = ROOT / "reports" / "runtime" / "gameplay_support_asset_build.json"

PROJECTILES = (
    "thrown_axe",
    "thrown_dagger",
    "thrown_barrel",
    "organic_spit",
    "iron_claw",
    "hermit_web_ball",
    "magician_fireball",
)
UI_ICONS = ("bullet_round", "reload_offscreen_icon")
WEAKPOINTS = ("chariot", "hangedman", "hermit", "magician")


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def fit_rgba(image: Image.Image, size: int, margin: int) -> Image.Image:
    rgba = image.convert("RGBA")
    bbox = rgba.getchannel("A").getbbox()
    if bbox is None:
        raise RuntimeError("source contains no visible pixels")
    crop = rgba.crop(bbox)
    scale = min((size - margin * 2) / crop.width, (size - margin * 2) / crop.height)
    resized = crop.resize(
        (max(1, round(crop.width * scale)), max(1, round(crop.height * scale))),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.alpha_composite(resized, ((size - resized.width) // 2, (size - resized.height) // 2))
    return canvas


def save_single(asset_id: str, category: str, size: int) -> dict[str, Any]:
    source = SOURCE_ROOT / f"{asset_id}.png"
    if not source.exists():
        raise RuntimeError(f"missing source {source}")
    with Image.open(source) as raw:
        result = fit_rgba(raw, size, max(12, size // 24))
    folder = OUTPUT_ROOT / category
    folder.mkdir(parents=True, exist_ok=True)
    output = folder / f"{asset_id}.png"
    result.save(output, optimize=True)
    return {
        "id": asset_id,
        "path": "res://" + output.relative_to(ROOT).as_posix(),
        "source_sha256": digest(source),
        "sha256": digest(output),
        "size": [size, size],
    }


def save_life_torch() -> dict[str, Any]:
    source = SOURCE_ROOT / "life_torch.png"
    with Image.open(source) as raw:
        rgba = raw.convert("RGBA")
        atlas = Image.new("RGBA", (256 * 8, 256), (0, 0, 0, 0))
        for frame in range(8):
            left = round(frame * rgba.width / 8.0)
            right = round((frame + 1) * rgba.width / 8.0)
            cell = fit_rgba(rgba.crop((left, 0, right, rgba.height)), 256, 14)
            atlas.alpha_composite(cell, (frame * 256, 0))
    folder = OUTPUT_ROOT / "ui"
    folder.mkdir(parents=True, exist_ok=True)
    output = folder / "life_torch.png"
    atlas.save(output, optimize=True)
    return {
        "id": "life_torch",
        "path": "res://" + output.relative_to(ROOT).as_posix(),
        "source_sha256": digest(source),
        "sha256": digest(output),
        "size": [2048, 256],
        "hframes": 8,
        "fps": 9.0,
    }


def main() -> int:
    if not SOURCE_MANIFEST.exists():
        print(f"Missing generation manifest: {SOURCE_MANIFEST}")
        return 1
    generation = json.loads(SOURCE_MANIFEST.read_text(encoding="utf-8"))
    records: dict[str, Any] = {
        "schema_version": 1,
        "asset_policy": "original fan-made OpenAI Images replacements; no licensed extraction",
        "projectiles": {},
        "ui": {},
        "weakpoints": {},
    }
    failures: list[str] = []
    for asset_id in PROJECTILES:
        try:
            records["projectiles"][asset_id] = save_single(asset_id, "projectiles", 512)
        except Exception as error:  # noqa: BLE001
            failures.append(f"{asset_id}: {error}")
    for asset_id in UI_ICONS:
        try:
            records["ui"][asset_id] = save_single(asset_id, "ui", 256)
        except Exception as error:  # noqa: BLE001
            failures.append(f"{asset_id}: {error}")
    try:
        records["ui"]["life_torch"] = save_life_torch()
    except Exception as error:  # noqa: BLE001
        failures.append(f"life_torch: {error}")
    for boss_id in WEAKPOINTS:
        source_id = f"weakpoint_{boss_id}"
        try:
            records["weakpoints"][boss_id] = save_single(source_id, "weakpoints", 384)
        except Exception as error:  # noqa: BLE001
            failures.append(f"{source_id}: {error}")
    records["generation_manifest_sha256"] = digest(SOURCE_MANIFEST)
    records["failures"] = failures
    RUNTIME_MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    RUNTIME_MANIFEST.write_text(json.dumps(records, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    BUILD_REPORT.parent.mkdir(parents=True, exist_ok=True)
    BUILD_REPORT.write_text(json.dumps(records, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        "GAMEPLAY SUPPORT BUILD: "
        f"{len(records['projectiles'])} projectiles, "
        f"{len(records['ui'])} UI assets, {len(records['weakpoints'])} weakpoints, "
        f"{len(failures)} failures"
    )
    for failure in failures:
        print(f"- {failure}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
