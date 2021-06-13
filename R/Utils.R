
# for dimension reduction

# data frame d, columns d[,-ncol(d)] of interest

# replace d[,-ncol(d)] <- newCols

dimRed <- function(d,newCols) 
{
   ncolx <- ncol(d) - 1
   numnewcolx <- length(newCols)
   tonull <- (numnewcolx+1):ncolx
   d[,tonull] <- NULL
   d[1:numnewcolx] <- newCols
   d
}

