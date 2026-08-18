#import "../template.typ": *

= Processing bathymetric data to produce hydrographic charts <chap:bathymetry>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/DVUm7SdzhfI")

A hydrographic chart is a map of the underwater world specifically intended for the safe navigation of ships, see @fig:enc for an example.
In its digital form, it is often called an electronic navigational chart, or ENC.
#index[electronic navigational chart (ENC)]
The information appearing on an ENC is standardised, and there are open formats.

We focus in this chapter on one element of these charts: depth-contours.
These are contour lines that, instead of elevation, show the depth with respect to a given level of water.
The creation of these depth-contours from an input point cloud of depth measurements requires many tools that were introduced in this book; Delaunay triangulation and the Voronoi diagram (@chap:dtvd), interpolation (@chap:interpol), and contour generation from a TIN (@chap:conversion).

== #flex-heading[Depth contours][How are depth-contours produced in practice?]

Traditionally, depth-contours were drawn by hand by skilled hydrographers.
They used a sparse set of scattered surveyed depth measurements to deduct and depict the morphology of the seafloor with smooth-looking curves.

Nowadays, with technologies such as multibeam echosounders (MBES)
#note[multibeam echosounder (MBES)]#index[multibeam echosounder (MBES)]
offering an almost full coverage of the seafloor (see @sec:mbes), one would expect the contouring process to be fully automatic.
It is however in practice still a (semi-)manual process since the new technologies have ironically brought new problems: computers have problems processing the massive amount of data, especially in choosing which data is relevant and which is not.

#figure(
  image("figs/enc_denhelder.jpeg", width: 90%),
  caption: [An example of an ENC (electronic navigational chart) in the Netherlands. [photo of a paper map from the #emph[Hydrografische Dienst]]],
  placement: none,
) <fig:enc>

The raw contours constructed directly from MBES datasets are often not satisfactory for navigational purposes since, as @fig:raw shows,
they are zigzagging (the representation of the seafloor thus contains "waves", ie the slope changes abruptly) and they contain many "island" contours (seafloor has several local minima and maxima). 
These artefacts are the result of measurement noise that is present in MBES datasets, ie the variation in depth between two close samples can be larger than in reality, even after the dataset has been (statistically) cleaned.
@fig:ideal illustrates what is expected by hydrographers.
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("figs/raw.pdf", width: 100%), caption: []), <fig:raw>,
  figure(image("figs/maponly.pdf", width: 100%), caption: []), <fig:ideal>,
  figure(image("figs/smoothinAndOmission.png", width: 100%), caption: []),
  figure(image("figs/aggregation.png", width: 100%), caption: []), <fig:aggregation>,
  columns: (1fr, 1fr),
  caption: [Comparison of #strong[(a)] depth-contours obtained automatically from the raw MBES data and #strong[(b)] the hydrographic chart from the Royal Australian Navy for the Torres Strait north of Australia. Raw depth contours are blue, generalized depth contours are black. #strong[(c)] Pits are removed, while peaks are preserved or integrated with another contour. #strong[(d)] Groups of nearby contour lines are aggregated],
  placement: none,
  label: <fig:contouringaspects>,
)

=== Generalisation is required to obtain good depth contours <sec:good-depth-contours>

Creating good depth-contours requires _generalisation_, ie the process of meaningfully reducing information.

The process of generalisation is guided by constraints that essentially define when a depth-contour is "good".
A good depth contour satisfies all of the following four generalisation constraints.
/ Safety constraint: #note[safety constraint]
 At every location, the indicated depth must not be deeper than the depth that was originally measured at that location; this is to guarantee that a ship never runs aground because of a faulty map.
 This constraint is a so-called hard constraint, ie it can never be broken.
/ Legibility constraint: 
 An overdose of information slows down the map reading process for the mariner, thus only the essential information should be depicted on the map in a form that is clearly and efficiently apprehensible.
/ Topology constraint:
 The topology of the depicted map elements must be correct, ie isocontours may not touch or intersect (also a hard constraint).
/ Morphology constraint:
 The map should be as realistic and accurate as possible, ie the overall shape of the morphology of the underwater surface should be clearly perceivable and defined features should be preserved.

It should be noted that these four constraints are sometimes incompatible with each other. 
For instance, the morphology constraint tells us to stay close to the measured shape of the seafloor, while the legibility constraint forces us to deviate from that exact shape by disregarding details.

