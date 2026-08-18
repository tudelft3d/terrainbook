#import "../template.typ": *

= Spatial interpolation: kriging <chap:kriging>

#minitoc(suboutline(depth: 1, indent: 0pt), youtube: "https://youtu.be/ZaadzBvgE2s")

Kriging is a spatial interpolation method that was developed mostly by Georges Matheron based on the earlier work of Danie Krige, who used similar statistical methods to estimate the yield of gold mines in South Africa.
In contrast to other spatial interpolation methods, it involves creating a custom model that is fine-tuned using the statistical properties of each dataset.
In this way, kriging can take into account the specific characteristics of a dataset, often yielding better results than other interpolation methods.

Like other techniques based on geostatistical models, kriging relies on the fact that when one moves across space, values such as the gold content in rock or the elevation in a terrain have both a general spatial _trend_#note[trend]#index[trend] (eg a flat mean value, a fitted plane or a more complex polynomial defining a surface) and a certain spatially correlated _randomness_ (ie closer points tend to have more similar values).
Both of these elements are modelled in kriging.

More than a single method, kriging comprises a family of related methods.
Within this chapter, we will look at two types of kriging in detail: simple kriging and ordinary kriging.
These treat the spatially correlated randomness in a similar way, but they make different assumptions about the trend in a dataset.

== Statistical background

The physical processes that shape the world can be considered to be at least partly deterministic.
In the case of a terrain, the elevation is determined by processes that we can model (more or less accurately), such as plate tectonics, volcanic activity, and erosion.
However, these processes are too complex and not understood well enough to use them to obtain accurate elevation values.
Imagine, for instance, how difficult it would be to get an accurate elevation map of the world using only the shape of the tectonic plates and some other parameters (eg their direction and speed of movement).

Because of this complexity, the value of complex properties, such as the elevation of a terrain, is usually treated in geostatistics as the result of what is known as a _random_#note[random process]#index[random process] or _stochastic process_#note[stochastic process]#index[stochastic process].
In this context, randomness can be understood as the fact that the value of a property at an unsampled location is not known exactly, and so we cannot assign it an exact number.
Instead, we can make an educated guess of the value at that location by creating a statistical model of its possible values using a _probability distribution_#note[probability distribution]#index[probability distribution], which we can associate with a function (ie a _probability distribution function_) or with a set of standard statistical measures, such as the mean and variance.

This situation is phrased in mathematical terms by saying that the value of the elevation property $Z$ at a location $x$ is a _random variable_#note[random variable]#index[random variable] $Z(x)$.
For the sake of simplicity, we will usually omit the location and denote it just as $Z$; or when working with multiple locations (eg $x_i$ and $x_j$), we will shorten their respective random variables ($Z(x_i)$ and $Z(x_j)$) using subscripts ($Z_i$ and $Z_j$).

In geostatistics, the most common way to express the general shape of the probability distribution of a random variable is in terms of its mean and its variance.
Here, the _mean_#note[mean]#index[mean] (also called _expectation_#note[expectation]#index[expectation] or _expected value_#note[expected value]#index[expected value]) of a random variable $Z$ is a sort of probability-weighted average of its possible values and is denoted as $E[Z]$ or $mu$.
Meanwhile, the _variance_#note[variance]#index[variance] of a random variable $Z$ is a measure of how far the values of $Z$ will usually spread from its mean, and it is denoted as $"var"(Z)$ or $sigma^2$.
A small variance thus means that a few random samples of $Z$ will likely form a tight cluster around its mean, whereas a large variance means that the samples will be more distant from the mean value.

Mathematically, the variance is defined as the expected value of the squared deviation from the expected value of $Z$, or:

$ "var"(Z) &= E[(Z - E[Z])^2] \
  &= E[Z^2 - 2 Z E[Z] + E[Z]^2] \
  &= E[Z^2] - 2 E[Z] E[Z] + E[Z]^2 \
  &= E[Z^2] - 2 E[Z]^2 + E[Z]^2 \
  &= E[Z^2] - E[Z]^2. $ <eq:variance1>

Next, it is important to define the _covariance_#note[covariance]#index[covariance], denoted as $"cov"(Z_i, Z_j)$, or $sigma_("ij")$, which expresses the joint variability of the random variables $Z_i$ and $Z_j$.
Thus, a positive covariance between $Z_i$ and $Z_j$ means that when one increases/decreases, the other is expected to increase/decrease in the same direction.
Conversely, a negative covariance means that the variables tend to increase/decrease in opposite directions.
The magnitude of the covariance is related to the magnitude of this increase or decrease.
It is thus defined mathematically as the expected product of their deviations from their (individual) expected values, or:

$ "cov"(Z_i, Z_j) &= E[(Z_i - E[Z_i]) (Z_j - E[Z_j])] \
  &= E[Z_i Z_j - Z_i E[Z_j] - E[Z_i] Z_j + E[Z_i] E[Z_j]] \
  &= E[Z_i Z_j] - E[Z_i] E[Z_j] - E[Z_i] E[Z_j] + E[Z_i] E[Z_j] \
  &= E[Z_i Z_j] - E[Z_i] E[Z_j]. $ <eq:covariance>

Here, it is good to note that the covariance of $Z_i$ with itself is equivalent to its variance:

$ "cov"(Z, Z) = E[(Z - E[Z])^2] = "var"(Z). $

While not used further in this chapter, it is also good to know that the variance and the covariance can be used to calculate the _Pearson correlation coefficient_#note[correlation coefficient]#index[correlation coefficient] $rho_("ij")$, which is one of the most common statistical measures that is applied to datasets:

$ rho_("ij") = ("cov"(Z_i, Z_j)) / sqrt("var"(Z_i) "var"(Z_j)). $

Note that this is essentially just a normalised form of the covariance.

== #flex-heading[Geostatistical model][Geostatistics and the standard geostatistical model]

In geostatistics, we apply the concepts covered in the previous section on general-purpose statistics to consider how they work with spatial phenomena, where values have a location and are often _spatially_ correlated, ie the similarity between two values depends on the distance between their locations.

The model most commonly applied in geostatistics considers that a random variable $Z$, which represents a spatially correlated property at a given location, can be decomposed into two components: (i) a non-random spatial trend that can be modelled by the expectation $E[Z]$ (eg using a constant, a polynomial, a spline, etc.); and (ii) a random but spatially correlated deviation from this trend that is considered as a sort of adjustment, error or residual term and is here denoted as $R$.
In the case of elevation, the former would represent the general shape of the terrain, whereas the latter would represent local differences from it.
We therefore have:

$ Z = E[Z] + R. $ <eq:geostat>

For a sample dataset, this decomposition is shown in @fig:trend_residual: (a) the samples, (b) a quadratic surface fitted to the samples as the trend, and (c) the residuals, ie the local differences from the trend.

#wideblock[
  #subfigure(
    figure(image("figs/trend_data.pdf", width: 100%), caption: []),
    figure(image("figs/trend_surface.pdf", width: 100%), caption: []),
    figure(image("figs/trend_residuals.pdf", width: 100%), caption: []),
    columns: (1fr, 1fr, 1fr),
    caption: [#strong[(a)] A sample dataset can be decomposed into #strong[(b)] a spatial trend (a quadratic surface fitted to the samples) and #strong[(c)] the residuals (ie the local differences from the trend).],
    placement: none,
    label: <fig:trend_residual>,
  )
]

The two types of kriging covered in this chapter treat the residual term in the same way, but they model the trend differently.
These are:
- _simple kriging_, where the trend is a known constant that we specify in the model; and
- _ordinary kriging_, where the trend is a local mean that we calculate in the interpolation process.

These will be described in detail later in the chapter.
However, in order to understand how these work and when they can be applied, it is important to cover some common properties of the two terms of the standard geostatistical model.

Regarding the expectation/trend, simple kriging relies on the assumption that the expectation $E[Z]$ is the same everywhere, which is known as the _stationarity of the mean_#note[stationarity of the mean]#index[stationarity of the mean].
In the case of a terrain, that could mean that a terrain is uneven with significant peaks and valleys, but that there is not a general trend across it (eg a clear slope with higher elevations on one side and lower elevations on the opposite side).
Mathematically, we can express that as:

$ E[Z(x + h)] = E[Z(x)], $ <eq:stationarityofthemean>

where $x$ is an arbitrary point in the domain (ie the area we want to interpolate), $h$ is any vector from $x$ to another point in the domain and $Z(x)$ is the value of a random variable at $x$ (eg its elevation).
@fig:stationarity illustrates this assumption: (a) a terrain profile with peaks and valleys but no general trend, where the expectation is the same everywhere, and (b) a terrain profile with a clear slope, where the expectation changes across the domain.

