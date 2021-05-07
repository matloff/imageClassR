library(tdaImage)
library(liquidSVM)
library(e1071)

TDAsweep_demo_hmnist28 <- function(){

# ------- loading histology-mnist (28x28) -------- #
histology_mnist_28 <- read.csv("~/Downloads/54223_103778_bundle_archive/hmnist_28_28_L.csv")

# ------- pre-processing for histology-mnist(28x28) ------- #
histology_mnist_28 <- as.data.frame(histology_mnist_28)
histology_mnist_28$label <- as.factor(histology_mnist_28$label)
set.seed(1)
train_idx <- sample(seq_len(nrow(histology_mnist_28)), 0.8*nrow(histology_mnist_28))
train_set <- histology_mnist_28[train_idx, -785]  # exclude label if doing tda
train_y_true <- histology_mnist_28[train_idx, 785]
test_set <- histology_mnist_28[-train_idx, -785]
test_y_true <- histology_mnist_28[-train_idx, 785]

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

system.time(tda_test_set <- TDAsweepImgSet(imgs=test_set, labels=test_y_true, 
                                           nr=nr, nc=nc, thresh=thresholds,
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
# 
TDAsweep_demo_hmnist64 <- function(){

# ------- loading histology-mnist (64x64) -------- #
histology_mnist_64 <- read.csv("./54223_103778_bundle_archive/hmnist_64_64_L.csv")

# ------- pre-processing for histology-mnist(64x64) ------- #
histology_mnist_64 <- as.data.frame(histology_mnist_64)
histology_mnist_64$label <- as.factor(histology_mnist_64$label)
set.seed(1)
train_idx <- sample(seq_len(nrow(histology_mnist_64)), 0.8*nrow(histology_mnist_64))
train_set <- histology_mnist_64[train_idx, -4097]  # exclude label if doing tda
train_y_true <- histology_mnist_64[train_idx, 4097]
test_set <- histology_mnist_64[-train_idx, -4097]
test_y_true <- histology_mnist_64[-train_idx, 4097]

#---- parameters for performing TDAsweep ----#
nr = 64  # mnist is 28x28
nc = 64
thresholds = c(100, 175) 
intervalWidth = 2  

# ------- TDA Sweep ------- #
system.time(tda_train_set <- TDAsweepImgSet(imgs=train_set,
                                            labels=train_y_true, nr=nr, nc=nc, 
                                            intervalWidth = intervalWidth))
labels <- as.factor(tda_train_set[,194])
tda_train_set <- as.data.frame(tda_train_set[,-194])


system.time(tda_test_set <- TDAsweepImgSet(imgs=test_set, labels=test_y_true,
                                           nr=nr, nc=nc, thresh=thresholds,
                                           intervalWidth = intervalWidth))
tda_test_label <- as.factor(tda_test_set[,194])
tda_test <- as.data.frame(tda_test_set[,-194])

# ------- SVM ------- #
svm_model <- svm(labels ~., data=tda_train_set)
predict <- predict(svm_model, newdata = tda_test)
# CV
mean(predict == tda_test_label) # accuracy on test set
# confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}
