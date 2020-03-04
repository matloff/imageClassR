# Example of using tda_wrapper_func()
# User will feed a set of images and labels
#
#   img           : type data frame. set of images as a matrix
#   label         : type vector. labels for each image in `img`
#   nr            : type integer. number of rows in an image
#   nc            : type integer. number of columns in an image
#   rgb           : type boolean value. input image is rgb or not 
#   thresh        : type float/integer. minimum intensity to include
#   intervalWidth : type integer. width of each sweep
#   resfilename   : file name to write results to

source("~/Downloads/tdaImage/R/tda_wrapper.R")

# User Init
mnist <- read.csv("~/Downloads/mnist.csv")
img <- mnist[, -785]
label <- mnist[, 785]
nr <- 28
nc <- 28
rgb <- FALSE
thresh <- 20
intervalWidth <- 1
resfilename <- "tdaRes.csv"

# Call function and write results to a csv file for later use
res <- tda_wrapper_func(img, label, nr=nr, nc=nc, rgb=FALSE, thresh=thresh, intervalWidth=intervalWidth)
write.table(res, file=resfilename, row.names=FALSE, col.names=FALSE)

# Visualizing tda sweep on one mnist data
test_one_img(img, label, nr=nr, nc=nc, rgb=FALSE, thresh=thresh, intervalWidth=intervalWidth)
