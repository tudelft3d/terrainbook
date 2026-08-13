#import "../../template.typ": *
#import "@preview/fleck:0.1.0": *

= Extra information about the AHN datasets <app:ahn>

// #minitoc(suboutline(depth: 1, indent: 0pt))

#figure(
  image("./figs/ahn4.png", width: 100%),
  caption: [Classification codes used in the AHN3+AHN4 datasets.],
) <fig:ahn3>

The AHN dataset (_Actueel Hoogtebestand Nederland_ in Dutch, or "actual height of the Netherlands"), 
#note[_Actueel Hoogtebestand Nederland_ (AHN)]
#note[#link("https://www.ahn.nl")]
is a lidar dataset that contains several points per $m^(2)$ and covers entirely the Netherlands.
It is an open dataset.

#note[AHN6 is the current version]
It began in 1997, and its current version is 6 (called AHN6).

The AHN6 dataset uses the "Point Data Record Format 6", see Table @tab:las-record.

LAS v1.4 allows us to store certain extra user-defined attributes, and in AHN4 the following 3 are also stored (but not in other versions):
+ _Amplitude:_ echo signal amplitude [dB] (min: 0; max: 10000)
+ _Reflectance:_ echo signal reflectance [dB] (min: 0; max: 10000)
+ _Deviation:_ pulse shape deviation (min: 0; max: 65535)

The AHN lidar dataset is disseminated in the LAZ format (a compressed version of LAS, see Appendices @sec:lasformat and @sec:lazformat) and uses the LAS classification codes (see Table @tab:las-classes). 
@fig:ahn3 shows all the codes that are used. 
Notice that apart from the pre-defined codes from Table @tab:las-classes, AHN4/5/6 also uses the custom code $26$ for a 'civil structure' (Dutch: _kunstwerk_) class that includes special infrastructures such as bridges, statues, and viaducts.

It should be noticed that in AHN5 the class 6/`building` is for the roofs of the buildings _only_, the façades of a building are in class 1/`unclassified`.
This is in contrast to previous versions, and the current version, in which all points representing a building were classified as 6/`building`.

Observe also that in AHN the points representing vegetation are not classified as such, and vegetation is never explicitly classified.
#note[⚠️ vegetation is classified as $1$/`unclassified`]
This is because the aim of the AHN project is mostly to model dikes and to protect us from floods, and vegetation is not very important for this use-case.
The class $1$ is thus used for vegetation, but other objects such as street furniture (eg lampposts) or cars are also classified as $1$.

Certain tiles contain the classification 14/`high-voltage pylons and cables`, but not all of them. 
// #note[class=14 for pylons+cables (for some tiles only)]
If 14 is not used, the pylons and cables are in class 26/`kunstwerk`.

#coffee-b(where: center + horizon, angle: 95deg, opacity: 50%)
#coffee-d(where: right + bottom, angle: 95deg, opacity: 50%)

#figure(
  table(
    columns: 2,
    // stroke: none,
    // inset: 3pt,
    align: (right,left),
    table.header([Code], [Meaning],),
    table.hline(),
    [0], [never classified],
    [1], [unclassified],
    [2], [ground],
    [3], [low vegetation],
    [4], [medium vegetation],
    [5], [high vegetation],
    [6], [building],
    [7], [low point (noise)],
    [9], [water],
    [14], [high-voltage pylons and cables],
    [26], [civil structure (_kunstwerk_)],
    table.hline(),
  ),
  caption: [The LAS classification codes and their meanings.],
  placement: none,
) <tab:ahn-classes>
