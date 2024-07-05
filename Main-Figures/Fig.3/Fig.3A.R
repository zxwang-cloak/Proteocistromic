library(ComplexHeatmap)
library(circlize)
library(ggplot2)
library(ggthemes)

data <- read.table("./input_data/Fig3A-1-input.txt", sep = "\t", header = T)
pdf("Fig3A-1.pdf", height = 3, width = 6)
ggplot(data, aes(x = RANKnumber, y = ASBnumber)) +
  geom_point(shape = 19, color = "black", size = 1, alpha = 1) +
  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = FALSE, color = "darkred") +
  labs(y = "Number of ASB") +
  theme_few()
dev.off()

mat_gwas <- read.table(file = "./input_data/Fig3A-2-input.txt", sep = "\t", header = T, row.names = 1)
gwas = as.matrix(mat_gwas)

mat_tcga <- read.table(file = "./input_data/Fig3A-3-input.txt", sep = "\t", header = T, row.names = 1)
tcga = as.matrix(mat_tcga)

mat_gtex <- read.table(file = "./input_data/Fig3A-4-input.txt", sep = "\t", header = T, row.names = 1)
gtex = as.matrix(mat_gtex)

heatmap_col_fun_gwas = colorRamp2(c(0, 8), c("white", "#dc7c22"))  # GWAS
heatmap_col_fun_tcga = colorRamp2(c(0, 100), c("white", "#c61754")) # TCGA_eQTL
heatmap_col_fun_gtex = colorRamp2(c(0, 200), c("white", "#0f3fa8")) # GTEx_eQTL

pdf("Fig3A-2.pdf", height = 2, width = 10)
Heatmap(gwas, 
               col = heatmap_col_fun_gwas, 
               cluster_columns = F,
               cluster_rows = T,
               row_names_side = "left",
               show_column_names = FALSE,
               show_row_names = FALSE,
               column_names_centered = TRUE,
               column_names_gp = gpar(fontsize = 5),
               row_names_gp = gpar(fontsize = 5),
               name = "Number of ASB",
               border = 'black',                
)
dev.off()

pdf("Fig3A-3.pdf", height = 2, width = 10)
Heatmap(tcga,   
               col = heatmap_col_fun_tcga,
               cluster_columns = F,
               cluster_rows = T,
               row_names_side = "left",
               show_column_names = FALSE,
               show_row_names = FALSE,
               column_names_centered = TRUE,
               column_names_gp = gpar(fontsize = 5),
               row_names_gp = gpar(fontsize = 5),
               name = "Number of ASB",
               border = 'black',
)
dev.off()

pdf("Fig3A-4.pdf", height = 2, width = 10)
Heatmap(gtex,   
               col = heatmap_col_fun_gtex,
               cluster_columns = F,
               cluster_rows = T,
               row_names_side = "left",
               show_column_names = FALSE,
               show_row_names = FALSE,
               column_names_centered = TRUE,
               column_names_gp = gpar(fontsize = 5),
               row_names_gp = gpar(fontsize = 5),
               name = "Number of ASB",
               border = 'black',
)
dev.off()

