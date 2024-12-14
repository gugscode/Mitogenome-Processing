#!/bin/bash

# Directory settings
input_dir="/path/to/input/directory"        # Directory containing the original FASTQ files
output_dir="/path/to/output/directory"        # Directory for Fastp processed files
fastqc_dir_pre="/path/to/FastQC_pre_reports"   # Directory for FastQC reports before Fastp
fastqc_dir_post="/path/to/FastQC_post_reports"   # Directory for FastQC reports after Fastp
multiqc_dir="/path/to/MultiQC_reports" # Directory for MultiQC reports
alignment_dir="/path/to/alignment/files" # Directory for SAM files
reference_mtDNA="/path/to/reference/fasta/file" # mtDNA reference sequence
picard_output_dir="/path/to/marked/files"  # Directory for marked BAM files

# Creating necessary directories
mkdir -p "$output_dir" "$fastqc_dir_pre" "$fastqc_dir_post" "$multiqc_dir" "$alignment_dir" "$picard_output_dir"
mkdir -p bam_files sorted_bam

# Step 1: Initial quality analysis with FastQC
echo "Starting initial quality analysis..."
fastqc "$input_dir"/*_R1.fastq "$input_dir"/*_R2.fastq --outdir "$fastqc_dir_pre"
multiqc "$fastqc_dir_pre" -o "$multiqc_dir"
echo "Initial quality analysis completed!"

# Step 2: Processing FASTQ files with Fastp
echo "Starting FASTQ file processing..."
for r1 in "$input_dir"/*_R1.fastq; do
    r2=${r1/_R1/_R2}  # Corresponding R2 file name
    base=$(basename "$r1" _R1.fastq)

    # Output file names
    trimmed_r1="$output_dir/${base}_R1_trimmed.fastq"
    trimmed_r2="$output_dir/${base}_R2_trimmed.fastq"

    # Running Fastp
    fastp -i "$r1" -I "$r2" -o "$trimmed_r1" -O "$trimmed_r2" \
          -q 20 -5 20 -3 20 -r 20 \
          --cut_front_window_size 3 \
          --cut_tail_window_size 3 --cut_right_window_size 3 \
          --detect_adapter_for_pe \
          -w 10 -D --dup_calc_accuracy 6 \
          --report_title "$base Report" --html "$output_dir/${base}_report.html"
done
echo "Processing completed!"

# Step 3: Post-processing quality analysis with FastQC and MultiQC
echo "Starting post-processing quality analysis..."
fastqc "$output_dir"/*trimmed.fastq --outdir "$fastqc_dir_post"
multiqc "$fastqc_dir_post" -o "$multiqc_dir"
echo "Post-processing quality analysis completed!"

# Step 4: Alignment with BWA
echo "Starting alignment with BWA..."
for r1_file in "$output_dir"/*R1_trimmed.fastq; do
    base_name=$(basename "$r1_file" _R1_trimmed.fastq)  # Base name of R1 file
    r2_file="$output_dir/${base_name}_R2_trimmed.fastq"  # Corresponding R2 file
    output_file="$alignment_dir/${base_name}.sam"        # SAM output file

    # BWA alignment
    bwa mem "$reference_mtDNA" "$r1_file" "$r2_file" > "$output_file"
done
echo "Alignment completed!"

# Step 5: Conversion of SAM to BAM
echo "Converting SAM files to BAM..."
for sam_file in "$alignment_dir"/*.sam; do
    base_name=$(basename "$sam_file" .sam)  # Base name of SAM file
    bam_file="bam_files/${base_name}.bam"  # BAM output file

    # Conversion with SAMtools
    samtools view -bS "$sam_file" -o "$bam_file"
done
echo "Conversion to BAM completed!"

# Step 6: Sorting BAM files
echo "Sorting BAM files..."
for bam_file in bam_files/*.bam; do
    base_name=$(basename "$bam_file" .bam)  # Base name of BAM file
    sorted_bam_file="sorted_bam/${base_name}_sorted.bam"  # Sorted BAM output file

    # Sorting with SAMtools
    samtools sort -o "$sorted_bam_file" "$bam_file"
done
echo "Sorting completed!"

# Step 7: Marking and removing duplicates with Picard
echo "Marking and removing duplicates..."
for sorted_bam_file in sorted_bam/*_sorted.bam; do
    base_name=$(basename "$sorted_bam_file" _sorted.bam)  # Base name of sorted BAM file
    output_file="$picard_output_dir/${base_name}.marked_remov.bam"  # Marked BAM output file
    metrics_file="$picard_output_dir/${base_name}.metrics.txt"  # Metrics file

    # Marking duplicates
    java -jar picard.jar MarkDuplicates \
        REMOVE_DUPLICATES=true \
        I="$sorted_bam_file" \
        O="$output_file" \
        M="$metrics_file"
done
echo "Marking duplicates completed!"

# Finalization
echo "Pipeline complete! Check the processed files and generated reports."
