
# 'drml' stands for "dimension reduction + ML", meaning that the image
# set is run through a dimension reduction algorithm, say PCA, with the
# output then fit by an ML algorithm

# high-level functions to provide a "turnkey" environment for image
# analysts; input images matrix or data frame and the associated labels,
# output an object to be used in prediction 

# uses the qe*() series from regtools

# general arguments:

#    data: data from of pixel data, one row per image (each img in 1-D
#       form), with a column for the labels
#    yName: name of colun R factor containing the class labels
#    nr,nc: number of rows, columns in each image
#    qeFtnName: ML function to be used after dimension reduction, e.g. 'qeSVM'
#    opts: R list, containing optional arguments for the ML function
#    dataAug: specification of what data augmentation to do, if any,
#       prior to applying dimension reduction
#    holdout: as in all qe-series ML functions

############################  TDAsweep  ###################################

drmlTDAsweep <- function(data,yName,nr,nc,
   qeFtnName,opts=NULL,dataAug=NULL, 
   holdout=floor(min(1000,0.1*nrow(imgs))),
   thresh=c(50,100,150),intervalWidth=2)
{
   ycol <- which(names(data) == yName)
   imgs <- as.matrix(data[,-ycol])
   labels <- data[,ycol]

   res <- list()  # eventual return value
   res$nr <- nr
   res$nc <- nc
   res$thresh <- thresh
   res$intervalWidth <- intervalWidth

   # fit TDAsweep
   tdaout <- TDAsweepImgSet(imgs=imgs,labels=labels,nr=nr,nc=nc,
      thresh=thresh,intervalWidth=intervalWidth,rcOnly=TRUE)

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
      TDAsweepImgSet(imgs=newImages,labels=fakeLabels,nr=object$nr,nc=object$nc,
      thresh=object$thresh,intervalWidth=object$intervalWidth,
      rcOnly=TRUE)
   tdaout <- tdaout[,-ncol(tdaout)]  # remove fake labels

   # remove whatever cols were deleted in the original fit
   ccs <- object$constCols
   if (length(ccs) > 0) tdaout <- tdaout[,-ccs]

   predict(object$qeout,tdaout)  
}

############################  PCA  ###################################

drmlPCA <- function(data,yName,nr,nc,
   qeFtnName,opts=NULL,dataAug=NULL, 
   holdout=floor(min(1000,0.1*nrow(data))),
   pcaProp)
{
   qePCA(data,yName,qeName=qeFtnName,opts=opts,
      pcaProp=pcaProp,holdout=holdout)
}

############################  UMAP  ###################################

drmlUMAP <- function(data,yName,nr,nc,
   qeFtnName,opts=NULL,dataAug=NULL, 
   holdout=floor(min(1000,0.1*nrow(data))))
{
   qeUMAP(data,yName,qeName=qeFtnName,opts=opts,
      holdout=holdout)
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

