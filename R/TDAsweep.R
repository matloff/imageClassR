
# TDAsweep routines 

# main function is TDAsweepImgSet(), which operates on a set of images;
# usage:  input a matrix of images, 1 image per row; apply prepImgSet();
# feed output of latter into TDAsweepImgSet()



######################  TDAsweepOneImg()  ##############################

# inputs an image in the form of a vector storing the image in row-major
# order, WITHOUT labels; does horizontal and vertical sweeps, and
# outputs a vector of component counts

# nr and nc are the numbers of rows and cols in the image 

# arguments:

#    img: img in vector form (see above)
#    nr:  number of rows in image
#    nc:  number of cols in image
#    intervalWidth:  number of consecutive rows and columns to consolidate

# value:
#
#    vector of component counts 

TDAsweepOneImg <- function(img,nr,nc,thresh,intervalWidth=1,rcOnly=FALSE) 
{
   
   tda <- NULL

   # replace each pixel by 1 or 0, according to whether >= 1, and
   # convert to matrix rep
   img10 <- as.integer(img >= thresh)
   img10vec <- img10
   img10 <- matrix(img10,ncol=nc,byrow=TRUE)

   counts <- NULL
   for (i in 1:nr) counts <- c(counts,findNumComps(img10[i,]))
   # counts <- toIntervalMeans(counts,intervalWidth)
   tda <- c(tda,counts)

   counts <- NULL
   for (i in 1:nc) counts <- c(counts,findNumComps(img10[,i]))
   # counts <- toIntervalMeans(counts,intervalWidth)
   tda <- c(tda,counts)

   if (!rcOnly) {
      counts <- getNWSEdiags(img10vec,nr,nc)
      # counts <- toIntervalMeans(counts,intervalWidth)
      tda <- c(tda,counts)
      counts <- getSWNEdiags(img10vec,nr,nc)
      # counts <- toIntervalMeans(counts,intervalWidth)
      tda <- c(tda,counts)
   }

   # note: this average at boundaries, e.g. end of row counts and start
   # of column counts, but convenient, and presumably only used for
   # large images anyway
   if (intervalWidth > 1) tda <- toIntervalMeans(tda,intervalWidth)
   tda
}

# returns the number of components in a given row or column 

# args:
#    img10: thresholded version of img
#    rowOrCol: one of 'row', 'col', 'nwse', 'nesw'
#    nr, nc: numbers of rows and columns in the image

# value: number of components found in this sweep
findNumComps <- function(ray)
{
   # components in tmp start wherever a 0 is followed by a 1, or with a
   # 1 on the left end
   rayLength <- length(ray)
   tmp <- ray
   tmp0 <- c(0,tmp)
   sum(tmp - tmp0[-(rayLength+1)] == 1)
}

# v is a vector of nr and nc rows and cols, stored in row-major order;
# return value is a list with all the NW-to-SE diagonals
getNWSEdiags <- function(v,nr,nc) 
{
   m <- matrix(v,ncol=nc,byrow=TRUE)
   res <- list()
   # go through all possible starting points, first along column 1 and
   # then along row 1
   rowm <- row(m)
   colm <- col(m)
   # get ray starting at Row nr-k
   getOneNWSEdiag <- function(k) m[rowm - colm == nr-k]
   lout <- lapply(1:(nr+nc-1),getOneNWSEdiag)
   sapply(lout,findNumComps)
}

# v is a vector of nr and nc rows and cols, stored in row-major order;
# return value is a list with all the SW-to-NE diagonals
getSWNEdiags <- function(v,nr,nc) 
{
   m <- matrix(v,ncol=nc,byrow=TRUE)
   res <- list()
   # go through all possible starting points, first at row 1, col 1
   rowm <- row(m)
   colm <- col(m)
   # get ray with row + col = k
   getOneNWSEdiag <- function(k) m[rowm + colm == k]
   lout <- lapply(2:(nr+nc),getOneNWSEdiag)
   sapply(lout,findNumComps)
}

# countVec: vector of counts from one row or column or diagonal
toIntervalMeans <- function(countVec,intervalWidth) 
{
   # add padding if needed; 
   lcv <- length(countVec)
   extra <- intervalWidth - lcv %% intervalWidth
   if (extra > 0) countVec <- c(countVec,rep(countVec[lcv],extra))

   mat <- matrix(countVec,byrow=TRUE,ncol=intervalWidth)
   apply(mat,1,mean)
}

# this routine sweeps through all images in a set, but unlike
# TDAsweepOneImg(), here we assume the labels are present, in the last
# column

TDAsweepImgSet <- function(imgs,nr,nc,thresh,intervalWidth=1,rcOnly=FALSE) 
{
   f <- function(img) TDAsweepOneImg(img=img,nr=nr,nc=nc,thresh=thresh,
         intervalWidth=intervalWidth,rcOnly=rcOnly)
   t(apply(imgs[,-(nr*nc+1)],1,f))
}

