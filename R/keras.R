
# various wrappers to regtools::krsFit(), in turn a wrapper for the
# R 'keras' package 

# arguments consistent with qeML package:

#    imgSet: data frame, one row per image
#    yName: name of the labels column; latter must be an R factor

# also:

#    xShape: number of rows, cols, channels per image
#    hidden: dense layers
#    RGB: if TRUE, color, otherwise grayscale

# general specification of convolutional and dense layesr
kerasConv  <- function(imgSet,yName,xShape,conv,
   RGB=FALSE,acts=rep("relu",length(hidden)),
   learnRate=0.001,hidden=c(100,100),nEpoch=30,
   holdout=floor(min(1000,0.1*nrow(imgSet))))
{
    require(keras)
    require(qeML)
    if (!is.null(holdout))
        splitData(holdout, imgSet)
    ycol <- which(names(imgSet) == yName)
    x <- imgSet[, -ycol]
    y <- imgSet[, ycol]
    classNames <- levels(y)
    yFactor <- y
    y <- as.numeric(as.factor(y)) - 1
    krsout<-regtools::krsFit(x,y,hidden,acts=acts,learnRate=learnRate,
       conv=conv,xShape=xShape,classif=TRUE,nClass=length(classNames),
       nEpoch = nEpoch)
    krsout$classNames = classNames
    krsout$x <- x
    krsout$y <- y
    krsout$yFactor <- yFactor
    krsout$trainRow1 <- getRow1(imgSet,yName)
    class(krsout) <- c('kerasConv')
    if (!is.null(holdout)) {
        predictHoldout(krsout)
        krsout$holdIdxs <- holdIdxs
    }
    krsout
}


