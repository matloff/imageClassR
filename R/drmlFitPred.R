
# high-level functions to provide a "turnkey" environment for image
# analysts; input images matrix or data frame and the associated labels,
# output an object to be used in prediction

# uses the qe*() series from regtools

# args are as in TDAsweepImgSet(), except for:

#    qeFtn: one of the functions in regtools::qe*, e.g. qeSVM()
#    opts:  algorithm-specifc arguments, R list of named elements,
#       e.g. opts = list(gamma = 1) for qeSVM()
#    method-specific arguments, e.g. thresh and intervalWidth for TDAsweep

############################  TDAsweep  ###################################

drmlTDAsweep <- function(imgs,labels,nr,nc,rgb=FALSE,
   holdout=floor(min(1000,0.1*nrow(imgs))),
   qeFtn,opts=list(holdout=holdout),cls=NULL,
   thresh=c(50,100,150),intervalWidth=2)
{

   tdaout <- TDAsweepImgSet(imgs=imgs,labels=labels,nr=nr,nc=nc,
      thresh=thresh,intervalWidth=intervalWidth,rcOnly=TRUE)

   # must deal with constant columns, typically all-0, as many ML algs try to
   # scale the data and will balk; remove such columns, and make a note
   # so the same can be done during later prediction
   ccs <- constCols(tdaout)
   if (length(ccs) > 0) {
      tdaout <- tdaout[,-ccs]
      warning('constant columns have been removed from the input data')
   }  

   # construct the qe*() series call
   mlcmd <- buildQEcall(paste0(qeFtn,'(tdaout,"labels"'),opts)

   res <- list()  # eventual return value

   # exeecute the command and set result for return value
   res$qeout <- eval(parse(text=mlcmd))
   res$nr <- nr
   res$nc <- nc
   res$rgb <- rgb
   res$thresh <- thresh
   res$intervalWidth <- intervalWidth
   res$constCols <- ccs
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

###############################  DCT  ################################

# nFreqs: number of lowest frequencies to retain

drmlFFT <- function(imgs,labels,nr,nc,rgb=TRUE,
   thresh=c(50,100,150),intervalWidth=2,cls=NULL,rcOnly=FALSE,
   holdout=floor(min(1000,0.1*nrow(imgs))),
   qeFtn,opts=list(holdout=holdout),nFreqs=8)
{

   require(fftw)

   if (is.data.frame(imgs)) imgs <- as.matrix(imgs)
   fout <- apply(hm1,1,DCT)
   fout <- fout[,1:nFreqs]
  

}

