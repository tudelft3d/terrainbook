#import "../template.typ": *

= Processing point clouds <chap:pcprocessing>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/gGchA5fluos")

Point clouds are irregularly spaced sample points (to which attributes are attached, see @app:pcformats[Appendix]), that are most often acquired from lidar or obtained from the dense matching of images.
While they are often considered as a suitable terrain representation, as explained in @sec:representation_others, it should be stressed that they are technically not since they are three-dimensional (eg samples can represent vertical walls) and they are not continuous surfaces (there are gaps between the points).

This chapter describes algorithms and techniques to process a point cloud such that it can be used to construct a (2.5D) terrain, or to extract objects that can be used in applications related to the built environment.

== Thinning <sec:thinning>

#index[thinning]

Point clouds can be in practice very large, see @chap:massive for more details and for spatial indexing and some practical solutions.
A point cloud with fewer points is easier to manage and quicker to visualise and process.
Therefore a point cloud is sometimes _thinned_, which simply means that a portion of the points is discarded and not used for processing.
Commonly encountered thinning methods in practice are:
/ random: randomly keep a given percentage of the points, eg 10%.
/ #emph[n]th-point: keep only the $n$th point in the dataset. For instance, if $n=100$, we would keep the 1st, the 101th, the 201th, etc; a dataset with #num(100000) points is reduced to #num(1000) points. This is the quickest thinning method.
/ #emph[n]th-point random: if there is some structure in the input points (eg if generated from a gridded terrain) then #emph[n]th-point could create datasets with artefacts. The randomised variation chooses randomly in the $n$ points one point.
/ grid: overlay a 2D or 3D regular grid over the points and keep $m$ points per grid cell. That can be one of the original points, an average of those, or the exact centre of the cell. The thinning factor depends on the chosen cell-size. Notice that the result is often a point cloud with a homogeneous point density on all surfaces (only on the horizontal surfaces if a 2D grid is used).
See @fig:randvsgrid for a comparison between random thinning and grid thinning.
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("./figs/rand01.png", width: 100%), caption: [random thinning]),
  figure(image("./figs/voxel08m.png", width: 100%), caption: [3D grid thinning]),
  columns: (1fr, 1fr),
  caption: [Comparison of two thinning methods. The thresholds were chosen such that the number of remaining points is approximately the same.],
  placement: none,
  label: <fig:randvsgrid>,
)

From @sec:tin-simpl you undoubtedly remember that TIN simplification has a somewhat similar objective: data reduction. 
However, for a given number of resulting points, TIN simplification yields a higher quality end result because it only removes points that are deemed unimportant.
Thinning methods on the other hand do not consider the 'importance' of a point in any way, and might discard a lot of potentially meaningful details.
So why bother with thinning? The answer is that thinning methods are a lot faster since they do not require something like a computationally expensive triangulation.
Especially in scenarios where the point density is very high and the available time is limited, thinning can be useful.
They are also very useful to test algorithms to get an answer quickly, and then the final processing can be done with all the points.

== Outlier detection <sec:outlier_detection>

Recall from @chap:acquisition that outliers are points that have a large error in their coordinates.
Outliers are typically located far away from the terrain surface and often occur in relatively low densities.
Outlier detection aims to detect and remove outliers and is a common processing step for point clouds.

Most outlier detection methods revolve around analysing the local neighbourhood of a point.
The neighbourhood can be defined using a $k$-nearest neighbour (knn) search (see @sec:kdtree), a fixed radius search, or by superimposing a regular grid on the point cloud and finding the points that are in the same grid-cell.
The points that are determined to be in the neighbourhood of a point of interest $p$ are used to determine whether $p$ is an outlier or not.

