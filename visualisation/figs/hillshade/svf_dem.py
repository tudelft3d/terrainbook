#!/usr/bin/env python3
"""SVF-based visualisation of dem_01.tif (the Tasmania terrain), following
Zaksek, Ostir and Kokalj (2011).

For each cell, the elevation angle of the horizon is computed in NDIR
directions up to a search radius RADIUS (by marching along the ray with
bilinear sampling of the DEM), and the sky-view factor is

    SVF = 1 - (1/n) * sum_i sin(gamma_i),

which is the formula defined in the visibility chapter of the book. The
SVF values are then contrast-stretched (linear, 2% cut-off) and rendered
in greyscale: the brighter, the more open the terrain.

Writes two images next to this script:
- dem_01_svf.jpg: the SVF visualisation alone;
- dem_01_svf_hillshade.jpg: the SVF overlaid (semi-transparent) on the
  hillshade from colour_dem.py (light from the North-West, 315 deg/45 deg),
  the combination recommended for cartographic purposes.

Run with: ~/venv/geo1015/.venv/bin/python svf_dem.py
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import rasterio
from scipy.ndimage import map_coordinates

from colour_dem import hillshade, SRC, SUN_AZIMUTH, SUN_ALTITUDE

HERE = Path(__file__).resolve().parent

NDIR = 16           # number of directions (>=8; 16 is enough for visualisation)
RADIUS = 1000.0     # search radius [m]; ~30 cells of the 33.37 m grid
STRETCH_CUT = 2.0   # percentage cut-off for the contrast stretch

OVERLAY_OPACITY = 0.5  # SVF over hillshade, for the combined image


def svf(dem: np.ndarray, cellsize: float,
        ndir: int = NDIR, radius: float = RADIUS) -> np.ndarray:
    """Sky-view factor of a gridded DEM, values in [0, 1].

    The elevation angle of the horizon is computed in ndir directions
    (azimuths clockwise from the north) by marching along each ray step
    by step (1 cell at a time, bilinear sampling), up to radius metres.
    """
    max_steps = int(round(radius / cellsize))
    dem = dem.astype("float64")
    z0 = dem
    sin_gamma_sum = np.zeros_like(dem)

    rows, cols = np.indices(dem.shape)
    for d in range(ndir):
        delta = np.deg2rad(360.0 * d / ndir)
        # azimuths are clockwise from the north; rows increase to the south
        gamma_max = np.zeros_like(dem)
        for k in range(1, max_steps + 1):
            # bilinearly sample the DEM at distance k * cellsize along the ray
            r = rows - k * np.cos(delta)
            c = cols + k * np.sin(delta)
            z = map_coordinates(dem, [r.ravel(), c.ravel()], order=1,
                                mode="nearest").reshape(dem.shape)
            dist = k * cellsize
            angle = np.arctan2(z - z0, dist)
            gamma_max = np.maximum(gamma_max, angle)
        sin_gamma_sum += np.sin(gamma_max)

    return 1.0 - sin_gamma_sum / ndir


def linear_stretch(values: np.ndarray, cut: float = STRETCH_CUT) -> np.ndarray:
    """Linear greyscale stretch with a symmetric percentage cut-off."""
    lo, hi = np.percentile(values, [cut, 100.0 - cut])
    return np.clip((values - lo) / (hi - lo), 0.0, 1.0)


def save_grey(grey: np.ndarray, out_jpg: Path) -> None:
    fig = plt.figure(figsize=(grey.shape[1] / 300, grey.shape[0] / 300),
                     dpi=300)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.imshow(grey, cmap="gray", interpolation="bilinear")
    ax.set_axis_off()
    fig.savefig(out_jpg, dpi=300, pil_kwargs={"quality": 90})
    plt.close(fig)
    print(f"wrote {out_jpg.name}")


def main() -> None:
    with rasterio.open(SRC) as src:
        dem = src.read(1).astype("float64")
        if src.nodata is not None:
            dem[dem == src.nodata] = np.nan
        cellsize = abs(src.transform.a)

    value = svf(dem, cellsize)
    print(f"SVF: ndir={NDIR}, radius={RADIUS:.0f} m ({RADIUS / cellsize:.0f} "
          f"cells), range {value.min():.3f}-{value.max():.3f}, "
          f"mean {value.mean():.3f}")

    svf_grey = linear_stretch(value)
    save_grey(svf_grey, HERE / "dem_01_svf.jpg")

    shade = hillshade(dem, cellsize, SUN_AZIMUTH, SUN_ALTITUDE)
    combined = OVERLAY_OPACITY * svf_grey + (1 - OVERLAY_OPACITY) * shade
    save_grey(combined, HERE / "dem_01_svf_hillshade.jpg")


if __name__ == "__main__":
    main()
