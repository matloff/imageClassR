
plotTDA <- function(tdaout) 
{
   require(matplot)
   nCompCounts <- ncol(tdaout) - 1
   # nCompCounts is the number of TDAsweep counts, vertical, horizonal,
   # diagonal
   labels <- tdaout[,nCompCounts+1]
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
   # get started, plot first column
   plot(x,clm[,1],col=1,type='l',ylim=c(0,1.1*maxCount))
   for (j in 2:nLabels) {
      lines(x,clm[,j],col=j)
   }
   legend('topright',legend=colnames(clm),col=1:nLabels,lty=1:2)

}