#subfigure(
  figure(image("./figs/radius-count.pdf", width: 100%), caption: [radius count]),
  figure(image("./figs/grid-count.pdf", width: 100%), caption: [grid count]),
  figure(image("./figs/knn-distance.pdf", width: 100%), caption: [knn distance ($k=3$)]),
  columns: (1fr, 1fr, 1fr),
  caption: [Three outlier detection methods based on local point density. The red point is an outlier, whereas the blue point is an inlier.],
  placement: none,
  label: <fig:outlier-detection>,
)
The underlying assumption of most outlier detection methods is that an outlier is often an isolated point, ie there are not many points in its neighbourhood. We distinguish the following outlier detection methods (see also @fig:outlier-detection):
/ radius count: Count the number of points that are within a fixed radius from $p$ (a sphere in 3D). If the count is lower than a given threshold, $p$ is marked as an outlier.
/ grid count: Superimpose a grid on the point cloud and count for each grid-cell the number of points. If the count is lower than a given threshold, the points inside the corresponding grid cell are marked as outliers. Sometimes the neighbourhood is extended with adjacent grid cells. The grid method has the advantage that it can be used with the spatial streaming paradigm (see @sec:streaming).
/ knn distance: Find the $k$ nearest neighbours of $p$, eg using a $k$d-tree, and compute the mean or median of the distances between $p$ and its neighbours. If this value is above a given threshold, $p$ is marked as an outlier.

These methods generally work well if the outliers are isolated.
However, in some cases this assumption does not hold.
For example in case of a point cloud derived from multi-beam echo sounding (see @sec:mbes), a common issue is the occurrence of (shoals of) fish. 
These fish cause large groups of points that are clustered closely together above the seafloor.
These are not isolated points since each outlier will have plenty of other points nearby.
A possible solution is to construct a TIN of all points and to remove the relatively long edges that connect the outlier clusters to the seafloor.
This splits the TIN into several smaller TINs, and the largest of those should then be the seafloor surface without the outliers. 
@fig:mbes gives an example.
#subfigure(
  figure(image("./figs/mbes_cleaning_before.png", width: 100%), caption: [before outlier detection]),
  figure(image("./figs/mbes_cleaning_after.png", width: 100%), caption: [after outlier detection]),
  columns: (1fr, 1fr),
  caption: [Outlier detection in a multi-beam echo sounding dataset using a TIN. Figure from #citep(<Arge10>).],
  placement: none,
  label: <fig:mbes>,
)

== Ground filtering

Ground filtering involves classifying the points of a point cloud into ground points and non-ground points.
As shown in @fig:filter-profile, ground points are those points that are part of the bare-earth surface of the Earth, thus excluding vegetation and man-made structures such as buildings, statues, and cars.
The ground points can then be used to generate a DTM, usually as a TIN or a raster.
Or, the non-ground points can be used as input for another classifier, eg to classify buildings and vegetation possibly using a region growing algorithm (see @sec:regiongrowing).
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("./figs/filter-profile-before.png", width: 100%), caption: [Original point cloud]),
  figure(image("./figs/filter-profile-after.png", width: 100%), caption: [After ground filtering]),
  columns: (1fr),
  caption: [Profile of the point cloud of an area.],
  placement: auto,
  label: <fig:filter-profile>,
)

Ground filtering methods are typically based on the assumptions that 
+ the ground is a continuous surface without sudden elevation jumps,
+ for a given 2D neighbourhood, the ground points are the ones with the lowest elevation.
Notice that outliers (especially those under the ground surface) may break these assumptions and in some cases it may be necessary to first run an outlier removal algorithm such as one from @sec:outlier_detection.

Notice that the resulting bare-earth model may thus have holes where these non-ground objects used to be.
If needed, these holes can be filled in a subsequent processing step with for example spatial interpolation.

=== Ground filtering with progressive TIN densification

#index[ground filtering]

We describe in this section an effective ground filtering method that is widely used in practice since it has been integrated into different commercial software.
It should be observed that there are several variations of this algorithm; we describe only one of these in the following.

The main idea of the method is to first construct an initial TIN based on (known) ground points, and then densify this TIN by iteratively adding points that fulfil certain criteria.
The method uses the same algorithmic paradigm as the iterative TIN refinement from @sec:tin-simpl.

The algorithm starts by constructing a rudimentary initial TIN, usually based on the Delaunay triangulation. 
The TIN is constructed from a number of points that have locally the lowest elevation and are spread somewhat evenly over the data extent.
These points are found by superimposing a 2D grid over the data extent and selecting the lowest point for each grid cell (similar to grid thinning).
The cellsize of the grid should be chosen such that it is larger than the largest non-ground object (usually a building).
Thus, if the largest building has a footprint of 100mX100m, the cellsize should be a bit larger, eg #qty("110", "m"), so that it is guaranteed that each grid-cell has at least a few ground points.

