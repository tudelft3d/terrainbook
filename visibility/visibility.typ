#import "../template.typ": *

= Visibility queries on terrains <chap:visibility>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/3HYlBogztOU")

Several applications using terrains involve _visibility queries_, ie given a viewpoint, which area of the surrounding terrain is visible?
Examples of such applications are many: optimal position of telecommunication towers, path planning for hiking (to ensure the nicest views), estimation of the view for scenic drives, estimation of visual damage when trees in a forest are cut, etc.
There are also several related problems.
Two closely related examples are the estimation of shadows (position of the sun continually varies, also with seasons) and the calculation of the solar irradiance (how much sunlight will a certain area have per day/week).
These can be used to estimate the photovoltaic potential (where can we best install solar panels?), for estimating where snow will accumulate in mountains, or for estimating the temperature of the ground (necessary for climate modelling), among other applications.



When referring to visibility problems in terrains, we address the following three fundamental problems:
/ line-of-sight (LoS): given a viewpoint $v$ and another point $q$, does $v$ see $q$ (and vice-versa)? Or, in other words, does the segment $v q$ intersects the terrain? The result is either True or False. (@fig:overview_los)
/ viewshed: given a viewpoint $v$, which area of the surrounding terrain is visible? The result is a polygon (potentially disconnected) showing the locations and extent of what is visible from $v$. Usually the extent is limited to a certain "horizon", or radius of visibility. If the terrain is formed of different objects (eg buildings), an object is either visible or not (simple case), or parts of objects can be visible (more complex). (@fig:overview_viewshed)
/ sky-view factor (SVF): given a viewpoint $v$, the SVF is the portion of the sky that is visible from $v$, ie the part of the sky hemisphere that is not obstructed by the surrounding terrain (and the objects on it, such as buildings and trees). (@fig:overview_svf)

#notefigure(
  image("figs/overview_los.pdf", width: 100%), 
  caption: [Line-of-sight between $v$ and $q$; $q$ is not visible.], 
  // placement: none,
) <fig:overview_los>

#notefigure(
  image("figs/overview_viewshed.pdf", width: 100%), 
  caption: [The viewshed at the location marked with a red star (green = visible; maximum view distance (dark grey) is set to #qty("15", "km")).], 
  dy: 100pt,
) <fig:overview_viewshed>

#notefigure(
  image("figs/Flatiron_fishView_ideal.jpg", width: 100%), 
  caption: [A fisheye view looking straight up: every direction of the sky visible from the camera position appears in the image, which is essentially what a sky-view factor measures. Photo: Autopilot, remapped by Peter Wieden (CC BY-SA 3.0), via Wikimedia Commons.], 
  dy: 200pt,
) <fig:overview_svf>

      
Observe that for all these problems, the viewpoint can either be directly on the terrain (at relative elevation #qty("0", "m")) or at a given height (#qty("2", "m") for a human, or #qty("30", "m") for a telecommunication tower).

We discuss in this chapter the general problem of visibility as defined in computer graphics, and then discuss how terrains, being 2.5D surfaces, simplify the problem. 


#pagebreak()
== The general problem

Rendering is the process of generating (2D) images from 2D or 3D scenes. #index[rendering] #note[rendering]
As shown in @fig:Ray_trace_diagram, it involves projecting the (3D) objects in a scene to an image (say $800 times 800$ pixels) and assigning one colour to each pixel.
#notefigure(
  image("./figs/Ray_trace_diagram.pdf", width: 100%),
  caption: [Ray tracing builds the image pixel-by-pixel by extending rays into the scene. (Figure from #link("https://commons.wikimedia.org/wiki/File:Ray_trace_diagram.svg"))],
) <fig:Ray_trace_diagram>
In the simplest case the colour assigned is that of the closest object, but to obtain photorealistic images, lighting, shading, and other physics-based functions are often applied (however this goes beyond the scope of this book).

#index[ray casting] #note[ray casting]
_Ray casting_ is used for each pixel: a ray is defined between the viewpoint $v$ and the centre of the pixel, and the closest object in the scene must be found.
The main issue involves finding that closest object, and especially discarding the other objects lying behind it (an operation usually called hidden-surface determination/removal).
#index[hidden-surface determination]#note[hidden-surface determination]
@fig:zbuffer shows the idea for 2 objects ($O_1$ and $O_2$).
Observe that objects can _partially_ be hidden by others, and that the value of the pixel should always contain the closest object at that location.
#notefigure(
  image("./figs/zbuffer.pdf", width: 100%),
  caption: [Two planar objects $O_1$ and $O_2$ are partially overlapping when viewed from $v$.],
  placement: top,
) <fig:zbuffer>

One often used algorithm for solving the hidden-surface determination is the _depth-sort method_.
Its main idea is to define a coordinate reference system with $x$ and $y$ on the viewing plane, and $z$ perpendicular to it.
The objects are first sorted according to their maximal $z$-values, and the objects are drawn on the viewing plane from the furthest to the closest.
The value of a given pixel could therefore be redrawn several times, but its value will contain the colour of the closest object.
The algorithm assumes that all objects are planar polygons, which is for the case of terrains not an issue.
Observe that this algorithm is often referred to as the _painter's algorithm_ since it mimics the way one would draw a scene: details in the foreground are drawn "over" the background.

It should be noticed that it is possible that objects cannot be strictly $z$-ordered since their $z$-values can overlap.
@fig:depthsort_issues shows one example: the object $O_2$ from @fig:zbuffer was slightly rotated and now part of it is in front of $O_1$ and part of it is behind.
#notefigure(
  image("./figs/depthsort_issues.pdf", width: 100%),
  caption: [Part of $O_2$ is behind $O_1$ and part is in front.],
) <fig:depthsort_issues>
The solution to this is to decompose one of the objects by the plane of the other, and to process all the parts as different objects.

