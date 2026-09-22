#import "../template.typ": *

= Cartographic relief representation <chap:vis>
// Relief visualisation techniques

#minitoc(suboutline(depth: 1, indent: 0pt))

The problem we are tackling in this chapter is how to represent the 3D surface of a terrain on a flat 2D medium (a map or a computer screen) while maintaining both its measurable properties (position, shape, elevation) and its pictorial form (to obtain a legible impression of the relief).
Before computers were mainstream this has occupied cartographers for centuries, who had to _manually_ draw hachures, contours, and shading.

Eduard Imhof's book, _Cartographic Relief Presentation_, first published in German in 1965 and later translated into English, is the classic synthesis of this body of practice, and it remains the reference work on the subject.
#notefigure(
  image("figs/imhof_cover.pdf", width: 100%),
  caption: [Eduard Imhof seminal book.],
  dy:250pt,
) <fig:imhof_cover>
As Imhof states, the main difficulty when creating a map is that we look at the terrain from directly above, a viewing direction that does not help to convey an impression of three dimensions.
Our most effective hint for form and relief is the light: even the smallest undulation of a surface becomes visible when light falls on it at an angle, and this is precisely the effect that most of the techniques in this chapter exploit.
// Notice however that using light as a cue has its risks: the wrong light direction can _invert_ the relief, so that mountains are read as valleys (see @sec:vis-hillshading).

It should be noticed that the topic of this chapter is extremely vast and complex, and for a thorough treatment it would require a whole book (we will not attempt it here; we simply refer the interested reader to the book of Imhof, among others). 
Instead, we provide a short overview of the first attemps at depicting relief on a 2D medium, and then focus on the key techniques that remain central to cartographic practice today.

Nowadays the medium is a computer screen and the images are now computed from a gridded terrain (or a TIN, or a point cloud), but the questions are the same as in Imhof's time: which graphic device, and with which parameters, makes the form of the terrain legible?
// TODO: what about scale? where to put this discussion in this chapter?
The answer also depends on the scale, since a technique that suits a #qty("1", "km")-wide alpine valley is not necessarily suited to a map of a whole country.

Finally, we explain how colour and shading are combined (@sec:vis-colour), which is the recommended way to represent terrain.
The algorithms that produce the underlying data are covered elsewhere---gradient and aspect in @chap:topofeatures, contour extraction in @sec:iso; here we focus on how the result is rendered.


== Perpective views of relief <sec:vis_history>

The oldest maps (from the Middle Ages) showed mountains depicted from the side, as rows of rounded "molehills", which are regularly rounded domes arranged in certain patterns.
Figure @fig:molehills shows three examples taken from Imhof's book. 
#subfigure(
  figure(image("figs/molehill_1.png", width: 100%), caption: []),
  figure(image("figs/molehill_2.png", width: 100%), caption: []),
  figure(image("figs/molehill_3.png", width: 100%), caption: []),
  columns: (1fr, 1fr, 1fr),
  caption: [Early perspective representations showing rows of rounded "molehills" as seen from the side. Figures taken from #citet(<Imhof65>).],
  label: <fig:molehills>,
) 
Notice that the molehills are arranged in a row and are facing the viewer, but that they can also be arranged in other orientations to indicate where the valley is located.

Drawing exactly where the mountains where was not possible because there was neither the need nor the technique to place them correctly in plan.



== Hachures <sec:vis-hachures>

One of the first attempts at representing the shape, the form, and the interactions between mountains (and not depicted with pictorial-like symbols (the molehills)) is the Leonardo da Vinci's map of Tuscany (see @fig:leonardo_tuscany), which shows the mountains as a series of interlocking ridges and valleys viewed from above.
#figure(
  image("figs/davinci_tuscany.jpg", width: 100%),
  caption: [Leonardo da Vinci's map of Tuscany (c. 1502) showing mountains as interlocking ridges and valleys viewed from above.],
  placement: auto,
) <fig:leonardo_tuscany>
Notice that this map is still from a perpective view, but still provides insights into the morphology of the area.

We can observe in da Vinci's map that hachures (short parallel lines) were used to depict slope and shadow.
Hachures #index[hachuring] are usually drawn along the direction of steepest gradient, and their thickness (and thus spacing between adjacent lines) is proportional to the steepness at that location: the steeper, the thicker/darker.
This can be observed in the so-called "Dufour Map" from in 1842 by the Swiss Topographic Bureau.
#index[slope lines]

#figure(
  image("figs/dufour-map.jpg", width: 100%),
  caption: [The Dufour Map (1842) showing slope lines/hachures drawn along the direction of steepest gradient, with thickness proportional to steepness. Figure from #citet(<Imhof65>).],
  placement: auto,
) <fig:dufour_map>

The slope lines/hachures were later refined into _shadow hachures_ that imitate how a surface is lit from a certain direction: thin/white lines on slopes facing the source of light, and thick/black on shaded ones.
#note[slope lines]

