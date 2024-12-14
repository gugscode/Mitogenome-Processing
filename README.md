#### FASTQ Processing and Analysis Pipeline ####
---

#### Overview

This Bash script automates the processing of paired-end FASTQ files, including quality assessment, trimming, alignment, and duplicate marking. It leverages tools like **FastQC**, **MultiQC**, **Fastp**, **BWA**, **SAMtools**, and **Picard** to perform the following steps:

1. Quality Analysis using *FastQC* and *MultiQC* (Pre- and Post-trimming).
2. Trimming and Adapter Removal using *Fastp*.
3. Alignment of trimmed reads against a mitochondrial reference genome using *BWA*.
4. Conversion of SAM to BAM, sorting, and duplicate marking using *SAMtools* and *Picard*.
---

#### Prerequisites

Ensure the following software/tools are installed and accessible in your `$PATH`:

- `FastQC`
- `MultiQC`
- `Fastp`
- `BWA`
- `SAMtools`
- `Picard`
- Java Runtime Environment (for Picard)
---

#### Directory Structure

Before running the script, create and organize your directories as follows:

- **Input Directory:** Contains raw FASTQ files (`*_R1.fastq` and `*_R2.fastq`).
- **Output Directories:** The script will automatically create these:
  - Processed FASTQ files
  - Quality reports (pre- and post-trimming)
  - SAM/BAM files and final sorted BAM files
  - Marked duplicate files and metrics
---

#### How to Use

1. **Set Variables**: Update the following paths in the script to match your file structure:
   - `input_dir`: Path to raw FASTQ files.
   - `output_dir`: Directory for trimmed FASTQ files.
   - `fastqc_dir_pre`: Directory for pre-trimming quality reports.
   - `fastqc_dir_post`: Directory for post-trimming quality reports.
   - `multiqc_dir`: Directory for consolidated MultiQC reports.
   - `alignment_dir`: Directory for alignment (SAM) files.
   - `reference_mtDNA`: Path to the reference genome file (FASTA format).
   - `picard_output_dir`: Directory for Picard-marked BAM files.

2. Make Executable:
   ```bash
   chmod +x mitogenome_processing.sh
   ```

3. Run the Script**:
   ```bash
   ./mitogenome_processing.sh
   ```
---

#### Pipeline Workflow

1. Initial Quality Check:
   - Generates pre-trimming quality reports for raw FASTQ files using `FastQC`.
   - Combines individual reports using `MultiQC`.

2. Trimming with Fastp:
   - Removes adapters and low-quality bases.
   - Produces trimmed FASTQ files with a summary HTML report.

3. Post-Quality Check:
   - Generates quality reports for trimmed FASTQ files.

4. Alignment:
   - Aligns trimmed reads to the mitochondrial reference genome using `BWA` and outputs SAM files.

5. Conversion and Sorting:
   - Converts SAM files to BAM format using `SAMtools`.
   - Sorts BAM files for downstream processing.

6. Duplicate Marking:
   - Marks and removes duplicates from BAM files using `Picard`.
---

#### Outputs

- Quality Reports: Available in the directories for both pre- and post-trimming.
- Processed Files:
  - Trimmed FASTQ files in `output_dir`.
  - Aligned SAM files in `alignment_dir`.
  - Sorted BAM files in `sorted_bam`.
  - Marked BAM files and metrics in `picard_output_dir`.
---

#### Troubleshooting

- Ensure paths to tools and reference files are correct.
- Check the output logs for errors during alignment or duplicate marking.
---

#### Acknowledgments

This pipeline uses tools developed by open-source communities. Please refer to their documentation for further details:

- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- [MultiQC](https://multiqc.info/)
- [Fastp](https://github.com/OpenGene/fastp)
- [BWA](http://bio-bwa.sourceforge.net/)
- [SAMtools](http://www.htslib.org/)
- [Picard](https://broadinstitute.github.io/picard/)
---

#### References

- FastQC: Andrews, S. FastQC: A Quality Control Tool for High Throughput Sequence Data. Available at: FastQC

- MultiQC: Ewels, P., Magnusson, M., Lundin, S., & Käller, M. (2016). "MultiQC: summarize analysis results for multiple tools." Bioinformatics, 32(19), 3047–3048. https://doi.org/10.1093/bioinformatics/btw354

- Fastp: Chen, S., Zhou, Y., Chen, Y., & Gu, J. (2018). "fastp: an ultra-fast all-in-one FASTQ processor." Bioinformatics, 34(17), i884–i890. https://doi.org/10.1093/bioinformatics/bty560

- BWA: Li, H., & Durbin, R. (2009). "Fast and accurate short read alignment with Burrows-Wheeler transform." Bioinformatics, 25(14), 1754–1760. https://doi.org/10.1093/bioinformatics/btp324

- SAMtools: Li, H., Handsaker, B., Wysoker, A., & Fennell, T. (2009). "The Sequence Alignment/Map format and SAMtools." Bioinformatics, 25(16), 2078–2079. https://doi.org/10.1093/bioinformatics/btp352

    Picard: Broad Institute. (2020). Picard Tools. Available at: Picard
