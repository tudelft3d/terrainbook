#import "../template.typ": *

= Handling and processing massive terrains <chap:massive>

#minitoc(suboutline(depth: 1, indent: 0pt))

In this chapter we discuss three methods to handle and/or process _massive_ terrains and point cloud datasets.

"Massive" is a vague and undefined term in GIS, and it is continuously changing: 15 years ago a point cloud dataset containing 5 million elevation points was considered massive, but in 2024 it is considered a small one.
#index[massive datasets]
Examples of massive datasets: 
+ the point cloud dataset of a $qty("1.5", "km^2")$ of Dublin #note(link("https://bit.ly/32GXiFq")) contains around 1.4 billion points (density of $num("300")$ pts/$m^2$), which was collected with airborne laser scanners; //TODO m^2
+ the lidar dataset of the whole of the Netherlands (AHN #note(link("https://www.ahn.nl/"))) has about $num("10")$ pts/$m^2$ and its latest version (AHN6) has more than 900 billion points;
+ the global digital surface model _ALOS World 3D---30m (AW3D30)_ #note(link("https://www.eorc.jaxa.jp/ALOS/en/dataset/aw3d30/aw3d30_e.htm")) is a raster dataset with a resolution of #qty(1, "arcsecond"), therefore we have about #num("8.4e11") pixels.


We define as "massive" a dataset that does not fit into the main memory of a standard computer, which is usually around 24GB these days.
This definition makes practical sense because working with data outside of the main memory of a computer is substantially slower (about 2 orders of magnitude for solid state drives and 5 for spinning hard drives), causing many standard data processing algorithms to become impractical with massive datasets.
Keep in mind that not only the $x y z$ coordinates of the points of a point cloud need to be stored, but also often attributes for each point (LAS has several standard ones, see @tab:las-record).
In the case of TINs, the geometry of the triangles---and potentially the topological relationships between them---need to be explicitly stored.

What is ironic is that while datasets like those above are being collected in several countries, in practice they are seldom used directly since the tools that practitioners have, and are used to, usually cannot handle such massive datasets. 
Instead of the raw point clouds, gridded terrains are often derived (for example with a #qty("50", "cm") resolution), because those are easier to process with a personal computer.
Indeed, the traditional GISs and terrain modelling tools are limited by the main memory of computers: if a dataset is bigger then operations will be very slow, and will most likely not finish (or even crash).

This chapter discusses one method to visualise and potentially analyse massive raster terrains, one to index point clouds (for fast retrieval of neighbours, useful for several processing of points), and one to construct massive Delaunay triangulations (and potentially process them).

== Raster pyramids

#index[raster pyramid]

Raster pyramids are a well-known, standardised, and widely used mechanism to deal with large raster terrains.
They are also used for standard images in photography and many software programmes support them since they optimise visualisation and thus the speed of a software dealing with large images (they are called "tiled pyramidal images" or "overview images").

#subfigure(
  figure(image("figs/pyramids.pdf", width: 100%), caption: []),
  figure(image("figs/pyramids2.pdf", width: 33%), caption: []),
  columns: (1fr, 1fr),
  caption: [#strong[(a)] The pyramid for a given raster file. #strong[(b)] One $4 times 4$ raster downsampled twice with average-method.],
  placement: top,
  label: <fig:pyramids>,
)
As shown in @fig:pyramids, a pyramid means creating recursively copies at lower-resolutions of an original raster.
Usually we downsample the resolution by a factor 2,
#index[downsampling]#note[downsampling]
ie if we have $x$ columns and $y$ rows the first copy will have a size ($x/2$, $y/2$), the second ($x/4$, $y/4$), and so on (the number of images is arbitrary and defined by the user).
Notice that the extra storage will be maximum about $1/3$ of the original raster: the first pyramid is $1/4$, the second $1/16$, the third $1/64$, etc.

For downsampling, the most common method is based on averaging the 4 pixel values that are merged into one (as shown in @fig:pyramids\b), but other interpolation methods are possible, eg nearest neighbour as seen in @chap:interpol.

The downsamples grids are used to speed up visualisation (when a user zooms out on a lower-resolution grid is displayed) but the same principle could be applied for processing (eg the line-of-sight between 2 points in @chap:visibility could be sped up by using this principle).

#box-practice("How does it work in practice?")[
  For certain GIS formats, eg GeoTIFF, the lower-resolutions rasters can be stored directly in the same file as the original raster, and this is standardised.
  \ 
  For other formats, if the GDAL library is used (the _de facto_ open-source library for GIS images and grids), the pyramids can be stored in an auxiliary file with the extension `.ovr`, which is actually a TIFF format.
  \ 
  The GDAL utility \href{https://www.gdal.org/gdaladdo.html}{gdaladdo \faExternalLink} can create automatically the pyramids for a few formats, and the downsampling method can be chosen.
  In QGIS, one can use `gdaladdo`, or there is also a built-in mechanism, as can be seen in @fig:qgis
]

#figure(
  image("figs/qgis.png", width: 100%),
  caption: [QGIS has the option to create the pyramids automatically.],
  placement: none,
) <fig:qgis>

== #flex-heading[kd-tree][Indexing points in 3D space with the kd-tree] <sec:kdtree>

#index[kd-tree]

#notefigure(
  image("figs/kdtree.pdf", width: 100%),
  caption: [Example of $k$d-tree in 3D, with the dimension used at each level.],
) <fig:kdtree>

