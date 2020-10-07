\name{TDAsweep}
\alias{TDAsweep}

\title{TDAsweep for Dimension Reduction in Image Classification}

\description{
Functions implementing the TDAsweep method for dimension reduction of
image data.
}

\usage{
TDAsweep(images, labels, nr, nc , rgb=TRUE, 
                                 thresholds = 0, intervalWidth=1, cls=NULL, prep=FALSE, rcOnly=FALSE)
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
  \item{prep}{If the images are already in proper format, produced by prepImgSet function.}
  \item{rconly}{Perform row and column sweeps only, no diagonals.} 
}

\details{

The function \code{TDAsweep} is the wrapper function to perform TDAsweep, a novel method for image classification using Topological Data Analysis (TDA). The function formats the input image dataset to an appropriate format for TDAsweep sweeps in the input image dataset in four directions (column, row, NW to SE, and NE to SW).
   
}

\value{

The function \code{TDAsweep} returns a S3 class object called \code{sweepOut}, which contains the reduced dataset, number of samples, number of features, thresholds specified, and the intervalWidth specified. Specifically, the user can use the reduced dataset for input as a train set to a machine learning classification model of choice.

}

\examples{

\dontrun{
# This example shows TDAsweep + SVM on the famous MNIST dataset.
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


