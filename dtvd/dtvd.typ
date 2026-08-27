#import "../template.typ": *

#let Orient = smallcaps[Orient]
#let Walk = smallcaps[Walk]
#let Incircle = smallcaps[Incircle]

= Delaunay triangulations \& Voronoi diagrams <chap:dtvd>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/ysLCuqcyJZA")

Delaunay triangulations (DT) and Voronoi diagrams (VD) are fundamental data structures for terrains, both for their representation and for their processing (eg interpolation and several operations on terrains and point clouds are based on one of these structures).

This chapter formally defines the VD and DT in two dimensions, and introduces several concepts in computational geometry and combinatorial topology that are needed to understand, construct, and manipulate them in practice. 
Delaunay triangulations with constraints are also discussed.

== Voronoi diagram <sec:vd>

#index[Voronoi diagram]

Let $S$ be a set of points in $bb(R)^(2)$ (the two-dimensional Euclidean space). 
The Voronoi cell of a point $p in S$, defined $cal(V)_p$, is the set of points $x in bb(R)^(2)$ that are closer to $p$ than to any other point in $S$; that is:
$  cal(V)_p = {x in bb(R)^(2) | bar.v.double x - p bar.v.double thin <= thin bar.v.double x - q bar.v.double, forall thin q in S }.  $
The union of the Voronoi cells of all generating points $p in S$ form the Voronoi diagram of $S$, defined VD($S$). 
If $S$ contains only two points $p$ and $q$, then VD($S$) is formed by a single line defined by all the points $x in bb(R)^(2)$ that are equidistant from $p$ and $q$. 
This line is the perpendicular bisector of the line segment from $p$ to $q$, and splits the plane into two half-planes. 
$cal(V)_p$ is formed by the half-plane containing $p$, and $cal(V)_q$ by the one containing $q$. 
#notefigure(
  image("./figs/halfspaces.pdf", width: 100%),
  caption: [The Voronoi cell $cal(V)_p$ is formed by the intersection of all the half-planes between $p$ and the other points.],
) <fig:halfspaces>
As shown in @fig:halfspaces, when $S$ contains more than two points (let us say it contains $n$ points), the Voronoi cell of a given point $p in S$ is obtained by the intersection of $n-1$ half-planes defined by $p$ and the other points $q in S$. 
That means that $cal(V)_p$ is always convex. 
Notice also that every point $x in bb(R)^(2)$ has at least one nearest point in $S$, which means that VD($S$) covers the entire space.

#notefigure(
  image("./figs/vd_circle.pdf", width: 100%),
  caption: [The VD for a set $S$ of points in the plane (the black points). The Voronoi vertices (brown points) are located at the centre of the circle passing through three points in $S$, provided that this circle contains no other points in $S$ in its interior.],
) <fig:vd_circle>
As shown in @fig:vd_circle, the VD of a set $S$ of points in $bb(R)^(2)$ is a planar graph. 
Its edges are the perpendicular bisectors of the line segments of pairs of points in $S$, and its vertices are located at the centres of the circles passing through three points in $S$. 
The VD in $bb(R)^(2)$ can also be seen as a two-dimensional cell complex where each 2-cell is a (convex) polygon (see @fig:vd2d). 
#figure(
  image("./figs/vd2d.pdf", width: 100%, page: 3),
  caption: [VD of a set of points in the plane (clipped by a box). The point $p$ (whose Voronoi cell is dark grey) has seven neighbouring cells (light grey).],
  placement: none,
) <fig:vd2d>
Two Voronoi cells, $cal(V)_p$ and $cal(V)_q$, lie on the opposite sides of the perpendicular bisector separating the points $p$ and $q$.

The VD has many interesting properties, what follows is a list of the most relevant properties in the context of this course.
/ Size:: if $S$ has $n$ points, then VD($S$) has exactly $n$ Voronoi cells since there is a one-to-one mapping between the points and the cells.
/ Voronoi vertices:: a Voronoi vertex is equidistant from 3 data points. Observe for instance in @fig:vd_circle that the Voronoi vertices are at the centre of circles.
/ Voronoi edges:: a Voronoi edge is equidistant from 2 points.
/ Convex hull:: let $S$ be a set of points in $bb(R)^(2)$, and $p$ one of its points. $cal(V)_p$ is unbounded if $p$ bounds conv($S$). Otherwise, $cal(V)_p$ is the convex hull of its Voronoi vertices. Observe that in @fig:vd_circle, only the point in the middle has a bounded Voronoi cell.

== Delaunay triangulation <sec:dt_definition>

#index[Delaunay triangulation]

