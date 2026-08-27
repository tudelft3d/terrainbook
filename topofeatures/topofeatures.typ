#import "../template.typ": *

= Topographic properties and features <chap:topofeatures>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/iF64Qeb_isw")


While a terrain is a (2.5D) surface, it can also be conceptualised as an aggregation of many _topographic features_ that are inter-related.
#index[topographic feature]
Common examples of features are peaks, ridges, valleys, lakes, cliffs, etc., but one can think of application-specific ones such as the navigational channels in bathymetry, buildings in city modelling, or dikes for flood modelling.

Identifying the different features forming a terrain enhances our understanding of the raw dataset.
To help us extract and identify features, some properties (or characteristics) need to be extracted from terrains.

We describe in this chapter the main properties of terrains, explain how they can be extracted, and how they are used in practice (for specific use-cases in different fields, and to identify features).

== Topographic properties <sec:topoproperties>

We describe in this section the main topographic properties that are commonly extracted from terrains:
+ slope
+ curvature
+ roughness

Since these differ significantly from the data model used (TINs and grids), we give examples for both.

==== For grids
The extraction of these properties is more common with grids, and in most cases kernel filters are used, @fig:filter shows one example.
#notefigure(
  image("figs/filter.pdf", width: 100%),
  caption: [Example of a $3 times 3$ filter. The new value of the cell $x$ of the input (in blue) is calculated by using its 8 neighbours (eg \ averaging the values) and the output terrain $t_"output"$ contains that value for its cell $x$. This operation is usually performed for all cells in the input $t_"input"$.],
) <fig:filter>
#index[kernel filter]
A filter is conceptually the same as a focal operation in map algebra (in GIS), or as a convolutional filter in computer vision.
Observe that in @fig:filter a $3 times 3$ window is shown, but a $5 times 5$ or larger window could also be used; the size to use depends on the scale at which one wants to extract a property.
The main advantage of grids is that the value of a property can be easily calculated and the output is a new grid having the same resolution and orientation, but the values are the property (eg the gradient at this location) instead of the elevation.

==== For TINs
A given property is in most cases as easy as for a grid to calculate for a given location ($x,y$), but the issue is how to store the results: in a grid? only a set of points?
This makes the use of TINs more cumbersome in practice.


=== Slope

#index[slope]

#figure(
  image("figs/slope_concept.pdf", width: 100%),
  caption: [The slope at a given location $p_i$ is defined by the tangent plane $H_i$ to the surface. Here are 3 examples for a profile view of a terrain.],
  placement: top,
) <fig:slope_concept>

The slope at a given location $p$ on a terrain is defined by the plane $H$ that is tangent at $p$ to the surface representing the terrain (see @fig:slope_concept).
What we casually refer to as 'slope' has actually two components (see @fig:slope_aspect).
+ gradient
+ aspect
#note[slope = gradient + aspect]

#figure(
  image("figs/slope_aspect.pdf", width: 100%),
  caption: [One DTM with contour lines, and the gradient and aspect for a given location (blue cross).],
  placement: top,
) <fig:slope_aspect>

==== Gradient
The gradient at a given point $p$ is the maximum rate of change in elevation. 
It is obtained by the angle $alpha$ between $H$ and the horizontal plane (@fig:slope_aspect).
From a mathematical point-of-view, the gradient is the maximum value of the derivative at a point on the surface of the terrain (maximised over the direction).

The gradient will most often be expressed in degrees or in percentage.
If a percentage is used, the following is used (see @fig:slope_aspect):

$ "percentage" = frac(Delta z, Delta x y) $

which means that a hill with a gradient of 100% is equal to $alpha = qty("45", "degree")$.


Notice that if we calculate the gradient at every location for a terrain, then we obtain a new field since the gradient is a continuous phenomena (values from $qty("0", "degree")$ to $qty("30", "degree")$ for instance).
This means in practice that for a given terrain in raster, calculating its gradient will create a new raster file that can be further processed.

==== Aspect
At a given point $p$ on the terrain the gradient can be in any direction, the aspect is this direction projected to the $x y$-plane. 
It is basically a 2D vector telling us the direction of the steepest slope at a given point; at a given location the aspect will always be perpendicular to the contour line.
Observe that for the parts of the terrain that are horizontal (eg a lake) the value of the aspect is unknown.

The aspect is usually expressed as a _cartographical azimuth_,
#note[cartographical azimuth]
which is expressed in degrees, from the North, clockwise: $qty("0", "degree")$ means North, $qty("90", "degree")$ East, $qty("180", "degree")$ South, and $qty("270", "degree")$ West.

