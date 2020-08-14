library(tdaImage)
library(doMC)
library(caret)
library(partools)
library(liquidSVM)


# ------- loading histology-mnist (28x28) -------- #
histology_mnist_28 <- read.csv("~/Downloads/54223_103778_bundle_archive/hmnist_28_28_L.csv")

# ------- pre-processing for histology-mnist(28x28) ------- #
histology_mnist_28 <- as.data.frame(histology_mnist_28)
histology_mnist_28$label <- as.factor(histology_mnist_28$label)
train_idx <- createDataPartition(histology_mnist_28$label, p = 0.8, list = FALSE)
train_set <- histology_mnist_28[train_idx, -785]  # exclude label if doing tda
train_y_true <- histology_mnist_28[train_idx, 785]
test_set <- histology_mnist_28[-train_idx, -785]
test_y_true <- histology_mnist_28[-train_idx, 785]


# ------- loading histology-mnist (64x64) -------- #
# histology_mnist_64 <- read.csv("~/Downloads/54223_103778_bundle_archive/hmnist_64_64_L.csv")

# ------- pre-processing for histology-mnist(64x64) ------- #
# histology_mnist_64 <- as.data.frame(histology_mnist_64)
# histology_mnist_64$label <- as.factor(histology_mnist_64$label)
# train_idx <- createDataPartition(histology_mnist_64$label, p = 0.8, list = FALSE)
# train_set <- histology_mnist_64[train_idx, -4097]  # exclude label if doing tda
# train_y_true <- histology_mnist_64[train_idx, 4097]
# test_set <- histology_mnist_64[-train_idx, -4097]
# test_y_true <- histology_mnist_64[-train_idx, 4097]

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