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

# ------- TDA Sweep ------- #
system.time(tda_train_set <- TDAsweep(train_set, train_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1, cls=4))
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)


system.time(tda_test_set <- TDAsweep(test_set, test_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1, cls=4))
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -333]

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

# ------- TDA Sweep ------- #
system.time(tda_train_set <- TDAsweep(train_set, train_y_true, nr=64, nc=64, rgb=FALSE, thresh=c(50), intervalWidth = 1, cls=4))
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)


system.time(tda_test_set <- TDAsweep(test_set, test_y_true, nr=64, nc=64, rgb=FALSE, thresh=c(50), intervalWidth = 1, cls=4))
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -765]  # remove label column for test set


# ------- SVM ------- #
svm_model <- svm(labels ~., data=tda_train_set)
predict <- predict(svm_model, newdata = tda_test)
# CV
mean(predict == tda_test_label) # accuracy on test set
# confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}
