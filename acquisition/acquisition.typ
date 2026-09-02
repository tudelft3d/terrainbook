#import "../template.typ": *

= Acquisition of elevation measurements <chap:acquisition>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/_BSuNu3Ahw0")

The very first step in the process of terrain modelling is the acquisition of elevation measurements. 
Nowadays, these measurements are usually collected in large quantities using some form of remote sensing, ie sensors that measure---in our case---the distance to the Earth's surface from an airborne or even a spaceborne platform. 
In raw form, elevation measurements are typically stored as a point cloud, ie a collection of georeferenced 3D points with each point representing one elevation measurement on the Earth's surface.

There are a number of remote sensing techniques that are used to measure elevation on Earth or other planets. 
Typically, these techniques measure
+ the distance to the target surface;
+ their own position and orientation with respect to some global reference system.
By combining these, we can compute the 3D coordinates of the measured location on the target surface. 

In this chapter we will focus primarily on lidar, the most common acquisition technique for large scale terrain models with centimetre level accuracy. 
But we also give an overview of other acquisition techniques, for example photogrammetry, InSAR, and sonar. 
And to conclude we will look at typical artefacts that you might encounter while working with elevation data. 
This is because, as with any kind of real-world measurements, there are various uncertainties and restrictions in the acquisition process that lead to distortions---the _artefacts_---in the acquired data. These artefacts need to be taken into account when further processing and using the elevation data.

== Principles of lidar <sec:lidar-principles>

#index[lidar]
#note[While 'lidar' is often treated as the acronym of #strong[li]ght #strong[d]etection #strong[a]nd #strong[r]anging, it actually originated as a portmanteau of 'light' and 'radar'. (from #link("https://en.wikipedia.org/wiki/Lidar\#History\_and\_etymology")[Wikipedia])] 

A lidar system measures the distance to a target by illuminating it with pulsed laser light and measuring the reflected or _backscattered_ signal with a sensor (see @fig:acqLidar). 
#note[Backscattering is the natural phenomenon of the reflection of (electromagnetic) waves or signals back to the direction they came from.] 

#notefigure(
  image("figs/lidar.svg", width: 100%),
  caption: [Lidar range measurement.],
) <fig:acqLidar>

By measuring the time-of-flight, ie the difference in time between emitting a pulse and detecting its return or _echo_, the distance to the target that reflected the pulse can be found using a simple formula. To be exact, the time-of-flight $T$ is equal to
$  T = 2 R/c  $ <eq-tof>
where $c$ is the speed of light (approximately 300,000 km/s), and $R$ is the distance or _range_ between the lidar scanner and the target object that reflects the laser pulse. Therefore the range $R$ can be found from the measured time-of-flight $T$ using
#math.equation(block: true, numbering: none)[
$  R = 1/2 T c .  $
]
A typical lidar systems performs hundreds of thousands of such range measurements per second. 

Lidar scanners exist in various forms. 
They can be mounted on a static tripod (terrestrial lidar) for detailed local scans, or on a moving platform such as a car (mobile lidar) or an aircraft (airborne lidar) for rapid scanning of larger areas. Nowadays, also hand-held lidar systems exist, and even some of the latest smartphones have a lidar sensor. 
Furthermore, lidar can also be used from a satellite in space.
#note[NASA has used space lidar #link("https://en.wikipedia.org/wiki/ICESat-2")[on Earth], #link("https://lola.gsfc.nasa.gov")[on the Moon], and #link("https://en.wikipedia.org/wiki/Mars_Orbiter_Laser_Altimeter")[on Mars].]

However, in the remainder of this text we will focus on airborne lidar.

=== Georeferencing the range measurements

#figure(
  image("figs/lidar-gnss-imu.png", width: 70%),
  caption: [An airborne lidar system. Figure from #citet(<Dowman04>).],
  placement: auto,
) <fig:airborne-lidar>

