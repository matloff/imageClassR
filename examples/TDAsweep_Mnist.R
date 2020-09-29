library(tdaImage)
library(liquidSVM)
library(e1071)
source("~/Downloads/regtools-master/R/Img.R")
source("~/Downloads/tdaImage-master/R/TDAsweep_wrapper_par.R")


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
rgb = FALSE  # mnist is grey scaled
thresholds = c(100, 175)  # set one threshold, 50
intervalWidth = 2  # set intervalWidth to 2

#---- performing tda on train set ----#
system.time(tda_train_set <- TDAsweep(image=train_set, labels=train_y_true, 
                                        nr=nr, nc=nc, rgb=rgb, thresh=thresholds,
                                        intervalWidth=intervalWidth, cls=4))
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)

#---- performing tda on test set ----#
system.time(tda_test_set <- TDAsweep(image=test_set, labels=test_y_true,
                                        nr=nr, nc=nc, rgb=rgb, thresh=thresholds,
                                        intervalWidth=intervalWidth, cls=4))
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -167]  # take out labels for testing the svm model later

#---- training and predicting using caret's svm model ----#
system.time(svm_model <- svm(labels ~., data=tda_train_set))
predict <- predict(svm_model, newdata=tda_test)

#---- Evaluation ----#
mean(predict == tda_test_label) # accuracy on test set

}
# TDAsweep_demo_mnist()
