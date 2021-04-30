
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
   qeFtn,opts=NULL,holdout=floor(min(1000,0.1*nrow(images))))
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

   # exeecute the command and set result for return value
   mlout <- eval(parse(text=mlcmd))
   mlout$nr <- nr
   mlout$nc <- nc
   mlout$rgb <- rgb
   mlout$thresh <- thresh
   mlout$intervalWidth <- intervalWidth
   mlout$rcOnly <- rcOnly
   mlout$constCols <- ccs
   mlout$classNames <- levels(tdaout$labels)
   class(mlout) <- c('drmlTDA',class(mlout))
   mlout
}

predict.tdaFit <- function(object,newImages) 
{
   class(object) <- class(object)[-1]
   tdaout <-
      TDAsweep(images=newImages,labels=NULL,nr=object$nr,nc=object$nc,
      rgb=object$rgb,thresholds=object$thresholds,
      intervalWidth=object$intervalWidth,cls=object$cls,
      rcOnly=object$rcOnly,
      prep=FALSE)
   tdaout <- as.data.frame(tdaout$tda_df)

   # remove whatever cols were deleted in the original fit
   ccs <- object$constCols
   tdaout <- tdaout[,-ccs]
   tdaout <- as.data.frame(tdaout)  # df of the new features
   predict(object,tdaout)  
}