==== Slope in TINs
Calculating the slope in a TIN is fairly straightforward: for a point $p=(x,y)$ find the triangle $tau$ containing this point, and compute the normal vector $arrow(n)$ of $tau$ (pointing outwards). 
The projection of $arrow(n)$ on the $x y$-plane is the aspect (this is done by simply ignoring the $z$-component of the vector).
And the gradient is obtained by calculating the angle $gamma$ between $arrow(n)$ and the horizontal plane, and taking the complement of $gamma$.

If $p$ is directly on a edge of the TIN then the solution cannot be obtained directly; it is common practice to calculate the normal vector of the 2 incident triangle and average them to obtain one $arrow(n)$.
The same is applied if $p$ is directly on a vertex $v$ of the TIN: the average of all the normal vectors of all the incident triangle to $v$ is used.

==== Slope in grids
If the terrain is represented as a regular grid (say of resolution $r$), then there exist several algorithm to obtain the slope at a given cell $c_(i,j)$.
We list here a few common ones.
It should be noticed that most algorithms use a $3 times 3$ kernel, ie the value for the gradient/aspect at cell $c_(i,j)$ is computed by using (a subset of) the 8 neighbours.
#notefigure(
  image("figs/slope_grid.pdf", width: 100%),
  caption: [#strong[(top)] Given a cell $c_(i,j)$, the $3 times 3$ kernel and its 8 neighbours. #strong[(bottom)] A hypothetical case with some elevations; orange = aspect for method \#2 below, purple = aspect for method \#3 below.],
) <fig:slope_grid>

==== 1. Local triangulation + TIN method
It is possible to locally triangulate the 9 points, calculate the normal of the 8 triangles, and then use the method above for TINs.

