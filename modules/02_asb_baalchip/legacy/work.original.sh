mkdir script log BaalChIP_input BaalChIP_output
rm ./simul_output/*
##################################### prepare samplesheet
cut -f 2 ../sample_group.txt | while read line; do sed "s/treat/$line/g" samplesheet.tsv > ./BaalChIP_input/$line\-samplesheet.tsv; done

##################################### run BaalChIP
cat ../sample_group.txt | sed -n '11,100p' | while read line; do arr=(${line}); input=${arr[0]}; treat=${arr[1]}; sed -e "s/treat/$treat/g" -e "s/input/$input/g" BaalChIP.sh > $treat-BaalChIP.sh; sbatch $treat-BaalChIP.sh; done

cat ../sample_group.txt | sed -n '101,206p' | while read line; do arr=(${line}); input=${arr[0]}; treat=${arr[1]}; sed -e "s/treat/$treat/g" -e "s/input/$input/g" BaalChIP.sh > $treat-BaalChIP.sh; sbatch $treat-BaalChIP.sh; done


mv *-BaalChIP.sh script


