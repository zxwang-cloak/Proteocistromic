library(ComplexHeatmap)

file<-read.table(file = "./input_data/Fig2A-input.txt",sep = "\t", header = T, row.names = 1)
new_file = as.matrix(file)
noNA<-na.omit(new_file)
rownames=rownames(noNA)
colnames=colnames(noNA)

log2noNA <- log2(noNA+1)

annotation <- read.table(file="./input_data/Fig2A-anno.txt", sep = "\t", header = T, row.names = 1)
tf <- as.character(annotation$TYPE)
ha = rowAnnotation(tf = tf, 
                   border = TRUE,
                   col = list(tf = c("A" = "#b42d2d", "R" = "#1a1a62", "AR" = "#c6a870", "other" = "#ded8d8")))

pdf("Fig2A.pdf.pdf", width = 3.5, height = 8)
Heatmap(log2noNA, 
        clustering_method_columns = "complete",
        cluster_columns = T,
        cluster_rows = T,
        row_order = rownames,
        column_order = colnames,
        row_names_side = "right",
        show_column_names = TRUE,
        show_row_names = FALSE,
        row_km = 3,
        column_names_gp = gpar(fontsize = 9),
        column_names_rot = 30,
        row_names_gp = gpar(fontsize = 3.9),
        name = "log2(PPI number)",
        border = 'black',
        col = c('blue','orange','red'),
        right_annotation = ha
)
dev.off()
        