Also, because of the safety constraint, depth-contours can only be modified such that the safety is respected at all times: contours can only be pushed towards the deeper side during generalisation, as illustrated in @fig:genvalidornot. 
#figure(
  image("figs/genvalidornot.pdf", width: 80%),
  caption: [During generalisation, depth-contours can only be moved towards greater depth (indicated by a "--" in the figure).],
  placement: none,
) <fig:genvalidornot>
It is therefore obvious that the end result must be a reasonable compromise between the four constraints, although the hard constraints must not be broken.

== #flex-heading[Common methods][Common methods used in practice are not satisfactory]

The generation of depth contours, and their generalisation, can be done by several methods.
We present here the most frequently used methodologies to generate depth-contours from an MBES point cloud.

=== Displacement and generalisation of the lines

It is tempting to start with the raw contours lines and use a generalisation operator to simplify them, eg the Douglas-Peucker method.
#index[Douglas-Peucker simplification]#note[Douglas-Peucker simplification]
It should however be noticed that this method does _not_ guarantee that the safety constraint will be respected, that is the generalised line will be "pushed" both to the deeper and the shallower part (there is no control for this with the Douglas-Peucker method).

There exist a few algorithms to control the direction in which a line can be moved (these methods are outside the scope of this book), but these methods work only on lines individually and thus the resulting set of lines can contain intersecting lines.
Furthermore, this solution does not solve the presence of many island contours, or can at best delete the small ones (and not aggregate them as in @fig:aggregation).

=== Creation of a simplified raster

Practitioners usually first interpolate the original MBES samples to create a (coarse) grid and then directly extract the contours from the grid.
If the number of samples is too high to be processed by a computer, they often use a subset, which has the added benefits of creating smoother and simpler depth-contours.

The following are methods that use a raster data structure either to select a subset of the input samples or to construct a raster surface.

==== Selection with virtual gridding
This is a point filtering method that aims at reducing the volume of data, in order to create generalised contours and to speed up the computation time, or simply to make the computation possible, in the case the input dataset is several orders of magnitude bigger than the main memory of a computer.
The idea is to overlay a virtual grid on the input points and to keep one point for every grid cell (similar to grid thinning as explained in Section @sec:thinning).
The selected points can either be used to construct a raster using interpolation or a TIN surface, and contours can be derived from that.
While different functions can be used to select the point (eg deepest, shallowest, average, or median), because of the safety constraint the shallowest point is often chosen by practitioners, see @fig:fr:vg:a for a one-dimensional equivalent.
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("figs/virtualgridding.pdf", width: 100%, page: 2), caption: [Virtual gridding]), <fig:fr:vg:a>,
  figure(image("figs/maxgridding.pdf", width: 100%, page: 2), caption: [Max rasterisation]), <fig:fr:mg:a>,
  figure(image("figs/1Didw.pdf", width: 100%, page: 4), caption: [IDW rasterisation]), <fig:fr:idw:a>,
  figure(image("figs/virtualgridding.pdf", width: 100%, page: 3), caption: [Virtual gridding and TIN-based contour values]), <fig:fr:vg:b>,
  figure(image("figs/maxgridding.pdf", width: 100%, page: 3), caption: [Max rasterisation and contours]), <fig:fr:mg:b>,
  figure(image("figs/1Didw.pdf", width: 100%, page: 5), caption: [IDW rasterisation and contours]), <fig:fr:idw:b>,
  columns: (1fr, 1fr),
  caption: [Profile views of different filtering and rasterisation methods. The arrows indicate where the safety constraint is violated with respect to the original points. Also note that in case a grid cell contains no data, no contours can be derived.],
  placement: none,
  label: <fig:filterraster>,
)
It should however be stressed that choosing the shallowest point does not guarantee safe contours. 
The problem is that contour extraction algorithms perform a linear interpolation on the raster cells. 
As can be observed from @fig:fr:vg:b, this easily results in safety violations at 'secondary' local maxima in a grid cell. 
The number and severity of these violation is related to the cellsize of the virtual grid: a bigger cellsize will result in more and more severely violated points.
Notice that it is not possible to reduce the cellsize such that the safety issue can be guaranteed.

==== Max rasterisation
As @fig:fr:mg:a shows, it is similar to virtual gridding, the main difference is that a raster (a surface) is created where every cell in the virtual grid becomes a raster cell whose depth is the shallowest of all the samples.
This disregards the exact location of the original sample points, and moves the shallowest point in the grid cell to the centre of the pixel. 
That means that the morphology constraint is not respected.
Moreover, as @fig:fr:mg:b shows, the safety constraint is not guaranteed, for the same reasons as with virtual gridding.
Again, the severity of these problems depends on the chosen cellsize.

