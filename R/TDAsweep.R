
# TDAsweep routines; makes use of prep* in TDAprep

# main function is TDAsweepImgSet(), which operates on a set of images;
# usage:  input a matrix of images, 1 image per row; apply prepImgSet();
# feed output of latter into TDAsweepImgSet()

# example:

# 1-image "set" of images, each image 2x6 pixels

# > imgEx <- rbind(c(0,0,1,0,1,1),c(1,0,1,0,0,1))
# > imgEx
#      [,1] [,2] [,3] [,4] [,5] [,6]
# [1,]    0    0    1    0    1    1
# [2,]    1    0    1    0    0    1
# > lbls <- 2  # label for this image
# > imgExMatrix <- matrix(c(imgEx[1,],imgEx[2,]),nrow=1)
# > prepout <- prepImgSet(imgExMatrix,2,lbls,0.5)
# > prepout
# $imgs
# $imgs[[1]]   1st image (of 1)
# $imgs[[1]][[1]]  "img2D" form of that image, e.g. a 1 in row 1, col 5
#        j
# [1,] 2 1
# [2,] 1 3
# [3,] 2 3
# [4,] 1 5
# [5,] 1 6
# [6,] 2 6
# $imgs[[1]][[2]]  row number of image 1 in the original image matrix
# [1] 1
# $imgs[[1]][[3]]  label for this image
# [1] 2
# $thresh
# [1] 0.5
# $nr  number of rows in each image in the image set
# [1] 2
# $labels   labels for all images in this image set
# [1] 2
# component counts (rows, cols, 2 diags) for image 1
# > TDAsweepOneImg(prepout[[1]][[1]][[1]],2,6)
#  [1] 2 3 1 0 1 0 1 1 0 1 1 0 1 1 1 0 1 1 1 1 1 1
# broken down:
# row 1: 2
# row 2: 2
# col 1: 1
# col 2: 0
# col 3: 1
# col 4: 0
# col 5: 1
# col 6: 1
# NW-SE diag (note comment re order): 0 1 1 0 1 1 1
# NE-SW diag (note comment re order): 0 1 1 1 1 1 1

######################  TDAsweepImgSet()  ##############################

# applies the sweep to every image in the output of prepImgSet(), by
# calling TDAsweepOneImg() on the $imgs component of each one

# returns a matrix suitable to serve as "X" in your favorite prediction
# method, e.g. logit, random forests, NNs

# arguments:

#   imgsPrepped: output from prepImgSet()
#   nr:  number of rows in an image
#   nc:  number of columns in an image
#   valType:  type of return value, currently 'raw' or '1Dcells'; the
#      former means the raw counts, not grouped into intervals, while 
#      the latter means grouped
#   intervalWidth:  as the name says, for the '1Dcells' case

TDAsweepImgSet <- 
   function(imgsPrepped,nr,nc,valType='1Dcells',intervalWidth=1) 
{
   sweepOneImg <- 
      function(img) TDAsweepOneImg(img[[1]],nr=nr,nc=nc,
         valType=valType,intervalWidth=intervalWidth)
   result <- sapply(imgsPrepped$imgs,sweepOneImg)
   t(result)
}


######################  TDAsweepOneImg()  ##############################

# inputs an image in the form output by imgTo2D(), does horizontal,
# vertical and diagonals sweeps, and outputs a vector of component counts

# nr and nc are the numbers of rows and cols in the image 

# arguments:

#    i2D:  output of regtools::imgTo2D(), with row number, column number,
#       intensity for each one of a filtered set of pixels
#    nr:  as above
#    nc:  as above
#    valType:  as above
#    intervalWidth:  as above

# value:
#
#    vector of component counts or mean counts, depending on 'valType'

