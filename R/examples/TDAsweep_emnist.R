library(tdaImage)
library(doMC)
library(caret)
library(partools)
library(liquidSVM)

# ------- loading emnist train and test set ------- #
emnist_train <- read.csv("7160_10705_bundle_archive/emnist-balanced-train.csv")
emnist_test <- read.csv("7160_10705_bundle_archive/emnist-balanced-test.csv")

# ------- pre-processing for emnist ------- #
emnist_train$X45 <- as.factor(emnist_train$X45)
emnist_test$X41 <- as.factor(emnist_test$X41)
train_set <- emnist_train[, -785]  # exclude label if doing tda
train_y_true <- emnist_train[, 785]
test_set <- emnist_test[, -785]
test_y_true <- emnist_test[, 785]

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
system.time(svm_model <- train(labels ~., data=tda_train_set, method="svmRadial", trControl=tc))
predict <- predict(svm_model, newdata = tda_test)

# ------- Evaluate Model -------#
confusionMatrix(as.factor(predict), as.factor(tda_test_label))
