source("TDAsweep.R")

# Read data
mnist <- read.csv('../mnist.csv')

# Make data into `images` matrix and `labels` vector
# images <- matrix(unlist(mnist[, 1:784]), ncol=784, byrow=TRUE)
images <- as.matrix(mnist[, 1:784])
labels <- as.matrix(mnist[785])
# found this in https://stackoverflow.com/a/13224720

# Plot data
for (i in 1:70000) {
	filled.contour(matrix(images[i, ], 28, byrow=T))
}

# Invoke TDAsweepOneImg?
TDAsweepOneImg(matrix(images[1,], ncol=28), 28, 28)