Apart from the laser scanner itself, a lidar system uses a GPS receiver and an inertial navigation system (INS), see @fig:airborne-lidar. 
#note[inertial navigation system (INS)]#index[inertial navigation system (INS)]
These devices, which respectively provide the global position and orientation of the laser scanner, are needed for georeferencing, ie to convert the range measurements of the laser scanner to 3D point measurements in a global coordinate system such as WGS84. 

To obtain an accurate global position, _differential GPS_ (DGPS) is employed. 
#note[differential GPS]#index[differential GPS]
DGPS is a technique to enhance the accuracy of GPS by using GPS stations on the ground (one is visible in @fig:airborne-lidar). 
These DGPS stations have a known position and they broadcast the difference between that known position and the position at the station as indicated by GPS. 
This difference is essentially a correction for errors in the GPS signal. The aircraft receives these differences from nearby DGPS stations and uses them to correct the GPS position of the aircraft. Using DGPS the accuracy of the GPS position on the aircraft can be improved from around 15 meters to several centimetres.

To obtain the accurate orientation of the laser scanner, the INS of the aircraft is used. 
The INS accurately measures the orientation, ie the yaw, pitch and roll angles of the aircraft, by means of an inertial measurement unit (IMU). 
#note[inertial measurement unit (IMU)]#index[inertial measurement unit (IMU)]
Only when we accurately know the orientation of the laser scanner, can we know the direction (in a global coordinate system) in which a laser pulse is emitted from the aircraft.

By combining the global position and the global orientation of the laser scanner with the range measurement from the laser scanner, the georeferenced 3D position of the point on the target object that reflected the laser pulse can be computed.

=== Echo detection

A lidar system performs ranging measurements using the time-of-flight principle that allows us to compute range from a time measurement using the known speed of light in the air. 
The time measurement starts when the laser pulse is emitted and is completed when a backscattered echo of that signal is detected. 
In practice one emitted pulse can even lead to multiple echoes in the case when an object reflects part of the laser pulse, but also allows part of the pulse to continue past the object. 
Notice that lidar pulses are typically emitted in a slightly divergent manner. As a result the footprint of the pulse at ground level is several centimetres in diameter, which increases the likelihood of multiple echoes.

#figure(
  image("figs/lidar-multipulse.pdf", width: 80%),
  caption: [The emitted laser pulse, #strong[(a)] the returned signal, and #strong[(b)] the recorded echoes. Figure adapted from #citet(<Bailly12>).],
  placement: auto,
) <fig:lidar-multipulse>
@fig:lidar-multipulse illustrates what the backscattered signal looks like when it hits a target object in the shape of a tree. 
A tree is particularly interesting because it often causes multiple echoes (one or more on its branches and one on the ground below). The lidar sensor observes a waveform that represents the received signal power ($P$) as a function of time ($t$). 
With the direct detection lidar systems that we focus on in this book, the echoes are derived from the backscattered waveform by using a thresholding technique. This essentially means that an echo is recorded whenever the power of the waveform exceeds a fixed threshold (see @fig:lidar-multipulse\b). 

An echo can also be referred to as a _return_. 
For each return the return count is recorded,
#note[return]#index[return]
eg the first return is the first echo received from an emitted laser pulse and the last return is the last received echo (see @fig:lidar-multipulse). The return count can in some cases be used to determine if an echo was reflected on vegetation or ground (ground should then be the last return).

=== Anatomy of a lidar system <lidar:anatomy>

A lidar system consists of an optical and an electronic part. 
As shown in @fig:lidar-components, each part consists of several components.
#figure(
  image("figs/lidar-components.png", width: 100%),
  caption: [Conventional architecture of a direct detection lidar system. Figure from #citet(<Chazette16>).],
  placement: auto,
) <fig:lidar-components>

In the optical part, a pulse of a particular wavelength (typically near-infrared) is generated by the laser source for each lidar measurement. 
It then passes through a set of optics (lenses and mirrors) so that it leaves the scanner in an appropriate direction. 
After the pulse interacts with the scattering medium, it is reflected back into the scanning optics which then directs the signal into a telescope. 
The telescope converges the signal through a field diaphragm (essentially a tiny hole around the point of convergence). 
The field diaphragm blocks stray light rays (eg sunlight reflected into the optics from any angle) from proceeding in the optical pipeline.
Next, the light signal is recollimated so that it again consists only of parallel light rays.
The final step of the optical part is the interference filter which blocks all wavelengths except for the wavelength of the laser source. 
This is again needed to block stray light rays from distorting the measurement.

