
fi = open("mesh2.ply","r")
fo = open("mesh2_flat.ply","w")


for l in fi.readlines():
    a = l.split()
    # print(a)
    if len(a) == 3:
        try:
            # print(a[0])
            float(a[0])
            # print(b)
            fo.write('{} {} {}\n'.format(a[0], a[1], -30.0))
        except ValueError:
            fo.write("{}".format(l))
    else:
        fo.write("{}".format(l))

