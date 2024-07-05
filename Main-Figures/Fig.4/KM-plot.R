#setwd("/data/zxwang/Project/omics/293T-chipseq/TF-pairs/batch-KM-TCGA")

library(survival)
library(survminer)

file<-read.table("TYPE-TF1_TF2-CLINICAL.forplot",sep="\t",header = T,row.names = 1)
fit <- survfit(Surv(DFS_MONTHS, DFS_STATUS) ~ TF1_TF2_group, data = file)

plot<-ggsurvplot(
  fit,
  data = file,
  size = 1,                 # 更改线条粗细
  title = "TCGA-TYPE-TF1_TF2",
  xlab = "Time (months)",
  ylab = "CLINICAL",
  # 配色方案，支持ggsci配色，自定义颜色，brewer palettes中的配色，等
#  palette = "lancet",
  conf.int = FALSE,          # 可信区间
  pval = TRUE,              # log-rank P值，也可以提供一个数值
  pval.method = TRUE,       # 计算P值的方法，可参考https://rpkgs.datanovia.com/survminer/articles/Specifiying_weights_in_log-rank_comparisons.html
  log.rank.weights = "1",
  risk.table = TRUE,        # 增加risk table
  risk.table.col = "strata",# risk table根据分组使用不同颜色
  risk.table.height = 0.25, # risk table高度
  ggtheme = theme_survminer()      # 主题，支持ggplot2及其扩展包的主题
)

# 计算生存曲线的 p 值
surv_diff_res <- survdiff(Surv(DFS_MONTHS, DFS_STATUS) ~ TF1_TF2_group, data = file)
pval <- 1 - pchisq(surv_diff_res$chisq, length(surv_diff_res$n) - 1)

# 打印 p 值
write.table(pval, "TCGA-TYPE-TF1_TF2-CLINICAL.pvalue.txt", sep = "\t", quote = F)

# 绘制生存曲线图
pdf(file = "TCGA-TYPE-TF1_TF2-CLINICAL.pdf", height = 6, width = 6, onefile = FALSE)
plot
dev.off()


