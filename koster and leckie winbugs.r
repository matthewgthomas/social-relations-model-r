##
## Replicating the analyses in Koster & Leckie (2014) - "Food sharing networks in lowland Nicaragua: An application of the social relations model to count data"
## using the R interface to WinBUGS
##
## Author: Matthew Gwynfryn Thomas (@matthewgthomas)
## URL: http://matthewgthomas.co.uk
## Date: 16 April 2015
##
## Before running the code, do these:
## 1. install WinBUGS from: http://www.mrc-bsu.cam.ac.uk/software/bugs/the-bugs-project-winbugs/
##    - install patch for version 1.4.3
##    - load the license key
##
## 2. install the R packages R2WinBUGS and memisc
##
## 3. download the supplementary data files from http://dx.doi.org/10.1016/j.socnet.2014.02.002
##    and unzip them into your R working directory
##
## Note: This code uses a modified version of Koster & Leckie's "model1.txt" model specification.
##   The only difference is that in "model1_mgt.txt" the intercept 'beta' is no longer an array.
##   (The diff in this GitHub project shows the exact change made.)
##
##
## Copyright (c) 2015 Matthew Gwynfryn Thomas
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
## ----------------------------------------------------------------------------

#install.packages("R2WinBUGS", "memisc")
library(R2WinBUGS)
library(memisc)  # for the mtables() model summariser function

# this file contains a summariser function for BUGS social relations models
# see: https://gist.github.com/matthewgthomas/beef5ee7a434d3da934d
source("https://gist.githubusercontent.com/matthewgthomas/beef5ee7a434d3da934d/raw/06fbdc38003b7648b503f7dc0464549e053c84ad/getSummary.bugs.r")

winbugs_dir = "C:/Program Files/WinBUGS14/"  # change this to your WinBUGS directory


###############################################################
## Load and prepare data
##
dyads = read.csv("dyads.csv")
hh = read.csv("households.csv")

# remove "did" (dyad ID) and "hid" (household ID)
dyads$did = NULL
hh$hid = NULL

# convert the dyads and households column names into one list
data = c(as.list(colnames(dyads)), as.list(colnames(hh)))

# add "R_gr" (scale matrix associated with the Wishart prior for the giver-receiver covariance matrix)
data = c(data, "R_gr")

# make R_gr scale matrix
R_gr = matrix(c(1,0,0,1), nrow=2, ncol=2)

# create separate lists in the workspace for each column in the dyads and hh dataframes 
## code from: http://stackoverflow.com/questions/16052239/split-a-data-frame-by-columns-and-storing-each-column-as-an-object-with-the-colu
invisible(lapply(names(dyads), function(x) assign(x, dyads[, x], envir = .GlobalEnv)))
invisible(lapply(names(hh), function(x) assign(x, hh[, x], envir = .GlobalEnv)))

# what do we want out of the model?
parameters <- c("beta", "COV_gr", "COV_dd", "gr", "dd", "rho_dd", "sigma_dd", "sigma2_d")


###############################################################
## Model 1
##
data_m1 = data[c(1:5, length(data))]  # keep only hidA, hidB, giftsAB, giftsBA, offset and R_gr

# specify initial values for the model parameters
inits_m1 = function() {
  list (beta = 0,  # only intercept in this model
        TAU_gr = matrix(c(2,0,0,2), nrow=2, ncol=2),  # giver-receiver precision matrix
        tau_d = 1.333,  # relationship precision == relationship variance of 0.75 (1 / tau_d)
        rho_dd = 0.500  # dyadid reciprocity
  )
}

# run the model
model1 = bugs(data_m1, inits_m1, parameters, "model1_mgt.txt", 
              n.chains=1, n.burnin=50000, n.iter=100000, n.thin=100, 
              debug=F, bugs.directory=winbugs_dir)


###############################################################
## Model 2
##
# specify initial values for the model parameters
inits_m2 = function() {
  list (beta = rep(0, 17),  # 17 coefficients = 0
        TAU_gr = matrix(c(2,0,0,2), nrow=2, ncol=2),  # giver-receiver precision matrix
        tau_d = 1.333,  # relationship precision == relationship variance of 0.75 (1 / tau_d)
        rho_dd = 0.500  # dyadid reciprocity
  )
}

# run the model
model2 = bugs(data, inits_m2, parameters, "model2.txt", 
              n.chains=1, n.burnin=50000, n.iter=100000, n.thin=100, 
              debug=F, bugs.directory=winbugs_dir)


###############################################################
## Show output of models (Table 2 in Koster & Leckie 2014)
##
plot(model1)
plot(model2)

bugs.summary = mtable("Model 1"=model1, "Model 2"=model2, 
                      coef.style="ci.se.horizontal", digits=2)
relabel(bugs.summary, 
        "beta[1]"  = "Intercept",
        "beta[2]"  = "Giver – Game",
        "beta[3]"  = "Giver – Fish",
        "beta[4]"  = "Giver – Pigs",
        "beta[5]"  = "Giver – Wealth",
        "beta[6]"  = "Receiver – Game",
        "beta[7]"  = "Receiver – Fish",
        "beta[8]"  = "Receiver – Pigs",
        "beta[9]"  = "Receiver – Wealth",
        "beta[10]" = "Receiver – Pastors",
        "beta[11]" = "Relationship – Relatedness 1",
        "beta[12]" = "Relationship – Relatedness 2",
        "beta[13]" = "Relationship – Relatedness 3",
        "beta[14]" = "Relationship – Relatedness 4",
        "beta[15]" = "Relationship – Distance (log transformed)",
        "beta[16]" = "Relationship – Association index",
        "beta[17]" = "Relationship – Giver 1 & Receiver 25"
        )
