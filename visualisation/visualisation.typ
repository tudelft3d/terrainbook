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

Contour lines, also called isolines, are the most important element for the representation of elevation of an area, and they are the only method in this chapter that allows us to _geometrically_ reconstruct the shape of the terrain (with some loss of detail, as explained in @sec:representation_others and @sec:iso.

The algorithms to extract contour lines from a terrain are described in  @sec:r-iso (for regular grids) and @sec:tin-iso (for TINs); these algorithms identify the locations where the terrain reaches specific elevation levels.
In this section, we focus on how the extracted contours are rendered and depicted.

Spacing between contours (contour interval) #index[contour interval]#note[contour interval] is the vertical distance between successive contour lines. 
This parameter controls the density of the contour network and determines how much detail is visible in the map. 
Observe that this parameter is crucial for balancing detail against legibility and that scale affects it directly.
If we draw contour lines with a width of #qty("0.5", "mm"), then this value will be used for all the scales. At very small scales (eg #num("1"):#num("100000")) the contour interval must be chosen such that the line spacing remains legible at the given scale.
One usually chooses a contour interval that is a multiple of 10, 20, or 50 meters, depending on the terrain and the map's scale, and based on the terrain's general relief: very steep slopes (eg alpine regions with gradients up to potentially #qty("45", "deg")) will require larger intervals to maintain legibility.  

// Scale is crucial: it determines the physical size of the map relative to the terrain extent, and it directly influences the choice of contour interval. A small scale (large map) can accommodate fine contour intervals without clutter, whereas a large scale (small map) requires coarser intervals to maintain readability.
// - scale is very important to select the contour interval and stuff in Imhof book
#subfigure(
  figure(image("figs/interval_10.pdf", width: 100%), caption: [contour interval = #qty("10", "m")]),
  figure(image("figs/interval_100.pdf", width: 100%), caption: [contour interval = #qty("100", "m")]),
  columns: (1fr, 1fr),
  caption: [Comparison of contour intervals showing how increasing the spacing from #qty("10", "m") to #qty("100", "m") increases visual clutter.],
  placement: auto,
  label: <fig:contour_interval_comparison>,
) 

A smaller interval reveals more detail but increases visual clutter, while a larger interval provides a cleaner, more general view of the terrain.

We want the smallest possible contour interval (a more accurate representation of the terrain), but the map needs to remain legible.

//

==== Index contours
To improve the legibility of a map with contour lines, we can emphasise some lines, eg every 5th or 10th line by using a thicker line.
This is called an index contour and one example is shown in @fig:contour_index.
#figure(
  image("figs/contourindex.pdf", width: 100%),
  caption: [For the same region as @fig:contour_interval_comparison, with a contour interval of #qty("20", "m"), and with every 5th contour emphasized in bold.],
  placement: auto,
) <fig:contour_index>


==== Intermediate contours
The steepest slopes in an area can dictate the contour interval, but in areas where the terrain is relatively flat, the spacing between index contours becomes too large and detail is lost.
For those areas, intermediate contours can be added. 
As shown in @fig:contour_intermediate, these are typically drawn with a dashed line to distinguish them from the solid index contours.
#figure(
  image("figs/contourintemediate.pdf", width: 100%),
    caption: [With a contour interval of #qty("20", "m") we can add intermediate contours between the index contours where the terrain is relatively flat, here some lines manually picked shown with a dashed line.],
  placement: auto,
) <fig:index_intermediate>


==== Labelling
Notice that for @fig:contour_index and @fig:contour_intermediate the labels for the contours (only for the indexed ones) are oriented towards the reader of the map (upright position mostly; this was performed automatically with QGIS). 

However, elevation labels orientated to the direction of the slope---where higher ground is above the label---improves the legibility of the map (see @fig:contour_orientation).
#subfigure(
  figure(image("figs/c_orientation_1.pdf", width: 100%), caption: [Higher ground above label]),
  figure(image("figs/c_orientation_2.pdf", width: 100%), caption: [Random orientation]),
  columns: (1fr, 1fr),
  caption: [Contour labelling orientation.],
  placement: auto,
  label: <fig:contour_orientation>,
) 


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
  caption: [Two hillshades for the terrain from @fig:tasmania_dem_01. Observe how we perceive the same terrain differently when the light comes from different directions: in *(a)* we preceive mountains, and in *(b)* we see peaks as valleys and the water appears at higher altitude. ],
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

When using hillshading only one source of light is used to illuminate the terrain, and this can remove structures in the terrain and create a "flat" appearance.

Multi-directional hillshading combines multiple light sources at different angles to illuminate the terrain, and then combining the resulting images to produce a final output. 

The resulting image will have a more dynamic and three-dimensional appearance, with shadows and highlights that are more accurately represented; @fig:multi_hillshade shows an example.

The standard is that of Robert Mark from his 1992 paper: 4 sources are used (azimuth at #qty("225", "deg"), #qty("270", "deg"), #qty("315", "deg"), and #qty("360", "deg")) #note[GDAL and QGIS use the same 4 angles] with the height of the sun ($gamma$) constant at #qty("30", "deg"). 
The weights to apply to each of the 4 hillshades are per pixel, and are linked to the aspect of the pixel.  

#place(float: true, auto,
  wideblock[
    #subfigure(
      figure(image("figs/hillshade/hillshade_nw.png", width: 100%), caption: [Hillshade with light from North-West]),
      figure(image("figs/hillshade/multi_hillshade.png", width: 100%), caption: [Multi-directional hillshade]), 
      columns: (1fr, 1fr),
      caption: [Example of multi-directional hillshade for the terrain shown in @fig:tasmania_dem_01.],
      placement: auto,
      label: <fig:multi_hillshade>,
    )
  ]
)





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

The so-called "Tanaka contours", named after the cartographer Kitirô Tanaka who formalised the concept in 1950, is a visualisation method that (1) shades contour lines and (2) uses flat area tones to give a better impression of the relief of a terrain. 
@fig:tanaka_original shows a figure from the original paper, and the cover of this book shows the same technique applied to an terrain somewhere in Tasmania (Australia).
#notefigure(
  image("figs/tanaka_original.png", width: 100%),
  caption: [Tanaka's illuminated contours showing how contour lines vary with their orientation relative to the light source.],
  // placement: auto,
) <fig:tanaka_original>

For the illumination, the source of light is usually located at the North-West direction.
The lines are white when facing the source of light (slopes that are illuminated), and black when located on the opposite side of a hill/obstacle (shadow).
In between the lines appear in intermediate shades of grey; the shade of grey is defined by linear interpolation between white and black based on the angle between the line and the light direction.

Observe that when extracting contour lines from a terrain (see @sec:iso), one needs to correctly determine the orientation of the line to avoid 'inverting the relief' (notice that this is determined by the aspect of the slope, see @sec:slope).
One way to do this is to always orient a segment of a contour lines such that higher ground is always on the left of a line (or right, it just depends on the convention).

The horizontal areas between contour lines (which are considered flat) are filled with a uniform tone/colour, and the colour can be chosen by using a discrete colour map for each value of the contour interval.

The original method applies a different thickness to the lines so that where white and black lines meet, there is only a point of contact (or a smaller area of contact).
This can be observed from the Tanaka contours on the cover of Imhof's book (see @fig:imhof_cover).
// This can be obtained by several methods, one of them being drawing twice: first in light grey for the illuminated side, then in dark grey for the shadowed side, with the widths determined by the angle between the line and the light direction.

// ([more information on Wikipedia](https://en.wikipedia.org/wiki/Terrain_cartography#Tanaka_(relief)_contours)).
// #place(float: true, auto,
//   wideblock[
//     #figure(
//       image("figs/sunlight_direction.pdf", width: 100%),
//       caption: [The same map showing how Tanaka contours are illuminated based on their orientation relative to the light source. Notice that the hill looks like a depression when the light comes from the South-East.],
//       placement: auto,
//     ) <fig:tanaka>
//   ]
// )

== SVF-based hillshading

// TODO
// it's not with a source of light, but can be considered as having diffuse light
// not affected by the "reverse-effect"

== Notes and comments

The introduction of this chapter---in particular the tension between the measurability and the pictorial representation of relief---draws on #citet(<Imhof65>), which remains the classic reference on the subject.

The formula to calculate the hillshade for one cell in a gridded DTM is from #citet(<Burrough98>), and the ArcGIS manual describes it in detail (#link("https://desktop.arcgis.com/en/arcmap/10.3/tools/spatial-analyst-toolbox/how-hillshade-works.htm")[link]).

For the multi-directional hillshade, the 4 sources of light and the weights to apply to each hillshade is from #citet(<Mark92>).

The sky-view factor was proposed as a relief visualisation technique by #citet(<Zaksek11>), where the formula given above and the influence of the parameters (number of directions, search radius) on the results are discussed in detail.
The paper also describes its use for spatial analysis, eg for energy balance studies and to estimate the availability of GPS signals in urban areas.
// A closely related measure is the _openness_ of #citet(<Yokoyama02>), where instead of the solid angle of the visible sky, the zenith angles of the horizon are averaged (positive openness), or the nadir angles below the surface (negative openness).
// Free and open-source implementations of both, together with several other techniques to visualise high-resolution DTMs, are available in the Relief Visualization Toolbox (#link("https://rvt-py.readthedocs.io/")).


// TODO: add notes when sections are written
// - Tanaka 1950 (original, in Japanese) + English translation (Tanaka 1952?) (see the [original paper](https://doi.org/10.2307/211219))
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

+ For creating the Tanaka contours, it is mentioned that segments should be oriented such that higher ground is always on the left of a line. Does this mean that lines are always oriented counter-clockwise? 
// +
