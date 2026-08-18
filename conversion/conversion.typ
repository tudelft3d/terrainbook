#import "../template.typ": *

= Conversions between terrain representations <chap:conversion>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/youtu.be/Nqfp94KpcUA")

We consider in this chapter the following four terrain representations and discuss the conversions between them:

#figure(
  image("figs/reps.pdf", width: 100%),
  // caption: [],
  // placement: none,
)

#wideblock(side: "outer")[
#figure(
  // placement: ,
  caption: [Overview of the interpolation methods discussed in this chapter, with their properties (as described in @sec:interpol_properties)],
  table(
    stroke: 0.2pt,
    columns: (19mm, 1fr, 1fr, 1fr, 1fr),
    align: (left, center, center, center, center),
    table.hline(),
    table.header[from/to][*PC*][*raster*][*TIN*][*isolines*],
    table.hline(),
    [*PC*], [--], [interpolate at middle points of cells], [create DT using 2D projection of points (ie using $x$ and $y$ only)], [convert to TIN + extract from triangles + structure output],
    [*raster*], [keep middle points only], [--], [create TIN using middle points of cells + TIN simplification], [extract from grid cells + structure output],
    [*TIN*], [keep only vertices], [interpolate at middle points of cells], [--], [extract from triangles + structure output],
    [*isolines*], [keep only vertices \ (⚠️ wedding cake effect)], [convert lines to points + interpolate \ (⚠️ wedding cake effect)], [create DT using points \ (⚠️ wedding cake effect)], [--],
    
    table.hline(),
  ) 
) <tab:results_interpol>
]


== #flex-heading[Conversion to raster][Conversion of PC/TIN to raster] <sec:r-interpol>

#figure(
  image("figs/r-interpolation.pdf", width: 100%),
  caption: [#strong[(a)] input sample points. #strong[(b)] size/location of output raster. #strong[(c)] 9 interpolations must be performed (at the locations marked with blue disks): in the middle of each cell. #strong[(d)] the convex hull of the sample points show that 2 estimations are outside, thus no interpolation. #strong[(e)] the resulting raster.],
  placement: none,
) <fig:r-interpolation>

As shown in @fig:r-interpolation, this step is trivial: one needs to interpolate at the locations of the centre points of the raster cells.
The interpolation method can be any of the ones described in @chap:interpol and @chap:kriging.

== Conversion to isolines <sec:iso>

Reading a contour map requires some skill, however it is considerably easier to learn to interpret a contour map than to manually draw one from a limited set of sample points.
Yet this was exactly the task of many cartographers in the past couple of centuries: it was intuitively done by imagining a local triangulation of sample points.