Let $cal(D)$ be the VD of a set $S$ of points in $bb(R)^(2)$. 
Since VD($S$) is a planar graph, it has a dual graph, and let $cal(T)$ be this dual graph obtained by drawing straight edges between two points $p,q in S$ if and only if $cal(V)_p$ and $cal(V)_q$ are adjacent in $cal(D)$. 
Because the vertices in $cal(D)$ are of degree 3 (3 edges connected to it), the graph $cal(T)$ is a triangulation. 
$cal(T)$ is actually called the Delaunay triangulation (DT) of $S$, and, as shown in @fig:dt2da, 
#figure(
  image("./figs/vd2d.pdf", width: 100%, page: 4),
  caption: [The DT of a set of points in the plane (same point set as @fig:vd2d). The green circles show 2 examples of empty circumcircles.],
  // placement: none,
) <fig:dt2da>
partitions the plane into triangles---where the vertices of the triangles are the points in $S$ generating each Voronoi cell---that satisfy the _empty circumcircle_ test (a circle is said to be _empty_ when no points are in its interior). 
If $S$ is in general position, then DT($S$) is unique.

=== Convex hull <sec:convexhull>

#index[convex hull]

The DT of a set $S$ of points subdivides completely conv($S$), ie the union of all the triangles in DT($S$) is conv($S$).

Let $S$ be a set of points in $bb(R)^(2)$, the _convex hull_ of $S$, denoted conv($S$), is the minimal convex set containing $S$. 
It is best understood with the elastic band analogy: imagine each point in $bb(R)^(2)$ being a nail sticking out of the plane, and a rubber band stretched to contain all the nails, as shown in @fig:convex_hull. 
When released, the rubber band will assume the shape of the convex hull of the nails. 
Notice that conv($S$) is not only formed by the edges connecting the points (the rubber band), but all the points of $bb(R)^(2)$ that are contained within these edges (thus the whole polygon).

Observe that the number of triangles $t$ in a DT is related to the number of vertices $n$ and the number of points $h$ on the boundary of conv($S$): $t = 2n - 2 - h$.
Each insertion (see @fig:insertion_deletion) increases $t$ by exactly two.

#notefigure(
  image("./figs/convex_hull.pdf", width: 100%),
  caption: [The convex hull of a set of points in $bb(R)^(2)$.],
) <fig:convex_hull>

=== Local optimality

Let $cal(T)$ be a triangulation of $S$ in $bb(R)^(2)$. 
An edge $sigma$ is said to be _locally_ Delaunay if it either:
/ (i): belongs to only one triangle, and thus bounds conv($S$), or
/ (ii): belongs to two triangles $tau_a$ and $tau_b$, formed by the vertices of $sigma$ and respectively the vertices $p$ and $q$, and $q$ is outside of the circumcircle of $tau_a$ (see @fig:local).
@fig:local gives an example that violates the second criteria: both $p$ and $q$ are contained by the circumcircles of their opposing triangles, ie of $tau_b$ and $tau_a$ respectively.

#notefigure(
  grid(
    image("./figs/local.pdf", width: 100%, page: 1),
    image("./figs/local.pdf", width: 100%, page: 2),
  ),
  caption: [A quadrilateral that can be triangulated in two different ways. Only the top configuration is Delaunay. #strong[(top)] $sigma$ is locally Delaunay. #strong[(bottom)] $sigma$ is not locally Delaunay.],
) <fig:local>

In an arbitrary triangulation, not every edge that is locally Delaunay is necessarily an edge of DT($S$), but local optimality implies globally optimality in the case of the DT:
#quote(block: true)[
Let $cal(T)$ be a triangulation of a point set $S$ in $bb(R)^(2)$. If every edge of $cal(T)$ is locally Delaunay, then $cal(T)$ is the Delaunay triangulation of $S$.
]
This has serious implications as the DT---and its dual---are locally modifiable, ie we can theoretically insert, delete or move a point in $S$ without recomputing DT($S$) from scratch.

=== Angle optimality

The DT in two dimensions has a very important property that is useful in applications such as finite element meshing or interpolation: the _max-min angle optimality_. 
Among all the possible triangulations of a set $S$ of points in $bb(R)^(2)$, DT($S$) maximises the minimum angle (max-min property), and also minimises the maximum circumradii. 
In other words, it creates triangles that are as equilateral as possible. 
Notice here that maximising the minimum angle is not the same as minimising the maximum, and the DT only guarantees the former.

In the context of modelling terrains, the max-min angle optimality ensures that a surface approximated with the set of lifted (Delaunay) triangles will be close to the original surface.
@fig:notdelaunay shows two examples of a hill, the left surface is a random triangulation of some sample points of the surface, and the right one is the Delaunay triangulation of the same set of points.

