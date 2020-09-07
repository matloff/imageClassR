library(tdaImage)
library(doMC)
library(caret)


#---- data preparation ----#
mnist <- read.csv("~/Downloads/mnist.csv")
sample_n <- sample(nrow(mnist))
mnist <- mnist[sample_n, ]
mnist$y <- as.factor(mnist$y)
trainIndex = createDataPartition(mnist$y, p=0.7, list=FALSE)
train_set <- mnist[trainIndex, -785]  # exclude label if doing tda
train_y_true <- mnist[trainIndex, 785]
test_set <- mnist[-trainIndex, -785]
test_y_true <- mnist[-trainIndex, 785]

#---- parameters for performing TDAsweep ----#
nr = 28  # mnist is 28x28
nc = 28
rgb = FALSE  # mnist is grey scaled
thresholds = c(50)  # set one threshold, 50
intervalWidth = 1  # set intervalWidth to 1

#---- performing tda on train set ----#
tda_train_set <- tda_wrapper_func(image=train_set, labels=train_y_true, 
                                        nr=nr, nc=nc, rgb=rgb, thresh=thresholds,
                                        intervalWidth=intervalWidth)
dim(tda_train_set)  # 784 -> 166 features after TDAsweep
tda_train_set <- as.data.frame(tda_train_set)
tda_train_set$labels <- as.factor(tda_train_set$labels)

#---- performing tda on test set ----#
tda_test_set <- tda_wrapper_func(image=test_set, labels=test_y_true,
                                        nr=nr, nc=nc, rgb=rgb, thresh=thresholds,
                                        intervalWidth=intervalWidth)
dim(tda_test_set)
tda_test_set <- as.data.frame(tda_test_set)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -167]  # take out labels for testing the svm model later

#---- training and predicting using caret's svm model ----#
registerDoMC(cores=3)
tc <- trainControl(method = "cv", number = 4, verboseIter = F, allowParallel = T)
svm_model <- train(labels ~., data=tda_train_set, method = "svmRadial", trControl = tc)
predict <- predict(svm_model, newdata=tda_test)

#---- Evaluation ----#
confusionMatrix(as.factor(predict), as.factor(tda_test_label))

