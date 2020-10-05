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


   
}

\value{

}

\examples{

\dontrun{
# need to first get the MNIST data; one way is 
library(keras)
mnist <- dataset_mnist()
x_train <- mnist$train$x  # dim 60000 x 28 x 28 array
y_train <- mnist$train$y  # vec length 60000
dim(xtrn) <- c(60000,28*28)  # xtrn dim 60000 x 784 matrix
x_test <- mnist$test$x  # dim 10000 x 28 x 28
y_test <- mnist$ttest$y  # vec length 10000
dim(xtst) <- c(10000,28*28)  # xtst dim 10000 x 784 matrix

}
}

\author{
Norm Matloff
}


