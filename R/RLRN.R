
# RLRN routines 

######################  RLRNOneImg()  ##############################

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

RLRNOneImg <- function(img,nr,nc,thresh,intervalWidth=1,rcOnly=TRUE) 
{
stop('under construction')   
   rlrnRows <- NULL
   rlrnCols <- NULL
   rlrnDiags <- NULL

   for (threshi in thresh) {

      # replace each pixel by 1 or 0, according to whether >= 1, and
      # convert to matrix rep
      img10 <- as.integer(img >= threshi)
      img10vec <- img10
      img10 <- matrix(img10,ncol=nc,byrow=TRUE)
   
      counts <- NULL
      for (i in 1:nr) counts <- c(counts,findNumComps(img10[i,]))
      counts <- toIntervalMeans(counts,intervalWidth)
      rlrnRows <- c(rlrnRows,counts)
      rowCountsEnd <- length(rlrnRows)
   
      counts <- NULL
      for (i in 1:nc) counts <- c(counts,findNumComps(img10[,i]))
      counts <- toIntervalMeans(counts,intervalWidth)
      rlrnCols <- c(rlrnCols,counts)
      colCountsEnd <- rowCountsEnd + length(rlrnCols)
   
      if (!rcOnly) {
         counts <- getNWSEdiags(img10vec,nr,nc)
         rlrnDiags<- c(rlrnDiags,counts)
         counts <- getSWNEdiags(img10vec,nr,nc)
         counts <- toIntervalMeans(counts,intervalWidth)
         rlrnDiags <- c(rlrnDiags,counts)
      }

   }

   rlrn <- c(rlrnRows,rlrnCols,rlrnDiags)
   # add 2 fake elements, for communicating row, col counts ends
   rlrn <- c(rlrn,rowCountsEnd,colCountsEnd)
   rlrn
}

######################  helper functions  ##############################

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

#######################  RLRNImgSet()  ############################

# the main function

# this routine sweeps through all images in a matrix 'imgs', one image
# per row; 'labels' is the associated labels, as a vector or factor a
# data frame is returned, with col names 'T1', 'T2', ... and finally
# 'labels' 

RLRNImgSet <- 
   function(imgs,labels,nr,nc,thresh=c(50,100,150),intervalWidth=2,
      RGB=FALSE,rcOnly=TRUE) 
{
   fOneImg <- function(oneImg) {
      TDAsweepOneImg(img=oneImg,nr=nr,nc=nc,thresh=thresh,
         intervalWidth=intervalWidth,rcOnly=rcOnly)
   }
   tmp <- apply(imgs,1,fOneImg)
   rlrn <- t(tmp)
   # 'rlrn' form: see 'value' from TDAsweepOneImg above; nThresh sets of
   # row counts, then nThresh sets of column counts; 2 fake columns
   nctmp <- ncol(rlrn)
   rowCountsEnd <- rlrn[1,nctmp-1]
   colCountsEnd <- rlrn[1,nctmp]
   rlrn <- rlrn[,-((nctmp-1):nctmp)]
   rlrn <- as.data.frame(rlrn)
   names(rlrn) <- paste0('T',1:ncol(rlrn))
   if (!is.factor(labels)) labels <- as.factor(labels)
   rlrn$labels <- labels
   attr(rlrn,'rowCountsEnd') <- rowCountsEnd
   attr(rlrn,'colCountsEnd') <- colCountsEnd
   attr(rlrn,'thresh') <- thresh
   attr(rlrn,'rcOnly') <- rcOnly
   attr(rlrn,'RGB') <- RGB
   rlrn
}
