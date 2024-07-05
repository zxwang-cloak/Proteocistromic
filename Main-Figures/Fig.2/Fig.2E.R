library(scales)
library(ggplot2)
library(ggpubr)
library(foreach)

data <- read.table("./input_data/Fig2E-input.txt", sep = "\t", header = T)

my_comp=list(c("1promoter_like","3pro_enh_ctcf_avg"),
             c("1promoter_like","4other"),
             c("1promoter_like","2enhancer_like"),
             c("1promoter_like","5ctcf_like"),
             c("3pro_enh_ctcf_avg","4other"),
             c("3pro_enh_ctcf_avg","2enhancer_like"),
             c("3pro_enh_ctcf_avg","5ctcf_like"),
             c("4other","2enhancer_like"),
             c("4other","5ctcf_like"),
             c("2enhancer_like","5ctcf_like"))

pdf("Fig2E.pdf", width = 10, height = 10)
ggplot(data,aes(Group,PPI_number))+geom_boxplot(outlier.shape = NA,aes(colour=Group),size=1.5)+
  geom_jitter(size=2,width=0.15)+
  labs(x="",y="test")+
  guides(color=guide_legend(title="Group"))+
  theme(axis.text.y = element_text(size = 10),axis.title.y = element_text(size =19),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),panel.background=element_rect(fill=NA,colour = "black",size=1),
        plot.margin = unit(c(0,.25,0,.25), 'in'))+
  stat_compare_means(comparisons=my_comp,label.y.npc="bottom")+
  scale_y_continuous(breaks =c(0,100,200,300,400,500),labels =c(0,100,200,300,400,500)) + 
  theme_classic()
dev.off()

