#import "../template.typ": *

= Runoff modelling <chap:runoff>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/0NzZoJATFjc")

Many interesting DTM operations are based on runoff modelling, ie the computation of the flow and accumulation of water on a terrain.
These include knowing where streams will form in the case of heavy rainfall, finding the areas that will be affected by a waterborne pollutant, tracing the areas that could become submerged by floodwater, and calculating the rate of erosion or sedimentation in a given area.

In hydrology, runoff modelling can be very complex (@fig:hydrology).
Hydrological models usually consider different precipitation scenarios, model various types of overland and subsurface flows, and take into account many location- and time-dependent factors, such as the depth of the water table and the permeability of the soil.
Such models can be quite accurate, but they require high-resolution data that is often not available, they are difficult to create without specialised knowledge, and they involve substantial manual work.

#figure(
  image("figs/hydrology.pdf", width: 95%),
  caption: [Different types of water flows as modelled in hydrology. Figure adapted from #citet(<Beven12>).],
  placement: none,
) <fig:hydrology>

By contrast, the simpler _GIS models of runoff_ can be performed automatically in large areas with only a DTM.
These models mostly use gridded raster terrains, and so we will generally refer to this representation throughout this chapter.
The methods described here can be adapted to work on other representations, but the flow computation on a TIN is different enough that we discuss it separately at the end of this chapter.
In order for the GIS models of runoff to achieve their results, two big assumptions are usually made:

+ that all water flow is _overland_, thus ignoring all subsurface flows and dismissing factors such as evaporation and infiltration; and
+ that a good estimate for the total flow at any point is the drainage area upstream from it, ie the area above the point which drains through/to it, which is roughly equivalent to rain that is falling evenly all over a terrain.

Based on these assumptions, runoff modelling is simplified by considering only two values, which are computed for every cell in a DTM:

/ Flow direction: Given a DTM cell, towards which nearby cells and in which proportions does water flow from it? #note[flow direction]#index[flow direction]
/ Flow accumulation: Given a DTM cell, what is the total water flow that passes through it? #note[flow accumulation]#index[flow accumulation]

We look at a few different methods to compute these values in the next two sections.

== #flex-heading[Flow direction][Computing the flow direction] <se:direction>

Theoretically, the flow direction of a point is the direction with the steepest descent at that location, which does correspond to the direction towards which water would naturally flow.
However, the discretisation of a terrain into DTM cells means that some kind of an approximation needs to be made.
There are two broad approaches that can be followed to do this: computing a single flow direction, which assumes that all the water in a DTM cell flows to one other cell, or multiple flow directions, which assumes that the water in a DTM cell can flow towards multiple other cells.

=== Single flow direction

The earliest and simplest method to compute the flow direction of a cell is to compute the slope between the centre of the cell and the centre of all its neighbouring cells (using the distance between the centres and the difference in elevation), then assign the flow direction towards the neighbour with the steepest descent.
The method is known as the _single flow direction (SFD)_ approach, and when applied to a raster grid, it usually considers that there are eight neighbours to each pixel (left, right, up, down and the diagonals). 
#note[single flow direction (SFD)]#index[single flow direction]#index[SFD]
For this reason, it is also known as the _eight flow directions (D8)_ approach.
#note[D8 flow direction]#index[D8 flow direction]#index[eight flow directions]

On one hand, the method is very fast and easy to implement, and it avoids dispersing the water flow between multiple cells.
On the other hand, it can have significant errors in the flow direction, and it does not allow for divergent flows.
For instance, in a square grid, the errors can be of up to #qty("22.5", "degree") (because the method is forced to choose a neighbouring cell in increments of #qty("45", "degree")).
This method can therefore easily create artefacts in certain geometric configurations (@fig:d8).

#subfigure(
  figure(image("figs/d8_dinf.pdf", width: 100%), caption: [D-infinity]),
  figure(image("figs/d8_d8.pdf", width: 100%), caption: [D8]),
  columns: (1fr, 1fr),
  caption: [Flow accumulation as water drains from a circular cone, computed with D-infinity (left) and D8 (right). The D8 method creates artefactual spokes every #qty("45", "degree"), while D-infinity gives a smooth pattern. Based on #citet(<Tarborton97>).],
  placement: none,
  label: <fig:d8>,
)

Many of these artefacts can be reduced by using the rho8 ($rho 8$) method, which modifies D8 to assign the flow direction to one of its lower neighbours randomly with probability proportional to the slope.
#note[rho8 ($rho 8$)]#index[$rho 8$]#index[rho8]
However, it produces non-deterministic results, which is often a sufficient reason not to use it.

Despite its age and limitations, the SFD method is still widely used and available in many GIS tools.

=== Multiple flow directions

