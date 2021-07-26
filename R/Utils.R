
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
