
# TDAsweep routines 

# main function is TDAsweepImgSet(), which operates on a set of images

######################  TDAsweepOneImg()  ##############################

# inputs an image in the form of a vector storing the image in row-major
# order, WITHOUT labels; does horizontal and vertical sweeps, and
# optionally diagonal ones, outputting a vector of component counts
# for that image

# nr and nc are the numbers of rows and cols in the image 

# arguments:

#    img: img in vector form (see above); if color, then this is the
#       concatenation of the R, G and B vectors
#    nr:  number of rows in image
#    nc:  number of cols in image
#    thresh: vector of threshold values
#    intervalWidth:  number of consecutive rows and columns to consolidate
#    rcOnly:  row and column sweeping only, no diagonals

# value:
#
#    vector of component counts
#
#      format:
#
#          nThresh sets of row counts, then nThresh sets of col counts
#          (nThresh = length(thresh))
#
#          finally, rowCountsEnd, colCountsEnd tacked on at the end; 
#          used by the caller, and later removed

TDAsweepOneImg <- function(img,nr,nc,thresh,intervalWidth=1,rcOnly=TRUE) 
{
   
   tdaRows <- NULL
   tdaCols <- NULL
   tdaDiags <- NULL

   for (threshi in thresh) {

      # replace each pixel by 1 or 0, according to whether >= 1, and
      # convert to matrix rep
      img10 <- as.integer(img >= threshi)
      img10vec <- img10
      img10 <- matrix(img10,ncol=nc,byrow=TRUE)
   
      counts <- NULL
      for (i in 1:nr) counts <- c(counts,findNumComps(img10[i,]))
      counts <- toIntervalMeans(counts,intervalWidth)
      tdaRows <- c(tdaRows,counts)
      rowCountsEnd <- length(tdaRows)
   
      counts <- NULL
      for (i in 1:nc) counts <- c(counts,findNumComps(img10[,i]))
      counts <- toIntervalMeans(counts,intervalWidth)
      tdaCols <- c(tdaCols,counts)
      colCountsEnd <- rowCountsEnd + length(tdaCols)
   
      if (!rcOnly) {
         counts <- getNWSEdiags(img10vec,nr,nc)
         tdaDiags<- c(tdaDiags,counts)
         counts <- getSWNEdiags(img10vec,nr,nc)
         counts <- toIntervalMeans(counts,intervalWidth)
         tdaDiags <- c(tdaDiags,counts)
      }

   }

   tda <- c(tdaRows,tdaCols,tdaDiags)
   # add 2 fake elements, for communicating row, col counts ends
   tda <- c(tda,rowCountsEnd,colCountsEnd)
   tda
}

######################  helper functions  ##############################

# findNumComps():  finds the number of components in a ray

# args:
#    ray: a vector of counts, e.g. from one row of an image

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

# getNWSEdiags(), getSWNEdiags():  these find the numbers of component
# counts in all NW-to-SE and SW-to-NE diagonals

# v is a vector of nr and nc rows and cols, stored in row-major order;
# return value is a vector with all the NW-to-SE diagonals

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

# toIntervalMeans():  if intervalWidth > 1, finds interval means

# args:

#    countVec: vector of counts from one or more rows, columns or diagonals
#    intervalWidth: as the name implies

# value:

#    vector of counts replaced by mean

toIntervalMeans <- function(countVec,intervalWidth) 
{
   # add padding if needed; 
   lcv <- length(countVec)
   extra <- intervalWidth - lcv %% intervalWidth
   if (extra > 0) countVec <- c(countVec,rep(countVec[lcv],extra))

   mat <- matrix(countVec,byrow=TRUE,ncol=intervalWidth)
   apply(mat,1,mean)
}

#######################  TDAsweepImgSet()  ############################

# the main function

# this routine sweeps through all images in a matrix 'imgs', one image
# per row; 'labels' is the associated labels, as a vector or factor a
# data frame is returned, with col names 'T1', 'T2', ... and finally
# 'labels' 

TDAsweepImgSet <- 
   function(imgs,labels,nr,nc,thresh=c(50,100,150),intervalWidth=2,rcOnly=TRUE) 
{
   fOneImg <- function(oneImg) {
      TDAsweepOneImg(img=oneImg,nr=nr,nc=nc,thresh=thresh,
         intervalWidth=intervalWidth,rcOnly=rcOnly)
   }
   tmp <- apply(imgs,1,fOneImg)
   tda <- t(tmp)
   # 'tda' form: see 'value' from TDAsweepOneImg above; nThresh sets of
   # row counts, then nThresh sets of column counts; 2 fake columns
   nctmp <- ncol(tda)
   rowCountsEnd <- tda[1,nctmp-1]
   colCountsEnd <- tda[1,nctmp]
   tda <- tda[,-((nctmp-1):nctmp)]
   tda <- as.data.frame(tda)
   names(tda) <- paste0('T',1:ncol(tda))
   if (!is.factor(labels)) labels <- as.factor(labels)
   tda$labels <- labels
   attr(tda,'rowCountsEnd') <- rowCountsEnd
   attr(tda,'colCountsEnd') <- colCountsEnd
   attr(tda,'thresh') <- thresh
   attr(tda,'rcOnly') <- rcOnly
   tda
}