#wideblock[
#figure(
  image("./figs/notdelaunay/notdelaunay.png", width: 90%),
  caption: [The same set of sample points of a hill is triangulated on the left with a random triangulation (non-Delaunay) and right with a Delaunay triangulation. The shape of the triangles is shown at the bottom by projecting them to the $x y$-plane.],
    placement: none,
  ) <fig:notdelaunay>
]

=== Lifting on the paraboloid <sec:parabolic_lifting>

There exists a close relationship between DTs in $bb(R)^(2)$ and convex polyhedra in $bb(R)^(3)$. 

Let $S$ be a set of points in $bb(R)^(2)$. 
The parabolic lifting map projects each vertex $v(v_x, v_y)$ to a vertex $v^(+)(v_x, v_y, v_x^(2)+v_y^(2))$ on the paraboloid of revolution in $bb(R)^(3)$. 
The set of points thus obtained is denoted $S^(+)$. 
Observe that the paraboloid in three dimensions defines a surface whose vertical cross sections are parabolas, and whose horizontal cross sections are circles.

The relationship is the following: every triangle of the lower envelope of conv($S^(+)$) projects to a triangle of the Delaunay triangulation of $S$; this is illustrated in @fig:paraboloid for a simple DT. 
#notefigure(
  image("./figs/paraboloid.pdf", width: 100%),
  caption: [The parabolic lifting map for a set $S$ of points $bb(R)^(2)$.],
) <fig:paraboloid>

 Construction of the two-dimensional DT can be transformed into the construction of the convex hull of the lifted set of points in three dimensions (followed by a simple project to the two-dimensional plane).

#box-practice("How does it work in practice?")[
  Since it is easier to construct convex hulls (especially in higher dimensions, ie 4+), the DT is often constructed with this approach, even in 2D. 
  One popular and widely used implementation is Qhull (#link("http://www.qhull.org")).
]

=== Degeneracies <sec:degeneracies>

The previous definitions of the VD and the DT assumed that the set $S$ of points is in general position, ie the distribution of points does not create any ambiguity in the two structures. 
For the VD/DT in $bb(R)^(2)$, the degeneracies, or special cases, occur when 3 points lie on the same line and/or when 4 points are cocircular. 
For example, in two dimensions, when four or more points in $S$ are cocircular there is an ambiguity in the definition of DT($S$). 
#notefigure(
  image("./figs/degeneracies.pdf", width: 100%),
  caption: [The DT for four cocircular points in two dimensions is not unique (but the VD is).],
  dy: 120pt,
) <fig:degeneracies>
As shown in @fig:degeneracies, the quadrilateral can be triangulated with two different diagonals, and an arbitrary choice must be made since both respect the Delaunay criterion (points should not be on the interior of a circumcircle, but more than three can lie directly on the circumcircle).

This implies that in the presence of four or more cocircular points, DT($S$) is not unique. 
Notice that even in the presence of cocircular points, VD($S$) is still unique, but it has different properties. 
For example, in @fig:degeneracies, the Voronoi vertex in the middle has degree 4 (remember that when $S$ is in general position, every vertex in VD($S$) has degree 3). 
When three or more points are collinear, DT($S$) and VD($S$) are unique, but problems with the implementation of the structures can arise.

== #flex-heading[Duality DT/VD][Duality between the DT and the VD] <sec:duality>

#index[duality]

Duality can have many different meanings in mathematics, but it always refers to the translation or mapping in a one-to-one fashion of concepts or structures. 
We use it in this course in the sense of the dual graph of a given graph. 
Let $G$ be a planar graph, as illustrated in @fig:dual_graph (black edges).
#notefigure(
  image("./figs/dual_graph.pdf", width: 100%),
  caption: [A graph $G$ (black lines), and its dual graph $G^(star )$ (dashed lines).],
) <fig:dual_graph>

Observe that $G$ can also be seen as a cell complex in $bb(R)^(2)$.
The duality mapping is as follows (also shown in detail in @fig:dualdetail).
The dual graph $G^(star )$ has a vertex for each face (polygon) in $G$, and the vertices in $G^(star )$ are linked by an edge if and only if the two corresponding dual faces in $G$ are adjacent (in @fig:dual_graph, $G^(star )$ is represented with dashed lines). 
Notice also that each polygon in $G^(star )$ corresponds to a vertex in $G$, and that each edge of $G$ is actually dual to one edge (an arc in @fig:dual_graph) of $G^(star )$ (for the sake of simplicity the dual edges to the edges on the boundary of $G$ are not drawn).