#wideblock[
  #subfigure(
    figure(image("figs/stationary.pdf", width: 100%), caption: []),
    figure(image("figs/nonstationary.pdf", width: 100%), caption: []),
    columns: (1fr, 1fr),
    caption: [The stationarity of the mean. #strong[(a)] A terrain profile with peaks and valleys but no general trend: the expectation (dashed line) is the same everywhere. #strong[(b)] The same local variation superimposed on a clear slope: the expectation changes across the domain, and so the assumption does not hold.],
    placement: none,
    label: <fig:stationarity>,
  )
]

Next, there are also important properties of the residual term.
First, note that since $R = Z - E[Z]$, the variance (@eq:variance1) and covariance (@eq:covariance) can be defined in a simple way in terms of the residuals:

$ "var"(Z) = E[R^2], $ <eq:varres>

$ "cov"(Z_i, Z_j) = E[R_i dot R_j]. $ <eq:covres>

Then, since the trend is defined as the expectation, the residual should not introduce any bias, ie its expected value must be zero: $E[R] = 0$.
When this is fulfilled, the model is said to be _unbiased_#note[unbiased]#index[unbiased].
The way that this is achieved varies in different types of kriging.

Finally, another common assumption is that the residual term at a pair of locations does not depend on the locations, but instead can be defined based only on the vector separating them.
In the case of a terrain, this would mean that the likelihood of finding similar elevations at two points separated by a given distance and orientation does not change across the terrain.
For instance, a terrain that goes from smooth on one side to rough on the other would not satisfy this assumption.
Mathematically, we can express this using the covariance as:

$ "cov"(Z(x + h), Z(x)) = C(h), $ <eq:stationarityofthecovariance>

where $C$ is the covariance function.
Since both the expectation (@eq:stationarityofthemean) and the covariance (@eq:stationarityofthecovariance) are translation invariant, this pair of assumptions is together known as _second-order stationarity_#note[second-order stationarity]#index[second-order stationarity].

== Covariance, dissimilarity and the semivariogram

#index[variogram]

According to the standard geostatistical model described above, the residual term is spatially correlated.
That is, even after removing the general spatial trend from a dataset, nearby samples will tend to have more similar values than those farther apart.
In kriging, we exploit that property by modelling it through a _semivariogram_ or a _covariance function_.
These are roughly opposites, since the semivariogram is a measure of dissimilarity and the covariance is a measure of similarity.
However, both attempt to measure how much spatial correlation there is as a function of distance and both can be used with kriging.

The semivariogram $gamma(h)$#note[semivariogram]#index[semivariogram], often just called a variogram#note[variogram]#index[variogram] for short, is a function that expresses the average dissimilarity of the value of a random variable $Z$ between sample points at different distances.
It is defined as:

$ gamma(h) = 1/2 E[(Z(x + h) - Z(x))^2], $ <eq:semivariogram>

where $x$ is a point in the domain, $h$ is any vector from $x$ to another point in the domain and $Z(x)$ is the value of a random variable at $x$ (eg its elevation).
Note that the 'semi' in semivariogram comes from the $1/2$ in @eq:semivariogram.

When this is done with every possible pair of sample points in a dataset, or, as is usual in practice in order to speed up the process, with a representative subset of them, $|h|$ (ie the magnitude of the vector $h$) and $gamma(h)$ can be put into a scatter plot to show how the average dissimilarity of a value changes with the distance between the sample points.
The result of such a plot is what is known as a _variogram cloud_#note[variogram cloud]#index[variogram cloud] (@fig:variogram_cloud).

#figure(
  image("figs/variogram_cloud.pdf", width: 100%),
  caption: [Starting from the sample dataset (@fig:trend_residual\a), the variogram cloud can be computed. In this case, only a random selection of 1% of the point pairs was used.],
  placement: none,
) <fig:variogram_cloud>

In this figure, it is possible to see some typical characteristics of a variogram cloud.
Since nearby sample points tend to have similar values, the dissimilarity tends to increase as the distance between sample points increases.
However, it is worth noting that since the pairs of sample points that are farthest apart happen to have similar values in this specific dataset, the dissimilarity decreases again at the largest distances.

