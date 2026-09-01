#import "../../template.typ": *


= Estimating the normals in a point cloud <app:normalplane>

// #minitoc(suboutline(depth: 1, indent: 0pt))

Given a point cloud $S$, the normal vector for a point $p in S$ can be found by fitting a plane $P$ to the points in the local neighbourhood of $p$. 
The vector orthogonal to this plane is the normal vector $arrow(n)$ of $p$.

In practice, we might want to use the 10 (or 15 or 20, depending on the resolution of $S$) nearest neighbours to $p$.
This can be efficiently (and easily with the many implementations available) performed with a $k$d-tree, see Section @sec:knn-m.

To fit the plane, the preferred option is to use least-square fitting because it minimises the sum of squared distances between the points and the plane $P$.

We suggest to use Principal Component Analysis (PCA) 
#note[Principal Component Analysis (PCA)]
#index[Principal Component Analysis (PCA)]
to obtain the plane $P$, and to obtain its normal $arrow(n)$.
PCA allows us to identify the directions of maximum variance in a dataset, and it uses the _eigenvalues_ and _eigenvectors_ of the covariance matrix of a dataset.
#note[eigenvalues and eigenvectors]
#index[eigenvalues]#index[eigenvectors]
The eigenvector linked with the largest eigenvalue represents the direction where the variance is the largest, and the smallest eigenvalue where the variance is the smallest.

#wideblock[
  #figure(
    image("./figs/normal_demo.pdf", width: 100%),
    caption: [Perspective view of a point cloud with 3 planes fitted and their normal vector.],
    placement: none,
  ) <fig:normal_demo>
]

For our subset of 10 or 15 neighbouring points in $S$, the direction of maximum variance is the plane that best fits the data, and the normal vector is the direction of minimum variance.
@fig:knn_normal shows that one should be careful for points close to the edges of building for instance, since the normal will be affected by neighbouring points.
#notefigure(
  grid(
    image("./figs/normal.pdf", width: 100%, page: 1),
    v(2em),
    image("./figs/normal.pdf", width: 100%, page: 2),
    v(2em),
    image("./figs/normal.pdf", width: 100%, page: 3),
  ),
  caption: [Calculating the normal of points with $k$d-trees and fitting of a plane. *(top)* A few points sampling the surface of a cube. *(middle)* For the case where 5 neighbours are used, the normal is indicated in dark red. *(bottom)* If $p$ is near the edge of the cube, then some neighbours will on the other face and the normal will be modified.],
) <fig:knn_normal>

Observe that the normal obtained this way is not by definition correctly oriented, that is it could point in either direction perpendicular to the fitted plane.
For buildings, we usually prefer to have the normal pointing outwards/up, and thus the normal with the $z$-component positive is usually chosen.

==== Local geometric features
It should also be noticed that the eigenvalues $lambda _(1,2,3)$ (where $lambda_1 >= lambda_2 >= lambda_3 >= 0$) can be useful to calculate/estimate the local geometric properties around $p$, such as the following:


$ "linearity":  &quad L_(lambda) = frac(lambda_1 - lambda_2, lambda_1) \ 
  "planarity":  &quad P_(lambda) = frac(lambda_2 - lambda_3, lambda_1) \ 
  "sphericity": &quad S_(lambda) = frac(lambda_3, lambda_1) \  $
