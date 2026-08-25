#!/usr/bin/env python3
"""Build transparent eight-frame environment-effect strips from keyed sources.

The selected OpenAI Images sources are original fan-made replacements. This
deterministic step only removes the green key, normalizes the 4x2 source grid
to an 8x1 RGBA strip, and records exact source/output provenance.
"""

from __future__ import annotations

from collections import Counter, deque
from dataclasses import dataclass
import hashlib
import json
import math
from pathlib import Path
from typing import Any

from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "reports" / "runtime" / "environment-sources"
OUTPUT_ROOT = ROOT / "assets" / "environments_v2" / "effects"
PROVENANCE_PATH = ROOT / "data" / "assets" / "animated_effect_generation_provenance.json"
FRAME_SIZE = 256
FRAME_COUNT = 8
SOURCE_COLUMNS = 4
SOURCE_ROWS = 2
CONTENT_SIZE = 240


@dataclass(frozen=True)
class EffectSpec:
    asset_id: str
    source_name: str
    generation_reference: str
    fps: float


EFFECTS = (
    EffectSpec(
        "drips",
        "animated_effect_drips.png",
        "01a00811-e655-7262-8c79-852788f57b9b/exec-4fc2df33-f942-4336-b121-9a1068b26e72.png",
        10.0,
    ),
    EffectSpec(
        "water_flow",
        "animated_effect_water_flow.png",
        "01a00811-e655-7262-8c79-852788f57b9b/exec-ba9ad960-9b27-43d4-8056-a79b64fcad44.png",
        12.0,
    ),
    EffectSpec(
        "electrical_arc",
        "animated_effect_electrical_arc.png",
        "01a00811-e655-7262-8c79-852788f57b9b/exec-0b7ed69d-2226-4d21-aa7d-dafbefd11ba8.png",
        15.0,
    ),
    EffectSpec(
        "monitor_scan",
        "animated_effect_monitor_scan.png",
        "01a00811-e655-7262-8c79-852788f57b9b/exec-d18efd19-b490-453d-94c5-9c21c1932c1e.png",
        10.0,
    ),
)


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()

def flattened_pixels(image: Image.Image) -> Any:
    """Return Pillow pixel data without warnings on current or older releases."""
    modern_getter = getattr(image, "get_flattened_data", None)
    return modern_getter() if modern_getter is not None else image.getdata()



def estimate_green_key(image: Image.Image) -> tuple[int, int, int]:
    sample = image.convert("RGB").resize((128, 128), Image.Resampling.NEAREST)
    counts = Counter(flattened_pixels(sample))
    candidates = [
        (count, color)
        for color, count in counts.items()
        if color[1] >= 120 and color[1] - max(color[0], color[2]) >= 45
    ]
    if not candidates:
        raise RuntimeError("source has no dominant green-screen key")
    return max(candidates, key=lambda item: item[0])[1]


def color_distance(left: tuple[int, int, int], right: tuple[int, int, int]) -> float:
    return math.sqrt(sum((float(a) - float(b)) ** 2 for a, b in zip(left, right)))


def remove_connected_green(cell: Image.Image, key: tuple[int, int, int]) -> Image.Image:
    rgb = cell.convert("RGB")
    width, height = rgb.size
    pixels = list(flattened_pixels(rgb))
    candidates = bytearray(width * height)
    for index, color in enumerate(pixels):
        red, green, blue = color
        dominance = green - max(red, blue)
        if green >= 90 and dominance >= 32 and color_distance(color, key) <= 178.0:
            candidates[index] = 1

    background = bytearray(width * height)
    queue: deque[int] = deque()

    def seed(index: int) -> None:
        if candidates[index] and not background[index]:
            background[index] = 1
            queue.append(index)

    for x in range(width):
        seed(x)
        seed((height - 1) * width + x)
    for y in range(height):
        seed(y * width)
        seed(y * width + width - 1)

    while queue:
        index = queue.popleft()
        x = index % width
        y = index // width
        if x > 0:
            seed(index - 1)
        if x + 1 < width:
            seed(index + 1)
        if y > 0:
            seed(index - width)
        if y + 1 < height:
            seed(index + width)

    background_image = Image.frombytes(
        "L",
        (width, height),
        bytes(255 if value else 0 for value in background),
    )
    near_background = background_image.filter(ImageFilter.MaxFilter(9))
    near_pixels = list(flattened_pixels(near_background))
    output: list[tuple[int, int, int, int]] = []
    for index, color in enumerate(pixels):
        if background[index]:
            output.append((0, 0, 0, 0))
            continue
        red, green, blue = color
        alpha = 255
        dominance = green - max(red, blue)
        if near_pixels[index] and dominance > 8:
            distance = color_distance(color, key)
            alpha = max(0, min(255, round((distance - 38.0) * 255.0 / 108.0)))
            neutral_green = max(red, blue) + 8
            if green > neutral_green:
                green = round(neutral_green + (green - neutral_green) * alpha / 255.0)
        if alpha <= 2:
            output.append((0, 0, 0, 0))
        else:
            output.append((red, green, blue, alpha))
    keyed = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    keyed.putdata(output)
    return keyed