In an attempt to overcome the limitations of the SFD method, a variety of methods assign the flow direction of a DTM cell fractionally to some or all of its lower neighbouring cells according to some criteria.
These methods are collectively known as multiple flow directions (MFD), 
#note[multiple flow directions (MFD)]#index[multiple flow directions]#index[MFD]
and they usually use a variation of this equation:

$  F_i = frac((L_i tan alpha_i)^(x), sum_(j = 1)^(n)(L_j tan alpha_j)^(x))  $

where $F_i$ is the flow towards the i-th neighbouring cell, $L_i$ is the flow width (@fig:quinn), $alpha_i$ is the gradient towards the i-th neighbouring cell (and so $tan (alpha_i)$ is the slope), $x$ is an exponent that controls the dispersion, and $n$ is the number of lower neighbours of the cell, ie the ones that receive flow.

#notefigure(
  image("figs/quinn.pdf", width: 100%),
  caption: [The flow width $L$ can be computed using the geometry of the DTM cells. In the case of a square grid with spacing $d$, it is $frac(sqrt(2), 4)d$ for the diagonals ($L_2$) and $1/2d$ for the adjacencies ($L_1$), where $d$ is the grid spacing. Based on #citet(<Quinn91>).],
) <fig:quinn>

As shown in @fig:dispersion, MFD methods show characteristically wider flows compared to SFD methods.
D8 does not disperse the flow, but the path is constrained to the 8 possible grid directions.
By contrast, #citet(<Quinn91>) (an MFD method) can model the flow direction in a way that matches the topography better, but it also introduces substantial dispersion.
More modern approaches try to combine some of the advantages of both approaches.