The densification step of the algorithm is an iterative process where the points that fulfil the two 'ground filter' criteria below are inserted---one-by-one---into the TIN (and the triangulation is updated).
Observe that if a given point is not labelled as ground when first visited, it is possible that later it will be (because other points have been inserted and the geometric configuration has changed).
Therefore, the densification process continues until all remaining points fail the ground test.

#notefigure(
  image("./figs/gftin.pdf", width: 80%),
  caption: [The two ground filter criteria: $d$ and $alpha$.],
) <fig:gftin>

#notefigure(
  image("./figs/gftin_projection.pdf", width: 100%),
  caption: [Profile view of a TIN with the vertical projections (pink) and the closest distances to the plane (green) shown for 3 different points. Notice that it is possible that the closest projection falls outside the triangle, as shown for the point on the right.],
) <fig:gftin_projection>

As illustrated in @fig:gftin, the two criteria are based on the relation between the point $p$ and the triangle $tau$ in the current TIN that intersects its vertical projection:
/ Distance $d$ between $p$ and the plane spanning $tau$: Notice that it is the perpendicular distance between $p$ and the plane spanned by $tau$, and not the vertical distance (see @fig:gftin_projection).
/ Max angle $alpha$ to the vertices of $tau$: It is the largest angle of the angles between $tau$ and the three vectors that connect each vertex of $tau$ to $p$.

Two thresholds must be used for the algorithm ($d_(max )$ and $alpha _(max )$); if a point $p$ is under these two thresholds, then it is labelled as a ground point and is inserted in the TIN.

Observe that the algorithm is _greedy_, which means that it never "goes back" on operations that were previously performed, and thus when a point $p$ is inserted in the TIN, it is never removed.

=== Cloth simulation filter (CSF) algorithm

An alternative to TIN refinement is the algorithm called _cloth simulation filter_ (CSF).
Unlike the previous one, no TIN is required, its input is only a point cloud.
The main observation necessary for this algorithm is that lower points are usually forming the ground (again it is assumed no outliers appear below the ground in the dataset).

#figure(
  image("./figs/csf_idea.pdf", width: 100%),
  caption: [Basic idea behind the CSF algorithm for ground filtering of a point cloud: inverting the data and letting a cloth fall.],
  placement: none,
) <fig:csf_idea>
The key idea of the algorithm, as shown in @fig:csf_idea, is to invert (upside-down) a point cloud, and to let a piece of cloth fall from the sky.
The cloth will fall until it reaches the points forming the ground.
During the process, we aim to control the _tension_ (or rigidity) of the cloth, so that areas where there is no sample point (eg where there are large buildings or water) can be filled realistically.

The CSF algorithm is a simplification of an algorithm in computer graphics to simulate a piece of cloth falling on an object.
The cloth is modelled as a surface formed of _particles_ (vertices) that are regularly distributed on a grid, these particles have a mass and they are connected to their neighbours (4-neighbours in this case).
For terrains (2.5D objects), the particles are constrained to only move vertically.

Two factors influence the $z$-value of a particle during the cloth falling process:
/ external forces: in this case this is the gravity pulling down a particle;
/ internal forces: the tension in the cloth, which is modelled by the interactions between a particle and its neighbours.
As particles fall down, some will reach the ground and become _unmovable_.
These will potentially be neighbours to _movable_ ones, whose elevation will be controlled by how we define the rigidity of the cloth.

#notefigure(
  image("./figs/csf_iterations.pdf", width: 100%),
  caption: [First four iterations of the CSF algorithm for ground filtering of a point cloud.],
) <fig:csf_iterations>
As shown in @fig:csf_iterations, the process is iterative. 
We first define a cloth formed of particles ($t_0$), and then for each iteration we calculate the next $z$-value of each particle based on the vector of displacement from the external and internal forces at the previous step.
If a particle is movable (ie it has not reached the ground yet), then the gravity force is applied (a vector pointing downwards; its magnitude will depend on the momentum of the particle) and afterwards the internal forces are applied.
Notice that in @fig:csf_iterations, the particle in red at $t_3$ was moved downwards because of the gravity, but its internal forces are a vector pointing upwards since its 2 neighbours (it would be 4 for a 2D case) have higher $z$-values.

