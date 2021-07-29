# imageClassR

Quick and Easy tools for image classification, in the spirit of the
**qeML** package of Quick and Easy tools for machine learning.

Includes the novel **TDAsweep** method.


## Function Groups

The package consists of two main function groups.

### drml\*()

These functions implement an approach we call DR + ML, meaning one
first applies a dimension reduction method, then applies a standard
machine learning algorithm on the lower-dimensional data.

For instance, one might take DR = PCA and ML = SVM; we apply SVM to the
lower-dimensional data obtained by PCA.  

Our featured DR method is TDAsweep, a novel method for image
classification using [Topological Data Analysis (TDA)](Slides.pdf).
Using TDA in the image contenxt, one is able to perform dimension
reduction on a dataset to improve runtime of the analysis as well as to
avoid the risk of overfitting. More details below.

In addition to offering as DR methods PCA and TDAsweep, we also offer
UMAP, moments/HOG and RLRN.

Note that CNN is not quite a DR+ML method.  One might describe it as
C + NN, where C represents the convolutional layers
and NN the dense ones.  However, the two "summands" here do not operate
independently, as the weights in the C portion are computed in tandem
with those of the NN part.

### keras\*()

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