A $k$-dimensional tree, $k$d-tree in short, is a data structure to organise points in a $k$-dimensional space; it also partitions the space into regions.
In the context of terrains, $k$ is in most cases either 2 or 3.
Notice that in practice we would never say a "2d-tree" or a "3d-tree": we call them "$k$d-tree of dimension 2 (or 3)".

As shown in @fig:kdtree, a $k$d-tree is a binary tree
#index[binary tree]#note[binary tree]
(thus each node has a maximum of 2 children, if any), and the main idea is that each level of the tree compares against one specific dimension.
We "cycle through" the dimensions as we walk down the levels of the tree.

Let $S$ be a set of points in $bb(R)^(k)$, and let $Gamma$ be the $k$d-tree of dimension $k$ of $S$.
Each point $p_i$ in $S$ is a node of $Gamma$.
#index[hyperplane]#note[hyperplane]
A node implies a hyperplane that divides the space into 2 halfspaces according to one dimension; the hyperplane is perpendicular to the dimension of the node (which is linked to the level in the tree).
Points with a lower coordinate value than the node along that dimension (corresponding to 'left', in 2D, or 'under' the hyperplane) are put into the left subtree of the node, and the other ones into the right subtree.

#figure(
  image("figs/kdtree2.pdf", width: 90%),
  caption: [Example of $k$d-tree for 8 points in the $bb(R)^(2)$.],
  placement: none,
) <fig:kdtree2>

Consider the $k$d-tree in 2D in @fig:kdtree2.
The first dimension splits the data into 2 halfplanes along the line $x=5$, then each of these halfplanes is independently split according to the $y$ dimension (with the lines $y=7$ and $y=5$), then the 4 regions are split according to the $x$ dimension, and so on recursively until all the points in $S$ are inserted in $Gamma$.

==== Construction of a kd-tree
In theory, any point could be used to divide the space according to each dimension, and that would yield a valid $k$d-tree.
However, selecting the _median_ point creates a _balanced_ binary tree,
#note[selecting the median creates a balanced tree] 
which is desirable because it will improve searching and visiting the tree (see below).
The tree in @fig:kdtree2 is balanced, but if for instance ($1,3$) had been selected as the root, then there would be no children on the left, and all of them would be on the right.

