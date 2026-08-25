#!/usr/bin/env python3
"""Build deterministic runtime textures from ignored OpenAI Images sources.

The generated source files remain under reports/runtime/environment-sources.
This script produces stable, reviewable runtime assets without contacting a
network service: seamless material maps, compact PBR helpers and two-state
destructible sprites.
"""

from __future__ import annotations

from collections import deque
import hashlib
import json
import math
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageEnhance, ImageFilter, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "reports" / "runtime" / "environment-sources"
OUTPUT_ROOT = ROOT / "assets" / "environments_v2"
PROVENANCE_PATH = ROOT / "data" / "assets" / "environment_generation_provenance.json"
REPORT_PATH = ROOT / "reports" / "runtime" / "environment_asset_build.json"

MATERIAL_SPECS: dict[str, dict[str, float]] = {
    "garden_mud_moss": {"roughness": 0.94, "metallic": 0.00, "normal": 0.55},
    "garden_flagstone": {"roughness": 0.88, "metallic": 0.00, "normal": 0.72},
    "estate_weathered_stone": {"roughness": 0.91, "metallic": 0.00, "normal": 0.62},
    "mansion_damp_plaster": {"roughness": 0.86, "metallic": 0.00, "normal": 0.42},
    "mansion_dark_wood_panel": {"roughness": 0.72, "metallic": 0.00, "normal": 0.48},
    "mansion_marble_floor": {"roughness": 0.43, "metallic": 0.00, "normal": 0.26},
    "mansion_worn_red_carpet": {"roughness": 0.96, "metallic": 0.00, "normal": 0.32},
    "mansion_oak_door": {"roughness": 0.78, "metallic": 0.00, "normal": 0.53},
    "library_dark_oak_shelf": {"roughness": 0.75, "metallic": 0.00, "normal": 0.49},
    "sewer_wet_brick": {"roughness": 0.82, "metallic": 0.00, "normal": 0.76},
    "sewer_slick_stone": {"roughness": 0.58, "metallic": 0.00, "normal": 0.63},
    "sewer_rusted_iron": {"roughness": 0.83, "metallic": 0.62, "normal": 0.71},
    "roof_weathered_slate": {"roughness": 0.89, "metallic": 0.00, "normal": 0.66},
    "roof_gothic_stone": {"roughness": 0.91, "metallic": 0.00, "normal": 0.61},
    "lab_painted_metal": {"roughness": 0.61, "metallic": 0.54, "normal": 0.43},
    "lab_grated_floor": {"roughness": 0.69, "metallic": 0.72, "normal": 0.78},
    "lab_rusted_pipe": {"roughness": 0.76, "metallic": 0.66, "normal": 0.64},
    "lab_grimy_glass": {"roughness": 0.24, "metallic": 0.00, "normal": 0.16},
    "lab_bio_machine_panel": {"roughness": 0.57, "metallic": 0.48, "normal": 0.52},
    "hermit_web_membrane": {"roughness": 0.71, "metallic": 0.00, "normal": 0.74},
}

DESTRUCTIBLE_IDS = (
    "c01_foyer_door_lock",
    "c02_chained_hatch_plate",
    "c03_elevator_route_switch",
    "c03_vent_key_container",
    "c04_bonus_gate_seal",
    "c04_emergency_supply_crate",
)

