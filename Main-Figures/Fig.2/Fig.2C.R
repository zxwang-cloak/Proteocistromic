library(scales)
library(ggplot2)
library(ggpubr)
library(foreach)

data <- read.table("./input_data/Fig2C-input.txt", sep = "\t", header = T)

my_comp=list(c("cluster_a","cluster_b"),
             c("cluster_a","cluster_c"),
             c("cluster_b","cluster_c")
)

pdf("Fig2C.pdf", width = 5, height = 5)
ggplot(data,aes(Group,PEAK_number))+geom_boxplot(outlier.shape = NA,aes(colour=Group),size=1.5)+
  geom_jitter(size=2,width=0.15)+
  labs(x="",y="peak number")+
  guides(color=guide_legend(title="Group"))+
  theme(axis.text.y = element_text(size = 10),axis.title.y = element_text(size =19),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),panel.background=element_rect(fill=NA,colour = "black",size=1),
        plot.margin = unit(c(0,.25,0,.25), 'in'))+
  stat_compare_means(comparisons=my_comp,label.y.npc="bottom")+
#  scale_y_continuous(breaks =c(0,100,200,300,400,500),labels =c(0,100,200,300,400,500)) + 
  theme_classic()
dev.off()