==== 2. Maximum height difference
This method simply picks the maximum height difference between $c_(i,j)$ and each of its 8 neighbours, the maximum absolute value is the direction of the aspect and the gradient can be trivially calculated.
Notice that this means that there are only 8 possibilities for the slope (at #qty("45", "degree") intervals).
For the case in @fig:slope_grid, the aspect would be facing south #qty("180", "degree") and the gradient would be #qty("45", "degree").

==== 3. Finite difference
With this method, the height differences in the $x$-direction (west-east) and in the $y$-direction (south-north) are calculated separately, and then the 2 differences are combined to obtain the slope.
This means that only the direct 4-neighbours of $c_(i,j)$ are used.

$  frac(partial z, partial x) = frac(z_(i - 1,j) - z_(i + 1,j), 2 thin r) thin, frac(partial z, partial y) = frac(z_(i,j - 1) - z_(i,j + 1), 2 thin r)  $

The gradient is defined as:
$  tan alpha = sqrt((frac(partial z, partial x))^(2) +(frac(partial z, partial y))^(2))  $

and the aspect as:
$  tan theta = frac(frac(partial z, partial x), frac(partial z, partial y))  $

The value of $theta$ should be resolved for the correct trigonometric quadrant, and if $frac(partial z, partial y) = 0$ then it means the aspect should be handled differently (considering only the variation in the south-north direction). 

For the case in @fig:slope_grid, the gradient would be #qty("39.5", "degree") and the aspect would be #qty("194.0", "degree").

==== 4. Local polynomial fitting 
Based on the 9 elevation points, it is possible to fit a polynomial (as explained in @chap:interpol) that approximate the surface locally; notice that the polynomial might not pass through the point if a low-degree function is used.

A quadratic polynomial could for instance be defined:
$  f(x,y) = a x^(2) + b y^(2) + c x y + d x + e y + f  $
, and thus:
$  frac(partial f, partial x) = 2 a x + c y + d  $
$  frac(partial f, partial y) = 2 b y + c x + e  $
and if a local coordinate system centered at $c_(i,j)$ is used, then $x = y = 0$, and thus $frac(partial f, partial x) = d$ and $frac(partial f, partial y) = e$.

#box-practice("How does it work in practice?")[
  The GDAL utility `gdaldem` (#link("https://www.gdal.org/gdaldem.html")) does not have the best documentation and does not explicitly mention which method is used.
  \
  After some searching, we can conclude that the method "4. Local polynomial fitting" is used by default for slope/aspect, and specifically the Horn's method is used #citep(<Horn81>).
  This uses a $3 times 3$ window, and fits a polynomial; the centre pixel value is not used.
  \
  If the option `-alg ZevenbergenThorne` is used, then the algorithm of #citet(<Zevenbergen87>) is used. 
  This uses only the 4 neighbours, and is a variation of the method "3. Finite difference" above.
  \
  The documentation of `gdaldem` states that: _"literature suggests Zevenbergen & Thorne to be more suited to smooth landscapes, whereas Horn's formula to perform better on rougher terrain."_
]


=== Curvature

#index[curvature]

The curvature is the 2nd derivative of the surface representing the terrain, it represents the rate of change of the gradient.
#note[2nd derivative of the surface]
We are often not interested in the value of the curvature itself ($frac(degree, m)$) but whether the curvature is: convex, concave, or flat.

The curvature at a point $p$ is often decomposed into types:
+ *profile curvature:* the curvature of the vertical cross-section through $p$ perpendicular to the contour line passing through $p$ (or of the vertical plane along the 2D vector of the aspect at $p$)
+ *plan curvature:* the curvature along the contour line passing through $p$ (or along the line segment perpendicular to the 2D vector aspect and passing through $p$) 
Because there are 2 types of curvatures and each have 3 potential values, there are 9 possible options (as @fig:curvatures shows).
#figure(
  image("figs/curvatures.png", width: 90%),
  caption: [Nine curvatures (Figure adapted from #citet(<VanKreveld97>)).],
  placement: none,
) <fig:curvatures>

==== Computing for grids
Computing the curvature is a complex operation and we will not describe one specific method.
The idea is to reconstruct _locally_ the surface (eg with the polynomial fitting from the section above, or with a TIN), and then verify whether the 2 curvature types are convex/concave/flat.
Observe that the curvature, as it is the case for the slope, is heavily influenced by the scale of the terrain (its resolution) and thus having a $3 times 3$ kernel might be influenced by the noise in the data, or by small features.

==== Computing for TINs
For a TIN, it is possible to define for each vertex $v$ the profile and the plan curvatures by using the triangles that are incident to $v$ and extract the contour line for the elevation of $v$ (as is shown in @fig:saddle_contour).
The idea is to classify each vertex into one of the 9 possibilities in @fig:curvatures.

If there is no contour segment, then $v$ is either a peak or a pit.
A peak will be profile and plan convex; a pit will be profile and plan concave.

If there are 2 segments, then we can use these to estimate the direction of the aspect, it will be perpendicular (thus the bisector between the 2 segments is a good estimate) in the direction of lower elevations.
If we simply look at the elevations higher and lower than $v$ along this direction, then we can easily verify whether $v$ is profile convex or concave.
For the plan curvature, we can simply walk along one of the 2 edges so that higher elevations are on our left, $v$ is plan convex if the contour line makes a left turn at $v$, if it makes a right turn it is concave, and if it is straight then it is plan flat.

If there are $>2$ segments, then $v$ is a saddle point and thus no curvatures can be defined.

When each point has been assigned a curvature---a pair (_profile_, _plan_)---we can use for instance the Voronoi diagram, as shown in @fig:vd.
#notefigure(
  grid(
    image("figs/vd.pdf", width: 100%, page: 1),
    image("figs/vd.pdf", width: 100%, page: 2),
    image("figs/vd.pdf", width: 100%, page: 3),
  ),
  caption: [#strong[(top)] Points from a TIN classified according to their curvatures (con#strong[v]ex, con#strong[c]ave, #strong[f]lat). #strong[(middle)] The VD of the points. #strong[(bottom)] The Voronoi edges between the cells having the same label are removed, to create polygons.],
) <fig:vd>
It suffices to remove the Voronoi edges incident to cells having the same label, and polygonal zones are obtained.

=== Roughness & ruggedness

#index[roughness]#index[ruggedness]

The terms "roughness" and "ruggedness" are often used interchangeably and have slightly different definitions depending on the software and/or the documentation.
We can however claim that they both refer to how "undulating" or "regular" a (part of a) terrain is.
A terrain with a high roughness will have small local deviations, while one with low roughness will be "smoother".
In other words, the normals of the surface of the terrain will deviate from each other greatly for a high roughness, and less for low roughness.
Another way to measure roughness, is to think of it as the ratio between the surface area and its projection into a plane. 
#notefigure(
  image("figs/roughness.png", width: 100%),
  caption: [The green profile of a terrain has a lower roughness than the orange one (normals locally deviate less).],
) <fig:roughness>

For gridded terrains, the roughness is most often calculated by simply looking at the differences in elevations for the cells inside a $3 times 3$ filter (or larger filter).
The roughness value for one location can be one of these variations (more exist):
- the standard deviation of the 9 values (or 25 if a $5 times 5$ filter is used) in the filter;
- the largest difference in elevation between the value in the centre of the filter and one its neighbouring cell in the filter;
- the difference between the elevation of the central pixel and the mean of its surrounding cells;

It should be observed that these methods are highly influenced by the scale, ie the resolution of the grid and the size of the filter will yield potentially very different results.

Notice also that since the differences in the elevations are used, a terrain that would be a constant slope (eg a talus) would get a roughness that is not zero (in comparison to a perfectly flat terrain).
A solution to this would be to fit a plane with least-square adjustment to all the points involved in a filter, and then compare the differences of the elevations to the plane.

For TINs, the same three variations above can be used for a single location ($x,y$), if for instance we pick the natural neighbours or if all the points within a certain distance threshold are used.
However, as mentioned above, how to create a new field of roughness is not as trivial as for a grid.
One could recreate a TIN with the values of the vertices having the roughness, or create a grid.

== Topographic features

#figure(
  image("figs/feature_points.png", width: 100%),
  caption: [#strong[(a)] Peaks and pits. #strong[(b)] A saddle point (Figure from #link("https://www.armystudyguide.com"))],
  placement: none,
) <fig:feature_points>

=== Peak

A point $p$ whose surrounding is formed only of points that are of lower elevation is a peak.
The size and shape of the surrounding is dependent on the application and on the data model used to represent the terrain.
If a grid is used, this surrounding could be the 8 neighbours; if a TIN is used they could be the vertices of the triangles incident to $p$.
Observe that a peak can be local,
#note[peaks and pits are local and influenced by the scale of the data]
that is one point that happens to be a few centimetres higher than all its neighbours would be classified as a peak (the small terrain in @fig:feature_points contains several peaks), while if we consider a hill we would surely consider only the top as the peak.
A peak is therefore on the scale of the data.

The contour line through the $p$ does not exist.

=== Pit

A point $p$ whose surrounding is formed only of points that are of higher elevation is a pit.
The same remarks as for peak apply here.
The contour line through the $p$ does not exist.

=== Saddle point

#index[saddle point]

As shown in @fig:feature_points\b, a saddle point, also called a pass, is a point whose neighbourhood is composed of higher elevations on two opposite directions, and 2 lower elevations in the other two directions.
From a mathematics point-of-view, it is a point for which the derivatives in orthogonal directions are 0, but the point is not a maximum (peak) or a minimum (pit).

If we consider the contour line of a saddle point $p$, then there are 4 or more contour line segments meeting at $p$; for most points in a terrain this will be 2, except for peaks/pits where this is 0.
#notefigure(
  image("figs/saddle_contour.pdf", width: 100%, page: 2),
  caption: [A saddle point at elevation #qty("10", "m"), and its surrounding points. The triangulation of the area is created and used to extract the contour line segments at #qty("10", "m") (red lines).],
) <fig:saddle_contour>
@fig:saddle_contour shows an example for a point with an elevation of #qty("10", "m"), the contour lines at #qty("10", "m") are drawn by linearly interpolating along the edges of the TIN of the surrounding (see @chap:conversion).

=== Valleys \& ridges

#figure(
  image("figs/valley_ridge.png", width: 100%),
  caption: [Edges in a TIN can be classified as valley, ridge, or neither],
  placement: none,
) <fig:valley_ridge>
Valleys and ridges are 1-dimensional features.
If a terrain is represented as a TIN, we can extract the edges of the triangles that form a valley or a ridge.
An edge $e$, incident to 2 triangles, is considered a valley-edge if the projection of the 2 normals of the triangles, projected to the $x y$-plane, point to $e$.
If the 2 normals projected point in the opposite direction, then $e$ is a ridge.
If they point in different directions, then $e$ is neither.

