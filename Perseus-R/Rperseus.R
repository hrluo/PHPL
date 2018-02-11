#setwd(/path/to/this/file/and/perseusWin.exe)
args <- commandArgs(trailingOnly = TRUE)
options(scipen=9999)
#print(args)
#inputData<-args[1]
inputData="tmp.csv"
df<-read.csv(inputData)[,-1]
N<-dim(df)[1]
dimension<-dim(df)[2]
dim_adjust=1
#To minus one from highest dimension
stepStart<-0
stepInt<-0.001
stepNumber<-1000

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
dfDiagram<-as.data.frame(matrix(NA,nrow=1,ncol=3))
colnames(dfDiagram)<-c('birth','death','dimension')
counter<-1
for(d in 0:(dimension-dim_adjust)){
  phFile<-paste(outputData,'_',d,'.txt',sep="")
  info = file.info(phFile)
  empty = (info$size == 0)
  
  if(file.exists(phFile) && !empty){
    phData<-read.table(phFile,header=F)
    for(k in 1:dim(phData)[1]){
      dfDiagram[counter,]<-c(phData[k,],d)
      counter<-counter+1
    }
    print(d)
    #print(phData)
  }
}
#Plotting featrue
par(mfrow=c(2,2))
plot(df[,1],df[,2],main=paste('Data Plot, N=',N),type='o')

dfDiagram=dfDiagram[!duplicated(dfDiagram), ]

plot(0,0,xlim=c(0,1),ylim=c(0,1),
     main='Persistent Diagram',
     xlab='birth',ylab='death'
     ,yaxt='n',col='white')
abline(a =0 ,b =1,col='black' )
for (p in 1:dim(dfDiagram)[1]){
  rec=dfDiagram[p,]
  bir=(rec$birth/stepNumber)*(stepInt*stepNumber)+stepStart
  dea=(rec$death/stepNumber)*(stepInt*stepNumber)+stepStart
  points(bir,dea,col=rec$dimension+1,pch=rec$dimension+1,lwd=2)
}

image(otherLine,main="Distance Matrix Heatmap")

plot(0,0,xlim=c(0,stepNumber*stepInt),ylim=c(0,dim(dfDiagram)[1]),
     main='Barcode',
     xlab='time',ylab=''
     ,yaxt='n',col='white')
ht=0
for (d in 0:(dimension-dim_adjust)){
  df_sub<-dfDiagram[dfDiagram$dimension==d,]
  if(nrow(df_sub)==0) next
  for (p in 1:dim(df_sub)[1]){
    if(df_sub[p,]$death==-1){
      df_sub[p,]$death=stepNumber
    }
  }
  df_sub$diff<-df_sub$death-df_sub$birth
  df_sub=df_sub[order(-df_sub$diff),]
  #print(dr)
  for(k in 1:dim(df_sub)[1]){
    rec<-df_sub[k,]
    st=(rec$birth/stepNumber)*(stepInt*stepNumber)+stepStart
    dt=(rec$death/stepNumber)*(stepInt*stepNumber)+stepStart
    segments(x0 = st, y0 = ht, x1 = dt, y1 = ht,
             col = rec$dim+1,lwd=2)
    ht=ht+1
  }
}

