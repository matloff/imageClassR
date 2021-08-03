
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


#    imgSet: data frame, one image per row
#    yName: name of column with labels
#    nVFlip: number of vertical flips
#    nHFlip: number of horizontal flips
#    nShift: number of shifts; h,v done separately
#    maxShift: for b, h,v shift each random from [-b,b]

# value:

#    augmented data frame

dataAug <- function(imgSet,yName,nr,nc,nVFlip=0,nHFlip=0,nShift=0,maxShift=0) 
{
   # outIdxs will record the indices of the augmented rows back in the
   # original image set
   outIdxs <- NULL  
   nImgs <- nrow(imgSet)
   ycol <- which(yName == names(imgSet))
   imgs <- imgSet[,-ycol]

   outPixels <- NULL  # will be the augmented image set, minus labels

   if (nVFlip > 0) {
      augIdxs <- sample(1:nImgs,nVFlip,replace=TRUE)
      outIdxs <- c(outIdxs,augIdxs)
      for (i in 1:nVFlip) {
         j <- augIdxs[i]
         img <- imgs[j,]
         img <- unlist(img)  
         img <- matrix(img,byrow=TRUE,nrow=nr)  # images in row-major
         img <- img[nr:1,]
         tmp <- matrix(t(img),nrow=1)
         outPixels <- rbind(outPixels,tmp)
      }
   }

   if (nHFlip > 0) {
      augIdxs <- sample(1:nImgs,nHFlip,replace=TRUE)
      outIdxs <- c(outIdxs,augIdxs)
      for (i in 1:nHFlip) {
         j <- augIdxs[i]
         img <- imgs[j,]
         img <- unlist(img)
         img <- matrix(img,byrow=TRUE,nrow=nr)
         img <- img[,nc:1]
         tmp <- matrix(t(img),nrow=1)
         outPixels <- rbind(outPixels,tmp)
      }
   }

   if (maxShift > 0) {
   
      if (nShift == 0) stop('nShift = 0')
      if (maxShift >= min(nr,nc))  stop('cannot shift more than image size')

      # basic idea:  the shift will result in 0s in the portion of the
      # matrix "vacated" by the shift; handle this by creating a
      # supermatrix with 0s built in, then shift the original matrix
      # within it
      b <- maxShift
      nShift <- ceiling(nShift / 2)  # 1/2 vert, 1/2 horiz

      # determine which images will be shifted; each selected image
      # will be first shifted vertically, then horizontally
      augIdxs <- sample(1:nImgs,nShift,replace=TRUE)
      outIdxs <- c(outIdxs,augIdxs)
      
      for (i in 1:nShift) {

         # image to be shifted
         j <- augIdxs[i]
         img <- imgs[j,]
         img <- unlist(img)  
         img <- matrix(img,byrow=TRUE,nrow=nr)

         # vertical shift
         zeros <- matrix(rep(0,b*nc),ncol=nc)
         supermatrix <- rbind(zeros,img,zeros)  
         # loc of orig image in supermatrix
         firstRealRow <- 1+b
         lastRealRow <- nr+b
         # random amount of shift
         bb <- -b:b
         bb[b+1]
         bb <- bb[-(b+1)]  # remove 0 case
         r <- sample(bb,1) 
         # shift within supermatrix, extract region of original image
         tmp <- supermatrix[(firstRealRow+r):(lastRealRow+r),]
         tmp <- matrix(t(tmp),nrow=1)
         outPixels <- rbind(outPixels,tmp)
         browser()

         # horizontal shift
         zeros <- matrix(rep(0,b*nr),ncol=b)
         supermatrix <- cbind(zeros,img,zeros)  
         # loc of orig image in supermatrix
         firstRealCol <- 1+b
         lastRealCol <- firstRealCol + nc - 1
         # random amount of shift
         bb <- -b:b
         bb[b+1]
         bb <- bb[-(b+1)]  # remove 0 case
         r <- sample(bb,1) 
         # shift within supermatrix, extract region of original image
         tmp <- supermatrix[,(firstRealCol+r):(lastRealCol+r)]
         tmp <- matrix(t(tmp),nrow=1)
         outPixels <- rbind(outPixels,tmp)
      }
   }

   outDF <- as.data.frame(outPixels)
   outDF[[yName]] <- imgSet[outIdxs,ycol]
   names(outDF) <- names(imgSet)
   outDF <- rbind(outDF,imgSet)
   outDF
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

