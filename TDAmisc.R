
library(TDAstats)
library(regtools)
library(pdist)

# overview

# persistent homology:

# homStat():  inputs an image, consists of (i,j) pairs as above;
#    calculates Vietoris-Rips homology; outputs a vector of binned birth
#    and death times, to be used as a feature vector in classification
 
# imgsHomStat(): inputs output of prepImgSet(); for each element,

#    applies homStat() to matrix; outputs an R list, consisting of a
#    matrix of TDA feature vectors and class labels; so row i of the
#    matrix is the feature vector for the i-th image in the training
#    set, and element i of the labels vector is the associated class
#    label; in the matrix, number of rows = number of images in the
#    training image collection, number of cols = number of bins 

# predictTDA(): inputs the output from imgsHomStat() and an image
#    in 1-row form; converts to (i,j) pixel form, and inputs to
#    prepOneImage(); the outputted feature vector is then compared to
#    the training set matrix of feature vectors; the closest one is
#    determined, and our predicted label will be the associated training
#    set label


####################  persistent hom. ops  ##########################

# apply PH to 'img', returning vector of proportions of bars in the bins
# of width 'w' between 'lt' and 'rt'; dim 1 only for now; 'img' is a
# matrix

# 'img' will be treated as a point cloud

# returns vector of bin proportions for births then deaths

homStat.old <- function(img,lt,rt,w) 
{
   chOut <- calculate_homology(img)
   # get dim 1 births, deaths
   births <- chOut[chOut[,1] == 0,2]
   deaths <- chOut[chOut[,1] == 0,3]
   brks <- seq(lt,rt,w)
   if (min(births) < lt || max(deaths) > rt) {
      warning('max values, b and d: ',max(births),' ',max(deaths),'\n')
      return(rep(NA,2*(length(brks)-1)))
   }
   bprop <- hist(births,brks,plot=FALSE)$counts / nrow(img)
   dprop <- hist(deaths,brks,plot=FALSE)$counts / nrow(img)
   c(bprop,dprop)
}

# like homStat.old(), but using proportions on the 2D birth-death plane

homStat <- function(img,lt,rt,w) 
{
   chOut <- calculate_homology(img)
   # get dim 1 births, deaths
   births <- chOut[chOut[,1] == 0,2]
   deaths <- chOut[chOut[,1] == 0,3]
   keep <- which(births >= lt && deaths <= rt)
   births <- births[keep]
   deaths <- deaths[keep]
   brks <- c(-Inf,seq(lt,rt,w),Inf)
   counts <- hist2(births,deaths,brks,brks)
   # below diag all 0s (birth > death)
   counts <- counts[upper.tri(counts)]
   as.vector(counts) / sum(counts)
}

# imgList is output of prepImgSet()

imgsHomStat <- function(imgList,lt,rt,w) {
   doOnePreppedImg <- function(img) homStat(img[[1]],lt,rt,w)
   homMat <- t(sapply(imgList$imgs,doOnePreppedImg))
   l <- list(homMat=homMat,lt=lt,rt=rt,w=w,thresh=imgList$thresh,
      labels=imgList$labels,nr=imgList$nr)
   class(l) <- 'homElt'
   l
}

predict.homElt <- function(ihsOut,newImg,k=10) {
   lt <- ihsOut$lt
   rt <- ihsOut$rt
   w <- ihsOut$w
   nr <- ihsOut$nr
   thresh <- ihsOut$thresh
   newImg <- imgTo2D(newImg,nr)
   newImg <- prepOneImage(newImg,thresh) 
   hs <- homStat(newImg,lt,rt,w)
   pdout <- pdist(hs,ihsOut$homMat)
   # wm <- which.min(pdout@dist)
   dists <- pdout@dist
   do <- order(dists)
   # ihsOut$labels[wm]
   dok <- do[1:k]
   dokl <- ihsOut$labels[dok]
   findMode(dokl)
}

# which number appears the most?
findMode <- function(x) 
{
   tbl <- table(x)
   wm <- which.max(tbl)
   as.numeric(names(tbl)[wm])
}

# display pixel locations of 'img', an element from the output of
# prepImgSet(); locations are assumed between 0 and 'ub'; the resulting
# image will be saved in a file named 'name'

########################  2-D histograms  ###########################

# counts for a 2-dimensional histogram

# differs from gplots:hist2d() in that the breaks are specified, rather
# than the number of bins, so can use the same breaks in each image

hist2 <- function(x,y,brksx,brksy) {
   xb <- split(x,c(-Inf,brksx,Inf))
   yb <- split(y,c(-Inf,brksx,Inf))
   counts <- tapply(1:length(x),list(xb,yb),length)
   counts[is.na(counts)] <- 0
   counts
}

dispImg <- function(img,ub,name) 
{
   img <- img[[1]]  # the actual pixel locations matrix
   # set up uniform bounding box by adding 2 fake pixels
   img <- rbind(img,c(0,0),c(35,35))
   img <- rotrt90flip(img,ub)
   plot(img)
   pr2file(name)
   img
}

addRedLine <- function(img,ht,name) 
{
   abline(a=ht,b=0,col='red')
   pr2file(name)
} 

# rotate right, then flip, so MNIST comes out right; 'img' is a pixels
# locations matrix, with values between 0 and 'ub'
rotrt90flip <- function(img,ub)
{
   nr <- nrow(img)
   # rotate
   img <- img[,2:1]
   # flip
   tmp <- ub+1 - img[,2]
   img[,2] <- tmp
   img
}

# data prep:

# prepImgSet():  inputs image collection matrix, one image per row, 
#    an associated vector of class labels, the number of pixel rows in
#    each image, and the threshold; outputs an R list, each element
#    consisting of a pixels locations matrix, the index of the original
#    image in the input data, and the class label; the matrix has pixels
#    passing above the threshold, each pixel as an (row number,col
#    number) pair

# arguments:
 
#    imgs: matrix or data frame of image data, one row per image
#    nr: number of rows per image, cols stored in col-major order
#    thresh: only pixels with intensity at least this value
#       will be chosen
 
# value:
 
#    2-column matrix of (row,column) coordinates of the selected pixels

prepImgSet <- function(imgs,nr,labels,thresh) 
{
   pOI <- function(oneImgRow) {
      img2D <- imgTo2D(imgs[oneImgRow,],nr)
      img <- prepOneImage(img2D,thresh)
      list(img,oneImgRow,labels[oneImgRow])
   }
   imgs <- lapply(1:nrow(imgs),pOI)
   list(imgs=imgs,thresh=thresh,nr=nr,labels=labels)
}

# img2D is output of imgTo2D() for a single image; nr, thresh as above

prepOneImage <- function(img2D,thresh) 
{
   aboveThresh <- which(img2D[,3] >= thresh)
   if (length(aboveThresh) < 2) returnImg <- NA
   else returnImg <- img2D[aboveThresh,1:2,drop=FALSE]
   returnImg
}

