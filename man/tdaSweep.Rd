\name{tdaFit}
\alias{tdaFit}
\alias{predict.tdaFit}

\title{TDAsweep for Dimension Reduction in Image Classification}

\description{
Functions implementing the TDAsweep method for dimension reduction of
image data.
}

\usage{
tdaFit(images, labels, nr, nc, rgb = TRUE, thresholds = 0, 
    intervalWidth = 1, cls = NULL, rcOnly = FALSE, qeFtn, mlFtnArgs = NULL) 
predict.tdaFit(tdaFitObject,newImages)
}

\arguments{
  \item{images}{Matrix or data frame of image dataset, one image per
  row.}
  \item{labels}{Vector or R factor, one element per row of \code{images}.}
  \item{nr}{Number of rows per image.} 
  \item{nc}{Number of columns per image. Must have
     \code{nr * nc = ncol(images)}.} 
  \item{rgb}{TRUE indicates color images.} 
  \item{thresholds}{Vector of TDAsweep thresholds.}
  \item{intervalWidth}{Number of rows etc. in a TDAsweep group.}
  \item{cls}{Cluster for parallel computation.} 
  \item{rconly}{Perform row and column sweeps only, no diagonals.} 
  \item{qeFtn}{Quoted name of desired qe*-series function.}
  \item{mlFtnArgs}{R list of optional arguments for the qe*-series
     function.}
  \item{tdaFitObject}{An object returned by \code{tdaFit}.}
  \item{newImages}{Matrix or data frame of new images to be predicted, 
     in the same form that had been input to \code{tdaFit}.} 
}

\details{

The function \code{tdaFit} is offered for convenience, a "turnkey" tool.
It performs both the tdaSweep and model-fitting steps. The paired
prediction function, \code{predict.tdaFit}, is similarly integrated.
Model-fitting is done via the qe*-series ("quick and easy") from
\pkg{regtools}, offering logistic, multi-outcome linear, random forests,
gradient boosting, SVM and neural networks.  This wrapper thus enables
the user to focus better on choosing hyperparameters and so on.
   
}

\value{

The function \code{tdaFit} returns an object of type \code{tdaFit},
suitable for input to \code{predict.tdaFit}, called as \code{predict}.
One component of the object, \code{testAcc}, shows the overall
probability of correct classification on a holdout set.

}

\examples{

\dontrun{
# need to first get the MNIST data, in form required for 'images'
# arguments; one way is 
library(keras)
mnist <- dataset_mnist()
x_train <- mnist$train$x  # dim 60000 x 28 x 28 array
y_train <- mnist$train$y  # vec length 60000
xtrn <- x_train
ytrn <- y_train
dim(xtrn) <- c(60000,28*28)  # xtrn now dim 60000 x 784 matrix
x_test <- mnist$test$x  # dim 10000 x 28 x 28 array
y_test <- mnist$test$y  # vec length 10000
xtst <- x_test
ytst <- y_test
dim(xtst) <- c(10000,28*28)  # xtst now dim 10000 x 784 matrix
# fit, and predict first few
tfout <- tdaFit(xtrn,ytrn,28,28,FALSE,c(100,175),qeFtn='qeRF') 
predict(tfout,xtst[1:3,]) 
# performance on holdout set (within training set)
tfout$testAcc
# fit a gradient boosting model, with optional parameters
tfout <- tdaFit(xtrn,ytrn,28,28,FALSE,c(100,175),qeFtn='qeGBoost',
   mlFtnArgs=list(nTree=500,minNodeSize = 20))

}
}

\author{
Norm Matloff
}


