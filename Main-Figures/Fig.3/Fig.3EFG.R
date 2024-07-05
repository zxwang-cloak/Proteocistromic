library(CMplot)
library(tidyverse)

rs655530 <- c("rs655530")
rs117990130 <- c("rs117990130")
Highlight_SNPs <- c("rs655530", "rs117990130")

SNPs_ID <- Highlight_SNPs

data<-read.table("./input_data/Fig3E-input.txt", header = T, sep = "\t")
pdf("Fig3E.pdf", height = 3, width = 5)
CMplot(data,plot.type="m",
       col = c("grey"),
       highlight = Highlight_SNPs,
       highlight.cex = 1,
       highlight.col = "red",
#      highlight.text = SNPs_ID,
#      highlight.text.col = "black",
       LOG10=FALSE,threshold=NULL,
       pch = 19, cex = 0.5,
       chr.den.col=NULL,file.output=FALSE,verbose=TRUE)
dev.off()

TCGA<-read.table("./input_data/Fig3F-input.txt", header = T, sep = "\t")
pdf("Fig3F.pdf", height = 3, width = 5)
CMplot(TCGA,plot.type="m",
       col = c("firebrick"),
       highlight = rs655530,
       highlight.cex = 1,
       highlight.col = "firebrick",
#      highlight.text = SNPs_ID,
#      highlight.text.col = "black",
       LOG10=FALSE,threshold=NULL,
       pch = 19, cex = 0.5,
       chr.den.col=NULL,file.output=FALSE,verbose=TRUE)
dev.off()

GTEx<-read.table("./input_data/Fig3G-input.txt", header = T, sep = "\t")
pdf("Fig3G.pdf", height = 3, width = 5)
CMplot(GTEx,plot.type="m",
       col = c("navy"),
       highlight = rs117990130,
       highlight.cex = 1,
       highlight.col = "navy",
#      highlight.text = SNPs_ID,
#      highlight.text.col = "black",
       LOG10=FALSE,threshold=NULL,
       pch = 19, cex = 0.5,
       chr.den.col=NULL,file.output=FALSE,verbose=TRUE)
dev.off()


