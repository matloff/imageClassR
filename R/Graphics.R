
plotTDA <- function(tdaout,labelsToPlot) 
{
   nColTdaout <- ncol(tdaout)
   nCompCounts <- nColTdaout - 1
   # nCompCounts is the number of TDAsweep counts, vertical, horizonal,
   # diagonal
   labels <- tdaout[,nColTdaout]
   labelGroups <- split(1:nrow(tdaout),labels)
   nLabels <- length(labelGroups)

   # for the tdaout rows corresponding to a given label, average the
   # component counts at each TDAsweep "X" value
   getClassColMeans <- function(rowGrp)                                         
   {
      tmp <- tdaout[rowGrp,]
      colMeans(tmp)
   }

   colmeans <- sapply(labelGroups,getClassColMeans)
   # colmeans is nCompCounts x nLabels, same shape as t(tdaout)
   clm <- colmeans[-(nCompCounts+1),]  # remove labels
   maxCount <- max(clm)
   x <- 1:nCompCounts
   # plot first label
   lbl1 <- labelsToPlot[1]
   if (length(labelsToPlot) > 1) {
      plot(x,clm[,lbl1],col=1,type='l',ylim=c(0,1.1*maxCount))
      for (lbl in labelsToPlot[-1]) {
         lines(x,clm[,lbl],col=lbl)
      }
   } else {
      plot(x,clm[,lbl1],col='red',type='l',ylim=c(0,1.1*maxCount))
      nLines <- min(5,length(labelGroups[[lbl1]]))
      toPlot <- sample(labelGroups[[lbl1]],nLines,replace=FALSE)
      ## for (i in labelGroups[[lbl1]]) {
      for (i in toPlot) {
         lines(x,tdaout[i,-nColTdaout],col=1)
      }
   }
   legend('topright',legend=colnames(clm),col=1:nLabels,lty=1:2)

}
