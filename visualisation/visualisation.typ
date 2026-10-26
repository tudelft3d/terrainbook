#import "../template.typ": *

= Cartographic relief representation <chap:vis>
// Relief visualisation techniques

#minitoc(suboutline(depth: 1, indent: 0pt))

The main problem we are tackling in this chapter is how to represent the 3D surface of a terrain on a flat 2D medium (a map or a computer screen) while maintaining both its _measurable properties_ (position and shape of the hills/mountains and their elevation) and its _pictorial form_ (to obtain a legible impression of the relief).
Before computers were mainstream, this had occupied cartographers for centuries, who had to _manually_ draw hachures, contours, and shading.

Eduard Imhof's book, _Cartographic Relief Presentation_, first published in German in 1965 and later translated into English, is the classic synthesis of this body of practice, and it remains the reference work on the subject.
As Imhof states, the main difficulty when creating a map is that we look at the terrain from directly above, a viewing direction that does not help to convey an impression of three dimensions.
Our most effective hint for form and relief is the _light_#note[light is used to see form]: even the smallest undulation of a surface becomes visible when light falls on it at a specific angle, and this is precisely the effect that most of the techniques in this chapter exploit.
#notefigure(
  image("figs/imhof_cover.jpg", width: 100%),
  caption: [Eduard Imhof's seminal book.],
  dy:250pt,
) <fig:imhof_cover>
// Notice however that using light as a cue has its risks: the wrong light direction can _invert_ the relief, so that mountains are read as valleys (see @sec:vis-hillshading).

// Note that the topic of this chapter is extremely vast and complex, and for a thorough treatment it would require a whole book (we will not attempt it here; we simply refer the interested reader to the book of Imhof, among others).
// Instead, we provide a short overview of the first attempts at depicting relief on a 2D medium, and then focus on the key techniques that remain central to cartographic practice today.

Nowadays the medium is a computer screen and the images are computed from a gridded terrain (or a TIN, or a point cloud), but the questions are the same as in Imhof's time: which graphic device, and with which parameters, makes the form of the terrain legible?
In this chapter, we also explain how colour and shading are combined (@sec:vis-colour), which is the recommended way to represent terrain.
The algorithms that produce the underlying data are covered elsewhere---gradient and aspect in @chap:topofeatures, contour extraction in @sec:iso; here we focus on how the result is rendered.

Observe that the depiction of terrains is highly _scale-dependent_, since a technique that suits a #qty("1", "km")-wide alpine valley is not necessarily suited to a map of a whole country.


== Perspective views of relief <sec:vis_history>

The oldest maps (from the Middle Ages) showed mountains depicted from the side, as rows of rounded "molehills"—regular domes arranged in certain patterns.
@fig:molehills shows three examples taken from Imhof's book. 
#subfigure(
  figure(image("figs/molehill_1.png", width: 100%), caption: []),
  figure(image("figs/molehill_2.png", width: 100%), caption: []),
  figure(image("figs/molehill_3.png", width: 100%), caption: []),
  columns: (1fr, 1fr, 1fr),
  caption: [Early perspective representations showing rows of rounded "molehills" as seen from the side. Figures from #citet(<Imhof65>).],
  label: <fig:molehills>,
) 
Notice that the molehills are arranged in a row and are facing the viewer, but that they can also be arranged in other orientations to indicate where the valley is located.

Drawing exactly where the mountains were was not possible because there was neither the need nor the technique to place them correctly on the map.



== Hachures <sec:vis-hachures>

Leonardo da Vinci's map of Tuscany (see @fig:leonardo_tuscany) represents one of the first attempts at depicting the shape, form, and interactions between mountains---rather than using pictorial symbols like the molehills---showing them as a series of interlocking ridges and valleys viewed from above.
#figure(
  image("figs/davinci_tuscany.jpg", width: 100%),
  caption: [Leonardo da Vinci's map of Tuscany (c. 1502) showing mountains as interlocking ridges and valleys viewed from above.],
  placement: auto,
) <fig:leonardo_tuscany>
Notice that this map is still drawn in perspective, but it provides insights into the morphology of the area.