The median point is the one whose value for the splitting dimension is the median of all the points involved in the operation.
This implies that to construct the $k$d-tree of a set $S$ of $n$ points, as a first step $n$ values need to be sorted, which is a rather slow operation ($cal(O) (n log n)$).
In practice, most software libraries will not sort $n$ values, but rather sample randomly a subset of them (say 1\
While this does not guarantee a balanced tree, in practice the tree should be close to balanced.

The tree is built incrementally, ie points are added in the tree one after the other, and after each insertion the tree is updated.
Each insertion is simple: traverse the tree starting from the root, go left or right depending on the splitting dimension value, and insert the new point as a new leaf in the tree.
@fig:kdtree_insert illustrates this for one point.
Observe that this insertion renders the tree unbalanced.
Methods to balance a $k$d-tree exists but are out of scope for this book.
#figure(
  image("figs/kdtree_insert.pdf", width: 90%),
  caption: [Insertion of a new point ($7,3$) in a $k$d-tree.],
  placement: none,
) <fig:kdtree_insert> 

==== Nearest neighbour query in kd-trees <sec:knn>
The nearest neighbour query aims to find the point $c$ in a set $S$ that is the nearest (according to the Euclidean distance) to a query point $q$.
#index[nearest neighbour query]#note[nearest neighbour query]
It can be performed brute-force (computing all the distances to all the points in $S$ and choosing the shortest), but this is very slow in practice.
An alternative is to construct the Voronoi diagram (or the Delaunay triangulation), and navigate in the cells or in the triangles with the method from @sec:dtwalk.
While this works, in practice it is not as efficient as using a $k$d-tree.

First observe that the obvious method to find the cell in the $k$d-tree containing $q$---follow the insertion steps as described above and look for the parents---does not work because $q$ can be far away in the tree.
@fig:kdtree_nn\a illustrates this: $c$ (the nearest neighbour to $q$) is ($6,4$) but is located in the right subtree of the root, while $q$ is in the left subtree.
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("figs/kdtree_nn.pdf", width: 100%, page: 2), caption: []),
  figure(image("figs/kdtree_nn.pdf", width: 100%, page: 3), caption: []),
  figure(image("figs/kdtree_nn.pdf", width: 100%, page: 4), caption: []),
  figure(image("figs/kdtree_nn.pdf", width: 100%, page: 5), caption: []),
  columns: (1fr, 1fr),
  caption: [Several states for the nearest neighbour query based on a $k$d-tree, $q=(4.5, 4.0)$ is the query point and $c=(6,4)$ is the nearest point.],
  placement: none,
  label: <fig:kdtree_nn>,
)

The idea of the algorithm we are presenting here is to traverse the whole tree (in depth-first order), but use the properties of the tree to quickly eliminate large portions of the tree.
The eliminated subtrees are based on their bounding boxes.
#note[subtrees are eliminated based on their bounding boxes]
As we traverse the tree, we must keep track of the closest point $c_"temp"$ so far visited.

The algorithm starts at the root, stores the current closest point $c_"temp"$ as the root, and visits the nodes in the tree in the same order as for the insertion of a new point.
This order is the one that is _most promising_, because we expect $c$ to be close to the insertion location (albeit this is not always the case).
At each node $n_i$ it updates $c_"temp"$ if it is closer.
For this, the Euclidean distance is used.
For the example in @fig:kdtree_nn\b, point ($5,6$) is the first $c_"temp"$, and then although ($2,7$) and ($1,3$) are visited, neither is closer and thus after that step $c_"temp" = (5,6)$.

The algorithm then recursively visits the other subtrees, and checks whether there could be any points, on the other side of the splitting hyperplane, that are closer to $q$ than $c_"temp"$.
The idea behind this step is that most of the subtrees can be eliminated by verifying whether the region of the bounding box of the subtree is closer than the current $d(q, c_"temp")$, $d()$ being the Euclidean distance between 2 points.
If that distance is shorter, then it is possible that one point in the subtree is closer than $c_"temp"$, and thus that subtree must be visited. 
If not, then the whole subtree can be skipped, and the algorithm continues.

@fig:kdtree_nn\c shows this idea after ($1,3$) has been visited.
$c_"temp"$ is ($5,6$), and we must decide whether the subtree right of ($2,7$) must be visited.
In this case it must not be visited because the bounding box (light blue region) is 3.0 units from $q$, and $d(q,c_"temp")$ is around 2.07; it is thus impossible that one point inside the subtree be closer than ($5,6$).

