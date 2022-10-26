
<!-- README.md is generated from README.Rmd. Please edit that file -->

# savetexvalue

<!-- badges: start -->
<!-- badges: end -->

`savetexvalue` helps saving and managing values calculated in R for
integration in projects written in LaTeX in an automatic and
reproducible way. savetexvalue uses special formatted `.tex` files
containing pairs of values and command names to be used in LaTeX.

## Installation

You can install the development version of savetexvalue from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Ori-Shoham/savetexvalue")
```

## Usage and examples

Suppose you work on a project analyzing the sepal length of irises.

``` r
library(savetexvalue)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
data(iris)

# These are the computations
avg_sep_length <- iris %>% 
  group_by(Species) %>% 
  summarise(sep_length_avg = mean(Sepal.Length))

prop_greater_6 <- iris %>% 
  group_by(Species) %>% 
  summarise(prop_greater = mean(Sepal.Length>6))

# Save the values:
path <- tempdir()
save_tex_value(values = avg_sep_length$sep_length_avg,
               names = paste0(avg_sep_length$Species,"Avg"),
               file_name = "iris_calc",
               path = path)
save_tex_value(values = prop_greater_6$prop_greater,
               names = paste0(prop_greater_6$Species,"PerGreaterSix"),
               file_name = "iris_calc",
               path = path,
               percent = T,
               accuracy = 0.1)
```

The contents of `iris_calc.tex` should now be:

    \newcommand\setosaAvg {5.01}
    \newcommand\setosaPerGreaterSix {0.0\%}
    \newcommand\versicolorAvg {5.94}
    \newcommand\versicolorPerGreaterSix {40.0\%}
    \newcommand\virginicaAvg {6.59}
    \newcommand\virginicaPerGreaterSix {82.0\%}

![screenshot](man/figures/README-test-1.PNG)

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