The algorithm is detailed in Algorithm @algo:csf.

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [CSF algorithm.],
  pseudocode-list[
    + *Input:* A set $S$ of sample points from a point cloud; resolution $r$ of the cloth grid; tolerance $epsilon_"zmax"$ to stop the iterations; tolerance $epsilon_"ground"$ to classify points in $S$
    + *Output:* The points in $S$ are classified as ground/non-ground
    + invert $S$
    + initialise the cloth $C$ at an elevation $z_0$ higher than the highest elevation
    + *for* each point $p$ in $C$ *do*
      + $p_"zmin" =$ lowest possible elevation based on $S$ #line-label(<algo:csf:l:zmin>)
      + $p_"zprev" = z_0 + "displacement"$ #line-label(<algo:csf:l:init_prev>)
      + $p_"zcur" = z_0$
    + *while* $Delta  z > epsilon_"zmax"$ *do*
      + \// _external forces_
      + *for* each point $p$ in $C$ *do*
        + *if* $p$ is movable *then*
          + $"tmp" = p_"zcur"$
          + $p_"zcur" = (p_"zcur" - p_"zprev") + p_"zcur"$
          + $p_"zprev" = "tmp"$
      + \// _internal forces, process once each pair $e$ of adjacent particles_
      + *for* each $e$ in $C$ *do*
        + $p 0 = e_"start"$ 
        + $p 1 = e_"end"$ 
        + update $p 0_"zcur"$ and $p 1_"zcur"$ if they are movable 
      + \// _calculate the max $Delta z$_
      + *for* each $p$ in $C$ *do*
        + *if* $(p_"zcur" - p_"zprev") > Delta z$ *then*
          + $Delta z = p_"zcur" - p_"zprev"$
  ]
) <algo:csf>



==== Initialisation of the cloth
The cloth is first initialised at an arbitrary height above the highest points in the point cloud.
The cloth is formed of particles regularly distributed according to a user-defined parameter.
We assume that all particles have the same mass, and we define arbitrarily a first displacement vector due to the gravity (pointing downwards) (@algo:csf:l:init_prev).
For each particle $p$, we need to define the lowest elevation it can move, once it reaches it it is labelled as unmovable (@algo:csf:l:zmin).
The lowest elevation of one particle $p$ is defined as the original elevation of the closest sample point $s$ after projecting both to the 2D-plane.

==== Internal forces
The internal forces are applied only to movable particles; once a particle has been labelled as unmovable it cannot be moved again.
Given a movable particle $p$, we apply the internal forces by individually looking at its 4 neighbours $n_i$.
For each neighbour $n_i$, there are two cases (see @fig:csf_2cases):
#notefigure(
  image("./figs/csf_2cases.pdf", width: 80%),
  caption: [Internal forces in the CSF algorithm: 2 cases are possible.],
) <fig:csf_2cases>
/ $n_i$ is unmovable: only $p$ is moved, towards $n_i$.
/ $n_i$ is movable: the idea is that both $p$ and $n_i$ will try to move towards each other to the same height. The vector applied to each will thus be in opposite direction.


==== Controlling the tension/rigidity
Notice that in @fig:csf_2cases\b, both particles are moved to the same elevation, but that it is also possible to scale the internal forces displacement vector, eg to 0.8 of its length (and thus decrease the tension in the cloth). Lower internal force displacement means that the particles will move more during a single iteration and so the tension in the cloth is effectively reduced. 
The same idea applies to @fig:csf_2cases\a, the displacement vector can be controlled by scaling the displacement vector. 
In @fig:csf_2cases\a, it is 0.5 of the difference in elevation, but if less tension is wanted, then the scale could be for instance 0.4 (so that $p$ has an internal displacement $arrow(v) =(0, 0, 3.2)$, because $0.4 \* (10-2) = 3.2$) or 0.3.

==== How the process ends
This iterative process is repeated until the maximum displacement of all particles is less than a user-defined parameters ($epsilon_"zmax"$); or until a certain number of iterations has been performed.

