
library(TDAstats)
library(regtools)
library(pdist)

# overview

# data prep:

# prepImgSet():  inputs image collection matrix, one image per row, 
#    an associated vector of class labels, the number of pixel rows in
#    each image, and the threshold; outputs an R list, each element
#    consisting of a pixels locations matrix, the index of the original
#    image in the input data, and the class label; the matrix has pixels
#    passing above the threshold, each pixel as an (row number,col
#    number) pair


###########################  TDAsweep  ##############################

# inputs an image in the form output by imgTo2D(), does horizontal,
# vertical and diagonals sweeps, and outputs a vector of component counts

# nr and nc are the numbers of rows and cols in the image 

# arguments:

#    i2D:  output of imgTo2D(), with row number, column number,
#       intensity for each one of a filtered set of pixels
#    nr:  number of rows in the image
#    nc:  number of columns in the image
#    valType:  type of return value, currently 'raw' or '1Dcells'
#    intervalWidth:  as the name says, for the '1Dcells' case

# form of return value is specified via 'valType':  

#    'raw':  component counts, unbinned 
#    '1Dcells':  binned counts; e.g. for row counts, break [1,nr] into 
#        intervals of width intervalWidth; find mean number of components 
#        over the rows in an interval; return the means, one per
#        interval

TDAsweepOneImg <- function(i2D,nr,nc,valType='raw',intervalWidth=NULL) 
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
   rayLength <- length(ray)
   tmp <- ray
   tmp0 <- c(0,tmp)
   sum(tmp - tmp0[-rayLength] == 1)
}

# applies the sweep to every image in the output of prepImgSet();
# returns a matrix suitable to serve as "X" in a prediction model
TDAsweepImgSet <- function(imgsPrepped,nr,nc,valType='1Dcells',intervalWidth=NULL) 
{
   sweepOneImg <- 
      function(img) TDAsweepOneImg(img[[1]],nr=nr,nc=nc,
         valType=valType,intervalWidth=intervalWidth)
   result <- sapply(imgsPrepped$imgs,sweepOneImg)
   t(result)
}


### #######################  experiments  ###############################
### 
### expt1 <- function(n,w,iT) {
###    prepForExpt('../TDA.tmp/MNIST.Save','mntrn',28,28,iT,n) 
###    z <- TDAsweepImgSet(imgsPrepped,28,28,intervalWidth=w)
###    zd <- as.data.frame(z) 
###    lmout <- mvrlm(zd,trnLabels,'dig') 
###    preds <- predict(lmout,zd) 
###    preds <- apply(preds,1,which.max) - 1 
###    print(mean(preds == trnLabels) )
###    print(table(preds,trnLabels))
### }
### 
### # MNIST; sample n for training, n for testing; bounds lt, rt for hist,
### # bin width w; intensity threshold iT
### expt2 <- function(n,lt,rt,w,iT) {
###    load('../TDA.tmp/MNIST.Save')  # loads mntrn, mntst
###    mntrn <- as.matrix(mntrn)
###    colnames(mntrn) <- NULL 
###    set.seed(9999)
###    trnidxs <- sample(1:nrow(mntrn),n) 
###    tstidxs <- setdiff(1:nrow(mntrn),trnidxs)
###    mtr <- mntrn[trnidxs,-785]
###    trlabels <- mntrn[trnidxs,785]
###    mts <- mntrn[tstidxs,-785]
###    imgsPrepped <- prepImgSet(mtr,28,trlabels,iT)  # allow for fainter images
###    ihs <- imgsHomStat(imgsPrepped,lt,rt,w)
###    mts <- mntrn[tstidxs,]
###    counts <- NULL
###    for (i in 1:250) {
###       mtsi <- mts[i,]
###       predi <- predict(ihs,mtsi[-785],10)
###       # cat(predi,'  ',mtsi[785],'\n')
###       counts <- rbind(counts,c(predi,mtsi[785]))
###    }
###    print(mean(counts[,1] == counts[,2]))
###    print(table(data.frame(counts)))
### }

