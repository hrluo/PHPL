options_args<-read.table('Rargs.data')
bin_scale=as.numeric(as.character(options_args[1,1]))
simulation_signature=as.character(options_args[2,1])
library(imager)
image1 <- load.image(paste('R_Plot_',simulation_signature,'.png',sep=''))
image2 <- load.image(paste('PH_Plot_',simulation_signature,'.png',sep=''))
destfile=paste('PRF_Plot_0_',simulation_signature,'.png',sep='')
if(file.exists(destfile)){
  image3 <- load.image(paste('PRF_Plot_0_',simulation_signature,'.png',sep=''))
  image4 <- load.image(paste('PRF_Plot_1_',simulation_signature,'.png',sep=''))
}
png(paste("Summary_Plot_",simulation_signature,".png",sep=''),width = 1920,height =1080 )
par(bg='white')
par(mar=c(.2,.2,.2,.2))
if(file.exists(destfile)){
  layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
  plot(image1, axes = FALSE)
  plot(image2, axes = FALSE)
  #plot_mat<-as.matrix(read.csv(paste("PRF_CSV_",simulation_signature,".csv",sep='')))
  plot(image3, axes = FALSE)
  plot(image4, axes = FALSE)
}else{
  layout(matrix(c(1,2), 1, 2 , byrow = TRUE))
  plot(image1, axes = FALSE)
  plot(image2, axes = FALSE)
}
dev.off()


