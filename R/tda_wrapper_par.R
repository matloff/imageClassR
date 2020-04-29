source("~/Downloads/tdaImage-master/R/TDAprep.R")
source("~/Downloads/tdaImage-master/R/TDAsweep.R")
mnist <- read.csv("~/Downloads/mnist.csv")
library(partools)
# Updates:
# 1. (tested) RBG handling done, assuming intake vector (24x24x3 will be 1x1728 vector)
# 2. (tested) removed subset feature
# 3. (tested) added intervalWidth parameter
# 4. Found that "Bug" was because the picture was rotated. The code is correct


# parameters

# images: dataframe or matrix of sets of vectors of image pixels
# labels: dataframe or vector of labels
# nr: integer; number of rows in image
# nc: integer; number of cols in image
# rgb: bool.; TRUE if images are RGB, otherwise greyscale
# thresholds: integer vector; thresholds for pixels
# intervalWidth: integer; interval width for each sweep

tda_wrapper_func <- function(images, labels, nr, nc , rgb=TRUE, 
   thresholds = 0, intervalWidth=1, cls, prep=FALSE)
{
   if(is.null(cls)){  # default cluster
     cls <- makeCluster(detectCores()/2)
   }
   tdaOut <- NULL
   for (thresh in thresholds) {
      images_df <- as.data.frame(images)  
      if (rgb == TRUE) {  # run sweep three times, for R,G,B
         tda_result <- NULL  # will be the output after R,G,B sweeps
         one_layer_size <- nr*nc
         images_R = images_df[, 1:one_layer_size]  
         images_G = images_df[, (one_layer_size+1):(2*one_layer_size)]  
         images_B = images_df[, (2*one_layer_size+1):(3*one_layer_size)]  
         # run TDA Sweep for R, G, and B layers
         tda_result_R <- tda_sweep(images=images_R, labels=labels, 
            nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth, cls=cls, prep=prep)
         tda_result_G <- tda_sweep(images=images_G, labels=labels, 
            nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth, cls=cls, prep=prep)
         tda_result_B <- tda_sweep(images=images_B, labels=labels, 
            nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth, cls=cls, prep=prep)
         new_dataset <- cbind(tda_result_R, tda_result_G, tda_result_B)
      } else {  # greyscale
         tda_result <- tda_sweep(images=images_df, labels=labels, 
            nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth, cls=cls, prep=prep)
         new_dataset <- tda_result 
      }
      tdaOut <- cbind(tdaOut,new_dataset)
   }
   cbind(tdaOut,labels)
}

# basic pipeline function for tda-sweep in one set of images
tda_sweep <- function(images, labels, nr, nc, thresh, intervalWidth, cls, prep)
{  
    
    img_pixels <- images
    labels <- labels
    if(prep == FALSE){
      prepImgs <- prepImgSet(img_pixels, nr=nr, labels=labels, thresh=thresh)
    }
    else{
      prepImgs <- images
    }
    
    # sweep par
    setclsinfo(cls)
    imgsPerNode <- ceiling(nrow(img_pixels)/core_num)
    clusterExport(cls, varlist=c('nr', 'nc', 'intervalWidth' )
                  , envir=environment())
    temp <- list()
    prepImgs_split <- list()
    for(i in 1:core_num){
      temp$imgs <- prepImgs$imgs[(imgsPerNode*(i-1)+1):(imgsPerNode*i)]
      temp$thresh <- prepImgs$thresh[1]
      temp$nr <- prepImgs$nr[1]
      temp$labels <- prepImgs$labels[(imgsPerNode*(i-1)+1):(imgsPerNode*i)]
      prepImgs_split[i] <- list(temp)
    }
    clusterApply(cls, prepImgs_split, function(x){prepImgs_node <<- x; NULL})
    clusterEvalQ(cls, require('tdaImage'))
    print(system.time(res <- clusterEvalQ(cls, res <- 
                                            TDAsweepImgSet(
                                             prepImgs_node, nr=nr, nc=nc,
                                             intervalWidth=intervalWidth))))
    
    result <- do.call("rbind", res)  # combine results accross all clusters
    return(result)
    # print(system.time(TDAsweepImgSet(prepImgs, nr=nr, 
    #                                  nc=nc, intervalWidth=intervalWidth)))
}


mnist <- read.csv("~/Downloads/mnist.csv")  # just testing. No need for shuffle
mnist$y <- as.factor(mnist$y)
train_set <- mnist[1:800, -785]  # exclude label if doing tda
train_y_true <- mnist[1:800, 785]
a <- tda_wrapper_func(train_set, train_y_true, 28, 28, F, 
                      c(100), intervalWidth=1)

