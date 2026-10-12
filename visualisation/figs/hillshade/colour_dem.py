#!/usr/bin/env python3
"""Coloured DTM with a hypsometric colour ramp and legend, from dem_01.tif.

Cells at 0 m (water) are drawn separately in blue with their own legend entry.
Writes dem_01_colour.jpg and dem_01_colour.pdf next to this script (the
raster outputs are JPEG, quality 90; the PDFs are vector).

Also writes dem_01_colour_hillshade.png/.pdf: the same hypsometric tints
combined with a hillshade (light from the North-West, azimuth 315 deg and
altitude 45 deg). The hillshade is computed with the book's formula
(Horn 3x3 gradient and aspect, Lambertian lighting, like QGIS/ArcGIS) and
multiplies the tints: the shading modulates the lightness of the colours,
while their hue (and thus the elevation information) is preserved.
Water cells are not shaded.

The same two images are also produced with a second ramp, HYPSO2, taken
from the QGIS colour ramp "Imhof" (imhof_tints.xml): dem_01_imhof.jpg/.pdf
and dem_01_imhof_hillshade.jpg/.pdf.

Run with: ~/venv/geo1015/.venv/bin/python colour_dem.py
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import rasterio
from matplotlib.colors import LinearSegmentedColormap, Normalize, to_rgba
from matplotlib.cm import ScalarMappable
from matplotlib.patches import Rectangle

HERE = Path(__file__).resolve().parent
SRC = HERE / "dem_01.tif"

SUN_AZIMUTH = 315.0  # deg clockwise from north (North-West)
SUN_ALTITUDE = 45.0  # deg above the horizon

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

# HYPSO2: the colours of the QGIS colour ramp "Imhof" (imhof_tints.xml),
# a softened sequence (Imhof's types 11-12): grey-green lowlands flowing
# into pale grey-beige and near-white high ground. QGIS presets place the
# stops evenly between 0 and 1, so we do the same.
HYPSO2 = [
    (0.000, (160, 196, 138)),
    (0.125, (195, 204, 138)),
    (0.250, (220, 212, 138)),
    (0.375, (222, 214, 160)),
    (0.500, (232, 210, 168)),
    (0.625, (226, 200, 164)),
    (0.750, (214, 192, 178)),
    (0.875, (220, 216, 218)),
    (1.000, (242, 244, 246)),
]
CMAP2 = LinearSegmentedColormap.from_list(
    "hypsometric_imhof",
    [(pos, tuple(v / 255 for v in rgb)) for pos, rgb in HYPSO2])
CMAP2.set_bad("white")

plt.rcParams["font.family"] = "sans-serif"
plt.rcParams["font.sans-serif"] = ["Helvetica", "Arial", "DejaVu Sans"]
plt.rcParams["font.size"] = 9


def hillshade(dem: np.ndarray, xres: float, yres: float,
              azimuth: float = SUN_AZIMUTH,
              altitude: float = SUN_ALTITUDE) -> np.ndarray:
    """Hillshade of a gridded DEM, values normalised to [0, 1].

    Horn 3x3 kernel for the gradient (like GDAL/QGIS/ArcGIS), with the
    lighting convention of the book's formula: the azimuth is clockwise
    from the north, the altitude is the angle of the sun above the horizon.
    Flat cells get the value cos(zenith) = sin(altitude).
    """
    psi = np.deg2rad(azimuth)
    gamma = np.deg2rad(altitude)
    # unit vector pointing towards the sun (east, north, up)
    lx = np.sin(psi) * np.cos(gamma)
    ly = np.cos(psi) * np.cos(gamma)
    lz = np.sin(gamma)

    # Horn 3x3 window on an edge-padded grid (row 0 = north)
    z = np.pad(dem, 1, mode="edge")
    west = z[:-2, :-2] + 2 * z[1:-1, :-2] + z[2:, :-2]
    east = z[:-2, 2:] + 2 * z[1:-1, 2:] + z[2:, 2:]
    north = z[:-2, :-2] + 2 * z[:-2, 1:-1] + z[:-2, 2:]
    south = z[2:, :-2] + 2 * z[2:, 1:-1] + z[2:, 2:]
    dzdx = (east - west) / (8 * xres)     # eastward derivative
    dzdy = (north - south) / (8 * yres)   # northward derivative

    # surface normal (pointing upwards out of the terrain)
    nx, ny = -dzdx, -dzdy
    norm = np.sqrt(nx ** 2 + ny ** 2 + 1)
    shade = (nx * lx + ny * ly + lz) / norm
    return np.clip(shade, 0.0, 1.0)


def draw(rgb: np.ndarray, alpha: np.ndarray, water: np.ndarray,
         norm: Normalize, cmap, ticks: np.ndarray,
         out_png: Path, out_pdf: Path, dem_shape: tuple) -> None:
    """Draw the map panel (rgb image + water overlay + colourbar + swatch)."""
    # map panel keeps the true aspect of the grid (square 33.37 m cells)
    map_w_in = 4.6
    map_h_in = map_w_in * dem_shape[0] / dem_shape[1]
    pad = 0.05
    fig_w, fig_h = map_w_in + 1.15 + 2 * pad, map_h_in + 2 * pad
    fig = plt.figure(figsize=(fig_w, fig_h), dpi=300)
    ax = fig.add_axes([pad / fig_w, pad / fig_h,
                       map_w_in / fig_w, map_h_in / fig_h])

    rgba = np.concatenate([rgb, alpha[..., None]], axis=-1)
    ax.imshow(rgba, interpolation="bilinear")

    # overlay the water cells in a flat colour (with its own legend entry).
    # RGB is set everywhere so that edge interpolation only blends the alpha
    # channel (otherwise black, alpha-zero pixels create a dark halo)
    water_rgba = np.zeros(dem_shape + (4,))
    water_rgba[..., :3] = to_rgba(WATER_RGB)[:3]
    water_rgba[..., 3] = water
    ax.imshow(water_rgba, interpolation="bilinear")
    ax.set_axis_off()

    # continuous colourbar, ticks every 200 m
    cax_x0_in = pad + map_w_in + 0.25
    cax = fig.add_axes([cax_x0_in / fig_w, 0.19, 0.14 / fig_w, 0.62])
    cb = fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), cax=cax,
                      ticks=ticks)
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

    fig.savefig(out_png, dpi=300, pil_kwargs={"quality": 90})
    fig.savefig(out_pdf)
    print(f"wrote {out_png.name} and {out_pdf.name}")


def main() -> None:
    with rasterio.open(SRC) as src:
        dem = src.read(1).astype("float64")
        if src.nodata is not None:
            dem[dem == src.nodata] = np.nan
        xres, yres = abs(src.transform.a), abs(src.transform.e)

    water = dem == 0.0
    print(f"grid {dem.shape[1]}x{dem.shape[0]} cells "
          f"({xres:.2f}x{yres:.2f} m), "
          f"elevation {np.nanmin(dem):.0f}-{np.nanmax(dem):.0f} m, "
          f"water {water.sum()} cells ({100 * water.mean():.1f}%)")

    norm = Normalize(vmin=float(np.nanmin(dem)), vmax=float(np.nanmax(dem)))
    ticks = np.arange(0, np.floor(norm.vmax / 200 + 1) * 200, 200)

    # the flat water cells are not shaded
    shade = hillshade(dem, xres, yres)
    shade = np.where(water, 1.0, shade)
    print(f"hillshade: azimuth {SUN_AZIMUTH:.0f} deg, "
          f"altitude {SUN_ALTITUDE:.0f} deg, "
          f"range {shade[~water].min():.2f}-{shade[~water].max():.2f}")

    # bad = no-data cells (alpha 0)
    bad = np.isnan(dem)
    alpha = np.where(bad, 0.0, 1.0)
    dem_clean = np.where(bad, 0.0, dem)

    for cmap, name in [(CMAP, "colour"), (CMAP2, "imhof")]:
        tint_rgb = cmap(norm(dem_clean))[..., :3]
        shaded_rgb = np.clip(tint_rgb * shade[..., None], 0.0, 1.0)
        draw(tint_rgb, alpha, water, norm, cmap, ticks,
             HERE / f"dem_01_{name}.jpg", HERE / f"dem_01_{name}.pdf",
             dem.shape)
        draw(shaded_rgb, alpha, water, norm, cmap, ticks,
             HERE / f"dem_01_{name}_hillshade.jpg",
             HERE / f"dem_01_{name}_hillshade.pdf", dem.shape)


if __name__ == "__main__":
    main()