The electronic part consists of a photodetector, which first transforms the light signal into an electrical current, which is then converted to a digital signal using the analogue-to-digital converter. 
Once the digital signal is available, further electronics can be used to interpret and record the signal.

=== Laser wavelength

Choosing the optimal laser wavelength is a compromise of several different factors. 
One needs to consider atmospheric scattering, 
#note[atmospheric scattering]#index[atmospheric scattering]
ie how much of the signal is lost simply by travelling through the atmosphere, and the absorption capacity of vegetation, ie how much of the signal is lost because it is absorbed by vegetation. In addition, there is the stray signal due to direct and scattered contributions of sunlight. While it is possible to filter such stray signals in the lidar system to some degree, it remains wise to choose a wavelength that is only minimally affected by it. Finally there are regulations that limit the laser radiance values permissible to the eye. This means that the power of emitted signal needs to be carefully controlled, and/or a wavelength must be chosen that is not absorbed by the eye so much.

As a result, most lidar systems use a wavelength in the near-infrared spectrum, usually between 600 and 1000 nm. A notable exception is made for bathymetric purposes, in which case a green (532 nm) laser is used because that has a greater penetration ability in water.

=== Scanning patterns

In order to improve the capacity to quickly scan large areas, a number of rotating optical elements are typically present in a lidar system. Using these optical elements, ie mirrors or prisms, the emitted laser pulse is guided in a cross-track direction (ie perpendicular to the along-track direction in which the aircraft moves, see @fig:acqLidar), thereby greatly increasing the scanned ground area per travelled meter of the aircraft.
@fig:lidar-patterns depicts a number of possible configurations of rotating optics and shows the resulting scanning patterns. It is clear that density of points on the ground is affected by the scanning pattern. The top example for example, yields much higher densities on edges of the scanned area. In practice more uniform patterns, such as the bottom two examples, are often preferred.

#figure(
  image("figs/lidar-patterns.pdf", width: 70%),
  caption: [Different configurations of rotating mirrors and the associated scanning patterns from a moving platform. Arrows indicate the direction of the emitted laser signal. Figure from #citet(<Chazette16>).],
  placement: auto,
) <fig:lidar-patterns>


#box-toread("To read or to watch")[
	This YouTube video explains the principles of an aerial lidar system:
  
  #link("https://youtu.be/EYbhNSUnIdU")
]

== #flex-heading[Other techniques][Other acquisition techniques] <sec:acquisition-techniques>

Apart from lidar there are also other sensor techniques that can be used to acquire elevation data. Some of these are active sensors just like lidar (a signal is generated and emitted from the sensor), whereas others are passive (using the sun as light source). And like lidar, these sensors themselves only do range measurements, and need additional hardware such as a GPS receiver and an IMU to georeference the measurements. What follows is a brief description of the three other important acquisition techniques used in practice.

=== Photogrammetry <sec:photogrammetry>

#index[photogrammetry]

#notefigure(
  image("figs/photogrammetry.png", width: 100%),
  caption: [Photogrammetry],
) <fig:acqPhoto>

Photogrammetry allows us to measure the distance from overlapping photographs taken from different positions. 
If a ground point, called a _feature_, is identifiable in two or more images, its 3D coordinates can be computed in two steps. 
First, a viewing ray for that feature must be reconstructed for each image. 
A viewing ray can be defined as the line from the feature, passing through the projective centre of the camera, to the corresponding pixel in the image sensor (see @fig:acqPhoto). 
Second, considering that we know the orientation and position of the camera, the distance to the feature (and its coordinates) can be computed by calculating the spatial intersection of several viewing rays.

