library(regtools)
source("~/Downloads/tdaImage-master/R/TDAsweep.R")
source("~/Downloads/tdaImage-master/R/TDAprep.R")

# Questions:
# 1. is the user going to put in raw images, or are they going to do some processing to make it like csv MNIST?
# 2. Do we need subset parameter? Or is it better to let the user just subset themselves?

# Todo:
# 1. finish RGB handling
# 2. make the code read from the user input images
# 3. test out and de-bug


tda_wrapper_func <- function(images, nr, nc, subset = NULL, tresh = 0){
  
  ############################## this part would be reading or processing the image/csv data from the user ##############################
  mnist <- read.csv("~/Downloads/mnist.csv")   
  
  ############################## Semi-Pseudocode for handling RGB images ####################################
  if(RGB == TRUE){  # run sweep three times
    tda_result <- NULL  # list to append later for R,G,B sweeps
    images_R = images[,,1]  # R layer
    images_G = images[,,2]  # G layer
    images_B = images[,,3]  # B layer
    for(images in c(images_R, images_G, images_B)){ 
      tda_result <- c(tda_result, tda_sweep(images=images, nr=nr, nc=nc, subset=subset, thresh=thresh))
    }
    return(tda_result)
  }else{  # run sweep one time
    tda_result <- tda_sweep(images=images, nr=nr, nc=nc, subset=subset, thresh=thresh)
    return(tda_result)
  }
  
  
  tda_sweep <- function(images=images, nr=nr, nc=nc, subset=subset, thresh=thresh){  # basic pipeline function for tda-sweep in one set of images
    
    ############################## this part is checking if the user wants subset and preparing features and labels data ##############################
    #if(is.null(subset)){  # if the user wants to subset
      img_pixels <- mnist[, -785]
      labels <- mnist[, 785]
    #}#else{  # if the user wants every row
     # set.seed(999) 
      #n <- sample(1:nrow(mnist), subset)  
      #img_pixels <- mnist[n, -785]
      #labels <- mnist[n, 785]
    #}
    
    ############################## this part is processing the data using prepImgSet ##############################
    prepImgs <- prepImgSet(img_pixels, nr=nr, labels=labels, thresh=thresh)  
    
    ############################## this part is performing TDASweep ##############################
    sweep_result <- TDAsweepImgSet(prepImgs, nr=nr, nc=nc)
  
    return(sweep_result)
  }
}