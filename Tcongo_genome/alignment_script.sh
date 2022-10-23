#!/bin/bash

INDEX_GENOME="Index_Congo"
THREAD=64
BOWTIE_BASE_ARGS="--no-unal -x $INDEX_GENOME"
SAMTOOLS_VIEW_ARGS="view"
SAMTOOLS_SORT_ARGS="sort"

# echo *.fq

get_bowtie_2_lines()
{
	for readpair1 in *_1.fq 
    do
		readpair2=${readpair1/_1/_2}
		congo="$(cut -d '_' -f 1 <<< $readpair1)" # <<< in standard input
		bowtie_args="$BOWTIE_BASE_ARGS -1 $readpair1 -2 $readpair2 -S $congo.sam"
		echo $bowtie_args
    done
}

get_bowtie_2_lines | parallel bowtie2  #takes arguments for bowtie2 and pipes it into bowtie2 line by line in parallel

get_sam_to_bam_lines()
{
  for congo in *.sam; do
    bamfile_name="${congo/%sam/bam}"
    args="view -S -b $congo -o $bamfile_name"
    echo $args
  done
}

# Samtools does not like being given a full line as arguments.
# Combine the arguments together in a line to then separate on spaces
# and specify individually all six fields.
get_sam_to_bam_lines | parallel --colsep " " samtools {1} {2} {3} {4} {5} {6}

# # Conversion to bam and sorting and indexing
# for congo in *.sam
#   do 
#   echo "samtools view -S -b $congo > ${congo/%sam/bam}"
#   # samtools view -S -b $congo > ${congo/%sam/bam}
# done

get_bam_to_sorted_lines()
{
  for congo in *.bam; do
    sorted_bam_file="${congo/%bam/sorted.bam}"
    echo "sort $congo -o $sorted_bam_file"
  done
 }

# for congo in *.bam
#   do
#   samtools sort $congo -o ${congo/%bam/sorted.bam}
# done

get_bam_to_sorted_lines | parallel --colsep " " samtools {1} {2} {3} {4}

get_sorted_to_index_lines()
{
  for congo in *.sorted.bam; do
    echo "index $congo"
  done
}

get_sorted_to_index_lines | parallel --colsep " " samtools {1} {2}

# for congo in *.sorted.bam
#   do
#   samtools index $congo
# done

#Bedtools
# bedtools multicov -bams *.sorted.bam -bed TriTrypDB-46_TcongolenseIL3000_2019.bed