The most widely used modern method to do so is the D∞ (#citet(<Tarborton97>)) method, which computes, for each cell, the direction of the steepest descent within the triangular facets formed by the cell and pairs of its neighbouring cells.
#note[D∞ ($D^infinity$)]#index[$D^infinity$]#index[D∞]
The resulting flow direction is continuous, ie it is not restricted to the 8 grid directions, and the flow is split between the two neighbouring cells that bracket this direction, in proportions that depend on the angles.
D∞ thus avoids both the quantisation of the flow direction inherent to D8 and the strong dispersion of the earlier MFD methods.

#subfigure(
  figure(image("figs/dispersion_d8.pdf", width: 100%), caption: [D8]),
  figure(image("figs/dispersion_quinn.pdf", width: 100%), caption: [Quinn]),
  columns: (1fr, 1fr),
  caption: [Flows in a circular cone: SFD (D8) versus MFD (#citet(<Quinn91>)). Based on #citet(<Tarborton97>).],
  placement: none,
  label: <fig:dispersion>,
)

== #flex-heading[Flow accumulation][Computing the flow accumulation] <se:accumulation>

After the flow directions in all the cells of a DTM have been computed, the usual next step is to use this information to compute the flow accumulation in all of them.
Note that this assumes that the flow directions are well defined in every cell, which is not always the case; we discuss how to handle the problematic cases (sinks and flats) in @se:sinks and @se:flats.
As stated in the assumptions we make for GIS models of runoff, the flow accumulation at a given DTM cell can be estimated by the area that drains to it.
Note that in the case of a square grid, it is simply the number of cells that drain to it.

In practical terms, the flow accumulation is defined based on a recursive operation:

$  A_0 = a_0 + sum_(i = 1)^(n) p_i A_i  $

where $A_0$ is the accumulated flow for a cell, $a_0$ is the area of the cell, $p_i$ is the proportion of the flow of the i-th neighbour that drains to the cell, $A_i$ is the accumulated flow for the i-th neighbour, $n$ is the number of neighbouring cells.
Note that this calculation can be sped up substantially by: (i) storing the accumulated flows that have already been computed, and (ii) not following the recursion when $p_i = 0$.

== Solving issues with sinks <se:sinks>

_Sinks_#note[sink]#index[sink], which are also known as depressions or pits, are areas in a DTM that are completely surrounded by higher terrain, ie from which no path of non-increasing elevation leads to the boundary of the DTM.
Some of these are natural features that are present in the terrain (eg lakes and dry lakebeds), towards which water would flow and stagnate in reality, and are thus not a problem for runoff modelling.
However, they can also be artefacts of the DTM (eg noise and vegetation removal can create depressions), or they can be very small areas that are easily filled (ie flooded), after which water would flow out of them.
In the latter case, we need to implement a mechanism to route water flows out of these depressions, since otherwise our runoff model could have very large water flows stopping at even tiny depressions.
We will look at two common options to solve this problem: modifying a DTM by filling in (certain) sinks, and implementing a flow routing algorithm that allows water to flow out of sinks.

=== Filling in sinks

#index[sink filling]

The aim of the algorithms to fill in sinks is to increase the elevation of certain DTM cells in a way that ensures that all the cells in the DTM can drain to a cell on its boundary (@fig:pf), or possibly to a set of cells that are known to be valid outlets, eg lakes and oceans.
#note[outlet]
At the same time, the elevation increases should be minimised in order to preserve the original DTM as much as possible.
In the best case scenario, we can imagine that the resulting DTM is one that: (i) is identical to the original DTM where there is no water, but (ii) follows the top of water bodies where there is.

#figure(
  image("figs/pf.pdf", width: 80%),
  caption: [A vertical cross-section of a DTM with a filled sink. The dashed line is the original terrain and the thicker solid line is the filled terrain; the shaded area is the material added to fill the sink.],
  placement: none,
) <fig:pf>

One efficient method to fill in sinks is the priority-flood algorithm #citep(<Barnes14a>).
It works by keeping: (i) a list of DTM cells that are known to drain, which is kept sorted by elevation; and (ii) a raster marking whether each cell of the DTM is known to drain yet.
The list is initialised with the cells on the boundary of the DTM (which are assumed to be able to drain outwards), as well as other specially marked cells (eg those forming part of a lake or a large river).
Then, it iteratively: (i) removes the lowest cell from the sorted list of cells that are known to drain, (ii) raises the elevation of its neighbours that are not yet known to drain and that are lower than the cell to the level of the cell (leaving those that are higher unchanged), (iii) adds the neighbours that are not yet known to drain to the list.
Note that implicit in this last step is the fact that the neighbour cells are deemed to be able to drain through the current (lowest) cell.

=== Least-cost (drainage) paths

An alternative to modifying a DTM to eliminate sinks is to implement a more complex water routing algorithm that allows water to flow out of sinks.
For this, the usual approach is to implement a variation of the $A^(\*)$ search algorithm, which in this context is known as the least-cost paths (LCP)#note[least-cost paths (LCP)]#index[least-cost paths]#index[LCP] algorithm #citep(<Metz11>).

For each sink, the LCP algorithm finds the least-cost path to route its water out towards a cell that is already known to drain.
The cost of moving from one cell to another is typically based on the difference in elevation between them, so that the search finds the path that requires the least elevation gain, ie the one that crosses the rim of the sink at its lowest point.
The flow direction of the cells along this path is then set towards the outlet, effectively breaching the rim of the sink.

== #flex-heading[Flow direction in flats][Assigning flow direction in flats] <se:flats>

_Flats_ are areas in a DTM that have the same elevation.
#note[flat]#index[flat]
They therefore do not have a well-defined flow direction, which causes problems for many water routing algorithms.
Flats are common in real terrain (eg lakes, floodplains and salt flats), but they are more often the result of precision limits, noise removal, or sink filling algorithms.

It is thus often necessary to apply a method that assigns a flow direction to flats, either by: (i) modifying the DTM to eliminate them, and then assigning them a flow direction in the usual way, or (ii) assigning them a flow direction directly.

After all flats in a DTM have been identified and their extent is known, algorithms usually work by (i) assigning an artificial gradient away from higher terrain (@fig:ht), ie terrain in a flat is assumed to become lower as we move farther away from its neighbouring higher terrain; and/or (ii) assigning an artificial gradient towards lower terrain (@fig:lt), ie terrain in a flat is assumed to become lower as we move closer to its neighbouring lower terrain.
#citet(<Barnes14>) is a good example of an efficient method that combines both of these approaches, resulting in more natural flow directions and better results than would be possible with either approach individually.

#figure(
  image("figs/ht.pdf", width: 100%),
  caption: [In a flat surrounded by higher terrain (dark grey) with a single lower-elevation outlet (light grey), we can use a gradient away from the higher terrain to route water out of the flat and towards the outlet. For this, we can iteratively assign (tiny or symbolic) elevation decreases in the flat starting from the higher terrain until all non-draining cells in the flat have been covered. Note that in this case, a sink is produced by the procedure. Figure from #citet(<Barnes14>).],
  placement: none,
) <fig:ht>

#figure(
  image("figs/lt.pdf", width: 100%),
  caption: [In a flat surrounded by higher terrain (dark grey) with a single lower-elevation outlet (light grey), we can use a gradient towards the outlet to route water out of the flat. For this, we can iteratively assign (tiny or symbolic) elevation increases in the flat starting from the outlet until all non-draining cells in the flat have been covered. Figure from #citet(<Barnes14>).],
  placement: none,
) <fig:lt>

== #flex-heading[Drainage networks][Drainage networks and basins] <sec:drainage_basins>

Interpreting DTM cells as nodes and the flow direction as directed edges connecting them yields the _drainage network_#note[drainage network]#index[drainage network] of a DTM.
However, it is usually best to filter out the least important parts of the network using a flow accumulation threshold.
A common starting point for this threshold is the mean flow accumulation in the DTM, but the exact value is usually set by trial and error until the desired parts of the network are kept.

Based on a computed drainage network, it is then possible to extract the _drainage basins_#note[drainage basin]#index[drainage basin]#index[basin] of a DTM by considering the areas that are drained by one or more nodes of the network (@fig:oceans).
This operation can be performed in many different places, such as the end node of a river (yielding its river basin), the nodes just before junctions in the network (yielding the drainage basins of the tributaries of a river), or the end nodes of a selected part of the network (yielding the drainage basin of a sea or ocean).
The lines that separate adjacent drainage basins are _drainage divides_#note[drainage divide]#index[drainage divide], which form topographical ridges.

#figure(
  image("figs/Ocean_drainage.png", width: 100%),
  caption: [The areas that drain to all the oceans can be computed by selecting the DTM cells on the coastline of these oceans and finding the areas that drain through them. Note the endorheic basins that drain to none of these cells. These actually form sinks in the DTM. From Wikimedia Commons.],
  placement: none,
) <fig:oceans>

