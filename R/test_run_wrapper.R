# Example of using tda_wrapper_func()
# User will feed a set of images and labels
#
#   img         : set of images as a matrix
#   label       : labels for each image in `img`
#   nr          : number of rows in an image
#   nc          : number of columns in an image
#   thresh      : minimum intensity to include
#   resfilename : file name to write results to

source("./tda_wrapper.R")

# User Init
mnist <- read.csv("../mnist.csv")
img <- mnist[,1:784]
label <- mnist[,785]
numrow <- 28
numcol <- 28
userThresh <- 20
resfilename <- "tdaRes.txt"

# Call function and write results to file
res <- tda_wrapper_func(img, label, nr=numrow, nc=numcol, thresh=userThresh)
write.table(res, file=resfilename, row.names=FALSE, col.names=FALSE)

# Sample 1 random image from `img` and visualize it in matrix.
test_one_img(img, label, nr=numrow, nc=numcol, thresh=userThresh)