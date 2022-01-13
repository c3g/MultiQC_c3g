#!/bin/bash
# Exit immediately on error

set -eu -o pipefail

#-------------------------------------------------------------------------------
# ChipSeq SLURM Job Submission Bash script
# Version: 3.5.1-beta
# Created on: 2021-08-18T16:28:47
# Steps:
#   picard_sam_to_fastq: 0 job... skipping
#   trimmomatic: 8 jobs
#   merge_trimmomatic_stats: 1 job
#   mapping_bwa_mem_sambamba: 8 jobs
#   sambamba_merge_bam_files: 8 jobs
#   sambamba_mark_duplicates: 9 jobs
#   sambamba_view_filter: 9 jobs
#   metrics: 17 jobs
#   homer_make_tag_directory: 8 jobs
#   qc_metrics: 1 job
#   homer_make_ucsc_file: 17 jobs
#   macs2_callpeak: 9 jobs
#   homer_annotate_peaks: 5 jobs
#   homer_find_motifs_genome: 5 jobs
#   annotation_graphs: 1 job
#   run_spp: 9 jobs
#   differential_binding: 1 job
#   ihec_metrics: 6 jobs
#   multiqc_report: 1 job
#   cram_output: 8 jobs
#   TOTAL: 131 jobs
#-------------------------------------------------------------------------------

OUTPUT_DIR=/lustre04/scratch/newtonma/chipseq_test_2
JOB_OUTPUT_DIR=$OUTPUT_DIR/job_output
TIMESTAMP=`date +%FT%H.%M.%S`
JOB_LIST=$JOB_OUTPUT_DIR/ChipSeq_job_list_$TIMESTAMP
export CONFIG_FILES="/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,chipseq.ini"
mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

                    sed -i "s/\"submission_date\": \"\",/\"submission_date\": \"$TIMESTAMP\",/" /lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json

                    sed -i "s/\"submission_date\": \"\",/\"submission_date\": \"$TIMESTAMP\",/" /lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json

                    sed -i "s/\"submission_date\": \"\",/\"submission_date\": \"$TIMESTAMP\",/" /lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json

                    sed -i "s/\"submission_date\": \"\",/\"submission_date\": \"$TIMESTAMP\",/" /lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json

#------------------------------------------------------------------------------
# Print a copy of sample JSONs for the genpipes dashboard
#------------------------------------------------------------------------------
cp "/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json" "$PORTAL_OUTPUT_DIR/$USER.EW22.395918dcc2e745dca8d2edd65b13a046.json"
cp "/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json" "$PORTAL_OUTPUT_DIR/$USER.EW3.e5f9ecdbf1f54fd298aa52d093f6823f.json"
cp "/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json" "$PORTAL_OUTPUT_DIR/$USER.EW7.e04c3e989d944e9cbbbb30c7418105ea.json"
cp "/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json" "$PORTAL_OUTPUT_DIR/$USER.TC71.8ed94d1fb56844e59d21a058a1dcfa4a.json"

#-------------------------------------------------------------------------------
# STEP: trimmomatic
#-------------------------------------------------------------------------------
STEP=trimmomatic
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: trimmomatic_1_JOB_ID: trimmomatic.EW22_A787C17_input
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.EW22_A787C17_input
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.EW22_A787C17_input.61e1fc4761cf200b49a7f8a6912075ee.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.EW22_A787C17_input.61e1fc4761cf200b49a7f8a6912075ee.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.39 && \
mkdir -p trim/EW22/input && \
`cat > trim/EW22/input/EW22_A787C17_input.trim.adapters.fa << END
>Single
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
END
` && \
java -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx20G -jar $TRIMMOMATIC_JAR SE \
  -threads 5 \
  -phred33 \
  /lustre04/scratch/newtonma/chipseq_test_2/raw_data/EW22_A787C17_input_chr19.fastq.gz \
  trim/EW22/input/EW22_A787C17_input.trim.single.fastq.gz \
  ILLUMINACLIP:trim/EW22/input/EW22_A787C17_input.trim.adapters.fa:2:30:15 \
  TRAILING:20 \
  MINLEN:25 \
  2> trim/EW22/input/EW22_A787C17_input.trim.log
trimmomatic.EW22_A787C17_input.61e1fc4761cf200b49a7f8a6912075ee.mugqic.done
chmod 755 $COMMAND
trimmomatic_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 | grep "[0-9]" | cut -d\  -f4)
echo "$trimmomatic_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_2_JOB_ID: trimmomatic.EW22_A787C20_H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.EW22_A787C20_H3K27ac
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.EW22_A787C20_H3K27ac.8b76bb2d1e78c416b39ec2bcdc3cc4ce.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.EW22_A787C20_H3K27ac.8b76bb2d1e78c416b39ec2bcdc3cc4ce.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.39 && \
mkdir -p trim/EW22/H3K27ac && \
`cat > trim/EW22/H3K27ac/EW22_A787C20_H3K27ac.trim.adapters.fa << END
>Single
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
END
` && \
java -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx20G -jar $TRIMMOMATIC_JAR SE \
  -threads 5 \
  -phred33 \
  /lustre04/scratch/newtonma/chipseq_test_2/raw_data/EW22_A787C20_H3K27ac_chr19.fastq.gz \
  trim/EW22/H3K27ac/EW22_A787C20_H3K27ac.trim.single.fastq.gz \
  ILLUMINACLIP:trim/EW22/H3K27ac/EW22_A787C20_H3K27ac.trim.adapters.fa:2:30:15 \
  TRAILING:20 \
  MINLEN:25 \
  2> trim/EW22/H3K27ac/EW22_A787C20_H3K27ac.trim.log
trimmomatic.EW22_A787C20_H3K27ac.8b76bb2d1e78c416b39ec2bcdc3cc4ce.mugqic.done
chmod 755 $COMMAND
trimmomatic_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 | grep "[0-9]" | cut -d\  -f4)
echo "$trimmomatic_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_3_JOB_ID: trimmomatic.EW3_1056C284_input
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.EW3_1056C284_input
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.EW3_1056C284_input.fd2cc2fc31c764d3eb5705ca630fcf49.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.EW3_1056C284_input.fd2cc2fc31c764d3eb5705ca630fcf49.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.39 && \
mkdir -p trim/EW3/input && \
`cat > trim/EW3/input/EW3_1056C284_input.trim.adapters.fa << END
>Single
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
END
` && \
java -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx20G -jar $TRIMMOMATIC_JAR SE \
  -threads 5 \
  -phred33 \
  /lustre04/scratch/newtonma/chipseq_test_2/raw_data/EW3_1056C284_input_chr19.fastq.gz \
  trim/EW3/input/EW3_1056C284_input.trim.single.fastq.gz \
  ILLUMINACLIP:trim/EW3/input/EW3_1056C284_input.trim.adapters.fa:2:30:15 \
  TRAILING:20 \
  MINLEN:25 \
  2> trim/EW3/input/EW3_1056C284_input.trim.log
trimmomatic.EW3_1056C284_input.fd2cc2fc31c764d3eb5705ca630fcf49.mugqic.done
chmod 755 $COMMAND
trimmomatic_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 | grep "[0-9]" | cut -d\  -f4)
echo "$trimmomatic_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_4_JOB_ID: trimmomatic.EW3_A1056C287_H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.EW3_A1056C287_H3K27ac
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.EW3_A1056C287_H3K27ac.91b9743f08249532c80ed1b5b6a73066.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.EW3_A1056C287_H3K27ac.91b9743f08249532c80ed1b5b6a73066.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.39 && \
mkdir -p trim/EW3/H3K27ac && \
`cat > trim/EW3/H3K27ac/EW3_A1056C287_H3K27ac.trim.adapters.fa << END
>Single
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
END
` && \
java -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx20G -jar $TRIMMOMATIC_JAR SE \
  -threads 5 \
  -phred33 \
  /lustre04/scratch/newtonma/chipseq_test_2/raw_data/EW3_A1056C287_H3K27ac_chr19.fastq.gz \
  trim/EW3/H3K27ac/EW3_A1056C287_H3K27ac.trim.single.fastq.gz \
  ILLUMINACLIP:trim/EW3/H3K27ac/EW3_A1056C287_H3K27ac.trim.adapters.fa:2:30:15 \
  TRAILING:20 \
  MINLEN:25 \
  2> trim/EW3/H3K27ac/EW3_A1056C287_H3K27ac.trim.log
trimmomatic.EW3_A1056C287_H3K27ac.91b9743f08249532c80ed1b5b6a73066.mugqic.done
chmod 755 $COMMAND
trimmomatic_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 | grep "[0-9]" | cut -d\  -f4)
echo "$trimmomatic_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_5_JOB_ID: trimmomatic.EW7_A485C51_input
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.EW7_A485C51_input
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.EW7_A485C51_input.73aedc5448426898ce64b47e097cde1d.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.EW7_A485C51_input.73aedc5448426898ce64b47e097cde1d.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.39 && \
mkdir -p trim/EW7/input && \
`cat > trim/EW7/input/EW7_A485C51_input.trim.adapters.fa << END
>Single
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
END
` && \
java -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx20G -jar $TRIMMOMATIC_JAR SE \
  -threads 5 \
  -phred33 \
  /lustre04/scratch/newtonma/chipseq_test_2/raw_data/EW7_A485C51_input_chr19.fastq.gz \
  trim/EW7/input/EW7_A485C51_input.trim.single.fastq.gz \
  ILLUMINACLIP:trim/EW7/input/EW7_A485C51_input.trim.adapters.fa:2:30:15 \
  TRAILING:20 \
  MINLEN:25 \
  2> trim/EW7/input/EW7_A485C51_input.trim.log
trimmomatic.EW7_A485C51_input.73aedc5448426898ce64b47e097cde1d.mugqic.done
chmod 755 $COMMAND
trimmomatic_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 | grep "[0-9]" | cut -d\  -f4)
echo "$trimmomatic_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_6_JOB_ID: trimmomatic.EW7_A490C39_H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.EW7_A490C39_H3K27ac
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.EW7_A490C39_H3K27ac.3b3e1f91b5bba2af39039522d21c5752.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.EW7_A490C39_H3K27ac.3b3e1f91b5bba2af39039522d21c5752.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.39 && \
mkdir -p trim/EW7/H3K27ac && \
`cat > trim/EW7/H3K27ac/EW7_A490C39_H3K27ac.trim.adapters.fa << END
>Single
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
END
` && \
java -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx20G -jar $TRIMMOMATIC_JAR SE \
  -threads 5 \
  -phred33 \
  /lustre04/scratch/newtonma/chipseq_test_2/raw_data/EW7_A490C39_H3K27ac_chr19.fastq.gz \
  trim/EW7/H3K27ac/EW7_A490C39_H3K27ac.trim.single.fastq.gz \
  ILLUMINACLIP:trim/EW7/H3K27ac/EW7_A490C39_H3K27ac.trim.adapters.fa:2:30:15 \
  TRAILING:20 \
  MINLEN:25 \
  2> trim/EW7/H3K27ac/EW7_A490C39_H3K27ac.trim.log
trimmomatic.EW7_A490C39_H3K27ac.3b3e1f91b5bba2af39039522d21c5752.mugqic.done
chmod 755 $COMMAND
trimmomatic_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 | grep "[0-9]" | cut -d\  -f4)
echo "$trimmomatic_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_7_JOB_ID: trimmomatic.TC71_A379C48_H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.TC71_A379C48_H3K27ac
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.TC71_A379C48_H3K27ac.093a1ffc07505e680e709217c0b9875c.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.TC71_A379C48_H3K27ac.093a1ffc07505e680e709217c0b9875c.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.39 && \
mkdir -p trim/TC71/H3K27ac && \
`cat > trim/TC71/H3K27ac/TC71_A379C48_H3K27ac.trim.adapters.fa << END
>Single
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
END
` && \
java -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx20G -jar $TRIMMOMATIC_JAR SE \
  -threads 5 \
  -phred33 \
  /lustre04/scratch/newtonma/chipseq_test_2/raw_data/TC71_A379C48_H3K27ac_chr19.fastq.gz \
  trim/TC71/H3K27ac/TC71_A379C48_H3K27ac.trim.single.fastq.gz \
  ILLUMINACLIP:trim/TC71/H3K27ac/TC71_A379C48_H3K27ac.trim.adapters.fa:2:30:15 \
  TRAILING:20 \
  MINLEN:25 \
  2> trim/TC71/H3K27ac/TC71_A379C48_H3K27ac.trim.log
