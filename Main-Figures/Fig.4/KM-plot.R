library(survival)
library(survminer)

file<-read.table("TYPE-TF1_TF2-CLINICAL.forplot",sep="\t",header = T,row.names = 1)
fit <- survfit(Surv(DFS_MONTHS, DFS_STATUS) ~ TF1_TF2_group, data = file)

plot<-ggsurvplot(
  fit,
  data = file,
  size = 1,
  title = "TCGA-TYPE-TF1_TF2",
  xlab = "Time (months)",
  ylab = "CLINICAL",
  conf.int = FALSE, 
  pval = TRUE,
  pval.method = TRUE,
  log.rank.weights = "1",
  risk.table = TRUE,
  risk.table.col = "strata",
  risk.table.height = 0.25,
  ggtheme = theme_survminer()
)

surv_diff_res <- survdiff(Surv(DFS_MONTHS, DFS_STATUS) ~ TF1_TF2_group, data = file)
pval <- 1 - pchisq(surv_diff_res$chisq, length(surv_diff_res$n) - 1)

write.table(pval, "TCGA-TYPE-TF1_TF2-CLINICAL.pvalue.txt", sep = "\t", quote = F)

pdf(file = "TCGA-TYPE-TF1_TF2-CLINICAL.pdf", height = 6, width = 6, onefile = FALSE)
plot
dev.off()


