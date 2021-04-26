
set.seed(9999)
m1 <- matrix(sample(1:100,20),ncol=5)
m1
#     [,1] [,2] [,3] [,4] [,5]
# [1,]   19   63    4   71   70
# [2,]   43   29  100   33    6
# [3,]   20    1   57   94   54
# [4,]   40   75   48   97   89
m1a <- as.vector(t(m1))  # change to row-major vector form
TDAsweepOneImg(img=m1a,nr=4,nc=5,thresh=50,intervalWidth=1,rcOnly=TRUE)
# 2 1 1 2 0 2 1 2 2
TDAsweepOneImg(img=m1a,nr=4,nc=5,thresh=50,intervalWidth=2,rcOnly=TRUE)
# 1.5 1.5 1.0 1.5 2.0
TDAsweepOneImg(img=m1a,nr=4,nc=5,thresh=50,intervalWidth=1,rcOnly=FALSE)
# 2 1 1 2 0 2 1 2 2 0 1 0 1 1 1 1 1 0 1 0 1 2 1 1 1
TDAsweepOneImg(img=m1a,nr=4,nc=5,thresh=50,intervalWidth=3,rcOnly=FALSE)
# [1] 1.3333333 1.3333333 1.6666667 0.3333333 1.0000000 0.6666667 0.6666667
# [8] 1.3333333 1.0000000