It should be mentioned that hachures are no longer used because they require enormous engraving workload, especially for steep terrain where they darken the map (see Da Vinci's map...), and because absolute elevation is not encoded.
Hillshading and contours have replaced those techniques.
Tanaka's illuminated contours, presented below, can be seen as the modern, computational reincarnation of shadow hachures.


== Contour lines  <sec:vis-contours>

// Scale dependence and the warning that technique is a means, not an end.
// The second were the _contour lines_: an abstract but measurable device that encodes elevation in equally spaced lines, and which became the standard for large-scale topographic maps.
// Imhof described this as an imagined "contour blanket" laid over the terrain; we are so accustomed to it that its abstract character is seldom appreciated, and on its own it gives a poor impression of form, so it was soon combined with shading, hachures, and colour.

// - contour lines are the oldest and most used technique; how they are read
//   (closeness = steepness), index vs intermediate contours, labelling
// - only geometric representation (hachures and shading give an impression of relief; 
//   from contours we can reconstruct the shape)
// - the algorithms to *extract* contour lines are covered in @sec:iso
//   (Chapter @chap:conversion); here we focus on how they are *rendered/presented*
// - scale is very important to select the contour interval and stuff in Imhof book




== Hillshading <sec:vis-hillshading>

#index[hillshading]

Hillshading is a technique used to visualise the relief of a gridded terrain.
It involves creating an image that depicts the relative slopes and highlights features such as ridges and valleys; a hillshade does not depict absolute elevation.
It assumes that the source of light (the sun) is located at a given position (usually North-West and at a certain elevation) and that it illuminates the terrain.

Consider the gridded DEM shown in @fig:tasmania_dem_01, which contains a river at low elevation and two peaks.
The resulting hillshade image is shown in @fig:hillshade_nw; this hillshade has the sun located at an azimuth of #qty("315", "deg") (North-West) and an elevation of #qty("45", "deg").
#figure(
  image("figs/hillshade/dem_01_colour.pdf", width: 80%),
  caption: [The terrain of a random region in Tasmania, Australia.],
  placement: auto,
) <fig:tasmania_dem_01>
#subfigure(
  figure(image("figs/hillshade/hillshade_nw.png", width: 100%), caption: [Hillshade with light from North-West]), <fig:hillshade_nw>,
  figure(image("figs/hillshade/hillshade_se.png", width: 100%), caption: [Hillshade with light from South-East]), <fig:hillshade_se>,
  columns: (1fr, 1fr),
  caption: [Hillshade for the terrain from @fig:tasmania_dem_01. Observe how we perceive the same terrain differently when the light comes from different directions, and that in *(b)* we see peaks as valleys. ],
  placement: auto,
  label: <fig:hillshade>,
)



#box-practice("Why does the sunlight come from the North-West?")[
  The source of the light for hillshading, and other techniques using light, is usually set at the North-West, but in reality the sun is _never_ located there (in the northern hemisphere).
  Why is this a common practice then?
  The main reason is because the human brain usually assumes that the light comes from above when looking at picture.
  Doing so reduces the chances of _relief inversion_, ie when mountains are perceived as valleys, and vice-versa.

  Observe that @fig:hillshade_se shows the terrain from @fig:tasmania_dem_01 but with the light coming from the South instead of the North-West, resulting in an inverted perception of the relief.
  // The website #link("https://ramblemaps.com/why-does-sunlight-come-from-north") gives a clear example where a valley is interpreted as a mountain ridge by many if the sun is coming from the South.
]

While it would be possible to use advanced computer graphics methods (see @chap:visibility) to compute the shadows created by the terrain surface, in practice most GIS implements a simplified version of it which can be computed very efficiently.

Given a regular gridded terrain, hillshading means that each cell gets a value which depicts the variation in tone, from light to dark.
The output of a hillshade operation is thus a regular gridded DTM, usually with the same extent and resolution as the original grid (for convenience).
The values computed for each cell need as input the gradient and the aspect of the terrain (see @chap:topofeatures).
The formula to compute the hillshade of a given cell $c_"ij"$ differs from software to software, and we present here one (it is used in QGIS and ArcGIS for example, and surely others).
It assumes that the output hillshade value is an integer in the range $[0, 255]$ (8-bit pixel), and that the direction (azimuth) and the height (given as an angle) of the illumination source is known.
Notice that the position of the sun is relative to the cell, its position thus changes for different cells of a terrain.
As above and in @fig:hillshade-params, for a cell $c_"ij"$, its gradient is $alpha_"ij"$, its aspect is $theta_"ij"$, the azimuth of the sun is $psi$ (angle clockwise from the north, like the aspect), and the height of the sun is $gamma$ (0 rad is the horizon, $pi/2$ rad is the zenith).
#figure(
  image("figs/hillshade-params.svg", width: 100%),
  caption: [The 4 parameters necessary to calculate the hillshade at a location (black point on the terrain).],
  placement: auto,
) <fig:hillshade-params>

