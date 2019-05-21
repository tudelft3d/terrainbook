import math
import scipy.spatial
import numpy
import csv


def main():
    list_pts_3d = []
    with open('/Users/hugo/Dropbox/data/dtm/tylermw/dem_01.tif.xyz') as csvfile:
        r = csv.reader(csvfile, delimiter=' ')
        header = next(r)
        for line in r:
            p = list(map(float, line)) #-- convert each str to a float
            list_pts_3d.append(p)

    zhat = []
    rmse = 0
    for i in range(1000):
        p = list_pts_3d[i]
        list_pts_3d.pop(i)
        zhat = idw_one_location((p[0], p[1]), 1200, 2, list_pts_3d)
        # print (p[0], p[1], abs(zhat - p[2]))
        print (p[0], p[1], p[2], zhat)
        list_pts_3d.insert(i, p)
        rmse = rmse + (zhat - p[2])*(zhat - p[2])
    rmse = math.sqrt(rmse / (i+1))
    # print(rmse)

def distance_2_points(p1, p2):
    a = p2[0]-p1[0]
    b = p2[1]-p1[1]
    return math.sqrt((a*a) + (b*b))

def idw_one_location(p, radius, power, list_pts_3d):
    list_pts_2d = []
    for each in list_pts_3d:
        list_pts_2d.append(each[:2])
    kd = scipy.spatial.KDTree(list_pts_2d)
    i = kd.query_ball_point(p, radius)
    totalw = 0
    total = 0
    # print (i)
    if len(i) == 0:
        print("NODATA_VALUE")
        return -9999
    for n in i:
        d = distance_2_points(p, list_pts_3d[n])
        if (d == 0.0):
            return list_pts_3d[n][2]
        w = math.pow(d, -power)
        totalw += w
        total += list_pts_3d[n][2] * w
    return (total/totalw)

if __name__ == '__main__':
    main()