def source_cells(image: Image.Image, key: tuple[int, int, int]) -> list[Image.Image]:
    cells: list[Image.Image] = []
    for row in range(SOURCE_ROWS):
        top = round(row * image.height / SOURCE_ROWS)
        bottom = round((row + 1) * image.height / SOURCE_ROWS)
        for column in range(SOURCE_COLUMNS):
            left = round(column * image.width / SOURCE_COLUMNS)
            right = round((column + 1) * image.width / SOURCE_COLUMNS)
            cells.append(remove_connected_green(image.crop((left, top, right, bottom)), key))
    if len(cells) != FRAME_COUNT:
        raise RuntimeError(f"expected {FRAME_COUNT} cells, received {len(cells)}")
    return cells



def align_cells_to_common_plane(cells: list[Image.Image]) -> list[Image.Image]:
    """Center equivalent panels from separate source rows without rescaling them."""
    boxes = [cell.getchannel("A").getbbox() for cell in cells]
    if any(box is None for box in boxes):
        raise RuntimeError("cannot align an empty animation cell")
    visible_boxes = [box for box in boxes if box is not None]
    common_width = max(box[2] - box[0] for box in visible_boxes)
    common_height = max(box[3] - box[1] for box in visible_boxes)
    padding = max(3, round(min(common_width, common_height) * 0.02))
    canvas_size = (common_width + padding * 2, common_height + padding * 2)
    aligned: list[Image.Image] = []
    for cell, box in zip(cells, visible_boxes):
        crop = cell.crop(box)
        canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
        offset = (
            padding + (common_width - crop.width) // 2,
            padding + (common_height - crop.height) // 2,
        )
        canvas.alpha_composite(crop, offset)
        aligned.append(canvas)
    return aligned

def shared_content_bounds(cells: list[Image.Image]) -> tuple[int, int, int, int]:
    boxes = [cell.getchannel("A").getbbox() for cell in cells]
    if any(box is None for box in boxes):
        raise RuntimeError("at least one source-grid cell contains no visible effect")
    visible_boxes = [box for box in boxes if box is not None]
    left = min(box[0] for box in visible_boxes)
    top = min(box[1] for box in visible_boxes)
    right = max(box[2] for box in visible_boxes)
    bottom = max(box[3] for box in visible_boxes)
    padding = max(3, round(min(cells[0].size) * 0.015))
    return (
        max(0, left - padding),
        max(0, top - padding),
        min(cells[0].width, right + padding),
        min(cells[0].height, bottom + padding),
    )


def clean_resampled_frame(frame: Image.Image) -> Image.Image:
    cleaned: list[tuple[int, int, int, int]] = []
    for red, green, blue, alpha in flattened_pixels(frame):
        if alpha <= 2:
            cleaned.append((0, 0, 0, 0))
            continue
        if alpha < 248 and green - max(red, blue) > 55 and green > 150:
            green = min(green, max(red, blue) + 12)
        cleaned.append((red, green, blue, alpha))
    result = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    result.putdata(cleaned)
    return result