The next step is verifying whether the subtree right of the root could contain a point closer than $c_"temp"$.
In the @fig:kdtree_nn\d, this is possible since the bounding box is only 0.5 unit from $q$, and thus the subtree must be visited.

The algorithm continues until all subtrees have either been visited or eliminated.
At the end, $c$ is ($6,4$).

==== Time complexity
To insert a new point, and to search for a nearest neighbour, the time complexity on average is $cal(O) (log n)$; this is assuming the tree is balanced, if not it could be $cal(O) (n)$ in the worst-case.
The tree stores one node per point, thus the space complexity is $cal(O) (n)$.

==== $m$-closest neighbours <sec:knn-m>
The algorithm can be extended in several ways by simple modifications. 
It can provide the $m$ nearest neighbours to a point by maintaining $m$ current closest points instead of just one. 
A branch is only eliminated when $m$ points have been found and the branch cannot have points closer than any of the $m$ current bests. 
This can help improve significantly the running time of several operations described in this book: IDW with a fixed number of neighbours (@sec:wam_interpol), extracting shapes from point clouds (@sec:shape-detection), estimating normals in point clouds (@app:normalplane[Appendix]), calculating the spatial extent (@chap:spatialextent), are only but a few examples.

== #flex-heading[Streaming paradigm][Streaming paradigm to construct massive TINs and grids from point clouds] <sec:streaming>

The incremental construction algorithm for the Delaunay triangulation (DT), presented in @chap:dtvd, will not work if the size of the input dataset is larger than the main memory.
Or if it works, it will be very slow.
The reason for this is that the data structure for the DT (to store the points coordinates, and also the data structure for the triangles and their topological relationships) will not fully fit in the main memory.
Therefore, part of it will be in the main memory (say #qty("16", "GB") of RAM) and the other part will be on the harddrive.
The operating system controls which parts are in memory and which parts are on the harddrive, and we call _swapping_ the operations to transfer between them.
#note[swapping]

One solution to this problem is to design external memory algorithms.
#index[external memory algorithms]#note[external memory algorithms]
These basically do not rely on the operating system to decide which parts of the data structure are stored on the disk, but improve the process by explicitly storing temporarily files and having explicit rules for the swapping of data between the disk and the memory. 
The main drawbacks of this approach are that the design of such algorithms is rather complex, that for different problems different solutions have to be designed, and that for problems like the DT construction a lot of large temporary files need to be created.

We discuss in this section an alternative approach to dealing with massive datasets: _streaming_.
#index[streaming data]#note[streaming data] 
A _stream_ is a sequence of data---in theory it can be infinite!---that is available over a period of time, and "can be thought of as items on a conveyor belt being processed one at a time rather than in large batches" #note(link("https://en.wikipedia.org/wiki/Stream_(computing)")).
One concrete example is YouTube: to watch a given video a user does not need to first download the whole file, she can simply start watching the video as soon as the first KB are downloaded.
The content of the video is downloaded as she watches the video, and if she fast-forwards to, for instance, 5:32s then only the KB of content from where the cursor is need to be downloaded to watch the video.
At no moment is the full video downloaded to the user's device.

Batch algorithms, like the incremental insertion algorithm described in @sec:dtconstruction,
#index[batch processing]#note[batch processing] 
require to have all the points in memory to work.
By contrast, a streaming algorithm operates only _locally_ and can thus, in theory, process infinitely large datasets.

The streaming paradigm can be used to process geometries (points, meshes, polygons, etc.) but it is slightly more involved than for a simple video.
Since the First Law of Geography of #citet(<Tobler70>) stipulates that "everything is related to everything else, but near things are more related than distant things", 
if we wanted to calculate the slope at one location in a point cloud we would need to retrieve all the neighbouring points and potentially calculate locally the DT.
The question is: is it possible to do this without reading the whole file and only process one part of it?

We focus in the following on the creation of a DT.
The main issue that we are facing is that a triangle is respecting the Delaunay criterion if its circumcircle is empty of any point, therefore while constructing the DT we need to test all the other points in the dataset to ensure that a given triangle is Delaunay (or not).
Streaming would mean here: can we assess that a given triangle is Delaunay without having to read/download the whole file?

#box-practice("Streaming is realised with Unix pipes")[
  The key to implementing streaming of geometries is to use Unix pipes (also called _pipelines_).
  \ 
  Pipelines were designed by Douglas McIlroy at Bell Labs during the development of Unix, and they allow to chain several processes together. The output of a process becomes the input of the next one, and so on (the data flowing through the process is the _stream_). Given 2 processes, the 2nd one can usually start before the 1st one has finished processing all the data.
  \ 
  In Unix, the pipe operator is the vertical line "`|`", and several commands can be chained with it: "`cmd1 | cmd2 | cmd3`". 
  A simple example would be "`ls -l | grep json | wc -l`" which would:
  + list all the files in the current directory (one file name per line); 
  + send this to the operator _grep_ which would discard all lines not having the keyword `"json"`; 
  + send this to the operator "`wc -l`" which counts the number of line.
]

