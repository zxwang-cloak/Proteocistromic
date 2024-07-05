mkdir -p ./chipseq_out/INPUT_ID/00datafilter
mkdir -p ./chipseq_out/INPUT_ID/01cleandata
mkdir -p ./chipseq_out/INPUT_ID/02alignment
mkdir -p ./chipseq_out/INPUT_ID/03bigwig

### qc-1
fastqc --threads 20 -f fastq -o ./chipseq_out/INPUT_ID/00datafilter/ ./Rawdata/INPUT_ID.fq.gz

trim_galore -q 20 -o ./chipseq_out/INPUT_ID/01cleandata/ --length 20 --gzip ./Rawdata/INPUT_ID.fq.gz

fastqc --threads 20 -f fastq -o ./chipseq_out/INPUT_ID/01cleandata/ ./chipseq_out/INPUT_ID/01cleandata/INPUT_ID_trimmed.fq.gz

### alignment
bowtie2 -p 20 -x /home/u41546/ZixianWang/ref/hg38/chipseq/hg38.fa -U ./chipseq_out/INPUT_ID/01cleandata/INPUT_ID_trimmed.fq.gz 2>./chipseq_out/INPUT_ID/02alignment/INPUT_ID.mapping.metrics.txt | samtools sort -@ 20 -o ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.sort.bam - 1>./chipseq_out/INPUT_ID/02alignment/INPUT_ID.bowtie2.log 2>./chipseq_out/INPUT_ID/02alignment/INPUT_ID.bowtie2.err

### qc-2
samtools index -@ 20 ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.sort.bam && samtools view -@ 20 -q 30 -F 3844 -bo ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.af.bam ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.sort.bam && samtools index -@ 20 ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.af.bam && samtools flagstat ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.af.bam > ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.af.metrics.txt

java -jar ~/software/picard.jar MarkDuplicates I=./chipseq_out/INPUT_ID/02alignment/INPUT_ID.af.bam O=./chipseq_out/INPUT_ID/02alignment/INPUT_ID.df.bam METRICS_FILE=./chipseq_out/INPUT_ID/02alignment/INPUT_ID.df.metrics.txt REMOVE_DUPLICATES=true

samtools index -@ 20 ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.df.bam && samtools flagstat ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.df.bam > ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.df.metrics.txt

bamCoverage --bam ./chipseq_out/INPUT_ID/02alignment/INPUT_ID.df.bam -o ./chipseq_out/INPUT_ID/03bigwig/INPUT_ID.bw -bs 10 --normalizeUsing CPM --effectiveGenomeSize 2862010578 --extendReads 200