Isolines are usually directly extracted from either a TIN or a grid representation of a terrain. 
#figure(
  image("figs/isoline.pdf", width: 90%),
  caption: [Vertical cross-section of a terrain (left), and a 2D projection of the terrain TIN with the extracted #qty("200", "m") isoline (right).],
  placement: none,
) <fig:isolineidea>
The basic idea, as shown in @fig:isolineidea, is to compute the intersection between a level value (eg #qty("200", "m")) and each cell of the terrain (triangle or grid cell in our case).
Notice that the cells are 'lifted' to their elevation. 
Each cell of the terrain is thus visited, one after the other, and for each cell if there is an intersection (which forms a line segment) then it is extracted.
The resulting set of segment lines forms an approximation of the isoline.
This process is then repeated for every level value.
Notice that an isoline can have several _components_, for instance when the terrain has more than one peak.
#note[isoline components]#index[isoline components]

Therefore the number and size of the line segments in the resulting isoline are dependent on the resolution of the data representation.

The basic algorithm for extracting one isoline is shown in @algo:iso.
#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Simple extraction of one isoline],
  pseudocode-list(
    title: [#smallcaps[OneIsoline] ($E$, $z_0$)]
  )[
    + *Input:* a planar partition $E$ formed of cells (either rectangular or triangular cells); the elevation value $z_0$
    + *Output:* a list of unstructured line segments representing the contour lines at $z_0$
    + _segmentList_ = []
    + *for* $e in E$
      + *if* $z_0$ intersects $e$ *then*
        + \// See @fig:rasterconfs and @fig:isoline-tr
        + extract intersection $chi$ of $z_0$ with $e$
        + add $chi$ to _segmentList_
  ]
) <algo:iso>
   

#figure(
  image("figs/isoline-square.pdf", width: 95%),
  caption: [Different cases when extracting an isoline at elevation #qty("10", "m") (in blue) for a regular grid. The blue lines are the ones extracted for that cell.],
  placement: none,
) <fig:rasterconfs>
#figure(
  image("figs/isoline-tr.pdf", width: 95%),
  caption: [Different cases when extracting an isoline at elevation #qty("10", "m") (in blue) for a TIN. The blue lines are the ones extracted for that triangle.],
  placement: none,
) <fig:isoline-tr>
Note that since the algorithm visits every grid cell or triangle individually and requires only local information, it is very easy to parallelise. 
It is thus a scalable algorithm.
Its time complexity is $cal(O) (c)$, where $c$ is the number of cells.
Recall from @chap:dtvd that for $n$ points a DT contains about $2n$ triangles.

The same idea can be used to extract all the isolines: for each triangle/cell and each level value, extract all the necessary line segments.

=== Conversion of raster to isolines <sec:r-iso>

Observe that, for a raster, the dual of the raster must be constructed (see Section @sec:duality), that is we consider the centre each pixel as a sample point, and we join with an edge the centres of two adjacent pixels (in @fig:rasterconfs, the four values are centres of 4 adjacent raster cells).

Intersections are computed by linearly interpolating the elevations of the vertex pairs along the edges of this grid.
@fig:rasterconfs illustrates the different possible configurations. 
The top-left case indicates the case for which there are no intersections: all vertices are either higher or lower than $z_0$. 

Observe that when two vertices are exactly at $z_0$, then the extraction of these is in theory not necessary because the neighbouring cell could also extract them. 
However, we do not want to obtain an output with duplicate line segments, and thus a simple solution to this is to only extract such line segments if they are for instance the lower and/or left segments of a given cell.

The most interesting case is the bottom-left one in @fig:rasterconfs, it occurs when the two pairs of opposing points are respectively higher and lower than $z_0$.
This forms a saddle point. 
The ambiguity arises here since there are two ways to extract a valid pair of contour line segments (only one of the 2 options must be extracted).
This can be resolved by simply picking a random option or consistently choose one geometric orientation.

=== Conversion TIN to isolines <sec:tin-iso>

Since a triangle has one fewer vertices than a square grid cell, there are less possible intersection cases and, more importantly, there is no ambiguous case. 

When one or more vertices of the triangle are at the same elevation as $z_0$, then one must be careful.
As shown in @fig:isoline-tr, if only one vertex is at $z_0$ then nothing should be extract; if two vertices are at $z_0$ then the edge between these can be extracted; if all three vertices are at $z_0$ then the triangle is flat/horizontal and nothing should be extracted (because adjacent triangles will have edges extracted).

To avoid extracting twice the same line segment when two vertices are at $z_0$ (case on the right in @fig:isoline-tr), then we can simply look at the normal of the edge segment: if its $y$-component is positive then it can be added, if $y=0$ then only add if the $x$-component is positive.

Observe that since the algorithm is simpler than that for a raster dataset, one way to extract isolines from a raster dataset is by first triangulating it: each square cell is subdivided into two triangles (simply ensure that the diagonal is consistent, eg from lower-left to top-right).

=== Structuring the output <sec:structuring>

The line segments obtained from the simple algorithms above are not structured, ie they are in an arbitrary order (the order in which we visited the triangles/cells) and are not connected.
Furthermore, the set of line segments can form more than one _component_, a set of segments forming a closed polygon (unless they are at the border of the dataset).
Perhaps the only application where having unstructured line segments is fine is for visualisation of the lines.
For most other applications this can be problematic, for instance:
+ if one wants to know how many peaks above #qty("1000", "m") there are in a given area;
+ if smoothing of the isolines is necessary, with the Douglas-Peucker algorithm for instance;
+ if a GIS format requires that the isolines be closed polylines oriented such that the higher terrain is on the left for instance, such as for colouring the area enclosed by an isoline.

To obtain structured segments, the simplest solution is to merge, as post-processing, the line segments based on their start and end vertices.
Observe that the line segments will not be consistently oriented to form one polygon (see @fig:isoline2a), that is the orientation of the segments might need to be swapped.
This can be done by simply starting with a segment $a b$, and searching for the other segment having $b$ as either start or end vertex, and continue until a component is formed (a polygon is formed), or until no segment can be found (the border of the dataset is reached, as shown in @fig:isoline2a).
#figure(
  image("figs/isoline2.pdf", width: 100%),
  caption: [#strong[(a)] The isoline segments extracted with @algo:iso do not have a consistent orientation. #strong[(b)] @algo:iso can be sped up by starting at a seed triangle and 'tracing' the isoline; the order is shown by the blue arrows.],
  placement: none,
) <fig:isoline2>

As shown in @fig:isoline2\b, another solution is to find _one_ cell $tau_0$ intersecting the isoline at a given elevation, 'tracing' the isoline by navigating from $tau_0$ to the adjacent cell, and continuing until $tau_0$ is visited again (or the border of the dataset is reached).
To navigate to the adjacent cell, it suffices to identify the edge $epsilon$ intersecting the isoline, and then navigating to the triangle/cell that is incident to $epsilon$.
It is possible that there is no adjacent cell, if the boundary of the convex hull is reached in a TIN for instance.
This requires that the TIN be stored in a topological data structure in which the adjacency between the triangles is available (for a grid this is implied).

The main issue is finding the starting cells (let us call them seed triangles).
Obviously, it suffices to have one seed for each of the component of the isolines (there would be 2 seeds in @fig:isoline2\b).
An easy algorithm to extract all the components of an isoline requires visiting all the cells in a terrain, and keeping track of which triangles have been visited (simply store a Boolean attribute for each triangle, which is called a _mark bit_).
Simply visit triangle sequentially and mark them as 'visited', when one triangle has an intersection then start the tracing operation, marking triangles as visited as you trace.

=== Smoothness of the contours <sec:smoothness-contours>

The mathematical concept of the _Implicit Function Theorem_ states that a contour line extracted from a field $f$ will be no less smooth than $f$ itself.
In other words, obtaining smooth contour lines can be achieved by smoothing the field itself.
#citet(<Sibson97>)Sibson goes further in stating that:
#quote(block: true)[
  #emph("The eye is very good at detecting gaps and corners, but very bad at detecting discontinuities in derivatives higher than the first. For contour lines to be accepted by the eye as a description of a function however smooth, they need to have continuously turning tangents, but higher order continuity of the supposed contours is not needed for them to be visually convincing.")
]
In brief, in practice we should use interpolant functions whose first derivative is continuous (ie $C^(1)$) if we want to obtain smooth contours. 
$C^(0)$ interpolants are not enough, and $C^(2)$ ones are not necessary.

