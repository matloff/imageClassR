library(dimRedImage)
library(liquidSVM)
library(e1071)


TDAsweep_demo_fmnist <- function(){

# ------- pre-processing for fashion mnist ------- #
train_set <- read.csv("./fashionmnist/fashion-mnist_train.csv")  # exclude label if doing tda
train_y_true <- train_set[, 1]
test_set <-  read.csv("./fashionmnist/fashion-mnist_test.csv")
test_y_true <- test_set[, 1]

#---- parameters for performing TDAsweep ----#
nr = 28  # mnist is 28x28
nc = 28
thresholds = c(100, 175) 
intervalWidth = 2  

# ------- TDA Sweep ------- #
# sweep for train set. change parameter as needed
system.time(tda_train_set <- TDAsweepImgSet(imgs=train_set[,-1],
                                            labels=train_y_true, nr=nr, nc=nc,
                                            thresh=thresholds,
                                            intervalWidth = intervalWidth))
labels <- as.factor(tda_train_set[,58])
tda_train_set <- as.data.frame(tda_train_set[,-58])

# sweep for test set. change parameter as needed
system.time(tda_test_set <- TDAsweepImgSet(imgs=test_set[,-1],
                                           labels=test_y_true, nr=nr, nc=nc,
                                           thresh=thresholds, 
                                           intervalWidth = intervalWidth))
tda_test_label <- as.factor(tda_test_set[,58])
tda_test <- as.data.frame(tda_test_set[,-58])


# ------- SVM ------- #
system.time(svm_model <- e1071::svm(labels ~., data=tda_train_set))  # train model
predict <- predict(svm_model, newdata = tda_test)

# Evaluate Model
mean(predict == tda_test_label) # accuracy on test set
# confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}
