# dimRedImage

## Overview

Currently a popular method for image classification is Convolutional
Neural Networks (CNN).  It provides a general technique, and when
properly tuned, can be quite powerful.

The key phrase here, though, is "properly tuned."  CNNs have many
hyperparameters, and finding the proper combination can be quite
difficult and extremely time-consuming.  In some applications,
alternative approaches may be desirable.

This package takes an approach we call DR + ML, meaning one first
applies a dimension reduction method, then applies a standard
machine learning algorithm on the lower-dimensional data.

For instance, one might take DR = PCA and ML = SVM; we apply SVM to the
lower-dimensional data obtained by PCA.  CNN may be viewed as a special
case, described as C + NN.  Here C represents the convolutional layers
and NN the dense ones.

We feature TDAsweep, a novel method for image classification using
[Topological Data Analysis (TDA)](Slides.pdf). Using TDA in the image
contenxt, one is able to perform dimension reduction on a dataset to
improve runtime of the analysis as well as to avoid the risk of
overfitting. 

## TDAsweep

### Intuition

Inspired from Topological Data Analysis, TDAsweep defines components in a more simplified way. Specifically, TDAsweep casts thresholding on the original image (each pixel value above the threshold will be denoted as 1 and 0 otherwise). Then, TDAsweep counts contiguous components in horizontal, vertical, and the two diagonal directions of a pixel matrix. The counts of the components in each direction will serve as the new set of features describing the original image.

An example should help illustrate the process more clearly:

Say, after thresholding some toy image, we have the following matrix:

                                10011101
                                10111100
                                10101101

Then, we would count the number of components in each rows, columns, and diagonals.
An example of counting the components for each rows would be:

                There are 3 components in vector “10011101”
                There are 2 components in vector “10111100”
                There are 4 components in vector “10101101”

Here, [3,2,4] will be included as the new set of features. We repeat this process for columns and the two diagonal directions (NW to SE and NE to SW).

The typical pattern involved is:

1.  Perform dimension reduction, by some means -- PCA, the 'C' in "CNN,"
our **TDAsweep** presented here, etc.

2.  Feed the results of 1) above into one's favorite machine learning
    method, such as NNs, SVM, logit or random forests.

A fast, non-iterative method for dimension reduction of images would be
quite useful.

### QUICK START

The convenience wrapper `tdaFit()` makes running the system easy.  Type

``` r
> ?tdaFit
```

and scroll down to the *examples* section and run the example there.


### TDAsweep

The [**regtools** package](https://github.com/matloff/regtools) is required. 

**Usage:**

tda_wrapper_func(images, labels, nr, nc, rgb=TRUE, thresholds=0 , intervalWidth=1, cls, prep=FALSE, rcOnly=FALSE)

* `image`: a pixel intensity matrix of images. 
* `labels`: a vector of labels each row corresponding to each image. 
* `nr`: number of rows of the input image pixels.
* `nc`: number of columns of the input image pixels.
* `rgb`: TRUE if rgb image is used. FALSE otherwise.
* `thresholds`: the minimum pixel intensity to be included in each sweep. 
* `intervalWidth`: should be set to an integer greater than 1 to achieve dimension reduction. Represent this many rows by taking the mean of them.
* `cls`: self-defined number of clusters to use for parallelization. If not specified, TDAsweep will default to no parallelization.
* `prep`: TRUE if prepImgSet has already be run on the image dataset to avoid redundancy in code. FALSE otherwise.
* `rcOnly`: TRUE if the user wish to only sweep row and column directions. FALSE otherwise.


The return value of **tda_wrapper_func()** is a list of number of components in row, column, and diagonals.
*Example: TDAsweep + Support Vector Machine* 

This example uses the [MNIST dataset](http://heather.cs.ucdavis.edu/mnist.csv) and perform dimension reduction with TDA, then predict the results using the  [**caret  package's SVM function**](https://cran.r-project.org/web/packages/caret/index.html). 

```R
library(tdaImage)
library(e1071)  # standard e1071 SVM
library(liquidSVM)  # load if using liquidSVM to train

#---- data preparation ----#
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
```


*Example: Polynomial Regression* 

This example uses the [MNIST dataset](http://heather.cs.ucdavis.edu/mnist.csv) and perform dimension reduction with TDA, then predict the results using [**polyreg**](http://github.com/matloff/polyreg). 

```R
# initialization
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

#---- training and predicting using polyFit ----#
pfout <- polyFit(res[-c(1:5),],2)   # fit quadratic model
newx <- tdaout[c(1:5),]             # test on the 5 rows we omitted before
newx <- newx[,-43] 
predict(pfout, newx)

#---- Evaluation ----#
mean(predict == tda_test_label) # accuracy on test set

```

### Parallelization
Parallelization is supported by TDAsweep. Users can input number of cores to TDAsweep (e.g. TDAsweep(...,cls=4,...) # using 4 cores). If the parameter was not specified, the code will use the default option of not doing parallelization.



### Analysis of TDAsweep on the MNIST dataset

The results of running TDAsweep on the MNIST dataset before classification was very encouraging. We were able to achieve ~78.8% feature reduction in exchange for less than 1% accuracy loss. As a result, the runtime of training the Support Vector Machine was drastically decreased.

![alt text](https://github.com/matloff/table.png)

    (Table 1. Speed Comparison of SVM before and after TDAsweep)