==== Two possible outputs
When the process is completed, the surface of the cloth can be used to obtain two outputs (see @fig:csf-example):
+ classification of points into ground/non-ground
+ a surface representing the ground (the cloth)
If the surface of the cloth is used, it is for instance possible to triangle it or to create a grid from it.
If a segmentation/classification of the input points is wanted, then the distance between a sample point of the original point cloud and the cloth can be used (this is the parameter $epsilon_"ground"$ in @algo:csf).
If this distance is less than a given user-defined threshold, then the sample point is a ground point.
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("./figs/csf_before.png", width: 100%), caption: [Original point cloud]),
  figure(image("./figs/csf_onlyground.png", width: 100%), caption: [Output \#1: the ground points (with the ground surface shown in grey)]),
  figure(image("./figs/csf_after.png", width: 100%), caption: [Output \#2: the ground surface]),
  columns: (1fr),
  caption: [Two outputs of the CSF algorithm for a given area.],
  placement: auto,
  label: <fig:csf-example>,
)

#box-practice("CSF is implemented in several open-source libraries")[
  The description of the CSF algorithm in this book is a simplification of the original algorithm (see #citet(<Zhang16>)), it omits the post-processing to take into account steep slopes.
  \ \
  The complete algorithm is implemented in the open-source software _CloudCompare_ (#link("https://cloudcompare.org")) and in the open-source library _PDAL_ (#link("https://pdal.io")).
]

== Shape detection <sec:shape-detection>

#index[shape detection]

#figure(
  image("./figs/bk-planes.png", width: 100%),
  caption: [Planar regions in the AHN3 point cloud. Each region was assigned a random colour.],
  placement: none,
) <fig:bk-planes>

Shape detection is used to automatically detect simple shapes---such as planes---in a point cloud.
See for example @fig:bk-planes where the points are randomly coloured according to the corresponding planar surfaces.
Shape detection is an important step in the extraction and reconstruction of more complex objects, eg man-made structures such as buildings are often composed of planar surfaces.

In this section, three shape detection methods will be introduced: 
+ RANSAC
+ Region growing
+ Hough transform

First, some common terminology.
Let $P$ denote a point cloud, if we perform shape detection on $P$ we aim to find a subset of points $S subset P$ that fit with a particular shape. 
Most shape detection methods focus on shapes that can be easily parametrised, such as a line, a plane, or a sphere. 
If we specify values for the parameters of such a parametrised shape, we define an _instance_ of that shape.
For example, a line in the plane can be parametrised using the equation $y = m x + b$, in this case $m$ and $b$ are the parameters.
We can create an instance of a line by specifying values for its parameters $m$ and $b$, respectively fixing the slope and the position of the line.

In the following, the methods are described in a general way, ie without specialisations for one particular shape.
#note[spheres, cones, cylinders, planes, etc. can be detected]
Only for illustrative purposes specific shapes such as a line or a plane are used to (visually) explain the basic concept of each shape detection method, but the same could be done with spheres, cones, or other shapes.

=== RANSAC

#index[RANSAC]

RANSAC is short for _RANdom SAmpling Consensus_ and, as its name implies, works by randomly sampling the input points.
In fact it starts by picking a random set of points $M subset P$. 
This set $M$ is called the _minimal set_#note[minimal set] and contains exactly the minimum number of points that is needed to uniquely construct the shape that we are looking for, eg 2 for a line and 3 for a plane. 
From the minimal set $M$ the (unique) shape instance $cal(I)$ is constructed (see Figures @fig:ransac:b and @fig:ransac:c).
#subfigure(
  figure(image("./figs/ransac.pdf", width: 100%, page: 1), caption: [Input points]), <fig:ransac:a>,
  figure(image("./figs/ransac.pdf", width: 100%, page: 2), caption: [1st minimal set]), <fig:ransac:b>,
  figure(image("./figs/ransac.pdf", width: 100%, page: 3), caption: [2nd minimal set]), <fig:ransac:c>,
  figure(image("./figs/ransac.pdf", width: 100%, page: 4), caption: [Detected line instance]), <fig:ransac:d>,
  columns: (1fr, 1fr, 1fr, 1fr),
  caption: [RANSAC for line detection ($k=2$ iterations)],
  placement: auto,
  label: <fig:ransac>,
)

The algorithm then checks for each point $p in {P without M}$ if it fits with $cal(I)$. 
This is usually done by computing the distance $d$ from $p$ to $cal(I)$ and comparing $d$ against a user-defined threshold $epsilon$.
If $d < epsilon$ we say that $p$ is an _inlier_#index[inliers]#note[inlier], otherwise $p$ is an _outlier_.
The complete set of inliers is called the _consensus set_#note[consensus set], and its size is referred to as the _score_#note[score].
The whole process from picking a minimal set to computing the consensus set and its score, as shown in @algo:ransac, is repeated a fixed number of times, after which the shape instance with the highest score is outputted (@fig:ransac:d). 

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [RANSAC algorithm.],
  pseudocode-list[
    + *Input:* An input point cloud $P$, the error threshold $epsilon$, the minimal number of points needed to uniquely construct the shape of interest $n$, and the number of iterations $k$
    + *Output:* the detected shape instance $cal(I)_"best"$
    + $s_"best" <- 0$
    + $cal(I)_"best" <-$ nil
    + *for* $i$ in $[1..k]$ *do*
      + $M <- n$ randomly selected points from $P$
      + $cal(I) <-$ shape instance constructed from $M$
      + $C <- emptyset$ 
      + *for* each $p in P without M$ *do*
        + $d <- "distance" (p, cal(I))$
        + *if* $d < epsilon$ *then*
          + add $p$ to $C$
      + $s <- "score" (C)$
      + *if* $s > s_"best"$ *then*
        + $s_"best" <- s$
        + $cal(I)_"best" <- cal(I)$
  ]
) <algo:ransac>

The most touted benefit of RANSAC is its robustness, ie its performance in the presence of many outliers (up to 50%).
Other algorithms to identify planes, eg fitting a plane with least-square adjustment, are usually more sensitive to the presence of noise and outliers (which are always present in real-world datasets).
The probability that a shape instance is detected with RANSAC depends mainly on two criteria:
+ the number of inliers in $P$, and
+ the number of iterations $k$.
Naturally, it will be easier to detect a shape instance in a dataset with a relatively low number of outliers.
And it is more likely that a shape instance is found if more minimal sets are evaluated.
Picking a sufficiently high $k$ is therefore important for the success of the algorithm, although a higher $k$ also increases the computation time.

Because of the random nature of RANSAC, the minimal sets that it will evaluate will be different every time you run the algorithm, even if the input data is the same.
The detected shape instance can therefore also be different every time you run the algorithm; RANSAC is therefore said to be a _non-deterministic_ algorithm.
This could be a disadvantage.

==== Time complexity
The time complexity of RANSAC is $cal(O) (k n)$, where $n$ is the size of $P$.


=== Region growing <sec:regiongrowing>

#index[region growing]
Region growing works by gradually growing sets of points called _regions_ that fit a particular shape instance.
A region $R$ starts from a _seed point_#index[seed point]#note[seed point], ie a point that is suspected to fit a shape instance.
More points are added to $R$ by inspecting _candidate points_, ie points in the neighbourhood of the members of $R$.
To check if a candidate point $c$ should be added to $R$, a test is performed.
In the case of region growing for plane detection (see @fig:region-growing) this test entails computing the angle between the normal vector of $c$ and the normal vector #note[see @app:normalplane[Appendix] to estimate the normal in a point cloud] of its neighbour in $R$.
If this angle is small it is assumed that $c$ lies in the plane instance that corresponds to $R$, and that it can therefore be added to $R$.
Otherwise $c$ is ignored (@fig:region-growing:d).
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("./figs/region-growing.pdf", width: 100%, page: 1), caption: [Input points with normals and three seed points]), <fig:region-growing:a>,
  figure(image("./figs/region-growing.pdf", width: 100%, page: 2), caption: [Start growing. Add neighbours if the normal angle is small]), <fig:region-growing:b>,
  figure(image("./figs/region-growing.pdf", width: 100%, page: 3), caption: [Continue growing from new region \ point]), <fig:region-growing:c>,
  figure(image("./figs/region-growing.pdf", width: 100%, page: 4), caption: [Stop growing where the normal angle is too large]), <fig:region-growing:d>,
  figure(image("./figs/region-growing.pdf", width: 100%, page: 5), caption: [Final regions from all three seed points]), <fig:region-growing:e>,
  columns: (1fr, 1fr),
  caption: [Region growing for plane detection based on the angle between neighbouring point normals],
  placement: none,
  label: <fig:region-growing>,
)
This process of growing $R$ continues until no more candidates can be found that are compatible with $R$.
When this happens, the algorithm proceeds to the next seed point to grow a new region.

