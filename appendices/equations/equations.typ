#import "../../template.typ": *

= Some useful equations <app:equations>

// #minitoc(suboutline(depth: 1, indent: 0pt))

== Centre of a circle defined by 3 points <sec:centrecircle>

#box-info("This section is taken and adapted from:")[
  #link("https://www.ambrsoft.com/trigocalc/circle3d.htm")
]

#notefigure(
  image("./figs/circle.pdf", width: 100%),
)

Given the 3 points $a$, $b$, and $c$ in the plane, we can determine the unique circle passing through those 3 points by solving the following determinant equation:
$  mat(delim: "|", x^(2) + y^(2), x, y, 1 ; a_x^(2) + a_y^(2), a_x, a_y, 1 ; b_x^(2) + b_y^(2), b_x, b_y, 1 ; c_x^(2) + c_y^(2), c_x, c_y, 1 ;) = 0  $

We can rewrite the determinant as:
$ (x^(2) + y^(2))M_(1 1) - x M_(1 2) + y M_(1 3) - M_(1 4) = 0  $
where $M_"ij"$ is a minor of the 4x4 matrix.

The general equation of a circle is $x^(2) + y^(2) = r^(2)$, which means:
$  r^(2) - x frac(M_(1 2), M_(1 1)) + y frac(M_(1 3), M_(1 1)) - frac(M_(1 4), M_(1 1)) = 0  $

For a circle with centre $p$ and radius $r_p$, its general equation is:
$ (x - p_x)^(2) +(y - p_y)^(2) = r_p^(2)  $
if we expand and rearrange:
$  r^(2) - 2 x p_x - 2 y p_y + p_x^(2) + p_y^(2) - r_p^(2) = 0  $

Thus:
$  p_x = frac(M_(1 2), 2 M_(1 1))  $
$  p_y = frac(M_(1 3), 2 M_(1 1))  $
$  r_p^(2) = frac(M_(1 4), M_(1 1)) + p_x^(2) + p_y^(2)  $
