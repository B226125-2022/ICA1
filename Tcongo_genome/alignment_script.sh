#!/bin/bash

INDEXGENOME="Tcongoindex"
THREAD=64

for READPAIR1 in ./*_1.fq
  do
    echo $READPAIR1
    echo ${READPAIR1/_1/_2}
    bowtie2 --no-unal -p $THREAD -x $INDEXGENOME -1 $READPAIR1 -2 ${READPAIR1/_1/_2} -S samfile.sam 
    for samfile.sam in ./
      samtools view -S -b samfile.sam > bamfile.bam

  done 
    

