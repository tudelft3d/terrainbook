#import "../template.typ": *

= Spatial extent of a set of points <chap:spatialextent>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/dqRb32iGZ_c")

Given a point cloud, one operation that practitioners often need to perform is to define the spatial extent of the dataset.
That is, they need to define the shape of the region that best abstracts or represents the set of points.

As seen in @fig:examples, this region is often in two dimensions, for example in the case of an aerial lidar datasets we may want to know where the ground is (after removing the points on the water), or in the case of the scanning of the façade of a building, we would like to obtain a polygon that represents where the wall is (omitting the windows).
Another example is if we consider a subset of a point cloud that represents the points for a given building, we can be interested in creating the polygon that represents its footprint (@fig:examples\c).

Calculating the spatial extent is useful to calculate the area covered by a dataset, to convert it to other formats (eg raster), or to get an overview of several datasets it is faster to load a few polygons instead of billions of points, etc.

The spatial extent is often called by different names, for instance: envelope, hull, concave hull, or footprints.
It is important to notice that the spatial extent is not uniquely defined and that it is a vague concept.
As @fig:ideas shows, there are several potential regions for a rather simple set of points, and most of these could be considered 'correct' by a human.

In this chapter we present methods that are used in practice to define the spatial extent of a set of points in $bb(R)^(2)$, which implies that the points in a point cloud are first projected to a two-dimensional plane.

#subfigure(
  figure(image("figs/ahn3-water.png", width: 100%), caption: []),
  figure(image("figs/facade.jpg", width: 100%, page: 2), caption: []),
  figure(image("figs/footprint.png", width: 100%), caption: []),
  columns: (1fr, 1fr, 1fr),
  caption: [Three point cloud datasets for which we would like to find the spatial extent. #strong[(a)] An aerial point cloud with several canals (dark colour). #strong[(b)] A scan of a façade containing several windows. #strong[(c)] For the subset formed of the building footprint (green points) we would like to obtain its footprint (line in red).],
  placement: bottom,
  label: <fig:examples>,
)

#subfigure(
  figure(image("figs/idea.pdf", width: 80%, page: 1), caption: [A set of points in $bb(R)^(2)$]),
  figure(image("figs/idea.pdf", width: 80%, page: 2), caption: [Its convex hull]),
  figure(image("figs/idea.pdf", width: 80%, page: 3), caption: [A $chi$-shape]),
  figure(image("figs/idea.pdf", width: 80%, page: 4), caption: [An $alpha$-shape]),
  columns: (1fr, 1fr),
  caption: [Different methods to obtain the spatial extent of a given set of points in the plane.],
  placement: none,
  label: <fig:ideas>,
)


== Properties of the region <sec:properties>

#subfigure(
  figure(image("figs/properties.pdf", width: 100%, page: 2), caption: []),
  figure(image("figs/properties.pdf", width: 100%, page: 4), caption: []),
  figure(image("figs/properties.pdf", width: 100%, page: 5), caption: []),
  figure(image("figs/properties.pdf", width: 100%, page: 3), caption: []),
  columns: (1fr, 1fr, 1fr, 1fr),
  caption: [Different properties for the spatial extent],
  placement: bottom,
  label: <fig:properties>,
)

Let $S$ be a set of points in $bb(R)^(2)$, and $R(S)$ the region that characterise the spatial extent of $S$.
The region is potentially formed by a set of polygons (if $S$ forms two distinct clusters for instance), and in practice most algorithms will compute a linear approximation of $R(S)$, so the polygons will have straight edges as boundaries.

