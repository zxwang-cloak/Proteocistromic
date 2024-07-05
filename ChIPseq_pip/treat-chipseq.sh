mkdir -p ./chipseq_out/TREAT_ID/00datafilter
mkdir -p ./chipseq_out/TREAT_ID/01cleandata
mkdir -p ./chipseq_out/TREAT_ID/02alignment
mkdir -p ./chipseq_out/TREAT_ID/03bigwig
mkdir -p ./chipseq_out/TREAT_ID/04macs
mkdir -p ./chipseq_out/TREAT_ID/05motif

### qc-1
fastqc --threads 20 -f fastq -o ./chipseq_out/TREAT_ID/00datafilter/ ./Rawdata/TREAT_ID.fq.gz

trim_galore -q 20 -o ./chipseq_out/TREAT_ID/01cleandata/ --length 20 --gzip ./Rawdata/TREAT_ID.fq.gz

fastqc --threads 20 -f fastq -o ./chipseq_out/TREAT_ID/01cleandata/ ./chipseq_out/TREAT_ID/01cleandata/TREAT_ID_trimmed.fq.gz

### alignment
bowtie2 -p 20 -x ~/ZixianWang/ref/hg38/chipseq/hg38.fa -U ./chipseq_out/TREAT_ID/01cleandata/TREAT_ID_trimmed.fq.gz 2>./chipseq_out/TREAT_ID/02alignment/TREAT_ID.mapping.metrics.txt | samtools sort -@ 20 -o ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.sort.bam - 1>./chipseq_out/TREAT_ID/02alignment/TREAT_ID.bowtie2.log 2>./chipseq_out/TREAT_ID/02alignment/TREAT_ID.bowtie2.err

### qc-2
samtools index -@ 20 ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.sort.bam && samtools view -@ 20 -q 30 -F 3844 -bo ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.af.bam ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.sort.bam && samtools index -@ 20 ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.af.bam && samtools flagstat ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.af.bam > ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.af.metrics.txt

java -jar ~/software/picard.jar MarkDuplicates I=./chipseq_out/TREAT_ID/02alignment/TREAT_ID.af.bam O=./chipseq_out/TREAT_ID/02alignment/TREAT_ID.df.bam METRICS_FILE=./chipseq_out/TREAT_ID/02alignment/TREAT_ID.df.metrics.txt REMOVE_DUPLICATES=true

samtools index -@ 20 ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.df.bam && samtools flagstat ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.df.bam > ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.df.metrics.txt

bamCoverage --bam ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.df.bam -o ./chipseq_out/TREAT_ID/03bigwig/TREAT_ID.bw -bs 10 --normalizeUsing CPM --effectiveGenomeSize 2862010578 --extendReads 200

### peak calling
macs2 callpeak -t ./chipseq_out/TREAT_ID/02alignment/TREAT_ID.df.bam -c ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.df.bam -f BAM --gsize hs -n TREAT_ID -p 0.001 -B --outdir ./chipseq_out/TREAT_ID/04macs

macs2 bdgcmp -t ./chipseq_out/TREAT_ID/04macs/TREAT_ID_treat_pileup.bdg -c ./chipseq_out/TREAT_ID/04macs/TREAT_ID_control_lambda.bdg -o ./chipseq_out/TREAT_ID/04macs/TREAT_ID_FE.bdg -m FE && macs2 bdgcmp -t ./chipseq_out/TREAT_ID/04macs/TREAT_ID_treat_pileup.bdg -c ./chipseq_out/TREAT_ID/04macs/TREAT_ID_control_lambda.bdg -o ./chipseq_out/TREAT_ID/04macs/TREAT_ID_logLR.bdg -m logLR -p 0.00001 && bdg2bw ./chipseq_out/TREAT_ID/04macs/TREAT_ID_FE.bdg ~/ZixianWang/ref/hg38/chipseq/hg38.len && bdg2bw ./chipseq_out/TREAT_ID/04macs/TREAT_ID_logLR.bdg ~/ZixianWang/ref/hg38/chipseq/hg38.len

annotatePeaks.pl ./chipseq_out/TREAT_ID/04macs/TREAT_ID_peaks.narrowPeak hg38 > ./chipseq_out/TREAT_ID/04macs/TREAT_ID_peaks.narrowPeak.annotations.txt

### motif analysis using MEME
awk 'BEGIN {WIDTH=100} {if($2<=WIDTH) print $1 "\t1\t" $2+WIDTH "\t" $4 "\t" $5; else print $1 "\t" $2-WIDTH "\t" $2+WIDTH "\t" $4 "\t" $5}' ./chipseq_out/TREAT_ID/04macs/TREAT_ID_summits.bed > ./chipseq_out/TREAT_ID/04macs/TREAT_ID_summits_extended_peaks.bed

bedtools subtract -a ./chipseq_out/TREAT_ID/04macs/TREAT_ID_summits_extended_peaks.bed -b ~/ZixianWang/ref/hg38/chipseq/blacklist.bed -f 0.25 -A > ./chipseq_out/TREAT_ID/04macs/TREAT_ID_extended_bk_removal_peaks.bed

sort -r -k5 -n ./chipseq_out/TREAT_ID/04macs/TREAT_ID_extended_bk_removal_peaks.bed | head -n 500 > ./chipseq_out/TREAT_ID/04macs/TREAT_ID_top_peaks.bed

bedtools getfasta -bed ./chipseq_out/TREAT_ID/04macs/TREAT_ID_top_peaks.bed -fi ~/ZixianWang/ref/hg38/chipseq/hg38.fa > ./chipseq_out/TREAT_ID/05motif/TREAT_ID_top_peaks.fa

meme-chip -meme-nmotifs 5 -oc ./chipseq_out/TREAT_ID/05motif/TREAT_ID -ccut 200 -dna -meme-minw 6 -meme-maxw 30 -db ~/ZixianWang/ref/motif_databases/HUMAN/HOCOMOCOv11_full_HUMAN_mono_meme_format.meme -db ~/ZixianWang/ref/motif_databases/JASPAR/JASPAR2022_CORE_vertebrates_non-redundant_v2.meme -db ~/ZixianWang/ref/motif_databases/EUKARYOTE/jolma2013.meme ./chipseq_out/TREAT_ID/05motif/TREAT_ID_top_peaks.fa

### motif analysis using HOMER
findMotifsGenome.pl ./chipseq_out/TREAT_ID/04macs/TREAT_ID\_peaks.narrowPeak hg38 ./chipseq_out/TREAT_ID/04macs/TREAT_ID_homer-motif -len 8,10,12

### FIMO
meme2meme -numbers ./chipseq_out/TREAT_ID/05motif/TREAT_ID/meme_out/meme.txt > ./chipseq_out/TREAT_ID/05motif/TREAT_ID/PWM.meme

sed -i "s/ MEME/_MEME/g" ./chipseq_out/TREAT_ID/05motif/TREAT_ID/PWM.meme

fimo --text ./chipseq_out/TREAT_ID/05motif/TREAT_ID/PWM.meme ./chipseq_out/TREAT_ID/05motif/TREAT_ID_top_peaks.fa > ./chipseq_out/TREAT_ID/05motif/TREAT_ID/TREAT_ID-fimo.txt


