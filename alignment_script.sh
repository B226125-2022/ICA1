#!/bin/bash

INDEX_GENOME="Index_Congo"
THREAD=64
BOWTIE_BASE_ARGS="--no-unal -x $INDEX_GENOME"

if [ ! -d $2 ]; then
  echo "cannot find $2 to move to"
  exit
fi
cd "$2"

cleanup() 
{
  cd $FASTQ_DIR
  echo "Removing *.bam *.sam *.bai"
  rm *.bam *.sam *.bai
}

get_bowtie_2_lines()
{
	for readpair1 in *_1.fq; do
    #echo "$readpair1"
		readpair2=${readpair1/_1/_2}
		congo="$(cut -d '_' -f 1 <<< $readpair1)" # <<< in standard input
		bowtie_args="$BOWTIE_BASE_ARGS -1 $readpair1 -2 $readpair2 -S $congo.sam"
		echo $bowtie_args
    done
}

get_sam_to_bam_lines()
{
  for congo in *.sam; do
    bamfile_name="${congo/%sam/bam}"
    args="view -S -b $congo -o $bamfile_name"
    echo $args
  done
}

get_bam_to_sorted_lines()
{
  for congo in *.bam; do
    sorted_bam_file="${congo/%bam/sorted.bam}"
    echo "sort $congo -o $sorted_bam_file"
  done
 }

get_sorted_to_index_lines()
{
  for congo in *.sorted.bam; do
    echo "index $congo"
  done
}

process()
{
  get_bowtie_2_lines | parallel bowtie2  #takes arguments for bowtie2 and pipes it into bowtie2 line by line in parallel

  # Samtools does not like being given a full line as arguments.
  # Combine the arguments together in a line to then separate on spaces
  # and specify individually all six fields.
  
  # Conversion to bam
  get_sam_to_bam_lines | parallel --colsep " " samtools {1} {2} {3} {4} {5} {6}

  # Sort bam files
  get_bam_to_sorted_lines | parallel --colsep " " samtools {1} {2} {3} {4}

  # Index bam files
  get_sorted_to_index_lines | parallel --colsep " " samtools {1} {2}
}



case $1 in
  cleanup)
    echo "Running cleanup"
    cleanup
    ;;
  process)
    echo "Processing files"
    process
    ;;
  *)
    echo "Usage: $0 <cleanup|process> <fastq_dir>"
    exit 1
    ;;
esac