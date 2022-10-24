#!/bin/bash

getRelevantLines()
{
     # file=$1
     echo "$1"
     while read line; do
        awk -F'\t' '{print $1}'
     done < $1
 }

getAverages() {
    offset=5
    sum=0
    field_count="$(echo $1 | tr " " "\n" | wc -l)"
    while read file_line; do
        sum=0
        while read column; do
            column_number=$((column+offset))
            value="$(awk -v c=$column_number -F'\t' '{print $c}' <<< "$file_line")"
            sum=$((sum+value))
            bc_string="$sum / $field_count"
            # use bc to do floating-point division
            average="$(echo "$bc_string" | bc -l)"
            # echo "sum: $sum; average: $average"
        done <<< "$(tr " " "\n" <<< $1)"
        echo "$(awk -F'\t' '{print $4}' <<< "$file_line")	$(awk -F'\t' '{print $5}' <<< "$file_line"))	$average"
    done < "fastq/read_count.txt"
}

for file in *duced.txt; do
    relevant_lines="$(
    while read line; do
        echo "$line" | awk -F'\t' '{print $1}'
    done < $file)"
    getAverages "$relevant_lines" >> "$file-averages.txt"
done