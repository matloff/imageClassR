
# takes a full sweep output and keeps only the row and column data, not
# the diagonals

# arguments:
 
# sweepOut:  value returned by TDAsweep()
# nr,nc:  numbers of rows, cols per image
# nThresh:  number of threshold levels
# intWidth:  interval width
 
# value:
 
# a copy of sweepOut without the diagonal data but retaining the labels
# column at the end

rcOnly <- function(sweepOut,nr,nc,nThresh,intWidth) {
   nOneThresh <- (nr + nc + 2*(nr+nc-1)) / intWidth
   so <- as.matrix(sweepOut[,-ncol(sweepOut)])
   newSweepOut <- NULL
   for (thresh in 1:nThresh) {
      start <- (thresh - 1) * nOneThresh + 1
      end <- start + (nr+nc)/intWidth
      newSweepOut <- cbind(newSweepOut,so[,start:end])
   }
   newSweepOut <- as.data.frame(newSweepOut)
   newSweepOut$labels <- sweepOut$labels
   newSweepOut
}

