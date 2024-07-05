######################### left
library(ComplexHeatmap)

file<-read.table(file = "./input_data/Fig2B-left-input.txt",sep = "\t", header = T, row.names = 1)
new_file = as.matrix(file)
noNA<-na.omit(new_file)
rownames=rownames(noNA)
colnames=colnames(noNA)
d <- dist(noNA,method = "euclidean")
cluster2 <- hclust(d, method = "complete")

pdf("cluster.pdf", width = 12, height = 3)
plot(cluster2,hang = -1,cex=0.3,axes=F,ann=F)
dev.off()

pdf("Fig2B-left.pdf", width = 3, height = 10)
Heatmap(noNA, 
        cluster_columns = F,
        cluster_rows = T,
        row_order = rownames,
        column_order = colnames,
        row_names_side = "right",
        show_column_names = TRUE,
        show_row_names = TRUE,
        column_names_gp = gpar(fontsize = 9),
        column_names_rot = 30,
        row_names_gp = gpar(fontsize = 3.9),
        name = "Occupancy",
        border = 'black',
        col = c('white','red'),
        rect_gp = gpar(col = "white", lwd = 0.4),
)
dev.off()

######################### right
library(ggplot2)
library(reshape2)

file<-read.table("./input_data/Fig2B-right-input.txt",header = T, sep = "\t")
file2<-melt(file, id.vars = "Tag")
file2$Tag= factor(file2$Tag, levels = file$Tag)
file2$variable=factor(file2$variable, levels = c('open_chromatin_region', 'CTCF_binding_site', 'TF_binding_site','enhancer', 'promoter'))

pdf("Fig2B-right.pdf", width = 6, height = 10)
ggplot(file2, aes(x = value, y = Tag, fill = variable)) +
  geom_bar(stat = "identity") +
  guides(fill=guide_legend(reverse=TRUE)) +
  scale_fill_manual(name = "Regulation type", 
  values = c("blue", "#BA55D3", "#696969", "#FF7256", "#008B8B"), 
  breaks=c("open_chromatin_region", "CTCF_binding_site", "TF_binding_site","enhancer", "promoter"))+
  theme_classic() +
  theme(legend.position = 'right', 
         axis.text.y = element_text(size = 4)
  )
dev.off()