=== Overview of streaming DT construction

@fig:streamingdt shows the overview of the processes involved for the construction of a DT with the streaming paradigm.
#figure(
  image("figs/streaming_pipeline.pdf", width: 90%),
  caption: [Overview of the streaming pipeline to construct a DT (or extract isolines).],
  placement: none,
) <fig:streamingdt>
Think of the stream as a 1D list of objects (points, triangles, tags, etc.) and the aim is to be able to perform an operation without having in memory the whole stream.

=== Finaliser: adding finalisation tags to the stream

The key idea is to _preprocess_ a set $S$ of points and insert _finalisation tags_ informing that certain points/areas will not be needed again.
For the DT construction, as shown in @fig:finaliser, this can be realised by constructing a quadtree of $S$; a finalisation tag basically informs the following processes that a certain cell of the quadtree is empty, that all the points inside have been processed (have already appeared in the stream).
#figure(
  image("figs/finaliser.pdf", width: 100%),
  caption: [How the finaliser modifies the input and injects finalisation tags. #strong[Left:] 9 points and the related streams (just a list of the points with coordinates). #strong[Right:] if a quadtree of depth 1 (in orange) is used (with 4 cells), then the stream would be augmented with finalisation tags.],
  placement: none,
) <fig:finaliser>

In practice, this is performed by reading a LAS/LAZ file (or any format with points) _twice_ from disk: 
+ the first pass will count how many points are in each cell of the quadtree (and store the results)
+ the second pass will read again sequentially each point (and send it in the stream), and decrement the counter for each cell. When it is empty, a finalisation tag will be added to the stream.

=== Triangulator

The input of the triangulator is the output of the finaliser: a set of points with finalisation tags.
The triangulator will triangulate the points as described in @sec:dtconstruction, but will attempt to remove from memory the triangles that are _final_, those that we are sure will never be modified (since it is guaranteed that no new points will fall inside their circumcircle).
This is performed with the finalisation tags and the following observation (see @fig:triangulator): 
#figure(
  image("figs/triangulator.pdf", width: 100%),
  caption: [The DT at a given moment during the triangulation process. Blue quadtree cells are not finalised yet, white ones are; yellow triangles are still in memory (their circumcircles (in red) encroach on unfinalised cells); white triangles have been written to disk since their circumcircles do not encroach on an active cell (some green circles shown as example).],
  placement: none,
) <fig:triangulator>
a triangle inside a finalised quadtree cell (ie where all the points in the streams inside that cell have been read) is _final_
#note[finalisation of triangles]
if its circumcircle does not encroach on an active quadtree cell.
If its circumcircle overlaps with an active quadtree cell, then it is possible that later in the stream a new point will be added inside the circle, and thus the triangle will not be Delaunay.

