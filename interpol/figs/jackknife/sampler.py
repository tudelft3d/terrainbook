
import numpy
import rasterio
import random 
import math
import csv
import sys

nsamples = 1000

# d = rasterio.open('/Users/hugo/Dropbox/data/dtm/CristoRedentor/S23W043.hgt')
# d = rasterio.open('/Users/hugo/Dropbox/data/dtm/CristoRedentor/reprojected.tif')
d = rasterio.open('/Users/hugo/Dropbox/data/dtm/tylermw/dem_01.tif')

band1 = d.read(1)
ofile = open(d.name + '.xyz', 'w')
csvfile = csv.writer(ofile, delimiter=' ')
csvfile.writerow(['x', 'y', 'z'])
print (d.bounds)
print ("crs:", d.crs)

i = 0
while (True):
    x = random.uniform(d.bounds[0], d.bounds[2])
    y = random.uniform(d.bounds[1], d.bounds[3])
    row, col = d.index(x, y)
    if (band1[row,col] == int(d.nodata)):
        continue
    csvfile.writerow([x, y, band1[row,col]])
    i += 1
    if (i == nsamples):
        break


# print ("name:", d.name)
# print ("count:", d.count)
# print ("width:", d.width)
# print ("height:", d.height)
# print ("crs:", d.crs)
# print ("transform:", d.transform)
# print ("left:", d.bounds.left)
# print ("top:", d.bounds.top)
# print ("bounds:", d.bounds)