Since most of the time there is a wide variation between the dissimilarities shown at all distances in a variogram cloud, the next step is to average the dissimilarity of the pairs of sample points based on distance intervals.
Mathematically, the averages of the dissimilarities, known as _experimental semivariances_#note[experimental semivariance]#index[experimental semivariance] $gamma^star(h)$, are computed for all point pairs whose separation is within one of a series of specified intervals (generally known as _bins_ or _lags_).
#note[intervals (bins)]
Given a set $frak(h)$ containing the vectors for a distance interval, the experimental semivariances are computed as:

$ gamma^star(frak(h)) = 1/(2n) sum_(h in frak(h)) (z(x + h) - z(x))^2 $

where $n$ is the number of sample point pairs in $frak(h)$ and lowercase $z$ denotes the observed values of $Z$ at the sample points.

This computation results in much smoother values for the dissimilarity, and the values of $gamma^star(h)$ for all values of $|h|$ are known as an _experimental_#note[experimental variogram]#index[experimental variogram] or _empirical variogram_#note[empirical variogram]#index[empirical variogram] (@fig:experimental_variogram\a).
@fig:experimental_variogram\b shows the relationship between the experimental semivariances, covariances and variance.

#wideblock[
  #subfigure(
    figure(image("figs/experimental_variogram.pdf", width: 100%), caption: []),
    figure(image("figs/semivariance_covariance.pdf", width: 100%), caption: []),
    columns: (1fr, 1fr),
    caption: [#strong[(a)] The experimental variogram and #strong[(b)] the relationship between the experimental semivariances, covariances and variance.],
    placement: none,
    label: <fig:experimental_variogram>,
  )
]

Note that in order to avoid the unreliable dissimilarities that are common at large distances between sample points, it is usual practice to compute the experimental variogram only for distances up to about half of the extent of the region covered by the dataset.

From the scatterplot of the experimental variogram, it is possible to see how a few important parameters can be used to describe it (@fig:example_variogram):
- the _sill_#note[sill]#index[sill], which is the upper bound of $gamma^star(h)$;
- the _range_#note[range]#index[range], which is the value of $|h|$ at which $gamma^star(h)$ levels off (reaches the sill);
- the _nugget_#note[nugget]#index[nugget], which is the value of $gamma^star(h)$ when $|h|$ approaches 0.

#figure(
  image("figs/example_variogram.pdf", width: 100%),
  caption: [An experimental variogram can be described in terms of a few parameters.],
  placement: none,
) <fig:example_variogram>

The last step is to use these parameters to replace the experimental variogram with a _theoretical variogram function_#note[theoretical variogram function]#index[theoretical variogram function] that approximates it and which can be more easily evaluated for further calculations.
Depending on the shape of the variogram, there are various functions that can be used.
Some examples are:

$ gamma_"circular"(h) &= cases(
    s (1 - 2/pi cos^(-1)(|h|/r) + (2 |h|)/(pi r) sqrt(1 - (|h|^2)/(r^2))) + n & "if" |h| <= r,
    s + n & "if" |h| > r,
  ) \
  gamma_"cubic"(h) &= cases(
    s ((7 |h|^2)/(r^2) - (8.75 |h|^3)/(r^3) + (3.5 |h|^5)/(r^5) - (0.75 |h|^7)/(r^7)) + n & "if" |h| <= r,
    s + n & "if" |h| > r,
  ) \
  gamma_"exponential"(h) &= s (1 - e^((-3 |h|)/r)) + n \
  gamma_"gaussian"(h) &= s (1 - e^((-3 |h|^2)/(r^2))) + n \
  gamma_"linear"(h) &= cases(
    (s |h|)/r + n & "if" |h| <= r,
    s + n & "if" |h| > r,
  ) \
  gamma_"power"(h) &= cases(
    (s |h|^2)/(r^2) + n & "if" |h| <= r,
    s + n & "if" |h| > r,
  ) \
  gamma_"spherical"(h) &= cases(
    s ((3 |h|)/(2 r) - (|h|^3)/(2 r^3)) + n & "if" |h| <= r,
    s + n & "if" |h| > r,
  ) $

