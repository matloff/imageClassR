
# data prep routines, not necessarily for TDAsweep



# prepImgSet():  

#    inputs: 

#       imgs: image collection matrix, one image per row 
#       nr: the number of pixel rows in an image (cols 
#           assumed stored in col-major order)
#       labels: an associated vector of class labels 
#       thesh: the threshold 

#    output, an R list with components:

#       imgs: an R list, one element per image; an element has structure: 

#          a pixels locations matrix (see below)
#          the index of the original image in the input data, and 
#          the class label 

#          pixels locations matrix consists of (row number,col number)
#          pairs; a pair (i,j) means the pixel in row i, column j in the
#          image has intensity above the threshold

#      thresh: copy of the input 'thresh'
#      nr: copy of the input n'r'
#      labels: copy of the input 'labels'

prepImgSet <- function(imgs,nr,labels,thresh) 
{
   pOI <- function(oneImgRow) {
      img2D <- imgTo2D(imgs[oneImgRow,],nr)
      img <- prepOneImage(img2D,thresh)
      list(img,oneImgRow,labels[oneImgRow])
   }
   imgs <- lapply(1:nrow(imgs),pOI)
   list(imgs=imgs,thresh=thresh,nr=nr,labels=labels)
}


# img2D is output of regtools::imgTo2D() for a single image; nr, thresh as above

prepOneImage <- function(img2D,thresh) 
{
   aboveThresh <- which(img2D[,3] >= thresh)
   if (length(aboveThresh) < 2) returnImg <- NA
   else returnImg <- img2D[aboveThresh,1:2,drop=FALSE]
   returnImg
}


### #######################  experiments  ###############################
### 
### expt1 <- function(n,w,iT) {
###    prepForExpt('../TDA.tmp/MNIST.Save','mntrn',28,28,iT,n) 
###    z <- TDAsweepImgSet(imgsPrepped,28,28,intervalWidth=w)
###    zd <- as.data.frame(z) 
###    lmout <- mvrlm(zd,trnLabels,'dig') 
###    preds <- predict(lmout,zd) 
###    preds <- apply(preds,1,which.max) - 1 
###    print(mean(preds == trnLabels) )
###    print(table(preds,trnLabels))
### }
### 
### # MNIST; sample n for training, n for testing; bounds lt, rt for hist,
### # bin width w; intensity threshold iT
### expt2 <- function(n,lt,rt,w,iT) {
###    load('../TDA.tmp/MNIST.Save')  # loads mntrn, mntst
###    mntrn <- as.matrix(mntrn)
###    colnames(mntrn) <- NULL 
###    set.seed(9999)
###    trnidxs <- sample(1:nrow(mntrn),n) 
###    tstidxs <- setdiff(1:nrow(mntrn),trnidxs)
###    mtr <- mntrn[trnidxs,-785]
###    trlabels <- mntrn[trnidxs,785]
###    mts <- mntrn[tstidxs,-785]
###    imgsPrepped <- prepImgSet(mtr,28,trlabels,iT)  # allow for fainter images
###    ihs <- imgsHomStat(imgsPrepped,lt,rt,w)
###    mts <- mntrn[tstidxs,]
###    counts <- NULL
###    for (i in 1:250) {
###       mtsi <- mts[i,]
###       predi <- predict(ihs,mtsi[-785],10)
###       # cat(predi,'  ',mtsi[785],'\n')
###       counts <- rbind(counts,c(predi,mtsi[785]))
###    }
###    print(mean(counts[,1] == counts[,2]))
###    print(table(data.frame(counts)))
### }

