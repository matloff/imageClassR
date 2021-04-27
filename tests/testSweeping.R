
set.seed(9999)
m1 <- matrix(sample(1:100,20),ncol=5)
m1
#      [,1] [,2] [,3] [,4] [,5]
# [1,]   96   74    9   10   43
# [2,]    6   66   36   38   20
# [3,]   41    8   25   14   40
# [4,]    3   31   83   19   63
m1a <- as.vector(t(m1))  # change to row-major vector form
TDAsweepOneImg(img=m1a,nr=4,nc=5,thresh=50,intervalWidth=1,rcOnly=TRUE)
# [1] 1 1 0 2 1 1 1 0 1
TDAsweepOneImg(img=m1a,nr=4,nc=5,thresh=50,intervalWidth=2,rcOnly=TRUE)
# [1] 1.0 1.0 1.0 0.5 1.0
TDAsweepOneImg(img=m1a,nr=4,nc=5,thresh=50,intervalWidth=1,rcOnly=FALSE)
# [1] 1 1 0 2 1 1 1 0 1 0 0 1 1 2 0 0 0 1 1 1 0 0 1 0 1
TDAsweepOneImg(img=m1a,nr=4,nc=5,thresh=50,intervalWidth=3,rcOnly=FALSE)
# [1] 0.6666667 1.3333333 0.6666667 0.3333333 1.0000000 0.3333333 0.6666667
# [8] 0.3333333 1.0000000
m2 <- t(m1)
m2
#      [,1] [,2] [,3] [,4]
# [1,]   96    6   41    3
# [2,]   74   66    8   31
# [3,]    9   36   25   83
# [4,]   10   38   14   19
# [5,]   43   20   40   63
m2a <- as.vector(m1)
TDAsweepOneImg(img=m2a,nr=5,nc=4,thresh=50,rcOnly=FALSE)
# [1] 1 1 1 0 1 1 1 0 2 0 0 0 2 1 1 0 0 1 1 1 0 0 1 0 1
ma <- rbind(m1a,m2a,m2a,m1a)
lbls <- c(1,3,2,2)
TDAsweepImgSet(ma,lbls,4,5,50,rcOnly=FALSE)
#       T1 T2 T3 T4 T5 T6 T7 T8 T9 T10 T11 T12 T13 T14 T15 T16 T17 T18 T19 T20
# m1a    1  1  0  2  1  1  1  0  1   0   0   1   1   2   0   0   0   1   1   1
# m2a    2  1  1  1  1  1  0  0  2   0   0   1   1   1   0   0   1   1   1   0
# m2a.1  2  1  1  1  1  1  0  0  2   0   0   1   1   1   0   0   1   1   1   0
# m1a.1  1  1  0  2  1  1  1  0  1   0   0   1   1   2   0   0   0   1   1   1
#       T21 T22 T23 T24 T25 labels
# m1a     0   0   1   0   1      1
# m2a     1   1   0   0   1      3
# m2a.1   1   1   0   0   1      2
# m1a.1   0   0   1   0   1      2