The number of 3D point measurements resulting from photogrammetry thus depends on the number of features that are visible in multiple images, ie the so-called matches.
With _dense image matching_ 
#note[dense image matching]#index[dense image matching]
it is attempted to find a match for every pixel in an image. 
If the ground sampling distance, ie the pixel size on ground level, is small (around \SI{5}{\cm} for state-of-the-art systems), point densities of hundreds of points per square meter can be achieved, which is much higher than the typical lidar point cloud (typically up to dozens of points per square meter). 

In photogrammetry we distinguish between _nadir_ images, 
#note[nadir images]#index[nadir images]
that are taken in a direction straight down from the camera, and _oblique_
#note[oblique images]#index[oblique images]
images that are taken at an angle with respect to the nadir direction.
Vertical features such as building façades are only visible on oblique images.
Therefore, oblique images are needed if one wants to see building façades in a dense image matching point cloud.

Because photography is used, photogrammetry gives us also the colour of the target surface, in addition to the elevation.
This could be considered an advantage over lidar which captures several attributes for each point (eg the intensity of measured laser pulse and the exact GPS time of measurement), but colour is not among them.

Both airborne and spaceborne photogrammetry are possible.

=== InSAR <sec:insar>

#index[InSar]

Interferometric synthetic aperture radar (InSAR) is a radar-based technique that is used from space in the context of terrain generation. 
It is quite different from airborne lidar or photo\-gramme\-try-based acquisition because of the extremely high altitude of the satellite carrying the sensor. 
Signals have to travel very long distances through several layers of unpredictable atmospheric conditions. 
As a result the speed of the radar signal is not known and the time-of-flight principle can not be used to get detailed measurements. 
However, by using a comprehensive chain of processing operations based on the measured phase shifts and the combination of multiple InSAR images, accurate elevation can still be measured. 
With InSAR it is possible to cover very large regions in a short amount of time, eg the global SRTM dataset was generated with InSAR (see @chap:gdem). 
Compared to dense image matching and lidar, InSAR-derived DTMs usually have a much lower resolution, eg SRTM has a pixel size of #qty("30", "m").

#box-toread("To read or to watch")[
  Interferometric synthetic-aperture radar:
  #link("https://en.wikipedia.org/wiki/Interferometric_synthetic-aperture_radar")
]


=== Echo sounding <sec:mbes>

Echo sounding is a form of sonar that can be used for bathymetry, ie mapping underwater terrains from a boat. 
Similar to lidar, it uses the time-of-flight principle to compute distance, but sound is used instead of light. 

Single-beam and multi-beam echo sounders exist. Multi-beam systems are capable of receiving many narrow sound beams from one emitted pulse. As a result it measures the target surface much more accurately. 
For bathymetry usually a multi-beam echo sounder is used.

@chap:bathymetry describes techniques to process bathymetric datasets and create terrain of the seabed.

#box-toread("To read or to watch")[
  The principles of echo sounding: 
	#link("https://en.wikipedia.org/wiki/Echo_sounding")
]

== Artefacts <sec:artefacts>

In the acquisition process, there are many aspects---both under our control and not under our control--- that affect the quality and usability of the resulting elevation data for a given application. 
Some examples are
- the choice of the sensor technique,
- the sensor specifications, eg the resolution and focal length of a camera, or the scanning speed, the width of the swath, and scanning pattern of a lidar system,
- the flight parameters, eg the flying altitude and the distance and overlap between adjacent flights,
- atmospheric conditions,
- the physical properties of the target surface.

An artefact is any error in the perception or representation of information that is introduced by the involved equipment or techniques. 
Artefacts can result in areas without any measurements (eg the _no-data_ values in a raster), or in so-called _outliers_, ie sample points with large errors in their coordinates. 
#note[outliers]#index[outliers]

We distinguish three types of artefacts, 
+ those that occur due to problems in the sensor,
+ those that occur due to the geometry and material properties of the target surface,
+ those that occur due to post-processing steps.

=== Sensor orientation

