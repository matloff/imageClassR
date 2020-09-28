
# high-level functions to provide a "turnkey" enrionment for image
# analysts

# args are as in TDAsweep(), except for mlCnd: this is the function call
# (quoted) to run on the training set produced by the TDAsweep
# operation; the input must be referred to as tdaout

tdaFit <- function(images,labels,nr,nc,rgb=TRUE,
   thresholds=0,intervalWidth=1,cls=NULL,rcOnly=FALSE,
   mlCmd)
{
stop('under construction')
# no mlCmd; use qe*() for extra convenience
   tdaout <- TDAsweep(images=images,labels=labels,nr=nr,nc=nc,rgb=rgb,
      thresholds=thresholds,intervalWidth=intervalWidth,cls=cls,rcOnly=rcOnly,
      prep=FALSE)
   mlout <- eval(parse(text=mlCnd))
   mlout$nr <- nr
   mlout$nc <- nc,mlout$rgb <- rgb,
   mlout$thresholds <- thresholds
   mlout$intervalWidth <- intervalWidth
   mlout$rcOnly <- rcOnly
   class(mlout) <- c('tdaFit',class(mlout))
   mlout
}

predict.tdaFit <- function(object,,newImages) 
{
### need to retain classNames
}

