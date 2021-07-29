# imageClassR

Quick and Easy tools for image classification, in the spirit of the
**qeML** package of Quick and Easy tools for machine learning.  Simple,
uniform APIs similar to **qeML**.

Includes the novel **TDAsweep** method.


## Function Groups

The package consists of two main function groups (as well as misc.
utilities).

Each function returns an S3 object with various components, including
**testAcc**, the error rate in the holdout set.  Each function also
has a paired generic **predict()** function for predicting new images.


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

Choices for DR:

* Principal Components Analysis (PCA)

* Uniform Manifold Approximation and Projection (UMAP)

* TDAsweep

* Discrete Cosine Transform (DCT)

* Run Length Run Number (RLRN)

For the ML portion, one my use any in the **qeML** package. including

* k-NN

* SVM

* random forests (several implementations)

* neural networks

* gradient boosting

* Adaboost

* logistic model

Note that CNN is not quite a DR+ML method.  One might describe it as
C + NN, where C represents the convolutional layers
and NN the dense ones.  However, the two "summands" here do not operate
independently, as the weights in the C portion are computed in tandem
with those of the NN part.

### keras\*()

Image-related wrappers, using R **keras** package, with
**regtools::krsFit()** as intermediary.

* **kerasConv():** Basic CNN, user-supplied convolutional and dense
  layers.

## TDAsweep

### Intuition

Inspired from Topological Data Analysis and RLRN, TDAsweep defines
components in terms of rows and columns of an image.  Specifically, the
original image is thresholded, i.e. each pixel value above the threshold
will be denoted as 1 and 0 otherwise. Then, TDAsweep counts contiguous
components in the horizontal and vertical directions of a pixel matrix.
(The software allows diagonal counts as well, but these are generally
less useful.) The counts of the components in each direction will serve
as the new, dimension-reduced set of features describing the original
image.

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

**This method is fast (and quite amenable to GPU) and non-iterative.**

# Examples

``` r
data(hm)  # histology slide daa
# TDAsweep + random forests; images are 28x28; use 7 threshold levels,
# 5000 augmented images
drmlTDAsweep(data=hm,yName='label',qeFtnName='qeRF',nr=28,nc=28,
   thresh=-7,tdasAug=5000)$testAcc
# 0.06
# 6% error rate on holdout set
```