The sensor position and orientation are continuously monitored during acquisition, eg by means of GNSS and an IMU for airborne and seaborne systems, and used to determine the 3D coordinates of the measured points. 
Consequently, any errors in the position and orientation of the sensor platform affect the elevation measurements. 
For this reason adjacent flight strips (see @fig:lidarStrips) often need to be adjusted to match with each other using ground control points. 
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("figs/lidar_strips.png", width: 100%), caption: [Plan view of the different strips of a lidar survey. Figure from #citet(<Kornus03>)]), <fig:lidarStrips>,
  figure(image("figs/strip_adjustment.png", width: 100%), caption: [Cross-section of gable roof before (top) and after (bottom) strip adjustment.]), <fig:lidarGableRoof>,
  columns: (1fr, 1fr),
  caption: [Strip adjustment for lidar point clouds],
  placement: auto,
  label: <fig:lidarStripsAdj>,
)
If the strip adjustment process fails or is omitted, a 'ghosting' effect can occur as illustrated in @fig:lidarGableRoof (top). 
Photogrammetry knows a similar process called aerial triangulation, in which camera positions and orientation parameters (one set for each image) are adjusted to fit with each other. Errors in the aerial triangulation can lead to a noisy result for the dense matching as seen in @fig:dim.
/* TODO: verify subfigure layout */
#subfigure(
  figure(image("figs/Roof_OP_NA_10cm.jpg", width: 100%), caption: [Nadir image.]),
  figure(image("figs/Roof_DSM_NA_10cm.jpg", width: 100%), caption: [DSM with good aerial triangulation.]),
  figure(image("figs/Roof_DSM_NA+OBL_10cm.jpg", width: 100%), caption: [DSM with poor aerial triangulation.]),
  columns: (1fr, 1fr, 1fr),
  caption: [Errors in aerial triangulation can lead to distortions in the DSM (derived from dense image matching). Images courtesy of Vermessung AVT.],
  placement: auto,
  label: <fig:dim>,
)

=== Target surface

Many commonly occurring artefacts happen due to properties of the target surface. We distinguish three classes.

==== Geometry
The shape of the target surfaces in relation to the sensor position has a great effect on 1) local point densities and 2) occlusion. As you can see from @fig:lidarAcquisitionConditions:a,
#notefigure(
  image("figs/lidarAcq.pdf", width: 100%, page: 2),
  caption: [Point distribution and occlusion],
) <fig:lidarAcquisitionConditions:a>
which illustrates this for lidar, surfaces that are closest to the scanner and orthogonal to the laser beams will yield the highest point densities (see the rooftop of the middle house). Very steep surfaces on the other hand, yield relatively low point densities (see the façades of the buildings). 

_Occlusion_ happens when a surface is not visible from the scanner position.
#index[occlusion]
As a result there will be gaps in the point coverage, also visible in @fig:lidarAcquisitionConditions:a. 
Notice how some steep surfaces and some of the adjacent ground are not registered at all by the scanner because it simply could not 'see' these parts.

The severity of both effects mostly depends on the geometry of the target objects and flight parameters such as the flying altitude and the amount of overlap between flight strips.
However, regardless of what flight parameters are chosen for a survey both effects are almost always visible somewhere in the resulting dataset, see for example @fig:pcd:ahn1 for different lidar datasets for the same area.

#wideblock[
#subfigure(
  figure(image("figs/ahn1_d.png", width: 100%), caption: [AHN1 (1996--2003)]),
  figure(image("figs/ahn2_d.png", width: 100%), caption: [AHN2 (2008)]),
  figure(image("figs/ahn3_d.png", width: 100%), caption: [AHN3 (2014)]),
  figure(image("figs/rdam16_d.png", width: 100%), caption: [City of Rotterdam (2016)]),
  columns: (1fr, 1fr),
  caption: [Several lidar point clouds for the same area in the city of Rotterdam. Point distribution and occlusion effects vary.],
  placement: auto,
  label: <fig:pcd:ahn1>,
)
]

