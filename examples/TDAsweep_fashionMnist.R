library(tdaImage)
library(liquidSVM)


TDAsweep_demo_fmnist <- function(){
# ------- loading fashion mnsit dataset ------- #
fashion_mnist <- read.csv("fashion-mnist_train.csv")

# ------- pre-processing for fashion mnist ------- #
fashion_mnist <- as.data.frame(fashion_mnist)
fashion_mnist$label <- as.factor(fashion_mnist$label)
set.seed(1)
train_idx = sample(seq_len(nrow(fashion_mnist)), 0.8*nrow(fashion_mnist))
train_set <- fashion_mnist[train_idx, -1]  # exclude label if doing tda
train_y_true <- fashion_mnist[train_idx, 1]
test_set <- fashion_mnist[-train_idx, -1]
test_y_true <- fashion_mnist[-train_idx, 1]

# ------- TDA Sweep ------- #
# sweep for train set. change parameter as needed
tda_train_set <- TDAsweep(train_set, train_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1)
tda_train_set <- as.data.frame(tda_train_set$tda_df)
tda_train_set$labels <- as.factor(tda_train_set$labels)

# sweep for test set. change parameter as needed
tda_test_set <- TDAsweep(test_set, test_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(25, 100), intervalWidth = 1)
tda_test_set <- as.data.frame(tda_test_set$tda_df)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -333]  # remove label column for generated test set


# ------- SVM ------- #
svm_model <- svm(labels ~., data=tda_train_set)  # train model
predict <- predict(svm_model, newdata = tda_test)

# Evaluate Model
confusionMatrix(as.factor(predict), as.factor(tda_test_label))
}