where $s$ is the _partial sill_#note[partial sill]#index[partial sill], set to roughly the difference between the value of $gamma^star(h)$ when it is flat and the nugget; $r$ is the _range_, roughly the minimum value of $|h|$ where $gamma^star(h)$ is flat; and $n$ is the nugget, which is the starting value of $gamma^star(h)$. Together, the partial sill and the nugget make up the (total) _sill_, $s + n$, which is the value at which $gamma^star(h)$ becomes flat.
@fig:theoretical_variogram shows the result of fitting the example theoretical variogram functions.
Note how the cubic and especially the Gaussian functions fit well in this case.
Unlike the other functions, the power model is usually unbounded: $gamma(h) = c |h|^a$ grows without limit as $|h|$ increases, and therefore has no sill or range. The bounded version above is used here so that it can be compared with the other models.

#wideblock[
  #subfigure(
    figure(image("figs/model_circular.pdf", width: 100%), caption: []),
    figure(image("figs/model_cubic.pdf", width: 100%), caption: []),
    figure(image("figs/model_exponential.pdf", width: 100%), caption: []),
    figure(image("figs/model_gaussian.pdf", width: 100%), caption: []),
    figure(image("figs/model_linear.pdf", width: 100%), caption: []),
    figure(image("figs/model_power.pdf", width: 100%), caption: []),
    figure(image("figs/model_spherical.pdf", width: 100%), caption: []),
    columns: (1fr, 1fr, 1fr),
    caption: [Some possible theoretical variogram functions. #strong[(a)] Circular. #strong[(b)] Cubic. #strong[(c)] Exponential. #strong[(d)] Gaussian. #strong[(e)] Linear (bounded). #strong[(f)] Power (bounded). #strong[(g)] Spherical.],
    placement: none,
    label: <fig:theoretical_variogram>,
  )
]

Many other theoretical variogram functions are possible, eg Matérn or the pure nugget model.
However, of the ones described above, the spherical, exponential and Gaussian are the ones most commonly used in practice.

Before moving on to apply these to kriging, there are a couple of important points.
First, note that these theoretical functions are often only applied when $|h| > 0$, since setting $gamma(0) = 0$ helps to ensure that kriging passes exactly through the sample points (the exactness property, as explained in @sec:interpol_properties and discussed further in @sec:kriging_impl).
Second, all of the semivariogram-related functions seen in this section can be converted to covariance functions as well, taking into account that $gamma(h) = "sill" - C(h)$.
Note that this means that the covariance is high when $|h|$ is small and it decreases as $|h|$ increases.

== Simple kriging

Simple kriging is similar to other spatial interpolation methods that use a weighted average.
It starts from the assumption of second-order stationarity.
Moreover, the expectation is also known, and so the general procedure is to: (i) subtract the expectation from the sample points to obtain residuals, (ii) use the residuals to define a function that estimates the value of the residual term at any location, and (iii) interpolate at the desired locations using the function added to the expectation.

Thus, simple kriging defines a function $hat(R)_0$ that estimates the value of the residual $R$ of the random variable $Z$ at a location $x_0$ as a weighted average of its residuals at the $n$ sample points $x_i$ that we will use for the interpolation (where $1 <= i <= n$).
We denote this as:

$ hat(R)_0 = hat(Z)_0 - E[Z_0] = sum_(i=1)^(n) w_i (underbrace(Z_i - E[Z_i], R_i)). $ <eq:wask>

Simple kriging is unbiased, meaning that in expectation the estimate at a location $x_0$ is equal to the (unknown) true value at that location.
In mathematical terms, we can formulate this as:

$ E[hat(Z)_0 - Z_0] = 0 quad "or" quad E[Z_0] = E[hat(Z)_0]. $ <eq:unbiased>

// In order to check this for simple kriging, we can put the weighted average from
// Equation @eq:wask in this equation, which results in the following:
// // TODO: why is latex complaining at \end{align} I removed \cancelto{} and it's solved
// E[Z_0] &= E[E[Z_0] + sum_(i=1)^n w_i R_i] \
//   &= E[Z_0] + sum_(i=1)^n w_i 0 E[R_i] \
//   &= E[Z_0].

Then, in order to derive the equations used in simple kriging, we impose the criterion that it _minimises the variance of the estimation error_#note[minimisation of the variance]#index[minimisation of the variance], which in this case is given by $"var"(hat(R)_0 - R_0)$.
If we use the definition of the variance from @eq:variance1, this can be instead put in terms of an expectation:

$ "var"(hat(R)_0 - R_0) = E[((hat(R)_0 - R_0) - E[hat(R)_0 - R_0])^2] $

However, we know from the unbiased criterion in @eq:unbiased that $E[hat(R)_0 - R_0] = 0$, and so we can simplify the previous equation as:

