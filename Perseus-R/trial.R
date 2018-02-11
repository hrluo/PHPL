pdf(paste0('ExampleFractal.pdf'),height = 6, width = 8)
for(i in 1:24){
  source('rIFS.R')
  source('Rperseus.R')
  message(i)
}
dev.off()