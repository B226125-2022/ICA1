WORK_DIR="$HOME/ICA1"
FASTQ_DIR="$WORK_DIR/fastq"
GUNZIP_FASTQ_DIR="$WORK_DIR/fastq"
UNZIPPED_FASTQ_DIR="$FASTQ_DIR/unzipped_fastqc_zipfiles"
FASTQ_SOURCE="/localdisk/home/data/BPSM/ICA1/fastq"
TCONGO_SOURCE="/localdisk/data/BPSM/ICA1/Tcongo_genome"
TCONGO_BED_SOURCE="/localdisk/data/BPSM/ICA1/TriTrypDB-46_TcongolenseIL3000_2019.bed"
TCONGO_DIR="$WORK_DIR/Tcongo_genome"

# # if [ -d "$WORK_DIR" ]; then
# #     echo "Wiping $WORK_DIR"
# #     rm -r "$WORK_DIR"
# # fi

if [ ! -d "$WORK_DIR" ]; then
    echo "Creating $WORK_DIR"
    mkdir "$WORK_DIR"
else
    echo "$WORK_DIR already exists, continuing"
fi

echo "Copying fastq files from $FASTQ_SOURCE to $WORK_DIR"
cp -r $FASTQ_SOURCE $WORK_DIR

#fastqc files
fastqc $FASTQ_DIR/*.fq.gz -o $FASTQ_DIR #assess content on any file containing fastq.gz and output into directory fastq_files

# gunzip
echo "Unzipping every .fq.gz file in $FASTQ_DIR"
gunzip $FASTQ_DIR/*.fq.gz # get .fq files

# unzip post_fastqc_zip_files
echo "Unzipping every .zip file in $FASTQ_DIR"
for zipfile in $FASTQ_DIR/*.zip; do
    unzip $zipfile -d $UNZIPPED_FASTQ_DIR
done

# Run the quality assessment
echo "Running the quality assessment on $UNZIPPED_FASTQ_DIR"
./quality_assessment.sh "$UNZIPPED_FASTQ_DIR"

echo "Removing all html files in $FASTQ_DIR"
rm $FASTQ_DIR/*.html
echo "Removing all zip files in $FASTQ_DIR"
rm $FASTQ_DIR/*.zip

# import/cp Tcongo genome
echo "Copying $TCONGO_SOURCE to $WORK_DIR"
cp -r $TCONGO_SOURCE $WORK_DIR

echo "Unzipping every .fasta.gz file in $TCONGO_DIR"
gunzip $TCONGO_DIR/*.fasta.gz

echo "Running bowtie2-build on the Tcongo file"
bowtie2-build "$TCONGO_DIR/TriTrypDB-46_TcongolenseIL3000_2019_Genome.fasta" "$TCONGO_DIR/Index_Congo"

echo "Copying everything from $TCONGO_DIR into $FASTQ_DIR"
cp -v $TCONGO_DIR/* $FASTQ_DIR

# #run alignment script
echo "Running the alignment script's cleanup routine"
./alignment_script.sh cleanup $FASTQ_DIR
echo "Running the alignment script on $FASTQ_DIR"
./alignment_script.sh process $FASTQ_DIR

# #copy bedfile
echo "Copying $TCONGO_BED_SOURCE to $FASTQ_DIR"
cp -r $TCONGO_BED_SOURCE $FASTQ_DIR

# #run bedtools
echo "Running bedtools on *.sorted.bam in $FASTQ_DIR"
cd $FASTQ_DIR
bedtools multicov -bams *.sorted.bam -bed TriTrypDB-46_TcongolenseIL3000_2019.bed > read_count.txt

#just in case scripts are not in $WORK_DIR
echo "Copying scripts to $WORK_DIR"
cp -r *.sh $WORK_DIR

cd $WORK_DIR
echo "Grouping!"
./grouping.sh 

echo "Generating averages"
./getAverages.sh