set.seed(1234)
df<-matrix(NA,nrow=20,ncol=3)
myFun <- function(n = 5000) {
  a <- do.call(paste0, replicate(5, sample(LETTERS, n, TRUE), FALSE))
  paste0(a, sprintf("%04d", sample(9999, n, TRUE)), sample(LETTERS, n, TRUE))
}

colnames(df)<-c('OBS','X.coord','Y.coord')
for(i in 1:dim(df)[1]){
  city<-i
  lon<-runif(1)*180-90
  lat<-runif(1)*360-180
  df[i,]<-c(city,lat,lon)
}

df<-as.data.frame(df)

write.csv(df, file = "cityloc.csv")
write.csv(df[,2:3],file="coordpair.csv")
m1<-matrix(c(0,0,
         0,sqrt(2),
         1,0,
         1,sqrt(2)),ncol=2)
write.csv(m1,file="test.csv")