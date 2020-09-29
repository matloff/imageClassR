library(tdaImage)
source("~/Downloads/tdaImage-master/R/TDAsweep_wrapper_par.R")
library(liquidSVM)


detectCores()
TDAsweep_demo_emnist <- function(){
# ------- loading emnist train and test set ------- #
emnist_train <- read.csv("./7160_10705_bundle_archive/emnist-balanced-train.csv")
emnist_test <- read.csv("./7160_10705_bundle_archive/emnist-balanced-test.csv")

# ------- pre-processing for emnist ------- #
emnist_train$X45 <- as.factor(emnist_train$X45)
emnist_test$X41 <- as.factor(emnist_test$X41)
train_set <- emnist_train[, -1]  # exclude label if doing tda
train_y_true <- emnist_train[, 1]
test_set <- emnist_test[, -1]
test_y_true <- emnist_test[, 1]

dim(train_set)

# ------- TDA Sweep ------- #
# sweep for train set. change parameter as needed
system.time(tda_train_set <- TDAsweep(train_set, train_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1, cls=4))
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)

# sweep for test set. change parameter as needed
system.time(tda_test_set <- TDAsweep(test_set, test_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1, cls=4))
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -333]


# ------- SVM ------- #
system.time(svm_model <- liquidSVM::svm(labels ~., tda_train_set))
predict <- predict(svm_model, newdata = tda_test)

# ------- Evaluate Model -------#
mean(predict == tda_test_label) # accuracy on test set
# confusionMatrix(as.factor(predict), as.factor(tda_test_label))

}