To evaluate the different algorithms to create R($S$), we list here different properties that one must consider when defining the spatial extent of a set of points.
/ P1.: *_Regular_ polygons?* Are polygons allowed to have dangling parts (lines), such as the one in @fig:properties\b
/ P2.: *All points part of the region?* Can outliers be ignored? Or do they have to be part of the region? In @fig:properties\a and @fig:properties\b they are all part of the region, in @fig:properties\c and @fig:properties\d one outlier is not.
/ P3.: *Region is one connected component?* Or are more components allowed? In @fig:properties\a and @fig:properties\c there is one component, but @fig:properties\d has two.
/ P4.: *Are holes allowed in a polygon?* Polygons in @fig:properties\a--@fig:properties\c have only an exterior boundary, while in @fig:properties\d one polygon has an interior boundary too (a hole).
/ P5.: *Computational efficiency* What is the time complexity of the algorithm, and does it require large and complex auxiliary data structures?

== Convex hull <sec:se_ch>

As explained in @sec:convexhull, given $S$, a set of points in $bb(R)^(2)$, its convex hull, which we denote conv($S$), is the minimal convex set containing $S$.
Two examples of convex hulls are in Figures @fig:ideas\b and @fig:properties\a.

For a given set of points, the convex hull is uniquely defined and does not require any parameters (unlike the other methods listed below).
It is also relatively easy to compute: it can be extracted from the Delaunay triangulation, or computed directly using a specific algorithm.
An example of the latter is the well-known _gift wrapping algorithm_, shown in @fig:giftwrapping.
#subfigure(
  image("figs/giftwrapping.pdf", width: 100%, page: 1),
  image("figs/giftwrapping.pdf", width: 100%, page: 2),
  columns: (1fr, 1fr),
  caption: [*(a)* First four steps of the gift wrapping algorithm to compute the convex hull. *(b)* The resulting convex hull.],
  label: <fig:giftwrapping>
) 
It begins with a point that is guaranteed to be on conv($S$) (we can take an 'extreme', such as $a$ in @fig:giftwrapping, because it is the point with the lowest $y$-coordinate), and then picks the point in $S$ (omitting the ones already on conv($S$)) for which the polar angle between the horizontal line and that point ($a$ at this step) is the largest ($b$ in this case), and adds it to conv($S$).
Then for $b$, the polar angle is calculated from the line $a b$ and the $c$ is chosen since it forms the largest angle.
The algorithm continues this way until $a$ is visited again.

If $S$ has $n$ points and conv($S$) is formed of $h$ points, then the gift wrapping algorithm has a time complexity of $cal(O) (n h)$; each of the $h$ points are tested against all $n$ points in $S$.
However, there exist more efficient algorithms that have a time complexity of $cal(O) (n log n)$.

Properties convex hull: \
#table(
  columns: 2,
  align: (left, left),
  table.hline(),
  [*P1*], [The sole polygon is guaranteed to be regular (and convex)],
  [*P2*], [All points are on or inside the region],
  [*P3*], [One component],
  [*P4*], [No holes in the region],
  [*P5*], [$cal(O) (n log  n)$],
  table.hline(),
) 


== Moving arm

#notefigure(
  image("figs/movingarm.pdf", width: 100%, page: 1),
  caption: [First four steps of the #emph[moving arm algorithm] (with a length $l$) to compute the spatial extent.],
) <fig:movingarm:1>

#notefigure(
  image("figs/movingarm.pdf", width: 100%, page: 2),
  caption: [First four steps of the #emph[moving arm algorithm] (with a #emph[knn] where $k=3$) to compute the spatial extent.],
) <fig:movingarm:2>

#notefigure(
  image("figs/movingarm.pdf", width: 90%, page: 3),
  caption: [The resulting region for the moving arm, it is concave. Observe that 1 point from $S$ (highlighted in red) is not part of the region.],
) <fig:movingarm:3>

==== Arm of length $l$
The moving arm is a generalisation of the gift wrapping algorithm (see Section @sec:se_ch) where the infinite line, used to calculate the polar angles, is replaced by a line segment of a given length $l$ (the "moving arm").
This means that, unlike the original gift wrapping algorithm, only a subset of the points in $S$ are considered at each step.
This also means that potentially the result is a polygon that is non-convex.
@fig:movingarm:1 shows the first few steps for a given $l$, and it can be observed that 1 point is not part of the final region.
Observe also that if $l$ had been larger then conv($S$) could have been obtained.

