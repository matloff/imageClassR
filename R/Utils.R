
# for dimension reduction; the "X" portion of d, i.e. not yName, will be
# replaced by newCols

dimRed <- function(d,yName,newCols) 
{
   # rearrange d to have yName last
   ycol <- which(names(d) == yName)
   tmp <- c(setdiff(1:ncol(d),ycol),ycol)
   d <- d[,tmp]

   ncolx <- ncol(d) - 1
   numnewcolx <- ncol(newCols)
   tonull <- (numnewcolx+1):ncolx
   d[,tonull] <- NULL
   d[,1:numnewcolx] <- newCols
   d
}

