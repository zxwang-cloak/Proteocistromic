#!/bin/bash

# 定义输出文件名
input_file="10TF-overlaps_with_sources.bed"
pre_merged_file="pre_merged.bed"
merged_regions_file="merged_regions.bed"
final_output_file="final_regions_with_tf.bed"

# 预处理文件：提取染色体、起始位置、结束位置和转录因子涉及情况列
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $5}' $input_file > $pre_merged_file

# 使用 bedtools 合并区域，并保留涉及的转录因子信息
bedtools merge -i $pre_merged_file -c 4 -o collapse -delim "," > $merged_regions_file

# 处理合并后的转录因子列表，去除重复，并生成最终的转录因子全集
# 同时确保区域长度至少为55bp
awk -F"\t" 'BEGIN{OFS="\t"} {
    region_length = $3 - $2;
    if (region_length >= 55) {  # 只处理长度大于或等于55bp的区域
        split($4, a, ",");
        delete uniq;
        for (i in a) uniq[a[i]]++;
        printf "%s\t%s\t%s\t", $1, $2, $3;
        first = 1;
        for (i in uniq) {
            if (!first) printf ",";
            printf i;
            first = 0;
        }
        printf "\n";
    }
}' $merged_regions_file > $final_output_file

echo "Processing completed. Check '$final_output_file' for the final output."

