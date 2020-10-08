\name{TDAsweep}
\alias{TDAsweep}
\alias{TDAsweepOneImg}
\alias{TDAsweepImgSet}
\alias{prepOneImage}
\alias{prepImgSet}
\alias{tdaFit}
\alias{predict.tdaFit}


\title{TDAsweep for Dimension Reduction in Image Classification}

\description{
Functions implementing the TDAsweep method for dimension reduction of
image data.
}

\usage{
tdaFit(
  images,
  labels,
  nr,
  nc,
  rgb = TRUE,
  thresholds = 0, 
  intervalWidth = 1,
  cls = NULL,
  rcOnly = FALSE,
  qeFtn,
  mlFtnArgs = NULL
) 
  
predict.tdaFit(
  tdaFitObject,
  newImages
)


TDAsweep(
  images,
  labels,
  nr,
  nc,
  rgb=TRUE, 
  thresholds = 0,
  intervalWidth=1,
  cls=NULL,
  prep=FALSE,
  rcOnly=FALSE
) 

TDAsweepOneImg(
  i2D,
  nr,
  nc,
  valType='raw',
  intervalWidth=1,
  rcOnly=FALSE
) 
   
   
TDAsweepImgSet(
  imgsPrepped,
  nr,
  nc,
  valType='1Dcells',
  intervalWidth=1,
  rcOnly=FALSE
) 

prepOneImage(
  img2D,
  thresh
) 

prepImgSet(
  imgs,
  nr,
  labels,
  thresh
) 

  


}

\arguments{
  \item{images}{Matrix or data frame of image dataset, one image per row.}
  \item{labels}{Vector or R factor, one element per row of \code{images}.}
  \item{nr}{Number of rows per image.} 
  \item{nc}{Number of columns per image. Must have
     \code{nr * nc = ncol(images)}.}
  \item{rgb}{TRUE indicates color images.} 
  \item{thresholds}{Vector of TDAsweep thresholds.}
  \item{intervalWidth}{Number of rows etc. in a TDAsweep group.}
  \item{cls}{Number of Clusters for parallel computation.} 
  \item{prep}{If the images are already in proper format, produced by prepImgSet function.}
  \item{rconly}{Perform row and column sweeps only, no diagonals.} 
  \item{qeFtn}{Quoted name of desired qe*-series function.}
  \item{mlFtnArgs}{R list of optional arguments for the qe*-series
     function.}
  \item{tdaFitObject}{An object returned by \code{tdaFit}.}
  \item{newImages}{Matrix or data frame of new images to be predicted, 
     in the same form that had been input to \code{tdaFit}.} 
  \item{i2D}{Output of regtools::imgTo2D(), with row number, column number, intensity for each one of a filtered set of pixels}
  \item{valType}{Type of return value, currently 'raw' or '1Dcells'; the former means the raw counts, not grouped into intervals, while the latter means grouped}
  \item{img2D}{Output of regtools::imgTo2D() for a single image; each row is of form (row number,column number,intensity), storing information for a given pixel}
  \item{imgsPrepped}{Output from prepImgSet()}
  
}

\details{

The function \code{tdaFit} is offered for convenience, a "turnkey" tool.
It performs both the tdaSweep and model-fitting steps. The paired
prediction function, \code{predict.tdaFit}, is similarly integrated.
Model-fitting is done via the qe*-series ("quick and easy") from
\pkg{regtools}, offering logistic, multi-outcome linear, random forests,
gradient boosting, SVM and neural networks.  This wrapper thus enables
the user to focus better on choosing hyperparameters and so on.

The function \code{TDAsweep} is the wrapper function to perform TDAsweep. The function wraps up functions TDAsweepOneImg(), TDAsweepImgSet(), prepOneImage(), and prepImgSet() to create a complete pipeline for TDAsweep. Specifically, the function formats the input image dataset to an appropriate format for TDAsweep and sweeps in the input image dataset in four directions (column, row, NW to SE, and NE to SW).

As mentioned above, functions TDAsweepOneImg(), TDAsweepImgSet(), prepOneImage(), and prepImgSet() are the building block functions of TDAsweep, which are integrated in the wrapper function TDAsweep(). These could be called for experimental or debugging purposes. 
   
}

\value{

The function \code{tdaFit} returns an object of type \code{tdaFit},
suitable for input to \code{predict.tdaFit}, called as \code{predict}.
One component of the object, \code{testAcc}, shows the overall
probability of correct classification on a holdout set.

The function \code{TDAsweep} returns a S3 class object called \code{sweepOut}, which contains the reduced dataset, number of samples, number of features, thresholds specified, and the intervalWidth specified. Specifically, the user can use the reduced dataset for input as a train set to a machine learning classification model of choice.

}

\examples{

\dontrun{
# this example shows the use of tdaFit and predict.tdaFit()
# need to first get the MNIST data, in form required for 'images'
# arguments; one way is 
mnist <- getMNIST()
idxs <- sample(1:nrow(mnist),10000)  # keep the scale small in this example
x <- mnist[idxs,-785]
y <- mnist[idxs,785]
# fit, and predict first few
tfout <- tdaFit(x,y,28,28,FALSE,c(100,175),qeFtn='qeRF') 
predict(tfout,x[1:3,]) 
# performance on holdout set (within training set)
tfout$testAcc

# fit a gradient boosting model, with optional parameters
tfout <- tdaFit(x,y,28,28,FALSE,c(100,175),qeFtn='qeGBoost',
   mlFtnArgs=list(nTree=500,minNodeSize = 20))

}

\dontrun{
# This example shows the use of TDAsweep(), along with e1071 SVM as the classification model on the famous MNIST dataset.
library(tdaImage)  
library(e1071)

#---- data preparation ----#
# will need to first prepare the MNIST dataset. One way to get it: https://www.kaggle.com/c/digit-recognizer
mnist <- read.csv("PATH TO MNIST.CSV")
mnist$y <- as.factor(mnist$y)
set.seed(1)
train_idx <- sample(seq_len(nrow(mnist)), 0.8*nrow(mnist))  # simple sampling
train_set <- mnist[train_idx, -785]  # exclude label if doing tda
train_y_true <- mnist[train_idx, 785]
test_set <- mnist[-train_idx, -785]
test_y_true <- mnist[-train_idx, 785]

#---- parameters for performing TDAsweep ----#
nr = 28  # mnist is 28x28
nc = 28
rgb = FALSE  # mnist is grey scaled
thresholds = c(50)  # set one threshold, 50
intervalWidth = 1  # set intervalWidth to 1

#---- performing tda on train set ----#
tda_train_set <- tda_wrapper_func(image=train_set, labels=train_y_true, 
                                        nr=nr, nc=nc, rgb=rgb, thresh=thresholds,
                                        intervalWidth=intervalWidth)
dim(tda_train_set)  # 784 -> 166 features after TDAsweep
tda_train_set <- as.data.frame(tda_train_set)
tda_train_set$labels <- as.factor(tda_train_set$labels)

#---- performing tda on test set ----#
tda_test_set <- tda_wrapper_func(image=test_set, labels=test_y_true,
                                        nr=nr, nc=nc, rgb=rgb, thresh=thresholds,
                                        intervalWidth=intervalWidth)
tda_test_set <- as.data.frame(tda_test_set)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -167]  # take out labels for testing the svm model later

#---- training and predicting using e1071 svm model ----#
system.time(svm_model <- svm(labels ~., data=tda_train_set))
predict <- predict(svm_model, newdata=tda_test)

#---- Evaluation ----#
mean(predict == tda_test_label) # accuracy on test set

}
}

\author{
Norm Matloff
}