@algo:region-growing gives the pseudo-code for the region growing algorithm.
Notice that the set $S$ is used to keep track of the points in the current region whose neighbours still need to be checked.
Also notice that candidate points that are already assigned to a region are skipped.

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Region growing algorithm.],
  pseudocode-list[
    + *Input:* An input point cloud $P$, a list of seed points $L_S$, a function to find the neighbours of a point _neighbours()_
    + *Output:* A list with detected regions $L_R$
    + $L_R <- []$
    + *for* each $s$ in $L_S$ *do*
      + $S <- {s}$ 
      + $R <- emptyset$
      + *while* $S$ is not empty *do*
        + $p <- "pop"(S)$
        + *for* each candidate point $c in "neighbours"(p)$
          + *if* $c$ was not previously assigned to any region *then*
            + *if* $c$ fits with $R$ *then*
              + add $c$ to $S$
              + add $c$ to $R$
    + append $R$ to $L_R$
  ]
) <algo:region-growing>

The seed points can be generated by assessing the local neighbourhood of each input point. 
For example in case of plane detection one could fit a plane through each point neighbourhood and subsequently sort all points on the fitting error. 
Points with a low plane fitting error are probably part of a planar region so we can expect them to be good seeds.

To compute the point neighbourhoods a $k$-nearest neighbour search or a fixed radius search can be used, which can both be implemented efficiently using a $k$d-tree (see @sec:kdtree).
Notice that region growing is based on the idea that we can always find a path of neighbouring points between any pair of points within the same region.
This does mean that two groups of points that fit the same shape instance but are not connected through point neighbourhoods will end up in different regions.
Other shape detection methods described in this chapter do not need point neighbourhood information.

