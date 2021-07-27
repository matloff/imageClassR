
# 'drml' stands for "dimension reduction + ML", meaning that the image
# set is run through a dimension reduction algorithm, say PCA, with the
# output then fit by an ML algorithm

# NOTE:  Color case assumes data is concatenated by channel.  E.g.
# 785-column MNIST training data is 65000 x 785 in grayscale, 
# 65000 x 2353 in RGB (one column for the labels)

# high-level functions to provide a "turnkey" environment for image
# analysts; input images matrix or data frame and the associated labels,
# output an object to be used in prediction 

# uses the qe*() series from regtools

# general arguments (followed by method-specific arguments, e.g.
#    'thresh' for drmlTDAsweep, though the latter is modified below):

#    thresh

#    data: data from of pixel data, one row per image (each img in 1-D
#       form), with a column for the labels; in the case of color
#       images, one row of 'data' consists of the concatenation of the
#       R, G and B vectors
#    yName: name of colun R factor containing the class labels
#    qeFtnName: ML function to be used after dimension reduction, e.g. 'qeSVM'
#    opts: R list, containing optional arguments for the ML function
#    RGB: if color, then TRUE
#    pixAug: specification of what data augmentation to do, if any,
#       prior to applying dimension reduction
#    tdasAug: specification of how much augmented data to generate, 
#       after TDAsweep is applied; half will be vertical flips, after
#       which horizontal flips will be done on the other half
#    holdout: as in all qe-series ML functions

############################  TDAsweep  ###################################

# 'thresh' argument is as in TDAsweepImgSet(), except that a negative
# value will indicate partitioning [0,255] (255 hard coded for now) into
# |thresh|+1 equal subintervals

drmlTDAsweep <- function(data,yName,
   qeFtnName,opts=NULL,RGB=FALSE,pixAug=0,tdasAug=0, 
   holdout=floor(min(1000,0.1*nrow(imgs))),
   nr=0,nc=0,thresh=c(50,100,150),intervalWidth=2)
{
   ncc <- (1 + 2*RGB) * nc
   if (nr*ncc != ncol(data) - 1) stop('mismatch in number of columns')
   ycol <- which(names(data) == yName)
   imgs <- as.matrix(data[,-ycol])
   labels <- data[,ycol]

   if (thresh[1] < 0) {
      thresh <- -thresh
      increm <- 256 / (thresh+1)
      thresh <- increm * (1:thresh)
      thresh <- thresh
   }  

   res <- list()  # eventual return value
   res$nr <- nr
   res$nc <- nc
   res$RGB <- RGB
   res$tdasAug <- tdasAug
   res$ncc <- ncc
   res$thresh <- thresh
   res$intervalWidth <- intervalWidth

   # fit TDAsweep
   tdaout <- TDAsweepImgSet(imgs=imgs,labels=labels,nr=nr,nc=ncc,
      thresh=thresh,intervalWidth=intervalWidth,rcOnly=TRUE)
   attr(tdaout,'RGB') <- RGB

   tdaout <- tdasweepAug(tdaout,nr,nc,intervalWidth,tdasAug)

   # must deal with constant columns, typically all-0, as many ML algs try to
   # scale the data and will balk; remove such columns, and make a note
   # so the same can be done during later prediction
   ccs <- constCols(tdaout)
   res$constCols <- ccs
   if (length(ccs) > 0) {
      tdaout <- tdaout[,-ccs]
      warning('constant columns have been removed from the input data')
   }  

   # construct the qe*() series call
   mlcmd <- buildQEcall(qeFtnName,'tdaout','labels',opts,holdout=holdout)

   # execute the command and set result for return value
   res$qeout <- eval(parse(text=mlcmd))
   res$classNames <- levels(tdaout$labels)
   res$testAcc <- res$qeout$testAcc
   res$baseAcc <- res$qeout$baseAcc
   class(res) <- c('drmlTDAsweep',class(res$qeout))
   res
}

