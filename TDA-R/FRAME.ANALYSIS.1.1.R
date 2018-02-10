library("TDA")

#This is a source of 2-dim normal distribution with mean (0,0)
PH_RIPS<-function(X,by=.1,mytitle="My Title",threshold=Inf,percentile=1,percent.contour=NULL,full.data=X){
  #Note that our kernel density estimation only works for 2-dim data and will result in error if dataX 
  
  #Xlim and Ylim of the sample 
  Xlim<-range(X[,1])
  Ylim<-range(X[,2])
  cat("\n X range: ",Xlim)
  cat("\n Y range: ",Ylim)
  
  #by <- 0.01
  #Ideally, we need to construct this smoothly. However, nerve theorem allows us to construct Cech complexes.
  #Ideally, we need to construct the Cech complexes exhausting all 2^n possible combinations, however we take VR approximation.
  MAX_SCALE<-max(dist(X))
  Diag <- ripsDiag(X = X, 
                  maxdimension=10,
                  maxscale=MAX_SCALE,
                  library="GUDHI",
                  dist="euclidean",
                  printProgress=TRUE)
  #We use the distance to measure distance function' if we want to recover the stationarity then we probably want KDE instead.

  #Extract information from the computed Persistent Diagram
  Diagdf<-as.matrix(Diag[["diagram"]])
  colnames(Diagdf)<-c('PHorder','birth','death')
  #The Diagdf contains all information we can get from the PH, that is for each row
  ###'PHorder'=* means: At the persistent homology group H_{p}(K_{*}) this topological feature lives
  ###'birth'=*   means: At the distance *, (which is dependent on the choice of the distance function in 'FUN') this topological feature born
  ###'death'=*   means: At the distance *, (which is dependent on the choice of the distance function in 'FUN') this topological feature die
  par(mfrow = c(2, 2),
      oma = c(1,1,1,1) + 0.1,
      mar = c(1,1,1,1) + 0.1)
  
  plot(x=full.data[,1],y=full.data[,2],pch=1,cex=.6,main=paste("Data Plot\n N=",dim(full.data)[1],"\n Subsample at KDE Percentile=",percentile))
  if(!is.null(percent.contour) ){
    lines(percent.contour,lty=2)
  }
  
  connectPoints<-function(dataX,distThreshold){
    dataN<-dim(dataX)[1];
    dstCOLOR<-matrix(0,nrow=dataN,ncol=dataN)
    
    for(num1 in 1:dataN){
      for(num2 in 1:dataN){
        if(num1==num2){next}
        pt1<-dataX[num1,]
        pt2<-dataX[num2,]
        if(dist(rbind(pt1,pt2))<=distThreshold){
          lines(x=c(pt1[1],pt2[1]),
                y=c(pt1[2],pt2[2]),col='cyan' )
          dstCOLOR[num1,num2]<-1;
          dstCOLOR[num2,num1]<-1;
          
        }
      }
    }
    require(grDevices)
    for(vert1 in 1:dataN){
      for(vert2 in 1:dataN){
        for(vert3 in 1:dataN){
          if(vert1==vert2 | vert2==vert3 | vert1==vert3){next}
          pt1<-dataX[vert1,]
          pt2<-dataX[vert2,]
          pt3<-dataX[vert3,]
          
          side1<-dist(rbind(pt1,pt2))
          side2<-dist(rbind(pt2,pt3))
          side3<-dist(rbind(pt1,pt3))
          if(side1<=distThreshold & side2<=distThreshold & side3<=distThreshold){
            dstCOLOR[vert1,vert2]<-2
            dstCOLOR[vert2,vert1]<-2
            dstCOLOR[vert1,vert3]<-2
            dstCOLOR[vert3,vert1]<-2
            dstCOLOR[vert2,vert3]<-2
            dstCOLOR[vert3,vert2]<-2
            
            triangle<-cbind(pt1,pt2,pt3)
            xx <- triangle[1,]
            yy <- triangle[2,]
            #plot(xx, yy, type = "n", xlab = "Time", ylab = "Distance")
            polygon(xx, yy, col = adjustcolor( "yellow", alpha.f = 0.1), border = "cyan")
          }
        }
      }
    }
    return(dstCOLOR)
  }
  if(is.finite(threshold)){
    dstCOLOR_data<-connectPoints(X,distThreshold = threshold)
  }else{
    N<-dim(X)[1];
    dstCOLOR_data<-matrix(2,nrow=N,ncol=N)
  }
  #This is the first plot illustrating how the sample looks like.
  text(x=X[,1]+.1,y=X[,2]+.1, labels=1:dim(X)[1], cex= .5)
  plot(Diagdf, 
       #band = 2 * bandwidth, 
       main = "Persistent Diagram")
  #This is the second plot illustrating the persistent homology of the sample in terms of persistent diagram.
  
  plotDistance<-function(TwoDimData,cutoff,dstCOLOR=dstCOLOR){
    #2dData <- cbind(1:4,1:4)
    dst <- dist(TwoDimData)
    dst <- data.matrix(dst)
    
    dim <- ncol(dst)
    
    library(fields)
    #image.plot(1:dim, 1:dim, t(dst), axes = FALSE, xlab="", ylab="")
    print(dstCOLOR)
   
    dst <- dst[,c(dim:1),drop=FALSE]
    
    #col.pal<-palette()
    #palette(c('white'<->0,'cyan'<->1,'yellow'<->2))
    color_pallete_function <- colorRampPalette(
      colors = c("white", "yellow", "cyan"),
      space = "Lab" # Option used when colors do not represent a quantitative scale
    )
    dstCOLOR=dstCOLOR[,c(dim(dstCOLOR)[1]:1),drop=FALSE]
    image(1:dim, 1:dim, dstCOLOR+1, axes = FALSE, xlab="", ylab="",col=color_pallete_function(3))
    #palette(col.pal)
    
    axis(2, dim:1, 1:dim, cex.axis = 1, las=3)
    axis(3, 1:dim, 1:dim, cex.axis = 1, las=1)
    
    text(expand.grid(1:dim, 1:dim), sprintf("%0.3f", dst), cex=.5)
    title("Distance Matrix of the data")
    
  }
  plotDistance(X,cutoff=threshold,dstCOLOR = dstCOLOR_data)
  #This is the third plot illustrating the Euclidean distance matrix in terms of heat map.
  
  
  
  plot(Diagdf, 
       barcode = TRUE, 
       main = "Barcode")
  if(is.finite(threshold)){
    abline(v=threshold,col="cyan",lwd=2,lty=2)
  }
  #This is the fourth plot illustrating the persistent homology of the sample in terms of barcode plot
  title(mytitle, outer=TRUE)
  return(list(Diagdf=Diagdf))
}