$ "var"(hat(R)_0 - R_0) = E[(hat(R)_0 - R_0)^2]. $

If this is expanded, it results in:

$ "var"(hat(R)_0 - R_0) &= E[hat(R)_0^2 - 2 hat(R)_0 R_0 + R_0^2] \
  &= E[hat(R)_0^2] - 2 E[hat(R)_0 R_0] + E[R_0^2] \
  &= E[sum_(i=1)^(n) sum_(j=1)^(n) w_i w_j R_i R_j] - 2 E[sum_(i=1)^(n) w_i R_i R_0] + E[R_0^2] \
  &= sum_(i=1)^(n) sum_(j=1)^(n) w_i w_j E[R_i R_j] - 2 sum_(i=1)^(n) w_i E[R_i R_0] + E[R_0^2]. $

Here, we can use the definitions of the variance based on residuals from @eq:varres and @eq:covres together with our covariance formula from @eq:stationarityofthecovariance, which yields:

$ "var"(hat(R)_0 - R_0) &= sum_(i=1)^(n) sum_(j=1)^(n) w_i w_j "cov"(R_i, R_j) - 2 sum_(i=1)^(n) w_i "cov"(R_i, R_0) + "cov"(R_0, R_0) \
  &= sum_(i=1)^(n) sum_(j=1)^(n) w_i w_j C(x_i - x_j) - 2 sum_(i=1)^(n) w_i C(x_i - x_0) + C(x_0 - x_0). $ <eq:variancesk>

In order to minimise this, we set its first derivative with respect to each weight $w_i$ to zero.
This is:

$ (partial "var"(hat(R)_0 - R_0)) / (partial w_i) = 2 sum_(j=1)^(n) w_j C(x_i - x_j) - 2 C(x_i - x_0) = 0 quad "for all" 1 <= i <= n $

which yields the set of $n$ simple kriging equations:

$ sum_(j=1)^(n) w_j C(x_i - x_j) = C(x_i - x_0). $

While these equations can be solved directly, it is often easier to work with them in matrix form:

$ underbrace(mat(C(x_1 - x_1) & dots.c & C(x_1 - x_n); dots.v & dots.down & dots.v; C(x_n - x_1) & dots.c & C(x_n - x_n)), A) underbrace(mat(w_1; dots.v; w_n), w) = underbrace(mat(C(x_1 - x_0); dots.v; C(x_n - x_0)), d) $

which is known as the _simple kriging system_#note[simple kriging system]#index[simple kriging system].
Finally, if we invert the matrix $A$, the weights are given by:

$ w = A^(-1) d. $

These weights can be applied to interpolate the value of the residual term at any location as a weighted average of the sample points, where the correlation between the points is given by a covariance function, which can be obtained from the semivariogram.

However, simple kriging does not tell us what value we should use for the expectation $E[Z]$, since we start from the assumption that it is known, which is often not the case.
Even a seemingly reasonable value, such as the average of all sample points, can be very inaccurate if the sample points are unevenly distributed across the domain.

== Ordinary kriging

#index[ordinary kriging]

Ordinary kriging is similar to simple kriging in that it estimates values using a weighted average function with weights computed from the semivariogram/covariance based on the distance between the points.
However, it does not assume that the expectation is known, relying instead only on _local_ second-order stationarity, ie a constant mean within a moving neighbourhood, and this mean is estimated as part of the interpolation.

Rather than relying on the residuals, it defines a function $hat(Z)_0$ that directly estimates the value of the random variable $Z$ at a location $x_0$ as a weighted average of its value at the $n$ neighbouring sample points $x_i$ that we will use for the interpolation (where $1 <= i <= n$).
We denote this as:

$ hat(Z)_0 = sum_(i=1)^(n) w_i Z_i. $ <eq:waok>

Like simple kriging, ordinary kriging is _unbiased_, which is achieved by making sure that the interpolation weights add up to one, ie $sum_(i=1)^(n) w_i = 1$.
Ordinary kriging also _minimises the variance of the estimation error_, which is given by $"var"(hat(Z)_0 - Z_0)$.
For this, we can use the same derivation as for simple kriging up to @eq:variancesk but using the variogram for the final step.
This is:

