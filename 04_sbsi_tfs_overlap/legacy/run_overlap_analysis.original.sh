#!/bin/bash

# 清空之前的文件列表，如果存在
> file_list.txt

# 生成文件列表，确保只包括 .bed 文件
ls *.bed | grep -v 'overlaps_with_sources.bed' > file_list.txt

# 准备文件和名称列表
echo -n "" > files.txt
echo -n "" > names.txt

while read file; do
    if [[ -s "$file" ]]; then  # 确保文件不为空
        echo "$file" >> files.txt
        echo "$(basename "$file" .bed)" >> names.txt
    fi
done < file_list.txt

# 执行 multiIntersectBed，使用文件输入
multiIntersectBed -i $(cat files.txt) -names $(cat names.txt) > overlaps_with_sources.bed

# 检查输出文件是否存在并打印头部信息
if [[ -f overlaps_with_sources.bed ]]; then
    head overlaps_with_sources.bed
else
    echo "No output file generated."
fi