==== Adaptative arm with _knn_
There exists a variation of this algorithm where the length of the moving arm is adaptive at each step; the $k$ nearest neighbours (knn) of a given point $p$ are used to determine it (see @sec:kdtree).
As can be seen in @fig:movingarm:2, the largest polar angle, as used for gift wrapping algorithm, is used to select the point at each step.

==== No guarantee that it will work
Both versions of the algorithm will work in most cases, but there is no guarantee that they will for all inputs.
@fig:movingarm_kdd shows a concrete example.
#notefigure(
  grid(
    image("figs/movingarm.pdf", width: 100%, page: 4),
    image("figs/movingarm.pdf", width: 100%, page: 5),
  ),
  caption: [First four steps of the \emph{moving arm algorithm} (with a length $l$) to compute the spatial extent.],
) <fig:movingarm:kdd>
In this case, a solution to this problem would be to either choose another $k$, or to rotate counter-clockwise instead of clockwise, which will in practice yield different results.

==== Different clusters?
One drawback of the moving arm method is that only one polygon is obtained as a region.
If $S$ forms different clusters (see for instance @fig:clusters), then only the cluster that is the 'lowest' will be output for the region (since the lowest point is picked as a starting point).
#notefigure(
  image("figs/clusters.pdf", width: 90%, page: 2),
  caption: [$S$ has two distinct clusters. In green the typical output if $S$ processed as a single cluster with a moving arm algorithm.],
) <fig:clusters>
Notice that this can also be useful to discard unwanted outliers (unless the lowest point is an outlier).
In practice, the problem of several clusters can be solved by preprocessing the input points with a clustering algorithm (in the case of @fig:clusters two clusters should be detected) and then each cluster is processed separately.
See Section @sec:clustering for an overview.

The worst case time complexity is the same as for the gift wrapping algorithm: $cal(O) (n h)$.
If a $k$d-tree is used, this stays the same but in practice will be sped up as the subset of $S$ tested will be smaller. 
Each query in a $k$d-tree takes $cal(O) (log n)$ on average, but we need to store an auxiliary structure that takes $cal(O) (n)$ storage.

Properties moving arm:
#table(
  columns: 2,
  align: (left, left),
  table.hline(),
  [*P1*], [The sole polygon could be degenerate (self-intersection)],
  [*P2*], [Outliers can be discarded (except if it is the lowest point],
  [*P3*], [One component],
  [*P4*], [No holes in the region],
  [*P5*], [$cal(O) (n h)$],
  table.hline(),
)


== $chi$-shape

#subfigure(
  figure(image("figs/chishape.pdf", width: 100%, page: 1), caption: []),
  figure(image("figs/chishape.pdf", width: 100%, page: 2), caption: []),
  figure(image("figs/chishape.pdf", width: 100%, page: 3), caption: []),
  columns: (1fr, 1fr, 1fr),
  caption: [$chi$-shape examples. *(a)* $S$, its DT, and its envelope (cons($S$)). *(b)* After some edges have been removed. *(c)* The final result for a given threshold. Observe that neither of the red edges can be removed because a self-intersection would be created],
  label: <fig:chishape>,
)

The $chi$-shape is based on first constructing the Delaunay triangulation (DT) of $S$, and then removing iteratively the longest edge forming the envelop (at first this envelop is conv($S$)) until no edge is longer than a given threshold $l$.
The idea is to construct one polygon that is potentially non-convex, and that contains all the points in $S$.
Before removing an edge, we must verify that it will not introduce a topological issue in the envelop, that is that the envelop will not contain a self-intersection (see @fig:chishape\c, the dangling edge is there twice, once in each direction).

A DT can be constructed in $cal(O) (n log n)$.
The number of edges in a DT of $n$ points is roughly $3n$ (thus $cal(O) (n)$), and since verifying the topological constraint can be done locally (previous and next edge) the overall time complexity is $cal(O) (n log n)$.