An efficient implementation of the depth-sort algorithm requires indexing the objects in the scene, and for this BSP-trees are commonly used.
#note[BSP-tree: binary space partitioning]
A depth order for the scene can now be obtained by a traversal of the BSP tree.


== Visibility in terrains

For 2.5D terrains, the visibility problem is simplified because:
  1. cells are simple polygons, usually triangles or squares;
  2. we can sort those cells from closest to farthest;
  3. we can convert the problem to a 2D one (because a terrain is a 2.5D surface).
  
We can then exploit the connectivity and adjacency between the 2D cells forming a terrain to minimise the number of objects to test (for intersections and for hidden-surface determination).

=== Visibility in grids

Solving visibility queries in grids is simpler than with triangles since the topology of the grid is implied (we have direct access to the neighbours of a given cell), and because grid cells are usually small we can assume that a grid cell is visible (or not) if its centre is visible (or not).
The same assumption is tricky for triangles, since these can be large; in practice it is often assumed that a triangle is visible if its 3 vertices are visible, but this varies per implementation.

We describe below how both LoS, viewshed, and SVF queries can be implemented for grids; the same principles could be applied to TINs with minor modifications.


=== Visibility in TINs

Using the depth-sort algorithm for arbitrary triangles would require using a BSP-tree for indexing and sorting the triangles, and some triangles would need to be decomposed, as explained above.
@fig:acyclicity shows one simple example.
#notefigure(
  image("./figs/acyclicity.pdf", width: 100%),
  caption: [The 3 triangles $tau_1$, $tau_2$, and $tau_3$ form a cycle when viewed from the viewpoint $v$, and it is not possible to sort them from furthest to closest (without decomposing them).],
  dy: -100pt,
) <fig:acyclicity>

However, it has been proven that Delaunay triangulations are _acyclic_ for any fixed viewpoint.
In other words, the in-front/behind relationship for the triangles of a DT, with respect to a given viewpoint, is acyclic (see @fig:ordering_triangles).
#notefigure(
  image("./figs/ordering_triangles.pdf", width: 100%),
  caption: [The triangles in a DT can be ordered in an in-front/behind manner when viewed from a viewpoint.],
) <fig:ordering_triangles>
Therefore, to obtain the triangles intersecting a ray coming out of a viewpoint (ordered from the closest to farthest), it suffices to modify slightly the point location algorithm from @sec:dtwalk.
This operation can be performed in 2D, by projecting the triangles of the TIN to the $x y$-plane.

This means that visibility queries in TINs---like in grids---are greatly simplified compared to the general case where the ordering of objects is the main difficulty (and handling overlapping objects like in @fig:depthsort_issues).



