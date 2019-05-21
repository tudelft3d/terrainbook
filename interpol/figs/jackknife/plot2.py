
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
fig, ax = plt.subplots(2, 2)


im0 = mpimg.imread('/Users/hugo/teaching/terrainbook/interpol/figs/jackknife/dem_01_preview.tiff')
imgplot = ax[0][0].imshow(im0)

im1 = ax[0][1].scatter(pts[:,0], pts[:,1], s=10, c=pts[:,2], alpha=0.5, cmap='Reds')

im2 = ax[1][0].scatter(pts[:,0], pts[:,1], s=10, c=cm, alpha=0.5, cmap='Reds')

im3 = ax[1][1].scatter(pts[:,2], pts[:,3], s=10, c=cm, alpha=0.5, cmap='Reds')


# ax[0].legend()
# ax.grid(True)
# ax[0].set_xlabel(r'$x$', fontsize=10)
# ax[0].set_ylabel(r'$y$', fontsize=10)
# ax[0].set_title('RMSE from IDW')


ax[0][0].get_xaxis().set_visible(False)
ax[0][0].get_yaxis().set_visible(False)
ax[0][1].get_xaxis().set_visible(False)
ax[0][1].get_yaxis().set_visible(False)
ax[1][0].get_xaxis().set_visible(False)
ax[1][0].get_yaxis().set_visible(False)
ax[1][1].get_xaxis().set_visible(False)
ax[1][1].get_yaxis().set_visible(False)


# fig.colorbar(im1)
cbar = fig.colorbar(im2, ax=ax.ravel().tolist(), shrink=0.8)
cbar = fig.colorbar(im1, ax=ax.ravel().tolist(), shrink=0.8)

# plt.show()
plt.savefig("total.pdf", bbox_inches='tight')


# import numpy as np
# import matplotlib.pyplot as plt
# import csv
# import sys

# tmp = []
# with open('jk3.xyz') as csvfile:
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