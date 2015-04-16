A replication, in R, of the social relations models presented in Koster &amp; Leckie (2014): "Food sharing networks in lowland Nicaragua: An application of the social relations model to count data"

Before running the code, do these things:

1. install [WinBUGS](http://www.mrc-bsu.cam.ac.uk/software/bugs/the-bugs-project-winbugs/)

- install the patch for version 1.4.3
- load the license key

2. install the R packages [R2WinBUGS](http://cran.r-project.org/web/packages/R2WinBUGS/index.html) and [memisc](http://cran.r-project.org/web/packages/memisc/)

3. download the [supplementary data files](http://dx.doi.org/10.1016/j.socnet.2014.02.002) and unzip them into your R working directory

Note: This code uses a modified version of Koster & Leckie's "model1.txt" model specification. The only difference is that in "model1_mgt.txt" the intercept 'beta' is no longer an array. (The diff in this GitHub project shows the exact change made.)

The models are summarised using the `mtable()` function in [Martin Elff's `memisc` package](http://cran.r-project.org/web/packages/memisc/). `mtable()` doesn't work with bugs models out of the box, so I've [written some code to prettify them](https://gist.github.com/matthewgthomas/beef5ee7a434d3da934d)

The R code is released under an MIT License. WinBUGS model code is copyright (c) 2014 Elsevier B.V.
