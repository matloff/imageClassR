library(tdaImage)
library(doMC)
library(caret)
library(partools)
library(liquidSVM)


# ------- loading cifar dataset -------- #
cifar <- download_cifar10()
cifar <- cifar[, -3074]

# ------- pre-processing for cifar ------- #
cifar <- as.data.frame(cifar)
cifar$Label <- as.factor(cifar$Label)
train_idx <- createDataPartition(cifar$Label, p = 0.8, list = FALSE)
train_set <- cifar[train_idx, -3073]  # exclude label column if doing TDAsweep
train_y_true <- cifar[train_idx, 3073]
test_set <- cifar[-train_idx, -3073]
test_y_true <- cifar[-train_idx, 3073]

# ------- TDA Sweep ------- #
# sweep for train set. change parameter as needed
system.time(tda_train_set <- TDAsweep(train_set, train_y_true, nr=28, nc=28, rgb=TRUE, thresh=c(25, 100), intervalWidth = 1))
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)

# sweep for test set. change parameter as needed
system.time(tda_test_set <- TDAsweep(test_set, test_y_true, nr=64, nc=64, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1))
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -765]


# ------- SVM ------- #
system.time(svm_model <- train(labels ~., data=tda_train_set, method="svmRadial", trControl=tc))  # train
predict <- predict(svm_model, newdata = tda_test)
# CV
confusionMatrix(as.factor(predict), as.factor(tda_test_label))