PROP_SPECS: dict[str, dict[str, Any]] = {
    "mansion_chandelier": {"frames": 2, "pixel_size": 0.0064, "world_scale": 0.34},
    "mansion_sconce": {"frames": 2, "pixel_size": 0.0055, "world_scale": 0.18},
    "mansion_double_door": {"frames": 2, "pixel_size": 0.0070, "world_scale": 0.47},
    "library_bookcase": {"frames": 1, "pixel_size": 0.0065, "world_scale": 0.50},
    "mansion_portrait": {"frames": 1, "pixel_size": 0.0052, "world_scale": 0.32},
    "lab_control_console": {"frames": 2, "pixel_size": 0.0065, "world_scale": 0.32},
    "estate_gate": {"frames": 2, "pixel_size": 0.0065, "world_scale": 0.51},
    "garden_lamp": {"frames": 2, "pixel_size": 0.0062, "world_scale": 0.35},
    "dead_tree": {"frames": 1, "pixel_size": 0.0072, "world_scale": 0.60},
    "stone_bridge_arch": {"frames": 1, "pixel_size": 0.0074, "world_scale": 0.63},
    "roof_gargoyle": {"frames": 1, "pixel_size": 0.0064, "world_scale": 0.30},
    "lab_specimen_tank": {"frames": 2, "pixel_size": 0.0064, "world_scale": 0.50},
    "lab_pipe_cluster": {"frames": 1, "pixel_size": 0.0065, "world_scale": 0.46},
    "lab_vent_fan": {"frames": 2, "pixel_size": 0.0062, "world_scale": 0.30},
}

MATTE_REPAIR_PROPS = frozenset({"estate_gate", "mansion_chandelier", "mansion_sconce"})
EDGE_DESPILL_PROPS = MATTE_REPAIR_PROPS | frozenset({"garden_lamp"})
MATTE_COMPONENT_MIN_PIXELS = 500


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def square_source(image: Image.Image, size: int) -> Image.Image:
    rgb = image.convert("RGB")
    edge = min(rgb.size)
    left = (rgb.width - edge) // 2
    top = (rgb.height - edge) // 2
    cropped = rgb.crop((left, top, left + edge, top + edge))
    return cropped.resize((size, size), Image.Resampling.LANCZOS)


def _edge_match(array: np.ndarray, width: int = 18) -> np.ndarray:
    result = array.astype(np.float32)
    for offset in range(width):
        weight = 0.5 * (1.0 + math.cos(math.pi * offset / max(1, width - 1)))
        average_x = (result[:, offset, :] + result[:, -1 - offset, :]) * 0.5
        result[:, offset, :] = result[:, offset, :] * (1.0 - weight) + average_x * weight
        result[:, -1 - offset, :] = result[:, -1 - offset, :] * (1.0 - weight) + average_x * weight
        average_y = (result[offset, :, :] + result[-1 - offset, :, :]) * 0.5
        result[offset, :, :] = result[offset, :, :] * (1.0 - weight) + average_y * weight
        result[-1 - offset, :, :] = result[-1 - offset, :, :] * (1.0 - weight) + average_y * weight
    return np.clip(result, 0.0, 255.0).astype(np.uint8)