We can observe in Leonardo da Vinci's map that hachures (short parallel lines) were used to depict slope and shadow.
#index[hachures]#note[hachures follow direction of steepest slope] Hachures are usually drawn along the direction of steepest gradient, and their thickness (and thus spacing between adjacent lines) is proportional to the steepness at that location: the steeper the slope, the thicker and darker the lines.
This can be observed in the so-called "Dufour Map" (published 1845--1864) by the Swiss Topographic Bureau.
#index[slope lines]

#figure(
  image("figs/dufour-map.jpg", width: 100%),
  caption: [The Dufour Map (1845--1864) showing slope lines/hachures drawn along the direction of steepest gradient, with thickness proportional to steepness. Figure from #citet(<Imhof65>).],
  placement: auto,
) <fig:dufour_map>

The slope lines/hachures were later refined into _shadow hachures_ that imitate how a surface is lit from a certain direction: thin/white lines on slopes facing the source of light, and thick/black on shaded ones.
#note[slope lines]

It should be mentioned that hachures are no longer used because they require an enormous engraving workload, especially for steep terrain where they darken the map (see @fig:leonardo_tuscany), and because absolute elevation is not encoded.
Hillshading and contours have replaced these techniques; see below.
// Tanaka's illuminated contours, presented below, can be seen as the modern, computational reincarnation of shadow hachures.


== Contour lines  <sec:vis-contours>

Contour lines, also called isolines, are the most important element for the representation of elevation of an area, and they are the only method in this chapter that allows us to _geometrically_ reconstruct the shape of the terrain (albeit with some loss of detail, as explained in @sec:representation_others and @sec:iso).

The algorithms to extract contour lines from a terrain are described in @sec:r-iso (for regular grids) and @sec:tin-iso (for TINs); these algorithms identify the locations where the terrain reaches specific elevation levels.
In this section, we focus on how the extracted contours should be rendered and depicted.

