library(tdaImage)
library(liquidSVM)
library(e1071)
source("~/Downloads/regtools-master/R/Img.R")
source("~/Downloads/tdaImage-master/R/TDAsweep_wrapper_par.R")
getwd()
TDAsweep_demo_fmnist <- function(){

# ------- pre-processing for fashion mnist ------- #
train_set <- read.csv("./fashionmnist/fashion-mnist_train.csv")  # exclude label if doing tda
train_y_true <- train_set[, 1]
test_set <-  read.csv("./fashionmnist/fashion-mnist_test.csv")
test_y_true <- test_set[, 1]

# ------- TDA Sweep ------- #
# sweep for train set. change parameter as needed
system.time(tda_train_set <- TDAsweep(train_set[,-1], train_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(100), intervalWidth = 1, cls=4))
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)

# sweep for test set. change parameter as needed
system.time(tda_test_set <- TDAsweep(test_set[,-1], test_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(100), intervalWidth = 1, cls=4))
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -167]  # remove label column for generated test set


# ------- SVM ------- #
system.time(svm_model <- e1071::svm(labels ~., data=tda_train_set))  # train model
predict <- predict(svm_model, newdata = tda_test)

# Evaluate Model
mean(predict == tda_test_label) # accuracy on test set
# confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}