== Simplification of a TIN <sec:tin-simpl>

The TIN simplification problem is:
#quote(block: true)[
  Given a TIN formed by the Delaunay triangulation of a set $S$ of points, the aim is to find a subset $R$ of $S$ which will approximate the surface of the TIN as accurately as possible, using as few points as possible. The subset $R$ will contain the 'important' points of $S$, ie a point $p$ is important when the elevation at location $p$ can not be accurately estimated by using the neighbours of $p$.
]

The overarching goal of TIN simplification is always to (smartly) reduce the number of points in the TIN.
This reduces memory and storage requirements, and speeds up TIN analysis algorithms.

Observe that the simplification of a TIN can be used to simplify a raster terrain: we can first obtain the triangulation of the middle points of each cell, and then simplify this TIN to obtain a simplified terrain.

=== The importance of a point

The importance of a point is a measure that indicates the error in the TIN when that point would not be part of it. 
Imagine for instance a large flat area in a terrain. 
This area can be accurately approximated with only a few large triangles, and inserting points in the middle of such an area does not make the TIN more accurate. 
An area with a lot of relief on the other hand can only be accurately modelled with many small triangles. 
We can therefore say that the points in the middle of the flat area are less important than the points in the area with relief.

The importance of a point---or importance measure---can be expressed in several ways, eg based on an elevation difference or the curvature of the point. Here we focus on the _vertical error_ which has proven to be effective in practice.

The vertical error of a point $p$ is the elevation difference between $p$ itself and the interpolated elevation in the TIN $cal(T)$ at the $(x,y)$ coordinates of $p$ (see @fig:meshsimplification). 
Notice that $cal(T)$ does not contain $p$ as a vertex.

#figure(
  image("figs/mesh_simplification.pdf", width: 85%),
  caption: [The importance measure of a point can be expressed by its vertical error. When this error is greater than a given threshold $epsilon_(max )$, the point is kept ($p_1$), else it is discarded ($p_2$).],
  placement: none,
) <fig:meshsimplification>

=== TIN simplification algorithms

