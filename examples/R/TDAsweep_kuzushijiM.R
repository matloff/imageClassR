library(dimRedImage)
library(liquidSVM)


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
# ------- load kuzushiji-mnist dataset ------- #
# load images
kuzushiji_train = load_image_file("./89887_215882_bundle_archive/train-images-idx3-ubyte/train-images-idx3-ubyte")
kuzushiji_test  = load_image_file("./89887_215882_bundle_archive/t10k-images-idx3-ubyte/t10k-images-idx3-ubyte")

# # load labels
kuzushiji_train$y = as.factor(load_label_file("./89887_215882_bundle_archive/train-labels-idx1-ubyte/train-labels-idx1-ubyte"))
kuzushiji_test$y  = as.factor(load_label_file("./89887_215882_bundle_archive/t10k-labels-idx1-ubyte/t10k-labels-idx1-ubyte"))

# ------- pre-processing for kuzushiji-mnist ------- #
train_set <- kuzushiji_train[, -785]  # exclude label if doing tdas
train_y_true <- kuzushiji_train[, 785]
test_set <- kuzushiji_test[, -785]
test_y_true <- kuzushiji_test[, 785]

#---- parameters for performing TDAsweep ----#
nr = 28  # mnist is 28x28
nc = 28
thresholds = c(100, 175) 
intervalWidth = 2  

# ------- TDA Sweep ------- #
system.time(tda_train_set <- TDAsweepImgSet(imgs=train_set, labels=train_y_true,
                                      nr=nr, nc=nc, thresh=thresholds, 
                                      intervalWidth = intervalWidth))

labels <- as.factor(tda_train_set[,58])
tda_train_set <- as.data.frame(tda_train_set[,-58])


system.time(tda_test_set <- TDAsweepImgSet(imgs=test_set, labels=test_y_true, nr=nr,
                                     nc=nc, thresh=thresholds,
                                     intervalWidth = intervalWidth))

tda_test_label <- as.factor(tda_test_set[,58])
tda_test <- as.data.frame(tda_test_set[,-58])


# ------- SVM ------- #
svm_model <- svm(labels ~., data=tda_train_set)
predict <- predict(svm_model, newdata = tda_test)

# CV
mean(predict == tda_test_label) # accuracy on test set
# confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}
