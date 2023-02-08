The `farsdata` R Package
========

<img src="vignettes/figure/coursera.jpg" width="120" />

This is an assignment for the **Course 3 : Building R Packages**. Kindly refer to my GitHub repo for the courses [Coursera Mastering Software Development in R](https://github.com/oleled/farsData) to know the course detail or [Building R Packages](https://www.coursera.org/learn/r-packages) to register for study.


## Installation

You can install the development version of Highway.Fatality.Census.Project from 
[GitHub](https://github.com/) with:
``` r
install.packages('farsData')

# Or below code if above code unable install the package
devtools::install_github("oleled/farsData")
```

## Example

You can load the package and read the sample dataset. The data in this package come from the National Highway Traffic Safety Administration (NHTSA) Fatality Analysis Reporting System (FARS) data.

``` r
library(farsdata)
library(maps)

fars_2014_fn <- make_filename(2014)
fars_2014_fn
```

## Vignettes

You can refer to below articles for more infoamtion about the package.
- [Introduction to `farsdata` Package](http://rpubs.com/oleled/farsData/vignette)

