#!/bin/bash

INDEXGENOME="Tcongoindex"
THREAD=64

for READPAIR1 in ./*_1.fq
  do
    bowtie2 --no-unal -p $THREAD -x $INDEXGENOME -1 $READPAIR1 -2 ${READPAIR1/_1/_2} -S testoutput.sam

  done 
    