== Runoff on TINs

All the methods described so far assume a gridded raster DTM.
The same computations can be performed on a TIN, but the approach is somewhat different, because the surface is continuous and there are no cells to accumulate flow into.

In a TIN, water flows over each triangular facet in the direction of its steepest descent, which is the projection of the facet's normal onto the horizontal plane.
When a flow line reaches an edge shared by two triangles, it continues on the adjacent facet in its steepest-descent direction, which means that the flow lines follow the edges of the TIN.
The flow direction is thus continuous, like in the D∞ method, but it is determined geometrically rather than being discretised to the neighbouring cells.

A continuous TIN surface has no flats and no interior sinks in the sense of @se:sinks: within a facet the surface is planar, so the gradient is well defined everywhere, and the special handling described there is not needed.
This does not mean that water never accumulates, however.
Every point has a well-defined downhill direction except at the vertices, and a vertex is a local minimum when all the facets incident to it slope away from it.
Water therefore genuinely collects in such vertices, just as it would in a real depression or a raster sink.
Some of these local minima are real terrain features, but others are artefacts of the triangulation, and a TIN must be built with care: a poor triangulation can, for instance, make the flow lines cycle instead of reaching an outlet.

As with rasters, when a local minimum is a triangulation artefact (or a depression we wish to drain), water must be routed out of it.
The TIN analogue of filling a sink is to remove the offending vertex: the vertex is deleted and the polygon formed by its neighbours is re-triangulated, which eliminates the local minimum.
The alternative, closer in spirit to the least-cost paths of @se:sinks, is to allow water to escape over the lowest point of the rim of the local minimum, ie along the shortest path of least elevation gain to a point that drains.
Both operations change the surface and can create new artefacts elsewhere, so they require care.
#citet(<Palacios86>) describes such a TIN-based approach to basin delineation.

To compute the flow accumulation at a point, one traces the flow line backwards from it, accumulating the area of every facet that drains into it.
Unlike in a raster, the facets of a TIN are not all the same size, so each one contributes its own (horizontal) area, in the same way that the cell area $a_0$ appears in the accumulation equation of @se:accumulation.
Because the flow lines are not aligned to a grid, they cannot be accumulated cell by cell as in a raster; the usual approach is to trace each flow line and distribute the drained area along it.

== Notes and comments

#citet(<Beven12>) is a good reference book on hydrology.
It covers how to make much more complex runoff models than the ones described here.

#citet(<OCallaghan84>) was the original paper to describe the D8 method.
#citet(<Fairfield91>) modify D8 into the stochastic rho8 method.
#citet(<Quinn91>) describes the original MFD method.
#citet(<Tarborton97>) describes the D∞ MFD method and contains nice figures comparing multiple methods.

#citet(<Barnes14a>) describes how to fill in sinks, while #citet(<Metz11>) describes how to use a variation of $A^(*)$ search algorithm to route water out of them.
#citet(<Barnes14>) describes how to assign the drainage direction over flats.

#citet(<Jones90>) is a classic reference for the computation of runoff on TINs.
#citet(<Palacios86>) is another early reference that handles the delineation of rivers, ridges and basins, including the treatment of pits, on TINs.

== Exercises

+ Given a raster map of precipitation values, how would you be able to improve the flow accumulation estimates?
+ Why is the flow width important?
+ You have a cycle in your drainage network. How can that happen? How would you solve it?
+ How can you detect endorheic basins without finding all other basins first?
+ Come up with an algorithm to identify flats in a DTM.
