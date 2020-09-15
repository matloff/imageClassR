library(tdaImage)
library(doMC)
library(caret)
library(partools)
library(liquidSVM)


TDAsweep_demo_fmnist <- function(){
# ------- loading fashion mnsit dataset ------- #
fashion_mnist <- read.csv(fashion-mnist_train.csv")

# ------- pre-processing for fashion mnist ------- #
fashion_mnist <- as.data.frame(fashion_mnist)
fashion_mnist$label <- as.factor(fashion_mnist$label)
train_idx <- createDataPartition(fashion_mnist$label, p=0.8, list = FALSE)
sample_n <- sample(nrow(fashion_mnist))
fashion_mnist <- fashion_mnist[sample_n, ]
train_set <- fashion_mnist[train_idx, -1]  # exclude label if doing tda
train_y_true <- fashion_mnist[train_idx, 1]
test_set <- fashion_mnist[-train_idx, -1]
test_y_true <- fashion_mnist[-train_idx, 1]

# ------- TDA Sweep ------- #
# sweep for train set. change parameter as needed
tda_train_set <- TDAsweep(train_set, train_y_true, nr=28, nc=28, rgb=TRUE, thresh=c(25, 100), intervalWidth = 1)
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)

# sweep for test set. change parameter as needed
tda_test_set <- TDAsweep(test_set, test_y_true, nr=28, nc=28, rgb=TRUE, thresh=c(25, 100), intervalWidth = 1)
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -997]  # remove label column for generated test set


# ------- SVM ------- #
svm_model <- train(labels ~., data=tda_train_set, method="svmRadial", trControl=tc)  # train model
predict <- predict(svm_model, newdata = tda_test)

# Evaluate Model
confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}
