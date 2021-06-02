library(tdaImage)
library(liquidSVM)

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

#---- parameters for performing TDAsweep ----#
nr = 28  # mnist is 28x28
nc = 28
thresholds = c(100, 175) 
intervalWidth = 2  

# ------- TDA Sweep ------- #
# sweep for train set. change parameter as needed
system.time(tda_train_set <- TDAsweepImgSet(imgs=train_set,
                                            labels=train_y_true, nr=nr, nc=nc,
                                            thresh=thresholds,
                                            intervalWidth = intervalWidth))
labels <- as.factor(tda_train_set[,58])
tda_train_set <- as.data.frame(tda_train_set[,-58])

# sweep for test set. change parameter as needed
system.time(tda_test_set <- TDAsweepImgSet(imgs=test_set, labels=test_y_true,
                                           nr=nr, nc=nc, thresh=thresholds,
                                           intervalWidth = intervalWidth))
tda_test_label <- as.factor(tda_test_set[,58])
tda_test <- as.data.frame(tda_test_set[,-58])

# ------- SVM ------- #
system.time(svm_model <- liquidSVM::svm(labels ~., tda_train_set))
predict <- predict(svm_model, newdata = tda_test)

# ------- Evaluate Model -------#
mean(predict == tda_test_label) # accuracy on test set
# confusionMatrix(as.factor(predict), as.factor(tda_test_label))

}
