source('FRAME.ANALYSIS.R')

Nsample <- 12
set.seed(1125)

pdf(paste0('Example(Normal)_N_',Nsample,'.pdf'),height = 6, width = 8)
#Let us simulate a sample from a source that is known to us.

library("mvtnorm")

#Full 2-dim Embedding(x,y)~N_2(0,I_2)
plotText('Result and Frame-by-frame plots for Example 1')
X1 <- rmvnorm(n=Nsample,mean=c(0,0))
result1 <- PH_RIPS(X1,mytitle = "Ex1. Full 2-dim Embedding(x,y)~N_2(0,I_2)")
PH_BYFRAME(X1,result1$Diagdf)

#Trivial Embedding   (x,0), x~N_1(0,1)
plotText('Result and Frame-by-frame plots for Example 2')
X2 <- cbind(rnorm(Nsample,mean=0,sd=1),0)
result2 <- PH_RIPS(X2,mytitle = "Ex2. Trivial Embedding   (x,0), x~N_1(0,1)")
PH_BYFRAME(X2,result2$Diagdf)

#Quadratic Embedding (x,x^2), x~N_1(0,1)
plotText('Result and Frame-by-frame plots for Example 3')
X3 <- cbind(X2[,1],X2[,1]^2)
result3 <- PH_RIPS(X3,mytitle = "Ex3. Quadratic Embedding (x,x^2), x~N_1(0,1)")
PH_BYFRAME(X3,result3$Diagdf)

dev.off()

pdf(paste0('Example(T)_N_',Nsample,'.pdf'),height = 6, width = 8)
#Let us simulate a sample from a source that is known to us.

library("mnormt")

#Full 2-dim Embedding(x,y)~t_2(0,I_2,df=2)
plotText('Result and Frame-by-frame plots for Example 4')
X4 <- rmt(n=Nsample, mean=c(0,0), S=diag(2), df=2, sqrt=NULL)
result4 <- PH_RIPS(X4,mytitle = "Ex4. Full 2-dim Embedding(x,y)~t_2(0,I_2,df=2)")
PH_BYFRAME(X4,result4$Diagdf)

#Trivial Embedding   (x,0), x~t(0,df=2)
plotText('Result and Frame-by-frame plots for Example 5')
X5 <- cbind(rt(n=Nsample,ncp=0,df=2),0)
result5 <- PH_RIPS(X5,mytitle = "Ex5. Trivial Embedding   (x,0), x~t(0,df=2)")
PH_BYFRAME(X5,result5$Diagdf)

#Quadratic Embedding (x,x^2), x~t(0,df=2)
plotText('Result and Frame-by-frame plots for Example 6')
X6 <- cbind(X5[,1],X5[,1]^2)
result6 <- PH_RIPS(X6,mytitle = "Ex6. Quadratic Embedding (x,x^2), x~t(0,df=2)")
PH_BYFRAME(X6,result6$Diagdf)

dev.off()

pdf('Example_grid.pdf',height = 6, width = 8)
#Let us simulate a sample from a source that is known to us.


#Full 2-dim Grid Example
plotText('Result and Frame-by-frame plots for Example 7')
X7 <- expand.grid(seq(-2,2,length.out = 4),seq(-2,2,length.out = 4))
result7 <- PH_RIPS(X7,mytitle = "Ex7. Full 2-dim Grid with space 1")
PH_BYFRAME(X7,result7$Diagdf)

#Perturbed 2-dim Grid Example
plotText('Result and Frame-by-frame plots for Example 8')
X8 <- X7
for(i in 1:dim(X8)[1]){
  for(j in 1:dim(X8)[2]){
    X8[i,j]<-X8[i,j]+rnorm(1,mean=0,sd=.1)
  }
}
result8 <- PH_RIPS(X8,mytitle = "Ex8. Perturbed 2-dim Grid with space 1 and N(0,.01) noise")
PH_BYFRAME(X8,result8$Diagdf)

#Perturbed 2-dim Grid Example
plotText('Result and Frame-by-frame plots for Example 9')
X9 <- X7
for(i in 1:dim(X9)[1]){
  for(j in 1:dim(X9)[2]){
    X9[i,j]<-X9[i,j]+rnorm(1,mean=0,sd=1)
  }
}
result9 <- PH_RIPS(X9,mytitle = "Ex9. Perturbed 2-dim Grid with space 1 and N(0,1) noise")
PH_BYFRAME(X9,result9$Diagdf)

dev.off()