==== Interpolation to a raster
For hydrographic charts, the raster surface is often constructed with spatial interpolation, particularly with the method of inverse distance weighting (IDW).
Figures @fig:fr:idw:a and @fig:fr:idw:b illustrate the process of IDW interpolation, notice that as a result of the averaging that takes place, extrema are disregarded and subsequently the safety constraint is also violated.


=== TIN simplification

One could use TIN simplification, as explained in @chap:conversion, to simplify the seabed.
This would also simplify the depth-contours that are generated from the TIN. 
However, as @fig:simpfail shows, the safety constraint is not guaranteed to be respected when vertices are removed from a TIN.
This is due to the fact that the triangulation must be updated (with flips, see @sec:dtconstruction) and it is likely that a change in the triangulation will eventually violate the safety constraint on a vertex that was removed earlier.
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("figs/simpfail.pdf", width: 100%, page: 1), caption: [Initial configuration]), <fig:simpfail:a>,
  figure(image("figs/simpfail.pdf", width: 100%, page: 2), caption: [1st vertex removal]), <fig:simpfail:b>,
  figure(image("figs/simpfail.pdf", width: 100%, page: 3), caption: [2nd vertex removal]), <fig:simpfail:c>,
  columns: (1fr, 1fr, 1fr),
  caption: [Due to the re-triangulation after a removal, violations of the safety constraint may occur after a series of points are removed. The first vertex is removed (locally the resulting surface will be shallower). However, the second removal changes the configuration of triangles and at that location the surface is now deeper. A lower number means a shallower point.],
  placement: none,
  label: <fig:simpfail>,
)

== #flex-heading[Voronoi-based approach][A Voronoi-based surface approach]

Part of the problems with existing approaches to generate depth-contours is the fact that the different processes, such as spatial interpolation, generalisation and contouring, are treated as independent processes, while they are in fact interrelated. In the following we introduce a method where the different processes are integrated.
This method uses several of the algorithms and data structures studied in this book, and with small extensions and modifications we can obtain depth-contours that are both legible and guaranteed to be safe.

The key idea behind the method, called the Voronoi-based surface approach, is to have one single consistent representation of the seafloor from which contours can be generated on-the-fly (potentially for different map scales, or with varying degrees of generalisation).
Instead of performing generalisation by moving lines or using a subset of the original samples, we include all MBES points in a triangulation (the surface) and manipulate this triangulation directly with generalisation operators that fulfil the constraints listed in Section @sec:good-depth-contours.

@fig:surfapproach gives a schematic overview of the different components of our Voronoi-based surface concept. 
#figure(
  image("figs/surfaceapproach_V2.pdf", width: 100%),
  caption: [Overview of the Voronoi- and surface-based approach.],
  placement: none,
) <fig:surfapproach>

Firstly, all the input points of a given area are used to construct a Delaunay TIN.
Secondly, a number of generalisation operators are used that alter the TIN using Laplace interpolation, which is based on the Voronoi diagram.
#index[Laplace interpolation]#note[Laplace interpolation]
These operators aim at improving the slope of the surface, and permit us to generalise the surface.
Finally, contour lines are derived from the altered TIN using linear interpolation.

Representing a field in a computer is problematic since computers are discrete machines.
We therefore need to _discretise_ the field, ie partition it into several pieces that cover the whole area (usually either grid cells or triangles).
Contours in @fig:raw are not smooth basically because the seabed is represented simply with a TIN of the original samples, which is a $C^0$ interpolant.
However, as we demonstrate below, we can obtain a smooth looking approximation of the field by densifying the TIN using the Laplace interpolant (see Section @sec:laplace), which is $C^1$.

Two generalisation operators allow us to obtain a smoother surface from which depth-contours can be extracted: (1) smoothing; (2) densification.

=== The smoothing operator <chap:myapproach:smoothing>

The smoothing operator basically estimates, with the Laplace interpolant (see @sec:laplace), the depth of each vertex in a dataset by considering its natural neighbours (see @fig:1Dsmoothop).
If this depth is shallower, then the vertex is assigned this value; if it is deeper then nothing is done.
Thus, the smoothing operator does not change the planimetric coordinates of vertices, but only lifts the vertices' depths upwards (if at all). 
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("figs/1Dsmoothop.pdf", width: 100%, page: 1), caption: [Initial TIN]), <fig:1Dsmoothop:a>,
  figure(image("figs/1Dsmoothop.pdf", width: 100%, page: 2), caption: [Estimation using only neighbours]), <fig:1Dsmoothop:b>,
  figure(image("figs/1Dsmoothop.pdf", width: 100%, page: 3), caption: [Comparison of depths]), <fig:1Dsmoothop:c>,
  figure(image("figs/1Dsmoothop.pdf", width: 100%, page: 4), caption: [Resulting TIN]), <fig:1Dsmoothop:d>,
  columns: (1fr, 1fr),
  caption: [Cross-section view of the smoothing of a single vertex in a TIN.],
  placement: none,
  label: <fig:1Dsmoothop>,
)