$ "hillshade"_(i j) = 255 dot.op &[(cos(pi/2 - gamma) cos(alpha_(i j))) + \
&(sin(pi/2 - gamma) sin(alpha_(i j)) cos(psi - theta_(i j)))] $


Notice that: (1) all angles need to be radians; (2) if $"hillshade"_"i j" < 0$ then $"hillshade"_"ij" = 0$.

=== Multi-directional hillshading

// https://deltares.github.io/Geomorphometry.jl/dev/reference#Geomorphometry.multihillshade-Tuple{AbstractMatrix{%3C:Real}}
// multihillshade is the simulated illumination of a surface based on its slope and aspect. Like hillshade, but combining multiple light sources at the given azimuth angles (degrees) as defined in Mark, R.K. (1992), similar to GDAL's -multidirectional. Returns a Matrix{Union{Missing,UInt8}} of illumination values in 0:255.


// TODO: possible additions
// - alternatives based on diffuse illumination (no single light direction,
//   thus no relief inversion): present the sky-view factor as the main one
//   (it is defined in @sec:svf, Chapter @chap:visibility), and mention
//   openness (average zenith/nadir angles, Yokoyama et al. 2002) in passing.
//   Show the SVF + hillshade combination, which is the recommended one for
//   cartography (Zaksek et al. 2011)



== Combining colour and shading <sec:vis-colour>

// TODO:
// - hypsometric tints: colouring elevations along a ramp; why they are
//   misleading on their own (they encode absolute elevation, not the form)
// - why a hillshade alone lacks height context
// - blending the two: multiplicative hillshade over a coloured DEM, weighted
//   multi-layer compositing (blending modes in GIS software)
// - references: Imhof (1982) Cartographic Relief Presentation;
//   Patterson & Jenny (2011) cross-blended hypsometric tints


== Tanaka contours <sec:tanaka>

imhof calls them "3D shaded contours with flat area tones"

#notefigure(
  image("figs/tanaka_original.png", width: 100%),
  caption: [Tanaka's illuminated contours showing how contour lines vary with their orientation relative to the light source.],
  // placement: auto,
) <fig:tanaka_original>

// - Tanaka maps (Tanaka 1950): illuminated contours, where the width/style of
// - hypsometric layer tints between contours
//   each contour line varies with the direction of the line relative to the
//   light source; reuses the gradient and aspect from @chap:topofeatures



#place(float: true, auto,
  wideblock[
    #figure(
      image("figs/sunlight_direction.pdf", width: 100%),
      caption: [The same map showing how Tanaka contours are illuminated based on their orientation relative to the light source. Notice that the hill looks like a depression when the light comes from the South-East.],
      placement: auto,
    ) <fig:tanaka>
  ]
)

== SVF-based hillshading

// TODO
// it's not with a source of light, but can be considered as having diffuse light
// not affected by the "reverse-effect"

== Notes and comments

The introduction of this chapter---in particular the tension between the measurability and the pictorial representation of relief---draws on #citet(<Imhof65>), which remains the classic reference on the subject.

The formula to calculate the hillshade for one cell in a gridded DTM is from #citet(<Burrough98>), and the ArcGIS manual describes it in detail (#link("https://desktop.arcgis.com/en/arcmap/10.3/tools/spatial-analyst-toolbox/how-hillshade-works.htm")[link]).

The sky-view factor was proposed as a relief visualisation technique by #citet(<Zaksek11>), where the formula given above and the influence of the parameters (number of directions, search radius) on the results are discussed in detail.
The paper also describes its use for spatial analysis, eg for energy balance studies and to estimate the availability of GPS signals in urban areas.
// A closely related measure is the _openness_ of #citet(<Yokoyama02>), where instead of the solid angle of the visible sky, the zenith angles of the horizon are averaged (positive openness), or the nadir angles below the surface (negative openness).
// Free and open-source implementations of both, together with several other techniques to visualise high-resolution DTMs, are available in the Relief Visualization Toolbox (#link("https://rvt-py.readthedocs.io/")).


// TODO: add notes when sections are written
// - Tanaka 1950 (original, in Japanese) + English translation (Tanaka 1952?)
// - Imhof (1982), Cartographic Relief Presentation
// - Patterson & Jenny (2011), cross-blended hypsometric tints

// - Yoeli 1985, Topographic relief depiction by hachures with computer and
//   plotter, Cartographic Journal 22(2): 111-124, doi:10.1179/caj.1985.22.2.111
//   (first computer algorithm; works from contour lines -> backward pointer
//   to @sec:iso)
// - Kennelly & Kimerling 2000, Desktop hachure maps from digital elevation
//   models, Cartographic Perspectives 37, doi:10.14714/cp37.811 (small-scale
//   illuminated hachures from DEM slope/aspect; explicitly Tanaka-like)
// - Automated Swiss-style relief shading and rock hachuring (2018),
//   Cartographic Journal, doi:10.1080/00087041.2018.1551955





== Exercises

// TODO: add exercises
