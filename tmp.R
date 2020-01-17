source("TDAmisc.R")

# Read data
mnist <- read.csv('mnist.csv')

# Make data into `images` and `labels` vector
images <- matrix(unlist(mnist[, 1:784]), ncol=784, byrow=TRUE)
labels <- as.matrix(mnist[785])
# TODO: found this in https://stackoverflow.com/a/13224720, but out of memory on
#  my (Eric Li) laptop