To perform the Laplace interpolation for each vertex $v$ in the Voronoi diagram $cal(D)$, it suffices to obtain the natural neighbours $p_i$ of $v$, and for each calculate the lengths of the Delaunay and the dual Voronoi edge (as explained in Section @sec:laplace).
There is no need to insert/remove $v$ in the dataset, since we are only interested in estimating its depth (without considering the depth it is already assigned).

The primary objective of smoothing is to generalise the surface by removing high frequency detail while preserving the overall seabed shape. 
Applying it reduces the angle between adjacent triangles which gives the surface a smoother look.

It performs two linear loops over the $n$ vertices of the dataset (the depths are only updated after all the depths have been estimated), and since the smoothing of one vertex is performed in expected constant time, the expected time complexity of the algorithm is $cal(O) (n)$.

Observe that the operator can be performed either on a portion of a dataset, or on the whole dataset. 
Furthermore this operator can be applied any number of times, delivering more generalisation with each pass.

=== The densification operator <sec:densification>

Its objective is primarily to minimise the discretisation error between the Laplace interpolated field and the contours that are extracted from the DT, this is illustrated in @fig:1Ddensop.
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("figs/1Ddensop.pdf", width: 100%, page: 1), caption: [Initial TIN]), <fig:1Ddensop:a>,
  figure(image("figs/1Ddensop.pdf", width: 100%, page: 2), caption: [Interpolated field (dashed)]), <fig:1Ddensop:b>,
  figure(image("figs/1Ddensop.pdf", width: 100%, page: 3), caption: [Addition of intermediate points (orange)]), <fig:1Ddensop:c>,
  figure(image("figs/1Ddensop.pdf", width: 100%, page: 4), caption: [Resulting TIN]), <fig:1Ddensop:d>,
  columns: (1fr, 1fr),
  caption: [Cross-section view of the densification operator in a TIN.],
  placement: none,
  label: <fig:1Ddensop>,
)

By inserting extra vertices in large triangles (to break them into three triangles), the resolution of the DT is improved.
As a result also the extracted contour lines have a smoother appearance because they now have shorter line-segments; see Section @sec:smoothness-contours for an explanation.
We insert a new vertex at the centre of the circumscribed circle of any triangle that has an area greater than a preset threshold; its depth is assigned with the Laplace interpolant.
The circumcentre is chosen here because that location is equidistant to its three closest points, and subsequently results in a very natural point distribution.


#subfigure(
  figure(image("figs/pyramid_o_tr.pdf", width: 100%), caption: [Original data]),
  figure(image("figs/pyramid_o_pers.pdf", width: 100%), caption: [Perspective view of original data]),
  figure(image("figs/pyramid_o_cl.pdf", width: 100%), caption: [Contour lines from original data]),
  figure(image("figs/pyramid_v_tr.pdf", width: 100%), caption: [Densified with Laplace interpolant]),
  figure(image("figs/pyramid_v_pers.pdf", width: 100%), caption: [Perspective view after densification]),
  figure(image("figs/pyramid_v_cl.pdf", width: 100%), caption: [Contour lines from densified surface]),
  columns: (1fr, 1fr, 1fr),
  caption: [Original data are shown in #strong[(a)] and #strong[(b)], and the resulting contour lines in #strong[(c)]. The three figures below represent the same area densified with the Laplace interpolant.],
  placement: none,
  label: <fig:interpol_smooth>,
)

@fig:interpol_smooth shows an example of these ideas. 
@fig:interpol_smooth\a and @fig:interpol_smooth\b show the original dataset, which is a very simple pyramid having its base at elevation 0, and its summit at 10. 
@fig:interpol_smooth\d--f shows the results when a densification operator based on the Laplace interpolant is used. 
It should be noticed that the "top" of the pyramid was densified, and not so much the bottom, therefore the contour lines near the bottom should be ignored (the fact that they are close to the border of the dataset also creates artefacts).

