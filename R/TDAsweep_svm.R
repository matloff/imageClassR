# library(tdaImage)
library(doMC)
library(caret)
library(snedata)
library(magick)
library(partools)
library(liquidSVM)

# --- parameters --- #
# images: dataframe or matrix of sets of vectors of image pixels
# labels: dataframe or vector of labels
# nr: integer; number of rows in image
# nc: integer; number of cols in image
# rgb: bool.; TRUE if images are RGB, otherwise greyscale
# thresholds: integer vector; thresholds for pixelss
# intervalWidth: integer; interval width for each sweep


# ------- useful settings ------- #
registerDoMC(cores=3)
tc <- trainControl(method = "cv", number = 4, verboseIter = F, allowParallel = T)
set.seed(10)


# ------- loading mnist dataset ------- #
# mnist <- read.csv("~/Downloads/mnist.csv")

# ------- pre-processing for mnist ------- #
# mnist <- as.data.frame(mnist)
# mnist$y <- as.factor(mnist$y)
# train_idx <- createDataPartition(mnist$y, p = 0.8, list = FALSE)
# train_set <- mnist[train_idx, -785]  # exclude label if doing tda
# train_y_true <- mnist[train_idx, 785]
# test_set <- mnist[-train_idx, -785]
# test_y_true <- mnist[-train_idx, 785]

# ------- loading fashion mnsit dataset ------- #
# fashion_mnist <- read.csv("~/Downloads/fashionmnist/fashion-mnist_train.csv")

# ------- pre-processing for fashion mnist ------- #
# fashion_mnist <- as.data.frame(fashion_mnist)
# fashion_mnist$label <- as.factor(fashion_mnist$label)
# train_idx <- createDataPartition(fashion_mnist$label, p=0.8, list = FALSE)
# # sample_n <- sample(nrow(fashion_mnist))
# # fashion_mnist <- fashion_mnist[sample_n, ]
# train_set <- fashion_mnist[train_idx, ]  # exclude label if doing tda
# train_y_true <- fashion_mnist[train_idx, 1]
# test_set <- fashion_mnist[-train_idx, -1]
# test_y_true <- fashion_mnist[-train_idx, 1]

# ------- loading fashion mnist dataset -------- #
# cifar <- download_cifar10()
# cifar <- cifar[, -3074]

# ------- pre-processing for cifar ------- #
# cifar <- as.data.frame(cifar)
# cifar$Label <- as.factor(cifar$Label)
# train_idx <- createDataPartition(cifar$Label, p = 0.8, list = FALSE)
# train_set <- cifar[train_idx, -3073]  # exclude label if doing tda
# train_y_true <- cifar[train_idx, 3073]
# test_set <- cifar[-train_idx, -3073]
# test_y_true <- cifar[-train_idx, 3073]

# ------- loading histology-mnist (28x28) -------- #
# histology_mnist_28 <- read.csv("~/Downloads/54223_103778_bundle_archive/hmnist_28_28_L.csv")

# ------- pre-processing for histology-mnist(28x28) ------- #
# histology_mnist_28 <- as.data.frame(histology_mnist_28)
# histology_mnist_28$label <- as.factor(histology_mnist_28$label)
# train_idx <- createDataPartition(histology_mnist_28$label, p = 0.8, list = FALSE)
# train_set <- histology_mnist_28[train_idx, -785]  # exclude label if doing tda
# train_y_true <- histology_mnist_28[train_idx, 785]
# test_set <- histology_mnist_28[-train_idx, -785]
# test_y_true <- histology_mnist_28[-train_idx, 785]


# ------- loading histology-mnist (64x64) -------- #
histology_mnist_64 <- read.csv("~/Downloads/54223_103778_bundle_archive/hmnist_64_64_L.csv")

# ------- pre-processing for histology-mnist(64x64) ------- #
histology_mnist_64 <- as.data.frame(histology_mnist_64)
histology_mnist_64$label <- as.factor(histology_mnist_64$label)
train_idx <- createDataPartition(histology_mnist_64$label, p = 0.8, list = FALSE)
train_set <- histology_mnist_64[train_idx, -4097]  # exclude label if doing tda
train_y_true <- histology_mnist_64[train_idx, 4097]
test_set <- histology_mnist_64[-train_idx, -4097]
test_y_true <- histology_mnist_64[-train_idx, 4097]

# ------- loading augmented histology-mnist (64x64) -------- #
# augmented_histology_mnist_64 <- read.csv("~/Downloads/augmented_hmnist64.csv")

# ------- pre-processing for augmented histology-mnist(64x64) ------- #
# augmented_histology_mnist_64 <- as.data.frame(augmented_histology_mnist_64)
# augmented_histology_mnist_64$label <- as.factor(augmented_histology_mnist_64$label)
# train_idx <- createDataPartition(augmented_histology_mnist_64$label, p = 0.8, list = FALSE)
# train_set <- augmented_histology_mnist_64[train_idx, ]  # exclude label if doing tda
# train_y_true <- augmented_histology_mnist_64[train_idx, 4097]
# test_set <- augmented_histology_mnist_64[-train_idx, -4097]
# test_y_true <- augmented_histology_mnist_64[-train_idx, 4097]


# ------- loading emnist ------- #
# emnist_train <- read.csv("~/Downloads/7160_10705_bundle_archive/emnist-balanced-train.csv")
# emnist_test <- read.csv("~/Downloads/7160_10705_bundle_archive/emnist-balanced-test.csv")
  