The VD and the DT are the best example of the duality between plane graphs.
As @fig:dualdetail demonstrates:
+ a Voronoi cell is dual to a Delaunay vertex;
+ a Voronoi edge is dual to a Delaunay edge;
+ a Voronoi vertex is dual to a Delaunay triangle.
Observe that, as shown in Figures @fig:vd2d and @fig:dualdetail, the location of a Voronoi vertex $v^(star )$, which is dual to a Delaunay triangle $tau$, is at the centre of the circumcircle of $tau$; @app:equations[Appendix] describes how to obtain the ($x,y$)-coordinates of the centre.

#notefigure(
  grid(
    // columns: 2,
    // align: "vertical",
    image("./figs/dualdetail.pdf", width: 100%),
    table(
      columns: 3,
      stroke: none,
      align: (left, center, left),
      table.header([DT], [], [VD]),
      table.hline(),
      [#text(color.rgb("#c9f6c8"))[*face*]], [#sym.arrow.l.r], [#text(color.rgb("#2e8b58"))[*vertex*]],
      [#text(color.rgb("#000080"))[*vertex*]], [#sym.arrow.l.r], [#text(color.rgb("#d6ecf3"))[*face*]],
      [#text(color.rgb("#e6793d"))[*edge*]], [#sym.arrow.l.r], [#text(color.rgb("#ffd602"))[*edge*]],
      table.hline(),
    ),
  ),
  caption: [Duality between the DT (dotted) and the VD (dashed).],
  placement: none,
) <fig:dualdetail>


== #flex-heading[Incremental construction][Incremental construction of the DT] <sec:dtconstruction>

Since the VD and the DT are dual structures, the knowledge of one implies the knowledge of the other one. 
In other words, if one has only one structure, she can always extract the other one. 
Because it is easier, from an algorithmic and data structure point of view, to manage triangles over arbitrary polygons (they have a constant number of vertices and neighbours), constructing and manipulating a VD by working only on its dual structure is simpler and usually preferred. 
When the VD is needed, it is extracted from the DT. 
This has the additional advantage of speeding up algorithms because when the VD is used directly intermediate Voronoi vertices---that will not necessarily exist in the final diagram---need to be computed and stored.

While there exist different strategies to construct a DT, we focus in this book on the _incremental_ method since it is easier to understand and implement.
An incremental algorithm is one where the structure is built incrementally; in our case this means that each point is inserted one at a time in a valid DT and the triangulation is updated, with respect to the Delaunay criterion (empty circumcircle), after each insertion. 
Observe that the insertion of a single point $p$ in a DT modifies only _locally_ the DT, ie only the triangles whose circumcircle contains $p$ need to be deleted and replaced by new ones respecting the Delaunay criterion (see @fig:insertion_deletion for an example). 
#notefigure(
  image("./figs/insertion_deletion.pdf", width: 90%),
  caption: [#strong[(top)] The DT before and #strong[(bottom)] after a point $p$ has been inserted. Notice that the DT is updated only locally (only the yellow triangles are affected).],
) <fig:insertion_deletion>

In sharp contrast to this, other strategies to construct a DT (eg divide-and-conquer and plane sweep algorithms, see Section @sec:notes), build a DT in _one_ operation (this is a batch operation), and if another point needs to be inserted after this, the whole construction operation must be done again from scratch. 
That hinders their use for some applications where new data coming from a sensor would have to be added, or where we want to delete points because they are outliers.

The incremental insertion algorithm, and the other well-known algorithms, can all construct the DT of $n$ points randomly distributed in the Euclidean plane in $cal(O) (n log n)$.

@fig:insertion_steps illustrates the steps of the algorithm, and @algo:insert1pt its pseudo-code. 
#figure(
  image("./figs/insertion_steps.pdf", width: 90%),
  caption: [Step-by-step insertion, with flips, of a single point in a DT in two dimensions.],
  placement: none,
) <fig:insertion_steps>

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Algorithm to insert one point in a DT],
  pseudocode-list[
    + *Input:* A DT($S$) $cal(T)$, and a new point $p$ to insert 
    + *Output:* $cal(T) ^(p) = cal(T)  union  {p}$ \//-- the DT with point $p$
    + find triangle $tau$ containing $p$
    + insert $p$ in $tau$ by splitting it into 3 new triangles (flip13)\;
    + push 3 new triangles on a stack
    + *while* stack is non-empty *do*
      + $tau = {p,a,b} <-$ pop from stack
      + $tau_a = {a,b,c} <-$ get adjacent triangle of $tau$ having the edge $a b$
      + *if* $c$ is inside circumcircle of $tau$ *then*
        + flip22 $tau$ and $tau_a$
        + push 2 new triangles on stack
  ]
) <algo:insert1pt>