def make_seamless(image: Image.Image, size: int = 1024) -> Image.Image:
    base = square_source(image, size)
    shifted = Image.fromarray(
        np.roll(np.roll(np.asarray(base), size // 2, axis=0), size // 2, axis=1),
        mode="RGB",
    )
    blurred = shifted.filter(ImageFilter.GaussianBlur(radius=9.0))
    yy, xx = np.mgrid[0:size, 0:size]
    distance = np.minimum(abs(xx - size // 2), abs(yy - size // 2)).astype(np.float32)
    seam_mask = np.clip((34.0 - distance) / 34.0, 0.0, 1.0)
    seam_mask = (seam_mask * seam_mask * 176.0).astype(np.uint8)
    blended = Image.composite(blurred, shifted, Image.fromarray(seam_mask, mode="L"))
    return Image.fromarray(_edge_match(np.asarray(blended)), mode="RGB")


def derive_normal(albedo: Image.Image, strength: float, size: int = 512) -> Image.Image:
    height = np.asarray(
        ImageOps.grayscale(albedo).resize((size, size), Image.Resampling.LANCZOS),
        dtype=np.float32,
    ) / 255.0
    dx = np.gradient(height, axis=1) * strength * 8.0
    dy = np.gradient(height, axis=0) * strength * 8.0
    normal = np.dstack((-dx, -dy, np.ones_like(height)))
    normal /= np.maximum(np.linalg.norm(normal, axis=2, keepdims=True), 1e-6)
    encoded = ((normal * 0.5 + 0.5) * 255.0).astype(np.uint8)
    return Image.fromarray(encoded, mode="RGB")


def derive_orm(albedo: Image.Image, roughness: float, metallic: float, size: int = 256) -> Image.Image:
    gray = np.asarray(
        ImageOps.grayscale(albedo).resize((size, size), Image.Resampling.LANCZOS),
        dtype=np.float32,
    ) / 255.0
    soft = np.asarray(
        Image.fromarray((gray * 255.0).astype(np.uint8)).filter(ImageFilter.GaussianBlur(7.0)),
        dtype=np.float32,
    ) / 255.0
    ao = np.clip(0.78 + (gray - soft) * 0.8, 0.48, 1.0)
    rough = np.clip(roughness + (0.5 - gray) * 0.08, 0.04, 1.0)
    metal = np.full_like(gray, metallic)
    orm = np.dstack((ao, rough, metal))
    return Image.fromarray((orm * 255.0).astype(np.uint8), mode="RGB")


def find_material_source(asset_id: str) -> Path:
    matches = sorted(SOURCE_ROOT.glob(f"materials_*/*{asset_id}*.png"))
    if len(matches) != 1:
        raise RuntimeError(f"Expected one source for {asset_id}, found {len(matches)}")
    return matches[0]


def build_material(asset_id: str, spec: dict[str, float]) -> dict[str, Any]:
    source = find_material_source(asset_id)
    with Image.open(source) as raw:
        albedo = make_seamless(raw)
    albedo = ImageEnhance.Contrast(albedo).enhance(1.04)
    normal = derive_normal(albedo, spec["normal"])
    orm = derive_orm(albedo, spec["roughness"], spec["metallic"])
    target = OUTPUT_ROOT / "materials" / asset_id
    target.mkdir(parents=True, exist_ok=True)
    albedo_path = target / f"{asset_id}_albedo.png"
    normal_path = target / f"{asset_id}_normal.png"
    orm_path = target / f"{asset_id}_orm.png"
    albedo.save(albedo_path, optimize=True)
    normal.save(normal_path, optimize=True)
    orm.save(orm_path, optimize=True)
    return {
        "id": asset_id,
        "kind": "tileable_material",
        "source": str(source.relative_to(ROOT)).replace("\\", "/"),
        "source_sha256": sha256(source),
        "outputs": {
            "albedo": str(albedo_path.relative_to(ROOT)).replace("\\", "/"),
            "normal": str(normal_path.relative_to(ROOT)).replace("\\", "/"),
            "orm": str(orm_path.relative_to(ROOT)).replace("\\", "/"),
        },
        "dimensions": {"albedo": [1024, 1024], "normal": [512, 512], "orm": [256, 256]},
        "roughness": spec["roughness"],
        "metallic": spec["metallic"],
        "generator": "OpenAI Images built-in source plus deterministic local processing",
        "status": "original_fan_made",
    }


def ensure_alpha(image: Image.Image) -> Image.Image:
    """Recover transparency without erasing light details inside the prop.

    Some ImageGen downloads flatten the preview's pale checkerboard into RGB.
    A global color key would punch holes in stone, candle wax, portraits and
    specular highlights. Only checker-like pixels connected to an image edge
    are background. A narrow matte band then restores antialiasing and removes
    the bright fringe introduced by the flattened checkerboard.
    """
    rgba = image.convert("RGBA")
    alpha = np.asarray(rgba.getchannel("A"))
    if int(alpha.min()) < 250:
        return rgba
    pixels = np.asarray(rgba).copy()
    rgb_u8 = pixels[:, :, :3]
    high = rgb_u8.max(axis=2).astype(np.int16)
    low = rgb_u8.min(axis=2).astype(np.int16)
    checker_candidate = (low >= 215) & ((high - low) <= 28)
    height, width = checker_candidate.shape
    exterior = np.zeros((height, width), dtype=bool)
    frontier: deque[tuple[int, int]] = deque()

    def queue_if_background(y: int, x: int) -> None:
        if checker_candidate[y, x] and not exterior[y, x]:
            exterior[y, x] = True
            frontier.append((y, x))

    for x in range(width):
        queue_if_background(0, x)
        queue_if_background(height - 1, x)
    for y in range(1, height - 1):
        queue_if_background(y, 0)
        queue_if_background(y, width - 1)
    while frontier:
        y, x = frontier.popleft()
        if y > 0:
            queue_if_background(y - 1, x)
        if y + 1 < height:
            queue_if_background(y + 1, x)
        if x > 0:
            queue_if_background(y, x - 1)
        if x + 1 < width:
            queue_if_background(y, x + 1)

    alpha_out = np.full((height, width), 255, dtype=np.uint8)
    alpha_out[exterior] = 0
    dilated = np.asarray(
        Image.fromarray((exterior.astype(np.uint8) * 255), mode="L").filter(ImageFilter.MaxFilter(7))
    ) > 0
    matte_band = dilated & ~exterior
    rgb = rgb_u8.astype(np.float32) / 255.0
    brightness = rgb.mean(axis=2)
    chroma = rgb.max(axis=2) - rgb.min(axis=2)
    pale = np.clip((brightness - 0.53) / 0.43, 0.0, 1.0)
    neutral = np.clip((0.24 - chroma) / 0.24, 0.0, 1.0)
    matte_strength = pale * neutral
    feather = np.clip((1.0 - matte_strength) * 255.0, 18.0, 255.0).astype(np.uint8)
    alpha_out[matte_band] = np.minimum(alpha_out[matte_band], feather[matte_band])

    partial = (alpha_out > 0) & (alpha_out < 255)
    if partial.any():
        alpha_float = np.maximum(alpha_out.astype(np.float32) / 255.0, 0.07)
        matte_rgb = 246.0
        recovered = (rgb_u8.astype(np.float32) - (1.0 - alpha_float[:, :, None]) * matte_rgb) / alpha_float[:, :, None]
        pixels[:, :, :3][partial] = np.clip(recovered, 0.0, 255.0).astype(np.uint8)[partial]
    pixels[:, :, 3] = alpha_out
    pixels[exterior, :3] = 0
    return Image.fromarray(pixels, mode="RGBA")


def remove_large_neutral_matte(image: Image.Image, minimum_pixels: int = MATTE_COMPONENT_MIN_PIXELS) -> Image.Image:
    """Remove only large connected pale-neutral remnants from transparent props.

    The threshold intentionally preserves small candle/flame highlights while
    clearing baked checkerboard or white-card regions enclosed by ironwork.
    """
    pixels = np.asarray(image.convert("RGBA")).copy()
    rgb = pixels[:, :, :3]
    alpha = pixels[:, :, 3]
    high = rgb.max(axis=2).astype(np.int16)
    low = rgb.min(axis=2).astype(np.int16)
    candidate = (alpha > 0) & (low >= 220) & ((high - low) <= 32)
    visited = np.zeros(candidate.shape, dtype=bool)
    remove = np.zeros(candidate.shape, dtype=bool)
    height, width = candidate.shape
    for start_y, start_x in zip(*np.where(candidate)):
        if visited[start_y, start_x]:
            continue
        frontier: deque[tuple[int, int]] = deque([(int(start_y), int(start_x))])
        visited[start_y, start_x] = True
        component: list[tuple[int, int]] = []
        while frontier:
            y, x = frontier.popleft()
            component.append((y, x))
            for next_y, next_x in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if (
                    0 <= next_y < height
                    and 0 <= next_x < width
                    and candidate[next_y, next_x]
                    and not visited[next_y, next_x]
                ):
                    visited[next_y, next_x] = True
                    frontier.append((next_y, next_x))
        if len(component) >= minimum_pixels:
            component_y, component_x = zip(*component)
            remove[component_y, component_x] = True
    pixels[remove] = 0
    return Image.fromarray(pixels, mode="RGBA")


def despill_neutral_edge(image: Image.Image) -> Image.Image:
    """Suppress pale neutral matte pixels only on the transparent boundary.

    The adjacency constraint protects internal candle, glass and metal
    highlights. Strong white fringe becomes transparent; weaker neutral spill
    is attenuated instead of cutting into the prop silhouette.
    """
    pixels = np.asarray(image.convert("RGBA")).copy()
    alpha = pixels[:, :, 3]
    transparent = alpha == 0
    adjacent_to_transparency = np.asarray(
        Image.fromarray((transparent.astype(np.uint8) * 255), mode="L").filter(ImageFilter.MaxFilter(3))
    ) > 0
    rgb = pixels[:, :, :3].astype(np.float32) / 255.0
    brightness = rgb.min(axis=2)
    chroma = rgb.max(axis=2) - rgb.min(axis=2)
    pale = np.clip((brightness - 0.62) / 0.38, 0.0, 1.0)
    neutral = np.clip((0.16 - chroma) / 0.16, 0.0, 1.0)
    strength = pale * neutral
    edge = adjacent_to_transparency & (alpha > 0)
    strong_matte = edge & (strength >= 0.72)
    alpha_out = alpha.astype(np.float32)
    alpha_out[edge & ~strong_matte] *= 1.0 - strength[edge & ~strong_matte] * 0.88
    alpha_out[strong_matte] = 0.0
    alpha_out[alpha_out < 8.0] = 0.0
    pixels[:, :, 3] = np.clip(alpha_out, 0.0, 255.0).astype(np.uint8)
    pixels[pixels[:, :, 3] == 0, :3] = 0
    return Image.fromarray(pixels, mode="RGBA")


def fit_transparent(image: Image.Image, size: int = 1024, margin: int = 28) -> Image.Image:
    rgba = ensure_alpha(image)
    bbox = rgba.getchannel("A").getbbox()
    if bbox is None:
        raise RuntimeError("Transparent prop source contains no visible pixels")
    crop = rgba.crop(bbox)
    scale = min((size - 2 * margin) / crop.width, (size - 2 * margin) / crop.height)
    resized = crop.resize(
        (max(1, int(crop.width * scale)), max(1, int(crop.height * scale))),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    x = (size - resized.width) // 2
    y = size - margin - resized.height
    canvas.alpha_composite(resized, (x, y))
    return canvas


def build_destructible(asset_id: str) -> dict[str, Any]:
    source = SOURCE_ROOT / "destructibles" / f"{asset_id}.png"
    if not source.exists():
        raise RuntimeError(f"Missing destructible source: {source}")
    with Image.open(source) as raw:
        midpoint = raw.width // 2
        intact = fit_transparent(raw.crop((0, 0, midpoint, raw.height)))
        broken = fit_transparent(raw.crop((midpoint, 0, raw.width, raw.height)))
    target = OUTPUT_ROOT / "destructibles" / asset_id
    target.mkdir(parents=True, exist_ok=True)
    intact_path = target / f"{asset_id}_intact.png"
    broken_path = target / f"{asset_id}_broken.png"
    intact.save(intact_path, optimize=True)
    broken.save(broken_path, optimize=True)
    return {
        "id": asset_id,
        "kind": "two_state_destructible",
        "source": str(source.relative_to(ROOT)).replace("\\", "/"),
        "source_sha256": sha256(source),
        "outputs": {
            "intact": str(intact_path.relative_to(ROOT)).replace("\\", "/"),
            "broken": str(broken_path.relative_to(ROOT)).replace("\\", "/"),
        },
        "dimensions": {"intact": [1024, 1024], "broken": [1024, 1024]},
        "generator": "OpenAI Images built-in source plus deterministic split/crop",
        "status": "original_fan_made",
    }


def find_prop_source(asset_id: str) -> Path:
    matches = sorted(SOURCE_ROOT.glob(f"props_*/*{asset_id}*.png"))
    if len(matches) != 1:
        raise RuntimeError(f"Expected one prop source for {asset_id}, found {len(matches)}")
    return matches[0]


def build_prop(asset_id: str, spec: dict[str, Any]) -> dict[str, Any]:
    source = find_prop_source(asset_id)
    frame_count = int(spec.get("frames", 1))
    with Image.open(source) as raw:
        rgba = ensure_alpha(raw)
        frames: list[Image.Image] = []
        if frame_count == 2:
            midpoint = rgba.width // 2
            frames.append(fit_transparent(rgba.crop((0, 0, midpoint, rgba.height))))
            frames.append(fit_transparent(rgba.crop((midpoint, 0, rgba.width, rgba.height))))
        else:
            frames.append(fit_transparent(rgba))
    if asset_id in MATTE_REPAIR_PROPS:
        frames = [remove_large_neutral_matte(frame) for frame in frames]
    if asset_id in EDGE_DESPILL_PROPS:
        frames = [despill_neutral_edge(frame) for frame in frames]
    if asset_id == "garden_lamp" and len(frames) == 2:
        frames[1].putalpha(ImageChops.darker(frames[1].getchannel("A"), frames[0].getchannel("A")))
    atlas = Image.new("RGBA", (1024 * frame_count, 1024), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        atlas.alpha_composite(frame, (index * 1024, 0))
    target = OUTPUT_ROOT / "props" / asset_id
    target.mkdir(parents=True, exist_ok=True)
    output_path = target / f"{asset_id}.png"
    atlas.save(output_path, optimize=True)
    return {
        "id": asset_id,
        "kind": "environment_prop",
        "source": str(source.relative_to(ROOT)).replace("\\", "/"),
        "source_sha256": sha256(source),
        "outputs": {"atlas": str(output_path.relative_to(ROOT)).replace("\\", "/")},
        "dimensions": [1024 * frame_count, 1024],
        "frames": frame_count,
        "pixel_size": float(spec.get("pixel_size", 0.0065)),
        "world_scale": float(spec.get("world_scale", 1.0)),
        "processing": (
            "authored dual-state atlas with checkerboard alpha recovery, neutral edge despill and silhouette clamp"
            if asset_id == "garden_lamp"
            else ("large neutral matte cleanup plus neutral edge despill" if asset_id in MATTE_REPAIR_PROPS else "alpha/crop normalization")
        ),
        "generator": "OpenAI Images built-in source plus deterministic alpha/matte/despill/crop",
        "status": "original_fan_made",
    }


def main() -> int:
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    records: list[dict[str, Any]] = []
    failures: list[str] = []
    for asset_id, spec in MATERIAL_SPECS.items():
        try:
            records.append(build_material(asset_id, spec))
        except Exception as error:  # noqa: BLE001 - report every production gap together
            failures.append(f"{asset_id}: {error}")
    for asset_id in DESTRUCTIBLE_IDS:
        try:
            records.append(build_destructible(asset_id))
        except Exception as error:  # noqa: BLE001 - report every production gap together
            failures.append(f"{asset_id}: {error}")

    for asset_id, spec in PROP_SPECS.items():
        try:
            records.append(build_prop(asset_id, spec))
        except Exception as error:  # noqa: BLE001 - report every production gap together
            failures.append(f"{asset_id}: {error}")

    payload = {
        "schema_version": 1,
        "generated_asset_policy": "original fan-made replacements; no ROM/video extraction",
        "assets": records,
        "failures": failures,
    }
    PROVENANCE_PATH.parent.mkdir(parents=True, exist_ok=True)
    PROVENANCE_PATH.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"ENVIRONMENT ASSET BUILD: {len(records)} assets, {len(failures)} failures")
    for failure in failures:
        print(f"- {failure}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
