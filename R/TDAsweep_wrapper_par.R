#' Add together two numbers
#' 
#' @param x A number.
#' @param y A number.
#' @return The sum of \code{x} and \code{y}.
#' @examples
#' add(1, 1)
#' add(10, 1)

# --- parameters --- #
# images: dataframe or matrix of sets of vectors of image pixels
# labels: dataframe or vector of labels
# nr: integer; number of rows in image
# nc: integer; number of cols in image
# rgb: bool.; TRUE if images are RGB, otherwise greyscale
# thresholds: integer vector; thresholds for pixels
# intervalWidth: integer; interval width for each sweep
# cls: integer; how many clusters for parallel. No parallel if NULL
# prep: bool; are the images already in prep format
# rcOnly: bool; sweep row and column only

TDAsweep <- function(images, labels, nr, nc , rgb=TRUE, 
                                 thresholds = 0, intervalWidth=1, cls=NULL, prep=FALSE, rcOnly=FALSE)
{

   # set current working directory to file location
  if(!is.null(cls)){  # default cluster
    print("creating custers...")
    cls <- makeCluster(cls)
  }
  tdaOut <- NULL
  for (thresh in thresholds) {
    images_df <- as.data.frame(images)  
    if (rgb == TRUE) {  # run sweep three times, for R,G,B
      tda_result <- NULL  # will be the output after R,G,B sweeps
      one_layer_size <- nr*nc
      images_R = images_df[, 1:one_layer_size]  
      images_G = images_df[, (one_layer_size+1):(2*one_layer_size)]  
      images_B = images_df[, (2*one_layer_size+1):(3*one_layer_size)]  
      # run TDA Sweep for R, G, and B layers
      tda_result_R <- tda_sweep(images=images_R, labels=labels, 
                                nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth,
                                cls=cls, prep=prep, rcOnly=rcOnly)
      tda_result_G <- tda_sweep(images=images_G, labels=labels, 
                                nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth,
                                cls=cls, prep=prep, rcOnly=rcOnly)
      tda_result_B <- tda_sweep(images=images_B, labels=labels, 
                                nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth,
                                cls=cls, prep=prep, rcOnly=rcOnly)
      new_dataset <- cbind(tda_result_R, tda_result_G, tda_result_B)
    } else {  # greyscale
      tda_result <- tda_sweep(images=images_df, labels=labels, 
                              nr=nr, nc=nc, thresh=thresh, intervalWidth=intervalWidth,
                              cls=cls, prep=prep, rcOnly=rcOnly)
      new_dataset <- tda_result 
    }
    tdaOut <- cbind(tdaOut,new_dataset)
  }
  result_tda <- cbind(tdaOut,labels)
  return_attr <- list(tda_df = result_tda, num_rows = dim(result_tda)[1],
                      num_features = dim(result_tda)[2],
                      thresholds = thresholds, interivalWidth = intervalWidth)
  class(return_attr) <- "sweepOut"
  return(return_attr)
}

# basic pipeline function for tda-sweep in one set of images
tda_sweep <- function(images, labels, nr, nc, thresh, intervalWidth, cls, prep, rcOnly)
{  
  if(!is.null(cls)){  # cls!=NULL. start parallel
    core_num = dim(as.matrix(setclsinfo(cls)))[1]
    img_pixels <- images
    labels <- labels
    
    if(prep == FALSE){
      print('starting to prep...')
      setclsinfo(cls)
      clusterExport(cls, varlist=c('nr', 'thresh'), envir=environment())
      distribsplit(cls, 'img_pixels')
      distribsplit(cls, 'labels')
      clusterEvalQ(cls, library(tdaImage))
      res <- clusterEvalQ(cls, res <- prepImgSet(img_pixels, nr=nr,
                                                 labels=labels, thresh=thresh))
      res <- do.call('rbind', res)
      prepImgs <- res[1,]
      for(i in 2:core_num){
        prepImgs <- addlists(prepImgs, res[i,], c)
      }
      prepImgs$thresh = thresh
      prepImgs$nr = nr
    }
    else{
      prepImgs <- images
    }
    
    print("starting sweep...")
    # sweep par
    setclsinfo(cls)
    imgsPerNode <- ceiling(nrow(img_pixels)/core_num)
    clusterExport(cls, varlist=c('nr', 'nc', 'intervalWidth', 'rcOnly')
                  , envir=environment())
    temp <- list()
    prepImgs_split <- list()
    for(i in 1:core_num){
      temp$imgs <- prepImgs$imgs[(imgsPerNode*(i-1)+1):(imgsPerNode*i)]
      temp$thresh <- prepImgs$thresh[1]
      temp$nr <- prepImgs$nr[1]
      temp$labels <- prepImgs$labels[(imgsPerNode*(i-1)+1):(imgsPerNode*i)]
      prepImgs_split[i] <- list(temp)
    }
    clusterApply(cls, prepImgs_split, function(x){prepImgs_node <<- x; NULL})
    clusterEvalQ(cls, library(tdaImage))
    
    res <- clusterEvalQ(cls, res <- TDAsweepImgSet(prepImgs_node, nr=nr, nc=nc,
                                                      intervalWidth=intervalWidth, rcOnly=rcOnly))  # prepImgs_node not found??
    result <- do.call("rbind", res)  # combine results accross all clusters
    return(result)
  } else{  # cls=NULL. No parallel
    img_pixels <- images
    labels <- labels 
    if(prep == FALSE){  # if need prep
      print("starting prep...")
      prepImgs <- prepImgSet(img_pixels, nr=nr, labels=labels, thresh=thresh)
    } else{
      prepImgs <- images
    }
    print("starting sweep...")
    result <- TDAsweepImgSet(prepImgs, nr=nr, nc=nc, intervalWidth=intervalWidth,
                   rcOnly=rcOnly)
    return(result)
  }

}