Densification aims to reduce the difference between the linear TIN and the Laplace interpolated field of its vertices---effectively improving the resolution of the extracted contours.
Therefore, densification is to be applied just before the extraction of the depth-contours.#note[apply densification _before_ contour extraction and _after_ smoothing]
If applied _before_ the smoothing operator, it would limit the effectiveness of that operator, since a denser triangulation smoothes more slowly.

The densification operator uses an area-threshold that determines which triangles should be densified. 
This way triangles that are already sufficiently small are not densified. 
It performs a single pass on the input triangles, thus with every call the resolution of the DT is increased, until all triangles have reached a certain area.

If the maximum area threshold is ignored, a single call costs $cal(O) (n)$ time, as it only requires a single pass over the $n$ triangles of the TIN. 
However, when a number of $t$ densification passes is sequentially performed, it only scales to $cal(O) (3^(t) n)$ time, since every point insertion creates two new triangles. 
However, because of the maximum area threshold, that worst case scenario will never be reached in practice with large $t$.

== #flex-heading[Real-world examples][Some examples of results with real-world datasets]

@fig:zl1845fieldview shows the results obtained with the implementation of the method described in this chapter.
This was tested with an MBES dataset from Zeeland, in the Netherlands.

#wideblock[
  #subfigure(
    figure(image("figs/zl1845fieldview_o.pdf", width: 100%), caption: []), <fig:zl1845fieldview_o>,
    figure(image("figs/zl1845fieldview_s.pdf", width: 100%), caption: []), <fig:zl1845fieldview_s>,
    figure(image("figs/zl1845fieldview_raster_d.pdf", width: 100%), caption: []), <fig:zl1845fieldview_raster_d>,
    columns: (1fr, 1fr, 1fr),
    caption: [The effect of the smoothing operator in the Zeeland dataset. #strong[(a)] Raw contours extracted at a #qty("50", "cm") depth interval. #strong[(b)] Smoothed contours (100 smoothing passes). The ellipses mark areas where aggregation (left), omission (middle) and enlargement (right) take place. #strong[(c)] Difference map between the initial and 100X smoothed interpolated and rasterised fields (pixel size #qty("50", "cm")).],
    placement: auto,
    label: <fig:zl1845fieldview>,
  )
]

As can be observed from @fig:zl1845fieldview_o, the raw and ungeneralised contours in the dataset have a very irregular and cluttered appearance. 
However, the smoothed contours (100 smoothing passes) from @fig:zl1845fieldview_s have a much cleaner and less cluttered appearance. 
Clearly, the number of contour lines has diminished. 
This is both because pits (local minima) have been lifted upwards by the smoothing operator, and nearby peaks (local maxima) have been aggregated (because the region in-between has been lifted upwards). 
Notice also that a third effect of the smoothing operator is the enlargement of certain features as a result of the uplifting of the points surrounding a local maximum.

The effects of the densification operator are also visible. 
The sharp edges of the undensified lines are caused by the large triangles in the initial TIN, however after densification these large triangles are subdivided into much smaller ones. 
The result is a much smoother contour line that still respects the sample points.

Naturally, the smoothing operator also smoothes and simplifies the resulting contour lines.
@fig:zl1845lineview illustrates the effect of the smoothing operator on a single contour over 30 smoothing passes. 
#wideblock[
#figure(
  image("figs/zl1845detailcontours0-30.pdf", width: 95%),
  caption: [From 0X smoothing (outer) to 30X smoothing (inner) for a given dataset.],
  placement: none,
) <fig:zl1845lineview>
]
It is clear that the contour line moves towards the inner region, which is the deeper side of the contour, which is to be expected since the smoothing operator is safe per definition (and only lifts the surface upwards). 
What can also be seen is that the line is simplified (the details on the outer rim disappear, note however that the point count stays the same) and smoothed.

== Notes and comments

The algorithm and the methodology of this chapter are (mostly) taken from #citet(<Peters14>).

#citet(<Zhang11>) explains in detail how the generalisation of the content of a nautical chart is hindered by the four constraints.

== Exercises

+ Explain why it is easier to respect the safety constraint using a TIN that has all the original MBES points as opposed to using a set of raw contours generated directly from that MBES dataset.
+ Explain why simplification with Douglas-Peucker is not applicable in a bathymetric context. And give a concrete example.
+ For a terrain "on the land", if Douglas-Peucker is used to simplify isocontours, what problems can be expected?
+ The Laplace interpolation is used in the methodology presented, but would the natural neighbour interpolation method also be suitable?
