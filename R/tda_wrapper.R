library(regtools)
source("~/Downloads/tdaImage/R/TDAsweep.R")
source("~/Downloads/tdaImage/R/TDAprep.R")

# Updates:
# 1. (tested) rbg handling done, assuming intake vector (24x24x3 will be 1x1728 vector)
# 2. (tested) removed subset feature
# 3. (tested) added intervalWidth parameter
# 4. Found that "Bug" was because the picture was rotated. The code is correct


# Parameters
# images: dataframe or matrix of sets of vectors of image pixels
# labels: dataframe or vector of sets of labels
# nr: Integer. Number of row of image
# nc: Integer. Number of col of image
# rgb: Bool. If images are rgb or grey scale
# thresh: Integer. Threshold for pixels
# intervalWidth: Integer. Interval Width for each sweep

tda_wrapper_func <- function(images, labels, nr, nc , rgb=TRUE, thresh = 0, intervalWidth=1){
  
  tda_sweep <- function(images, labels, nr, nc, thresh, intervalWidth){  # basic pipeline function for tda-sweep in one set of images
    
    ############################## Data preparation ##############################
    img_pixels <- images
    labels <- labels
    
    ############################## Processing data ##############################
    prepImgs <- prepImgSet(img_pixels, nr=nr, labels=labels, thresh=thresh)
    
    ############################## TDASweep ##############################
    sweep_result <- TDAsweepImgSet(prepImgs, nr=nr, nc=nc, intervalWidth=intervalWidth)
    
    return(sweep_result)
  }
  
  ############################## Reading the csv data from the user ##############################
  images_df <- as.data.frame(images)  
  labels <- labels
  
  ############################## Handling RGB images ####################################
  if(rgb == TRUE){  # run sweep three times
    tda_result <- NULL  # list to append later for R,G,B sweeps
    one_layer_size <- nr*nc
    images_R = images_df[, 1:one_layer_size]  # R layer
    images_G = images_df[, (one_layer_size+1):(2*one_layer_size)]  # G layer
    images_B = images_df[, (2*one_layer_size+1):(3*one_layer_size)]  # B layer
    # Run TDA Sweep for R, G, and B layers
    tda_result_R <- tda_sweep(images=images_R, labels=labels, nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth)
    tda_result_G <- tda_sweep(images=images_G, labels=labels, nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth)
    tda_result_B <- tda_sweep(images=images_B, labels=labels, nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth)
    new_dataset <- cbind(tda_result_R, tda_result_G, tda_result_B, labels)
    return(new_dataset)
  }else{  # when rgb=FALSE
    tda_result <- tda_sweep(images=images_df, labels=labels, nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth)
    new_dataset <- cbind(tda_result, labels)
    return(new_dataset)
  }
}


test_one_img <- function(imgset, labels, nr, nc, rgb=FALSE, thresh=0, intervalWidth=1) {
  idx <- sample(1:nr, 1)
  img2d <- imgTo2D(imgset[idx,], nr)
  label <- labels[idx]
  print(label)
  print(matrix(img2d[,3], nr, nc))
  res <- prepOneImage(img2d, thresh)
  res <- TDAsweepOneImg(res, nr, nc)
  return (res)
}
