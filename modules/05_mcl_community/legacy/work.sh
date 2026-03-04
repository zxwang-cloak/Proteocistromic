mcl bait-prey.with-PSM.tsv --abc -I 2.0

perl add-community-colmun.pl out.bait-prey.with-PSM.tsv.I20 | awk '{print "community"$0}' > clomn-community-info.txt
### vim clomn-community-info.txt && delete the clusters containing fewer than three proteins
# vim clomn-community-info.txt

### Fisher's exact test
perl community-connection.pl clomn-community-info.txt bait-prey.with-PSM.tsv > noself-community-info.txt

cut -f 1 noself-community-info.txt | cat <(cut -f 2 noself-community-info.txt) - | sort -u | perl generate-grep.pl - > generate-grep.sh

rm Community-count.txt
sh generate-grep.sh

cut -f 1 noself-community-info.txt | cat <(cut -f 2 noself-community-info.txt) - | sort -u | paste -d "\t" - Community-count.txt | sort -k 2,2nr > sorted-community-count.txt

perl community-connection.pl clomn-community-info.txt bait-prey.with-PSM.tsv | perl /data/zxwang/Project/omics/293T-chipseq/Pfam/statistic-domain-pair-count.pl - | sed 's/ + /\t/g' | sort -k 3,3nr > sorted-community-pair-count.txt

perl generate-Fisher-exact-test.pl sorted-community-count.txt sorted-community-pair-count.txt > pre-community-Fisher-exact.results.txt

sed '1d' pre-community-Fisher-exact.results.txt | cat -n | awk '{print "RANK"$1"\t"$2" + "$3"\t"$4"\t"$5"\t"$6"\t"$7}' - | cut -f 1,3- > for-community-Fisher-exact-test.txt
# vim for-community-Fisher-exact-test.txt title

sed '1d' pre-community-Fisher-exact.results.txt | cat -n | awk '{print "RANK"$1"\t"$2" + "$3"\t"$4"\t"$5"\t"$6"\t"$7}' - | cut -f 1,2 > RANK-index.txt
# vim RANK-index.txt title

Rscript batch-Fisher-exact-test.R

paste -d "\t" Fisher-exact-test-result.txt Fisher-exact-test-padjust.txt | paste -d "\t" RANK-index.txt - > final-community-intersection.txt

#
cd focus


# Figure 6a
perl add-community-info.pl clomn-community-info.txt bait-prey.with-PSM.tsv | sort -u | awk '$2 == $4 {print $0}' | awk '$1 != $3 {print $0}' > bait-prey-community-info.tsv
grep -w -f focused-community.list bait-prey-community-info.tsv | perl add-cluster-info.pl /data/zxwang/Project/omics/293T-chipseq/FOR_PUBLICATION/TF-cluster/PPI-ChIP-seq/community/v3-cluster-annotation-community.txt - | sort -k 3,3 > bait-prey-focused-community-TF-cluster-info.tsv
grep -w -f focused-community.list sig-community-cancer-interaction.info > focused-com-cancer-info.tsv

