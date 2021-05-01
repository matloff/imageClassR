
# high-level functions to provide a "turnkey" environment for image
# analysts; input images matrix or data frame and the associated labels,
# output an object to be used in prediction

# uses the qe*() series from regtools

# args are as in TDAsweep(), except for:

#    qeFtn: one of 'Logit', 'KNN', 'Lin', 'RF', 'SVM', 'GBoost', 'NN',
#       the choices in the qe*() series
#    mlFtnArgs:  algorithm-specifc arguments, R list of named elements

drmlTDA <- function(imgs,labels,nr,nc,rgb=TRUE,
   thresh=c(50,100,150),intervalWidth=2,cls=NULL,rcOnly=TRUE,
   holdout=floor(min(1000,0.1*nrow(imgs))),
   qeFtn,opts=list(holdout=holdout))
{

   tdaout <- TDAsweepImgSet(imgs=imgs,labels=labels,nr=nr,nc=nc,
      thresh=thresh,intervalWidth=intervalWidth,rcOnly=rcOnly)

   # must deal with constant columns, typically all-0, as many ML algs try to
   # scale the data and will balk; remove such columns, and make a note
   # so the same can be done during later prediction
   ccs <- constCols(tdaout)
   if (length(ccs) > 0) {
      tdaout <- tdaout[,-ccs]
      warning('constant columns have been removed from the input data')
   }  

   # construct the qe*() series call
   mlcmd <- paste0(qeFtn,'(tdaout,"labels"')
   if (is.null(opts)) mlcmd <- paste0(mlcmd,')')  # more args?
   else {
      nms <- names(opts)
      for (i in 1:length(nms)) {
         mlcmd <- paste0(mlcmd,',')
         argval <- opts[[nms[i]]]
         arg <- paste0(nms[i],'=',argval)
         if (i == length(nms)) mlcmd <- paste0(mlcmd,arg,')')
      }
   }

   res <- list()  # eventual return value

   # exeecute the command and set result for return value
   res$qeout <- eval(parse(text=mlcmd))
   res$nr <- nr
   res$nc <- nc
   res$rgb <- rgb
   res$thresh <- thresh
   res$intervalWidth <- intervalWidth
   res$rcOnly <- rcOnly
   res$constCols <- ccs
   res$classNames <- levels(tdaout$labels)
   res$testAcc <- res$qeout$testAcc
   res$baseAcc <- res$qeout$baseAcc
   class(res) <- c('drmlTDA',class(res$qeout))
   res
}

predict.drmlTDA <- function(object,newImages) 
{
   class(object) <- class(object)[-1]
   newImages <- as.matrix(newImages)
   fakeLabels <- rep(object$classNames[1],nrow(newImages))
   tdaout <-
      TDAsweepImgSet(imgs=newImages,labels=fakeLabels,nr=object$nr,nc=object$nc,
      thresh=object$thresh,intervalWidth=object$intervalWidth,
      rcOnly=object$rcOnly)
   tdaout <- tdaout[,-ncol(tdaout)]  # remove fake labels

   # remove whatever cols were deleted in the original fit
   ccs <- object$constCols
   if (length(ccs) > 0) tdaout <- tdaout[,-ccs]

   predict(object$qeout,tdaout)  
}

