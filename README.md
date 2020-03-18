# tdaImage

Novel methods for image classification using [Topological Data Analysis (TDA)](Slides.pdf). Using TDA, one is able to perform dimension reduction on a dataset to improve runtime of the analysis as well as to avoid the risk of overfitting. Dimension reduction in **tdaImage** is achieved by manipulating two variables, threshold and interval width.

The [**regtools** package](https://github.com/matloff/regtools) is required. 

**Usage:**

Call **tda_wrapper_func()** with the desired threshold (`thresh`) and interval width (`intervalWidth`). 
* `thresh`: the minimum pixel intensity to be included in each sweep. 
* `intervalWidth`: should be set to an integer greater than 1 to achieve dimension reduction. Represent this many rows by taking the mean of them.
* `img`: a pixel intensity matrix of images. 
* `label`: a vector of labels each row corresponding to each image. 

The return value is a list of number of components in row, column, and diagonals.

*Example: Polynomial Regression* 

This example uses the [MNIST dataset](http://heather.cs.ucdavis.edu/mnist.csv) and perform dimension reduction with TDA, then predict the results using [**polyreg**](http://github.com/matloff/polyreg). 

```R
# initialization
mnist <- read.csv("../mnist.csv")   # get dataset
img <- mnist[, -785]
label <- mnist[, 785]
nr <- 28                            # height of one image
nc <- 28                            # width of one image
rgb <- FALSE
thresh <- 20                        # ignore all pixels with intensity lower than this 
intervalWidth <- 4

... # shuffle and take a small chunk of images

tdaout <- tda_wrapper_func(img, label, nr=nr, nc=nc, rgb=FALSE, thresh=thresh, 
                            intervalWidth=intervalWidth)
# look at first output
head(tdaout, 1)   
# [1,] 0 0.5 2 2.25 2.00 1 0.5 0 0.25 1.25 2.75 1.50 0.25 0 3 1.75 1 0.00 0 0 0
# [1,] 2.5 2.25 1.25 0.25 0 0 0 0 0 0 0 0.25 1.50 1.75 1.25 1.00 1.25 0 0 0 0
#     labels
# [1,]      3
tdaout$labels <- as.character(tdaout$labels)
pfout <- polyFit(res[-c(1:5),],2)   # fit quadratic model
newx <- tdaout[c(1:5),]             # test on the 5 rows we omitted before
newx <- newx[,-43] 
predict(pfout, newx)

```


