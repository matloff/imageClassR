library(tdaImage)
library(liquidSVM)


# ------- load kuzushiji-mnist dataset ------- #
# Copyright 2008, Brendan O'Connor
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
# to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
# IN THE SOFTWARE.

load_image_file = function(filename) {  # function for extracting dataset from Brendan
  ret = list()
  f = file(filename, 'rb')
  readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  n    = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  nrow = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  ncol = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  x = readBin(f, 'integer', n = n * nrow * ncol, size = 1, signed = FALSE)
  close(f)
  data.frame(matrix(x, ncol = nrow * ncol, byrow = TRUE))
}

# load label files
load_label_file = function(filename) {  # function for extracting dataset from Brendan
  f = file(filename, 'rb')
  readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  n = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  y = readBin(f, 'integer', n = n, size = 1, signed = FALSE)
  close(f)
  y
}

TDAsweep_demo_kmnist <- function(){
# load images
kuzushiji_train = load_image_file("./89887_215882_bundle_archive/train-images-idx3-ubyte/train-images-idx3-ubyte")
kuzushiji_test  = load_image_file("./89887_215882_bundle_archive/t10k-images-idx3-ubyte/t10k-images-idx3-ubyte")

# # load labels
kuzushiji_train$y = as.factor(load_label_file("~/Downloads/89887_215882_bundle_archive/train-labels-idx1-ubyte/train-labels-idx1-ubyte"))
kuzushiji_test$y  = as.factor(load_label_file("~/Downloads/89887_215882_bundle_archive/t10k-labels-idx1-ubyte/t10k-labels-idx1-ubyte"))

# ------- pre-processing for kuzushiji-mnist ------- #
train_set <- kuzushiji_train[, -785]  # exclude label if doing tdas
train_y_true <- kuzushiji_train[, 785]
test_set <- kuzushiji_test[, -785]
test_y_true <- kuzushiji_test[, 785]

# ------- TDA Sweep ------- #
system.time(tda_train_set <- TDAsweep(train_set, train_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1, cls=4))
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)


system.time(tda_test_set <- TDAsweep(test_set, test_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1,cls=4))
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -333]  # remove label column for test set


# ------- SVM ------- #
svm_model <- svm(labels ~., data=tda_train_set)
predict <- predict(svm_model, newdata = tda_test)
# CV
mean(predict == tda_test_label) # accuracy on test set
# confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}
