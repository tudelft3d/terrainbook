#import "../template.typ": *

= Cartographic relief representation <chap:relief>

#minitoc(suboutline(depth: 1, indent: 0pt))


// TODO: intro
// - the problem: a terrain is a 2.5D surface, how to depict it on a (2D) map?
// - brief history: hachures -> contour lines -> hillshading (Imhof's Cartographic Relief Presentation)
// - overview of the chapter: contours (and Tanaka maps), hillshading,
//   combining colour and shading


== Contour lines and Tanaka maps <sec:vis-contours>

// TODO:
// - contour lines are the oldest and most used technique; how they are read
//   (closeness = steepness), index vs intermediate contours, labelling
// - the algorithms to *extract* contour lines are covered in @sec:iso
//   (Chapter @chap:conversion); here we focus on how they are *rendered/presented*
// - hypsometric layer tints between contours
// - Tanaka maps (Tanaka 1950): illuminated contours, where the width/style of
//   each contour line varies with the direction of the line relative to the
//   light source; reuses the gradient and aspect from @chap:topofeatures


== Hillshading <sec:vis-hillshading>

#index[hillshading]

Hillshading is a technique used to help visualise the relief of a gridded terrain (see @fig:hillshade for an example).

#place(float: true, bottom,
  wideblock[
    #figure(
      image("figs/hillshade.pdf", width: 100%),
      caption: [#strong[Left]: a DTM visualised with height as a shade of blue. #strong[Right]: when hillshading is applied.],
      placement: auto,
    ) <fig:hillshade>
  ]
)
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

// TODO: possible additions
// - multi-directional hillshading
// - alternatives avoiding relief inversion: sky-view factor / openness,
//   local dominance (ties in with @chap:visibility)


== Combining colour and shading <sec:vis-colour>

// TODO:
// - hypsometric tints: colouring elevations along a ramp; why they are
//   misleading on their own (they encode absolute elevation, not the form)
// - why a hillshade alone lacks height context
// - blending the two: multiplicative hillshade over a coloured DEM, weighted
//   multi-layer compositing (blending modes in GIS software)
// - references: Imhof (1982) Cartographic Relief Presentation;
//   Patterson & Jenny (2011) cross-blended hypsometric tints


== Notes and comments

The formula to calculate the hillshade for one cell in a gridded DTM is from #citet(<Burrough98>), and the ArcGIS manual describes it in detail (#link("https://desktop.arcgis.com/en/arcmap/10.3/tools/spatial-analyst-toolbox/how-hillshade-works.htm")[link]).

// TODO: add notes when sections are written
// - Tanaka 1950 (original, in Japanese) + English translation (Tanaka 1952?)
// - Imhof (1982), Cartographic Relief Presentation
// - Patterson & Jenny (2011), cross-blended hypsometric tints


== Exercises

// TODO: add exercises
+ // TODO