PH_BYFRAME<-function(dataX,Diagdf,default.cut=NULL,percentile=1,percent.contour=NULL,full.data=dataX){

  if(is.null(default.cut)){
    jointVec<-sort( unique(c(Diagdf[,2],Diagdf[,3])), decreasing = FALSE)
    #jointVec<-sort( c(jointVec,jointVec+min(diff(jointVec))*0.001 ) )
    #1e-6 to over-jump the plotting issue
  }else{
    jointVec<-seq(from = min( range(c(Diagdf[,2],Diagdf[,3])) ),
                  to = max( range(c(Diagdf[,2],Diagdf[,3])) ),
                  by = default.cut)
  }
  for(fr in jointVec){
    fr<-as.numeric(as.character(fr))
    titleText<-paste("This is the 'Frame' at Euclidean distance =",signif(fr,digits=3))
    PH_RIPS(X=dataX,mytitle = titleText,
            threshold = fr, percentile=percentile,percent.contour = percent.contour,full.data=full.data)
  }
  
}

plotText<-function(text,new.canvas=T){
  if(new.canvas)par(mfrow=c(1,1))
  plot(0,0, xaxt='n', yaxt='n', ann=FALSE, main=text,col='white')
  text(0,0,text,col='black')
}

KDEpercentile<-function(X,percentile=1){
  if(percentile!=1){
    if(percentile>1 || percentile<0){stop('Percentile must be in the range of 0 and 1.')}
    if(dim(X)[2]!=2){
      stop('Kernel density estimator only designed for 2-dim data!')
    }else{
      library(ks)
      #KDE package
      H.scv <- Hscv(x=X)
      fhat <- kde(x=X, H=H.scv)
      percentileContour <- with(fhat,contourLines(x=eval.points[[1]],y=eval.points[[2]],
                                                  z=estimate,levels=cont[paste(percentile*100,"%",sep='')])[[1]])
      library(sp)
      inner <- point.in.polygon(point.x=X[,1], point.y=X[,2],
                                pol.x=percentileContour$x, pol.y=percentileContour$y)
      outer <- 1-inner
      X<-X[!!outer,]
      #plot(fhat)
      
      #library(MASS) MASS package
      #KDEst<-kde2d(x=dataX[,1],y=dataX[,2]);
      #persp3d(x=KDEst$x,y=KDEst$y,z=KDEst$z)
      
    }
  }else{
    percentileContour=NULL
  }
  return(list(percentile=percentile,percentileContour=percentileContour,selectedData=X))
}

