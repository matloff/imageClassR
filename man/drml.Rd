\name{drml}
\alias{drmlDCT}
\alias{drmlPCA}
\alias{drmlUMAP}
\alias{drmlRLRN}
\alias{drmlTDAsweep}

\title{Dimension Reduction in Image Classification}

\description{
Functions for the "dimension reduction + machine learning" 
approach to image classification.
}

\usage{
   drmlTDAsweep(data, yName, qeFtnName, opts = NULL, RGB = FALSE, pixAug = 0, 
       tdasAug = 0, holdout = floor(min(1000, 0.1 * nrow(imgs))), 
       nr = 0, nc = 0, thresh = c(50, 100, 150), intervalWidth = 2) 
   drmlPCA(data, yName, qeFtnName, opts = NULL, dataAug = NULL, 
       holdout = floor(min(1000, 0.1 * nrow(data))), pcaProp) 
   drmlUMAP(data, yName, qeFtnName, opts = NULL, dataAug = NULL, 
       holdout = floor(min(1000, 0.1 * nrow(data))), nComps = 25) 
   drmlDCT(data, yName, qeFtnName, opts = NULL, dataAug = NULL, 
       holdout = floor(min(1000, 0.1 * nrow(data))), nFreqs) 
   drmlRLRN(data, yName, qeFtnName, opts = NULL, RGB = FALSE, pixAug = 0, 
       holdout = floor(min(1000, 0.1 * nrow(imgs))), nr = 0, nc = 0, 
       thresh = c(50, 100, 150)) 
}

\arguments{
   \item{data}{Data frame, one image per row, pixels within an
      image being stored in row-major.  For color images, 3 sets of
      columns, for the 3 primary colors.}
   \item{yName}{Name of the column within \code{data} that stores the
      image labels, an R factor.}
   \item{qeFtnName}{Name of the function from the \pkg{qeML} to be used
      in the "ML" portion of "DR+ML."}
   \item{opts}{Options for \code{qeFtnName}.}
   \item{RGB}{TRUE for color, FALSE for grayscale.}
   \item{pixAug}{Number of images to add via data augmentation, between
      the DR and ML stages.}
   \item{holdout}{Size of holdout set.}
   \item{nr}{Number of pixel rows within an image.}
   \item{nc}{Number of pixel columns within an image.}
   \item{thresh}{Vector specifying the threshold values.  If this is a
      negative scalar -m, then then m threshold values will be generated,
      partitioning [0,255] into m+1 equal parts.}
}

\details{

Dimension reduction is done on the pixel data, after which the ML method
is applied.  If data augmentation is requested, this is performed on the
dimension-reduced data, before applying ML.  This should yield a speedup
over doing data augmentation before dimension reduction.  Half the augmented
images are horizontal flips, half vertical.
   
}

\value{

If \code{holdout} is nonzero, the data are first randomly partitioned
into training and validations sets, and overall misclassification rate
is reported in the \code{testAcc} component of the return value.

New cases can be classified with the generic \code{predict} function
(only for TDAsweep as of now).

}

\examples{

\dontrun{

data(hm)  # histology MNIST, built-in dataset
tdasOut <- drmlTDAsweep(hm,'label','qeRF',nr=28,nc=28,thresh=-7)
tdasOut$testAcc
# 0.216, 22% misclassified

}

\author{
Norm Matloff, Yu-Shih Chen, Melissa Goh
}