TDAsweepOneImg <- function(i2D,nr,nc,valType='raw',intervalWidth=1) 
{
   toIntervalMeans <- function(oneRCD) 
   {
      l1rcd <- length(oneRCD)
      leftEnds <- seq(1,l1rcd,intervalWidth)
      rightEnds <- leftEnds + intervalWidth
      m <- length(leftEnds)
      rightEnds[m] <- rightEnds[m] + 1
      tmp <- vector(length=m)
      # could be speeded up but not worth it
      for (i in 1:m) {
         l <- leftEnds[i]
         r <- rightEnds[i]
         clr <- (oneRCD[l:(r-1)])
         if (length(clr) == 0) mn <- 0 else
            mn <- mean(clr,na.rm=TRUE)
         tmp[i] <- mn
      }
      tmp
   }
   
   tda <- NULL

   # actually easier to be repetitive here than get fancy

   counts <- NULL
   for (i in 1:nr) 
      counts <- c(counts,findNumComps(i2D,'row',c(i,1),nr,nc))
   if (valType == '1Dcells') 
      counts <- toIntervalMeans(counts)
   tda <- c(tda,counts)

   counts <- NULL
   for (i in 1:nc) 
      counts <- c(counts,findNumComps(i2D,'col',c(1,i),nr,nc))
   if (valType == '1Dcells') 
      counts <- toIntervalMeans(counts)
   tda <- c(tda,counts)

   # for now, report all diags, even length 1

   # NW to SE, from row 1; then from column 1
   counts <- NULL
   for (i in 1:nc) 
      counts <- c(counts,findNumComps(i2D,'nwse',c(1,i),nr,nc))
   for (i in 2:nr) 
      counts <- c(counts,findNumComps(i2D,'nwse',c(i,1),nr,nc))
   if (valType == '1Dcells') 
      counts <- toIntervalMeans(counts)
   tda <- c(tda,counts)

   # NE to SW, from row 1; then from column nc
   counts <- NULL
   for (i in 1:nc) 
      counts <- c(counts,findNumComps(i2D,'nesw',c(1,i),nr,nc))
   for (i in 2:nr) 
      counts <- c(counts,findNumComps(i2D,'nesw',c(i,nc),nr,nc))
   if (valType == '1Dcells') 
      counts <- toIntervalMeans(counts)
   tda <- c(tda,counts)

   tda
}

# in the extract*() functions, we'll refer to "rays," meaning either a
# full row, column or diagonal

# each function inspects the given ray for nonzero pixels; returns a
# vector of 1s and 0s, length the same as the ray, 1s signifying a pixel
# at that position in the ray

extractRow <- function(i2D,startRowCol,nr,nc)
{
   startRow <- startRowCol[1]
   startCol <- startRowCol[2]
   rayLength <- nc
   ray <- rep(0,rayLength)
   rcPlaces <- i2D[which(i2D[,1] == startRow),2]
   ray[rcPlaces] <- 1
   ray
}

extractCol <- function(i2D,startRowCol,nr,nc)
{
   startRow <- startRowCol[1]
   startCol <- startRowCol[2]
   rayLength <- nr
   ray <- rep(0,rayLength)
   rcPlaces <- i2D[which(i2D[,2] == startCol),1]
   ray[rcPlaces] <- 1
   ray
}

extractNWSE <- function(i2D,startRowCol,nr,nc)
{
   startRow <- startRowCol[1]
   startCol <- startRowCol[2]
   rayLength <- min(nc-startCol+1,nr-startRow+1)
   ray <- rep(0,rayLength)
   rcDiff <- startCol - startRow
   rcDiffs <- apply(i2D,1,function(i2Drow) i2Drow[2]-i2Drow[1])
   result <- i2D[which(rcDiffs == rcDiff),1]
   result <- result - startRow + 1
   ray[result] <- 1
   ray
}

extractNESW <- function(i2D,startRowCol,nr,nc)
{
   startRow <- startRowCol[1]
   startCol <- startRowCol[2]
   rayLength <- min(startCol,nr-startRow+1)
   ray <- rep(0,rayLength)
   rcSum <- startCol + startRow
   rcSums <- apply(i2D,1,function(i2Drow) i2Drow[2]+i2Drow[1])
   result <- i2D[which(rcSums == rcSum),1]
   result <- result - startRow + 1
   ray[result] <- 1
   ray
}

# returns the number of components in a given row, column or diagonal sweep
# args:
#    i2D: output of imgTo2D()
#    rowOrColOrDiag: one of 'row', 'col', 'nwse', 'nesw'
#    startPixel: (row,co) pair specifying where the sweep will start;
#       one of them must be equal to 1
#    nr, nc: numbers of rows and columns in the image
# value: number of components found in this sweep
findNumComps <- function(i2D,rowOrColOrDiag,startRowCol,nr,nc) 
{
   startRow <- startRowCol[1]
   startCol <- startRowCol[2]
   if (rowOrColOrDiag == 'row') {
      ray <- extractRow(i2D,startRowCol,nr,nc) 
   } else if (rowOrColOrDiag == 'col') {
      ray <- extractCol(i2D,startRowCol,nr,nc) 
   } else if (rowOrColOrDiag == 'nwse') {
      ray <- extractNWSE(i2D,startRowCol,nr,nc) 
   } else {
      ray <- extractNESW(i2D,startRowCol,nr,nc) 
   }
   # components in tmp start wherever a 0 is followed by a 1, or with a
   # 1 on the left end
   rayLength <- length(ray)
   tmp <- ray
   tmp0 <- c(0,tmp)
   sum(tmp - tmp0[-(rayLength+1)] == 1)
}

