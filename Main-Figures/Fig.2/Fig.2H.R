library(ComplexHeatmap)
library(circlize)

dat <- read.table("./input_data/Fig2H-input.txt", header = T, row.names = 1, sep = "\t")
mat = as.matrix(dat)

anno <- read.table("./input_data/Fig2H-anno.txt", header = T, row.names = 1, sep = "\t")
ha <- HeatmapAnnotation(
  cluster = anno$cluster,
  ED = anno$ED,
  DBD = anno$DBD,
  col = list( 
    cluster = c("a" = "red", "b" = "blue", "c" = "green") , 
    ED = c("A" = "#F7D58B", "R" = "#797BB7", "AR" = "#B595BF" , "other" = "#D0D2D4"),
    DBD = c("C2H2_ZF" = "#E1C855", "Ets" = "#E07B54", "Homeodomain" = "#51B1B7", "other" = "#D0D2D4")
  )
)

heatmap_col_fun = colorRamp2(c(-2, 0, 2), c("blue","black","#FF0000"))
pdf("Fig2H.pdf", height = 4, width = 12)
Heatmap(mat, 
        col = heatmap_col_fun, 
        top_annotation = ha,
        cluster_columns = FALSE,
        cluster_rows = FALSE,
        #row_order = rownames,
        #column_order = colnames,
        row_names_side = "left",
        show_column_names = TRUE,
        show_row_names = TRUE,
        column_names_centered = TRUE,
        column_names_gp = gpar(fontsize = 4),
        row_names_gp = gpar(fontsize = 10),
        name = "Abundance",
)
dev.off()
  