trimmomatic.TC71_A379C48_H3K27ac.093a1ffc07505e680e709217c0b9875c.mugqic.done
chmod 755 $COMMAND
trimmomatic_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 | grep "[0-9]" | cut -d\  -f4)
echo "$trimmomatic_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: trimmomatic_8_JOB_ID: trimmomatic.TC71_A379C51_input
#-------------------------------------------------------------------------------
JOB_NAME=trimmomatic.TC71_A379C51_input
JOB_DEPENDENCIES=
JOB_DONE=job_output/trimmomatic/trimmomatic.TC71_A379C51_input.ff0c02c5cb9551f6cdfd79f7af87cca5.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'trimmomatic.TC71_A379C51_input.ff0c02c5cb9551f6cdfd79f7af87cca5.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/trimmomatic/0.39 && \
mkdir -p trim/TC71/input && \
`cat > trim/TC71/input/TC71_A379C51_input.trim.adapters.fa << END
>Single
AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
END
` && \
java -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx20G -jar $TRIMMOMATIC_JAR SE \
  -threads 5 \
  -phred33 \
  /lustre04/scratch/newtonma/chipseq_test_2/raw_data/TC71_A379C51_input_chr19.fastq.gz \
  trim/TC71/input/TC71_A379C51_input.trim.single.fastq.gz \
  ILLUMINACLIP:trim/TC71/input/TC71_A379C51_input.trim.adapters.fa:2:30:15 \
  TRAILING:20 \
  MINLEN:25 \
  2> trim/TC71/input/TC71_A379C51_input.trim.log
trimmomatic.TC71_A379C51_input.ff0c02c5cb9551f6cdfd79f7af87cca5.mugqic.done
chmod 755 $COMMAND
trimmomatic_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"trimmomatic\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 | grep "[0-9]" | cut -d\  -f4)
echo "$trimmomatic_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$trimmomatic_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: merge_trimmomatic_stats
#-------------------------------------------------------------------------------
STEP=merge_trimmomatic_stats
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: merge_trimmomatic_stats_1_JOB_ID: merge_trimmomatic_stats.
#-------------------------------------------------------------------------------
JOB_NAME=merge_trimmomatic_stats.
JOB_DEPENDENCIES=$trimmomatic_1_JOB_ID:$trimmomatic_2_JOB_ID:$trimmomatic_3_JOB_ID:$trimmomatic_4_JOB_ID:$trimmomatic_5_JOB_ID:$trimmomatic_6_JOB_ID:$trimmomatic_7_JOB_ID:$trimmomatic_8_JOB_ID
JOB_DONE=job_output/merge_trimmomatic_stats/merge_trimmomatic_stats..9093bcdeb08c80719a389a758da929a5.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'merge_trimmomatic_stats..9093bcdeb08c80719a389a758da929a5.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/pandoc/1.15.2 && \
mkdir -p metrics && \

echo -e "Sample\tReadset\tMark Name\tRaw Single Reads #\tSurviving Single Reads #\tSurviving Single Reads %" > metrics/trimReadsetTable.tsv && \
grep ^Input trim/EW22/input/EW22_A787C17_input.trim.log | \
perl -pe 's/^Input Reads: (\d+).*Surviving: (\d+).*$/EW22\tEW22_A787C17_input\tinput\t\1\t\2/' | \
awk '{OFS="\t"; print $0, $5 / $4 * 100}' \
  >> metrics/trimReadsetTable.tsv && \
grep ^Input trim/EW22/H3K27ac/EW22_A787C20_H3K27ac.trim.log | \
perl -pe 's/^Input Reads: (\d+).*Surviving: (\d+).*$/EW22\tEW22_A787C20_H3K27ac\tH3K27ac\t\1\t\2/' | \
awk '{OFS="\t"; print $0, $5 / $4 * 100}' \
  >> metrics/trimReadsetTable.tsv && \
grep ^Input trim/EW3/input/EW3_1056C284_input.trim.log | \
perl -pe 's/^Input Reads: (\d+).*Surviving: (\d+).*$/EW3\tEW3_1056C284_input\tinput\t\1\t\2/' | \
awk '{OFS="\t"; print $0, $5 / $4 * 100}' \
  >> metrics/trimReadsetTable.tsv && \
grep ^Input trim/EW3/H3K27ac/EW3_A1056C287_H3K27ac.trim.log | \
perl -pe 's/^Input Reads: (\d+).*Surviving: (\d+).*$/EW3\tEW3_A1056C287_H3K27ac\tH3K27ac\t\1\t\2/' | \
awk '{OFS="\t"; print $0, $5 / $4 * 100}' \
  >> metrics/trimReadsetTable.tsv && \
grep ^Input trim/EW7/input/EW7_A485C51_input.trim.log | \
perl -pe 's/^Input Reads: (\d+).*Surviving: (\d+).*$/EW7\tEW7_A485C51_input\tinput\t\1\t\2/' | \
awk '{OFS="\t"; print $0, $5 / $4 * 100}' \
  >> metrics/trimReadsetTable.tsv && \
grep ^Input trim/EW7/H3K27ac/EW7_A490C39_H3K27ac.trim.log | \
perl -pe 's/^Input Reads: (\d+).*Surviving: (\d+).*$/EW7\tEW7_A490C39_H3K27ac\tH3K27ac\t\1\t\2/' | \
awk '{OFS="\t"; print $0, $5 / $4 * 100}' \
  >> metrics/trimReadsetTable.tsv && \
grep ^Input trim/TC71/H3K27ac/TC71_A379C48_H3K27ac.trim.log | \
perl -pe 's/^Input Reads: (\d+).*Surviving: (\d+).*$/TC71\tTC71_A379C48_H3K27ac\tH3K27ac\t\1\t\2/' | \
awk '{OFS="\t"; print $0, $5 / $4 * 100}' \
  >> metrics/trimReadsetTable.tsv && \
grep ^Input trim/TC71/input/TC71_A379C51_input.trim.log | \
perl -pe 's/^Input Reads: (\d+).*Surviving: (\d+).*$/TC71\tTC71_A379C51_input\tinput\t\1\t\2/' | \
awk '{OFS="\t"; print $0, $5 / $4 * 100}' \
  >> metrics/trimReadsetTable.tsv && \
cut -f1,3- metrics/trimReadsetTable.tsv | awk -F"\t" '{OFS="\t"; if (NR==1) {if ($3=="Raw Paired Reads #") {paired=1};print "Sample", "Mark Name", "Raw Reads #", "Surviving Reads #", "Surviving %"} else {if (paired) {$3=$3*2; $4=$4*2}; sample[$1$2]=$1; markname[$1$2]=$2; raw[$1$2]+=$3; surviving[$1$2]+=$4}}END{for (samplemark in raw){print sample[samplemark], markname[samplemark], raw[samplemark], surviving[samplemark], surviving[samplemark] / raw[samplemark] * 100}}' \
  > metrics/trimSampleTable.tsv && \
mkdir -p report/yaml && \
cp metrics/trimReadsetTable.tsv metrics/trimSampleTable.tsv report/ && \
sed -e 's@trailing_min_quality@20@g' \
    -e 's@min_length@25@g' \
    -e 's@read_type@Single@g' \
    -e 's@readset_merge_trim_stats@metrics/trimReadsetTable.tsv@g' \
    /home/newtonma/apps/genpipes/bfx/report/Illumina.merge_trimmomatic_stats.yaml > report/yaml/Illumina.merge_trimmomatic_stats.yaml
merge_trimmomatic_stats..9093bcdeb08c80719a389a758da929a5.mugqic.done
chmod 755 $COMMAND
merge_trimmomatic_stats_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"merge_trimmomatic_stats\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"merge_trimmomatic_stats\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$merge_trimmomatic_stats_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$merge_trimmomatic_stats_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: mapping_bwa_mem_sambamba
#-------------------------------------------------------------------------------
STEP=mapping_bwa_mem_sambamba
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: mapping_bwa_mem_sambamba_1_JOB_ID: mapping_bwa_mem_sambamba.EW22_A787C17_input
#-------------------------------------------------------------------------------
JOB_NAME=mapping_bwa_mem_sambamba.EW22_A787C17_input
JOB_DEPENDENCIES=$trimmomatic_1_JOB_ID
JOB_DONE=job_output/mapping_bwa_mem_sambamba/mapping_bwa_mem_sambamba.EW22_A787C17_input.77a432613e58cfbb05202a74ef1842a6.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'mapping_bwa_mem_sambamba.EW22_A787C17_input.77a432613e58cfbb05202a74ef1842a6.mugqic.done' > $COMMAND
module purge && \
module load mugqic/bwa/0.7.17 mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW22/input/EW22_A787C17_input && \
bwa mem -K 100000000 -v 3 -t 7 -Y \
   \
  -R '@RG\tID:EW22_A787C17_input\tSM:EW22\tLB:EW22\tPU:run2965_1\tCN:McGill University and Genome Quebec Innovation Centre\tPL:Illumina' \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/bwa_index/Homo_sapiens.hg19.fa \
  trim/EW22/input/EW22_A787C17_input.trim.single.fastq.gz | \
sambamba view -S -f bam \
  /dev/stdin \
    | \
sambamba sort  \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment/EW22/input/EW22_A787C17_input/EW22_A787C17_input.sorted.bam && \
sambamba index  \
  alignment/EW22/input/EW22_A787C17_input/EW22_A787C17_input.sorted.bam \
  alignment/EW22/input/EW22_A787C17_input/EW22_A787C17_input.sorted.bam.bai
mapping_bwa_mem_sambamba.EW22_A787C17_input.77a432613e58cfbb05202a74ef1842a6.mugqic.done
chmod 755 $COMMAND
mapping_bwa_mem_sambamba_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 10 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$mapping_bwa_mem_sambamba_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$mapping_bwa_mem_sambamba_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: mapping_bwa_mem_sambamba_2_JOB_ID: mapping_bwa_mem_sambamba.EW22_A787C20_H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=mapping_bwa_mem_sambamba.EW22_A787C20_H3K27ac
JOB_DEPENDENCIES=$trimmomatic_2_JOB_ID
JOB_DONE=job_output/mapping_bwa_mem_sambamba/mapping_bwa_mem_sambamba.EW22_A787C20_H3K27ac.93dff004da118acf282d8830c056d13b.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'mapping_bwa_mem_sambamba.EW22_A787C20_H3K27ac.93dff004da118acf282d8830c056d13b.mugqic.done' > $COMMAND
module purge && \
module load mugqic/bwa/0.7.17 mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW22/H3K27ac/EW22_A787C20_H3K27ac && \
bwa mem -K 100000000 -v 3 -t 7 -Y \
   \
  -R '@RG\tID:EW22_A787C20_H3K27ac\tSM:EW22\tLB:EW22\tPU:run2962_1\tCN:McGill University and Genome Quebec Innovation Centre\tPL:Illumina' \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/bwa_index/Homo_sapiens.hg19.fa \
  trim/EW22/H3K27ac/EW22_A787C20_H3K27ac.trim.single.fastq.gz | \
sambamba view -S -f bam \
  /dev/stdin \
    | \
sambamba sort  \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment/EW22/H3K27ac/EW22_A787C20_H3K27ac/EW22_A787C20_H3K27ac.sorted.bam && \
sambamba index  \
  alignment/EW22/H3K27ac/EW22_A787C20_H3K27ac/EW22_A787C20_H3K27ac.sorted.bam \
  alignment/EW22/H3K27ac/EW22_A787C20_H3K27ac/EW22_A787C20_H3K27ac.sorted.bam.bai
mapping_bwa_mem_sambamba.EW22_A787C20_H3K27ac.93dff004da118acf282d8830c056d13b.mugqic.done
chmod 755 $COMMAND
mapping_bwa_mem_sambamba_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 10 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$mapping_bwa_mem_sambamba_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$mapping_bwa_mem_sambamba_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: mapping_bwa_mem_sambamba_3_JOB_ID: mapping_bwa_mem_sambamba.EW3_1056C284_input
#-------------------------------------------------------------------------------
JOB_NAME=mapping_bwa_mem_sambamba.EW3_1056C284_input
JOB_DEPENDENCIES=$trimmomatic_3_JOB_ID
JOB_DONE=job_output/mapping_bwa_mem_sambamba/mapping_bwa_mem_sambamba.EW3_1056C284_input.a462472c90106986adffcc994ce3ae2e.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'mapping_bwa_mem_sambamba.EW3_1056C284_input.a462472c90106986adffcc994ce3ae2e.mugqic.done' > $COMMAND
module purge && \
module load mugqic/bwa/0.7.17 mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW3/input/EW3_1056C284_input && \
bwa mem -K 100000000 -v 3 -t 7 -Y \
   \
  -R '@RG\tID:EW3_1056C284_input\tSM:EW3\tLB:EW3\tPU:run2963_1\tCN:McGill University and Genome Quebec Innovation Centre\tPL:Illumina' \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/bwa_index/Homo_sapiens.hg19.fa \
  trim/EW3/input/EW3_1056C284_input.trim.single.fastq.gz | \
sambamba view -S -f bam \
  /dev/stdin \
    | \
sambamba sort  \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment/EW3/input/EW3_1056C284_input/EW3_1056C284_input.sorted.bam && \
sambamba index  \
  alignment/EW3/input/EW3_1056C284_input/EW3_1056C284_input.sorted.bam \
  alignment/EW3/input/EW3_1056C284_input/EW3_1056C284_input.sorted.bam.bai
mapping_bwa_mem_sambamba.EW3_1056C284_input.a462472c90106986adffcc994ce3ae2e.mugqic.done
chmod 755 $COMMAND
mapping_bwa_mem_sambamba_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 10 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$mapping_bwa_mem_sambamba_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$mapping_bwa_mem_sambamba_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: mapping_bwa_mem_sambamba_4_JOB_ID: mapping_bwa_mem_sambamba.EW3_A1056C287_H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=mapping_bwa_mem_sambamba.EW3_A1056C287_H3K27ac
JOB_DEPENDENCIES=$trimmomatic_4_JOB_ID
JOB_DONE=job_output/mapping_bwa_mem_sambamba/mapping_bwa_mem_sambamba.EW3_A1056C287_H3K27ac.8a04d65da40e6dfd175f29c090c7e0ff.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'mapping_bwa_mem_sambamba.EW3_A1056C287_H3K27ac.8a04d65da40e6dfd175f29c090c7e0ff.mugqic.done' > $COMMAND
module purge && \
module load mugqic/bwa/0.7.17 mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW3/H3K27ac/EW3_A1056C287_H3K27ac && \
bwa mem -K 100000000 -v 3 -t 7 -Y \
   \
  -R '@RG\tID:EW3_A1056C287_H3K27ac\tSM:EW3\tLB:EW3\tPU:run2964_1\tCN:McGill University and Genome Quebec Innovation Centre\tPL:Illumina' \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/bwa_index/Homo_sapiens.hg19.fa \
  trim/EW3/H3K27ac/EW3_A1056C287_H3K27ac.trim.single.fastq.gz | \
sambamba view -S -f bam \
  /dev/stdin \
    | \
sambamba sort  \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment/EW3/H3K27ac/EW3_A1056C287_H3K27ac/EW3_A1056C287_H3K27ac.sorted.bam && \
sambamba index  \
  alignment/EW3/H3K27ac/EW3_A1056C287_H3K27ac/EW3_A1056C287_H3K27ac.sorted.bam \
  alignment/EW3/H3K27ac/EW3_A1056C287_H3K27ac/EW3_A1056C287_H3K27ac.sorted.bam.bai
mapping_bwa_mem_sambamba.EW3_A1056C287_H3K27ac.8a04d65da40e6dfd175f29c090c7e0ff.mugqic.done
chmod 755 $COMMAND
mapping_bwa_mem_sambamba_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 10 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$mapping_bwa_mem_sambamba_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$mapping_bwa_mem_sambamba_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: mapping_bwa_mem_sambamba_5_JOB_ID: mapping_bwa_mem_sambamba.EW7_A485C51_input
#-------------------------------------------------------------------------------
JOB_NAME=mapping_bwa_mem_sambamba.EW7_A485C51_input
JOB_DEPENDENCIES=$trimmomatic_5_JOB_ID
JOB_DONE=job_output/mapping_bwa_mem_sambamba/mapping_bwa_mem_sambamba.EW7_A485C51_input.bd2b7c1659552685d4caf0fa866d4468.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'mapping_bwa_mem_sambamba.EW7_A485C51_input.bd2b7c1659552685d4caf0fa866d4468.mugqic.done' > $COMMAND
module purge && \
module load mugqic/bwa/0.7.17 mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW7/input/EW7_A485C51_input && \
bwa mem -K 100000000 -v 3 -t 7 -Y \
   \
  -R '@RG\tID:EW7_A485C51_input\tSM:EW7\tLB:EW7\tPU:run2966_1\tCN:McGill University and Genome Quebec Innovation Centre\tPL:Illumina' \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/bwa_index/Homo_sapiens.hg19.fa \
  trim/EW7/input/EW7_A485C51_input.trim.single.fastq.gz | \
sambamba view -S -f bam \
  /dev/stdin \
    | \
sambamba sort  \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment/EW7/input/EW7_A485C51_input/EW7_A485C51_input.sorted.bam && \
sambamba index  \
  alignment/EW7/input/EW7_A485C51_input/EW7_A485C51_input.sorted.bam \
  alignment/EW7/input/EW7_A485C51_input/EW7_A485C51_input.sorted.bam.bai
mapping_bwa_mem_sambamba.EW7_A485C51_input.bd2b7c1659552685d4caf0fa866d4468.mugqic.done
chmod 755 $COMMAND
mapping_bwa_mem_sambamba_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 10 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$mapping_bwa_mem_sambamba_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$mapping_bwa_mem_sambamba_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: mapping_bwa_mem_sambamba_6_JOB_ID: mapping_bwa_mem_sambamba.EW7_A490C39_H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=mapping_bwa_mem_sambamba.EW7_A490C39_H3K27ac
JOB_DEPENDENCIES=$trimmomatic_6_JOB_ID
JOB_DONE=job_output/mapping_bwa_mem_sambamba/mapping_bwa_mem_sambamba.EW7_A490C39_H3K27ac.0ca3336a07a9c69a3c8280390aebf6c1.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'mapping_bwa_mem_sambamba.EW7_A490C39_H3K27ac.0ca3336a07a9c69a3c8280390aebf6c1.mugqic.done' > $COMMAND
module purge && \
module load mugqic/bwa/0.7.17 mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW7/H3K27ac/EW7_A490C39_H3K27ac && \
bwa mem -K 100000000 -v 3 -t 7 -Y \
   \
  -R '@RG\tID:EW7_A490C39_H3K27ac\tSM:EW7\tLB:EW7\tPU:run2970_1\tCN:McGill University and Genome Quebec Innovation Centre\tPL:Illumina' \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/bwa_index/Homo_sapiens.hg19.fa \
  trim/EW7/H3K27ac/EW7_A490C39_H3K27ac.trim.single.fastq.gz | \
sambamba view -S -f bam \
  /dev/stdin \
    | \
sambamba sort  \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment/EW7/H3K27ac/EW7_A490C39_H3K27ac/EW7_A490C39_H3K27ac.sorted.bam && \
sambamba index  \
  alignment/EW7/H3K27ac/EW7_A490C39_H3K27ac/EW7_A490C39_H3K27ac.sorted.bam \
  alignment/EW7/H3K27ac/EW7_A490C39_H3K27ac/EW7_A490C39_H3K27ac.sorted.bam.bai
mapping_bwa_mem_sambamba.EW7_A490C39_H3K27ac.0ca3336a07a9c69a3c8280390aebf6c1.mugqic.done
chmod 755 $COMMAND
mapping_bwa_mem_sambamba_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 10 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$mapping_bwa_mem_sambamba_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$mapping_bwa_mem_sambamba_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: mapping_bwa_mem_sambamba_7_JOB_ID: mapping_bwa_mem_sambamba.TC71_A379C48_H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=mapping_bwa_mem_sambamba.TC71_A379C48_H3K27ac
JOB_DEPENDENCIES=$trimmomatic_7_JOB_ID
JOB_DONE=job_output/mapping_bwa_mem_sambamba/mapping_bwa_mem_sambamba.TC71_A379C48_H3K27ac.cff5477402568b3ac4deb5c7a1953d84.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'mapping_bwa_mem_sambamba.TC71_A379C48_H3K27ac.cff5477402568b3ac4deb5c7a1953d84.mugqic.done' > $COMMAND
module purge && \
module load mugqic/bwa/0.7.17 mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/TC71/H3K27ac/TC71_A379C48_H3K27ac && \
bwa mem -K 100000000 -v 3 -t 7 -Y \
   \
  -R '@RG\tID:TC71_A379C48_H3K27ac\tSM:TC71\tLB:TC71\tPU:run2980_1\tCN:McGill University and Genome Quebec Innovation Centre\tPL:Illumina' \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/bwa_index/Homo_sapiens.hg19.fa \
  trim/TC71/H3K27ac/TC71_A379C48_H3K27ac.trim.single.fastq.gz | \
sambamba view -S -f bam \
  /dev/stdin \
    | \
sambamba sort  \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment/TC71/H3K27ac/TC71_A379C48_H3K27ac/TC71_A379C48_H3K27ac.sorted.bam && \
sambamba index  \
  alignment/TC71/H3K27ac/TC71_A379C48_H3K27ac/TC71_A379C48_H3K27ac.sorted.bam \
  alignment/TC71/H3K27ac/TC71_A379C48_H3K27ac/TC71_A379C48_H3K27ac.sorted.bam.bai
mapping_bwa_mem_sambamba.TC71_A379C48_H3K27ac.cff5477402568b3ac4deb5c7a1953d84.mugqic.done
chmod 755 $COMMAND
mapping_bwa_mem_sambamba_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 10 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$mapping_bwa_mem_sambamba_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$mapping_bwa_mem_sambamba_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: mapping_bwa_mem_sambamba_8_JOB_ID: mapping_bwa_mem_sambamba.TC71_A379C51_input
#-------------------------------------------------------------------------------
JOB_NAME=mapping_bwa_mem_sambamba.TC71_A379C51_input
JOB_DEPENDENCIES=$trimmomatic_8_JOB_ID
JOB_DONE=job_output/mapping_bwa_mem_sambamba/mapping_bwa_mem_sambamba.TC71_A379C51_input.aa86f4787a68b6236ee5f141d7f4f0f9.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'mapping_bwa_mem_sambamba.TC71_A379C51_input.aa86f4787a68b6236ee5f141d7f4f0f9.mugqic.done' > $COMMAND
module purge && \
module load mugqic/bwa/0.7.17 mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/TC71/input/TC71_A379C51_input && \
bwa mem -K 100000000 -v 3 -t 7 -Y \
   \
  -R '@RG\tID:TC71_A379C51_input\tSM:TC71\tLB:TC71\tPU:run2981_1\tCN:McGill University and Genome Quebec Innovation Centre\tPL:Illumina' \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/bwa_index/Homo_sapiens.hg19.fa \
  trim/TC71/input/TC71_A379C51_input.trim.single.fastq.gz | \
sambamba view -S -f bam \
  /dev/stdin \
    | \
sambamba sort  \
  /dev/stdin \
  --tmpdir ${SLURM_TMPDIR} \
  --out alignment/TC71/input/TC71_A379C51_input/TC71_A379C51_input.sorted.bam && \
sambamba index  \
  alignment/TC71/input/TC71_A379C51_input/TC71_A379C51_input.sorted.bam \
  alignment/TC71/input/TC71_A379C51_input/TC71_A379C51_input.sorted.bam.bai
mapping_bwa_mem_sambamba.TC71_A379C51_input.aa86f4787a68b6236ee5f141d7f4f0f9.mugqic.done
chmod 755 $COMMAND
mapping_bwa_mem_sambamba_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"mapping_bwa_mem_sambamba\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 10 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$mapping_bwa_mem_sambamba_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$mapping_bwa_mem_sambamba_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: sambamba_merge_bam_files
#-------------------------------------------------------------------------------
STEP=sambamba_merge_bam_files
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: sambamba_merge_bam_files_1_JOB_ID: symlink_readset_sample_bam.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=symlink_readset_sample_bam.EW22.input
JOB_DEPENDENCIES=$mapping_bwa_mem_sambamba_1_JOB_ID
JOB_DONE=job_output/sambamba_merge_bam_files/symlink_readset_sample_bam.EW22.input.6db728fd461c0c4bd76281fdca9ecfc5.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'symlink_readset_sample_bam.EW22.input.6db728fd461c0c4bd76281fdca9ecfc5.mugqic.done' > $COMMAND
mkdir -p alignment/EW22/input && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW22/input/EW22_A787C17_input/EW22_A787C17_input.sorted.bam \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW22/input/EW22.input.sorted.bam && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW22/input/EW22_A787C17_input/EW22_A787C17_input.sorted.bam.bai \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW22/input/EW22.input.sorted.bam.bai
symlink_readset_sample_bam.EW22.input.6db728fd461c0c4bd76281fdca9ecfc5.mugqic.done
chmod 755 $COMMAND
sambamba_merge_bam_files_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_merge_bam_files_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_merge_bam_files_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_merge_bam_files_2_JOB_ID: symlink_readset_sample_bam.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=symlink_readset_sample_bam.EW22.H3K27ac
JOB_DEPENDENCIES=$mapping_bwa_mem_sambamba_2_JOB_ID
JOB_DONE=job_output/sambamba_merge_bam_files/symlink_readset_sample_bam.EW22.H3K27ac.25fad4946a4b78688692848d4c2f63dd.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'symlink_readset_sample_bam.EW22.H3K27ac.25fad4946a4b78688692848d4c2f63dd.mugqic.done' > $COMMAND
mkdir -p alignment/EW22/H3K27ac && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW22/H3K27ac/EW22_A787C20_H3K27ac/EW22_A787C20_H3K27ac.sorted.bam \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.bam && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW22/H3K27ac/EW22_A787C20_H3K27ac/EW22_A787C20_H3K27ac.sorted.bam.bai \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.bam.bai
symlink_readset_sample_bam.EW22.H3K27ac.25fad4946a4b78688692848d4c2f63dd.mugqic.done
chmod 755 $COMMAND
sambamba_merge_bam_files_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_merge_bam_files_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_merge_bam_files_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_merge_bam_files_3_JOB_ID: symlink_readset_sample_bam.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=symlink_readset_sample_bam.EW3.input
JOB_DEPENDENCIES=$mapping_bwa_mem_sambamba_3_JOB_ID
JOB_DONE=job_output/sambamba_merge_bam_files/symlink_readset_sample_bam.EW3.input.a5199d6cddb7a2710032bae58eae0ef4.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'symlink_readset_sample_bam.EW3.input.a5199d6cddb7a2710032bae58eae0ef4.mugqic.done' > $COMMAND
mkdir -p alignment/EW3/input && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW3/input/EW3_1056C284_input/EW3_1056C284_input.sorted.bam \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW3/input/EW3.input.sorted.bam && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW3/input/EW3_1056C284_input/EW3_1056C284_input.sorted.bam.bai \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW3/input/EW3.input.sorted.bam.bai
symlink_readset_sample_bam.EW3.input.a5199d6cddb7a2710032bae58eae0ef4.mugqic.done
chmod 755 $COMMAND
sambamba_merge_bam_files_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_merge_bam_files_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_merge_bam_files_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_merge_bam_files_4_JOB_ID: symlink_readset_sample_bam.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=symlink_readset_sample_bam.EW3.H3K27ac
JOB_DEPENDENCIES=$mapping_bwa_mem_sambamba_4_JOB_ID
JOB_DONE=job_output/sambamba_merge_bam_files/symlink_readset_sample_bam.EW3.H3K27ac.6168a43a8cc0e3c808c2e8921f07ccdb.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'symlink_readset_sample_bam.EW3.H3K27ac.6168a43a8cc0e3c808c2e8921f07ccdb.mugqic.done' > $COMMAND
mkdir -p alignment/EW3/H3K27ac && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW3/H3K27ac/EW3_A1056C287_H3K27ac/EW3_A1056C287_H3K27ac.sorted.bam \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.bam && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW3/H3K27ac/EW3_A1056C287_H3K27ac/EW3_A1056C287_H3K27ac.sorted.bam.bai \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.bam.bai
symlink_readset_sample_bam.EW3.H3K27ac.6168a43a8cc0e3c808c2e8921f07ccdb.mugqic.done
chmod 755 $COMMAND
sambamba_merge_bam_files_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_merge_bam_files_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_merge_bam_files_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_merge_bam_files_5_JOB_ID: symlink_readset_sample_bam.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=symlink_readset_sample_bam.EW7.input
JOB_DEPENDENCIES=$mapping_bwa_mem_sambamba_5_JOB_ID
JOB_DONE=job_output/sambamba_merge_bam_files/symlink_readset_sample_bam.EW7.input.2800ebe8a27199de5c15d01a39aa8672.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'symlink_readset_sample_bam.EW7.input.2800ebe8a27199de5c15d01a39aa8672.mugqic.done' > $COMMAND
mkdir -p alignment/EW7/input && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW7/input/EW7_A485C51_input/EW7_A485C51_input.sorted.bam \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW7/input/EW7.input.sorted.bam && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW7/input/EW7_A485C51_input/EW7_A485C51_input.sorted.bam.bai \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW7/input/EW7.input.sorted.bam.bai
symlink_readset_sample_bam.EW7.input.2800ebe8a27199de5c15d01a39aa8672.mugqic.done
chmod 755 $COMMAND
sambamba_merge_bam_files_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_merge_bam_files_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_merge_bam_files_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_merge_bam_files_6_JOB_ID: symlink_readset_sample_bam.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=symlink_readset_sample_bam.EW7.H3K27ac
JOB_DEPENDENCIES=$mapping_bwa_mem_sambamba_6_JOB_ID
JOB_DONE=job_output/sambamba_merge_bam_files/symlink_readset_sample_bam.EW7.H3K27ac.b4ae540f104289f0eb00f5b4082830fe.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'symlink_readset_sample_bam.EW7.H3K27ac.b4ae540f104289f0eb00f5b4082830fe.mugqic.done' > $COMMAND
mkdir -p alignment/EW7/H3K27ac && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW7/H3K27ac/EW7_A490C39_H3K27ac/EW7_A490C39_H3K27ac.sorted.bam \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.bam && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW7/H3K27ac/EW7_A490C39_H3K27ac/EW7_A490C39_H3K27ac.sorted.bam.bai \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.bam.bai
symlink_readset_sample_bam.EW7.H3K27ac.b4ae540f104289f0eb00f5b4082830fe.mugqic.done
chmod 755 $COMMAND
sambamba_merge_bam_files_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_merge_bam_files_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_merge_bam_files_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_merge_bam_files_7_JOB_ID: symlink_readset_sample_bam.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=symlink_readset_sample_bam.TC71.input
JOB_DEPENDENCIES=$mapping_bwa_mem_sambamba_8_JOB_ID
JOB_DONE=job_output/sambamba_merge_bam_files/symlink_readset_sample_bam.TC71.input.02261157c643ea282516b6d3cd817037.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'symlink_readset_sample_bam.TC71.input.02261157c643ea282516b6d3cd817037.mugqic.done' > $COMMAND
mkdir -p alignment/TC71/input && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/TC71/input/TC71_A379C51_input/TC71_A379C51_input.sorted.bam \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/TC71/input/TC71.input.sorted.bam && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/TC71/input/TC71_A379C51_input/TC71_A379C51_input.sorted.bam.bai \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/TC71/input/TC71.input.sorted.bam.bai
symlink_readset_sample_bam.TC71.input.02261157c643ea282516b6d3cd817037.mugqic.done
chmod 755 $COMMAND
sambamba_merge_bam_files_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_merge_bam_files_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_merge_bam_files_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_merge_bam_files_8_JOB_ID: symlink_readset_sample_bam.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=symlink_readset_sample_bam.TC71.H3K27ac
JOB_DEPENDENCIES=$mapping_bwa_mem_sambamba_7_JOB_ID
JOB_DONE=job_output/sambamba_merge_bam_files/symlink_readset_sample_bam.TC71.H3K27ac.9f871ab623569f817a03143de7969da6.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'symlink_readset_sample_bam.TC71.H3K27ac.9f871ab623569f817a03143de7969da6.mugqic.done' > $COMMAND
mkdir -p alignment/TC71/H3K27ac && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/TC71/H3K27ac/TC71_A379C48_H3K27ac/TC71_A379C48_H3K27ac.sorted.bam \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.bam && \
ln -s -f \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/TC71/H3K27ac/TC71_A379C48_H3K27ac/TC71_A379C48_H3K27ac.sorted.bam.bai \
  /lustre04/scratch/newtonma/chipseq_test_2/alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.bam.bai
symlink_readset_sample_bam.TC71.H3K27ac.9f871ab623569f817a03143de7969da6.mugqic.done
chmod 755 $COMMAND
sambamba_merge_bam_files_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_merge_bam_files\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_merge_bam_files_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_merge_bam_files_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: sambamba_mark_duplicates
#-------------------------------------------------------------------------------
STEP=sambamba_mark_duplicates
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_1_JOB_ID: sambamba_mark_duplicates.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates.EW22.input
JOB_DEPENDENCIES=$sambamba_merge_bam_files_1_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates.EW22.input.5d33f035a3ea602d7125c273b3eac2ae.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates.EW22.input.5d33f035a3ea602d7125c273b3eac2ae.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/sambamba/0.8.0 && \
mkdir -p alignment/EW22/input && \
sambamba markdup -t 4 --sort-buffer-size=8192 --io-buffer-size=1024 \
  alignment/EW22/input/EW22.input.sorted.bam \
  --tmpdir ${SLURM_TMPDIR} \
  alignment/EW22/input/EW22.input.sorted.dup.bam
sambamba_mark_duplicates.EW22.input.5d33f035a3ea602d7125c273b3eac2ae.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_2_JOB_ID: sambamba_mark_duplicates.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_merge_bam_files_2_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates.EW22.H3K27ac.a4e389a613481b86ead0139e2720ec5e.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates.EW22.H3K27ac.a4e389a613481b86ead0139e2720ec5e.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/sambamba/0.8.0 && \
mkdir -p alignment/EW22/H3K27ac && \
sambamba markdup -t 4 --sort-buffer-size=8192 --io-buffer-size=1024 \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.bam \
  --tmpdir ${SLURM_TMPDIR} \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.bam
sambamba_mark_duplicates.EW22.H3K27ac.a4e389a613481b86ead0139e2720ec5e.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_3_JOB_ID: sambamba_mark_duplicates.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates.EW3.input
JOB_DEPENDENCIES=$sambamba_merge_bam_files_3_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates.EW3.input.e39fdd9a560f1dd52684c06337a23ff1.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates.EW3.input.e39fdd9a560f1dd52684c06337a23ff1.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/sambamba/0.8.0 && \
mkdir -p alignment/EW3/input && \
sambamba markdup -t 4 --sort-buffer-size=8192 --io-buffer-size=1024 \
  alignment/EW3/input/EW3.input.sorted.bam \
  --tmpdir ${SLURM_TMPDIR} \
  alignment/EW3/input/EW3.input.sorted.dup.bam
sambamba_mark_duplicates.EW3.input.e39fdd9a560f1dd52684c06337a23ff1.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_4_JOB_ID: sambamba_mark_duplicates.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_merge_bam_files_4_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates.EW3.H3K27ac.ae8bde54f20de1dc4ddbb3328f96d39f.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates.EW3.H3K27ac.ae8bde54f20de1dc4ddbb3328f96d39f.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/sambamba/0.8.0 && \
mkdir -p alignment/EW3/H3K27ac && \
sambamba markdup -t 4 --sort-buffer-size=8192 --io-buffer-size=1024 \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.bam \
  --tmpdir ${SLURM_TMPDIR} \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.bam
sambamba_mark_duplicates.EW3.H3K27ac.ae8bde54f20de1dc4ddbb3328f96d39f.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_5_JOB_ID: sambamba_mark_duplicates.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates.EW7.input
JOB_DEPENDENCIES=$sambamba_merge_bam_files_5_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates.EW7.input.15c3a68c4c1c5e9e7d5e991c0cd010e9.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates.EW7.input.15c3a68c4c1c5e9e7d5e991c0cd010e9.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/sambamba/0.8.0 && \
mkdir -p alignment/EW7/input && \
sambamba markdup -t 4 --sort-buffer-size=8192 --io-buffer-size=1024 \
  alignment/EW7/input/EW7.input.sorted.bam \
  --tmpdir ${SLURM_TMPDIR} \
  alignment/EW7/input/EW7.input.sorted.dup.bam
sambamba_mark_duplicates.EW7.input.15c3a68c4c1c5e9e7d5e991c0cd010e9.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_6_JOB_ID: sambamba_mark_duplicates.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_merge_bam_files_6_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates.EW7.H3K27ac.69b9442c12ed5648c1d8520bb71979e5.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates.EW7.H3K27ac.69b9442c12ed5648c1d8520bb71979e5.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/sambamba/0.8.0 && \
mkdir -p alignment/EW7/H3K27ac && \
sambamba markdup -t 4 --sort-buffer-size=8192 --io-buffer-size=1024 \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.bam \
  --tmpdir ${SLURM_TMPDIR} \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.bam
sambamba_mark_duplicates.EW7.H3K27ac.69b9442c12ed5648c1d8520bb71979e5.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_7_JOB_ID: sambamba_mark_duplicates.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates.TC71.input
JOB_DEPENDENCIES=$sambamba_merge_bam_files_7_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates.TC71.input.6c584ea9ed0364eabc614e67d839ebab.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates.TC71.input.6c584ea9ed0364eabc614e67d839ebab.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/sambamba/0.8.0 && \
mkdir -p alignment/TC71/input && \
sambamba markdup -t 4 --sort-buffer-size=8192 --io-buffer-size=1024 \
  alignment/TC71/input/TC71.input.sorted.bam \
  --tmpdir ${SLURM_TMPDIR} \
  alignment/TC71/input/TC71.input.sorted.dup.bam
sambamba_mark_duplicates.TC71.input.6c584ea9ed0364eabc614e67d839ebab.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_8_JOB_ID: sambamba_mark_duplicates.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_merge_bam_files_8_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates.TC71.H3K27ac.1d8f9c42ab08e88e365c3aaf986ca317.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates.TC71.H3K27ac.1d8f9c42ab08e88e365c3aaf986ca317.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/sambamba/0.8.0 && \
mkdir -p alignment/TC71/H3K27ac && \
sambamba markdup -t 4 --sort-buffer-size=8192 --io-buffer-size=1024 \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.bam \
  --tmpdir ${SLURM_TMPDIR} \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.bam
sambamba_mark_duplicates.TC71.H3K27ac.1d8f9c42ab08e88e365c3aaf986ca317.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_mark_duplicates\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_mark_duplicates_9_JOB_ID: sambamba_mark_duplicates_report
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_mark_duplicates_report
JOB_DEPENDENCIES=$sambamba_mark_duplicates_1_JOB_ID:$sambamba_mark_duplicates_2_JOB_ID:$sambamba_mark_duplicates_3_JOB_ID:$sambamba_mark_duplicates_4_JOB_ID:$sambamba_mark_duplicates_5_JOB_ID:$sambamba_mark_duplicates_6_JOB_ID:$sambamba_mark_duplicates_7_JOB_ID:$sambamba_mark_duplicates_8_JOB_ID
JOB_DONE=job_output/sambamba_mark_duplicates/sambamba_mark_duplicates_report.58ada64a23c967f663e58da7684152c0.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_mark_duplicates_report.58ada64a23c967f663e58da7684152c0.mugqic.done' > $COMMAND
mkdir -p report/yaml && \
cp /home/newtonma/apps/genpipes/bfx/report/ChipSeq.sambamba_mark_duplicates.yaml report/yaml/ChipSeq.sambamba_mark_duplicates.yaml
sambamba_mark_duplicates_report.58ada64a23c967f663e58da7684152c0.mugqic.done
chmod 755 $COMMAND
sambamba_mark_duplicates_9_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=04:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_mark_duplicates_9_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_mark_duplicates_9_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: sambamba_view_filter
#-------------------------------------------------------------------------------
STEP=sambamba_view_filter
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_1_JOB_ID: sambamba_view_filter.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter.EW22.input
JOB_DEPENDENCIES=$sambamba_mark_duplicates_1_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter.EW22.input.fb2bff6ce222915cd25c3b4a443a0f14.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter.EW22.input.fb2bff6ce222915cd25c3b4a443a0f14.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW22/input && \
sambamba view -t 4 -f bam -F "not unmapped and not failed_quality_control and mapping_quality >= 20" \
  alignment/EW22/input/EW22.input.sorted.dup.bam \
  -o alignment/EW22/input/EW22.input.sorted.dup.filtered.bam  && \
sambamba index  \
  alignment/EW22/input/EW22.input.sorted.dup.filtered.bam \
  alignment/EW22/input/EW22.input.sorted.dup.filtered.bam.bai
sambamba_view_filter.EW22.input.fb2bff6ce222915cd25c3b4a443a0f14.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_2_JOB_ID: sambamba_view_filter.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_2_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter.EW22.H3K27ac.0a32a0223ecd910c160e4c6376dfa904.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter.EW22.H3K27ac.0a32a0223ecd910c160e4c6376dfa904.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW22/H3K27ac && \
sambamba view -t 4 -f bam -F "not unmapped and not failed_quality_control and mapping_quality >= 20" \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.bam \
  -o alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam  && \
sambamba index  \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam.bai
sambamba_view_filter.EW22.H3K27ac.0a32a0223ecd910c160e4c6376dfa904.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_3_JOB_ID: sambamba_view_filter.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter.EW3.input
JOB_DEPENDENCIES=$sambamba_mark_duplicates_3_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter.EW3.input.2569e90a5a63fdbf85545b509d4e3e18.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter.EW3.input.2569e90a5a63fdbf85545b509d4e3e18.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW3/input && \
sambamba view -t 4 -f bam -F "not unmapped and not failed_quality_control and mapping_quality >= 20" \
  alignment/EW3/input/EW3.input.sorted.dup.bam \
  -o alignment/EW3/input/EW3.input.sorted.dup.filtered.bam  && \
sambamba index  \
  alignment/EW3/input/EW3.input.sorted.dup.filtered.bam \
  alignment/EW3/input/EW3.input.sorted.dup.filtered.bam.bai
sambamba_view_filter.EW3.input.2569e90a5a63fdbf85545b509d4e3e18.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_4_JOB_ID: sambamba_view_filter.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_4_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter.EW3.H3K27ac.3201a64b19eb05236889c8650b76ec06.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter.EW3.H3K27ac.3201a64b19eb05236889c8650b76ec06.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW3/H3K27ac && \
sambamba view -t 4 -f bam -F "not unmapped and not failed_quality_control and mapping_quality >= 20" \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.bam \
  -o alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam  && \
sambamba index  \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam.bai
sambamba_view_filter.EW3.H3K27ac.3201a64b19eb05236889c8650b76ec06.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_5_JOB_ID: sambamba_view_filter.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter.EW7.input
JOB_DEPENDENCIES=$sambamba_mark_duplicates_5_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter.EW7.input.246de15d28079d9fe8e409458ea65441.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter.EW7.input.246de15d28079d9fe8e409458ea65441.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW7/input && \
sambamba view -t 4 -f bam -F "not unmapped and not failed_quality_control and mapping_quality >= 20" \
  alignment/EW7/input/EW7.input.sorted.dup.bam \
  -o alignment/EW7/input/EW7.input.sorted.dup.filtered.bam  && \
sambamba index  \
  alignment/EW7/input/EW7.input.sorted.dup.filtered.bam \
  alignment/EW7/input/EW7.input.sorted.dup.filtered.bam.bai
sambamba_view_filter.EW7.input.246de15d28079d9fe8e409458ea65441.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_6_JOB_ID: sambamba_view_filter.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_6_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter.EW7.H3K27ac.f1e704675980e6bc289a17398f11d302.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter.EW7.H3K27ac.f1e704675980e6bc289a17398f11d302.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/EW7/H3K27ac && \
sambamba view -t 4 -f bam -F "not unmapped and not failed_quality_control and mapping_quality >= 20" \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.bam \
  -o alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam  && \
sambamba index  \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam.bai
sambamba_view_filter.EW7.H3K27ac.f1e704675980e6bc289a17398f11d302.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_7_JOB_ID: sambamba_view_filter.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter.TC71.input
JOB_DEPENDENCIES=$sambamba_mark_duplicates_7_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter.TC71.input.805f9396a901e32efe5f578da60ba40b.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter.TC71.input.805f9396a901e32efe5f578da60ba40b.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/TC71/input && \
sambamba view -t 4 -f bam -F "not unmapped and not failed_quality_control and mapping_quality >= 20" \
  alignment/TC71/input/TC71.input.sorted.dup.bam \
  -o alignment/TC71/input/TC71.input.sorted.dup.filtered.bam  && \
sambamba index  \
  alignment/TC71/input/TC71.input.sorted.dup.filtered.bam \
  alignment/TC71/input/TC71.input.sorted.dup.filtered.bam.bai
sambamba_view_filter.TC71.input.805f9396a901e32efe5f578da60ba40b.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_8_JOB_ID: sambamba_view_filter.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_8_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter.TC71.H3K27ac.0cd9bab8b9fe34ecc1769c5b5ce4884d.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter.TC71.H3K27ac.0cd9bab8b9fe34ecc1769c5b5ce4884d.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 mugqic/samtools/1.12 && \
mkdir -p alignment/TC71/H3K27ac && \
sambamba view -t 4 -f bam -F "not unmapped and not failed_quality_control and mapping_quality >= 20" \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.bam \
  -o alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam  && \
sambamba index  \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam.bai
sambamba_view_filter.TC71.H3K27ac.0cd9bab8b9fe34ecc1769c5b5ce4884d.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"sambamba_view_filter\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: sambamba_view_filter_9_JOB_ID: sambamba_view_filter_report
#-------------------------------------------------------------------------------
JOB_NAME=sambamba_view_filter_report
JOB_DEPENDENCIES=$sambamba_view_filter_1_JOB_ID:$sambamba_view_filter_2_JOB_ID:$sambamba_view_filter_3_JOB_ID:$sambamba_view_filter_4_JOB_ID:$sambamba_view_filter_5_JOB_ID:$sambamba_view_filter_6_JOB_ID:$sambamba_view_filter_7_JOB_ID:$sambamba_view_filter_8_JOB_ID
JOB_DONE=job_output/sambamba_view_filter/sambamba_view_filter_report.df0c94d668c178ceeb2dc0dc0dcc8bde.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'sambamba_view_filter_report.df0c94d668c178ceeb2dc0dc0dcc8bde.mugqic.done' > $COMMAND
module purge && \
module load mugqic/pandoc/1.15.2 && \
mkdir -p report/yaml && \
sed -e 's@min_mapq@20@g' \
    /home/newtonma/apps/genpipes/bfx/report/ChipSeq.sambamba_view_filter.yaml > report/yaml/ChipSeq.sambamba_view_filter.yaml
sambamba_view_filter_report.df0c94d668c178ceeb2dc0dc0dcc8bde.mugqic.done
chmod 755 $COMMAND
sambamba_view_filter_9_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=04:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$sambamba_view_filter_9_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$sambamba_view_filter_9_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: metrics
#-------------------------------------------------------------------------------
STEP=metrics
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: metrics_1_JOB_ID: picard_collect_multiple_metrics.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=picard_collect_multiple_metrics.EW22.input
JOB_DEPENDENCIES=$sambamba_view_filter_1_JOB_ID
JOB_DONE=job_output/metrics/picard_collect_multiple_metrics.EW22.input.e083dc92c2d5671d3d759c9f66e17b10.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'picard_collect_multiple_metrics.EW22.input.e083dc92c2d5671d3d759c9f66e17b10.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.0.1 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p metrics/EW22/input && \
java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx8G -jar $PICARD_HOME/picard.jar CollectMultipleMetrics \
 PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectInsertSizeMetrics VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=${SLURM_TMPDIR} \
 REFERENCE_SEQUENCE=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa \
 INPUT=alignment/EW22/input/EW22.input.sorted.dup.filtered.bam \
 OUTPUT=metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics \
 MAX_RECORDS_IN_RAM=1000000
picard_collect_multiple_metrics.EW22.input.e083dc92c2d5671d3d759c9f66e17b10.mugqic.done
chmod 755 $COMMAND
metrics_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_2_JOB_ID: metrics_flagstat.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=metrics_flagstat.EW22.input
JOB_DEPENDENCIES=$sambamba_mark_duplicates_1_JOB_ID:$sambamba_view_filter_1_JOB_ID
JOB_DONE=job_output/metrics/metrics_flagstat.EW22.input.56a70ed574a097d234710de182f575ed.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_flagstat.EW22.input.56a70ed574a097d234710de182f575ed.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics/EW22/input && \
sambamba flagstat  \
  alignment/EW22/input/EW22.input.sorted.dup.bam \
  > metrics/EW22/input/EW22.input.sorted.dup.flagstat && \
sambamba flagstat  \
  alignment/EW22/input/EW22.input.sorted.dup.filtered.bam \
  > metrics/EW22/input/EW22.input.sorted.dup.filtered.flagstat
metrics_flagstat.EW22.input.56a70ed574a097d234710de182f575ed.mugqic.done
chmod 755 $COMMAND
metrics_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_3_JOB_ID: picard_collect_multiple_metrics.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=picard_collect_multiple_metrics.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_2_JOB_ID
JOB_DONE=job_output/metrics/picard_collect_multiple_metrics.EW22.H3K27ac.ad3c5fef5d32a0d4d3b38c918648d434.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'picard_collect_multiple_metrics.EW22.H3K27ac.ad3c5fef5d32a0d4d3b38c918648d434.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.0.1 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p metrics/EW22/H3K27ac && \
java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx8G -jar $PICARD_HOME/picard.jar CollectMultipleMetrics \
 PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectInsertSizeMetrics VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=${SLURM_TMPDIR} \
 REFERENCE_SEQUENCE=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa \
 INPUT=alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam \
 OUTPUT=metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics \
 MAX_RECORDS_IN_RAM=1000000
picard_collect_multiple_metrics.EW22.H3K27ac.ad3c5fef5d32a0d4d3b38c918648d434.mugqic.done
chmod 755 $COMMAND
metrics_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_4_JOB_ID: metrics_flagstat.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=metrics_flagstat.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_2_JOB_ID:$sambamba_view_filter_2_JOB_ID
JOB_DONE=job_output/metrics/metrics_flagstat.EW22.H3K27ac.32db70004f50c5e23f143621e0dc2180.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_flagstat.EW22.H3K27ac.32db70004f50c5e23f143621e0dc2180.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics/EW22/H3K27ac && \
sambamba flagstat  \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.bam \
  > metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.flagstat && \
sambamba flagstat  \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam \
  > metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.flagstat
metrics_flagstat.EW22.H3K27ac.32db70004f50c5e23f143621e0dc2180.mugqic.done
chmod 755 $COMMAND
metrics_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_5_JOB_ID: picard_collect_multiple_metrics.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=picard_collect_multiple_metrics.EW3.input
JOB_DEPENDENCIES=$sambamba_view_filter_3_JOB_ID
JOB_DONE=job_output/metrics/picard_collect_multiple_metrics.EW3.input.190ce131d5e854fd472a4d824e0f1fcb.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'picard_collect_multiple_metrics.EW3.input.190ce131d5e854fd472a4d824e0f1fcb.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.0.1 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p metrics/EW3/input && \
java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx8G -jar $PICARD_HOME/picard.jar CollectMultipleMetrics \
 PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectInsertSizeMetrics VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=${SLURM_TMPDIR} \
 REFERENCE_SEQUENCE=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa \
 INPUT=alignment/EW3/input/EW3.input.sorted.dup.filtered.bam \
 OUTPUT=metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics \
 MAX_RECORDS_IN_RAM=1000000
picard_collect_multiple_metrics.EW3.input.190ce131d5e854fd472a4d824e0f1fcb.mugqic.done
chmod 755 $COMMAND
metrics_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_6_JOB_ID: metrics_flagstat.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=metrics_flagstat.EW3.input
JOB_DEPENDENCIES=$sambamba_mark_duplicates_3_JOB_ID:$sambamba_view_filter_3_JOB_ID
JOB_DONE=job_output/metrics/metrics_flagstat.EW3.input.74047a34a01b857d4166be99438a6324.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_flagstat.EW3.input.74047a34a01b857d4166be99438a6324.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics/EW3/input && \
sambamba flagstat  \
  alignment/EW3/input/EW3.input.sorted.dup.bam \
  > metrics/EW3/input/EW3.input.sorted.dup.flagstat && \
sambamba flagstat  \
  alignment/EW3/input/EW3.input.sorted.dup.filtered.bam \
  > metrics/EW3/input/EW3.input.sorted.dup.filtered.flagstat
metrics_flagstat.EW3.input.74047a34a01b857d4166be99438a6324.mugqic.done
chmod 755 $COMMAND
metrics_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_7_JOB_ID: picard_collect_multiple_metrics.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=picard_collect_multiple_metrics.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_4_JOB_ID
JOB_DONE=job_output/metrics/picard_collect_multiple_metrics.EW3.H3K27ac.284addb460762974cb2dc93e27b8c8a6.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'picard_collect_multiple_metrics.EW3.H3K27ac.284addb460762974cb2dc93e27b8c8a6.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.0.1 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p metrics/EW3/H3K27ac && \
java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx8G -jar $PICARD_HOME/picard.jar CollectMultipleMetrics \
 PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectInsertSizeMetrics VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=${SLURM_TMPDIR} \
 REFERENCE_SEQUENCE=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa \
 INPUT=alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam \
 OUTPUT=metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics \
 MAX_RECORDS_IN_RAM=1000000
picard_collect_multiple_metrics.EW3.H3K27ac.284addb460762974cb2dc93e27b8c8a6.mugqic.done
chmod 755 $COMMAND
metrics_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_8_JOB_ID: metrics_flagstat.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=metrics_flagstat.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_4_JOB_ID:$sambamba_view_filter_4_JOB_ID
JOB_DONE=job_output/metrics/metrics_flagstat.EW3.H3K27ac.3f51e5307a720887b8677e3a322768e3.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_flagstat.EW3.H3K27ac.3f51e5307a720887b8677e3a322768e3.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics/EW3/H3K27ac && \
sambamba flagstat  \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.bam \
  > metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.flagstat && \
sambamba flagstat  \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam \
  > metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.flagstat
metrics_flagstat.EW3.H3K27ac.3f51e5307a720887b8677e3a322768e3.mugqic.done
chmod 755 $COMMAND
metrics_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_9_JOB_ID: picard_collect_multiple_metrics.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=picard_collect_multiple_metrics.EW7.input
JOB_DEPENDENCIES=$sambamba_view_filter_5_JOB_ID
JOB_DONE=job_output/metrics/picard_collect_multiple_metrics.EW7.input.c73ccca73ce8cab53046d1c079b66f76.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'picard_collect_multiple_metrics.EW7.input.c73ccca73ce8cab53046d1c079b66f76.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.0.1 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p metrics/EW7/input && \
java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx8G -jar $PICARD_HOME/picard.jar CollectMultipleMetrics \
 PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectInsertSizeMetrics VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=${SLURM_TMPDIR} \
 REFERENCE_SEQUENCE=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa \
 INPUT=alignment/EW7/input/EW7.input.sorted.dup.filtered.bam \
 OUTPUT=metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics \
 MAX_RECORDS_IN_RAM=1000000
picard_collect_multiple_metrics.EW7.input.c73ccca73ce8cab53046d1c079b66f76.mugqic.done
chmod 755 $COMMAND
metrics_9_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_9_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_9_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_10_JOB_ID: metrics_flagstat.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=metrics_flagstat.EW7.input
JOB_DEPENDENCIES=$sambamba_mark_duplicates_5_JOB_ID:$sambamba_view_filter_5_JOB_ID
JOB_DONE=job_output/metrics/metrics_flagstat.EW7.input.1bbc8f77fc4a951f3772ca8167c656f9.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_flagstat.EW7.input.1bbc8f77fc4a951f3772ca8167c656f9.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics/EW7/input && \
sambamba flagstat  \
  alignment/EW7/input/EW7.input.sorted.dup.bam \
  > metrics/EW7/input/EW7.input.sorted.dup.flagstat && \
sambamba flagstat  \
  alignment/EW7/input/EW7.input.sorted.dup.filtered.bam \
  > metrics/EW7/input/EW7.input.sorted.dup.filtered.flagstat
metrics_flagstat.EW7.input.1bbc8f77fc4a951f3772ca8167c656f9.mugqic.done
chmod 755 $COMMAND
metrics_10_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_10_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_10_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_11_JOB_ID: picard_collect_multiple_metrics.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=picard_collect_multiple_metrics.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_6_JOB_ID
JOB_DONE=job_output/metrics/picard_collect_multiple_metrics.EW7.H3K27ac.a1399893216247bc40e3853f975ba859.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'picard_collect_multiple_metrics.EW7.H3K27ac.a1399893216247bc40e3853f975ba859.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.0.1 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p metrics/EW7/H3K27ac && \
java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx8G -jar $PICARD_HOME/picard.jar CollectMultipleMetrics \
 PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectInsertSizeMetrics VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=${SLURM_TMPDIR} \
 REFERENCE_SEQUENCE=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa \
 INPUT=alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam \
 OUTPUT=metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics \
 MAX_RECORDS_IN_RAM=1000000
picard_collect_multiple_metrics.EW7.H3K27ac.a1399893216247bc40e3853f975ba859.mugqic.done
chmod 755 $COMMAND
metrics_11_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_11_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_11_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_12_JOB_ID: metrics_flagstat.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=metrics_flagstat.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_6_JOB_ID:$sambamba_view_filter_6_JOB_ID
JOB_DONE=job_output/metrics/metrics_flagstat.EW7.H3K27ac.c7329507cddf5777f01234c6ec3b1d89.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_flagstat.EW7.H3K27ac.c7329507cddf5777f01234c6ec3b1d89.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics/EW7/H3K27ac && \
sambamba flagstat  \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.bam \
  > metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.flagstat && \
sambamba flagstat  \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam \
  > metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.flagstat
metrics_flagstat.EW7.H3K27ac.c7329507cddf5777f01234c6ec3b1d89.mugqic.done
chmod 755 $COMMAND
metrics_12_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_12_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_12_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_13_JOB_ID: picard_collect_multiple_metrics.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=picard_collect_multiple_metrics.TC71.input
JOB_DEPENDENCIES=$sambamba_view_filter_7_JOB_ID
JOB_DONE=job_output/metrics/picard_collect_multiple_metrics.TC71.input.20bf2fa8027b9e24719ce0c9cbd56aa8.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'picard_collect_multiple_metrics.TC71.input.20bf2fa8027b9e24719ce0c9cbd56aa8.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.0.1 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p metrics/TC71/input && \
java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx8G -jar $PICARD_HOME/picard.jar CollectMultipleMetrics \
 PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectInsertSizeMetrics VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=${SLURM_TMPDIR} \
 REFERENCE_SEQUENCE=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa \
 INPUT=alignment/TC71/input/TC71.input.sorted.dup.filtered.bam \
 OUTPUT=metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics \
 MAX_RECORDS_IN_RAM=1000000
picard_collect_multiple_metrics.TC71.input.20bf2fa8027b9e24719ce0c9cbd56aa8.mugqic.done
chmod 755 $COMMAND
metrics_13_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_13_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_13_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_14_JOB_ID: metrics_flagstat.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=metrics_flagstat.TC71.input
JOB_DEPENDENCIES=$sambamba_mark_duplicates_7_JOB_ID:$sambamba_view_filter_7_JOB_ID
JOB_DONE=job_output/metrics/metrics_flagstat.TC71.input.b968cfda25a8add59c866af351590fbe.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_flagstat.TC71.input.b968cfda25a8add59c866af351590fbe.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics/TC71/input && \
sambamba flagstat  \
  alignment/TC71/input/TC71.input.sorted.dup.bam \
  > metrics/TC71/input/TC71.input.sorted.dup.flagstat && \
sambamba flagstat  \
  alignment/TC71/input/TC71.input.sorted.dup.filtered.bam \
  > metrics/TC71/input/TC71.input.sorted.dup.filtered.flagstat
metrics_flagstat.TC71.input.b968cfda25a8add59c866af351590fbe.mugqic.done
chmod 755 $COMMAND
metrics_14_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_14_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_14_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_15_JOB_ID: picard_collect_multiple_metrics.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=picard_collect_multiple_metrics.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_8_JOB_ID
JOB_DONE=job_output/metrics/picard_collect_multiple_metrics.TC71.H3K27ac.e05e70e2f54486451c2037922d65c2d6.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'picard_collect_multiple_metrics.TC71.H3K27ac.e05e70e2f54486451c2037922d65c2d6.mugqic.done' > $COMMAND
module purge && \
module load mugqic/java/openjdk-jdk1.8.0_72 mugqic/picard/2.0.1 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p metrics/TC71/H3K27ac && \
java -Djava.io.tmpdir=${SLURM_TMPDIR} -XX:ParallelGCThreads=1 -Dsamjdk.use_async_io=true -Dsamjdk.buffer_size=4194304 -Xmx8G -jar $PICARD_HOME/picard.jar CollectMultipleMetrics \
 PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectInsertSizeMetrics VALIDATION_STRINGENCY=SILENT \
 TMP_DIR=${SLURM_TMPDIR} \
 REFERENCE_SEQUENCE=/cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa \
 INPUT=alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam \
 OUTPUT=metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics \
 MAX_RECORDS_IN_RAM=1000000
picard_collect_multiple_metrics.TC71.H3K27ac.e05e70e2f54486451c2037922d65c2d6.mugqic.done
chmod 755 $COMMAND
metrics_15_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_15_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_15_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_16_JOB_ID: metrics_flagstat.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=metrics_flagstat.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_8_JOB_ID:$sambamba_view_filter_8_JOB_ID
JOB_DONE=job_output/metrics/metrics_flagstat.TC71.H3K27ac.41f145beff77b8d68f2991856c381324.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_flagstat.TC71.H3K27ac.41f145beff77b8d68f2991856c381324.mugqic.done' > $COMMAND
module purge && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics/TC71/H3K27ac && \
sambamba flagstat  \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.bam \
  > metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.flagstat && \
sambamba flagstat  \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam \
  > metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.flagstat
metrics_flagstat.TC71.H3K27ac.41f145beff77b8d68f2991856c381324.mugqic.done
chmod 755 $COMMAND
metrics_16_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=06:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_16_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_16_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: metrics_17_JOB_ID: metrics_report
#-------------------------------------------------------------------------------
JOB_NAME=metrics_report
JOB_DEPENDENCIES=$sambamba_view_filter_1_JOB_ID:$sambamba_view_filter_2_JOB_ID:$sambamba_view_filter_3_JOB_ID:$sambamba_view_filter_4_JOB_ID:$sambamba_view_filter_5_JOB_ID:$sambamba_view_filter_6_JOB_ID:$sambamba_view_filter_7_JOB_ID:$sambamba_view_filter_8_JOB_ID:$metrics_2_JOB_ID:$metrics_4_JOB_ID:$metrics_6_JOB_ID:$metrics_8_JOB_ID:$metrics_10_JOB_ID:$metrics_12_JOB_ID:$metrics_14_JOB_ID:$metrics_16_JOB_ID
JOB_DONE=job_output/metrics/metrics_report.6ed66189b66f8f2df29b997b5eaf0e5b.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'metrics_report.6ed66189b66f8f2df29b997b5eaf0e5b.mugqic.done' > $COMMAND
module purge && \
module load mugqic/pandoc/1.15.2 && \
module load mugqic/sambamba/0.8.0 && \
mkdir -p metrics
cp /dev/null metrics/SampleMetrics.tsv && \
declare -A samples_associative_array=(["EW22"]="input H3K27ac" ["EW3"]="input H3K27ac" ["EW7"]="input H3K27ac" ["TC71"]="input H3K27ac") && \
for sample in ${!samples_associative_array[@]}
do
  for mark_name in ${samples_associative_array[$sample]}
  do
    raw_flagstat_file=metrics/$sample/$mark_name/$sample.$mark_name.sorted.dup.flagstat
    filtered_flagstat_file=metrics/$sample/$mark_name/$sample.$mark_name.sorted.dup.filtered.flagstat
    bam_file=alignment/$sample/$mark_name/$sample.$mark_name.sorted.dup.filtered.bam
    raw_supplementarysecondary_reads=`bc <<< $(grep "secondary" $raw_flagstat_file | sed -e 's/ + [[:digit:]]* secondary.*//')+$(grep "supplementary" $raw_flagstat_file | sed -e 's/ + [[:digit:]]* supplementary.*//')`
    mapped_reads=`bc <<< $(grep "mapped (" $raw_flagstat_file | sed -e 's/ + [[:digit:]]* mapped (.*)//')-$raw_supplementarysecondary_reads`
    filtered_supplementarysecondary_reads=`bc <<< $(grep "secondary" $filtered_flagstat_file | sed -e 's/ + [[:digit:]]* secondary.*//')+$(grep "supplementary" $filtered_flagstat_file | sed -e 's/ + [[:digit:]]* supplementary.*//')`
    filtered_reads=`bc <<< $(grep "in total" $filtered_flagstat_file | sed -e 's/ + [[:digit:]]* in total .*//')-$filtered_supplementarysecondary_reads`
    filtered_mapped_reads=`bc <<< $(grep "mapped (" $filtered_flagstat_file | sed -e 's/ + [[:digit:]]* mapped (.*)//')-$filtered_supplementarysecondary_reads`
    filtered_mapped_rate=`echo "scale=4; 100*$filtered_mapped_reads/$filtered_reads" | bc -l`
    filtered_dup_reads=`grep "duplicates" $filtered_flagstat_file | sed -e 's/ + [[:digit:]]* duplicates$//'`
    filtered_dup_rate=`echo "scale=4; 100*$filtered_dup_reads/$filtered_mapped_reads" | bc -l`
    filtered_dedup_reads=`echo "$filtered_mapped_reads-$filtered_dup_reads" | bc -l`
    if [[ -s metrics/trimSampleTable.tsv ]]
      then
        raw_reads=$(grep -P "${sample}\t${mark_name}" metrics/trimSampleTable.tsv | cut -f 3)
        raw_trimmed_reads=`bc <<< $(grep "in total" $raw_flagstat_file | sed -e 's/ + [[:digit:]]* in total .*//')-$raw_supplementarysecondary_reads`
        mapped_reads_rate=`echo "scale=4; 100*$mapped_reads/$raw_trimmed_reads" | bc -l`
        raw_trimmed_rate=`echo "scale=4; 100*$raw_trimmed_reads/$raw_reads" | bc -l`
        filtered_rate=`echo "scale=4; 100*$filtered_reads/$raw_trimmed_reads" | bc -l`
      else
        raw_reads=`bc <<< $(grep "in total" $raw_flagstat_file | sed -e 's/ + [[:digit:]]* in total .*//')-$raw_supplementarysecondary_reads`
        raw_trimmed_reads="NULL"
        mapped_reads_rate=`echo "scale=4; 100*$mapped_reads/$raw_reads" | bc -l`
        raw_trimmed_rate="NULL"
        filtered_rate=`echo "scale=4; 100*$filtered_reads/$raw_reads" | bc -l`
    fi
    filtered_mito_reads=$(sambamba view -F "not duplicate" -c $bam_file chrM)
    filtered_mito_rate=$(echo "scale=4; 100*$filtered_mito_reads/$filtered_mapped_reads" | bc -l)
    echo -e "$sample\t$mark_name\t$raw_reads\t$raw_trimmed_reads\t$raw_trimmed_rate\t$mapped_reads\t$mapped_reads_rate\t$filtered_reads\t$filtered_rate\t$filtered_mapped_reads\t$filtered_mapped_rate\t$filtered_dup_reads\t$filtered_dup_rate\t$filtered_dedup_reads\t$filtered_mito_reads\t$filtered_mito_rate" >> metrics/SampleMetrics.tsv
  done
done && \
sed -i -e "1 i\Sample\tMark Name\tRaw Reads #\tRemaining Reads after Trimming #\tRemaining Reads after Trimming %\tAligned Trimmed Reads #\tAligned Trimmed Reads %\tRemaining Reads after Filtering #\tRemaining Reads after Filtering %\tAligned Filtered Reads #\tAligned Filtered Reads %\tDuplicate Reads #\tDuplicate Reads %\tFinal Aligned Reads # without Duplicates\tMitochondrial Reads #\tMitochondrial Reads %" metrics/SampleMetrics.tsv && \
mkdir -p report/yaml && \
cp metrics/SampleMetrics.tsv report/SampleMetrics.tsv && \
sed -e 's@report_metrics_file@report/SampleMetrics.tsv@g'\
    /home/newtonma/apps/genpipes/bfx/report/ChipSeq.metrics.yaml > report/yaml/ChipSeq.metrics.yaml
metrics_report.6ed66189b66f8f2df29b997b5eaf0e5b.mugqic.done
chmod 755 $COMMAND
metrics_17_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=03:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$metrics_17_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$metrics_17_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: homer_make_tag_directory
#-------------------------------------------------------------------------------
STEP=homer_make_tag_directory
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: homer_make_tag_directory_1_JOB_ID: homer_make_tag_directory.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_tag_directory.EW22.input
JOB_DEPENDENCIES=$sambamba_view_filter_1_JOB_ID
JOB_DONE=job_output/homer_make_tag_directory/homer_make_tag_directory.EW22.input.d75c0847aed0dd13dbab083bde3a8933.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_tag_directory.EW22.input.d75c0847aed0dd13dbab083bde3a8933.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/samtools/1.12 && \
makeTagDirectory tags/EW22/EW22.input \
            alignment/EW22/input/EW22.input.sorted.dup.filtered.bam \
            -genome hg19 \
            -checkGC \
 
homer_make_tag_directory.EW22.input.d75c0847aed0dd13dbab083bde3a8933.mugqic.done
chmod 755 $COMMAND
homer_make_tag_directory_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_tag_directory_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_tag_directory_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_tag_directory_2_JOB_ID: homer_make_tag_directory.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_tag_directory.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_2_JOB_ID
JOB_DONE=job_output/homer_make_tag_directory/homer_make_tag_directory.EW22.H3K27ac.d6751c63ef1f3d3bb4beccdd0c09d3f8.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_tag_directory.EW22.H3K27ac.d6751c63ef1f3d3bb4beccdd0c09d3f8.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/samtools/1.12 && \
makeTagDirectory tags/EW22/EW22.H3K27ac \
            alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam \
            -genome hg19 \
            -checkGC \
 
homer_make_tag_directory.EW22.H3K27ac.d6751c63ef1f3d3bb4beccdd0c09d3f8.mugqic.done
chmod 755 $COMMAND
homer_make_tag_directory_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_tag_directory_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_tag_directory_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_tag_directory_3_JOB_ID: homer_make_tag_directory.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_tag_directory.EW3.input
JOB_DEPENDENCIES=$sambamba_view_filter_3_JOB_ID
JOB_DONE=job_output/homer_make_tag_directory/homer_make_tag_directory.EW3.input.56a98a775219e47fd7580dc1bcc8d2a4.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_tag_directory.EW3.input.56a98a775219e47fd7580dc1bcc8d2a4.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/samtools/1.12 && \
makeTagDirectory tags/EW3/EW3.input \
            alignment/EW3/input/EW3.input.sorted.dup.filtered.bam \
            -genome hg19 \
            -checkGC \
 
homer_make_tag_directory.EW3.input.56a98a775219e47fd7580dc1bcc8d2a4.mugqic.done
chmod 755 $COMMAND
homer_make_tag_directory_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_tag_directory_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_tag_directory_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_tag_directory_4_JOB_ID: homer_make_tag_directory.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_tag_directory.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_4_JOB_ID
JOB_DONE=job_output/homer_make_tag_directory/homer_make_tag_directory.EW3.H3K27ac.5dc340ef1a9cb8b64bb11f816db5c635.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_tag_directory.EW3.H3K27ac.5dc340ef1a9cb8b64bb11f816db5c635.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/samtools/1.12 && \
makeTagDirectory tags/EW3/EW3.H3K27ac \
            alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam \
            -genome hg19 \
            -checkGC \
 
homer_make_tag_directory.EW3.H3K27ac.5dc340ef1a9cb8b64bb11f816db5c635.mugqic.done
chmod 755 $COMMAND
homer_make_tag_directory_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_tag_directory_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_tag_directory_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_tag_directory_5_JOB_ID: homer_make_tag_directory.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_tag_directory.EW7.input
JOB_DEPENDENCIES=$sambamba_view_filter_5_JOB_ID
JOB_DONE=job_output/homer_make_tag_directory/homer_make_tag_directory.EW7.input.b863b070f551ff0fb9c780a4d695c883.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_tag_directory.EW7.input.b863b070f551ff0fb9c780a4d695c883.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/samtools/1.12 && \
makeTagDirectory tags/EW7/EW7.input \
            alignment/EW7/input/EW7.input.sorted.dup.filtered.bam \
            -genome hg19 \
            -checkGC \
 
homer_make_tag_directory.EW7.input.b863b070f551ff0fb9c780a4d695c883.mugqic.done
chmod 755 $COMMAND
homer_make_tag_directory_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_tag_directory_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_tag_directory_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_tag_directory_6_JOB_ID: homer_make_tag_directory.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_tag_directory.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_6_JOB_ID
JOB_DONE=job_output/homer_make_tag_directory/homer_make_tag_directory.EW7.H3K27ac.b1621093d0b9fc5a1cc53032fb2c40d9.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_tag_directory.EW7.H3K27ac.b1621093d0b9fc5a1cc53032fb2c40d9.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/samtools/1.12 && \
makeTagDirectory tags/EW7/EW7.H3K27ac \
            alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam \
            -genome hg19 \
            -checkGC \
 
homer_make_tag_directory.EW7.H3K27ac.b1621093d0b9fc5a1cc53032fb2c40d9.mugqic.done
chmod 755 $COMMAND
homer_make_tag_directory_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_tag_directory_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_tag_directory_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_tag_directory_7_JOB_ID: homer_make_tag_directory.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_tag_directory.TC71.input
JOB_DEPENDENCIES=$sambamba_view_filter_7_JOB_ID
JOB_DONE=job_output/homer_make_tag_directory/homer_make_tag_directory.TC71.input.415670cb4bb10d3125029ebe2247f7cf.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_tag_directory.TC71.input.415670cb4bb10d3125029ebe2247f7cf.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/samtools/1.12 && \
makeTagDirectory tags/TC71/TC71.input \
            alignment/TC71/input/TC71.input.sorted.dup.filtered.bam \
            -genome hg19 \
            -checkGC \
 
homer_make_tag_directory.TC71.input.415670cb4bb10d3125029ebe2247f7cf.mugqic.done
chmod 755 $COMMAND
homer_make_tag_directory_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_tag_directory_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_tag_directory_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_tag_directory_8_JOB_ID: homer_make_tag_directory.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_tag_directory.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_8_JOB_ID
JOB_DONE=job_output/homer_make_tag_directory/homer_make_tag_directory.TC71.H3K27ac.f69a49f14deb5c5225a46c4079d99f93.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_tag_directory.TC71.H3K27ac.f69a49f14deb5c5225a46c4079d99f93.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/samtools/1.12 && \
makeTagDirectory tags/TC71/TC71.H3K27ac \
            alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam \
            -genome hg19 \
            -checkGC \
 
homer_make_tag_directory.TC71.H3K27ac.f69a49f14deb5c5225a46c4079d99f93.mugqic.done
chmod 755 $COMMAND
homer_make_tag_directory_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 2 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_tag_directory_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_tag_directory_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: qc_metrics
#-------------------------------------------------------------------------------
STEP=qc_metrics
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: qc_metrics_1_JOB_ID: qc_plots_R
#-------------------------------------------------------------------------------
JOB_NAME=qc_plots_R
JOB_DEPENDENCIES=$homer_make_tag_directory_1_JOB_ID:$homer_make_tag_directory_2_JOB_ID:$homer_make_tag_directory_3_JOB_ID:$homer_make_tag_directory_4_JOB_ID:$homer_make_tag_directory_5_JOB_ID:$homer_make_tag_directory_6_JOB_ID:$homer_make_tag_directory_7_JOB_ID:$homer_make_tag_directory_8_JOB_ID
JOB_DONE=job_output/qc_metrics/qc_plots_R.93ebd24692d0f5ed1fba1ebf3eb383f1.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'qc_plots_R.93ebd24692d0f5ed1fba1ebf3eb383f1.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p graphs && \
Rscript $R_TOOLS/chipSeqGenerateQCMetrics.R readset.chipseq.txt /lustre04/scratch/newtonma/chipseq_test_2 && \
mkdir -p report/yaml && \
cp /home/newtonma/apps/genpipes/bfx/report/ChipSeq.qc_metrics.yaml report/yaml/ChipSeq.qc_metrics.yaml && \
declare -A samples_associative_array=(["EW22"]="input H3K27ac" ["EW3"]="input H3K27ac" ["EW7"]="input H3K27ac" ["TC71"]="input H3K27ac") && \
for sample in ${!samples_associative_array[@]}
do
  for mark_name in ${samples_associative_array[$sample]}
  do
    cp --parents graphs/${sample}.${mark_name}_QC_Metrics.ps report/
    convert -rotate 90 graphs/${sample}.${mark_name}_QC_Metrics.ps report/graphs/${sample}.${mark_name}_QC_Metrics.png
    echo -e "    ![QC Metrics for Sample $sample and Mark $mark_name ([download high-res image](graphs/${sample}.${mark_name}_QC_Metrics.ps))](graphs/${sample}.${mark_name}_QC_Metrics.png)\n" >> report/yaml/ChipSeq.qc_metrics.yaml
  done
done
qc_plots_R.93ebd24692d0f5ed1fba1ebf3eb383f1.mugqic.done
chmod 755 $COMMAND
qc_metrics_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"qc_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"qc_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$qc_metrics_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$qc_metrics_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: homer_make_ucsc_file
#-------------------------------------------------------------------------------
STEP=homer_make_ucsc_file
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_1_JOB_ID: homer_make_ucsc_file.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file.EW22.input
JOB_DEPENDENCIES=$homer_make_tag_directory_1_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file.EW22.input.7d6e8e69ac92ffc344b691630457e049.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file.EW22.input.7d6e8e69ac92ffc344b691630457e049.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 && \
mkdir -p tracks/EW22/input && \
makeUCSCfile \
        tags/EW22/EW22.input > tracks/EW22/input/EW22.input.ucsc.bedGraph && \
        gzip -c tracks/EW22/input/EW22.input.ucsc.bedGraph > tracks/EW22/input/EW22.input.ucsc.bedGraph.gz
homer_make_ucsc_file.EW22.input.7d6e8e69ac92ffc344b691630457e049.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_2_JOB_ID: homer_make_ucsc_file_bigWig.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_bigWig.EW22.input
JOB_DEPENDENCIES=$homer_make_ucsc_file_1_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_bigWig.EW22.input.66899f6804e92d0cb1afa0f2bd8f3662.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_bigWig.EW22.input.66899f6804e92d0cb1afa0f2bd8f3662.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
mkdir -p tracks/EW22/input/bigWig && \
export TMPDIR=${SLURM_TMPDIR} && \
cat tracks/EW22/input/EW22.input.ucsc.bedGraph | head -n 1 > tracks/EW22/input/EW22.input.ucsc.bedGraph.head.tmp && \
cat tracks/EW22/input/EW22.input.ucsc.bedGraph | awk ' NR > 1 ' | sort  --temporary-directory=${SLURM_TMPDIR} -k1,1 -k2,2n | \
awk '{if($0 !~ /^[A-W]/) print ""$0; else print $0}' | grep -v "GL\|lambda\|pUC19\|KI\|\KN\|random"  | \
awk '{printf "%s\t%d\t%d\t%4.4g\n", $1,$2,$3,$4}' > tracks/EW22/input/EW22.input.ucsc.bedGraph.body.tmp && \
cat tracks/EW22/input/EW22.input.ucsc.bedGraph.head.tmp tracks/EW22/input/EW22.input.ucsc.bedGraph.body.tmp > tracks/EW22/input/EW22.input.ucsc.bedGraph.sorted && \
rm tracks/EW22/input/EW22.input.ucsc.bedGraph.head.tmp tracks/EW22/input/EW22.input.ucsc.bedGraph.body.tmp && \
bedGraphToBigWig \
  tracks/EW22/input/EW22.input.ucsc.bedGraph.sorted \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  tracks/EW22/input/bigWig/EW22.input.bw
homer_make_ucsc_file_bigWig.EW22.input.66899f6804e92d0cb1afa0f2bd8f3662.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_3_JOB_ID: homer_make_ucsc_file.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file.EW22.H3K27ac
JOB_DEPENDENCIES=$homer_make_tag_directory_2_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file.EW22.H3K27ac.49b488e75ffd205fdb6e35f8153b18b2.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file.EW22.H3K27ac.49b488e75ffd205fdb6e35f8153b18b2.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 && \
mkdir -p tracks/EW22/H3K27ac && \
makeUCSCfile \
        tags/EW22/EW22.H3K27ac > tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph && \
        gzip -c tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph > tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.gz
homer_make_ucsc_file.EW22.H3K27ac.49b488e75ffd205fdb6e35f8153b18b2.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_4_JOB_ID: homer_make_ucsc_file_bigWig.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_bigWig.EW22.H3K27ac
JOB_DEPENDENCIES=$homer_make_ucsc_file_3_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_bigWig.EW22.H3K27ac.32ee5e0fbcc65302ca4dc60629ab6931.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_bigWig.EW22.H3K27ac.32ee5e0fbcc65302ca4dc60629ab6931.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
mkdir -p tracks/EW22/H3K27ac/bigWig && \
export TMPDIR=${SLURM_TMPDIR} && \
cat tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph | head -n 1 > tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.head.tmp && \
cat tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph | awk ' NR > 1 ' | sort  --temporary-directory=${SLURM_TMPDIR} -k1,1 -k2,2n | \
awk '{if($0 !~ /^[A-W]/) print ""$0; else print $0}' | grep -v "GL\|lambda\|pUC19\|KI\|\KN\|random"  | \
awk '{printf "%s\t%d\t%d\t%4.4g\n", $1,$2,$3,$4}' > tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.body.tmp && \
cat tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.head.tmp tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.body.tmp > tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.sorted && \
rm tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.head.tmp tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.body.tmp && \
bedGraphToBigWig \
  tracks/EW22/H3K27ac/EW22.H3K27ac.ucsc.bedGraph.sorted \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  tracks/EW22/H3K27ac/bigWig/EW22.H3K27ac.bw
homer_make_ucsc_file_bigWig.EW22.H3K27ac.32ee5e0fbcc65302ca4dc60629ab6931.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_5_JOB_ID: homer_make_ucsc_file.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file.EW3.input
JOB_DEPENDENCIES=$homer_make_tag_directory_3_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file.EW3.input.8a2329ae7672d55b19bd263320b7b37c.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file.EW3.input.8a2329ae7672d55b19bd263320b7b37c.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 && \
mkdir -p tracks/EW3/input && \
makeUCSCfile \
        tags/EW3/EW3.input > tracks/EW3/input/EW3.input.ucsc.bedGraph && \
        gzip -c tracks/EW3/input/EW3.input.ucsc.bedGraph > tracks/EW3/input/EW3.input.ucsc.bedGraph.gz
homer_make_ucsc_file.EW3.input.8a2329ae7672d55b19bd263320b7b37c.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_6_JOB_ID: homer_make_ucsc_file_bigWig.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_bigWig.EW3.input
JOB_DEPENDENCIES=$homer_make_ucsc_file_5_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_bigWig.EW3.input.f451b3ef4e13230d2bf82983d13cf9f4.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_bigWig.EW3.input.f451b3ef4e13230d2bf82983d13cf9f4.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
mkdir -p tracks/EW3/input/bigWig && \
export TMPDIR=${SLURM_TMPDIR} && \
cat tracks/EW3/input/EW3.input.ucsc.bedGraph | head -n 1 > tracks/EW3/input/EW3.input.ucsc.bedGraph.head.tmp && \
cat tracks/EW3/input/EW3.input.ucsc.bedGraph | awk ' NR > 1 ' | sort  --temporary-directory=${SLURM_TMPDIR} -k1,1 -k2,2n | \
awk '{if($0 !~ /^[A-W]/) print ""$0; else print $0}' | grep -v "GL\|lambda\|pUC19\|KI\|\KN\|random"  | \
awk '{printf "%s\t%d\t%d\t%4.4g\n", $1,$2,$3,$4}' > tracks/EW3/input/EW3.input.ucsc.bedGraph.body.tmp && \
cat tracks/EW3/input/EW3.input.ucsc.bedGraph.head.tmp tracks/EW3/input/EW3.input.ucsc.bedGraph.body.tmp > tracks/EW3/input/EW3.input.ucsc.bedGraph.sorted && \
rm tracks/EW3/input/EW3.input.ucsc.bedGraph.head.tmp tracks/EW3/input/EW3.input.ucsc.bedGraph.body.tmp && \
bedGraphToBigWig \
  tracks/EW3/input/EW3.input.ucsc.bedGraph.sorted \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  tracks/EW3/input/bigWig/EW3.input.bw
homer_make_ucsc_file_bigWig.EW3.input.f451b3ef4e13230d2bf82983d13cf9f4.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_7_JOB_ID: homer_make_ucsc_file.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file.EW3.H3K27ac
JOB_DEPENDENCIES=$homer_make_tag_directory_4_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file.EW3.H3K27ac.ad3a827ed3ffb63132c3aebc30c1345f.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file.EW3.H3K27ac.ad3a827ed3ffb63132c3aebc30c1345f.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 && \
mkdir -p tracks/EW3/H3K27ac && \
makeUCSCfile \
        tags/EW3/EW3.H3K27ac > tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph && \
        gzip -c tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph > tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.gz
homer_make_ucsc_file.EW3.H3K27ac.ad3a827ed3ffb63132c3aebc30c1345f.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_8_JOB_ID: homer_make_ucsc_file_bigWig.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_bigWig.EW3.H3K27ac
JOB_DEPENDENCIES=$homer_make_ucsc_file_7_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_bigWig.EW3.H3K27ac.3efbcee5b441b69816d0b5d1ca892d9e.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_bigWig.EW3.H3K27ac.3efbcee5b441b69816d0b5d1ca892d9e.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
mkdir -p tracks/EW3/H3K27ac/bigWig && \
export TMPDIR=${SLURM_TMPDIR} && \
cat tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph | head -n 1 > tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.head.tmp && \
cat tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph | awk ' NR > 1 ' | sort  --temporary-directory=${SLURM_TMPDIR} -k1,1 -k2,2n | \
awk '{if($0 !~ /^[A-W]/) print ""$0; else print $0}' | grep -v "GL\|lambda\|pUC19\|KI\|\KN\|random"  | \
awk '{printf "%s\t%d\t%d\t%4.4g\n", $1,$2,$3,$4}' > tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.body.tmp && \
cat tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.head.tmp tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.body.tmp > tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.sorted && \
rm tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.head.tmp tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.body.tmp && \
bedGraphToBigWig \
  tracks/EW3/H3K27ac/EW3.H3K27ac.ucsc.bedGraph.sorted \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  tracks/EW3/H3K27ac/bigWig/EW3.H3K27ac.bw
homer_make_ucsc_file_bigWig.EW3.H3K27ac.3efbcee5b441b69816d0b5d1ca892d9e.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_9_JOB_ID: homer_make_ucsc_file.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file.EW7.input
JOB_DEPENDENCIES=$homer_make_tag_directory_5_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file.EW7.input.3c2d1ac475d38b8ba00a23cdd64deece.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file.EW7.input.3c2d1ac475d38b8ba00a23cdd64deece.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 && \
mkdir -p tracks/EW7/input && \
makeUCSCfile \
        tags/EW7/EW7.input > tracks/EW7/input/EW7.input.ucsc.bedGraph && \
        gzip -c tracks/EW7/input/EW7.input.ucsc.bedGraph > tracks/EW7/input/EW7.input.ucsc.bedGraph.gz
homer_make_ucsc_file.EW7.input.3c2d1ac475d38b8ba00a23cdd64deece.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_9_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_9_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_9_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_10_JOB_ID: homer_make_ucsc_file_bigWig.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_bigWig.EW7.input
JOB_DEPENDENCIES=$homer_make_ucsc_file_9_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_bigWig.EW7.input.24c9b355c77476bfc2d3166a69a35554.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_bigWig.EW7.input.24c9b355c77476bfc2d3166a69a35554.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
mkdir -p tracks/EW7/input/bigWig && \
export TMPDIR=${SLURM_TMPDIR} && \
cat tracks/EW7/input/EW7.input.ucsc.bedGraph | head -n 1 > tracks/EW7/input/EW7.input.ucsc.bedGraph.head.tmp && \
cat tracks/EW7/input/EW7.input.ucsc.bedGraph | awk ' NR > 1 ' | sort  --temporary-directory=${SLURM_TMPDIR} -k1,1 -k2,2n | \
awk '{if($0 !~ /^[A-W]/) print ""$0; else print $0}' | grep -v "GL\|lambda\|pUC19\|KI\|\KN\|random"  | \
awk '{printf "%s\t%d\t%d\t%4.4g\n", $1,$2,$3,$4}' > tracks/EW7/input/EW7.input.ucsc.bedGraph.body.tmp && \
cat tracks/EW7/input/EW7.input.ucsc.bedGraph.head.tmp tracks/EW7/input/EW7.input.ucsc.bedGraph.body.tmp > tracks/EW7/input/EW7.input.ucsc.bedGraph.sorted && \
rm tracks/EW7/input/EW7.input.ucsc.bedGraph.head.tmp tracks/EW7/input/EW7.input.ucsc.bedGraph.body.tmp && \
bedGraphToBigWig \
  tracks/EW7/input/EW7.input.ucsc.bedGraph.sorted \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  tracks/EW7/input/bigWig/EW7.input.bw
homer_make_ucsc_file_bigWig.EW7.input.24c9b355c77476bfc2d3166a69a35554.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_10_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_10_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_10_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_11_JOB_ID: homer_make_ucsc_file.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file.EW7.H3K27ac
JOB_DEPENDENCIES=$homer_make_tag_directory_6_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file.EW7.H3K27ac.1810cdd2fc7748290e28b0965aeb03bf.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file.EW7.H3K27ac.1810cdd2fc7748290e28b0965aeb03bf.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 && \
mkdir -p tracks/EW7/H3K27ac && \
makeUCSCfile \
        tags/EW7/EW7.H3K27ac > tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph && \
        gzip -c tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph > tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.gz
homer_make_ucsc_file.EW7.H3K27ac.1810cdd2fc7748290e28b0965aeb03bf.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_11_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_11_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_11_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_12_JOB_ID: homer_make_ucsc_file_bigWig.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_bigWig.EW7.H3K27ac
JOB_DEPENDENCIES=$homer_make_ucsc_file_11_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_bigWig.EW7.H3K27ac.3f44de0ee45aaf14515c19e018f2636b.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_bigWig.EW7.H3K27ac.3f44de0ee45aaf14515c19e018f2636b.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
mkdir -p tracks/EW7/H3K27ac/bigWig && \
export TMPDIR=${SLURM_TMPDIR} && \
cat tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph | head -n 1 > tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.head.tmp && \
cat tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph | awk ' NR > 1 ' | sort  --temporary-directory=${SLURM_TMPDIR} -k1,1 -k2,2n | \
awk '{if($0 !~ /^[A-W]/) print ""$0; else print $0}' | grep -v "GL\|lambda\|pUC19\|KI\|\KN\|random"  | \
awk '{printf "%s\t%d\t%d\t%4.4g\n", $1,$2,$3,$4}' > tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.body.tmp && \
cat tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.head.tmp tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.body.tmp > tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.sorted && \
rm tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.head.tmp tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.body.tmp && \
bedGraphToBigWig \
  tracks/EW7/H3K27ac/EW7.H3K27ac.ucsc.bedGraph.sorted \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  tracks/EW7/H3K27ac/bigWig/EW7.H3K27ac.bw
homer_make_ucsc_file_bigWig.EW7.H3K27ac.3f44de0ee45aaf14515c19e018f2636b.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_12_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_12_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_12_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_13_JOB_ID: homer_make_ucsc_file.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file.TC71.input
JOB_DEPENDENCIES=$homer_make_tag_directory_7_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file.TC71.input.e35fbbeca29e89ad8c2d11e0ffdd2b7e.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file.TC71.input.e35fbbeca29e89ad8c2d11e0ffdd2b7e.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 && \
mkdir -p tracks/TC71/input && \
makeUCSCfile \
        tags/TC71/TC71.input > tracks/TC71/input/TC71.input.ucsc.bedGraph && \
        gzip -c tracks/TC71/input/TC71.input.ucsc.bedGraph > tracks/TC71/input/TC71.input.ucsc.bedGraph.gz
homer_make_ucsc_file.TC71.input.e35fbbeca29e89ad8c2d11e0ffdd2b7e.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_13_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_13_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_13_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_14_JOB_ID: homer_make_ucsc_file_bigWig.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_bigWig.TC71.input
JOB_DEPENDENCIES=$homer_make_ucsc_file_13_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_bigWig.TC71.input.fcf536c84ea373101e5a40c197a62409.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_bigWig.TC71.input.fcf536c84ea373101e5a40c197a62409.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
mkdir -p tracks/TC71/input/bigWig && \
export TMPDIR=${SLURM_TMPDIR} && \
cat tracks/TC71/input/TC71.input.ucsc.bedGraph | head -n 1 > tracks/TC71/input/TC71.input.ucsc.bedGraph.head.tmp && \
cat tracks/TC71/input/TC71.input.ucsc.bedGraph | awk ' NR > 1 ' | sort  --temporary-directory=${SLURM_TMPDIR} -k1,1 -k2,2n | \
awk '{if($0 !~ /^[A-W]/) print ""$0; else print $0}' | grep -v "GL\|lambda\|pUC19\|KI\|\KN\|random"  | \
awk '{printf "%s\t%d\t%d\t%4.4g\n", $1,$2,$3,$4}' > tracks/TC71/input/TC71.input.ucsc.bedGraph.body.tmp && \
cat tracks/TC71/input/TC71.input.ucsc.bedGraph.head.tmp tracks/TC71/input/TC71.input.ucsc.bedGraph.body.tmp > tracks/TC71/input/TC71.input.ucsc.bedGraph.sorted && \
rm tracks/TC71/input/TC71.input.ucsc.bedGraph.head.tmp tracks/TC71/input/TC71.input.ucsc.bedGraph.body.tmp && \
bedGraphToBigWig \
  tracks/TC71/input/TC71.input.ucsc.bedGraph.sorted \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  tracks/TC71/input/bigWig/TC71.input.bw
homer_make_ucsc_file_bigWig.TC71.input.fcf536c84ea373101e5a40c197a62409.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_14_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_14_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_14_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_15_JOB_ID: homer_make_ucsc_file.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file.TC71.H3K27ac
JOB_DEPENDENCIES=$homer_make_tag_directory_8_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file.TC71.H3K27ac.d74d2c4f37622c6954689ffb9b5b67c2.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file.TC71.H3K27ac.d74d2c4f37622c6954689ffb9b5b67c2.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 && \
mkdir -p tracks/TC71/H3K27ac && \
makeUCSCfile \
        tags/TC71/TC71.H3K27ac > tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph && \
        gzip -c tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph > tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.gz
homer_make_ucsc_file.TC71.H3K27ac.d74d2c4f37622c6954689ffb9b5b67c2.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_15_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_15_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_15_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_16_JOB_ID: homer_make_ucsc_file_bigWig.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_bigWig.TC71.H3K27ac
JOB_DEPENDENCIES=$homer_make_ucsc_file_15_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_bigWig.TC71.H3K27ac.51af8c7600a24dc672828cdedce74b21.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_bigWig.TC71.H3K27ac.51af8c7600a24dc672828cdedce74b21.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
mkdir -p tracks/TC71/H3K27ac/bigWig && \
export TMPDIR=${SLURM_TMPDIR} && \
cat tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph | head -n 1 > tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.head.tmp && \
cat tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph | awk ' NR > 1 ' | sort  --temporary-directory=${SLURM_TMPDIR} -k1,1 -k2,2n | \
awk '{if($0 !~ /^[A-W]/) print ""$0; else print $0}' | grep -v "GL\|lambda\|pUC19\|KI\|\KN\|random"  | \
awk '{printf "%s\t%d\t%d\t%4.4g\n", $1,$2,$3,$4}' > tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.body.tmp && \
cat tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.head.tmp tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.body.tmp > tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.sorted && \
rm tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.head.tmp tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.body.tmp && \
bedGraphToBigWig \
  tracks/TC71/H3K27ac/TC71.H3K27ac.ucsc.bedGraph.sorted \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  tracks/TC71/H3K27ac/bigWig/TC71.H3K27ac.bw
homer_make_ucsc_file_bigWig.TC71.H3K27ac.51af8c7600a24dc672828cdedce74b21.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_16_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_make_ucsc_file\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_16_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_16_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_make_ucsc_file_17_JOB_ID: homer_make_ucsc_file_report
#-------------------------------------------------------------------------------
JOB_NAME=homer_make_ucsc_file_report
JOB_DEPENDENCIES=$homer_make_ucsc_file_1_JOB_ID:$homer_make_ucsc_file_3_JOB_ID:$homer_make_ucsc_file_5_JOB_ID:$homer_make_ucsc_file_7_JOB_ID:$homer_make_ucsc_file_9_JOB_ID:$homer_make_ucsc_file_11_JOB_ID:$homer_make_ucsc_file_13_JOB_ID:$homer_make_ucsc_file_15_JOB_ID
JOB_DONE=job_output/homer_make_ucsc_file/homer_make_ucsc_file_report.8fbdc1c2c320aab7e463e3a52bd8f02c.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_make_ucsc_file_report.8fbdc1c2c320aab7e463e3a52bd8f02c.mugqic.done' > $COMMAND
mkdir -p report/yaml && \
zip -r report/tracks.zip tracks/*/*/*.ucsc.bedGraph.gz && \
cp /home/newtonma/apps/genpipes/bfx/report/ChipSeq.homer_make_ucsc_file.yaml report/yaml/ChipSeq.homer_make_ucsc_file.yaml
homer_make_ucsc_file_report.8fbdc1c2c320aab7e463e3a52bd8f02c.mugqic.done
chmod 755 $COMMAND
homer_make_ucsc_file_17_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_make_ucsc_file_17_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_make_ucsc_file_17_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: macs2_callpeak
#-------------------------------------------------------------------------------
STEP=macs2_callpeak
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_1_JOB_ID: macs2_callpeak.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_1_JOB_ID:$sambamba_view_filter_2_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak.EW22.H3K27ac.4a4e441b11c5b4c8291d730ec6ad3139.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak.EW22.H3K27ac.4a4e441b11c5b4c8291d730ec6ad3139.mugqic.done' > $COMMAND
module purge && \
module load mugqic/python/3.7.3 mugqic/MACS2/2.2.7.1 && \
mkdir -p peak_call/EW22/H3K27ac && \
macs2 callpeak --format BAM --nomodel \
  --tempdir ${SLURM_TMPDIR} \
  --gsize 2509729011.2 \
  --treatment \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam \
  --control \
  alignment/EW22/input/EW22.input.sorted.dup.filtered.bam \
  --name peak_call/EW22/H3K27ac/EW22.H3K27ac \
  >& peak_call/EW22/H3K27ac/EW22.H3K27ac.diag.macs.out
macs2_callpeak.EW22.H3K27ac.4a4e441b11c5b4c8291d730ec6ad3139.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_2_JOB_ID: macs2_callpeak_bigBed.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak_bigBed.EW22.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_1_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak_bigBed.EW22.H3K27ac.939558725083c612d313358700e75db7.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak_bigBed.EW22.H3K27ac.939558725083c612d313358700e75db7.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
awk '{if ($9 > 1000) {$9 = 1000}; printf( "%s\t%s\t%s\t%s\t%0.f\n", $1,$2,$3,$4,$9)}' peak_call/EW22/H3K27ac/EW22.H3K27ac_peaks.narrowPeak > peak_call/EW22/H3K27ac/EW22.H3K27ac_peaks.narrowPeak.bed && \
bedToBigBed \
  peak_call/EW22/H3K27ac/EW22.H3K27ac_peaks.narrowPeak.bed \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  peak_call/EW22/H3K27ac/EW22.H3K27ac_peaks.narrowPeak.bb
macs2_callpeak_bigBed.EW22.H3K27ac.939558725083c612d313358700e75db7.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_3_JOB_ID: macs2_callpeak.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_3_JOB_ID:$sambamba_view_filter_4_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak.EW3.H3K27ac.5c07d547593c9710f0023639f818f2ad.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak.EW3.H3K27ac.5c07d547593c9710f0023639f818f2ad.mugqic.done' > $COMMAND
module purge && \
module load mugqic/python/3.7.3 mugqic/MACS2/2.2.7.1 && \
mkdir -p peak_call/EW3/H3K27ac && \
macs2 callpeak --format BAM --nomodel \
  --tempdir ${SLURM_TMPDIR} \
  --gsize 2509729011.2 \
  --treatment \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam \
  --control \
  alignment/EW3/input/EW3.input.sorted.dup.filtered.bam \
  --name peak_call/EW3/H3K27ac/EW3.H3K27ac \
  >& peak_call/EW3/H3K27ac/EW3.H3K27ac.diag.macs.out
macs2_callpeak.EW3.H3K27ac.5c07d547593c9710f0023639f818f2ad.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_4_JOB_ID: macs2_callpeak_bigBed.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak_bigBed.EW3.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_3_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak_bigBed.EW3.H3K27ac.1085d8d7f487c4efb35d2a84bfba7905.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak_bigBed.EW3.H3K27ac.1085d8d7f487c4efb35d2a84bfba7905.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
awk '{if ($9 > 1000) {$9 = 1000}; printf( "%s\t%s\t%s\t%s\t%0.f\n", $1,$2,$3,$4,$9)}' peak_call/EW3/H3K27ac/EW3.H3K27ac_peaks.narrowPeak > peak_call/EW3/H3K27ac/EW3.H3K27ac_peaks.narrowPeak.bed && \
bedToBigBed \
  peak_call/EW3/H3K27ac/EW3.H3K27ac_peaks.narrowPeak.bed \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  peak_call/EW3/H3K27ac/EW3.H3K27ac_peaks.narrowPeak.bb
macs2_callpeak_bigBed.EW3.H3K27ac.1085d8d7f487c4efb35d2a84bfba7905.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_5_JOB_ID: macs2_callpeak.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_5_JOB_ID:$sambamba_view_filter_6_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak.EW7.H3K27ac.a88f33b71c8c2f80fc4806af75dc3ee8.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak.EW7.H3K27ac.a88f33b71c8c2f80fc4806af75dc3ee8.mugqic.done' > $COMMAND
module purge && \
module load mugqic/python/3.7.3 mugqic/MACS2/2.2.7.1 && \
mkdir -p peak_call/EW7/H3K27ac && \
macs2 callpeak --format BAM --nomodel \
  --tempdir ${SLURM_TMPDIR} \
  --gsize 2509729011.2 \
  --treatment \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam \
  --control \
  alignment/EW7/input/EW7.input.sorted.dup.filtered.bam \
  --name peak_call/EW7/H3K27ac/EW7.H3K27ac \
  >& peak_call/EW7/H3K27ac/EW7.H3K27ac.diag.macs.out
macs2_callpeak.EW7.H3K27ac.a88f33b71c8c2f80fc4806af75dc3ee8.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_6_JOB_ID: macs2_callpeak_bigBed.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak_bigBed.EW7.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_5_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak_bigBed.EW7.H3K27ac.5718bc0fc6cd5a1ae2a1520f43576b52.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak_bigBed.EW7.H3K27ac.5718bc0fc6cd5a1ae2a1520f43576b52.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
awk '{if ($9 > 1000) {$9 = 1000}; printf( "%s\t%s\t%s\t%s\t%0.f\n", $1,$2,$3,$4,$9)}' peak_call/EW7/H3K27ac/EW7.H3K27ac_peaks.narrowPeak > peak_call/EW7/H3K27ac/EW7.H3K27ac_peaks.narrowPeak.bed && \
bedToBigBed \
  peak_call/EW7/H3K27ac/EW7.H3K27ac_peaks.narrowPeak.bed \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  peak_call/EW7/H3K27ac/EW7.H3K27ac_peaks.narrowPeak.bb
macs2_callpeak_bigBed.EW7.H3K27ac.5718bc0fc6cd5a1ae2a1520f43576b52.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_7_JOB_ID: macs2_callpeak.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_7_JOB_ID:$sambamba_view_filter_8_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak.TC71.H3K27ac.044a8f37d38b53cafbab646b630948de.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak.TC71.H3K27ac.044a8f37d38b53cafbab646b630948de.mugqic.done' > $COMMAND
module purge && \
module load mugqic/python/3.7.3 mugqic/MACS2/2.2.7.1 && \
mkdir -p peak_call/TC71/H3K27ac && \
macs2 callpeak --format BAM --nomodel \
  --tempdir ${SLURM_TMPDIR} \
  --gsize 2509729011.2 \
  --treatment \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam \
  --control \
  alignment/TC71/input/TC71.input.sorted.dup.filtered.bam \
  --name peak_call/TC71/H3K27ac/TC71.H3K27ac \
  >& peak_call/TC71/H3K27ac/TC71.H3K27ac.diag.macs.out
macs2_callpeak.TC71.H3K27ac.044a8f37d38b53cafbab646b630948de.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_8_JOB_ID: macs2_callpeak_bigBed.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak_bigBed.TC71.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_7_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak_bigBed.TC71.H3K27ac.a4f4c0109d35a051b5a4c97f29dc95b8.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak_bigBed.TC71.H3K27ac.a4f4c0109d35a051b5a4c97f29dc95b8.mugqic.done' > $COMMAND
module purge && \
module load mugqic/ucsc/v346 && \
awk '{if ($9 > 1000) {$9 = 1000}; printf( "%s\t%s\t%s\t%s\t%0.f\n", $1,$2,$3,$4,$9)}' peak_call/TC71/H3K27ac/TC71.H3K27ac_peaks.narrowPeak > peak_call/TC71/H3K27ac/TC71.H3K27ac_peaks.narrowPeak.bed && \
bedToBigBed \
  peak_call/TC71/H3K27ac/TC71.H3K27ac_peaks.narrowPeak.bed \
  /cvmfs/soft.mugqic/CentOS6/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa.fai \
  peak_call/TC71/H3K27ac/TC71.H3K27ac_peaks.narrowPeak.bb
macs2_callpeak_bigBed.TC71.H3K27ac.a4f4c0109d35a051b5a4c97f29dc95b8.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"macs2_callpeak\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: macs2_callpeak_9_JOB_ID: macs2_callpeak_report
#-------------------------------------------------------------------------------
JOB_NAME=macs2_callpeak_report
JOB_DEPENDENCIES=$macs2_callpeak_1_JOB_ID:$macs2_callpeak_3_JOB_ID:$macs2_callpeak_5_JOB_ID:$macs2_callpeak_7_JOB_ID
JOB_DONE=job_output/macs2_callpeak/macs2_callpeak_report.9935197568933feeccc7a983951980fa.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'macs2_callpeak_report.9935197568933feeccc7a983951980fa.mugqic.done' > $COMMAND
mkdir -p report/yaml && \
cp /home/newtonma/apps/genpipes/bfx/report/ChipSeq.macs2_callpeak.yaml report/yaml/ChipSeq.macs2_callpeak.yaml && \
declare -A samples_associative_array=(["EW22"]="H3K27ac" ["EW3"]="H3K27ac" ["EW7"]="H3K27ac" ["TC71"]="H3K27ac") && \
for sample in ${!samples_associative_array[@]}
do
  for mark_name in ${samples_associative_array[$sample]}
  do
    cp -a --parents peak_call/$sample/$mark_name/ report/ && \
    echo -e "    * [Peak Calls File for Sample $sample and Mark $mark_name](peak_call/$sample/$mark_name/${sample}.${mark_name}_peaks.xls)\n" >> report/yaml/ChipSeq.macs2_callpeak.yaml
  done
done
macs2_callpeak_report.9935197568933feeccc7a983951980fa.mugqic.done
chmod 755 $COMMAND
macs2_callpeak_9_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$macs2_callpeak_9_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$macs2_callpeak_9_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: homer_annotate_peaks
#-------------------------------------------------------------------------------
STEP=homer_annotate_peaks
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: homer_annotate_peaks_1_JOB_ID: homer_annotate_peaks.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_annotate_peaks.EW22.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_1_JOB_ID
JOB_DONE=job_output/homer_annotate_peaks/homer_annotate_peaks.EW22.H3K27ac.3e2d4fd3d4d286e3de650c83a04f55e2.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_annotate_peaks.EW22.H3K27ac.3e2d4fd3d4d286e3de650c83a04f55e2.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/mugqic_tools/2.6.0 && \
mkdir -p annotation/EW22/H3K27ac && \
annotatePeaks.pl \
    peak_call/EW22/H3K27ac/EW22.H3K27ac_peaks.narrowPeak \
    hg19 \
    -gsize hg19 \
    -cons -CpG \
    -go annotation/EW22/H3K27ac \
    -genomeOntology annotation/EW22/H3K27ac \
    > annotation/EW22/H3K27ac/EW22.H3K27ac.annotated.csv && \
perl -MReadMetrics -e 'ReadMetrics::parseHomerAnnotations(
  "annotation/EW22/H3K27ac/EW22.H3K27ac.annotated.csv",
  "annotation/EW22/H3K27ac/EW22.H3K27ac",
  -2000,
  -10000,
  -10000,
  -100000,
  100000
)'
homer_annotate_peaks.EW22.H3K27ac.3e2d4fd3d4d286e3de650c83a04f55e2.mugqic.done
chmod 755 $COMMAND
homer_annotate_peaks_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_annotate_peaks\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_annotate_peaks\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_annotate_peaks_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_annotate_peaks_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_annotate_peaks_2_JOB_ID: homer_annotate_peaks.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_annotate_peaks.EW3.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_3_JOB_ID
JOB_DONE=job_output/homer_annotate_peaks/homer_annotate_peaks.EW3.H3K27ac.1b9def29e94db906d4d2a67e34447b2b.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_annotate_peaks.EW3.H3K27ac.1b9def29e94db906d4d2a67e34447b2b.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/mugqic_tools/2.6.0 && \
mkdir -p annotation/EW3/H3K27ac && \
annotatePeaks.pl \
    peak_call/EW3/H3K27ac/EW3.H3K27ac_peaks.narrowPeak \
    hg19 \
    -gsize hg19 \
    -cons -CpG \
    -go annotation/EW3/H3K27ac \
    -genomeOntology annotation/EW3/H3K27ac \
    > annotation/EW3/H3K27ac/EW3.H3K27ac.annotated.csv && \
perl -MReadMetrics -e 'ReadMetrics::parseHomerAnnotations(
  "annotation/EW3/H3K27ac/EW3.H3K27ac.annotated.csv",
  "annotation/EW3/H3K27ac/EW3.H3K27ac",
  -2000,
  -10000,
  -10000,
  -100000,
  100000
)'
homer_annotate_peaks.EW3.H3K27ac.1b9def29e94db906d4d2a67e34447b2b.mugqic.done
chmod 755 $COMMAND
homer_annotate_peaks_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_annotate_peaks\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_annotate_peaks\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_annotate_peaks_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_annotate_peaks_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_annotate_peaks_3_JOB_ID: homer_annotate_peaks.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_annotate_peaks.EW7.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_5_JOB_ID
JOB_DONE=job_output/homer_annotate_peaks/homer_annotate_peaks.EW7.H3K27ac.ee69ef83cb2ee6ecdb79a8068b1b0445.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_annotate_peaks.EW7.H3K27ac.ee69ef83cb2ee6ecdb79a8068b1b0445.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/mugqic_tools/2.6.0 && \
mkdir -p annotation/EW7/H3K27ac && \
annotatePeaks.pl \
    peak_call/EW7/H3K27ac/EW7.H3K27ac_peaks.narrowPeak \
    hg19 \
    -gsize hg19 \
    -cons -CpG \
    -go annotation/EW7/H3K27ac \
    -genomeOntology annotation/EW7/H3K27ac \
    > annotation/EW7/H3K27ac/EW7.H3K27ac.annotated.csv && \
perl -MReadMetrics -e 'ReadMetrics::parseHomerAnnotations(
  "annotation/EW7/H3K27ac/EW7.H3K27ac.annotated.csv",
  "annotation/EW7/H3K27ac/EW7.H3K27ac",
  -2000,
  -10000,
  -10000,
  -100000,
  100000
)'
homer_annotate_peaks.EW7.H3K27ac.ee69ef83cb2ee6ecdb79a8068b1b0445.mugqic.done
chmod 755 $COMMAND
homer_annotate_peaks_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_annotate_peaks\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_annotate_peaks\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_annotate_peaks_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_annotate_peaks_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_annotate_peaks_4_JOB_ID: homer_annotate_peaks.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_annotate_peaks.TC71.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_7_JOB_ID
JOB_DONE=job_output/homer_annotate_peaks/homer_annotate_peaks.TC71.H3K27ac.8dd25f74b47b643599a2ec43b8c32450.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_annotate_peaks.TC71.H3K27ac.8dd25f74b47b643599a2ec43b8c32450.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/mugqic_tools/2.6.0 && \
mkdir -p annotation/TC71/H3K27ac && \
annotatePeaks.pl \
    peak_call/TC71/H3K27ac/TC71.H3K27ac_peaks.narrowPeak \
    hg19 \
    -gsize hg19 \
    -cons -CpG \
    -go annotation/TC71/H3K27ac \
    -genomeOntology annotation/TC71/H3K27ac \
    > annotation/TC71/H3K27ac/TC71.H3K27ac.annotated.csv && \
perl -MReadMetrics -e 'ReadMetrics::parseHomerAnnotations(
  "annotation/TC71/H3K27ac/TC71.H3K27ac.annotated.csv",
  "annotation/TC71/H3K27ac/TC71.H3K27ac",
  -2000,
  -10000,
  -10000,
  -100000,
  100000
)'
homer_annotate_peaks.TC71.H3K27ac.8dd25f74b47b643599a2ec43b8c32450.mugqic.done
chmod 755 $COMMAND
homer_annotate_peaks_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_annotate_peaks\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_annotate_peaks\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_annotate_peaks_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_annotate_peaks_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_annotate_peaks_5_JOB_ID: homer_annotate_peaks_report
#-------------------------------------------------------------------------------
JOB_NAME=homer_annotate_peaks_report
JOB_DEPENDENCIES=$homer_annotate_peaks_1_JOB_ID:$homer_annotate_peaks_2_JOB_ID:$homer_annotate_peaks_3_JOB_ID:$homer_annotate_peaks_4_JOB_ID
JOB_DONE=job_output/homer_annotate_peaks/homer_annotate_peaks_report.0e9f77251cd8ec6ecaddab595e53effc.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_annotate_peaks_report.0e9f77251cd8ec6ecaddab595e53effc.mugqic.done' > $COMMAND
mkdir -p report/annotation/ && \
mkdir -p report/yaml && \
cp /home/newtonma/apps/genpipes/bfx/report/ChipSeq.homer_annotate_peaks.yaml report/yaml/ChipSeq.homer_annotate_peaks.yaml && \
declare -A samples_associative_array=(["EW22"]="H3K27ac" ["EW3"]="H3K27ac" ["EW7"]="H3K27ac" ["TC71"]="H3K27ac") && \
for sample in ${!samples_associative_array[@]}
do
  for mark_name in ${samples_associative_array[$sample]}
  do
    rsync -rvP annotation/$sample report/annotation/ && \
    echo -e "    * [Gene Annotations for Sample $sample and Mark $mark_name](annotation/$sample/$mark_name/${sample}.${mark_name}.annotated.csv)\n    * [HOMER Gene Ontology Annotations for Sample $sample and Mark $mark_name](annotation/$sample/$mark_name/geneOntology.html)\n    * [HOMER Genome Ontology Annotations for Sample $sample and Mark $mark_name](annotation/$sample/$mark_name/GenomeOntology.html)\n" >> report/yaml/ChipSeq.homer_annotate_peaks.yaml
  done
done
homer_annotate_peaks_report.0e9f77251cd8ec6ecaddab595e53effc.mugqic.done
chmod 755 $COMMAND
homer_annotate_peaks_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=04:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_annotate_peaks_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_annotate_peaks_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: homer_find_motifs_genome
#-------------------------------------------------------------------------------
STEP=homer_find_motifs_genome
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: homer_find_motifs_genome_1_JOB_ID: homer_find_motifs_genome.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_find_motifs_genome.EW22.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_1_JOB_ID
JOB_DONE=job_output/homer_find_motifs_genome/homer_find_motifs_genome.EW22.H3K27ac.b49b6bac28befeb20c54dd6e438b5f0f.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_find_motifs_genome.EW22.H3K27ac.b49b6bac28befeb20c54dd6e438b5f0f.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/weblogo/3.3 && \
mkdir -p annotation/EW22/H3K27ac && \
findMotifsGenome.pl \
  peak_call/EW22/H3K27ac/EW22.H3K27ac_peaks.narrowPeak \
  hg19 \
  annotation/EW22/H3K27ac \
  -preparsedDir annotation/EW22/H3K27ac/preparsed \
  -p 4
homer_find_motifs_genome.EW22.H3K27ac.b49b6bac28befeb20c54dd6e438b5f0f.mugqic.done
chmod 755 $COMMAND
homer_find_motifs_genome_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_find_motifs_genome\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_find_motifs_genome\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_find_motifs_genome_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_find_motifs_genome_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_find_motifs_genome_2_JOB_ID: homer_find_motifs_genome.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_find_motifs_genome.EW3.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_3_JOB_ID
JOB_DONE=job_output/homer_find_motifs_genome/homer_find_motifs_genome.EW3.H3K27ac.8016fb5fda407edcfc98852141a19bed.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_find_motifs_genome.EW3.H3K27ac.8016fb5fda407edcfc98852141a19bed.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/weblogo/3.3 && \
mkdir -p annotation/EW3/H3K27ac && \
findMotifsGenome.pl \
  peak_call/EW3/H3K27ac/EW3.H3K27ac_peaks.narrowPeak \
  hg19 \
  annotation/EW3/H3K27ac \
  -preparsedDir annotation/EW3/H3K27ac/preparsed \
  -p 4
homer_find_motifs_genome.EW3.H3K27ac.8016fb5fda407edcfc98852141a19bed.mugqic.done
chmod 755 $COMMAND
homer_find_motifs_genome_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_find_motifs_genome\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_find_motifs_genome\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_find_motifs_genome_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_find_motifs_genome_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_find_motifs_genome_3_JOB_ID: homer_find_motifs_genome.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_find_motifs_genome.EW7.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_5_JOB_ID
JOB_DONE=job_output/homer_find_motifs_genome/homer_find_motifs_genome.EW7.H3K27ac.08560f9f9389cd6138c03f67eb5f863b.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_find_motifs_genome.EW7.H3K27ac.08560f9f9389cd6138c03f67eb5f863b.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/weblogo/3.3 && \
mkdir -p annotation/EW7/H3K27ac && \
findMotifsGenome.pl \
  peak_call/EW7/H3K27ac/EW7.H3K27ac_peaks.narrowPeak \
  hg19 \
  annotation/EW7/H3K27ac \
  -preparsedDir annotation/EW7/H3K27ac/preparsed \
  -p 4
homer_find_motifs_genome.EW7.H3K27ac.08560f9f9389cd6138c03f67eb5f863b.mugqic.done
chmod 755 $COMMAND
homer_find_motifs_genome_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_find_motifs_genome\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_find_motifs_genome\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_find_motifs_genome_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_find_motifs_genome_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_find_motifs_genome_4_JOB_ID: homer_find_motifs_genome.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=homer_find_motifs_genome.TC71.H3K27ac
JOB_DEPENDENCIES=$macs2_callpeak_7_JOB_ID
JOB_DONE=job_output/homer_find_motifs_genome/homer_find_motifs_genome.TC71.H3K27ac.dd80bbf275ddcb0f3d69d81261ffd615.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_find_motifs_genome.TC71.H3K27ac.dd80bbf275ddcb0f3d69d81261ffd615.mugqic.done' > $COMMAND
module purge && \
module load mugqic/perl/5.22.1 mugqic/homer/4.11 mugqic/weblogo/3.3 && \
mkdir -p annotation/TC71/H3K27ac && \
findMotifsGenome.pl \
  peak_call/TC71/H3K27ac/TC71.H3K27ac_peaks.narrowPeak \
  hg19 \
  annotation/TC71/H3K27ac \
  -preparsedDir annotation/TC71/H3K27ac/preparsed \
  -p 4
homer_find_motifs_genome.TC71.H3K27ac.dd80bbf275ddcb0f3d69d81261ffd615.mugqic.done
chmod 755 $COMMAND
homer_find_motifs_genome_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_find_motifs_genome\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"homer_find_motifs_genome\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 4 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_find_motifs_genome_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_find_motifs_genome_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: homer_find_motifs_genome_5_JOB_ID: homer_find_motifs_genome_report
#-------------------------------------------------------------------------------
JOB_NAME=homer_find_motifs_genome_report
JOB_DEPENDENCIES=$homer_find_motifs_genome_1_JOB_ID:$homer_find_motifs_genome_2_JOB_ID:$homer_find_motifs_genome_3_JOB_ID:$homer_find_motifs_genome_4_JOB_ID
JOB_DONE=job_output/homer_find_motifs_genome/homer_find_motifs_genome_report.91bbe85dabb8510a62410f8e2235e8a8.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'homer_find_motifs_genome_report.91bbe85dabb8510a62410f8e2235e8a8.mugqic.done' > $COMMAND
mkdir -p report/annotation/ && \
mkdir -p report/yaml && \
cp /home/newtonma/apps/genpipes/bfx/report/ChipSeq.homer_find_motifs_genome.yaml report/yaml/ChipSeq.homer_find_motifs_genome.yaml && \
declare -A samples_associative_array=(["EW22"]="H3K27ac" ["EW3"]="H3K27ac" ["EW7"]="H3K27ac" ["TC71"]="H3K27ac") && \
for sample in ${!samples_associative_array[@]}
do
  for mark_name in ${samples_associative_array[$sample]}
  do
    rsync -rvP annotation/$sample report/annotation/ && \
    echo -e "    * [HOMER _De Novo_ Motif Results for Sample $sample and Mark $mark_name](annotation/$sample/$mark_name/homerResults.html)\n\t* [HOMER Known Motif Results for Sample $sample and Mark $mark_name](annotation/$sample/$mark_name/knownResults.html)\n" >> report/yaml/ChipSeq.homer_find_motifs_genome.yaml
  done
done
homer_find_motifs_genome_report.91bbe85dabb8510a62410f8e2235e8a8.mugqic.done
chmod 755 $COMMAND
homer_find_motifs_genome_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=04:00:0 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$homer_find_motifs_genome_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$homer_find_motifs_genome_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: annotation_graphs
#-------------------------------------------------------------------------------
STEP=annotation_graphs
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: annotation_graphs_1_JOB_ID: annotation_graphs
#-------------------------------------------------------------------------------
JOB_NAME=annotation_graphs
JOB_DEPENDENCIES=$homer_annotate_peaks_1_JOB_ID:$homer_annotate_peaks_2_JOB_ID:$homer_annotate_peaks_3_JOB_ID:$homer_annotate_peaks_4_JOB_ID
JOB_DONE=job_output/annotation_graphs/annotation_graphs.c08f6958f96315ab53a43b13ac63c45f.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'annotation_graphs.c08f6958f96315ab53a43b13ac63c45f.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 mugqic/pandoc/1.15.2 && \
cp /dev/null annotation/peak_stats_AllSamples.csv && \
mkdir -p graphs && \
Rscript $R_TOOLS/chipSeqgenerateAnnotationGraphs.R readset.chipseq.txt /lustre04/scratch/newtonma/chipseq_test_2 && \
declare -A samples_associative_array=(["EW22"]="H3K27ac" ["EW3"]="H3K27ac" ["EW7"]="H3K27ac" ["TC71"]="H3K27ac") && \
for sample in ${!samples_associative_array[@]}
do
    header=$(head -n 1 annotation/$sample/peak_stats.csv)
    tail -n+2 annotation/$sample/peak_stats.csv >> annotation/peak_stats_AllSamples.csv
done && \
sed -i -e "1 i\\$header" annotation/peak_stats_AllSamples.csv && \
mkdir -p report/annotation/$sample && \
mkdir -p report/yaml && \
cp annotation/peak_stats_AllSamples.csv report/annotation/peak_stats_AllSamples.csv && \
sed -e 's@proximal_distance@2@g' \
    -e 's@distal_distance@10@g' \
    -e 's@distance5d_lower@10@g' \
    -e 's@distance5d_upper@100@g' \
    -e 's@gene_desert_size@100@g' \
    -e 's@peak_stats_table@annotation/peak_stats_AllSamples.csv@g' \
    /home/newtonma/apps/genpipes/bfx/report/ChipSeq.annotation_graphs.yaml > report/yaml/ChipSeq.annotation_graphs.yaml && \
for sample in ${!samples_associative_array[@]}
do
  cp annotation/$sample/peak_stats.csv report/annotation/$sample/peak_stats.csv && \
  for mark_name in ${samples_associative_array[$sample]}
  do
    cp --parents graphs/${sample}.${mark_name}_Misc_Graphs.ps report/
    convert -rotate 90 graphs/${sample}.${mark_name}_Misc_Graphs.ps report/graphs/${sample}.${mark_name}_Misc_Graphs.png
    echo -e "\t![Annotation Statistics for Sample $sample and Mark $mark_name ([download high-res image](graphs/${sample}.${mark_name}_Misc_Graphs.ps))](graphs/${sample}.${mark_name}_Misc_Graphs.png)\n" >> report/yaml/ChipSeq.annotation_graphs.yaml
  done
done
annotation_graphs.c08f6958f96315ab53a43b13ac63c45f.mugqic.done
chmod 755 $COMMAND
annotation_graphs_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:00 --mem-per-cpu=4700M -N 1 -c 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$annotation_graphs_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$annotation_graphs_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: run_spp
#-------------------------------------------------------------------------------
STEP=run_spp
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: run_spp_1_JOB_ID: run_spp.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=run_spp.EW22.input
JOB_DEPENDENCIES=$sambamba_view_filter_1_JOB_ID
JOB_DONE=job_output/run_spp/run_spp.EW22.input.26da5b89148d378a3106005f13226e7e.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp.EW22.input.26da5b89148d378a3106005f13226e7e.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p ihec_metrics/EW22/input && \
cat /dev/null > ihec_metrics/EW22/input/EW22.input.crosscor && \
Rscript $R_TOOLS/run_spp.R -c=alignment/EW22/input/EW22.input.sorted.dup.filtered.bam -savp -out=ihec_metrics/EW22/input/EW22.input.crosscor -rf -tmpdir=${SLURM_TMPDIR}
run_spp.EW22.input.26da5b89148d378a3106005f13226e7e.mugqic.done
chmod 755 $COMMAND
run_spp_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=10:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: run_spp_2_JOB_ID: run_spp.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=run_spp.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_2_JOB_ID
JOB_DONE=job_output/run_spp/run_spp.EW22.H3K27ac.060a5ef975561f1c016d149129223eea.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp.EW22.H3K27ac.060a5ef975561f1c016d149129223eea.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p ihec_metrics/EW22/H3K27ac && \
cat /dev/null > ihec_metrics/EW22/H3K27ac/EW22.H3K27ac.crosscor && \
Rscript $R_TOOLS/run_spp.R -c=alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam -savp -out=ihec_metrics/EW22/H3K27ac/EW22.H3K27ac.crosscor -rf -tmpdir=${SLURM_TMPDIR}
run_spp.EW22.H3K27ac.060a5ef975561f1c016d149129223eea.mugqic.done
chmod 755 $COMMAND
run_spp_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=10:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: run_spp_3_JOB_ID: run_spp.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=run_spp.EW3.input
JOB_DEPENDENCIES=$sambamba_view_filter_3_JOB_ID
JOB_DONE=job_output/run_spp/run_spp.EW3.input.bab8f11fcfebbeb3c63219ff0e3b4c94.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp.EW3.input.bab8f11fcfebbeb3c63219ff0e3b4c94.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p ihec_metrics/EW3/input && \
cat /dev/null > ihec_metrics/EW3/input/EW3.input.crosscor && \
Rscript $R_TOOLS/run_spp.R -c=alignment/EW3/input/EW3.input.sorted.dup.filtered.bam -savp -out=ihec_metrics/EW3/input/EW3.input.crosscor -rf -tmpdir=${SLURM_TMPDIR}
run_spp.EW3.input.bab8f11fcfebbeb3c63219ff0e3b4c94.mugqic.done
chmod 755 $COMMAND
run_spp_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=10:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: run_spp_4_JOB_ID: run_spp.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=run_spp.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_4_JOB_ID
JOB_DONE=job_output/run_spp/run_spp.EW3.H3K27ac.2298adfd2c91836b0edc357c7a4b7b80.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp.EW3.H3K27ac.2298adfd2c91836b0edc357c7a4b7b80.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p ihec_metrics/EW3/H3K27ac && \
cat /dev/null > ihec_metrics/EW3/H3K27ac/EW3.H3K27ac.crosscor && \
Rscript $R_TOOLS/run_spp.R -c=alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam -savp -out=ihec_metrics/EW3/H3K27ac/EW3.H3K27ac.crosscor -rf -tmpdir=${SLURM_TMPDIR}
run_spp.EW3.H3K27ac.2298adfd2c91836b0edc357c7a4b7b80.mugqic.done
chmod 755 $COMMAND
run_spp_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=10:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: run_spp_5_JOB_ID: run_spp.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=run_spp.EW7.input
JOB_DEPENDENCIES=$sambamba_view_filter_5_JOB_ID
JOB_DONE=job_output/run_spp/run_spp.EW7.input.bc9be50e330e0bb279a1d4a15803302f.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp.EW7.input.bc9be50e330e0bb279a1d4a15803302f.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p ihec_metrics/EW7/input && \
cat /dev/null > ihec_metrics/EW7/input/EW7.input.crosscor && \
Rscript $R_TOOLS/run_spp.R -c=alignment/EW7/input/EW7.input.sorted.dup.filtered.bam -savp -out=ihec_metrics/EW7/input/EW7.input.crosscor -rf -tmpdir=${SLURM_TMPDIR}
run_spp.EW7.input.bc9be50e330e0bb279a1d4a15803302f.mugqic.done
chmod 755 $COMMAND
run_spp_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=10:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: run_spp_6_JOB_ID: run_spp.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=run_spp.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_6_JOB_ID
JOB_DONE=job_output/run_spp/run_spp.EW7.H3K27ac.683c3f1104a16bc68aa67d87bb285c18.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp.EW7.H3K27ac.683c3f1104a16bc68aa67d87bb285c18.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p ihec_metrics/EW7/H3K27ac && \
cat /dev/null > ihec_metrics/EW7/H3K27ac/EW7.H3K27ac.crosscor && \
Rscript $R_TOOLS/run_spp.R -c=alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam -savp -out=ihec_metrics/EW7/H3K27ac/EW7.H3K27ac.crosscor -rf -tmpdir=${SLURM_TMPDIR}
run_spp.EW7.H3K27ac.683c3f1104a16bc68aa67d87bb285c18.mugqic.done
chmod 755 $COMMAND
run_spp_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=10:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: run_spp_7_JOB_ID: run_spp.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=run_spp.TC71.input
JOB_DEPENDENCIES=$sambamba_view_filter_7_JOB_ID
JOB_DONE=job_output/run_spp/run_spp.TC71.input.7b2d94b4577cc5ef821c1acf48661004.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp.TC71.input.7b2d94b4577cc5ef821c1acf48661004.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p ihec_metrics/TC71/input && \
cat /dev/null > ihec_metrics/TC71/input/TC71.input.crosscor && \
Rscript $R_TOOLS/run_spp.R -c=alignment/TC71/input/TC71.input.sorted.dup.filtered.bam -savp -out=ihec_metrics/TC71/input/TC71.input.crosscor -rf -tmpdir=${SLURM_TMPDIR}
run_spp.TC71.input.7b2d94b4577cc5ef821c1acf48661004.mugqic.done
chmod 755 $COMMAND
run_spp_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=10:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: run_spp_8_JOB_ID: run_spp.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=run_spp.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_8_JOB_ID
JOB_DONE=job_output/run_spp/run_spp.TC71.H3K27ac.aaae4d131141937561c8220b57feb162.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp.TC71.H3K27ac.aaae4d131141937561c8220b57feb162.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
mkdir -p ihec_metrics/TC71/H3K27ac && \
cat /dev/null > ihec_metrics/TC71/H3K27ac/TC71.H3K27ac.crosscor && \
Rscript $R_TOOLS/run_spp.R -c=alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam -savp -out=ihec_metrics/TC71/H3K27ac/TC71.H3K27ac.crosscor -rf -tmpdir=${SLURM_TMPDIR}
run_spp.TC71.H3K27ac.aaae4d131141937561c8220b57feb162.mugqic.done
chmod 755 $COMMAND
run_spp_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"run_spp\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=10:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: run_spp_9_JOB_ID: run_spp_report
#-------------------------------------------------------------------------------
JOB_NAME=run_spp_report
JOB_DEPENDENCIES=$run_spp_1_JOB_ID:$run_spp_2_JOB_ID:$run_spp_3_JOB_ID:$run_spp_4_JOB_ID:$run_spp_5_JOB_ID:$run_spp_6_JOB_ID:$run_spp_7_JOB_ID:$run_spp_8_JOB_ID
JOB_DONE=job_output/run_spp/run_spp_report.8d0554a4dd7bc07f62e764f589dfa697.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'run_spp_report.8d0554a4dd7bc07f62e764f589dfa697.mugqic.done' > $COMMAND
declare -A samples_associative_array=(["EW22"]="input H3K27ac" ["EW3"]="input H3K27ac" ["EW7"]="input H3K27ac" ["TC71"]="input H3K27ac") && \
for sample in ${!samples_associative_array[@]}
do
  echo -e "Filename\tnumReads\testFragLen\tcorr_estFragLen\tPhantomPeak\tcorr_phantomPeak\targmin_corr\tmin_corr\tNormalized SCC (NSC)\tRelative SCC (RSC)\tQualityTag)" > ihec_metrics/${sample}/${sample}.crosscor
  for mark_name in ${samples_associative_array[$sample]}
  do
    cat ihec_metrics/${sample}/${mark_name}/${sample}.${mark_name}.crosscor >> ihec_metrics/${sample}/${sample}.crosscor
  done
done
run_spp_report.8d0554a4dd7bc07f62e764f589dfa697.mugqic.done
chmod 755 $COMMAND
run_spp_9_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=00:10:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$run_spp_9_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$run_spp_9_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: differential_binding
#-------------------------------------------------------------------------------
STEP=differential_binding
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: differential_binding_1_JOB_ID: differential_binding.diffbind.contrast_EW22_EW3_vs_EW7_TC71
#-------------------------------------------------------------------------------
JOB_NAME=differential_binding.diffbind.contrast_EW22_EW3_vs_EW7_TC71
JOB_DEPENDENCIES=$sambamba_view_filter_1_JOB_ID:$sambamba_view_filter_2_JOB_ID:$sambamba_view_filter_3_JOB_ID:$sambamba_view_filter_4_JOB_ID:$sambamba_view_filter_5_JOB_ID:$sambamba_view_filter_6_JOB_ID:$sambamba_view_filter_7_JOB_ID:$sambamba_view_filter_8_JOB_ID:$macs2_callpeak_1_JOB_ID:$macs2_callpeak_3_JOB_ID:$macs2_callpeak_5_JOB_ID:$macs2_callpeak_7_JOB_ID
JOB_DONE=job_output/differential_binding/differential_binding.diffbind.contrast_EW22_EW3_vs_EW7_TC71.d0f7788c8e2de25a4bc6d9a51ae1d07d.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'differential_binding.diffbind.contrast_EW22_EW3_vs_EW7_TC71.d0f7788c8e2de25a4bc6d9a51ae1d07d.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.6.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
        mkdir -p differential_binding &&
cp $R_TOOLS/DiffBind.R differential_binding/diffbind_EW22_EW3_vs_EW7_TC71_DBA_DESEQ2_dba.R &&
Rscript -e 'cur_dir=getwd();library(knitr);rmarkdown::render("differential_binding/diffbind_EW22_EW3_vs_EW7_TC71_DBA_DESEQ2_dba.R",params=list(cur_wd=cur_dir,d="design.chipseq.txt",r="readset.chipseq.txt",c="EW22_EW3_vs_EW7_TC71",o="differential_binding/diffbind_EW22_EW3_vs_EW7_TC71_DBA_DESEQ2_dba.txt",b="alignment",p="peak_call",dir="differential_binding",minOverlap="2",minMembers="2",method="DBA_DESEQ2"),output_file=file.path(cur_dir,"differential_binding/diffbind_EW22_EW3_vs_EW7_TC71_DBA_DESEQ2_dba.html"));' &&
rm differential_binding/diffbind_EW22_EW3_vs_EW7_TC71_DBA_DESEQ2_dba.R
differential_binding.diffbind.contrast_EW22_EW3_vs_EW7_TC71.d0f7788c8e2de25a4bc6d9a51ae1d07d.mugqic.done
chmod 755 $COMMAND
differential_binding_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"differential_binding\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"differential_binding\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=03:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$differential_binding_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$differential_binding_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: ihec_metrics
#-------------------------------------------------------------------------------
STEP=ihec_metrics
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: ihec_metrics_1_JOB_ID: IHEC_chipseq_metrics.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=IHEC_chipseq_metrics.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_1_JOB_ID:$sambamba_mark_duplicates_2_JOB_ID:$macs2_callpeak_2_JOB_ID:$run_spp_9_JOB_ID
JOB_DONE=job_output/ihec_metrics/IHEC_chipseq_metrics.EW22.H3K27ac.9a59fe0d59bc86a7aeadc9ac97702ebb.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'IHEC_chipseq_metrics.EW22.H3K27ac.9a59fe0d59bc86a7aeadc9ac97702ebb.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.6.0 mugqic/samtools/1.12 mugqic/sambamba/0.8.0 mugqic/deepTools/3.5.0 && \
mkdir -p ihec_metrics/EW22 && \
IHEC_chipseq_metrics_max.sh \
    -d alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.bam \
    -i alignment/EW22/input/EW22.input.sorted.dup.bam \
    -s EW22 \
    -j input \
    -t narrow \
    -c H3K27ac \
    -n 6 \
    -p peak_call/EW22/H3K27ac/EW22.H3K27ac_peaks.narrowPeak.bed \
    -o ihec_metrics/EW22 \
    -a hg19
IHEC_chipseq_metrics.EW22.H3K27ac.9a59fe0d59bc86a7aeadc9ac97702ebb.mugqic.done
chmod 755 $COMMAND
ihec_metrics_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"ihec_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"ihec_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=08:00:0 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$ihec_metrics_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$ihec_metrics_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: ihec_metrics_2_JOB_ID: IHEC_chipseq_metrics.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=IHEC_chipseq_metrics.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_3_JOB_ID:$sambamba_mark_duplicates_4_JOB_ID:$macs2_callpeak_4_JOB_ID:$run_spp_9_JOB_ID
JOB_DONE=job_output/ihec_metrics/IHEC_chipseq_metrics.EW3.H3K27ac.76618cc4fb58fa00bca45c9c8dc9e410.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'IHEC_chipseq_metrics.EW3.H3K27ac.76618cc4fb58fa00bca45c9c8dc9e410.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.6.0 mugqic/samtools/1.12 mugqic/sambamba/0.8.0 mugqic/deepTools/3.5.0 && \
mkdir -p ihec_metrics/EW3 && \
IHEC_chipseq_metrics_max.sh \
    -d alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.bam \
    -i alignment/EW3/input/EW3.input.sorted.dup.bam \
    -s EW3 \
    -j input \
    -t narrow \
    -c H3K27ac \
    -n 6 \
    -p peak_call/EW3/H3K27ac/EW3.H3K27ac_peaks.narrowPeak.bed \
    -o ihec_metrics/EW3 \
    -a hg19
IHEC_chipseq_metrics.EW3.H3K27ac.76618cc4fb58fa00bca45c9c8dc9e410.mugqic.done
chmod 755 $COMMAND
ihec_metrics_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"ihec_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"ihec_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=08:00:0 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$ihec_metrics_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$ihec_metrics_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: ihec_metrics_3_JOB_ID: IHEC_chipseq_metrics.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=IHEC_chipseq_metrics.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_5_JOB_ID:$sambamba_mark_duplicates_6_JOB_ID:$macs2_callpeak_6_JOB_ID:$run_spp_9_JOB_ID
JOB_DONE=job_output/ihec_metrics/IHEC_chipseq_metrics.EW7.H3K27ac.221504e69511389b633cb326ef4651b7.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'IHEC_chipseq_metrics.EW7.H3K27ac.221504e69511389b633cb326ef4651b7.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.6.0 mugqic/samtools/1.12 mugqic/sambamba/0.8.0 mugqic/deepTools/3.5.0 && \
mkdir -p ihec_metrics/EW7 && \
IHEC_chipseq_metrics_max.sh \
    -d alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.bam \
    -i alignment/EW7/input/EW7.input.sorted.dup.bam \
    -s EW7 \
    -j input \
    -t narrow \
    -c H3K27ac \
    -n 6 \
    -p peak_call/EW7/H3K27ac/EW7.H3K27ac_peaks.narrowPeak.bed \
    -o ihec_metrics/EW7 \
    -a hg19
IHEC_chipseq_metrics.EW7.H3K27ac.221504e69511389b633cb326ef4651b7.mugqic.done
chmod 755 $COMMAND
ihec_metrics_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"ihec_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"ihec_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=08:00:0 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$ihec_metrics_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$ihec_metrics_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: ihec_metrics_4_JOB_ID: IHEC_chipseq_metrics.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=IHEC_chipseq_metrics.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_mark_duplicates_7_JOB_ID:$sambamba_mark_duplicates_8_JOB_ID:$macs2_callpeak_8_JOB_ID:$run_spp_9_JOB_ID
JOB_DONE=job_output/ihec_metrics/IHEC_chipseq_metrics.TC71.H3K27ac.3ccc0dc6b60a2e795b6820041ae757f8.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'IHEC_chipseq_metrics.TC71.H3K27ac.3ccc0dc6b60a2e795b6820041ae757f8.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.6.0 mugqic/samtools/1.12 mugqic/sambamba/0.8.0 mugqic/deepTools/3.5.0 && \
mkdir -p ihec_metrics/TC71 && \
IHEC_chipseq_metrics_max.sh \
    -d alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.bam \
    -i alignment/TC71/input/TC71.input.sorted.dup.bam \
    -s TC71 \
    -j input \
    -t narrow \
    -c H3K27ac \
    -n 6 \
    -p peak_call/TC71/H3K27ac/TC71.H3K27ac_peaks.narrowPeak.bed \
    -o ihec_metrics/TC71 \
    -a hg19
IHEC_chipseq_metrics.TC71.H3K27ac.3ccc0dc6b60a2e795b6820041ae757f8.mugqic.done
chmod 755 $COMMAND
ihec_metrics_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE && module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"ihec_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \"running\"
module unload mugqic/python/2.7.13 &&
   $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE
module load mugqic/python/2.7.13
/home/newtonma/apps/genpipes/utils/job2json.py \
  -u \"$USER\" \
  -c \"/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.base.ini,/home/newtonma/apps/genpipes/pipelines/chipseq/chipseq.beluga.ini,/lustre04/scratch/newtonma/chipseq_test_2/chipseq.ini\" \
  -s \"ihec_metrics\" \
  -j \"$JOB_NAME\" \
  -d \"$JOB_DONE\" \
  -l \"$JOB_OUTPUT\" \
  -o \"/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json,/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json,/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json\" \
  -f \$MUGQIC_STATE
module unload mugqic/python/2.7.13 

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=08:00:0 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$ihec_metrics_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$ihec_metrics_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: ihec_metrics_5_JOB_ID: merge_ihec_metrics
#-------------------------------------------------------------------------------
JOB_NAME=merge_ihec_metrics
JOB_DEPENDENCIES=$ihec_metrics_1_JOB_ID:$ihec_metrics_2_JOB_ID:$ihec_metrics_3_JOB_ID:$ihec_metrics_4_JOB_ID
JOB_DONE=job_output/ihec_metrics/merge_ihec_metrics.42fec0c117ed5960d56b63e1c69576a8.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'merge_ihec_metrics.42fec0c117ed5960d56b63e1c69576a8.mugqic.done' > $COMMAND
cp /dev/null ihec_metrics/IHEC_chipseq_metrics_AllSamples.tsv && \
for sample in ihec_metrics/EW22/H3K27ac/IHEC_chipseq_metrics.EW22.H3K27ac.tsv ihec_metrics/EW3/H3K27ac/IHEC_chipseq_metrics.EW3.H3K27ac.tsv ihec_metrics/EW7/H3K27ac/IHEC_chipseq_metrics.EW7.H3K27ac.tsv ihec_metrics/TC71/H3K27ac/IHEC_chipseq_metrics.TC71.H3K27ac.tsv
do
    header=$(head -n 1 $sample | cut -f -3,5-17,30-33,35,37,39-)
    tail -n 1 $sample | cut -f -3,5-17,30-33,35,37,39- >> ihec_metrics/IHEC_chipseq_metrics_AllSamples.tsv
done && \
sample_name=`tail -n 1 $sample | cut -f 1` && \
input_name=`tail -n 1 $sample | cut -f 4` && \
input_chip_type="NA" && \
genome_assembly=`tail -n 1 $sample | cut -f 5` && \
input_core=`tail -n 1 $sample | cut -f 18-29` && \
input_nsc=`tail -n 1 $sample | cut -f 34` && \
input_rsc=`tail -n 1 $sample | cut -f 36` && \
input_quality=`tail -n 1 $sample | cut -f 38` && \
if [[ $input_name != "no_input" ]]
  then
    echo -e "${sample_name}\t${input_name}\t${input_chip_type}\t${genome_assembly}\t${input_core}\tNA\tNA\tNA\t${input_nsc}\t${input_rsc}\t${input_quality}\tNA\tNA" >> ihec_metrics/IHEC_chipseq_metrics_AllSamples.tsv
fi && \
sed -i -e "1 i\\$header" ihec_metrics/IHEC_chipseq_metrics_AllSamples.tsv
merge_ihec_metrics.42fec0c117ed5960d56b63e1c69576a8.mugqic.done
chmod 755 $COMMAND
ihec_metrics_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$ihec_metrics_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$ihec_metrics_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: ihec_metrics_6_JOB_ID: merge_ihec_metrics_report
#-------------------------------------------------------------------------------
JOB_NAME=merge_ihec_metrics_report
JOB_DEPENDENCIES=$ihec_metrics_5_JOB_ID
JOB_DONE=job_output/ihec_metrics/merge_ihec_metrics_report.4d2ce400f2b907efb2ed1afb47555456.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'merge_ihec_metrics_report.4d2ce400f2b907efb2ed1afb47555456.mugqic.done' > $COMMAND
module purge && \
module load mugqic/pandoc/1.15.2 && \
mkdir -p report/yaml && \
cp ihec_metrics/IHEC_chipseq_metrics_AllSamples.tsv report/IHEC_chipseq_metrics_AllSamples.tsv && \
sed -e 's@ihec_metrics_merged_table@IHEC_chipseq_metrics_AllSamples.tsv@g' \
    /home/newtonma/apps/genpipes/bfx/report/ChipSeq.ihec_metrics.yaml > report/yaml/ChipSeq.ihec_metrics.yaml
merge_ihec_metrics_report.4d2ce400f2b907efb2ed1afb47555456.mugqic.done
chmod 755 $COMMAND
ihec_metrics_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:0 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$ihec_metrics_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$ihec_metrics_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: multiqc_report
#-------------------------------------------------------------------------------
STEP=multiqc_report
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: multiqc_report_1_JOB_ID: multiqc_report
#-------------------------------------------------------------------------------
JOB_NAME=multiqc_report
JOB_DEPENDENCIES=$metrics_1_JOB_ID:$metrics_2_JOB_ID:$metrics_3_JOB_ID:$metrics_4_JOB_ID:$metrics_5_JOB_ID:$metrics_6_JOB_ID:$metrics_7_JOB_ID:$metrics_8_JOB_ID:$metrics_9_JOB_ID:$metrics_10_JOB_ID:$metrics_11_JOB_ID:$metrics_12_JOB_ID:$metrics_13_JOB_ID:$metrics_14_JOB_ID:$metrics_15_JOB_ID:$metrics_16_JOB_ID:$homer_make_tag_directory_1_JOB_ID:$homer_make_tag_directory_2_JOB_ID:$homer_make_tag_directory_3_JOB_ID:$homer_make_tag_directory_4_JOB_ID:$homer_make_tag_directory_5_JOB_ID:$homer_make_tag_directory_6_JOB_ID:$homer_make_tag_directory_7_JOB_ID:$homer_make_tag_directory_8_JOB_ID
JOB_DONE=job_output/multiqc_report/multiqc_report.17416c49129ed3d1eb88b249cc84c040.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'multiqc_report.17416c49129ed3d1eb88b249cc84c040.mugqic.done' > $COMMAND
module purge && \
module load mugqic/python/3.7.3 mugqic/MultiQC/1.9 && \
multiqc -f  \
 \
  metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
  metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
  metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
  metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
  metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
  metrics/EW22/input/EW22.input.sorted.dup.filtered.flagstat  \
  tags/EW22/EW22.input/tagGCcontent.txt  \
  tags/EW22/EW22.input/genomeGCcontent.txt  \
  tags/EW22/EW22.input/tagLengthDistribution.txt  \
  tags/EW22/EW22.input/tagInfo.txt  \
  metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
  metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
  metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
  metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
  metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
  metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.flagstat  \
  tags/EW22/EW22.H3K27ac/tagGCcontent.txt  \
  tags/EW22/EW22.H3K27ac/genomeGCcontent.txt  \
  tags/EW22/EW22.H3K27ac/tagLengthDistribution.txt  \
  tags/EW22/EW22.H3K27ac/tagInfo.txt  \
  metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
  metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
  metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
  metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
  metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
  metrics/EW3/input/EW3.input.sorted.dup.filtered.flagstat  \
  tags/EW3/EW3.input/tagGCcontent.txt  \
  tags/EW3/EW3.input/genomeGCcontent.txt  \
  tags/EW3/EW3.input/tagLengthDistribution.txt  \
  tags/EW3/EW3.input/tagInfo.txt  \
  metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
  metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
  metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
  metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
  metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
  metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.flagstat  \
  tags/EW3/EW3.H3K27ac/tagGCcontent.txt  \
  tags/EW3/EW3.H3K27ac/genomeGCcontent.txt  \
  tags/EW3/EW3.H3K27ac/tagLengthDistribution.txt  \
  tags/EW3/EW3.H3K27ac/tagInfo.txt  \
  metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
  metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
  metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
  metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
  metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
  metrics/EW7/input/EW7.input.sorted.dup.filtered.flagstat  \
  tags/EW7/EW7.input/tagGCcontent.txt  \
  tags/EW7/EW7.input/genomeGCcontent.txt  \
  tags/EW7/EW7.input/tagLengthDistribution.txt  \
  tags/EW7/EW7.input/tagInfo.txt  \
  metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
  metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
  metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
  metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
  metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
  metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.flagstat  \
  tags/EW7/EW7.H3K27ac/tagGCcontent.txt  \
  tags/EW7/EW7.H3K27ac/genomeGCcontent.txt  \
  tags/EW7/EW7.H3K27ac/tagLengthDistribution.txt  \
  tags/EW7/EW7.H3K27ac/tagInfo.txt  \
  metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
  metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
  metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
  metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
  metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
  metrics/TC71/input/TC71.input.sorted.dup.filtered.flagstat  \
  tags/TC71/TC71.input/tagGCcontent.txt  \
  tags/TC71/TC71.input/genomeGCcontent.txt  \
  tags/TC71/TC71.input/tagLengthDistribution.txt  \
  tags/TC71/TC71.input/tagInfo.txt  \
  metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
  metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
  metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
  metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
  metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
  metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.flagstat  \
  tags/TC71/TC71.H3K27ac/tagGCcontent.txt  \
  tags/TC71/TC71.H3K27ac/genomeGCcontent.txt  \
  tags/TC71/TC71.H3K27ac/tagLengthDistribution.txt  \
  tags/TC71/TC71.H3K27ac/tagInfo.txt \
-n report/multiqc_report.html
multiqc_report.17416c49129ed3d1eb88b249cc84c040.mugqic.done
chmod 755 $COMMAND
multiqc_report_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=4:00:00 --mem-per-cpu=4700M -N 1 -c 5 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$multiqc_report_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$multiqc_report_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# STEP: cram_output
#-------------------------------------------------------------------------------
STEP=cram_output
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: cram_output_1_JOB_ID: cram_output.EW22.input
#-------------------------------------------------------------------------------
JOB_NAME=cram_output.EW22.input
JOB_DEPENDENCIES=$sambamba_view_filter_1_JOB_ID
JOB_DONE=job_output/cram_output/cram_output.EW22.input.0a8c1f66559e915a56f03d26c9875eee.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'cram_output.EW22.input.0a8c1f66559e915a56f03d26c9875eee.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 && \
samtools view \
  -h -T $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa -C \
  alignment/EW22/input/EW22.input.sorted.dup.filtered.bam  \
  > alignment/EW22/input/EW22.input.sorted.dup.filtered.cram
cram_output.EW22.input.0a8c1f66559e915a56f03d26c9875eee.mugqic.done
chmod 755 $COMMAND
cram_output_1_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$cram_output_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$cram_output_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: cram_output_2_JOB_ID: cram_output.EW22.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=cram_output.EW22.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_2_JOB_ID
JOB_DONE=job_output/cram_output/cram_output.EW22.H3K27ac.c104ca27056933cc8f0c42867801040d.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'cram_output.EW22.H3K27ac.c104ca27056933cc8f0c42867801040d.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 && \
samtools view \
  -h -T $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa -C \
  alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.bam  \
  > alignment/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.cram
cram_output.EW22.H3K27ac.c104ca27056933cc8f0c42867801040d.mugqic.done
chmod 755 $COMMAND
cram_output_2_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$cram_output_2_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$cram_output_2_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: cram_output_3_JOB_ID: cram_output.EW3.input
#-------------------------------------------------------------------------------
JOB_NAME=cram_output.EW3.input
JOB_DEPENDENCIES=$sambamba_view_filter_3_JOB_ID
JOB_DONE=job_output/cram_output/cram_output.EW3.input.921eb6128b7eaf52cb6f1c5d9e0b9d4b.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'cram_output.EW3.input.921eb6128b7eaf52cb6f1c5d9e0b9d4b.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 && \
samtools view \
  -h -T $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa -C \
  alignment/EW3/input/EW3.input.sorted.dup.filtered.bam  \
  > alignment/EW3/input/EW3.input.sorted.dup.filtered.cram
cram_output.EW3.input.921eb6128b7eaf52cb6f1c5d9e0b9d4b.mugqic.done
chmod 755 $COMMAND
cram_output_3_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$cram_output_3_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$cram_output_3_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: cram_output_4_JOB_ID: cram_output.EW3.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=cram_output.EW3.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_4_JOB_ID
JOB_DONE=job_output/cram_output/cram_output.EW3.H3K27ac.267e22ad2796e7b0c22b1a79d43b2de2.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'cram_output.EW3.H3K27ac.267e22ad2796e7b0c22b1a79d43b2de2.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 && \
samtools view \
  -h -T $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa -C \
  alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.bam  \
  > alignment/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.cram
cram_output.EW3.H3K27ac.267e22ad2796e7b0c22b1a79d43b2de2.mugqic.done
chmod 755 $COMMAND
cram_output_4_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$cram_output_4_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$cram_output_4_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: cram_output_5_JOB_ID: cram_output.EW7.input
#-------------------------------------------------------------------------------
JOB_NAME=cram_output.EW7.input
JOB_DEPENDENCIES=$sambamba_view_filter_5_JOB_ID
JOB_DONE=job_output/cram_output/cram_output.EW7.input.05687bd65d87bad562a1913c896cd399.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'cram_output.EW7.input.05687bd65d87bad562a1913c896cd399.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 && \
samtools view \
  -h -T $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa -C \
  alignment/EW7/input/EW7.input.sorted.dup.filtered.bam  \
  > alignment/EW7/input/EW7.input.sorted.dup.filtered.cram
cram_output.EW7.input.05687bd65d87bad562a1913c896cd399.mugqic.done
chmod 755 $COMMAND
cram_output_5_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$cram_output_5_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$cram_output_5_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: cram_output_6_JOB_ID: cram_output.EW7.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=cram_output.EW7.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_6_JOB_ID
JOB_DONE=job_output/cram_output/cram_output.EW7.H3K27ac.9bf7b0d953d0ab1aeaebef13a2ef539d.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'cram_output.EW7.H3K27ac.9bf7b0d953d0ab1aeaebef13a2ef539d.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 && \
samtools view \
  -h -T $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa -C \
  alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.bam  \
  > alignment/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.cram
cram_output.EW7.H3K27ac.9bf7b0d953d0ab1aeaebef13a2ef539d.mugqic.done
chmod 755 $COMMAND
cram_output_6_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$cram_output_6_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$cram_output_6_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: cram_output_7_JOB_ID: cram_output.TC71.input
#-------------------------------------------------------------------------------
JOB_NAME=cram_output.TC71.input
JOB_DEPENDENCIES=$sambamba_view_filter_7_JOB_ID
JOB_DONE=job_output/cram_output/cram_output.TC71.input.ad5066b1cd612bfa9e1be6cd5a704c48.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'cram_output.TC71.input.ad5066b1cd612bfa9e1be6cd5a704c48.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 && \
samtools view \
  -h -T $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa -C \
  alignment/TC71/input/TC71.input.sorted.dup.filtered.bam  \
  > alignment/TC71/input/TC71.input.sorted.dup.filtered.cram
cram_output.TC71.input.ad5066b1cd612bfa9e1be6cd5a704c48.mugqic.done
chmod 755 $COMMAND
cram_output_7_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$cram_output_7_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$cram_output_7_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# JOB: cram_output_8_JOB_ID: cram_output.TC71.H3K27ac
#-------------------------------------------------------------------------------
JOB_NAME=cram_output.TC71.H3K27ac
JOB_DEPENDENCIES=$sambamba_view_filter_8_JOB_ID
JOB_DONE=job_output/cram_output/cram_output.TC71.H3K27ac.af7530b34746985e29fdd05ca0ee5c46.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'cram_output.TC71.H3K27ac.af7530b34746985e29fdd05ca0ee5c46.mugqic.done' > $COMMAND
module purge && \
module load mugqic/samtools/1.12 && \
samtools view \
  -h -T $MUGQIC_INSTALL_HOME/genomes/species/Homo_sapiens.hg19/genome/Homo_sapiens.hg19.fa -C \
  alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.bam  \
  > alignment/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.cram
cram_output.TC71.H3K27ac.af7530b34746985e29fdd05ca0ee5c46.mugqic.done
chmod 755 $COMMAND
cram_output_8_JOB_ID=$(echo "#! /bin/bash
echo '#######################################'
echo 'SLURM FAKE PROLOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
rm -f $JOB_DONE &&    $COMMAND
MUGQIC_STATE=\$PIPESTATUS
echo MUGQICexitStatus:\$MUGQIC_STATE

if [ \$MUGQIC_STATE -eq 0 ] ; then touch $JOB_DONE ; fi
echo '#######################################'
echo 'SLURM FAKE EPILOGUE (MUGQIC)'
date
scontrol show job \$SLURM_JOBID
sstat -j \$SLURM_JOBID.batch
echo '#######################################'
exit \$MUGQIC_STATE" | \
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=24:00:00 --mem-per-cpu=4700M -c 1 -N 1 --depend=afterok:$JOB_DEPENDENCIES | grep "[0-9]" | cut -d\  -f4)
echo "$cram_output_8_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$cram_output_8_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# Call home with pipeline statistics
#-------------------------------------------------------------------------------
LOG_MD5=$(echo $USER-'10.74.73.4-ChipSeq-EW22.EW22_A787C17_input.EW22_A787C20_H3K27ac,EW3.EW3_1056C284_input.EW3_A1056C287_H3K27ac,TC71.TC71_A379C48_H3K27ac.TC71_A379C51_input,EW7.EW7_A485C51_input.EW7_A490C39_H3K27ac' | md5sum | awk '{ print $1 }')
echo `wget "http://mugqic.hpc.mcgill.ca/cgi-bin/pipeline.cgi?hostname=beluga4.int.ets1.calculquebec.ca&ip=10.74.73.4&pipeline=ChipSeq&steps=picard_sam_to_fastq,trimmomatic,merge_trimmomatic_stats,mapping_bwa_mem_sambamba,sambamba_merge_bam_files,sambamba_mark_duplicates,sambamba_view_filter,metrics,homer_make_tag_directory,qc_metrics,homer_make_ucsc_file,macs2_callpeak,homer_annotate_peaks,homer_find_motifs_genome,annotation_graphs,run_spp,differential_binding,ihec_metrics,multiqc_report,cram_output&samples=4&md5=$LOG_MD5" --quiet --output-document=/dev/null`
