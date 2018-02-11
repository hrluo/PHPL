#Plotting Betti-based Persistent Rank Function
args <- commandArgs(trailingOnly = TRUE)
options(scipen=9999)
#print(args)
#inputData<-args[1]
PRF<-function(a,b,stepInt=0.01){
  inputData="tmp.csv"
  df<-read.csv(inputData)[,-1]
  N<-dim(df)[1]
  dimension<-dim(df)[2]
  dim_adjust=1
  #To minus one from highest dimension
  stepStart<-a
  stepNumber<-(b-a)/stepInt
  
  firstLine=N
  secondLine=c(stepStart,stepInt,stepNumber,dimension)
  otherLine=dist(df,method='euclidean',diag=T,upper = T,p=2)
  otherLine=as.matrix(otherLine)
  
  inputtxt=paste(tools::file_path_sans_ext(inputData),'_Modified.txt',sep='')
  if(file.exists(inputtxt)){
    file.remove(inputtxt)
  }
  write.table(x=firstLine,
              file=inputtxt,
              append = T,row.names = F, col.names = F)
  write.table(x=t(as.matrix(secondLine)),
              file=inputtxt,
              append = T,row.names = F, col.names = F)
  write.table(x=otherLine,
              file=inputtxt,
              append = T,row.names = F, col.names = F)
  
  outputData=paste(tools::file_path_sans_ext(inputData),sep='')
  for(d in 0:dimension){
    phFile<-paste(outputData,'_',d,'.txt',sep="")
    if(file.exists(phFile)){
      file.remove(phFile)
    }
  }
  
  if(Sys.info()['sysname']=='Windows'){perseusOS<-'perseusWin'}
  if(Sys.info()['sysname']=='Linux'){perseusOS<-'./perseusLin'}
  
  cmd=paste(perseusOS," distmat ",inputtxt," ",outputData,sep='')
  system(cmd)
  #res<-read.table(outputData)
  BettiVector<-read.table(paste(outputData,'_betti.txt',sep=""),header=F)
  return(BettiVector)
}

PRFplot<-function(abrange=c(0,1),Betti_dim=0,gridmatplot=F){
  
  rang<-c(0,1)
  incr<-0.1
  #Betti_dim<-1  
  
  val<-PRF(a=rang[1],b=rang[2],stepInt = incr)
  valgrid<-val
  tmpmat=as.matrix(val)
  
  valgrid<-as.matrix(valgrid[,c(1,Betti_dim+1)])
  valgrid[,1]<-valgrid[,1]/dim(valgrid)[1]*rang[2]
  
  gridmat<-matrix(NA,nrow=dim(valgrid)[1],ncol=dim(valgrid)[1])
  for(a in 1:(dim(valgrid)[1]) ){
    for(b in a:(dim(valgrid)[1]) ){
      gridmat[a,b]<-valgrid[b,2]-valgrid[a,2]
    }
  }
  library(fields)
  if(gridmatplot==T){
    image(tmpmat,main=paste("Joint Betti number"))
  }else{
    image.plot(gridmat,main=paste("Persistent Rank function, dim=",Betti_dim),xlim=rang,ylim=rang)
  }
  return(gridmat)
}
PRFplot(gridmatplot=T)
PRFplot(Betti_dim = 0)
PRFplot(Betti_dim = 1)
PRFplot(Betti_dim = 2)