# Iterative Function System Fractal Algorithms in R.
Transforma2d<-function(a,b,c,d,e,f){
  #Define a 2-d affine transform.
  mat=matrix(c(a,b,c,d),nrow=2,ncol=2,byrow=T)
  translation=c(e,f)
  return(list(A=mat,b=translation))
}
weights=c(1/3,1/3,1/3)
initialPoint=c(0,0)
df=as.data.frame(matrix(NA,nrow=1,ncol=2))
df[1,]=initialPoint
thinning=1000
counter=2
for(i in 1:100000){
  chooser=rmultinom(n=1,size=1,prob=weights)
  whichTransform<-which(chooser[,1]==1)
  if(whichTransform==1){
    functional<-Transforma2d(.5,0,0,.5,0,0)    
  }
  if(whichTransform==2){
    functional<-Transforma2d(.5,0,0,.5,0.5,0)       
  }
  if(whichTransform==3){
    functional<-Transforma2d(.5,0,0,.5,1/4,sqrt(3)/4)    
  }
  #print(as.numeric(df[i-1,]))
  nextPoint=functional$A%*%as.numeric(df[counter-1,])+as.numeric(functional$b)
  if(i%%thinning==0){
    df[counter,]=nextPoint
    counter=counter+1
  }
}
par(mfrow=c(1,1))
plot(df,type='o',xlim=c(0,1),ylim=c(0,1))
points(0,0,col='red')
filenam=paste("tmp.csv", sep="")
write.csv(df,filenam)