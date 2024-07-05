library(ComplexHeatmap)
library(circlize)

dat <- read.table("./input_data/Fig3A-proteocistromic-merged-score-input.txt", header = T, row.names = 1, sep = "\t")
mat = as.matrix(dat)

anno <- read.table("./input_data/Fig3A-TF-pair-annotation-input.txt", header = T, row.names = 1, sep = "\t")
ha <- HeatmapAnnotation(
  cluster = anno$cluster,
  tfpair = anno$TFPAIR,
  relaxed = anno$relaxed,
  constrained = anno$constrained,
  col = list(
    cluster = c("1" = "red", "2" = "blue", "3" = "green"),
    tfpair = c("tfpair" = "black", "no" = "#DCDCDC"),
    relaxed = c("yes" = "blue", "no" = "white"),
    constrained = c("yes" = "orange", "no" = "white")
  )
)

heatmap_col_fun = colorRamp2(c(-5, 0, 5), c("blue","black","#FF0000"))
pdf("Fig3A-right.pdf", height = 2, width = 12)
Heatmap(mat, 
        col = heatmap_col_fun, 
        top_annotation = ha,
        cluster_columns = FALSE,
        cluster_rows = FALSE,
        row_names_side = "left",
        show_column_names = TRUE,
        show_row_names = TRUE,
        column_names_centered = TRUE,
        column_names_gp = gpar(fontsize = 4),
        row_names_gp = gpar(fontsize = 10),
        name = "Abundance",
)
dev.off()
  