predict.drmlTDAsweep <- function(object,newImages) 
{
   class(object) <- class(object)[-1]
   newImages <- as.matrix(newImages)
   fakeLabels <- rep(object$classNames[1],nrow(newImages))
   tdaout <-
      TDAsweepImgSet(imgs=newImages,labels=fakeLabels,
         nr=object$nr,nc=object$ncc,
         thresh=object$thresh,intervalWidth=object$intervalWidth,
         rcOnly=TRUE)
   tdaout <- tdaout[,-ncol(tdaout)]  # remove fake labels

   # remove whatever cols were deleted in the original fit
   ccs <- object$constCols
   if (length(ccs) > 0) tdaout <- tdaout[,-ccs]

   predict(object$qeout,tdaout)  
}

# data augmentation at the TDAsweep level, i.e. more rows are added to
# the TDAsweep output

tdasweepAug <- function(tdasOut,nr,nc,intervalWidth,nTDAsweepAug)
{

   # tdasOut has 1 row per image; each row consists of nThresh sets of
   # row counts, followed by nThresh sets of column counts for that
   # image

   nrtdas <- nrow(tdasOut)
   rowCountsEnd <- attr(tdasOut,'rowCountsEnd')
   colCountsEnd <- attr(tdasOut,'colCountsEnd')
   nRowCounts <- rowCountsEnd
   nColCounts <- colCountsEnd - nRowCounts
   thresh <- attr(tdasOut,'thresh')
   nThresh <- length(thresh)

   # note: no diagonal counts, due to TDAsweep() call
   labelsCol <- colCountsEnd + 1

   # initialize the augmented data; to get the column names right,
   # easiest just to use the original data!
   newTDAS <- tdasOut[1,]

   # vertical flips
   # first, a sanity check
   if (nRowCounts %% nThresh != 0) stop('nRowCounts not divisible by nThresh')
   nVertFlip <- round(0.5 * nTDAsweepAug)
   idxs <- sample(1:nrtdas,nVertFlip)
   # now do the flip once for each threshold level
   nRowCountsPerThresh <- nRowCounts / nThresh
   for (i in 1:nThresh) {
      start <- 1 + (i-1) * nRowCountsPerThresh
      end <- i * nRowCountsPerThresh
      tmp <- tdasOut[idxs,]
      tmp[,start:end] <- tdasOut[idxs,end:start]
      colnames(tmp)[start:end] <- colnames(tdasOut[,start:end])
      newTDAS <- rbind(newTDAS,tmp)
   }

   # horizontal flips (might have some overlap, not a bad thing)
   # first, a sanity check
   if (nColCounts %% nThresh != 0) stop('nColCounts not divisible by nThresh')
   nHorizFlip <- round(0.5 * nTDAsweepAug)
   idxs <- sample(1:nrtdas,nHorizFlip)
   nColCountsPerThresh <- nColCounts / nThresh
   for (i in 1:nThresh) {
      start <- nRowCounts + 1 + (i-1) * nColCountsPerThresh
      end <- i * nColCountsPerThresh
      tmp[,start:end] <- tdasOut[idxs,end:start]
      colnames(tmp)[start:end] <- colnames(tdasOut[,start:end])
      newTDAS <- rbind(newTDAS,tmp)
   }

   rbind(tdasOut,newTDAS)
}

############################  PCA  ###################################

drmlPCA <- function(data,yName,
   qeFtnName,opts=NULL,dataAug=NULL, 
   holdout=floor(min(1000,0.1*nrow(data))),
   pcaProp)
{
   qePCA(data,yName,qeName=qeFtnName,opts=opts,
      pcaProp=pcaProp,holdout=holdout)
}

############################  UMAP  ###################################

drmlUMAP <- function(data,yName,
   qeFtnName,opts=NULL,dataAug=NULL, 
   holdout=floor(min(1000,0.1*nrow(data))),nComps=25)
{
   qeUMAP(data,yName,qeName=qeFtnName,opts=opts,
      holdout=holdout,nComps=nComps)
}

######################  discrete cos xform  ###########################

