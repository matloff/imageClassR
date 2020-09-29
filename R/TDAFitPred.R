
# high-level functions to provide a "turnkey" enrionment for image
# analysts; uses the qe*() series from regtools

# args are as in TDAsweep(), except for:

# qeFtn

tdaFit <- function(images,labels,nr,nc,rgb=TRUE,
   thresholds=0,intervalWidth=1,cls=NULL,rcOnly=FALSE,
   qeFtn,mlFtnArgs=NULL)
{
   tdaout <- TDAsweep(images=images,labels=labels,nr=nr,nc=nc,rgb=rgb,
      thresholds=thresholds,intervalWidth=intervalWidth,cls=cls,rcOnly=rcOnly,
      prep=FALSE)
browser()
   tdaout <- cbind(as.data.frame(tdaout$tda_df),labels=labels)
   labels <- as.factor(labels)
   mlcmd <- paste0(qeFtn,'(tdaout,"labels"')
   if (is.null(mlFtnArgs)) mlcmd <- paste0(mlcmd,')')
   else {
      nms <- names(mlFtnArgs)
      for (i in 1:length(nms)) {
         mlcmd <- paste0(mlcmd,',')
         argval <- mlFtnArgs[[nms[i]]]
         arg <- paste0(nms[i],'=',argval)
         if (i == length(nms)) mlcmd <- paste0(mlcmd,')')
      }
   }
   mlout <- eval(parse(text=mlcmd))
   mlout$nr <- nr
   mlout$nc <- nc
   mlout$rgb <- rgb
   mlout$thresholds <- thresholds
   mlout$intervalWidth <- intervalWidth
   mlout$rcOnly <- rcOnly
   class(mlout) <- c('tdaFit',class(mlout))
   mlout
}

predict.tdaFit <- function(object,newImages) 
{
### need to retain classNames
}

