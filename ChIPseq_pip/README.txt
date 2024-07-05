# Before running treat-chipseq.sh, ensure that each input file has been processed, i.e., input-chipseq.sh has already been executed.
# We recommend creating a sample_group.txt file first, with the following format, separated by tabs：
# 
#  sample_group.txt：
#  Input-1  ELF1
#  Input-2  BHLHA15
#  Input-3  E2F1
#  ...  ...

# Step1. Analyze the input file. If you are in a cluster system, you can do it like this：
cut -f 1 sample_group.txt | sort -u | while read line; do sed "s/INPUT_ID/$line/g" input-chipseq.sh > $line\-input-chipseq.sh; sbatch $line\-input-chipseq.sh; done

# Step2. Analysis of each transcription factor：
cat sample_group.txt | while read line; do arr=(${line}); input=${arr[0]}; treat=${arr[1]}; sed -e "s/TREAT_ID/$treat/g" -e "s/INPUT_ID/$input/g" treat-chipseq.sh > $treat\-treat-chipseq.sh; sbatch $treat\-treat-chipseq.sh; done