==== Time complexity
If we assume that
+ the number of seeds in $L_S$ is linear with $n$, ie the size of $P$,
+ the size of $S$ is at most $n$, and that
+ a $k$nn search takes $cal(O) (k log n)$, where $k$ is the number of neighbours,
we come to a worst-case time complexity of $cal(O) (n^(2) k log n)$.
In practice it should be better since $S$ is not likely to be $n$ large, and it will get smaller the more regions have been found.


=== Hough transform

#index[Hough transform]

The Hough transform uses a voting mechanism to detect shapes.
It lets every point $p in P$ vote on each shape instance that could possibly contain $p$.
Possible shape instances thus accumulate votes from the input points.
The detected shape instances are the ones that receive the highest number of votes.
To find the possible shape instances for $p$, the algorithm simply checks all possible parameter combinations that give a shape instance that fits with $p$.

It is thus important to choose a good parametrisation of the shape that is to be detected.
For instance when detecting lines one could use the slope-intercept form, ie $y = m x+b$.
However, this particular parametrisation can not easily represent vertical lines, because $m$ would need to become infinite which is computationally difficult to manage. 
A better line parametrisation is the Hesse normal form#index[Hesse normal form]#note[Hesse normal form] which is defined as 
$  r = x cos phi.alt + y sin phi.alt  $
As illustrated in @fig:hough-transform:a, $(r,phi.alt )$ are the polar coordinates of the point on the line that is closest to the origin, ie $r$ is the distance from the origin to the closest point on the line, and $phi.alt in 0^(degree ), 180^(degree )$ is the angle between the positive $x$-axis and the line from the origin to that closest point on the line. 
This parametrisation has no problems with vertical lines (ie $phi.alt =90^(degree )$).
Similarly, for plane detection we can use the parametrisation
$ r = x cos theta sin phi.alt + y sin phi.alt sin theta + z cos phi.alt $
Where $(r, theta , phi.alt )$ are the spherical coordinates of the point on the plane that is closest to the origin.

@fig:hough-transform shows an example for line detection with the Hough transform and Algorithm @algo:hough-transform gives the full pseudo-code.

