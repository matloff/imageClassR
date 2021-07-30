
# contents:

#    1.  Components helpers, for TDAsweep, RLRN.
# 
#    2.  Misc.


#####################################################################
####################  components helpers  ###########################
#####################################################################

# findNumComps():  finds the number of components in a vertical,
# horizontal or diagonal ray

# args:
#    ray: a vector of 0-1 pixel values, e.g. from one row of an image

# value: number of components found in this sweep

findNumComps <- function(ray)
{
   # components in tmp start wherever a 0 is followed by a 1, or with a
   # 1 on the left end
   rayLength <- length(ray)
   tmp <- ray
   tmp0 <- c(0,tmp)
   tmp0 <- tmp0[-(rayLength+1)]
   sum(tmp - tmp0 == 1)
}

# used to find TDA-style components; 'ray' is a sequence of 1s and 0s; a
# component is a sequence of conseecutive 1s; function returns a
# 2-column matrix showing the start and stop points of components in
# 'ray'; (0,0) is output if no components

findEndpointsOneRay <- function(ray) 
{
   if (sum(ray) == 0) {
      starts <- 0
      ends <- 0
   } else {
      lngRay <- length(ray)
      ray <- c(0,ray,0)  # to make sure have 0-1 and 1-0 transitions
      rayShiftLeft <- c(ray[-1],0)
      diffs <- rayShiftLeft - ray
      starts <- which(diffs == 1)
      ends <- which(diffs == -1) - 1
   }
   cbind(starts,ends)
}

# apply findEndpointsOneRay() to full image, assumed in matrix form; rows
# and columns only, no diagonals; note: img must already be thresholded,
# thus consisting only of 0s and 1s

# 4-column data frame output, consisting of start point, end point,
# row/col number, and 'row' or 'col' 

findEndpointsOneImg <- function(img) 
{
   doOneRowCol <- function(i)  {
      if (rowcol == 'row') {
         n <- nc
         ray <- img[i,-(nc+1)]
      } else {
         n <- nr
         ray <- img[,i]
      }
      tmp <- findEndpointsOneRay(ray)
      cbind(tmp,i)  # tack on to each endpt the row/col number 
   }
   nr <- nrow(img)
   nc <- ncol(img)

   # process the rows
   rowcol <- 'row'
   rowData <- lapply(1:nr,doOneRowCol)
   rowData <- do.call(rbind,rowData)
   rowData <- as.data.frame(rowData)
   names(rowData) <- c('start','end','rcnum')
   rowData$rc <- rowcol

   # process the columns
   rowcol <- 'col'
   colData <- lapply(1:nc,doOneRowCol)
   colData <- do.call(rbind,colData)
   colData <- as.data.frame(colData)
   names(colData) <- c('start','end','rcnum')
   colData$rc <- rowcol

   rbind(rowData,colData)
}

#######################################################################
#####################  data augmentation ##############################
#######################################################################

# arguments:


#    img: image, a matrix
#    nVFlip: number of vertical flips
#    nHFlip: number of horizontal flips
#    nShift: number of shifts; h,v done separately
#    maxShift: for b, h,v shift each random from [-b,b]

dataAug <- function(imgSet,nr,nc,nVFlip,nHFlip,nShift,maxShift) 
{
   res <- NULL

   if (nVFlip > 0) {
      for (i in 1:nVFlip) {
         j <- sample(1:nr)
         img <- imgSet[j,]
         img <- unlist(img)
         img <- matrix(img,byrow=TRUE,nrow=nr)
         tmp <- matrix(img[nr:1,],nrow=1)
         res <- rbind(res,tmp)
      }
   }

##    if (nHFlip > 0) {
##       for (i in 1:nHFlip) {
##          j <- sample(1:nr)
##          img <- matrix(imgSet[j,],byrow=TRUE,nrow=nr)
##          tmp <- matrix(img[,nc:1],byrow=TRUE,nrow=1)
##          res <- rbind(res,tmp)
##       }
##    }

##    if (maxShift > 0) {
##       b <- maxShift
##       zeros <- matrix(rep(0,b*nc,ncol=nc))
##       for (i in 1:nHFlip) {
##          img1 <- rbind(tmp,img,tmp)
##          for (i in seq(1,nShift,1)) {
##             r <- sample(-b:b,1) - 1
##             tmp <- img1[(1+r):(nc+r),]
##             res <- rbind(res,tmp)
##          }
##       }

   res
}

#######################################################################
###########################  misc. ####################################
#######################################################################

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

# routines to read in pixels and labels from binary files; code by
# Yu-Shi

load_image_file = function(filename) {  
   # function for extracting dataset from Brendan
  ret = list()
  f = file(filename, 'rb')
  readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  n    = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  nrow = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  ncol = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  x = readBin(f, 'integer', n = n * nrow * ncol, size = 1, signed = FALSE)
  close(f)
  data.frame(matrix(x, ncol = nrow * ncol, byrow = TRUE))
}

# load label files
load_label_file = function(filename) {  
  # function for extracting dataset from Brendan
  f = file(filename, 'rb')
  readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  n = readBin(f, 'integer', n = 1, size = 4, endian = 'big')
  y = readBin(f, 'integer', n = n, size = 1, signed = FALSE)
  close(f)
  y
}