==== Material properties
Depending on material properties of a target surface, signals may be reflected in a way that makes it impossible to compute the correct distance. 
Surfaces that act like a mirror are especially problematic, @fig:lidarAcquisitionConditions:b illustrates this. 
#notefigure(
  image("figs/lidarAcq.pdf", width: 100%, page: 1),
  caption: [Reflection and multi-path],
  dy: 150pt,
) <fig:lidarAcquisitionConditions:b>
First, it may happen that a pulse is reflected away from the sensor, eg from a water surface, resulting in no distance measurement for that pulse. 
Or, in the case of photogrammetry, we will observe a different reflection in each image which heavily distorts the matching process, sometimes resulting in extreme outliers for water surfaces. 
In some cases, and only for active sensors, the reflected pulse does make its way back to the sensor, see for example the right half of @fig:lidarAcquisitionConditions:b. 
However, it will have travelled a longer distance than it should have and the scanner only knows in which direction it emitted the pulse. 
This effect is called _multi-path_ and the result is that points are measured at a distance that is too long and therefore they show up below the ground surface in the point cloud (see @fig:outliers). 
#figure(
  image("figs/outliers.png", width: 100%),
  caption: [Outliers, below and above the ground, in a lidar point cloud dataset.],
  placement: auto,
) <fig:outliers>

Photogrammetry suffers from a few other problems as well, such as surfaces that have a homogeneous texture that makes it impossible to find distinguishing features that can be used for matching.
This may also happen in poor lighting conditions, for example in the shadow parts of an image.

==== Moving objects
An example of moving objects are flocks of birds flying in front of the scanner. These can cause outliers high above the ground, as illustrated in @fig:outliers.

=== Processing
It is common to perform some kind of process after acquisition in order to fix errors caused by the reasons mentioned above. 
In most cases such processes are largely successful. 
For instance, one can attempt to fill the void regions, sometimes referred to as _no-data_ regions, that are for instance due to pools of rainwater or occlusion, using an interpolation method (@fig:voidfill).

#subfigure(
  figure(image("figs/srtm_trento_voidfill.png", width: 100%), caption: [Void-filling through interpolation in SRTM data.]), <fig:voidfill>,
  figure(image("figs/ourlier-detection-wrong.png", width: 100%), caption: [Good points, ie those on the power line, may be removed during outlier detection.]), <fig:outlier-wrong>,
  columns: (1fr, 1fr),
  caption: [Post-processing aimed at correcting artefacts. Before processing (left) and after processing (right).],
  placement: auto,
  label: <fig:processing>,
)

Or, one can attempt to detect and remove outliers caused eg by multi-path effects or flocks of birds (more details in @chap:pcprocessing). 
However, while the intention is always to reduce the number and severity of artefacts, these processes sometimes introduce distortions of their own.
For example, an outlier detection algorithm may remove 'good' points if they look the same as outliers to the outlier detection algorithm (see eg @fig:outlier-wrong).
And void-filling is only effective if the void area is not too large, since interpolation methods always assume there is sufficient neighbourhood information to work with; Chapters @chap:interpol and @chap:kriging explore the topic of spatial interpolation in detail.


#box-toread("To read or to watch")[
	This is a paper that compares lidar and photogrammetry derived point clouds for the generation of a DEM. 
	It shows that even when artefacts seem to be under control, both techniques may measure different elevations 

	// TODO \fullcite{Ressl16}
	#link("https://3d.bk.tudelft.nl/courses/geo1015/data/others/Ressl16.pdf")  
]

== Notes and comments

If you would like to learn more about how a lidar scanner works, the chapter from #citet(<Chazette16>) is recommended.
More details on InSAR can be found in the manual from #citet(<ESA07>).

#citet(<Reuter09>) give an elaborate overview of the processing that needs to be done to derive a high quality (raster) DTM from raw elevation measurements.

== Exercises

+ Name three differences between point cloud acquisition with lidar and with photogrammetry.
+ Explain what the time-of-flight principle entails.
+ How can you minimise occlusion effects in a point cloud during acquisition?
+ Why does positioning, using for instance GPS, play such an important role in acquisition?