Properties $chi$-shape:
#table(
  columns: 2,
  align: (left, left),
  table.hline(),
  [*P1*], [The sole polygon is guaranteed to be regular],
  [*P2*], [All points are part of the region],
  [*P3*], [One component],
  [*P4*], [No holes in the region],
  [*P5*], [$cal(O) (n log n)$],
  table.hline(),
)

== $alpha$-shape

The $alpha$-shape is conceptually a generalisation of the convex hull of a set $S$ of points.

It is best understood with the following analogy.
First imagine that $bb(R)^(2)$ is filled with Styrofoam and that the points in $S$ are made of hard material.
Now imagine that you have a carving tool which is a circle of radius $alpha$, and that this tool can be used anywhere from any direction (it is 'omnipresent'), and that it is only stopped by the points.
The result after carving, called the $alpha$-hull, is one or more pieces of Styrofoam.
If we straighten the circular edges, then we obtain the $alpha$-shape.
See @fig:alphashape for an example.
#subfigure(
  figure(image("figs/alphashape.pdf", width: 100%, page: 1), caption: []),
  figure(image("figs/alphashape.pdf", width: 100%, page: 2), caption: []),
  figure(image("figs/alphashape.pdf", width: 100%, page: 3), caption: []),
  figure(image("figs/alphashape.pdf", width: 100%, page: 4), caption: []),
  figure(image("figs/alphashape.pdf", width: 100%, page: 5), caption: []),
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  caption: [Five $alpha$-shape for the same set of points, with decreasing $alpha$ values from left to right.],
  placement: none,
  label: <fig:alphashape>,
)

Now let $alpha$ be a real number with $0 <= alpha <= infinity$.
If $alpha = infinity$, then the $alpha$-shape is conv($S$) because you will not be able to carve inside conv($S$).
As $alpha$ decreases, the $alpha$-shape shrinks and cavities can appear, and different components can be created.
If $alpha = 0$ then the $alpha$-shape is $S$ (which is a valid $alpha$-shape).

The $alpha$-shape is not a polygon or a region, but a complex formed of $k$-simplices, where $0 <= k <= 2$.
Furthermore, it is a subcomplex of the Delaunay triangulation (DT) of $S$.
That is, the easiest method to construct an $alpha$-shape is by first constructing DT($S$), and then removing all edges that are longer than $2alpha$.

In practice, all the $alpha$-shapes of $S$ (for different values of $alpha$) can be calculated and discretised since we know that $alpha$ will range from the shortest edge to the longest.
For each $k$-simplex, we can thus assign a range where it will be present.
Implementations of the $alpha$-shape will often offer to compute automatically an $alpha$ such that the complex obtained is for instance connected and contains only one polygon.

A DT can be constructed in $cal(O) (n log n)$ time, and the algorithm only requires to visit once each of the $cal(O) (n)$ triangles, thus the time complexity is $cal(O) (n log n)$.

Properties $alpha$-shape:
#table(
  columns: 2,
  align: (left, left),
  table.hline(),
  [*P1*], [A complex of $k$-simplices],
  [*P2*], [Some points can be omitted],
  [*P3*], [Several components possible],
  [*P4*], [Regions can contain holes],
  [*P5*], [$cal(O) (n log n)$],
  table.hline(),
)

== Clustering algorithms <sec:clustering>

