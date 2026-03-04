#setwd("/data/zxwang/Project/omics/293T-chipseq/mcl-community")

library(knitr)

df = read.table('for-community-Fisher-exact-test.txt', header = TRUE)
out <- data.frame()
for (i in 1:nrow(df)){
  t <- fisher.test(matrix(as.vector(t(df[i, 2:5])), ncol=2))
  d <- df[i, ]
  d$p.value <- t$p.value
  d$OR <- t$estimate[[1]]
  d$OR.lower95 <- t$conf.int[1]
  d$OR.upper95 <- t$conf.int[2]
  out <- rbind(out, d)
}

fdr.out<-p.adjust(out$p.value, method = "fdr")

#kable(out)
write.table(out, "Fisher-exact-test-result.txt", sep = "\t", quote = F)
write.table(fdr.out, "Fisher-exact-test-padjust.txt", sep = "\t", quote = F)



