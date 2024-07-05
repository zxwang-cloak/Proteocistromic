library(cluster)
library(GGally)
library(dplyr)
library(ggplot2)
library(ggthemes)

data <- read.table("./input_data/Fig2G-input.txt", header = TRUE, sep = "\t")

cols_to_cluster <- c("TED", "X10_fold_peak", "promoter", "enhancer", "CTCF_binding_site")
data_for_clustering <- data[, cols_to_cluster]
data_for_clustering <- log10(data_for_clustering+1) 

silhouette_scores <- sapply(2:10, function(k) {
  km <- kmeans(data_for_clustering, centers = k)
  silhouette_score <- mean(silhouette(km$cluster, dist(data_for_clustering))[, 3])
  return(silhouette_score)
})

best_k <- which.max(silhouette_scores) + 2
final_km <- kmeans(data_for_clustering, centers = best_k)
data_for_clustering$cluster <- as.factor(final_km$cluster)
write.table(data_for_clustering, file = "Fig2G-cluster.txt", quote = F, sep = "\t", row.names = FALSE)

pdf("V3-cluster.pdf", height = 5, width = 6)
ggparcoord(data_for_clustering, columns = 1:5, groupColumn = 6, 
           scale = "globalminmax", showPoints = TRUE, 
           title = "Parallel Coordinates Plot for Clustering") +
  scale_color_brewer(palette = "Set1") +
  theme_few() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
  geom_line(aes(color=cluster), linewidth=1, alpha=0.3) +
  geom_point(aes(color=cluster), size=2, alpha=0.3)
dev.off()

