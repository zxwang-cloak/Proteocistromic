cut -f 1 /data/zxwang/Project/omics/293T-chipseq/FOR_PUBLICATION/cluster.info | sed '1d' | while read line; do ln -s ../../ExactName_peak_bed/$line\.bed; done
sh run_overlap_analysis.sh
awk '$4 >= 10 {print $0}' overlaps_with_sources.bed > 10TF-overlaps_with_sources.bed
sh process_regions.sh
##
cut -f 1-3 overlaps_with_sources.bed | bedtools merge -i - > merged_overlaps_with_sources.bed