== #flex-heading[Properties used in practice][Properties and features used in practice]

=== Slope

The slope (gradient + aspect) are a cornerstone of runoff modelling (see Chapter @chap:runoff), the prediction of the flow and accumulation of water on a terrain.
The slope is used to calculate the flow direction at a given location, which is the direction with the steepest descent at that location.

The slope can also be used to predict the irradiation (from the sun) that a given location at a given day/time would receive.
This is often the input of (local) meteorological models, can be used to optimise the location of solar panels or to predict land surface temperature.

=== Curvature

While curvature is used implicitly to calculate the flow direction in runoff modelling, there are use-cases where the value is useful.
One of them is for the predicting of where snow covering will be.

The values of the curvature can help a practitioners understand and characterise the drainage basins, once extracted from a terrain (see Section @se:drainage_basins).

=== Roughness

The roughness can be used directly as a predictor for the habitats of different species.

The variations in roughness in a terrain can be used to delineate the terrain into geomorphological and geological areas.

=== Hillshading

#index[hillshading]

Hillshading is a technique used to help visualise the relief of a gridded terrain (see @fig:hillshade for an example).
#figure(
  image("figs/hillshade.pdf", width: 100%),
  caption: [#strong[Left]: a DTM visualised with height as a shade of blue. #strong[Right]: when hillshading is applied.],
  placement: none,
) <fig:hillshade>
It involves creating an image that depicts the relative slopes and highlights features such as ridges and valleys; a hillshade does not depict absolute elevation.
This image assumes that the source of light (the sun) is located at a given position (usually North-West).