#wideblock[
#subfigure(
  figure(image("./figs/hough-transform.pdf", width: 100%, page: 1), caption: [Line parametrisation]), <fig:hough-transform:a>,
  figure(image("./figs/hough-transform.pdf", width: 100%, page: 2), caption: [Input points]), <fig:hough-transform:b>,
  figure(image("./figs/hough-transform.pdf", width: 100%, page: 3), caption: [Line instances for each point]), <fig:hough-transform:c>,
  figure(image("./figs/hough-transform_accumulator.pdf", width: 70%), caption: [Accumulator contains the number of votes for each line instance.]), <fig:hough-transform:d>,
  figure(image("./figs/hough-transform.pdf", width: 100%, page: 4), caption: [Detected line instances with a minimal vote count of 3.]), <fig:hough-transform:e>,
  columns: (1fr, 1fr, 1fr),
  caption: [Hough transform for line detection with a $10times 2$ accumulator. The $(phi.alt, r)$ line parametrisation is chosen because this form can represent vertical lines (unlike the $y = m x + b$ form for example).],
  placement: none,
  label: <fig:hough-transform>,
)
]

#figure(
  kind: "algorithm",
  supplement: [Algorithm],
  caption: [Hough transform algorithm.],
  pseudocode-list[
    + *Input:* An input point cloud $P$, an accumulator matrix $A$, a detection threshold $alpha$
    + *Output:* A list with detected shape instances $L_I$
    + *for* each $p in P$ *do*
      + *for* each instance $i$ from $A$ that fits with $p$ *do*
        + increment $A[i]$
    + $L_I <-$ all shape instances from $A$ with a more than $alpha$ votes
  ]
) <algo:hough-transform>

The votes are saved in an _accumulator_#note[accumulator], which is essentially a matrix with an axis for each parameter of the shape, eg for detecting lines we would need two axes (See @fig:hough-transform:d).
Notice that each element in the accumulator represents one possible shape instance.
Because each axis only has a limited number of elements, each parameter is _quantised_#index[quantisation]#note[quantisation].
This means that each parameter is restricted in the possible values it can have.
The chosen quantisation determines the sensitivity of the accumulator.
The accumulator of @fig:hough-transform:d for example, can only detect horizontal and vertical lines, because the $phi.alt$ parameter is quantised in only two possible values.
Notice that the accumulator can be made more sensitive by choosing a finer quantisation, effectively increasing the size of the accumulator (although that will also make the algorithm run slower).

==== Time complexity
The time complexity of the Hough transform algorithm as discussed here is $cal(O) (n m)$, where $m$ is the number of elements in the accumulator.

== Notes and comments

#citet(<Arge10>) introduced the outlier detection method for echo-sounding datasets by cutting long edges in a TIN.

#citet(<Axelsson00>) originally proposed the greedy TIN densification algorithm for ground filtering.
He also describes how to handle discontinuities in the terrain such as cliffs.
It should be said that his paper is scarce on details, and many variations of the algorithms have been proposed so that small/low objects are filtered out and so that it performs well in densely forested areas.
See for instance #citet(<Lin14>). 

The cloth simulation filter (CSF) algorithm is from #citet(<Zhang16>).
The original paper has a somewhat complex definition that has been simplified and modified for this book.
Also, the original has a post-processing step for steep slope that is omitted in this book.

A comparison with several other ground filtering methods can be found in the work of #citet(<Meng10>).
#citet(<Fischler81>) originally introduced the RANSAC algorithm and applied to cartography in that same paper. On Wikipedia you can read how you can compute the required number of RANSAC iterations to achieve a certain probability of success given that you know how many outliers there are in your dataset (#link("https://en.wikipedia.org/wiki/Random_sample_consensus#Parameters")).

#citet(<Limberger15>) describes how to efficiently do plane detection in large point clouds using a variant of the Hough transform.

== Exercises

+ The LAS standard gives a global point offset in the header. What is the benefit of using such a global offset?
+ What is the difference between thinning a point cloud prior to triangulation and TIN simplification?
+ What is the probability that the line instance in @fig:ransac:d is detected with $k=2$ iterations?
+ In @chap:acquisition it is described how point density can vary based on the acquisition conditions. How could a (strongly) varying point density affect the effectiveness of the region growing algorithm?
+ How many axes would an accumulator need for plane detection with the Hough transform?
