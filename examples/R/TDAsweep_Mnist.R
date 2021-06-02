library(dimRedImage)
library(liquidSVM)
library(e1071)


TDAsweep_demo_mnist <- function(){
#---- data preparation ----#
mnist <- read.csv("~/Downloads/mnist.csv")
mnist$y <- as.factor(mnist$y)
set.seed(1)
train_idx <- sample(seq_len(nrow(mnist)), 0.8*nrow(mnist))
train_set <- mnist[train_idx, -785]  # exclude label if doing tda
train_y_true <- mnist[train_idx, 785]
test_set <- mnist[-train_idx, -785]
test_y_true <- mnist[-train_idx, 785]

#---- parameters for performing TDAsweep ----#
nr = 28  # mnist is 28x28
nc = 28
thresholds = c(100, 175) 
intervalWidth = 2  

#---- performing tda on train set ----#
system.time(tda_train_set <- TDAsweepImgSet(imgs=train_set, labels=train_y_true, 
                                        nr=nr, nc=nc, thresh=thresholds,
                                        intervalWidth=intervalWidth))
labels <- as.factor(tda_train_set[,58])
tda_train_set <- as.data.frame(tda_train_set[,-58])

#---- performing tda on test set ----#
system.time(tda_test_set <- TDAsweepImgSet(imgs=test_set, labels=test_y_true,
                                        nr=nr, nc=nc, thresh=thresholds,
                                        intervalWidth=intervalWidth))

tda_test_label <- as.factor(tda_test_set[, 58])
tda_test <- as.data.frame(tda_test_set[,-58])

#---- training and predicting using caret's svm model ----#
system.time(svm_model <- svm(labels ~., data=tda_train_set))
predict <- predict(svm_model, newdata=tda_test)

#---- Evaluation ----#
mean(predict == tda_test_label) # accuracy on test set

}
# TDAsweep_demo_mnist()