drmlDCT <- function(data,yName,
   qeFtnName,opts=NULL,dataAug=NULL, 
   holdout=floor(min(1000,0.1*nrow(data))),
   nFreqs)
{
   # compute and extract DCT components
   require(dtt)
   ycol <- which(names(data) == yName)
   x <- as.matrix(data[,-ycol])
   xdct <- dtt(x)[,1:nFreqs]  # not mvdtt

   # replace "X" portion of 'data'
   data <- dimRed(data,yName,xdct)

   # construct the qe*() series call
   mlcmd <- buildQEcall(qeFtnName,'data',yName,opts,holdout=holdout)

   res <- list()  # ultimately the return value
   # execute the command and set result for return value
   res$qeout <- eval(parse(text=mlcmd))
   res$classNames <- levels(data[[yName]])
   res$testAcc <- res$qeout$testAcc
   res$baseAcc <- res$qeout$baseAcc
   class(res) <- c('drmlDCT',class(res$qeout))
   res
}

############################  MomentsHOG  ################################

# nMoms: number of first moments to retain
# HOG: if not NULL, also include histogram of gradients, using this as 
#    (cells,orientations)

###  drmlMomentsHOG <- function(imgs,labels,nr,nc,
###     qeFtnName,opts=NULL,nMoments=4,HOG=NULL,
###     holdout=floor(min(1000,0.1*nrow(imgs))))
###  {
###     require(moments)
###  
###     ccs <- constCols(imgs)
###     if (length(ccs) > 0) {
###        imgs <- imgs[,-ccs]
###        warning('constant columns have been removed from the input data')
###     }  
###  
###     if (is.data.frame(imgs)) imgs <- as.matrix(imgs)
###  
###     getMoments <- function(x) all.moments(x,order.max=nMoments,central=TRUE)
###     fout <- apply(imgs,1,getMoments)
###     fout <- t(fout)
###     fout <- as.data.frame(fout)
###  
###     if (!is.null(HOG)) {
###        require(OpenImageR)
###        getHOG <- 
###           function(x) HOG(matrix(x,ncol=nc),cells=HOG[1],orientations=HOG[2])
###        tmp <- apply(as.matrix(imgs),1,getHOG)
###        tmp <- t(tmp)
###        colnames(tmp) <- paste0('HOG',1:ncol(tmp))
###        fout <- cbind(fout,as.data.frame(tmp))
###     }
###  
###     fout$labels <- labels
###  
###     # construct the qe*() series call
###     mlcmd <- buildQEcall(qeFtnName,'fout','labels',opts,holdout=holdout)
###  
###     res <- list()  # eventual return value
###  
###     # exeecute the command and set result for return value
###     res$qeout <- eval(parse(text=mlcmd))
###     res$fout <- fout
###     res$constCols <- ccs
###     res$classNames <- levels(labels)
###     res$nMoments <- nMoments
###     res$HOG <- HOG
###     res$testAcc <- res$qeout$testAcc
###     res$baseAcc <- res$qeout$baseAcc
###     res$classif <- TRUE
###     class(res) <- c('drmlMomentsHOG',class(res$qeout))
###     res
###  
###  }
###  
###  predict.drmlMomentsHOG <- function(object,newImages) 
###  {
###     class(object) <- class(object)[-1]
###     if (is.vector(newImages)) newImages <- matrix(newImages,nrow=1)
###     else newImages <- as.matrix(newImages)
###     nMoments <- object$nMoments
###     nc <- object$nc
###  
###     getMoments <- 
###        function(x) all.moments(x,order.max=nMoments,central=TRUE)
###     fout <- apply(newImages,1,getMoments)
###     fout <- t(fout)
###     fout <- as.data.frame(fout)
###     # remove whatever cols were deleted in the original fit
###     ccs <- object$constCols
###     if (length(ccs) > 0) fout <- fout[,-ccs]
###  
###     HOG <- object$HOG
###     if (!is.null(HOG)) {
###        require(OpenImageR)
###        getHOG <- 
###           function(x) HOG(matrix(x,ncol=nc),cells=HOG[1],orientations=HOG[2])
###        tmp <- apply(newImages,1,getHOG)
###        tmp <- t(tmp)
###        colnames(tmp) <- paste0('HOG',1:ncol(tmp))
###        fout <- cbind(fout,as.data.frame(tmp))
###     }
###  
###     predict(object$qeout,fout)  
###  }

