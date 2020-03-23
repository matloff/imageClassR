
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
   thresholds = 0, intervalWidth=1)
{
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
            nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth)
         tda_result_G <- tda_sweep(images=images_G, labels=labels, 
            nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth)
         tda_result_B <- tda_sweep(images=images_B, labels=labels, 
            nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth)
         new_dataset <- cbind(tda_result_R, tda_result_G, tda_result_B)
      } else {  # greyscale
         tda_result <- tda_sweep(images=images_df, labels=labels, 
            nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth)
         new_dataset <- tda_result 
      }
      tdaOut <- cbind(tdaOut,new_dataset)
   }
   cbind(tdaOut,labels)
}

# basic pipeline function for tda-sweep in one set of images
tda_sweep <- function(images, labels, nr, nc, thresh, intervalWidth)
{  
    img_pixels <- images
    labels <- labels
    prepImgs <- prepImgSet(img_pixels, nr=nr, labels=labels, thresh=thresh)
    TDAsweepImgSet(prepImgs, nr=nr, nc=nc, intervalWidth=intervalWidth)
}

test_one_img <- 
   function(imgset, labels, nr, nc, rgb=FALSE, thresh=0, intervalWidth=1) 
{
  idx <- sample(1:nr, 1)
  img2d <- imgTo2D(imgset[idx,], nr)
  label <- labels[idx]
  print(label)
  print(matrix(img2d[,3], nr, nc))
  res <- prepOneImage(img2d, thresh)
  TDAsweepOneImg(res, nr, nc)
}