$ "var"(hat(Z)_0 - Z_0) &= sum_(i=1)^(n) sum_(j=1)^(n) w_i w_j "cov"(Z_i, Z_j) - 2 sum_(i=1)^(n) w_i "cov"(Z_i, Z_0) + "cov"(Z_0, Z_0) \
  &= - sum_(i=1)^(n) sum_(j=1)^(n) w_i w_j gamma(x_i - x_j) + 2 sum_(i=1)^(n) w_i gamma(x_i - x_0). $

In the second line, the covariance was converted to the semivariogram using $gamma(h) = "sill" - C(h)$, and the terms with the sill cancel out because the weights are constrained to sum to one.

Using the previous equation and the unbiased criterion from @eq:unbiased, we can apply the minimisation method known as the method of Lagrange multipliers#footnote[#link("https://en.wikipedia.org/wiki/Lagrange_multiplier")] and arrive at the set of $n+1$ ordinary kriging equations:

$ sum_(j=1)^(n) w_j gamma(x_i - x_j) + mu(x_0) &= gamma(x_i - x_0) quad "for all" 1 <= i <= n \
  sum_(i=1)^(n) w_i &= 1 $

where $mu(x_0)$ is a Lagrange multiplier that was used in the minimisation process.

Like with simple kriging, these equations can be used to perform ordinary kriging, but it is often easier to deal with these in matrix form:

$ underbrace(mat(gamma(x_1 - x_1) & dots.c & gamma(x_1 - x_n) & 1; dots.v & dots.down & dots.v & 1; gamma(x_n - x_1) & dots.c & gamma(x_n - x_n) & 1; 1 & dots.c & 1 & 0), A) underbrace(mat(w_1; dots.v; w_n; mu(x_0)), w) = underbrace(mat(gamma(x_1 - x_0); dots.v; gamma(x_n - x_0); 1), d) $

which is known as the _ordinary kriging system_#note[ordinary kriging system]#index[ordinary kriging system].

Finally, if we invert the matrix $A$, the weights and the Lagrange multiplier are given by:

$ w = A^(-1) d. $

Here, the first $n$ entries of $w$ are the interpolation weights, which can be substituted into @eq:waok to estimate the value at $x_0$ as a weighted average of the values at the $n$ sample points used for the interpolation.
The last entry, the Lagrange multiplier $mu(x_0)$, is not used in the estimate itself, but rather to compute the kriging variance below.
Note also that the vector $d$ depends on the interpolation location $x_0$, and thus the system needs to be solved anew for every location at which we want to interpolate.

Substituting the ordinary kriging equations into the estimation variance above gives its minimum value, which is known as the _kriging variance_#note[kriging variance]#index[kriging variance]:

$ sigma^2(x_0) = sum_(i=1)^(n) w_i gamma(x_i - x_0) + mu(x_0). $ <eq:krigingvariance>

The kriging variance can be computed at every location where we interpolate, and a map of it is useful to identify where the interpolated values are least reliable (see @fig:kriging_variance and @sec:kriging_impl).

== Other types of kriging

/ Directional kriging: is useful when the similarity between points depends on the direction, eg north-south versus east-west. It involves creating variograms for different directions.
/ Block kriging: estimates the average value over an area (a block) rather than at a single point. It can be used to obtain smoother results.
/ Cokriging: applies kriging to multiple correlated variables. It is particularly useful when one variable has only a few sample points, but a correlated variable has many more.
/ Indicator kriging: applies kriging to binary indicator variables obtained by thresholding the data (eg the presence or absence of an attribute), yielding the probability of occurrence of each class rather than a continuous value.
/ Poisson kriging: applies kriging to count and rate data. It is often applied together with polygonal datasets.
/ Universal kriging: fits the trend using a predefined deterministic function. It is tricky to use in practice because it imposes conditions on the underlying variogram.

== Implementation details <sec:kriging_impl>

There are a few important details with respect to the implementation of kriging methods in practice.

First of all, within this chapter, we have assumed that you always use all sample points to interpolate any point on the plane.
While this is optimal in theory, if a large number of sample points are used to interpolate every point, kriging can be _very slow_ in practice.
The reason for this is that matrix $A$ will be very large, and inverting a matrix is a computationally expensive process.
Since the weights of far-away sample points are usually very small, the usual solution is to limit the number of sample points used, either by using a search radius, or by selecting only a given number of the closest sample points.
However, when the excluded far-away points would have had non-negligible weights, this causes artefacts in the final result.