# ------- pre-processing for augmented histology-mnist(64x64) ------- #
# emnist_train$X45 <- as.factor(emnist_train$X45)
# emnist_test$X41 <- as.factor(emnist_test$X41)
# train_set <- emnist_train[, ]  # exclude label if doing tda
# train_y_true <- emnist_train[, 785]
# test_set <- emnist_test[, -785]
# test_y_true <- emnist_test[, 785]


# ------- load kuzushiji-mnist dataset ------- #
# load image files
# load_image_file = function(filename) {
#   ret = list()
#   f = file(filename, 'rb')
#   readBin(f, 'integer', n = 1, size = 4, endian = 'big')
#   n    = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
#   nrow = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
#   ncol = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
#   x = readBin(f, 'integer', n = n * nrow * ncol, size = 1, signed = FALSE)
#   close(f)
#   data.frame(matrix(x, ncol = nrow * ncol, byrow = TRUE))
# }
#
# # load label files
# load_label_file = function(filename) {
#   f = file(filename, 'rb')
#   readBin(f, 'integer', n = 1, size = 4, endian = 'big')
#   n = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
#   y = readBin(f, 'integer', n = n, size = 1, signed = FALSE)
#   close(f)
#   y
# }
#
# # load images
# kuzushiji_train = load_image_file("~/Downloads/89887_215882_bundle_archive/train-images-idx3-ubyte/train-images-idx3-ubyte")
# kuzushiji_test  = load_image_file("~/Downloads/89887_215882_bundle_archive/t10k-images-idx3-ubyte/t10k-images-idx3-ubyte")
#
# # load labels
# kuzushiji_train$y = as.factor(load_label_file("~/Downloads/89887_215882_bundle_archive/train-labels-idx1-ubyte/train-labels-idx1-ubyte"))
# kuzushiji_test$y  = as.factor(load_label_file("~/Downloads/89887_215882_bundle_archive/t10k-labels-idx1-ubyte/t10k-labels-idx1-ubyte"))

# ------- pre-processing for kuzushiji-mnist ------- #
# train_set <- kuzushiji_train[, -785]  # exclude label if doing tda
# train_y_true <- kuzushiji_train[, 785]
# test_set <- kuzushiji_test[, -785]
# test_y_true <- kuzushiji_test[, 785]



# ------- TDA Sweep ------- #
system.time(tda_train_set <- TDAsweep(train_set, train_y_true, nr=64, nc=64, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1))
dim(tda_train_set$tda_df)
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)

system.time(tda_test_set <- TDAsweep(test_set, test_y_true, nr=64, nc=64, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1))
dim(tda_test_set)
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -765]

# ------- SVM ------- #
system.time(svm_model <- train(label ~., data=train_set, method="svmRadial", trControl=tc))
predict <- predict(svm_model, newdata = test_set)
# CV
confusionMatrix(as.factor(predict), as.factor(test_y_true))




# ------- edge detection attempt ------- #
# rotate <- function(x) t(apply(x, 2, rev))
# edge_detect <- function(img){
#   dim(img) <- c(28,28,1)
#   img_mag <- magick::image_read(img/ 255) %>% magick::image_scale("28x28")
#   img_mag <- img_mag %>% image_quantize(colorspace = "gray")
#   edge_img <- img_mag %>% image_convolve('Sobel') %>% image_negate()
#   print(edge_img)
#   edge_img <- as.matrix(as.integer(image_data(edge_img)))  # already flatten
#   return(edge_img)
# }
#
# edge_mnist <- apply(mnist[,-1], 1, edge_detect)
# edge_mnist <- rotate(edge_mnist)
# edge_mnist <- cbind(edge_mnist, mnist[, 785])










# MNIST V1
# whole set: 97.56% accuracy
# 95% CI:(0.9732, 0.9778)

# tda on whole set: 96.82% accuracy (tda interval=1) 166
# 95% CI : (0.9655, 0.9708)

# tda on whole set: 0.9709 accuracy (tda interval=2) 85
# 95% CI : (0.9683, 0.9733)

# tda on whole set: 0.9706 accuracy (tda interval=3) 58
# 95% CI : (0.968, 0.973)


# FASHION MNIST
# tda on whole set: 89.6% accuracy (interval=2, thresh=100) 85
# 95% CI : (0.8872, 0.9043)
# Time (svm train) : user   system  elapsed
#                 20878.050   698.096  9177.334


# MNIST V2

# whole set: 97.9% accuracy
# 95% CI:(0.9746, 0.9828)
# Time (svm train) : user    system   elapsed
#               15799.457   607.704  7398.008


# tda on whole set: 97% accuracy (interval=2, thresh=100) 85
# 95% CI : ((0.9649, 0.9746))
# Time (tda train set): user   system  elapsed
#                   2359.068    3.802 2363.781
# Time (tda test set): user  system elapsed
#                   192.039   0.716 192.837
# Time (svm train) : user   system  elapsed
#                 1734.545  188.005  860.263

# tda on whole set: 97.86% accuracy (interval=2, thresh=(100,175)) 168
# 95% CI : (0.9742, 0.9824)
# Time (tda train set): user   system  elapsed
#                   4331.668    6.746 4339.500
# Time (tda test set): user  system elapsed
#                   348.885   1.344 350.240
# Time (svm train): user   system  elapsed
#               3044.832  217.805 1464.373



# Fashion Mnist
# tda on whole set: Accuracy : 0.8308 (interval=1, thresh=(100))
# 95% CI : (0.8201, 0.8411)
# Time (tda train set): user   system  elapsed
#                   4468.885    2.7    4472.015
# Time (tda test set): user  system elapsed
#                   413.078   0.752  413.851
# Time (svm train): user   system  elapsed
#               7035.283   406.805    3127.865


















































































































