def normalize_cells(cells: list[Image.Image]) -> list[Image.Image]:
    bounds = shared_content_bounds(cells)
    source_width = bounds[2] - bounds[0]
    source_height = bounds[3] - bounds[1]
    scale = min(CONTENT_SIZE / source_width, CONTENT_SIZE / source_height)
    target_width = max(1, round(source_width * scale))
    target_height = max(1, round(source_height * scale))
    offset = ((FRAME_SIZE - target_width) // 2, (FRAME_SIZE - target_height) // 2)
    normalized: list[Image.Image] = []
    for cell in cells:
        crop = cell.crop(bounds)
        resized = crop.resize((target_width, target_height), Image.Resampling.LANCZOS)
        canvas = Image.new("RGBA", (FRAME_SIZE, FRAME_SIZE), (0, 0, 0, 0))
        canvas.alpha_composite(resized, offset)
        normalized.append(clean_resampled_frame(canvas))
    return normalized


def build_strip(spec: EffectSpec) -> tuple[Image.Image, dict[str, Any]]:
    source = SOURCE_ROOT / spec.source_name
    if not source.exists():
        raise RuntimeError(f"missing source: {source.relative_to(ROOT).as_posix()}")
    with Image.open(source) as raw:
        image = raw.convert("RGB")
    key = estimate_green_key(image)
    cells = source_cells(image, key)
    if spec.asset_id == "monitor_scan":
        cells = align_cells_to_common_plane(cells)
    frames = normalize_cells(cells)
    strip = Image.new("RGBA", (FRAME_SIZE * FRAME_COUNT, FRAME_SIZE), (0, 0, 0, 0))
    visible_pixels: list[int] = []
    for frame_index, frame in enumerate(frames):
        strip.alpha_composite(frame, (frame_index * FRAME_SIZE, 0))
        visible_pixels.append(sum(1 for alpha in flattened_pixels(frame.getchannel("A")) if alpha > 12))
    return strip, {
        "source_dimensions": [image.width, image.height],
        "detected_key_rgb": list(key),
        "frame_visible_pixels": visible_pixels,
    }


def main() -> int:
    built: list[tuple[EffectSpec, Path, dict[str, Any]]] = []
    for spec in EFFECTS:
        strip, metrics = build_strip(spec)
        output = OUTPUT_ROOT / spec.asset_id / f"{spec.asset_id}_strip.png"
        output.parent.mkdir(parents=True, exist_ok=True)
        strip.save(output, format="PNG", optimize=True, compress_level=9)
        built.append((spec, output, metrics))
        print(
            f"ANIMATED EFFECT BUILD: {spec.asset_id} -> "
            f"{strip.width}x{strip.height} RGBA, visible={metrics['frame_visible_pixels']}"
        )

    records: list[dict[str, Any]] = []
    for spec, output, metrics in built:
        source = SOURCE_ROOT / spec.source_name
        records.append(
            {
                "id": spec.asset_id,
                "kind": "animated_environment_effect",
                "source": source.relative_to(ROOT).as_posix(),
                "generation_reference": spec.generation_reference,
                "source_sha256": digest(source),
                "output": output.relative_to(ROOT).as_posix(),
                "output_sha256": digest(output),
                "source_grid": [SOURCE_COLUMNS, SOURCE_ROWS],
                "frame_order": "row_major",
                "dimensions": [FRAME_SIZE * FRAME_COUNT, FRAME_SIZE],
                "frame_size": [FRAME_SIZE, FRAME_SIZE],
                "hframes": FRAME_COUNT,
                "fps": spec.fps,
                "detected_key_rgb": metrics["detected_key_rgb"],
                "frame_visible_pixels": metrics["frame_visible_pixels"],
                "generator": "OpenAI Images built-in source plus deterministic local chroma-key normalization",
                "processing": [
                    "split_4x2_row_major",
                    "connected_green_key_removal",
                    "edge_despill",
                    *(["monitor_common_plane_alignment"] if spec.asset_id == "monitor_scan" else []),
                    "shared_bounds_scale_preservation",
                    "rgba_8x1_strip",
                ],
                "status": "original_fan_made_non_sega_exact",
                "fidelity_status": "not_verified_against_authorized_sega_arcade_reference",
            }
        )
    provenance = {
        "schema_version": 1,
        "generated_asset_policy": "original fan-made OpenAI Images replacements; non-Sega-exact; no ROM, video or licensed-asset extraction",
        "output_contract": {
            "layout": "8x1",
            "frame_size": [FRAME_SIZE, FRAME_SIZE],
            "dimensions": [FRAME_SIZE * FRAME_COUNT, FRAME_SIZE],
            "format": "PNG RGBA",
        },
        "assets": records,
    }
    PROVENANCE_PATH.parent.mkdir(parents=True, exist_ok=True)
    PROVENANCE_PATH.write_text(json.dumps(provenance, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"ANIMATED EFFECT BUILD OK: {len(records)} strips, provenance={PROVENANCE_PATH.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