In a nutshell, for the insertion of a new point $p$ in a DT($S$), the triangle $tau$ containing $p$ is identified and then split into three new triangles by joining $p$ to every vertex of $tau$. 
Second, each new triangle is tested---according to the Delaunay criterion---against its opposite neighbour (with respect to $p$); if it is not a Delaunay triangle then the edge shared by the two triangles is _flipped_ (a _flip_ is an operation to modify adjacent triangles, see below) and the two new triangles will also have to be tested later. 
This process stops when every triangle having $p$ as one of its vertices respects the Delaunay criterion.

=== Initialisation: the big triangle or the infinite vertex <sec:big_tr>

The DT of a set $S$ of points subdivides conv($S$), which means in practice that the triangles on the boundary of conv($S$) will not be adjacent to exactly 3 neighbouring triangles.

#notefigure(
  image("./figs/big_tr.pdf", width: 100%),
  caption: [The set $S$ of points is contained by a _big triangle_ formed by the vertices $o_1$, $o_2$ and $o_3$. Many triangles outside conv($S$) are created.],
) <fig:big_tr>
#notefigure(
  image("./figs/infinite_vertex.pdf", width: 60%),
  caption: [The infinite vertex ($infinity$) is used to ensure that the triangles in DT($S$) are always adjacent to exactly 3 triangles. This DT contains 7 finite triangles and 5 infinite triangles.],
) <fig:infinite_vertex>
Because it is convenient to store and manipulate triangles having exactly 3 neighbours, in practice most DT construction algorithms will use one of these two "tricks":

/ Big triangle: $S$ is entirely contained in a big triangle $tau_"big"$ several times larger than the spatial extent of $S$; conv($S$) therefore becomes $tau_"big"$. 
 @fig:big_tr illustrates this.
 The construction of DT($S$) is for example always initialised by first constructing $tau_"big"$, and then the points in $S$ are inserted one by one.
/ Infinite vertex: a fictitious vertex is inserted at the "infinity", and therefore the edges on the boundary of conv($S$) are incident to "infinite triangles" formed by a convex hull edge and the infinite vertex, see @fig:infinite_vertex.
 This can be conceptually seen as embedding $S$ on a sphere, and adding the infinite vertex on the other side of the sphere.
 The infinite vertex is conceptually the same as the big triangle but is numerically more stable since the size of the big triangle does not need to be defined.
 Observe however that since the infinite vertex has no coordinates, the predicates #Orient #Incircle are used to construct a DT (see Section @sec:predicates) cannot be used with the infinite vertex and infinite triangles, instead one should handle those with specific cases.

Using a big triangle or an infinite vertex has many practical advantages. 
First, since an edge is always guaranteed to be shared by two triangles, point location algorithms never "fall off" the convex hull. 
Second, when a single point $p$ needs to be inserted in DT($S$), this guarantees that $p$ is always inside an existing triangle; we thus do not have to deal explicitly with vertices added outside the convex hull. 
Third, identifying the vertices that bounds conv($S$) is easy: they have one incident triangle that has one or more of the big triangle vertices (or it contains the infinite vertex).
Fourth, the Voronoi cells of the points that bounds conv($S$) will be bounded, since the only unbounded cells will be the ones of the 3 points of $tau_"big"$. 
This can help for some of the spatial analysis operations, for instance interpolation based on the VD (see @chap:interpol).

The main disadvantage is that more triangles than needed are constructed. 
For example in @fig:big_tr only the shaded triangles would be part of DT($S$). 
The extra triangles can nevertheless be easily marked as they are the only ones containing at least one of the 3 points forming $tau_"big"$.

#box-practice("How are DT created in practice?")[
  Several implementations of the DT use a big triangle or the infinite vertex, CGAL (#link("https://www.cgal.org/")) and startinpy (#link("https://github.com/hugoledoux/startinpy")) are two examples.
  Those will refer in their API to "finite" and "infinite" vertices, edges, and triangles.
  It is therefore essential to understand the mechanism to use those libraries, even if one is not constructing the DT herself.
]

=== Point location with walking <sec:dtwalk>

To find the triangle containing the newly inserted point $p$, we can use the point-in-polygon test for every triangle (the standard GIS operation), but that brute-force operation would be very slow (complexity would be $cal(O) (n)$ or a single point location since each triangle must be checked).