#box-practice("Why does the sunlight come from the North-West?")[
  The source of the light for hillshading is usually set at the North-West, but in reality the sun is _never_ located there (in the northern hemisphere).
  Why is this a common practice then?
  The main reason is because the human brain usually assumes that the light comes from above when looking at picture.
  Doing so reduces the chances of _relief inversion_, ie when mountains are perceived as valleys, and vice-versa.
  This #link("https://ramblemaps.com/why-does-sunlight-come-from-north")[website] gives a clear example where a valley is interpreted as a mountain ridge by many if the sun is coming from the South.
]

While it would be possible to use advanced computer graphics methods (see @chap:visibility) to compute the shadows created by the terrain surface, in practice most GIS implements a simplified version of it which can be computed very quickly.

Given a regular gridded terrain, hillshading means that each cell gets a value which depicts the variation in tone, from light to dark.
The output of a hillshade operation is thus a regular gridded DTM, usually with the same extent and resolution as the original grid (for convenience).
The values computed for each cell need as input the gradient and the aspect of the terrain.
The formula to compute the hillshade of a given cell $c_"ij"$ differs from software to software, and we present here one (it is used in QGIS and ArcGIS for example, and surely others).
It assumes that the output hillshade value is an integer in the range $[0, 255]$ (8-bit pixel), and that the direction (azimuth) and the height (given as an angle) of the illumination source is known. 
Notice that the position of the sun is relative to the cell, its position thus changes for different cells of a terrain.
#figure(
  image("figs/hillshade-params.png", width: 95%),
  caption: [The 4 parameters necessary to calculate the hillshade at a location (black point on the terrain).],
  placement: none,
) <fig:hillshade-params>
As above and in @fig:hillshade-params, for a cell $c_"ij"$, its gradient is $alpha_"ij"$, its aspect is $theta_"ij"$, the azimuth of the sun is $psi$ (angle clockwise from the north, like the aspect), and the height of the sun is $gamma$ (0 rad is the horizon, $pi/2$ rad is the zenith).

$ "hillshade"_(i j) = 255 dot.op &[(cos(pi/2 - gamma) cos(alpha_(i j))) + \
&(sin(pi/2 - gamma) sin(alpha_(i j)) cos(psi - theta_(i j)))] $


Notice that: (1) all angles need to be radians; (2) if $"hillshade"_"i j" < 0$ then $"hillshade"_"ij" = 0$.

== Notes and comments

The polynomial fitting method for computing the slope is from #citet(<Evans80>) and #citet(<Wood96>).
#citet(<Skidmore89>) carried out a comparison of 6 methods to extract slope from regular gridded DTMs, and concluded that methods using 8 neighbours perform better than those using only 4 or the biggest height difference.
He did not however investigate how the resolution of the grid influences the results.

The formula to calculate the hillshade for one cell in a gridded DTM is from #citet(<Burrough98>), and the ArcGIS manual describes it in detail (#link("https://desktop.arcgis.com/en/arcmap/10.3/tools/spatial-analyst-toolbox/how-hillshade-works.htm")[link]).

Some algorithms have been developed to identify the features forming a DTM: #citet(<Kweon94>) and #citet(<Schneider05>) can identify simple features in DEMs (if they are pre-processed into bilinear patches); and #citet(<Magillo09>) and #citet(<Edelsbrunner01-1>) describe algorithms to perform the same, but directly on TINs.

The algorithm to extract profile and plan curvatures from a TIN is taken from #citet(<VanKreveld97>).

#citet(<Bohner09>) give several concrete examples of the use of terrain properties for climatology applications, and provide details about one method to identify snow covering.

== Exercises

+ What is the missing word? The \_\_\_\_\_\_\_\_\_ is the 2nd derivative of the surface representing the terrain, it represents the rate of change of the gradient.
+ Given a raster, how to identify a valley and a ridge?
+ If we want to compute the slope (gradient + aspect) for the cell at the centre of this $3 times 3$ DTM with the 'finite difference method', what results will we get? \ #image("./figs/slope_grid_question.pdf")
