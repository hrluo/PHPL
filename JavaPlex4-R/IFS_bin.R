args = commandArgs(trailingOnly=TRUE)
library(pracma)
filename = 'tmp.csv'
options_args<-read.table('Rargs.data')
bin_scale=as.numeric(as.character(options_args[1,1]))
simulation_signature=as.character(options_args[2,1])
xp <- c(0,1,1/2)
yp <- c(0,0,sqrt(3)/2)

xq <- c(1/2,         3/2,      1)
yq <- c(sqrt(3)/2, sqrt(3)/2,0)

#bin_scale=0.05
xp<-xp*bin_scale
yp<-yp*bin_scale
xq<-xq*bin_scale
yq<-yq*bin_scale

#inpolygon(x, y, xp, yp, boundary = FALSE)  # FALSE
#inpolygon(x, y, xp, yp, boundary = TRUE)   # TRUE
shift1<-function(xp,yp){
  xp_new<-xp+1/2*bin_scale
  yp_new<-yp+sqrt(3)/2*bin_scale
  return(list(xp=xp_new,yp=yp_new))
}
shift2<-function(xp,yp){
  xp_new<-xp+1*bin_scale
  yp_new<-yp+0*bin_scale
  return(list(xp=xp_new,yp=yp_new))
}
iterative<-function(xp,yp,times,shift_func=shift1){
  if(times<1){
    return(list(xp=xp,yp=yp))
  }
  for(k in 1:times){
    ret=shift_func(xp,yp)
    xp=ret$xp
    yp=ret$yp
  }
  return(list(xp=xp,yp=yp))
}
check_bin<-function(df,bin_xp,bin_yp,binary=T){
  count=0
  for(k in 1:dim(df)[1]){
    if( inpolygon(x=df[k,1],y=df[k,2],xp=bin_xp,yp=bin_yp,boundary=F) ){
      count=count+1
      if(binary){
        return(TRUE)
      }
    }
  }
  if(count<=0){
    return(FALSE)
  }else{
    return(count)
  }
}

df_csv<-read.csv(filename)
df_csv<-df_csv[,2:3]
non_empty_bin_centroids<-as.data.frame(matrix(NA,nrow=1,ncol=3))
ct=1
Gen_text=read.table('Rargs_Gen.data',fill=T)
Gen_text=as.data.frame(Gen_text)
Gen_text[is.na(Gen_text)] <- ""

png(paste("R_Plot_",simulation_signature,".png",sep=''),width = 875,height = 656)
par(bg='white',mfrow=c(1,1),cex=1.2)
par(mai=c(1.25,0.95,.75,.05))
plot(0,0,xlim=c(0,1),ylim=c(0,1),col='white',xlab='x',ylab='y',
     main=paste('Point Cloud Data and Binning Scheme(',simulation_signature,')',
                                            '\n Total points: ',paste(Gen_text[3,],collapse=""),
                                            '(Thinning=',paste(Gen_text[4,],collapse=""),') ',
                                            'Sampled points: ',dim(df_csv)[1],
                                            
                                            '\n Probability ratio: ',paste(Gen_text[1,],collapse=":"),
                                            '   Scaling factors: ',paste(Gen_text[2,],collapse="&")
                                            ,sep=''))
for (i in 0:floor(1/bin_scale)){
  for (j in 0:floor(1/bin_scale)){
    shifted1=iterative(xp,yp,times=i,shift_func=shift1)
    shifted2=iterative(shifted1$xp,shifted1$yp,times=j,shift_func=shift2)
    
    xp_new=shifted2$xp
    yp_new=shifted2$yp
    
    shifted1=iterative(xq,yq,times=i,shift_func=shift1)
    shifted2=iterative(shifted1$xp,shifted1$yp,times=j,shift_func=shift2)
    
    xq_new=shifted2$xp
    yq_new=shifted2$yp
    
    if(check_bin(df_csv,bin_xp = xp_new,bin_yp = yp_new)){
      non_empty_bin_centroids[ct,1]<-sum(xp_new)/3
      non_empty_bin_centroids[ct,2]<-sum(yp_new)/3
      non_empty_bin_centroids[ct,3]<-check_bin(df_csv,bin_xp = xp_new,bin_yp = yp_new,binary=F)
      polygon(x=xp_new,y=yp_new,col = adjustcolor( "cyan", alpha.f = 0.5), border = "red" )
      points(x=non_empty_bin_centroids[ct,1],y=non_empty_bin_centroids[ct,2],col="red",pch=16)
      ct=ct+1
    } 
    if(check_bin(df_csv,bin_xp = xq_new,bin_yp = yq_new)){
      non_empty_bin_centroids[ct,1]<-sum(xq_new)/3
      non_empty_bin_centroids[ct,2]<-sum(yq_new)/3
      non_empty_bin_centroids[ct,3]<-check_bin(df_csv,bin_xp = xq_new,bin_yp = yq_new,binary=F)
      polygon(x=xq_new,y=yq_new,col = adjustcolor( "cyan", alpha.f = 0.5), border = "red" )
      points(x=non_empty_bin_centroids[ct,1],y=non_empty_bin_centroids[ct,2],col="red",pch=16)
      ct=ct+1
    } 
  }
}
text(1/2,1,paste('Binned Scheme, non-empty bins:',dim(non_empty_bin_centroids)[1],sep=''),cex=1.2) 
text(1/2,.95,paste('Bin scale:',bin_scale,sep=''),cex=1.2) 
points(df_csv,col='blue',pch=16)
dev.off()
write.csv(non_empty_bin_centroids,'tmp_bin.csv')