== Line-of-sight
A LoS query, between a viewpoint $v$ and another point $q$, implies reconstructing the profile of the terrain along the vertical projection of $v q$ (let us call it $v q_"xy"$).
It then suffices to follow $v q$ and verify whether the elevation at any ($x,y$) location along the profile is higher than that of $v q$.
As shown in @fig:los, 
since the terrain is discretised into grid cells, there are 2 options to reconstruct the profile between $v$ and $q$:
+ identify all the cells intersected by $v q_"xy"$, and assign the centre of each cell by projecting it to the terrain profile. This is what is done in @fig:los.
+ consider the edges of the cells, collect all the edges that are intersected by $v q_"xy"$, and linearly interpolate the elevations. This is far more expensive to compute, and therefore less used in practice.

The algorithm is thus as follows.
Start at $v$, and for each pixel $c$ encountered along $v q_"xy"$, verify whether the elevation value of $v q$ at that location is higher than the elevation of $c$.
If it is, then continue to the next pixel; if not, then there is an intersection and thus the visibility is False.
If the pixel containing $q$ is reached without detecting an intersection, then the visibility is True.

#place(float: true, auto,
  wideblock[
    #figure(
      image("./figs/los.pdf", width: 100%),
      caption: [Line-of-sight between $v$ and $q$. Observe that along the profile, the points with elevation are not equally spaced.],
      placement: auto,
    ) <fig:los>
  ]
)

#place(float: true, auto,
  wideblock[
    #figure(
      image("./figs/viewshed.pdf", width: 100%),
      caption: [Viewshed for the point $v$; the blue circle is the radius of the horizon (#qty("5000", "m") in this case).],
      placement: auto,
    ) <fig:viewshed>
  ]
)

== Viewshed
As shown in @fig:viewshed, computing the viewshed from a single viewpoint $v$ implies that the LoS between $v$ and the centre of each pixel in a given radius is tested. 
The result of a viewshed is a binary grid; in @fig:overview_viewshed, True/visible pixels are green, and False/invisible ones are dark grey.

