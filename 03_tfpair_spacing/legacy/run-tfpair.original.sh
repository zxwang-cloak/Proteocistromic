FILE=$1

cat ${FILE} | while read line; do arr=($line); a=${arr[0]}; b=${arr[1]}; python /data/zxwang/ref/motif/spacing_pipeline-main/scripts/characterize_spacing.py ../for-TF-pair/ $a $b --motif_path /data/zxwang/ref/motif/JASPAR_human_motifs/; done 1>>characterize_spacing.log 2>>characterize_spacing.err