There are two main approaches to TIN simplification: decimation and refinement. 
In a decimation algorithm, we start with a TIN that contains all the input points, and gradually remove points that are not important. 
In a refinement algorithm, we do the opposite: we start with a very simple TIN, and we gradually refine it by adding the important points. 

==== TIN simplification by refinement

Here we describe an iterative refinement algorithm based on a series of insertion.
It begins with a simple triangulation of the spatial extent and, at each iteration, finds the input point with highest importance---the highest vertical error---in the current TIN and inserts it as a new vertex in the triangulation. 
The algorithm stops when the highest error of the remaining input points with respect to the current TIN is below a user-defined threshold $epsilon _(max )$. 
Algorithm @algo:tin-simp:ref shows the pseudo-code.
It is also possible to insert only a certain percentage of the number of input points, eg we might want to keep only 10% of them.

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [TIN simplification by refinement],
  pseudocode-list(
    title: [#smallcaps[TINRefinement]]
  )[
    + *Input:* A set of input points $S$, and the simplification threshold $epsilon_(max)$ 
    + *Output:* A triangulation $cal(T)$ that consists of a subset of $S$ and that satisfies $epsilon_(max )$
    + Construct an initial triangulation $cal(T)$ that covers the 2D bbox of $S$
    + $epsilon  <-  infinity$
    + *while* $epsilon > epsilon_(max)$
      + $epsilon <- 0$
      + $q <-$ nil 
      + *for* $p in S$
        + $tau  <-$ the triangle in $cal(T)$ that contains $p$ 
        + $epsilon_(tau ) <-$ the vertical error of $p$ with respect to $tau$
        + *if* $epsilon _(tau ) > epsilon$ *then*
          + $epsilon <- epsilon_(tau )$
          + $q <- p$
      + \//-- insert the point $q$ that has the largest error
      + insert into $cal(T)$ the point $q$
      + remove the point $q$ from $S$
  ]
) <algo:tin-simp:ref>

The implementation of the decimation algorithm is similar to the refinement algorithm. The main differences are 
+ we start with a full triangulation of all the input points, instead of an empty triangulation;
+ instead of iteratively adding the point with the highest importance, we iteratively remove the point with the lowest importance, and
+ in order to compute the importance of a point we actually need to remove it _temporarily_ from the triangulation before we can decide if it should be permanently removed. In other words: we need to verify what the vertical error would be if the point was not present.

Algorithm @algo:tin-simp:dec shows the pseudo-code for the TIN decimation algorithm.
#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [TIN simplification by decimation],
  pseudocode-list(
    title: [#smallcaps[TINDecimation]]
  )[
    + *Input:* A set of input points $S$, and the simplification threshold $epsilon_(max)$ 
    + *Output:* A triangulation $cal(T)$ that consists of a subset of $S$ and that satisfies $epsilon_(max )$
    + $cal(T)  <-$ a triangulation of $S$
    + $epsilon  <- 0$ \;
    + *while* $epsilon < epsilon_(max)$
      + $epsilon <- 0$
      + $q <-$ nil 
      + *for* $p in cal(T)$
        + remove $p$ from $cal(T)$
        + $epsilon_(tau ) <-$ the vertical error of $p$ with respect to $tau$
        + *if* $epsilon_(tau ) < epsilon$ *then*
          + $epsilon <- epsilon_(tau )$
          + $q <- p$
      + \//-- remove the point $q$ that has the smallest error
      + remove from $cal(T)$ the point $q$
  ]
) <algo:tin-simp:dec>

It should be noticed that the implementation of this algorithm requires a method to delete/remove a vertex from a (Delaunay) triangulation, and that many libraries do not have one.
#note[The implementation of the DT in #link("https://docs.scipy.org/doc/scipy/reference/generated/scipy.spatial.Delaunay.html")[SciPy] does not allow to delete/remove vertices, but #link("https://www.cgal.org")[CGAL] and #link("https://github.com/hugoledoux/startinpy")[startinpy] do.]

Observe that the Algorithms @algo:tin-simp:ref and @algo:tin-simp:dec both state that the importance of the points must be completely recomputed after each iteration of the algorithms (either one removal or one insertion), but that in practice several of these will not have changed.
As can be seen in @chap:dtvd, the insertion/deletion of a single point/vertex will only _locally_ modify the triangulation, and it is thus faster from a computational point of view to flag the vertices incident to the modified triangles, and only update these.

=== Comparison: decimation versus refinement

