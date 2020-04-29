library(tdaImage)
library(doMC)
library(caret)
library(snedata)
library(magick)
# make labels factors?
# settings
registerDoMC(cores=3)
tc <- trainControl(method = "cv", number = 4, verboseIter = F, allowParallel = T)
set.seed(10)

edge_mnist[0,]

# loading mnist dataset
mnist <- read.csv("~/Downloads/mnist.csv")
rotate <- function(x) t(apply(x, 2, rev))
edge_detect <- function(img){
  dim(img) <- c(28,28,1)
  img_mag <- magick::image_read(img/ 255) %>% magick::image_scale("28x28") 
  img_mag <- img_mag %>% image_quantize(colorspace = "gray")
  edge_img <- img_mag %>% image_convolve('Sobel') %>% image_negate()
  print(edge_img)
  edge_img <- as.matrix(as.integer(image_data(edge_img)))  # already flatten
  return(edge_img)
}

edge_mnist <- apply(mnist[,-1], 1, edge_detect)
edge_mnist <- rotate(edge_mnist)
edge_mnist <- cbind(edge_mnist, mnist[, 785])


# loading fashion mnist dataset
# cifar <- download_cifar10()
# cifar <- cifar[, -3074]

# train-test split
# fashion_mnist$Label <- as.factor(cifar$Label)
# train_idx <- createDataPartition(cifar$Label, p = 0.93, list = FALSE)
# train_set <- cifar[train_idx, -3073]  # exclude label if doing tda
# train_y_true <- cifar[train_idx, 3073]
# test_set <- cifar[-train_idx, -3073]
# test_y_true <- cifar[-train_idx, 3073]
edge_mnist <- as.data.frame(edge_mnist)
# train-test split
sample_n <- sample(nrow(edge_mnist))
edge_mnist <- edge_mnist[sample_n, ]
edge_mnist$V785 <- as.factor(edge_mnist$V785)
train_set <- edge_mnist[1:65000, -785]  # exclude label if doing tda
train_y_true <- edge_mnist[1:65000, 785]
test_set <- edge_mnist[65001:70000, -785]
test_y_true <- edge_mnist[65001:70000, 785]


# levels(train_y_true)
# drop columns with all 0s
# nzv.data <- nearZeroVar(train_set, saveMetrics = TRUE)
# drop.cols <- rownames(nzv.data)[nzv.data$nzv == TRUE]
# train_set <- train_set[,!names(train_set) %in% drop.cols]
# test_set <- test_set[,!names(test_set) %in% drop.cols]

# Running TDA Sweep on train and test set
system.time(tda_train_set <- tda_wrapper_func(train_set, train_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(100), intervalWidth = 1))
dim(tda_train_set)
tda_train_set <- as.data.frame(tda_train_set)
tda_train_set$labels <- as.factor(tda_train_set$labels)

system.time(tda_test_set <- tda_wrapper_func(test_set, test_y_true, nr=28, nc=28, rgb=FALSE, thresh=c(100), intervalWidth = 1))
dim(tda_test_set)
tda_test_set <- as.data.frame(tda_test_set)
tda_test_label <- tda_test_set$labels
tda_test <- tda_test_set[, -167]
# 
# 
# unique(tda_train_set$labels)
# training and predicting svm model (normal)
# system.time(svm_model <- train(y ~., data= train_set, method = "svmRadial", trControl = tc, scale=FALSE))
# predict <- predict(svm_model, newdata = test_set)
# class(predict)
# # CV
# confusionMatrix(as.factor(predict), as.factor(test_y_true))

# MNIST V1
# whole set: 97.56% accuracy
# 95% CI:(0.9732, 0.9778)

# tda on whole set: 96.82% accuracy (tda interval=1) 166
# 95% CI : (0.9655, 0.9708)

# tda on whole set: 0.9709 accuracy (tda interval=2) 85
# 95% CI : (0.9683, 0.9733)

# tda on whole set: 0.9706 accuracy (tda interval=3) 58
# 95% CI : (0.968, 0.973)

# MNIST V2

# whole set: 97.9% accuracy
# 95% CI:(0.9746, 0.9828)
# Time (svm train) : user    system   elapsed 
#               15799.457   607.704  7398.008 


# tda on whole set: 97% accuracy (interval=2, thresh=100) 85
# 95% CI : ((0.9649, 0.9746))
# Time (tda train set): user   system  elapsed 
#                   2359.068    3.802 2363.781 
# Time (tda test set): user  system elapsed 
#                   192.039   0.716 192.837 
# Time (svm train) : user   system  elapsed 
#                 1734.545  188.005  860.263

# tda on whole set: 97.86% accuracy (interval=2, thresh=(100,175)) 168
# 95% CI : (0.9742, 0.9824)
# Time (tda train set): user   system  elapsed 
#                   4331.668    6.746 4339.500 
# Time (tda test set): user  system elapsed 
#                   348.885   1.344 350.240
# Time (svm train): user   system  elapsed 
#               3044.832  217.805 1464.373 


# training and predicting svm model (with tda)
system.time(svm_model <- train(labels ~., data=tda_train_set, method="svmRadial", trControl=tc))
predict <- predict(svm_model, newdata = tda_test)


# CV
confusionMatrix(as.factor(predict), as.factor(tda_test_label))















































































































































