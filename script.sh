#!/bin/bash
threads=6
inputs_dir="/home/bioinformatikai/HW2/inputs"
outputs_dir="/home/bioinformatikai/HW2/outputs"

prefetch -O /home/bioinformatikai/HW2/inputs ERR204044 SRR15131330 SRR18214264
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/022/832/545/GCF_022832545.1_ASM2283254v1/GCF_022832545.1_ASM2283254v1_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/022/832/545/GCF_022832545.1_ASM2283254v1/GCF_022832545.1_ASM2283254v1_protein.faa.gz

fastq-dump --outdir /home/bioinformatikai/HW2/inputs/ --gzip --split-files /home/bioinformatikai/HW2/inputs/ERR204044
fastq-dump --outdir /home/bioinformatikai/HW2/inputs/ --gzip --split-files /home/bioinformatikai/HW2/inputs/SRR15131330
fastq-dump --outdir /home/bioinformatikai/HW2/inputs/ --gzip --split-files /home/bioinformatikai/HW2/inputs/SRR18214264

# Run FASTQC 
mkdir -p ${outputs_dir}/raw_data
fastqc -t ${threads} ${inputs_dir}/*fastq.gz -o ${outputs_dir}/raw_data

#The overall quality of the sequences does not look too bad. 
However, the sequence SRR18214264 reaches the red zone when measuring per-base sequence quality. 
There are significant levels of duplication in sequences

# Run standard FASTQ trimming and re-run FASTQC on cleaned FASTQ files
for i in ${inputs_dir}/*_1.fastq.gz;
do
  R1=${i};
  R2="${inputs_dir}/"$(basename ${i} _1.fastq.gz)"_2.fastq.gz";
  trim_galore -j ${threads} -o ${outputs_dir} --paired --length 20 ${R1} ${R2}
done

fastqc -t ${threads} ${outputs_dir}/*fq.gz -o ${outputs_dir}

#After rerunning FastQC, there were not many significant changes, however, the quality of reads slightly improved.
#The ERR204044_2_val_2 sample was not fully trimmed, however, that should not cause any significant problems.
#The per-base sequence quality of SRR18214264 was improved

# Create MultiQC plots for raw and processed data
multiqc -o ${outputs_dir}/raw_data ${outputs_dir}/raw_data
multiqc -o ${outputs_dir} ${outputs_dir}
