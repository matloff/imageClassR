library(dimRedImage)
library(liquidSVM)
library(snedata)

TDAsweep_demo_cifar10 <- function(){

# ------- loading cifar dataset -------- #
cifar <- download_cifar10()
cifar <- cifar[, -3074]

# ------- pre-processing for cifar ------- #
cifar <- as.data.frame(cifar)
cifar$Label <- as.factor(cifar$Label)

set.seed(1)
train_idx = sample(seq_len(nrow(cifar)), 0.8*nrow(cifar))
train_set <- cifar[train_idx, -3073]  # exclude label column if doing TDAsweep
train_y_true <- cifar[train_idx, 3073]
test_set <- cifar[-train_idx, -3073]
test_y_true <- cifar[-train_idx, 3073]

#---- parameters for performing TDAsweep ----#
nr = 32  # mnist is 28x28
nc = 32
thresholds = c(100, 175) 
intervalWidth = 2  

# ------- TDA Sweep ------- #
# sweep for train set. change parameter as needed
system.time(tda_train_set <- TDAsweepImgSet(train_set, train_y_true, nr=nr,
                                            nc=nc, thresh=thresholds,
                                            intervalWidth = intervalWidth))
labels <- as.factor(tda_train_set[,66])
tda_train_set <- as.data.frame(tda_train_set[,-66])


# sweep for test set. change parameter as needed
system.time(tda_test_set <- TDAsweepImgSet(test_set, test_y_true, nr=nr,
                                           nc=nc, thresh=thresholds, 
                                           intervalWidth = intervalWidth))
tda_test_label <- as.factor(tda_test_set[,66])
tda_test <- as.data.frame(tda_test_set[,-66])

# ------- SVM ------- #
svm_model <- svm(labels ~., data=tda_train_set)  # train
predict <- predict(svm_model, newdata = tda_test)
# CV
confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}