The spacing between contours, called the _contour interval_#index[contour interval]#note[contour interval], is the vertical distance between successive contour lines. 
This parameter controls the density of the contour network and determines how much detail is visible in the map. 
Observe that this parameter is crucial for balancing detail against legibility and that scale affects it directly.
If we draw contour lines with a width of #qty("0.5", "mm"), then this width will be used at all scales. At very small scales (eg #num("1"):#num("100000")) the contour interval must be chosen such that the line spacing remains legible at the given scale.
One usually chooses a contour interval that is a multiple of 10, 20, or 50 metres, depending on the terrain and the map's scale, and based on the terrain's general relief: very steep slopes (eg alpine regions with gradients up to potentially #qty("45", "deg")) will require larger intervals to maintain legibility.

// Scale is crucial: it determines the physical size of the map relative to the terrain extent, and it directly influences the choice of contour interval. A small scale (large map) can accommodate fine contour intervals without clutter, whereas a large scale (small map) requires coarser intervals to maintain readability.
// - scale is very important to select the contour interval and stuff in Imhof book
#place(float: true, auto,
  wideblock[
    #subfigure(
      figure(image("figs/interval_10.pdf", width: 100%), caption: [contour interval = #qty("10", "m")]),
      figure(image("figs/interval_100.pdf", width: 100%), caption: [contour interval = #qty("100", "m")]),
      columns: (1fr, 1fr),
      caption: [Comparison of contour intervals showing how increasing the spacing from #qty("10", "m") to #qty("100", "m") decreases visual clutter.],
      placement: auto,
      label: <fig:contour_interval_comparison>,
    ) 
  ]
)

A smaller interval reveals more detail but increases visual clutter, while a larger interval provides a cleaner, more general view of the terrain.

In practice we want the smallest possible contour interval (a more accurate representation of the terrain), but the map needs to remain legible.


==== Index contours
To improve the legibility of a map with contour lines, we can emphasise some lines, eg every 5th or 10th line by using a thicker line.
This is called an index contour and one example is shown in @fig:contour_index.
#figure(
  image("figs/contourindex.pdf", width: 100%),
  caption: [For the same region as @fig:contour_interval_comparison, with a contour interval of #qty("20", "m"), and with every 5th contour emphasised in bold.],
  placement: auto,
) <fig:contour_index>


==== Intermediate contours
The steepest slopes in an area can dictate the contour interval, but in areas where the terrain is relatively flat, the spacing between index contours becomes too large and detail is lost.
For those areas, intermediate contours can be added. 
As shown in @fig:contour_intermediate, these are typically drawn with a dashed line to distinguish them from the solid index contours.
#figure(
  image("figs/contourintemediate.png", width: 100%),
    caption: [With a contour interval of #qty("20", "m") we can add intermediate contours between the index contours where the terrain is relatively flat, here some manually picked lines are shown with a dashed line.],
  placement: auto,
) <fig:contour_intermediate>


==== Labelling
Notice that for @fig:contour_index, the labels for the contours (only for the indexed ones) are mostly oriented towards the reader of the map (upright position mostly; this was performed automatically with QGIS).

However, elevation labels oriented to the direction of the slope---where higher ground is above the label---improve the legibility of the map (see @fig:contour_orientation).
#figure(
  image("figs/c_orientation.pdf", width: 100%),
  caption: [Contour labelling orientation with higher ground above label.],
  placement: auto,
) <fig:contour_orientation>


== Hillshading <sec:vis-hillshading>

#index[hillshading]

Hillshading is a technique used to visualise the relief of a (gridded) terrain.
It involves creating an image that depicts the relative slopes and highlights features such as ridges and valleys; a hillshade does not depict absolute elevation.
It assumes that the source of light (the sun) is located at a given position (usually North-West and at a certain elevation) and illuminates the terrain.

Consider the gridded terrain shown in @fig:tasmania_dem_01, which contains a river at low elevation and two peaks.
The resulting hillshade image is shown in @fig:hillshade_nw; this hillshade has the sun located at an azimuth of #qty("315", "deg") (North-West) and an elevation of #qty("45", "deg").
#figure(
  image("figs/hillshade/dem_01_colour.jpg", width: 80%),
  caption: [The terrain of a random region in Tasmania, Australia.],
  placement: auto,
) <fig:tasmania_dem_01>


#subfigure(
  figure(image("figs/hillshade/hillshade_nw.png", width: 100%), caption: [Hillshade with light from North-West (#sym.arrow.br)]), <fig:hillshade_nw>,
  figure(image("figs/hillshade/hillshade_se.png", width: 100%), caption: [Hillshade with light from South-East (#sym.arrow.tl)]), <fig:hillshade_se>,
  columns: (1fr, 1fr),
  caption: [Two hillshades for the terrain from @fig:tasmania_dem_01. Observe how the same terrain is perceived differently when the light comes from different directions: in *(a)* we perceive mountains, and in *(b)* we see peaks as valleys and the water appears at higher altitude.],
  placement: auto,
  label: <fig:hillshade>,
)



#box-practice("Why does the sunlight come from the North-West?")[
  The source of the light for hillshading, and other techniques using light, is usually set at the North-West, but in reality the sun is _never_ located there (at least in the northern hemisphere...).
  Why is this a common practice then?
  The main reason is that the human brain usually assumes that the light comes from above when looking at a picture.
  Doing so reduces the chances of _relief inversion_, ie when mountains are perceived as valleys, and vice-versa.

  Observe that @fig:hillshade_se shows the terrain from @fig:tasmania_dem_01 but with the light coming from the South-East instead of the North-West, resulting in an inverted perception of the relief.
  // The website #link("https://ramblemaps.com/why-does-sunlight-come-from-north") gives a clear example where a valley is interpreted as a mountain ridge by many if the sun is coming from the South.
]

While it would be possible to use advanced computer graphics methods (see @chap:visibility) to compute the shadows created by the terrain surface, in practice most GIS software implements a simplified version of it which can be computed very efficiently.

Given a regular gridded terrain, hillshading means that each cell gets a value that depicts the variation in tone, from light to dark.
The output of a hillshade operation is thus a regular gridded terrain, usually with the same extent and resolution as the original grid (for convenience).
The value computed for each cell requires as input the gradient and the aspect of the terrain (see @chap:topofeatures).
The formula to compute the hillshade of a given cell $c_"ij"$ differs from software to software, and we present here one (it is used in QGIS and ArcGIS for example, among others).
It assumes that the output hillshade value is an integer in the range $[0, 255]$ (8-bit pixel), and that the direction (azimuth) and the height (given as an angle) of the illumination source are known.
Notice that the position of the sun is relative to the cell, its position thus changes for different cells of a terrain.
As above and in @fig:hillshade-params, for a cell $c_"ij"$, its gradient is $alpha_"ij"$, its aspect is $theta_"ij"$, the azimuth of the sun is $psi$ (angle clockwise from the north, like the aspect), and the height of the sun is $gamma$ ($0$ rad is the horizon, $pi/2$ rad is the zenith).
#figure(
  image("figs/hillshade-params.svg", width: 100%),
  caption: [The 4 parameters necessary to calculate the hillshade at a location (black point on the terrain).],
  placement: auto,
) <fig:hillshade-params>

$ "hillshade"_(i j) = 255 dot.op &[(cos(pi/2 - gamma) cos(alpha_(i j))) + \
&(sin(pi/2 - gamma) sin(alpha_(i j)) cos(psi - theta_(i j)))] $ <eq:hillshade>

Notice that: (1) all angles need to be in radians; (2) if $"hillshade"_"i j" < 0$ then $"hillshade"_"ij" = 0$.

=== Multi-directional hillshading

When using @eq:hillshade for hillshading, only one source of light is used to illuminate the terrain, and this can obscure features in the terrain and create a "flat" appearance.

Multi-directional hillshading combines multiple light sources at different angles to illuminate the terrain, and then combines the resulting images to produce a final output.

The resulting image will have a more dynamic and three-dimensional appearance, with shadows and highlights that are more accurately represented; @fig:multi_hillshade shows an example.

Robert Mark's 1992 paper proposes a standard: 4 sources are used (azimuths at #qty("225", "deg"), #qty("270", "deg"), #qty("315", "deg"), and #qty("360", "deg")) #note[GDAL (and QGIS) uses the same 4 angles] with the height of the sun ($gamma$) constant at #qty("30", "deg").
The weights to apply to each of the 4 hillshades are per pixel, and are linked to the aspect of the pixel.  

#place(float: true, auto,
  wideblock[
    #subfigure(
      figure(image("figs/hillshade/hillshade_nw.png", width: 100%), caption: [Hillshade with single light source (NW)]),
      figure(image("figs/hillshade/multi_hillshade.png", width: 100%), caption: [Multi-directional hillshade]), 
      columns: (1fr, 1fr),
      caption: [Example of multi-directional hillshade for the terrain shown in @fig:tasmania_dem_01.],
      placement: auto,
      label: <fig:multi_hillshade>,
    )
  ]
)


== #flex-heading[Colour + shading][Combining colour and shading] <sec:vis-colour>

Notice that hillshade and shading give a sense of form, but not of the exact elevation: two flat areas at different elevations will look identical.
Therefore, they are not sufficient to represent terrain.

#figure(
  image("figs/colour_ramps.svg", width: 100%),
  caption: [Three widely used colour ramps for colouring terrains.],
  placement: auto,
) <fig:colour_ramps>

Elevation colouring, also called _hypsometric tints_#index[hypsometric tints]#note[hypsometric tints], on the other hand, gives a sense of absolute elevation but not of form.
It assigns a colour to elevation bands along a ramp (either continuous or discrete), and every pixel gets its colour purely from its $z$-value (absolute elevation). 
@fig:colour_ramps shows three widely used ramps:
/ Natural Earth tones: green for lowlands, yellow/brown for hills, white for snow-capped peaks (as used in @fig:tasmania_dem_01). It has the advantage of being immediately legible by everyone; the lightness progression is good, and summits are easily identifiable. A major drawback in practice is that many people misread elevation colours as climate or vegetation information.
/ Viridis: a perceptually uniform colour ramp where every equal elevation jump looks like an equally-sized colour change. Furthermore, it is robust for colourblind and greyscale printing. This is the default in many (generic, not GIS-related) visualisation libraries (such as `matplotlib`). However, for depicting terrains, it has drawbacks: the dark purple used for low elevation can be misread as "deep/sea", and its strong saturation can compete with a hillshade underneath.
/ Imhof's Swiss tints: developed to sit under shading and to exploit the "near = bright, far = hazy" aerial-perspective cue, which viridis ignores entirely. Forest green $->$ meadow $->$ sand $->$ rock brown $->$ snow. It is a classic scheme for topographic maps.

As a rule of thumb: viridis is probably best for analysis (if one is measuring elevations) and Imhof-style for presenting maps.

==== Combination with hillshading
If used alone, hypsometric tints are flat within each band, and therefore one does not perceive form inside one step of the band (this is clearly visible in @fig:tasmania_dem_01).
The combination of the two is arguably the best way to represent terrain so that both its form and the elevation are clear.
@fig:hillshade_colours shows the same terrain with the same hypsometric tints, but with a hillshade applied.
Observe that with this one can get both an idea of the absolute elevation and of the morphology of the area.

#place(float: true, auto,
  wideblock[
    #subfigure(
      figure(image("figs/hillshade/dem_01_colour_hillshade.jpg", width: 100%), caption: [Natural Earth tones]), 
      figure(image("figs/hillshade/dem_01_imhof_hillshade.jpg", width: 100%), caption: [Imhof's tints]), 
      columns: (1fr, 1fr),
      caption: [Hillshades, combined with two colour ramps, applied to @fig:tasmania_dem_01.],
      placement: auto,
      label: <fig:hillshade_colours>,
    )
  ]
)

These were obtained by applying a transparency of ~60% to the coloured terrain, which is overlaid on a simple greyscale hillshade.
But other methods exist, for instance where the colour of the ramp is multiplied (darkened) by the value of the hillshade.
This way, the colour (which represents the elevation) stays the same, but its lightness is modified by the value of the hillshade (so the form of the terrain is visible).


// #pagebreak()
== Tanaka contours <sec:tanaka>

The so-called "Tanaka contours", named after the cartographer Kitirô Tanaka who formalised the concept in 1950, is a visualisation method that (1) shades contour lines and (2) uses flat area tones to give a better impression of the relief of a terrain. 
@fig:tanaka_original shows a figure from the original paper, and the cover of this book shows the same technique applied to an actual area somewhere in Tasmania (Australia).
#notefigure(
  image("figs/tanaka_original.png", width: 100%),
  caption: [Tanaka's illuminated contours showing how contour lines vary with their orientation relative to the light source. Figure from #citet(<Imhof65>).],
  placement: auto,
) <fig:tanaka_original>

For the illumination, the source of light is usually located in the North-West direction.
The lines are white when facing the source of light (slopes that are illuminated), and black when located on the opposite side of a hill/obstacle (shadow).
In between these two extremes, the lines appear in intermediate shades of grey; the shade of grey is defined by linear interpolation between white and black based on the angle between the line and the light direction.

Observe that when extracting contour lines from a terrain (see @sec:iso), one needs to correctly determine the orientation of the line to avoid "inverting the relief" (notice that this is determined by the aspect of the slope, see @sec:slope).
One way to do this is to always orient a segment of a contour line such that higher ground is always on the left of a line (or right, it just depends on the convention).

The horizontal areas between contour lines (which are considered flat) are filled with a uniform tone/colour, and the colour can be chosen by using a discrete colour map for each value of the contour interval.

The original method applies a different thickness to the lines so that where white and black lines meet, there is only a point of contact (or a smaller area of contact).
This can be observed from the Tanaka contours on the cover of Imhof's book (see @fig:imhof_cover).
// This can be obtained by several methods, one of them being drawing twice: first in light grey for the illuminated side, then in dark grey for the shadowed side, with the widths determined by the angle between the line and the light direction.


== SVF-based hillshading <sec:vis-svf>

The hillshading techniques presented above rely on _direct_ illumination: one (or a few) light source(s).
An alternative is to use _diffuse_ illumination: instead of lighting the terrain from a few directions, or from a single direction, we consider a hypothetical light source that illuminates the entire sky hemisphere uniformly---as on a completely overcast day.
The brightness of a location is then given by the portion of the sky that it sees, which is precisely the sky-view factor as defined in @sec:svf.
A location on a ridge or on a plateau sees most of the sky and is rendered bright, while the bottom of a deep valley sees almost none and is rendered dark.

// Figure generated with visualisation/figs/hillshade/svf_dem.py
#place(float: true, auto,
  wideblock[
    #subfigure(
      figure(image("figs/hillshade/dem_01_svf.jpg", width: 100%), caption: [SVF visualisation]),
      figure(image("figs/hillshade/dem_01_svf_hillshade.jpg", width: 100%), caption: [SVF combined with the hillshade]),
      columns: (1fr, 1fr),
      caption: [SVF-based hillshading of the terrain from @fig:tasmania_dem_01, computed with $n = 16$ directions and a search radius $R = #qty("1", "km")$: *(a)* the SVF alone---the enclosed valleys are the darkest, and the flat cells (the river and the plateau) the brightest since nothing obstructs the sky there; *(b)* the SVF drawn as a semi-transparent layer over the hillshade from @fig:hillshade.],
      placement: auto,
      label: <fig:svf-hillshade>,
    )
  ]
)

@fig:svf-hillshade shows the technique for the terrain from @fig:tasmania_dem_01.
The main drawback of the technique is that the result tells us less about the shape of the slope.
The two techniques are therefore complementary, and it is recommended to combine them, eg by drawing the SVF as a semi-transparent layer over the hillshade; this enhances the legibility of the relief and is especially suitable for cartographic purposes.


== Notes and comments

The introduction of this chapter---in particular the tension between the measurability and the pictorial representation of relief---is heavily inspired by #citet(<Imhof65>), which remains the classic reference on the subject.

The formula to calculate the hillshade for one cell in a gridded DTM is from #citet(<Burrough98>), and the ArcGIS manual describes it in detail (see #link("https://desktop.arcgis.com/en/arcmap/10.3/tools/spatial-analyst-toolbox/how-hillshade-works.htm")).

For the multi-directional hillshade, the 4 sources of light and the weights to apply to each hillshade are from #citet(<Mark92>).

The sky-view factor was proposed as a relief visualisation technique by #citet(<Zaksek11>), where the formula (given in @sec:svf) and the influence of the parameters (number of directions, search radius) on the results are discussed in detail.
The paper also describes its use for spatial analysis, eg for energy balance studies and to estimate the availability of GPS signals in urban areas.
// Free and open-source implementations of both, together with several other techniques to visualise high-resolution DTMs, are available in the Relief Visualization Toolbox (#link("https://rvt-py.readthedocs.io/")).

#citet(<Patterson11>) propose a method to properly blend the hypsometric tints with a hillshade and avoid the confusion with land cover.
Their lowland colours vary with climate/vegetation (olives/greens in humid regions, tans in arid ones) while highlands go to browns/whites.

== Exercises

+ Explain why hachures encode the same information as a hillshade: which terrain property determines the direction of a hachure, and which one determines its thickness? 
+ A map at a scale of 1:#num("50000") shows a slope of #qty("20", "deg"). If the contour interval is #qty("20", "m"), what is the horizontal distance between 2 successive contour lines on the map (in mm)? Is the map still legible, knowing that the contour lines themselves are #qty("0.5", "mm") wide? (1 mm on the map corresponds to #qty("50", "m") on the ground.)
+ In @eq:hillshade, show that a flat cell is rendered as $255 sin gamma$. What is the hillshade value of a flat cell when the sun is at an elevation of #qty("45", "deg")? And what happens to the image when the sun is at the zenith ($gamma = pi/2$)? Explain why a light source at an angle, and not a vertical one, is used to reveal the form of the terrain.
+ Look at @fig:svf-hillshade. (a) Why are the flat areas (the river and the plateau) the brightest cells in the SVF image? (b) The SVF was computed with $n = 16$ directions and a search radius $R = #qty("1", "km")$. What would change in the image if $R$ were reduced to #qty("100", "m")? And if $n$ were reduced to 4?
+ When creating the Tanaka contours, it is mentioned that segments should be oriented such that higher ground is always on the left of a line. Does this mean that lines are always oriented counter-clockwise?
