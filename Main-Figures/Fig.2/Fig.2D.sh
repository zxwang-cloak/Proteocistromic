# sortBed -i 10FoldPeak-merged-P1.bed | bedtools genomecov -i - -g ~/ref/hg38/chrom_hg38.sizes -bg > P1.bedGraph
# bedGraphToBigWig P1.bedGraph ~/ref/hg38/chrom_hg38.sizes P1-10FoldPeak.bw

# sortBed -i 10FoldPeak-merged-P2.bed | bedtools genomecov -i - -g ~/ref/hg38/chrom_hg38.sizes -bg > P2.bedGraph
# bedGraphToBigWig P2.bedGraph ~/ref/hg38/chrom_hg38.sizes P2-10FoldPeak.bw

# sortBed -i 10FoldPeak-merged-P3.bed | bedtools genomecov -i - -g ~/ref/hg38/chrom_hg38.sizes -bg > P3.bedGraph
# bedGraphToBigWig P3.bedGraph ~/ref/hg38/chrom_hg38.sizes P3-10FoldPeak.bw

computeMatrix reference-point -p 10 \
              --binSize 50 \
              --referencePoint TSS \
              -a 3000 -b 3000 \
              -R ./input_data/ucsc.hg38.TSS.bed \
              -S ./input_data/P1-10FoldPeak.bw ./input_data/P2-10FoldPeak.bw ./input_data/P3-10FoldPeak.bw \
              --skipZeros \
              -o 10FoldPeak-combine-refPoint-data.gz

plotProfile -m 10FoldPeak-combine-refPoint-data.gz --perGroup --colors red green blue --plotHeight 10.5 --plotWidth 10 --plotTitle "10-fold peaks" -o Fig2D.pdf

