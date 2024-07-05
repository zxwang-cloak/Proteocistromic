## generate the circos picture
circos -conf Fig4A-left.circos.conf

## TF-pair analysis (Spacing analysis) and Fig.4B/C were performed and generated using Spacing pipeline (PMID: 35049498)
## Spacing pipeline: https://github.com/zeyang-shen/spacing_pipeline


## survival plot
cd ./input_data && unzip TF-pairs-TCGA.zip; cd ../
cd ./input_data; ls *.tpm | sed 's/.tpm//g' | while read line; do perl ../generate_+-.pl $line\.tpm > $line\-status.info; done

cut -f 1 TCGA_abbreviation.list | while read line; do perl ../generate-KM-file.pl TCGA-$line\-FOXJ2_KLF4-status.info $line\-KM_Plot__Overall_months.txt FOXJ2 KLF4 > $line\-FOXJ2_KLF4-Overall_months.forplot; done
cut -f 1 TCGA_abbreviation.list | while read line; do sed -e "s/TYPE/$line/g" -e "s/TF1/FOXJ2/g" -e "s/TF2/KLF4/g" -e "s/CLINICAL/Overall_months/g" ../KM-plot.R | Rscript -; done

cut -f 1 TCGA_abbreviation.list | while read line; do perl ../generate-KM-file.pl TCGA-$line\-MAX_KLF5-status.info $line\-KM_Plot__Overall_months.txt MAX KLF5 > $line\-MAX_KLF5-Overall_months.forplot; done
cut -f 1 TCGA_abbreviation.list | while read line; do sed -e "s/TYPE/$line/g" -e "s/TF1/MAX/g" -e "s/TF2/KLF5/g" -e "s/CLINICAL/Overall_months/g" ../KM-plot.R | Rscript -; done


