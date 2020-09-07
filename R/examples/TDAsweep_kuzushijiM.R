library(tdaImage)
library(doMC)
library(caret)
library(partools)
library(liquidSVM)


# ------- load kuzushiji-mnist dataset ------- #
# load image files
load_image_file = function(filename) {
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
load_label_file = function(filename) {
  f = file(filename, 'rb')
  readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  n = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  y = readBin(f, 'integer', n = n, size = 1, signed = FALSE)
  close(f)
  y
}

# load images
kuzushiji_train = load_image_file("~/Downloads/89887_215882_bundle_archive/train-images-idx3-ubyte/train-images-idx3-ubyte")
kuzushiji_test  = load_image_file("~/Downloads/89887_215882_bundle_archive/t10k-images-idx3-ubyte/t10k-images-idx3-ubyte")

# # load labels
kuzushiji_train$y = as.factor(load_label_file("~/Downloads/89887_215882_bundle_archive/train-labels-idx1-ubyte/train-labels-idx1-ubyte"))
kuzushiji_test$y  = as.factor(load_label_file("~/Downloads/89887_215882_bundle_archive/t10k-labels-idx1-ubyte/t10k-labels-idx1-ubyte"))

# ------- pre-processing for kuzushiji-mnist ------- #
train_set <- kuzushiji_train[, -785]  # exclude label if doing tda
train_y_true <- kuzushiji_train[, 785]
test_set <- kuzushiji_test[, -785]
test_y_true <- kuzushiji_test[, 785]

# ------- TDA Sweep ------- #
system.time(tda_train_set <- TDAsweep(train_set, train_y_true, nr=28, nc=28, rgb=TRUE, thresh=c(25, 100), intervalWidth = 1))
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)


system.time(tda_test_set <- TDAsweep(test_set, test_y_true, nr=64, nc=64, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1))
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -765]


# ------- SVM ------- #
system.time(svm_model <- train(labels ~., data=tda_train_set, method="svmRadial", trControl=tc))
predict <- predict(svm_model, newdata = tda_test)
# CV
confusionMatrix(as.factor(predict), as.factor(tda_test_label))