While this brute-force approach will work, several redundant computations will be made, since several of the rays from $v$ will intersect the same grid cells.
Furthermore, depending on the resolution, the number of cells in a #qty("5", "km") radius (a reasonable value where humans can see) can become _very_ large.
As an example, with the AHN5 gridded version (#qty("50", "cm") resolution), this means roughly 400 million queries ($(frac(5000 times 2, 0.5))^(2)$).

One alternative solution is shown in @fig:viewshed\b: it involves sampling the grid cells intersecting the border of the visible circle (obtaining several centres $q_i$), and computing the visibility of each of the cells along the line segment $v q_i$ as we 'walk' from $v$.
Observe that, along $v q_i$, it is possible that a point far from $v$ is visible, while several closer points are not; @fig:viewshed\c gives an example.

One solution involves using so-called _tangents_.
The current tangent $t_"cur"$ is first initialised as a vector pointing downwards.
Then, starting at $v$, we walk along the ray $v q_i$, and for each cell intersected its elevation $z$ is compared to the elevation of $t_"cur"$ at that location.
If $z$ is lower, then the cell is invisible.
If $z$ is higher, then the cell is visible and $t_"cur"$ is updated with a new tangent using the current elevation.

Viewsheds with several viewpoints $v_i$ are also very useful, think for instance of obtaining the viewshed along a road.
This can be computed by sampling the road at every #qty("50", "m") and computing the viewsheds from each of the points. 
Each viewshed yields a binary grid, and it suffices to use a map algebra operator to combine the results into one grid (if one cell is visible from any viewpoint, then it is visible).


== Sky-view factor <sec:svf>

// TODO: check SVF and the formula so that it's only geometric and not also with diffuse radiation

#index[sky-view factor]

This problem reverses the roles of the 2 above: instead of observing the terrain from a viewpoint, we observe the sky from a point on the terrain. The result is a value between 0 (the sky is completely hidden) and 1 (the entire sky hemisphere is visible). This is far from being only a geometric curiosity: the sky-view factor is a physical quantity that determines for instance how much diffuse sunlight a location receives, and it is used in urban climatology to quantify how open a street or a courtyard is (see @sec:svf).

The sky-view factor (SVF) of a location $v$ is the portion of the sky that is visible from $v$, ie the part of the sky hemisphere that is not obstructed by the surrounding terrain (and the objects on it, such as buildings).
It thus reverses the point of view of the 2 previous problems: instead of observing the terrain from a viewpoint, we observe the sky from a point of the terrain.
Its computation is nevertheless based on the same machinery as the viewshed.
For each of the $n$ directions (azimuths) equally spaced around $v$, we 'walk' along the ray starting at $p$ up to a maximum distance $R$ (the search radius), and we store the vertical elevation angle $gamma_i$ of the horizon, ie the maximal angle under which the terrain is seen along that direction.
Observe that this is exactly the tangent algorithm described above, except that instead of comparing each cell to the current tangent, we simply keep the largest angle encountered.
The sky visible from $p$ is the portion of the hemisphere lying above the horizon.
// TODO: add a figure illustrating the computation of the vertical elevation
// angle of the horizon $gamma_i$ in $n$ directions (here $n = 8$) up to the
// search radius $R$, and the visible sky as the portion of the hemisphere
// above the horizon (cf Figure 2 in Zaksek et al. 2011)

Let us first consider the case where the horizon has the same elevation angle $gamma$ in every direction.
The visible sky is then the part of the hemisphere above a cone with apex $p$, and its solid angle is $2 pi (1 - sin gamma)$ (the solid angle of the complete hemisphere is $2 pi$).
The visible portion of the sky is thus $(1 - sin gamma)$, and with $n$ directions the sky-view factor is obtained by averaging this quantity:

$ "SVF" = 1 - frac(1, n) sum_(i=1)^n sin gamma_i $

The values range from 1 (the entire hemisphere is visible; this is the case on exposed locations such as peaks) to 0 (the sky is completely obstructed; this happens in deep sinks and at the bottom of deep valleys).
In practice, the two parameters to set are the number of directions $n$ (8 or 16 is common) and the search radius $R$, which should be chosen according to the scale of the features of interest.

The SVF is a physical quantity: under the assumption that diffuse sunlight arrives approximately uniformly from the whole sky, the SVF is proportional to the amount of diffuse solar radiation received at a location.
This explains its use in many applications: it correlates with the urban heat island effect in cities, with the formation of frost on roads, and it is also used to estimate the availability of GPS signals in urban areas.
It is also a useful terrain visualisation technique, as we explain in @chap:relief: since the SVF does not depend on any light direction, it does not suffer from the relief inversion that affects hillshading (see @sec:vis-hillshading).


== Notes and comments

The 'tangent algorithm' to compute viewsheds was first described by #citet(<Blelloch90>).

The description here is inspired by that of #citet(<DeFloriani99-1>).

#citet(<Newell72>) first proposed the depth-sorting algorithm and the decomposition necessary when polygons in the scene cannot be sorted from furthest to closest.

#citet(<Edelsbrunner90>) proved that Delaunay triangulations, in any dimensions, are acyclic.

The sky-view factor was proposed as a relief visualisation technique by #citet(<Zaksek11>), where the formula given above and the influence of the parameters (number of directions, search radius) on the results are discussed in detail.
The paper also describes its use for spatial analysis, eg for energy balance studies and to estimate the availability of GPS signals in urban areas.
// A closely related measure is the _openness_ of #citet(<Yokoyama02>), where instead of the solid angle of the visible sky, the zenith angles of the horizon are averaged (positive openness), or the nadir angles below the surface (negative openness).
// Free and open-source implementations of both, together with several other techniques to visualise high-resolution DTMs, are available in the Relief Visualization Toolbox (#link("https://rvt-py.readthedocs.io/")).


== Exercises

+ Explain why the spacing in @fig:los\c along the profile has points that are not equally spaced.
+ The sky-view factor of a location is computed with $n = 8$ equally spaced directions. What is the SVF if the horizon elevation angle is #qty("30", "degree") in all directions? And if it is #qty("0", "degree") in 4 directions and #qty("60", "degree") in the 4 others?
+ You are given a 2.75D terrain of an area, it is composed of triangles, and your aim is to perform line-of-sight queries between some locations. Describe the algorithm that you will implement to perform the queries.