A better alternative is to use the adjacency relationships between the triangles, and use a series of #Orient tests, as described in Section @sec:predicates, to navigate from one triangle to the other. 
The idea, called "walking", is shown in @fig:walk and details are given in the @algo:walk.
#figure(
  image("./figs/walk.pdf", width: 70%),
  caption: [The Walk algorithm for a DT in two dimensions. The query point is $p$.],
  placement: none,
) <fig:walk>

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Algorithm to walk in a DT],
  pseudocode-list[
    + *Input:* A DT($S$) $cal(T)$, a starting triangle $tau$, and a query point $p$ 
    + *Output:* $tau_r$: the triangle in $cal(T)$ containing $p$
    + $tau_r$ = None
    + *while* $tau_r$ == None
      + visitededges = 0
      + *for* i in [0..2] *do*
        + $sigma_i <-$ get edge opposite to vertex $i$ in $tau$
        + *if* $#Orient (sigma_i, p) < 0$ *then*
          + $tau <-$ get neighbouring triangle of $tau$ incident to $sigma_i$
          + break
        + $"visitededges" = "visitededges" + 1$
      + *if* $"visitededges" == 3$ *then*
        + \//-- all the edges of $tau$ have been tested
        + $tau_r$ = $tau$
    + Return $tau_r$
  ]
) <algo:walk>


The idea is as follows: in a DT($S$), starting from a triangle $tau$ (it can be any), we move to one of the adjacent triangle of $tau$ ($tau$ has three neighbours, we choose one neighbour $tau_i$ such that the query point $p$ and $tau$ are on each side of the edge shared by $tau$ and $tau_i$) until there is no such neighbour, then the simplex containing $p$ is the current triangle $tau$.
Notice that this algorithm is not affected by degenerate cases, and that if an "Orientation" test returns 0 (collinearity), then it is simply considered a positive result. 
This will ensure that if the query point $p$ is located exactly at the same position as one point in $S$, then one triangle incident to $p$ will be returned.

It should be mentioned that while it appears straightforward, the point location step is the biggest computational bottleneck for a DT implementation.
For a large dataset (eg a lidar point cloud, see @chap:massive for some massive examples), if several thousands/millions of triangles must be tested to find the one containing a give point, then it will be very slow; the insertion itself with a series of flips is generally fast since around 4 flips will be performed for a normal distribution of points.
In practice, because most real-world datasets will have a high _spatial coherence_ (in simple terms, two consecutive points in the dataset are close in reality; see Section @sec:spatial_coherence), the time spent on walking will be minimised since most library will start the walk from the previously inserted point.

=== Flips

#notefigure(
  image("./figs/flip22.pdf", width: 70%),
  caption: [A #emph[flip22].],
) <fig:flip22>
Flips are operations that modify _locally_ the triangulation.
There are 3 flip operations (the numbers refer to the number of triangles before and after the flip):
- a *flip22* modifies the configuration of two adjacent triangles. 
 Consider the set $S = {a, b, c, d}$ of points in the plane forming a quadrilateral, as shown in @fig:flip22. 
 There exist exactly two ways to triangulate $S$: the first one contains the triangles $a b c$ and $b c d$; and the second one contains the triangles $a b d$ and $a c d$. 
 Only the first triangulation of $S$ is Delaunay because $d$ is outside the circumcircle of $a b c$. 
 A _flip22_ is the operation that transforms the first triangulation into the second, or vice-versa.
 It is performed in constant time $cal(O) (1)$.
- a *flip13* is the operation of inserting a vertex inside a triangle, and splitting it into three triangles (see @fig:flip13).
- a *flip31* is the inverse operation that deletes a vertex (see @fig:flip13).
#notefigure(
  image("./figs/flip13.pdf", width: 70%),
  caption: [A #emph[flip13] and its inverse operation #emph[flip31].],
) <fig:flip13>

=== Controlling the flips

To control which triangles have to be checked and potentially flipped, we use a _stack_#note[A stack is a first-in-last-out data structure: #link("https://en.wikipedia.org/wiki/Stack_(abstract_data_type)")]. 
When the stack is empty, then there are no more triangles to be tested, and we are guaranteed that all the triangles in the triangulation have an empty circumcircle.

=== Predicates <sec:predicates>

#index[predicates]
Constructing a DT and manipulating it essentially require two basic geometric tests (called _predicates_): #Orient  determines if a point $p$ is left, right or lies on the line segment defined by two points $a$ and $b$; and #Incircle determines if a point $p$ is inside, outside or lies on a circle defined by three points $a$, $b$ and $c$. 
Both tests can be reduced to the computation of the determinant of a matrix:

//-- TODO: add InCircle smallcaps
$ op(#Orient)(a, b, p) = mat(delim: "|", a_x, a_y, 1 ; b_x, b_y, 1 ; p_x, p_y, 1) $

$ "InCircle"(a, b, c, p) = mat(delim: "|", a_x, a_y, a^(2)_x + a^(2)_y, 1 ; b_x, b_y, b^(2)_x + b^(2)_y, 1 ; c_x, c_y, c^(2)_x + c^(2)_y, 1 ; p_x, p_y, p^(2)_x + p^(2)_y, 1)  $ <eq-insphere>

== #flex-heading[DT data structures][Data structures for storing a DT]

A triangulation is simply a subdivision of the plane into polygons, and thus any data structure used in GIS can be used to store a triangulation.

/ Simple Features:: while many use this (PostGIS and any triangulation you see in Shapefiles), this is not smart: (1) the topological relationships between the triangles are not stored; (2) the vertices are repeated for each triangle (and we know that for a Poisson distribution of points in the plane a given point has exactly 6 incident triangles).
/ Edge-based structures:: all the edge-based topological data structure used for storing planar graphs (eg DCEL, half-edge, winged-edge, etc) can be used. These usually lead to large storage space.

Observe that in practice, if only the DT is wanted (and not the constrained one, see below), practitioners will often simply store the sample points and reconstruct on-the-fly the DT, since it is unique (if we omit points not in general position that is).

However, because it is simpler to manage triangles over arbitrary polygons (they always have exactly 3 vertices and 3 neighbours), data structures specific for triangulations have been developed and are usually used.

#figure(
  image("./figs/tr_ds.pdf", width: 100%),
  caption: [The triangle-based data structure to store efficiently a triangulation (and the adjacency relationships between the triangles).],
) <fig:tr_ds>

The simplest data structure, as shown in @fig:tr_ds, considers the triangle as being its atom and stores each triangle with 3 pointers to its vertices and 3 pointers to its adjacent triangles.
Observe that the order in which the vertices and adjacent triangles are stored correspond to each other. 
This is an important property that allows an efficient retrieval of triangles in the Walk algorithm (@algo:walk) for instance.

== #flex-heading[Constraints in DT][Constrained and Conforming Delaunay Triangulations]

#index[Constrained DT]#index[CDT]#index[Conforming DT]

Given as input a set $S$ of points and straight-line segments in the plane, different triangulations of $S$ (so that the segments are respected) can be constructed. 
We are mostly interested in the _constrained Delaunay triangulation_ (ConsDT) and the _conforming Delaunay triangulation_ (ConfDT), see @fig:cdt_example for one example.
#notefigure(
  image("./figs/cdt_example.pdf", width: 85%),
  caption: [#strong[(top)] A set $S$ of points and straight-line segments. #strong[(middle)] Constrained DT of $S$. #strong[(bottom)] Conforming DT of $S$; the Steiner points added are in red.],
  dy: 200pt,
) <fig:cdt_example>

==== Constrained DT (ConsDT)
Given a set $S$ of points and straight-line segments in $bb(R)^(2)$, the ConsDT permits us to decompose the convex hull of $S$ into non-overlapping triangles, and every segment of $S$ appears as an edge in ConsDT($S$). 
ConsDT is similar to the Delaunay triangulation, but the triangles in ConsDT are not necessarily Delaunay (ie their circumcircle might contain other points from $S$). 
The empty circumcircle for a ConsDT is less strict: a triangle is Delaunay if its circumcircle contains no other points in $S$ that are _visible_ from the triangle.
The constrained segments in $S$ act as visibility blockers. 
@fig:cdt_buildings shows one example.
#figure(
  image("./figs/cdtbuildings.pdf", width: 95%),
  caption: [The ConsDT of a set of segments. On the right, the triangle whose circumcircle is green is a Delaunay (no other points in its interior) and so is the triangle whose circumcircle is in purple (there is one point in its interior, but it cannot be seen because of the constrained segment).],
  placement: none,
) <fig:cdt_buildings>

#figure(
  image("./figs/cdt_steps.pdf", width: 95%),
  caption: [Steps to construct a ConsDT.],
  placement: none,
) <fig:cdt_steps>
Without going into details about one potential algorithm, one way to construct a ConsDT($S$) is (see @fig:cdt_steps):
+ construct DT($S^(p)$), where $S^(p)$ is the set containing all the points in $S$ and the end points of the line segments (@fig:cdt_stepsb)
+ insert each line segment, each insertion will remove edges from DT($S^(p)$). In @fig:cdt_stepsc 3 edges are removed.
+ this creates 2 polygons that need to be retriangulated, in @fig:cdt_stepsd there is a blue and a green one.
+ retriangulate each separately, the Delaunay criterion needs to be verified only for the vertices incident to the triangles incident to the hole/polygon.

Observe that the ConsDT can be used to triangulate polygons with holes (see @fig:cdt_dog), it suffices to remove the triangle outside the exterior boundary, but inside the convex hull.

