#!/usr/bin/env python3
"""Coloured DTM with a hypsometric colour ramp and legend, from dem_01.tif.

Cells at 0 m (water) are drawn separately in blue with their own legend entry.
Writes dem_01_colour.png and dem_01_colour.pdf next to this script.

Run with: ~/venv/geo1015/.venv/bin/python colour_dem.py
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import rasterio
from matplotlib.colors import LinearSegmentedColormap, Normalize, to_rgba
from matplotlib.patches import Rectangle

HERE = Path(__file__).resolve().parent
SRC = HERE / "dem_01.tif"
OUT_PNG = HERE / "dem_01_colour.png"
OUT_PDF = HERE / "dem_01_colour.pdf"

WATER_RGB = "#8ec2e3"

# hypsometric tints: green lowlands, pale yellow/ochre mid-slopes,
# brown high ground, white summits
HYPSO = [
    (0.00, "#3d6b34"),
    (0.20, "#6fa055"),
    (0.40, "#c3cf7a"),
    (0.55, "#efe3a0"),
    (0.70, "#d9b978"),
    (0.82, "#b98a58"),
    (0.92, "#96683f"),
    (1.00, "#f6f4ee"),
]
CMAP = LinearSegmentedColormap.from_list("hypsometric", HYPSO)
CMAP.set_bad("white")

plt.rcParams["font.family"] = "sans-serif"
plt.rcParams["font.sans-serif"] = ["Helvetica", "Arial", "DejaVu Sans"]
plt.rcParams["font.size"] = 9


def main() -> None:
    with rasterio.open(SRC) as src:
        dem = src.read(1).astype("float64")
        if src.nodata is not None:
            dem[dem == src.nodata] = np.nan

    water = dem == 0.0
    print(f"grid {dem.shape[1]}x{dem.shape[0]} cells, "
          f"elevation {np.nanmin(dem):.0f}-{np.nanmax(dem):.0f} m, "
          f"water {water.sum()} cells ({100 * water.mean():.1f}%)")

    vmin, vmax = float(np.nanmin(dem)), float(np.nanmax(dem))
    norm = Normalize(vmin=vmin, vmax=vmax)

    # map panel keeps the true aspect of the grid (square 33.37 m cells)
    map_w_in = 4.6
    map_h_in = map_w_in * dem.shape[0] / dem.shape[1]
    pad = 0.05
    legend_w_in = 1.15
    fig_w, fig_h = map_w_in + legend_w_in + 2 * pad, map_h_in + 2 * pad
    fig = plt.figure(figsize=(fig_w, fig_h), dpi=300)
    ax = fig.add_axes([pad / fig_w, pad / fig_h,
                       map_w_in / fig_w, map_h_in / fig_h])

    im = ax.imshow(dem, cmap=CMAP, norm=norm, interpolation="bilinear")

    # overlay the water cells in a flat colour (with its own legend entry).
    # RGB is set everywhere so that edge interpolation only blends the alpha
    # channel (otherwise black, alpha-zero pixels create a dark halo)
    water_rgba = np.zeros(dem.shape + (4,))
    water_rgba[..., :3] = to_rgba(WATER_RGB)[:3]
    water_rgba[..., 3] = water
    ax.imshow(water_rgba, interpolation="bilinear")
    ax.set_axis_off()

    # continuous colourbar, 0-971 m, ticks every 200 m
    cax_x0_in = pad + map_w_in + 0.25
    cax = fig.add_axes([cax_x0_in / fig_w, 0.19, 0.14 / fig_w, 0.62])
    cb = fig.colorbar(im, cax=cax,
                      ticks=np.arange(0, np.floor(vmax / 200 + 1) * 200, 200))
    cb.set_label("elevation [m]", labelpad=8)

    # water swatch, drawn by hand for precise placement under the colourbar
    sw_x0 = cax_x0_in / fig_w
    sw_w = 0.14 / fig_w
    sw_y0 = 0.19 - 0.075
    sw_h = 0.10 / fig_h
    fig.add_artist(Rectangle((sw_x0, sw_y0), sw_w, sw_h,
                             transform=fig.transFigure,
                             facecolor=WATER_RGB, edgecolor="none"))
    fig.text(sw_x0 + sw_w + 0.08 / fig_w, sw_y0 + sw_h / 2, "water (0 m)",
             fontsize=9, ha="left", va="center")

    fig.savefig(OUT_PNG, dpi=300)
    fig.savefig(OUT_PDF)
    print(f"wrote {OUT_PNG.name} and {OUT_PDF.name}")


if __name__ == "__main__":
    main()
