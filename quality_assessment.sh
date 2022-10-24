#!/bin/bash

# Work in the specified directory
prev_dir="$(pwd)"

# If argument
if [ -z "$1" ]; then #-z if no value
  echo "Usage: $0 [fastq directory]"
  exit 1
fi

cd "$1"

# Theshold for failures and warnings in conjunction
THRESHOLD=3

FAIL_PATTERN="^FAIL"
WARN_PATTERN="^WARN"

for i in ./*/summary.txt; do
    # Get the parent folder name
    folder="$(awk -F "_" '{print $1}' <<< $i)" #-F delimiter
    # Remove the leading ./
    folder="${folder##*/}"
    failures="$(grep -c $FAIL_PATTERN $i)" #-c counts
    warnings="$(grep -c $WARN_PATTERN $i)"

    sum=$((failures+warnings))
  
    echo "$folder: Failures and warnings: $sum" >> $prev_dir/quality_assessment.txt

    if [ $sum -lt $THRESHOLD ]; then
      echo "$folder is successful"
      echo "$folder" >> $prev_dir/successful_files.txt
    else
      echo "$folder is unsuccessful"
      echo "Attempting to remove files. Please confirm each file."
      rm -i ../"$folder"_1.fq
      rm -i ../"$folder"_2.fq
      echo "$folder" >> $prev_dir/unsuccessful_files.txt
    fi
done

cd "$prev_dir"