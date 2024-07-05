library(umap)
library(ggplot2)
library(data.table)
library(ggrepel)
library(egg)

set.seed(123)

######## left
data <- fread("./input_data/Fig4L-left-input.txt")
data_for_umap <- data[, -c(1, 2, 3), with = FALSE]
umap_result <- umap(as.matrix(data_for_umap), n_neighbors = 30, min_dist = 0.3)
data$UMAP1 <- umap_result$layout[, 1]
data$UMAP2 <- umap_result$layout[, 2]
color_map <- RColorBrewer::brewer.pal(n = 8, name = "Dark2")
extended_color_map <- colorRampPalette(color_map)(10)

pdf("Fig4L-left.pdf", width = 6, height = 4.2)
ggplot(data, aes(x = UMAP1, y = UMAP2, color = Type)) +
  geom_point(shape = 16, alpha = 0.5, size = 0.5) +
  scale_color_manual(values = extended_color_map) +
  theme_article() +
  labs(title = "Proteocistromic TFs involved in Com-Cancer interaction", x = "UMAP1", y = "UMAP2") +
  coord_cartesian(xlim = c(-15, 15), ylim = c(-15, 15))
dev.off()


######## right
data <- fread("./input_data/Fig4L-right-input.txt")
data_for_umap <- data[, -c(1, 2, 3), with = FALSE] 
umap_result <- umap(as.matrix(data_for_umap), n_neighbors = 30, min_dist = 0.3) 
data$UMAP1 <- umap_result$layout[, 1]
data$UMAP2 <- umap_result$layout[, 2]
color_map <- RColorBrewer::brewer.pal(n = 8, name = "Dark2")
extended_color_map <- colorRampPalette(color_map)(10)

pdf("Fig4L-right.pdf", width = 6, height = 4.2)
ggplot(data, aes(x = UMAP1, y = UMAP2, color = Type)) +
  geom_point(shape = 16, alpha = 0.5, size = 0.5) +
  scale_color_manual(values = extended_color_map) +
  theme_article() +
  labs(title = "Proteocistromic TFs not involved in Com-Cancer interaction", x = "UMAP1", y = "UMAP2") +
  coord_cartesian(xlim = c(-15, 15), ylim = c(-15, 15))
dev.off()