#subfigure(
  figure(image("./figs/cdt_dog.pdf", width: 100%, page: 1), caption: []),
  figure(image("./figs/cdt_dog.pdf", width: 100%, page: 2), caption: []),
  figure(image("./figs/cdt_dog.pdf", width: 100%, page: 3), caption: []),
  columns: (1fr, 1fr, 1fr),
  caption: [#strong[(a)] One polygon with 4 holes (interior rings). #strong[(b)] its ConsDT. #strong[(c)] its ConfDT (the Steiner point added is in red).],
  placement: none,
  label: <fig:cdt_dog>,
)

==== Conforming DT (ConfDT)
A ConfDT adds new points to the input $S$ (called _Steiner_ points) to ensure that the input segments are present in the triangulation.
#index[Steiner point]#note[Steiner point]
As Figures @fig:cdt_example and @fig:cdt_dog show, the input straight-line segments will be potentially split into several collinear segments. 
The Steiner points have to be carefully chosen (where to put them is beyond the scope of this course).

Observe that each triangle in a ConfDT respects the Delaunay criterion, but that more triangles are present. 
If 2 segments are nearly parallel, many points could be necessary (for $m$ segments, up to $m^(2)$ could be necessary).

== Notes and comments <sec:notes>

The DT and the VD have been discovered, rediscovered and studied many times and in many different fields, see #citet(<Okabe00>) for a complete history.
The VD can be traced back to 1644, when Descartes used Voronoi-like structures in Part III of his _Principia Philosophiæ_. 
The VD was used by #citet(<Dirichlet50>) to study quadratic forms---this is why the VD is sometimes referred to as _Dirichlet tessellation_---but was formalised and defined by #citet(<Voronoi08>). 
The first use of the VD in a geographical context is due to #citet(<Thiessen11>), who used it in climatology to better estimate the precipitation average around observations sites; the DT was formalised by #citet(<Delaunay34>). 

For the construction of the DT, the incremental algorithm was first described by #citet(<Lawson72-1>).
#citet(<Fortune87>) describes a sweep-line one, and #citet(<Guibas85>) a divide-and-conquer algorithm.

The local optimality of a DT, which implies globally optimality in the case of the DT, was proven by #citet(<Delaunay34>) himself.
The _max-min angle optimality_ of the DT was firstly observed by #citet(<Sibson78>).
This parabolic lifting was first observed by #citet(<Brown79>) (who used a spherical transformation), further described by #citet(<Seidel82>) and #citet(<Edelsbrunner86>). 

#citet(<Liu05-1>) explains the details of the infinite vertex.

The walking algorithm described in this chapter, with a few modifications, can perform point location in $cal(O) (n^(1/3)$).
However, it is in theory not the fastest solution: #citet(<Mucke99>) and #citet(<Devillers02>) discuss alternatives that are optimal (ie $cal(O) (log n)$).
However, they both note that optimal algorithms do not necessarily mean better results in practice because of the amount of preprocessing involved, the extra storage needed, and also because the optimal algorithms do not always consider the dynamic case, where points in the DT could be deleted. 

Several criteria for constructing data-dependent triangulations are discussed in #citet(<Dyn90>). 
While these can be used, in practice it was proven that the Delaunay triangulation is still the triangulation that minimises the roughness of a surface #citep(<Wang01>)#citep(<Rippa90>)

#citet(<Shewchuk97>) shows that while the triangle-based data structure requires twice as much code as with the quad-edge (to store and construct a ConsDT), the result is that the code runs twice as fast and the memory requirement as about 2X less.
CGAL (#link("https://www.cgal.org/")), among many others, uses the triangle-based data structure.

Since a DT can be locally modified by adding one point (and not reconstructing the whole structure from scratch, see @fig:insertion_deletion), it is also possible to delete/remove one vertex from a DT with only local operations.
#citet(<Mostafavi03>) and #citet(<Devillers09>) describe algorithms.

== Exercises

+ A DT has 32 triangles and we insert a new point $p$ that falls inside one of the triangles. If we insert and update the triangulation (for Delaunay criterion), what is the number of triangles?
+ Given the input formed of elevation points and breaklines below (both projected to the $x y$-plane), draw both the constrained and conforming Delaunay triangulation (an approximation is fine). 
#image("./figs/cdt_exercise.pdf")
+ If a given vertex $v$ in a DT has 7 incident triangles, how many vertices will its dual polygon contain?
+ Identify the 5 infinite triangles in @fig:infinite_vertex.
+ A DT has 6 vertices, and 3 of these are forming the convex hull. How many triangles does the DT have?
+ Assume you have 8 points located on a circle. Draw the DT and the VD of these 8 points.
+ When inserting points in a DT (@algo:insert1pt), what happens if a new point is inserted directly on an edge? Line 2 states that the triangle is split into 3 new triangles, does it still hold?
