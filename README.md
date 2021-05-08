# imageClassR

## Overview

This package serves as a convenient, one-stop site for image
classification, enabling easy exploration of various standard methods.
In addition, a new method, TDAsweep, is introduced.

Currently a popular method for image classification is Convolutional
Neural Networks (CNN).  It provides a general technique, and when
properly tuned, can be quite powerful.

The key phrase here, though, is "properly tuned."  CNNs have many
hyperparameters, and finding the proper combination can be quite
difficult and extremely time-consuming.  In some applications,
alternative approaches may be desirable.

Thus, while the package will provide easy interface to standard CNN
architectures, it also takes an approach we call DR + ML, meaning one
first applies a dimension reduction method, then applies a standard
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

# QUICK START

(under construction)

