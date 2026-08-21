#!/usr/bin/env python3
"""Build production 8-direction sprite atlases from ImageGen source sheets.

ImageGen is asked for seven independently drawn direction rows. The opposite
right profile is derived from the left profile in a deterministic way, which
avoids an identity drift while still giving the runtime a complete eight-sector
turnaround. The chroma background is converted into a real alpha channel.

This is an art-production helper, not a runtime dependency. Install the pinned
packages from requirements-art.txt before regenerating the atlases.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "reports" / "runtime" / "directional-sources"
OUTPUT_ROOT = ROOT / "assets" / "sprites_v2"
CELL_SIZE = 256
CELL_INSET = 12
ART_MARGIN = 2
SOURCE_COLUMNS = 8
MIN_SOURCE_ROWS = 6

DIRECTIONS = (
    "front",
    "front_left",
    "left",
    "back_left",
    "back",
    "back_right",
    "right",
    "front_right",
)
FRAME_STATES = (
    "idle",
    "move_contact_a",
    "move_passing",
    "move_contact_b",
    "action_windup",
    "action_strike",
    "hit_recoil",
    "death_fall",
)


@dataclass(frozen=True)
class ActorSpec:
    actor_id: str
    folder: str
    source_columns: int = SOURCE_COLUMNS
    state_column_map: tuple[int, ...] = tuple(range(SOURCE_COLUMNS))
    source_name: str = ""


ACTORS = (
    ActorSpec("thomas_rogan", "heroes"),
    ActorSpec("agent_g", "heroes"),
    ActorSpec("sophie_richards", "npcs"),
    ActorSpec("dbr_scientist", "npcs"),
    ActorSpec("dr_curien", "npcs", 7, (0, 1, 2, 3, 4, 5, 5, 6)),
    ActorSpec("sam_a1", "enemies"),
    ActorSpec("neil_a2", "enemies"),
    ActorSpec("cyril_a3", "enemies"),
    ActorSpec("kageo_b1", "enemies"),
    ActorSpec("bourbon_b2", "enemies"),
    ActorSpec("ebitan_a_b3", "enemies"),
    ActorSpec("ebitan_b_b4", "enemies"),
    ActorSpec("samson_c1", "enemies"),
    ActorSpec("bentley_c2", "enemies"),
    ActorSpec("burner_c3", "enemies"),
    ActorSpec("simon_d1", "enemies"),
    ActorSpec("gilmore_d2", "enemies"),
    ActorSpec("harris_d3", "enemies"),
    ActorSpec("robert_d4", "enemies"),
    ActorSpec("rubin_e1", "enemies"),
    ActorSpec("drake_e2", "enemies"),
    ActorSpec("moody_e3", "enemies"),
    ActorSpec("parlor_e4", "enemies"),
    ActorSpec("kenfis_f1", "enemies"),
    ActorSpec("saruzou_f2", "enemies"),
    ActorSpec("bouere_f3", "enemies"),
    ActorSpec("devilon_f4", "enemies"),
    ActorSpec("murrer_g1", "enemies"),
    ActorSpec("name_g2", "enemies"),
    ActorSpec("taran_g3", "enemies"),
    ActorSpec("mutant_bat", "enemies"),
    ActorSpec("chariot", "bosses", source_name="chariot_compact_v2.png"),
    ActorSpec("hangedman", "bosses", 7, (0, 1, 2, 3, 4, 5, 5, 6)),
    ActorSpec("hermit", "bosses"),
    ActorSpec("magician", "bosses"),
)


def smoothstep(edge_a: float, edge_b: float, value: np.ndarray) -> np.ndarray:
    t = np.clip((value - edge_a) / (edge_b - edge_a), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def chroma_to_alpha(cell: Image.Image) -> Image.Image:
    """Remove the vivid green ImageGen background while preserving olive art."""
    rgb = np.asarray(cell.convert("RGB"), dtype=np.float32)
    red = rgb[..., 0]
    green = rgb[..., 1]
    blue = rgb[..., 2]
    other = np.maximum(red, blue)
    dominance = green - other

    chroma = smoothstep(42.0, 118.0, dominance)
    luminance_gate = smoothstep(115.0, 205.0, green)
    ratio_gate = (green > red * 1.18) & (green > blue * 1.18)
    background = np.clip(chroma * luminance_gate * ratio_gate, 0.0, 1.0)
    alpha = 1.0 - background
    alpha[alpha < 0.035] = 0.0
    alpha[alpha > 0.965] = 1.0

    # Remove green spill only on keyed, semi-transparent edge pixels. Alpha is
    # deliberately left untouched: the silhouette is not eroded and opaque
    # green/olive costume pixels remain authored artwork.
    edge = (alpha > 0.0) & (alpha < 1.0)
    spill = smoothstep(8.0, 72.0, dominance) * (1.0 - alpha)
    spill *= edge
    clean_green = np.minimum(green, other * 1.04 + 4.0)
    rgb[..., 1] = green * (1.0 - spill) + clean_green * spill

    rgba = np.dstack((np.clip(rgb, 0, 255), np.rint(alpha * 255.0)))
    return Image.fromarray(rgba.astype(np.uint8), "RGBA")


def foreground_spans(alpha: np.ndarray, axis: int) -> list[tuple[int, int]]:
    projection = np.count_nonzero(alpha > 20, axis=axis)
    active = projection > 20
    transitions = np.diff(np.r_[False, active, False].astype(np.int8))
    spans = list(zip(np.flatnonzero(transitions == 1), np.flatnonzero(transitions == -1)))
    spans = [
        (int(start), int(end))
        for start, end in spans
        if end - start >= 3 and int(projection[start:end].sum()) >= 200
    ]
    return spans


def foreground_row_spans(
    alpha: np.ndarray, source_columns: int = SOURCE_COLUMNS
) -> list[tuple[int, int]]:
    height, width = alpha.shape
    support = np.zeros(height, dtype=np.int16)
    for column in range(source_columns):
        left = round(column * width / source_columns)
        right = round((column + 1) * width / source_columns)
        column_counts = np.count_nonzero(alpha[:, left:right] > 20, axis=1)
        support += column_counts > 4
    # A true direction band is represented in several state columns. Long boss
    # weapons crossing a gutter affect only one or two columns and are ignored.
    active = support >= 3
    for _iteration in range(3):
        active[1:-1] |= active[:-2] & active[2:]
    transitions = np.diff(np.r_[False, active, False].astype(np.int8))
    spans = list(zip(np.flatnonzero(transitions == 1), np.flatnonzero(transitions == -1)))
    minimum_height = max(12, height // 100)
    return [(int(start), int(end)) for start, end in spans if end - start >= minimum_height]


def grid_bounds(spans: list[tuple[int, int]], size: int) -> list[int]:
    centers = [(start + end) * 0.5 for start, end in spans]
    first = int(round(centers[0] - (centers[1] - centers[0]) * 0.5))
    bounds = [max(0, min(first, spans[0][0] - 12))]
    for index in range(len(spans) - 1):
        bounds.append(int(round((spans[index][1] + spans[index + 1][0]) * 0.5)))
    last = int(round(centers[-1] + (centers[-1] - centers[-2]) * 0.5))
    bounds.append(min(size, max(last, spans[-1][1] + 12)))
    return bounds


def dilate_mask(mask: np.ndarray, radius: int = 1) -> np.ndarray:
    """Small dependency-free dilation used only to connect antialiased edges."""
    if radius <= 0:
        return mask.copy()
    height, width = mask.shape
    result = mask.copy()
    for offset_y in range(-radius, radius + 1):
        source_top = max(0, -offset_y)
        source_bottom = min(height, height - offset_y)
        target_top = max(0, offset_y)
        target_bottom = min(height, height + offset_y)
        for offset_x in range(-radius, radius + 1):
            source_left = max(0, -offset_x)
            source_right = min(width, width - offset_x)
            target_left = max(0, offset_x)
            target_right = min(width, width + offset_x)
            result[target_top:target_bottom, target_left:target_right] |= mask[
                source_top:source_bottom, source_left:source_right
            ]
    return result


def connected_component_labels(mask: np.ndarray) -> np.ndarray:
    """Label an 8-connected mask with a run-length union-find pass."""
    height, width = mask.shape
    parent = [0]
    runs_by_row: list[list[tuple[int, int, int]]] = []

    def make_label() -> int:
        label = len(parent)
        parent.append(label)
        return label

    def find(label: int) -> int:
        while parent[label] != label:
            parent[label] = parent[parent[label]]
            label = parent[label]
        return label

    def union(first: int, second: int) -> None:
        root_first = find(first)
        root_second = find(second)
        if root_first != root_second:
            parent[root_second] = root_first

    previous: list[tuple[int, int, int]] = []
    for y in range(height):
        row = mask[y]
        transitions = np.diff(np.r_[False, row, False].astype(np.int8))
        spans = list(zip(np.flatnonzero(transitions == 1), np.flatnonzero(transitions == -1)))
        current: list[tuple[int, int, int]] = []
        previous_index = 0
        for start_value, end_value in spans:
            start = int(start_value)
            end = int(end_value)
            while previous_index < len(previous) and previous[previous_index][1] < start - 1:
                previous_index += 1
            overlapping: list[int] = []
            scan = previous_index
            while scan < len(previous) and previous[scan][0] <= end:
                previous_start, previous_end, previous_label = previous[scan]
                if previous_end >= start - 1 and previous_start <= end:
                    overlapping.append(previous_label)
                scan += 1
            label = overlapping[0] if overlapping else make_label()
            for other_label in overlapping[1:]:
                union(label, other_label)
            current.append((start, end, label))
        runs_by_row.append(current)
        previous = current

    labels = np.zeros((height, width), dtype=np.int32)
    for y, runs in enumerate(runs_by_row):
        for start, end, label in runs:
            labels[y, start:end] = find(label)
    return labels


def component_inventory(
    alpha: np.ndarray,
    row_bounds: list[int],
    source_columns: int,
    allow_missing_last: bool = False,
) -> tuple[np.ndarray, dict[tuple[int, int], list[int]], dict[int, dict[str, object]]]:
    """Assign complete foreground components by ordered actors in each row.

    The generated sheets keep eight state poses in left-to-right order, but
    their centres are not an equal mathematical grid. Sorting the eight largest
    connected silhouettes per direction is therefore safer than a hard x crop:
    broad recoil poses and long weapons may cross the nominal boundary without
    being split or assigned to the preceding state.
    """
    alpha_height, alpha_width = alpha.shape
    # Label each authored direction band independently. A raised hammer or a
    # tall wing can touch the next row in an ImageGen sheet; independent row
    # segmentation prevents two different direction poses becoming one object.
    labels = np.zeros((alpha_height, alpha_width), dtype=np.int32)
    label_offset = 0
    for row in range(len(row_bounds) - 1):
        top = row_bounds[row]
        bottom = row_bounds[row + 1]
        local_labels = connected_component_labels(
            dilate_mask(alpha[top:bottom, :] > 20, 1)
        )
        positive = local_labels > 0
        if np.any(positive):
            local_labels[positive] += label_offset
            label_offset = int(local_labels.max())
        labels[top:bottom, :] = local_labels
    roots = np.unique(labels[(labels > 0) & (alpha > 2)])
    diagnostics: dict[int, dict[str, object]] = {}
    roots_by_row: dict[int, list[int]] = {
        row: [] for row in range(len(row_bounds) - 1)
    }
    for root_value in roots:
        root = int(root_value)
        ys, xs = np.nonzero((labels == root) & (alpha > 2))
        if len(xs) < 48:
            continue
        row_indices = np.clip(
            np.searchsorted(row_bounds, ys, side="right") - 1,
            0,
            len(row_bounds) - 2,
        )
        scores = np.bincount(
            row_indices,
            weights=alpha[ys, xs].astype(np.float64),
            minlength=len(row_bounds) - 1,
        )
        assigned_row = int(np.argmax(scores))
        roots_by_row[assigned_row].append(root)
        diagnostics[root] = {
            "assigned_cell": [assigned_row, -1],
            "visible_pixels": int(len(xs)),
            "bbox": [int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1],
            "weighted_center_x": round(
                float(np.average(xs, weights=alpha[ys, xs])), 4
            ),
            "weighted_assignment_confidence": round(
                float(scores[assigned_row] / max(1.0, scores.sum())), 5
            ),
        }

    assignments: dict[tuple[int, int], list[int]] = {}
    for row, row_roots in roots_by_row.items():
        missing_last = (
            allow_missing_last
            and row == len(row_bounds) - 2
            and len(row_roots) == source_columns - 1
        )
        if len(row_roots) < source_columns and not missing_last:
            raise ValueError(
                f"Direction row {row} has only {len(row_roots)} readable components; "
                f"expected at least {source_columns}"
            )
        primary_count = source_columns - 1 if missing_last else source_columns
        primary_roots = sorted(
            row_roots,
            key=lambda root: int(diagnostics[root]["visible_pixels"]),
            reverse=True,
        )[:primary_count]
        primary_roots.sort(
            key=lambda root: float(diagnostics[root]["weighted_center_x"])
        )
        for column, root in enumerate(primary_roots):
            assignments[(row, column)] = [root]
            diagnostics[root]["assigned_cell"] = [row, column]
            diagnostics[root]["is_primary"] = True

        for root in row_roots:
            if root in primary_roots:
                continue
            left, top, right, bottom = (
                int(value) for value in diagnostics[root]["bbox"]
            )
            center_x = (left + right) * 0.5
            center_y = (top + bottom) * 0.5
            nearest_column = 0
            nearest_distance = float("inf")
            for column, primary_root in enumerate(primary_roots):
                p_left, p_top, p_right, p_bottom = (
                    int(value) for value in diagnostics[primary_root]["bbox"]
                )
                gap_x = max(p_left - center_x, 0.0, center_x - p_right)
                gap_y = max(p_top - center_y, 0.0, center_y - p_bottom)
                distance = gap_x * gap_x + gap_y * gap_y
                if distance < nearest_distance:
                    nearest_distance = distance
                    nearest_column = column
            assignments[(row, nearest_column)].append(root)
            diagnostics[root]["assigned_cell"] = [row, nearest_column]
            diagnostics[root]["reattached_to_nearest_primary"] = True
    return labels, assignments, diagnostics


def despill_transparent_edges(image: Image.Image) -> Image.Image:
    """Neutralize keyed green in antialiased pixels without changing alpha."""
    rgba = np.asarray(image.convert("RGBA")).copy()
    red = rgba[..., 0].astype(np.float32)
    green = rgba[..., 1].astype(np.float32)
    blue = rgba[..., 2].astype(np.float32)
    alpha = rgba[..., 3]
    other = np.maximum(red, blue)
    keyed_edge = (
        (alpha > 0)
        & (alpha < 250)
        & (green > other + 8.0)
        & (green > red * 1.08)
        & (green > blue * 1.08)
    )
    clean_green = np.minimum(green, other * 1.035 + 3.0)
    rgba[..., 1] = np.where(keyed_edge, clean_green, green).astype(np.uint8)
    rgba[alpha == 0, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def compose_component_cell(
    source_rgba: Image.Image,
    labels: np.ndarray,
    roots: list[int],
) -> tuple[Image.Image, dict[str, int]]:
    source_array = np.asarray(source_rgba).copy()
    if not roots:
        return Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0)), {
            "source_visible_pixels": 0,
            "source_width": 0,
            "source_height": 0,
        }
    selected = np.isin(labels, roots) & (source_array[..., 3] > 0)
    ys, xs = np.nonzero(selected)
    if len(xs) == 0:
        return Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0)), {
            "source_visible_pixels": 0,
            "source_width": 0,
            "source_height": 0,
        }
    left, right = int(xs.min()), int(xs.max()) + 1
    top, bottom = int(ys.min()), int(ys.max()) + 1
    source_array[..., 3] = np.where(selected, source_array[..., 3], 0)
    source_array[source_array[..., 3] == 0, :3] = 0
    cropped = Image.fromarray(source_array[top:bottom, left:right], "RGBA")
    available = CELL_SIZE - (CELL_INSET + ART_MARGIN) * 2
    scale = min(available / cropped.width, available / cropped.height)
    resized_width = max(1, int(round(cropped.width * scale)))
    resized_height = max(1, int(round(cropped.height * scale)))
    cropped = cropped.resize((resized_width, resized_height), Image.Resampling.LANCZOS)
    resized = np.asarray(cropped).copy()
    resized[resized[..., 3] == 0, :3] = 0
    cropped = despill_transparent_edges(Image.fromarray(resized, "RGBA"))
    padded = Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0))
    paste_x = (CELL_SIZE - resized_width) // 2
    paste_y = CELL_SIZE - CELL_INSET - ART_MARGIN - resized_height
    padded.alpha_composite(cropped, (paste_x, paste_y))
    return padded, {
        "source_visible_pixels": int(len(xs)),
        "source_width": right - left,
        "source_height": bottom - top,
    }


def compose_moody_chain_cell(
    source_rgba: Image.Image,
    labels: np.ndarray,
    roots: list[int],
) -> tuple[Image.Image, dict[str, int | str]]:
    """Keep Moody's body scale while localising the exceptionally long chain.

    The source deliberately draws the complete chain across most of a logical
    state slot, making the body about one third of its normal size when the
    whole silhouette is aspect-fitted. The body is scaled uniformly; the chain
    layer overlaps at the hand and is shortened horizontally into the remaining
    cell width. No body, claw head or terminal spike pixels are discarded.
    """
    source_array = np.asarray(source_rgba).copy()
    selected = np.isin(labels, roots) & (source_array[..., 3] > 0)
    ys, xs = np.nonzero(selected)
    if len(xs) == 0:
        return Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0)), {
            "source_visible_pixels": 0,
            "source_width": 0,
            "source_height": 0,
            "policy": "localized_chain_body_scale",
        }
    left, right = int(xs.min()), int(xs.max()) + 1
    top, bottom = int(ys.min()), int(ys.max()) + 1
    source_array[..., 3] = np.where(selected, source_array[..., 3], 0)
    source_array[source_array[..., 3] == 0, :3] = 0
    local = source_array[top:bottom, left:right]
    object_height, object_width = local.shape[:2]

    projection = np.count_nonzero(local[..., 3] > 2, axis=0)
    body_threshold = max(5, int(round(object_height * 0.075)))
    active = projection >= body_threshold
    transitions = np.diff(np.r_[False, active, False].astype(np.int8))
    dense_runs = list(
        zip(np.flatnonzero(transitions == 1), np.flatnonzero(transitions == -1))
    )
    body_end = int(dense_runs[0][1]) if dense_runs else max(1, int(object_width * 0.36))
    if body_end < int(object_height * 0.60):
        body_end = min(object_width, int(round(object_height * 0.94)))
    overlap_start = max(0, body_end - int(round(object_height * 0.25)))

    inner_start = CELL_INSET + ART_MARGIN
    inner_end = CELL_SIZE - CELL_INSET - ART_MARGIN
    available = inner_end - inner_start
    target_height = int(round(available * 0.86))
    uniform_scale = target_height / object_height
    body_width = max(1, int(round(body_end * uniform_scale)))
    if body_width > int(available * 0.88):
        body_width = int(available * 0.88)
        uniform_scale = body_width / body_end
        target_height = max(1, int(round(object_height * uniform_scale)))

    body = Image.fromarray(local[:, :body_end], "RGBA").resize(
        (body_width, target_height), Image.Resampling.LANCZOS
    )
    body = despill_transparent_edges(body)
    body_x = inner_start
    body_y = inner_end - target_height

    tail_x = body_x + int(round(overlap_start * uniform_scale))
    tail_width = max(1, inner_end - tail_x)
    tail = Image.fromarray(local[:, overlap_start:], "RGBA").resize(
        (tail_width, target_height), Image.Resampling.LANCZOS
    )
    tail = despill_transparent_edges(tail)

    padded = Image.new("RGBA", (CELL_SIZE, CELL_SIZE), (0, 0, 0, 0))
    padded.alpha_composite(body, (body_x, body_y))
    padded.alpha_composite(tail, (tail_x, body_y))
    return padded, {
        "source_visible_pixels": int(len(xs)),
        "source_width": object_width,
        "source_height": object_height,
        "body_target_height": target_height,
        "policy": "localized_chain_body_scale",
    }


def build_actor(spec: ActorSpec) -> dict[str, object]:
    source_path = SOURCE_ROOT / (spec.source_name or f"{spec.actor_id}.png")
    if not source_path.exists():
        raise FileNotFoundError(source_path)
    source = Image.open(source_path).convert("RGB")
    if source.width < spec.source_columns * 32 or source.height < MIN_SOURCE_ROWS * 32:
        raise ValueError(f"Source sheet is too small: {source_path} ({source.size})")

    source_rgba = chroma_to_alpha(source)
    source_alpha = np.asarray(source_rgba.getchannel("A"))
    row_spans = foreground_row_spans(source_alpha, spec.source_columns)
    column_spans = foreground_spans(source_alpha, axis=0)
    if len(row_spans) not in (6, 7):
        raise ValueError(f"Expected six or seven direction bands, detected {len(row_spans)}: {row_spans}")
    row_bounds = grid_bounds(row_spans, source.height)
    column_bounds = [
        round(index * source.width / spec.source_columns)
        for index in range(spec.source_columns + 1)
    ]
    if len(spec.state_column_map) != SOURCE_COLUMNS:
        raise ValueError(f"State-column map must contain eight entries: {spec.actor_id}")

    labels, assignments, component_diagnostics = component_inventory(
        source_alpha,
        row_bounds,
        spec.source_columns,
        allow_missing_last=spec.actor_id == "samson_c1",
    )
    discarded_components: list[dict[str, object]] = []
    if spec.actor_id == "chariot":
        for source_row in range(len(row_spans)):
            death_cell = (source_row, spec.source_columns - 1)
            roots = assignments.get(death_cell, [])
            primaries = [
                root for root in roots
                if component_diagnostics[root].get("is_primary") is True
            ]
            dropped = [root for root in roots if root not in primaries]
            if dropped:
                discarded_components.append({
                    "source_row": source_row,
                    "state": "death_fall",
                    "reason": "detached_source_noise_outside_primary_prone_body",
                    "visible_pixels": sum(
                        int(component_diagnostics[root]["visible_pixels"])
                        for root in dropped
                    ),
                })
                assignments[death_cell] = primaries
    extracted: dict[tuple[int, int], Image.Image] = {}
    extraction_metrics: dict[tuple[int, int], dict[str, int | str]] = {}
    localized_cells: list[str] = []
    for source_row in range(len(row_spans)):
        for source_column in range(spec.source_columns):
            roots = assignments.get((source_row, source_column), [])
            if spec.actor_id == "moody_e3" and source_column in (4, 5):
                cell, metrics = compose_moody_chain_cell(
                    source_rgba,
                    labels,
                    roots,
                )
                localized_cells.append(
                    f"source_row_{source_row}/{FRAME_STATES[source_column]}"
                )
            else:
                cell, metrics = compose_component_cell(
                    source_rgba,
                    labels,
                    roots,
                )
            extracted[(source_row, source_column)] = cell
            extraction_metrics[(source_row, source_column)] = metrics

    atlas = Image.new("RGBA", (CELL_SIZE * 8, CELL_SIZE * 8), (0, 0, 0, 0))
    row_map = (0, 1, 2, 3, 4, 5, 2, 6) if len(row_spans) == 7 else (0, 1, 2, 3, 4, 3, 2, 5)
    mirrored_rows = (6,) if len(row_spans) == 7 else (5, 6)
    cell_alpha_counts: list[int] = []
    derived_cells: list[str] = []
    final_cells: dict[tuple[int, int], Image.Image] = {}
    for final_row, source_row in enumerate(row_map):
        for column, source_column in enumerate(spec.state_column_map):
            cell = extracted[(source_row, source_column)].copy()
            if final_row in mirrored_rows:
                cell = cell.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            alpha = np.asarray(cell.getchannel("A"))
            visible = int(np.count_nonzero(alpha))
            # The selected Samson source contains only a tiny detached fragment
            # in front_right/death_fall. Derive it from the valid neighbouring
            # right/death_fall sector; never invent pixels or hide the fallback.
            source_visible = extraction_metrics[(source_row, source_column)][
                "source_visible_pixels"
            ]
            if (
                spec.actor_id == "samson_c1"
                and final_row == 7
                and column == 7
                and source_visible < 1500
            ):
                cell = final_cells[(6, 7)].copy()
                alpha = np.asarray(cell.getchannel("A"))
                visible = int(np.count_nonzero(alpha))
                derived_cells.append("front_right/death_fall_from_right/death_fall")
            if visible < 80:
                raise ValueError(
                    f"Empty or unreadable cell {spec.actor_id} row={final_row} col={column}"
                )
            # Twelve outer pixels plus the two-pixel art margin must stay empty.
            if (
                np.any(alpha[: CELL_INSET + ART_MARGIN, :])
                or np.any(alpha[-(CELL_INSET + ART_MARGIN) :, :])
                or np.any(alpha[:, : CELL_INSET + ART_MARGIN])
                or np.any(alpha[:, -(CELL_INSET + ART_MARGIN) :])
            ):
                raise ValueError(
                    f"Transparent gutter violation {spec.actor_id} row={final_row} col={column}"
                )
            final_cells[(final_row, column)] = cell
            cell_alpha_counts.append(visible)
            atlas.alpha_composite(cell, (column * CELL_SIZE, final_row * CELL_SIZE))

    output_dir = OUTPUT_ROOT / spec.folder / spec.actor_id
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{spec.actor_id}__v2__action_cycle__8dirx8f.png"
    atlas.save(output_path, "PNG", optimize=True)
    return {
        "id": spec.actor_id,
        "source": source_path.relative_to(ROOT).as_posix(),
        "source_sha256": hashlib.sha256(source_path.read_bytes()).hexdigest(),
        "output": output_path.relative_to(ROOT).as_posix(),
        "source_size": list(source.size),
        "output_size": list(atlas.size),
        "directions": list(DIRECTIONS),
        "frame_states": list(FRAME_STATES),
        "source_direction_rows": len(row_spans),
        "source_state_columns": spec.source_columns,
        "derived_state_columns": ["hit_recoil_from_action_strike"] if spec.source_columns == 7 else [],
        "derived_cells": derived_cells,
        "state_column_map": list(spec.state_column_map),
        "right_profile": "mirrored_from_left_profile",
        "back_right": "generated" if len(row_spans) == 7 else "mirrored_from_back_left",
        "detected_row_spans": row_spans,
        "detected_column_spans": column_spans,
        "regular_column_bounds": column_bounds,
        "extraction_method": "whole_connected_components_aspect_fit_ground_anchor",
        "transparent_gutter_px": CELL_INSET,
        "art_margin_px": ART_MARGIN,
        "component_count": len(component_diagnostics),
        "reattached_component_count": sum(
            1 for item in component_diagnostics.values()
            if item.get("reattached_to_nearest_primary") is True
        ),
        "discarded_components": discarded_components,
        "localized_cells": localized_cells,
        "source_cell_visible_pixels_min": min(
            metrics["source_visible_pixels"] for metrics in extraction_metrics.values()
        ),
        "visible_pixels_min": min(cell_alpha_counts),
        "visible_pixels_max": max(cell_alpha_counts),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--actor", action="append", default=[], help="Build only this actor ID; repeatable")
    parser.add_argument("--report", default="reports/runtime/directional-atlas-assembly.json")
    args = parser.parse_args()

    if len(ACTORS) != 35 or len({spec.actor_id for spec in ACTORS}) != 35:
        raise SystemExit("Directional actor contract must contain 35 unique identities")
    requested = set(args.actor)
    specs = [spec for spec in ACTORS if not requested or spec.actor_id in requested]
    unknown = requested.difference(spec.actor_id for spec in ACTORS)
    if unknown:
        raise SystemExit(f"Unknown actor IDs: {', '.join(sorted(unknown))}")

    records = []
    for spec in specs:
        record = build_actor(spec)
        records.append(record)
        print(f"ASSEMBLED {spec.actor_id}: {record['output']}")

    report_path = ROOT / args.report
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(
        json.dumps(
            {
                "schema_version": 2,
                "extraction_method": "whole_connected_components_aspect_fit_ground_anchor",
                "source_layout": {"columns": 8, "supported_rows": [6, 7]},
                "output_layout": {"columns": 8, "rows": 8, "cell_px": CELL_SIZE},
                "actors": records,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"REPORT {report_path.relative_to(ROOT).as_posix()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
