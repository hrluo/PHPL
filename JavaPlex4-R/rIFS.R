# Iterative Function System Fractal Algorithms in R.
Transforma2d<-function(a,b,c,d,e,f,scaling=1){
  #Define a 2-d affine transform.
  mat=matrix(c(a,b,c,d),nrow=2,ncol=2,byrow=T)
  translation=c(e,f)
  return(list(A=mat*scaling,b=translation*scaling))
}
Gen_text=read.table('Rargs_Gen.data',fill=T)
Gen_text=as.data.frame(Gen_text)
Gen_text[is.na(Gen_text)] <- ""
weights=Gen_text[1,]
initialPoint=c(1/2,sqrt(3)/6)
df=as.data.frame(matrix(NA,nrow=1,ncol=2))
df[1,]=initialPoint
total_runs=Gen_text[3,1]
thinning=Gen_text[4,1]
counter=2
for(i in 1:total_runs){
  chooser=rmultinom(n=1,size=1,prob=weights)
  whichTransform<-which(chooser[,1]==1)
  if(whichTransform==1){
    functional<-Transforma2d(.5,0,0,.5,0,0,as.numeric(Gen_text[2,1]))
  }
  if(whichTransform==2){
    functional<-Transforma2d(.5,0,0,.5,0.5,0,as.numeric(Gen_text[2,2]))      
  }
  if(whichTransform==3){
    functional<-Transforma2d(.5,0,0,.5,1/4,sqrt(3)/4,as.numeric(Gen_text[2,3]))
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
points(initialPoint[1],initialPoint[2],col='red')
filenam="tmp.csv"
df=tail(df,dim(df)[1]*.9)
write.csv(df,filenam,append = F)
print('IFS fractal constructed!')