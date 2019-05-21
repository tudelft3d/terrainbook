
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import csv
import sys

tmp = []
with open('jk3.xyz') as csvfile:
    r = csv.reader(csvfile, delimiter=' ')
    # header = next(r)
    for line in r:
        p = list(map(float, line)) #-- convert each str to a float
        tmp.append(p)

pts = np.array(tmp)
cm = np.zeros(pts.shape[0])
for i in range(pts.shape[0]):
    cm[i] = abs(pts[i][3] - pts[i][2])
# print(cm.reshape(1000, 1))
# sys.exit()



# fig, ax = plt.subplots(1, 2)
fig, ax = plt.subplots()


# im0 = mpimg.imread('/Users/hugo/teaching/terrainbook/interpol/figs/jackknife/dem_01_preview.tiff')
# imgplot = ax.imshow(im0)

# im0 = ax.scatter(pts[:,0], pts[:,1], c=pts[:,2], alpha=0.5)

# im0 = ax.scatter(pts[:,0], pts[:,1], c=cm, alpha=0.5, cmap='Reds')

im0 = ax.scatter(pts[:,2], pts[:,3], c=cm, alpha=0.5, cmap='Reds')


# ax[0].legend()
# ax.grid(True)
ax.set_xlabel(r'Real value', fontsize=10)
ax.set_ylabel(r'Estimated value', fontsize=10)
# ax[0].set_title('RMSE from IDW')

# ax.get_xaxis().set_visible(False)
# ax.get_yaxis().set_visible(False)
fig.colorbar(im0)

# locs, labels = xticks()
# print (labels)
# ax.set_xticklabels( ('a', '2.5', '5.0', '7.5', '10.0', '12.5', '15.0', '17.5', '20.0', '22.5', '1') )
# ax.set_yticklabels( ('a', '2.5', '5.0', '7.5', '10.0', '12.5', '15.0', '17.5', '20.0', '22.5', '1') )

# plt.show()
# plt.savefig("aaa.pdf", bbox_inches='tight')
plt.savefig("jk4.pdf", bbox_inches='tight')


# import numpy as np
# import matplotlib.pyplot as plt
# import csv
# import sys

# tmp = []
# with open('jk2.xyz') as csvfile:
#     r = csv.reader(csvfile, delimiter=' ')
#     # header = next(r)
#     for line in r:
#         p = list(map(float, line)) #-- convert each str to a float
#         tmp.append(p)

# pts = np.array(tmp)
# cm = np.zeros(pts.shape[0])
# for i in range(pts.shape[0]):
#     cm[i] = abs(pts[i][3] - pts[i][2])


# # print(cm.reshape(1000, 1))
# # sys.exit()



# fig, ax = plt.subplots()
# plt.scatter(pts[:,0], pts[:,1], c=cm, alpha=0.5, cmap='Reds')
# # plt.scatter(pts[:,2], pts[:,3])

# # plt.legend()
# # plt.grid(True)
# # plt.set_xlabel(r'$x$', fontsize=15)
# # plt.set_ylabel(r'$y$', fontsize=15)
# # plt.set_title('RMSE from IDW')


# plt.grid(True)
# # fig.tight_layout()

# plt.colorbar()
# plt.show()


# # plt.savefig("foo.pdf", bbox_inches='tight')