While both methods will allow us to obtain similar results, the properties of the resulting terrain are different.
Consider the threshold $epsilon_(max )$ that is used to stop the simplification process.
If the refinement method is used, then it is guaranteed that the final surface of the terrain will be at a maximum of $epsilon_(max )$ (vertical distance) to the 'real surface' because all the points of the input are considered.
However, with the decimation method, after a vertex is deleted from the TIN, it is never considered again when assessing whether a given vertex has an error larger than $epsilon_(max )$. 
It is thus possible that the final surface does not lie within $epsilon_(max )$, although for normal distribution of points, it should not deviate too much from it.

In practice, refinement is often computationally more efficient than decimation because we do not need to first build a TIN from all input points before removing several of them again. 
However, decimation could be more efficient when you already have a detailed TIN, stored in a topological data structure, that just needs to be slightly simplified.

== #flex-heading[Wedding cake effect][Conversion isolines to TIN/raster creates the "wedding cake effect"] <sec:weddingcake>

#wideblock[
#subfigure(
  figure(image("figs/wedding0.png", width: 100%), caption: []),
  figure(image("figs/wedding-tin.png", width: 100%), caption: []),
  figure(image("figs/wedding-nn.png", width: 100%), caption: []),
  columns: (1fr, 1fr, 1fr),
  caption: [The 'wedding cake' effect. #strong[(a)] The input isolines have been discretised into sample points. #strong[(b)] The TIN of the samples creates several horizontal triangles. #strong[(c)] The surface obtained with nearest-neighbour interpolation.],
  placement: none,
  label: <fig:wedding>,
)
]
If the input is a set of isolines, then the simplest solution is, as shown in @fig:weddinga, to convert these to points and then use any of the interpolation methods previously discussed.
This conversion can be done by either keeping only the vertices of the polylines, or by sampling points at regular intervals along the lines (say every #qty("10", "m")).
However, one should be aware that doing so will create terrains having the so-called _wedding cake effect_.
Indeed, the TIN obtained with a Delaunay triangulation, as shown in @fig:weddingb, contains several horizontal triangles; these triangles are formed by 3 vertices from the same isoline.
If another interpolation method is used, eg nearest neighbour (@fig:weddingc), then the results are catastrophic.

Solving this problem requires solutions specifically designed for such inputs.
The main ideas for most of them is to add extra vertices between the isolines, to avoid having horizontal triangles. 
One strategy that has proven to work is to add the new vertices on the _skeleton_, or medial-axis transform, of the isolines, which are located 'halfway' between two isolines.
The elevation assigned to these is based on the elevations of the isolines.

== Notes and comments

The _Implicit Function Theorem_ is further explained in #citet(<Sibson97>).

#citet(<Dakowicz03>) describe in detail the skeleton-based algorithm to interpolate from isolines, and show the results of using different interpolation methods.

The basic algorithm to extract isolines, which is a brute-force approach, can be slow if for instance only a few isolines are extracted from a very large datasets: all the $n$ triangles/cells are visited, and most will not have any intersections.
To avoid this, #citet(<VanKreveld96>) build an auxiliary data structure, the _interval tree_, which allows us to find quickly which triangles will intersect a given elevation.
It is also possible to build another auxiliary structure, the contour tree, where the triangle seeds are stored #citep(<VanKreveld97-1>).
Such methods require more storage, but can be useful for interactive environment where the user extracts isolines interactively.

#citet(<Garland95>) elaborate further on different aspects of TIN simplification, such as different importance measures, the differences between refinement and decimation, and the usefulness of data-dependent triangulations. 
They also show how Algorithm @algo:tin-simp:ref can be made a lot faster by only recomputing the importance of points in triangles that have been modified.

== Exercises

+ When converting isolines to a TIN, what main "problem" should you be aware of? Describe _in detail_ one algorithm to convert isolines (given for instance in a _shapefile_) to a TIN and avoid this problem.
+ What would the isocontours of a 2.75D terrain look like?
+ In @sec:structuring, it is mentioned that merging the segments will form one polygon. But how to ensure that the orientation of that resulting curve is consistent, that it is for instance having higher terrains on the right?
+ Given a raster terrain (GeoTiff format) that contains several cells with `no_data` values, describe the methodology you would use to extract contour lines from it. As a reminder, contours lines should be closed curves, except at the boundary of the dataset.
+ Assume you have the small terrain formed of 3 triangles below, draw the isoline in this TIN for an elevation of #qty("10", "m"). \ #image("./figs/threetr.pdf")