Final triangles can be removed from memory and written directly to disk; it is however possible to add another process to the pipeline and send the final triangles to them (eg to create a grid or to extract isolines).

Notice also that the memory the triangle was using can be reused to store another new triangle created by new points arriving in the stream.

=== Spatial coherence <sec:spatial_coherence>

The construction of a DT with the streaming paradigm will only succeed (in the sense that the memory footprint will stay relatively low) if the _spatial coherence_
#index[spatial coherence]
of the input dataset is high.
It is defined by #citet(<Isenburg06>) as:
#quote(block: true)[
  _"a correlation between the proximity in space of geometric entities and the proximity of their representations in [the file]"_
]
They demonstrate that real-world point cloud datasets often have natural spatial coherence because the points are usually stored in the order they were collected.
If we shuffled randomly the points in an input file, then the spatial coherence would be very low and the finalisation tags in the stream coming out of the finaliser would be located at the end (and not distributed in the stream).

It is possible to visualise the spatial coherence of a dataset by colouring, for an arbitrary grid, the positions of the first and last points; @fig:spatial_coherence gives an example.
The idea is to assign a colour map based on the position of the points in the file, and to colour the centre of the cells with the position of the first point inside that cell, and to colour the boundary of the cell with the position of the last point.
#notefigure(
  image("figs/spatial_coherence.pdf", width: 95%),
  caption: [The colour map used for the position of a point in the file, and 3 examples of cells.],
  dy: 300pt,
) <fig:spatial_coherence>

@fig:spatial_coherence_examples illustrates the spatial coherence for 2 tiles of the AHN3 dataset in the Netherlands.
Notice that the cells are generally of the same colour, which means that the spatial coherence is relatively high.
It is interesting to notice that the two datasets have different patterns probably because they were compiled by different companies, who used different equipment and processing software to generate the datasets.
// #wideblock[
  #subfigure(
    figure(image("figs/37EN1_double.pdf", width: 100%), caption: []),
    figure(image("figs/07BZ2-double.pdf", width: 100%), caption: []),
    columns: (1fr, 1fr),
    caption: [Spatial coherence of 2 AHN3 tiles. The inner cell colour indicates the position in the stream of first point in that cell, and the outer cell colour indicates the position in the stream of the last point in that cell.],
    placement: top,
    label: <fig:spatial_coherence_examples>,
  )
// ]

=== Streaming cannot solve all problems related to terrains

The ideas behind streaming are very useful for certain _local_ problems (eg interpolation, creation of grids, extraction of contour lines), but unfortunately they cannot be used directly (or it would be extremely challenging) for _global_ problems such as visibility or flow modelling.

== Notes and comments

The description of the $k$d-tree and the nearest neighbour query is adapted from Wikipedia (link("https://en.wikipedia.org/wiki/K-d_tree")) and the lecture notes entitled "kd-Trees---CMSC 420" from Carl Kingsford (available at #link("https://www.cs.cmu.edu/ckingsf/bioinfo-lectures/kdtrees.pdf")).

#citet(<Vitter01>) provides an overview of external algorithms.

#citet(<Agarwal05>) construct massive TINs by designing external algorithms, and #citet(<Arge06>) and #citet(<Agarwal08>) have implemented spatial analysis functions on TINs based on that paradigm.

The streaming computation of the DT algorithm is a simplification of the algorithm described in #citet(<Isenburg06>), and some figures were basically redrawn.

#citet(<Isenburg06-1>) explains in detail how large rasters can be constructed with spatial interpolation by modifying the streaming pipeline of @fig:streamingdt.

== Exercises

+ The tree in @fig:kdtree2 is balanced, but if ($1,3$) had been selected as the root, how would the tree look like?
+ Real-world point cloud datasets often have natural spatial coherence. Explain why that is the case for lidar datasets.
+ How to construct a $k$d-tree that is as balanced as possible?
+ "The ideas behind streaming are very useful for certain _local_ problems, but unfortunately they cannot be used directly for _global_ problems such as visibility or flow modelling". Explain why that is with a concrete example.