Clustering algorithms are used widely for statistical data analysis, they allow us to group points (often in higher dimensions) that are close to each other in one group.
Different notions to create clusters can be used, eg distance between the points, density, intervals or particular statistical distributions.
As @fig:clustering shows, the result of a clustering algorithm is that each input point is assigned to a cluster (here a colour), and potentially some outliers are identified.
#subfigure( 
  figure(image("figs/clustering.pdf", width: 100%, page: 1), caption: []),
  figure(image("figs/clustering.pdf", width: 100%, page: 2), caption: []),
  figure(image("figs/clustering.pdf", width: 100%, page: 3), caption: []),
  columns: (1fr, 1fr, 1fr),
  caption: [Clustering points. *(a)* A set of points $S$. *(b)* The result of a clustering algorithm (DBSCAN): points are assigned to a group (based on colours, here 2 groups) or labelled as outliers (grey points). *(c)* DBSCAN has 3 types of points: core points (dark red), border points (orange), and outliers (grey); the orange circle is the $epsilon$ and the $n_"min" = 2$.],
  label: <fig:clustering>,
)

==== k-mean clustering
It is a centroid-based clustering, where a cluster is represented by its centroid.
The parameter $k$ is the number of clusters, usually given as input.
A point belongs to a given cluster if its distance to the centroid is less than for any other cluster centroids.
The algorithm can be seen as an optimisation problem, since we want the total distances from each point to its assigned centroid to be minimised.
In practice, we often seek approximate solutions, for instance the location of the $k$ centroids are first randomised, and thus the algorithm will yield different outputs.
The algorithm is iterative: at each iteration the points are assigned to the closest centroid, and new centroid locations are updated.
The algorithm stops when the centroids have converged and their locations do not change.

==== DBSCAN: density-based clustering
A density-based cluster is defined as an area of higher density than other points, the density being the number of points per area.
The aim is to group points having many close neighbours.

The most used algorithm is DBSCAN (density-based spatial clustering of applications with noise), and works as follows.
First the density is defined with 2 parameters: (1) $epsilon$ is a distance defining the radius of the neighbourhood around a given point; (2) $n_(min)$ is the minimum number of points that a neighbourhood can contain to be considered a cluster.
Points are categorised either as: (1) _core points_ if they have more than $n_(min)$ neighbours within $epsilon$; (2) _border points_ if they have less than $n_(min)$ neighbours within $epsilon$, but are closer than $epsilon$ to a core point; (3) _outliers_.
In @fig:clustering\c, if $n_(min) = 2$ and the orange circle represents $epsilon$, notice that a few points are border points since they have only one point in their neighbourhood, and that 3 points are outliers (1 is clear, the other 2 are very close to being border points).
A cluster is formed by recursively finding all the neighbouring points of a given core point, adding them to the cluster.

== Notes and comments

The properties listed in Section @sec:properties are taken, and slightly adapted, from #citet(<Galton06>). 

The _Quickhull_ algorithm is the most known and used convex hull algorithm, and it is valid in any dimensions. See #citet(<Barber96>) for the details, and #link("http://www.qhull.org") for implementations.

The gift wrapping algorithm to compute the convex hull of a set of points in $bb(R)^(2)$ is from #citet(<Jarvis73>).

The moving arm with a length is presented and described in #citet(<Galton06>), and the adaptative one in #citet(<Moreira07>).
In both papers, the authors describe different strategies to make the algorithm work for all input, but these do not have any warranty to output a simple polygon.

The $chi$-shape was introduced in #citet(<Duckham08>).

The explanation of the $alpha$-shape is taken from #citet(<Edelsbrunner94>) and from the #link("https://doc.cgal.org/latest/Alpha_shapes_2/index.html")[CGAL documentation].

The DBSCAN algorithm was introduced in #citet(<Ester96>).

== Exercises

+ Given a DT($S$), how to extract conv($S$)?
+ What are the disadvantages of the $chi$-shape compared with the $alpha$-shape?
+ If the parameter $l$ for the $chi$-shape is equal to the $alpha$ parameter for an $alpha$-shape, will the resulting shapes be the same?
+ Given an $alpha$-shape of $S$, how to calculate how many components are part of it?
+ Draw what would happen if one of the 2 edges was removed in @fig:chishape\c.
+ What is the influence of $k$ for the moving arm algorithm (with a _knn_)? Will a higher $k$ create a larger or smaller region in general?