Another related issue is that kriging is often said to be exact in theory, ie it passes exactly through the sample points.
Strictly speaking, this exactness follows from using $gamma(0) = 0$ in the kriging system, and it holds even when the fitted theoretical variogram function has a nugget.
However, a nugget larger than zero has a noticeable effect around the sample points: since $gamma(h)$ is already large for very small $|h|$, the interpolant is smoothed in the neighbourhood of each sample point, reaching the sample value only exactly at the sample point itself, which creates a discontinuity.
Because of this, some authors and implementations instead treat the nugget as measurement error, using its value on the diagonal of the kriging system rather than zero; in that case the interpolant no longer passes exactly through the sample points.
@fig:nugget_exactness illustrates this: with a zero nugget the interpolant passes exactly through the sample points (a), whereas with a large nugget it smooths the data (b).

#wideblock[
  #subfigure(
    figure(image("figs/nugget_exact.pdf", width: 100%), caption: []),
    figure(image("figs/nugget_smooth.pdf", width: 100%), caption: []),
    columns: (1fr, 1fr),
    caption: [The effect of the nugget on ordinary kriging along a horizontal transect through the sample dataset. #strong[(a)] With a zero nugget, the interpolant passes exactly through the sample points. #strong[(b)] With a large nugget, the interpolant smooths the data, and even the values at the sample points are no longer reproduced exactly.],
    placement: none,
    label: <fig:nugget_exactness>,
  )
]

Finally, it is worth noting that kriging can be directly applied to any point on the plane, yielding a result such as the one in @fig:interpolation.
However, much like other interpolation methods, kriging is only reliable in the domain (ie roughly the convex hull of the points).
It can extrapolate (often by using negative weights), but that does not mean that the results outside the domain are accurate.
The kriging variance (@eq:krigingvariance) shown in @fig:kriging_variance gives a quantitative picture of this: it is lowest close to the sample points and increases with the distance from them, becoming particularly large outside the domain.

#figure(
  image("figs/interpolation.pdf", width: 100%),
  caption: [The result of using ordinary kriging to interpolate on a grid using the sample dataset and the 20 nearest sample points of each location, with a spherical variogram function (sill 1250, range 150).],
  placement: none,
) <fig:interpolation>

#figure(
  image("figs/kriging_variance.pdf", width: 100%),
  caption: [The ordinary kriging variance for the sample dataset, computed with a spherical variogram function (sill 1250, range 150) and the 20 nearest sample points. The variance is lowest close to the sample points and grows with the distance from them, in particular outside the domain; the white polygon shows the convex hull of the sample points.],
  placement: none,
) <fig:kriging_variance>

== Notes and comments

#citet(<Krige51>) is the original publication by Danie Krige; the method was later formalised by Georges Matheron #citep(<Matheron62>) #citep(<Matheron65>).
How this came to be is best explained in #citet(<Cressie93>).

If you have trouble following the derivations of the kriging equations or want to know more about them, #citet(<Lichtenstern13>) explains this well.
If you feel like your statistics background is a bit weak, you first might want to have a look at #citet(<Fewster14>), particularly Chapter 3.

A relatively simple explanation of kriging with agricultural examples is given by #citet(<Oliver15>).
A standard reference textbook that is good but not so easy to follow is #citet(<Wackernagel03>).
The mathematics covered in this chapter is partly based on the latter.

Strictly speaking, ordinary kriging evaluated at a location that coincides exactly with a sample point reproduces the sample value even when the nugget is larger than zero, since by definition $gamma(0) = 0$.
The smoothing at the sample points shown in @fig:nugget_exactness\b therefore comes from treating the nugget as measurement error, ie from using its value on the diagonal of the kriging system rather than zero.

`Pyinterpolate`#note[#link("https://pyinterpolate.readthedocs.io/")] is a good Python library to perform kriging and is used to generate some of the example figures from this chapter.

Two other good YouTube videos that explain kriging:
- #link("https://www.youtube.com/watch?v=CVkmuwF8cJ8")
- #link("https://www.youtube.com/watch?v=98zz25kTteQ")

== Exercises

+ Why can using a search radius create artefacts in the interpolated terrain?
+ If kriging generally provides better results than other interpolation methods, why would you use something else (eg IDW)?
+ What does a nugget of zero say about a dataset? What about a large nugget?
+ What kind of dataset would yield a flat variogram (ie a horizontal line)?