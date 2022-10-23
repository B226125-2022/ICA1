#!/bin/bash

INDEX_GENOME="Index_Congo"
THREAD=64
BOWTIE_BASE_ARGS="--no-unal -x $INDEX_GENOME"
SAMTOOLS_VIEW_ARGS="view"
SAMTOOLS_SORT_ARGS="sort"

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
	
echo "$(get_bowtie_2_lines)" | parallel bowtie2  #takes arguments for bowtie2 and pipes it into bowtie2 line by line in parallel

#Conversion to bam and sorting and indexing
for congo in *.sam
  do 
  samtools view -S -b $congo > ${congo/%sam/bam}
  done

for congo in *.bam
  do
  samtools sort $congo -o ${congo/%bam/sorted.bam}
  done

for congo in *.sorted.bam
  do
  samtools index $congo
  done

#Bedtools
bedtools multicov -bams *.sorted.bam -bed TriTrypDB-46_TcongolenseIL3000_2019.bed