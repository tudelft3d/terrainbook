Hi Ravi, 

Roof from Dense Image Matching
Roof is displayed in the Orthophoto (OP) (imagery textured on DSM from Nadir)

Examples (they are not typical for NA+OBL Aerial Triangulations or thereof resulting dense image matching (!), 
but just one example for you of what impact slightly wrong aerial triangulation has on dense image matching). 
Here the aerial triangulation for Nadir (NA) was without problem, but the aerial triangulation one for the oblique views had some problem (1-2 pix of horizontal paralax)
 - so image rays were not perfectly alligned (perfect never happens, but sub-pixel accuracy is usual). 
The flight was about 3 cm, and DSM products made in 10 cm (NA) and 5 and 10 cm (NA+OBL).   
 
Attached you find: 
DSM from Nadir only -> 10 cm 
DSM from NA+OBL -> 5 cm - here the deviations in height are best visible as noice on the roof
DSM from NA+OBL -> sampled to 10 cm (same resolution like , some of the noice are smoothed, but the still visible)

Notice that 5cm resolution output was not possible from the Nadir-only images, because an overdetermined system of parameters is needed (ie many overlapping images).

Notice some smoothing is applied during semi-global matching, therefore images look smoothened

Kjersti Moe