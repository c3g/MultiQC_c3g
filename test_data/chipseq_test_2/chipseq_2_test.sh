#!/bin/bash
# Exit immediately on error

set -eu -o pipefail

#-------------------------------------------------------------------------------
# ChipSeq SLURM Job Submission Bash script
# Version: 3.6.0
# Created on: 2021-08-19T10:54:05
# Steps:
#   qc_metrics: 1 job
#   annotation_graphs: 1 job
#   TOTAL: 2 jobs
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
cp "/lustre04/scratch/newtonma/chipseq_test_2/json/EW22.json" "$PORTAL_OUTPUT_DIR/$USER.EW22.93f09c157b194d1980bb3d9b53c938a9.json"
cp "/lustre04/scratch/newtonma/chipseq_test_2/json/EW3.json" "$PORTAL_OUTPUT_DIR/$USER.EW3.110cfffa13df4d70866757c30dc9e260.json"
cp "/lustre04/scratch/newtonma/chipseq_test_2/json/EW7.json" "$PORTAL_OUTPUT_DIR/$USER.EW7.01fa1825e7ed40efbf5c6a7caee73784.json"
cp "/lustre04/scratch/newtonma/chipseq_test_2/json/TC71.json" "$PORTAL_OUTPUT_DIR/$USER.TC71.aae42866c3b94b178699a372b494e945.json"

#-------------------------------------------------------------------------------
# STEP: qc_metrics
#-------------------------------------------------------------------------------
STEP=qc_metrics
mkdir -p $JOB_OUTPUT_DIR/$STEP

#-------------------------------------------------------------------------------
# JOB: qc_metrics_1_JOB_ID: qc_plots_R
#-------------------------------------------------------------------------------
JOB_NAME=qc_plots_R
JOB_DEPENDENCIES=
JOB_DONE=job_output/qc_metrics/qc_plots_R.24b563b424d812ba78b3e83a9f602204.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'qc_plots_R.24b563b424d812ba78b3e83a9f602204.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.7.0 mugqic/R_Bioconductor/4.0.3_3.12 && \
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
    echo -e "\n\n\t----\n\t![](graphs/${sample}.${mark_name}_QC_Metrics.png)\n\n\tQC Metrics for Sample $sample and Mark $mark_name \([download high-res image](graphs/${sample}.${mark_name}_QC_Metrics.ps)\)" >> report/yaml/ChipSeq.qc_metrics.yaml
  done
done
qc_plots_R.24b563b424d812ba78b3e83a9f602204.mugqic.done
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
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=12:00:0 --mem-per-cpu=4700M -N 1 -c 1 | grep "[0-9]" | cut -d\  -f4)
echo "$qc_metrics_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$qc_metrics_1_JOB_ID	$JOB_NAME submitted"
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
JOB_DEPENDENCIES=
JOB_DONE=job_output/annotation_graphs/annotation_graphs.370fbe137ddd57f127a6edbf8cb80e59.mugqic.done
JOB_OUTPUT_RELATIVE_PATH=$STEP/${JOB_NAME}_$TIMESTAMP.o
JOB_OUTPUT=$JOB_OUTPUT_DIR/$JOB_OUTPUT_RELATIVE_PATH
COMMAND=$JOB_OUTPUT_DIR/$STEP/${JOB_NAME}_$TIMESTAMP.sh
cat << 'annotation_graphs.370fbe137ddd57f127a6edbf8cb80e59.mugqic.done' > $COMMAND
module purge && \
module load mugqic/mugqic_tools/2.7.0 mugqic/R_Bioconductor/4.0.3_3.12 mugqic/pandoc/1.15.2 && \
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
    echo -e "\n\n\t----\n\t![](graphs/${sample}.${mark_name}_Misc_Graphs.png)\n\n\tAnnotation Statistics for Sample $sample and Mark $mark_name \([download high-res image](graphs/${sample}.${mark_name}_Misc_Graphs.ps)\)" >> report/yaml/ChipSeq.annotation_graphs.yaml
  done
done
annotation_graphs.370fbe137ddd57f127a6edbf8cb80e59.mugqic.done
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
sbatch --mail-type=END,FAIL --mail-user=$JOB_MAIL -A $RAP_ID -D $OUTPUT_DIR -o $JOB_OUTPUT -J $JOB_NAME --time=01:00:00 --mem-per-cpu=4700M -N 1 -c 1 | grep "[0-9]" | cut -d\  -f4)
echo "$annotation_graphs_1_JOB_ID	$JOB_NAME	$JOB_DEPENDENCIES	$JOB_OUTPUT_RELATIVE_PATH" >> $JOB_LIST

echo "$annotation_graphs_1_JOB_ID	$JOB_NAME submitted"
sleep 0.1

#-------------------------------------------------------------------------------
# Call home with pipeline statistics
#-------------------------------------------------------------------------------
LOG_MD5=$(echo $USER-'10.74.73.1-ChipSeq-EW22.EW22_A787C17_input.EW22_A787C20_H3K27ac,EW3.EW3_1056C284_input.EW3_A1056C287_H3K27ac,TC71.TC71_A379C48_H3K27ac.TC71_A379C51_input,EW7.EW7_A485C51_input.EW7_A490C39_H3K27ac' | md5sum | awk '{ print $1 }')
echo `wget "http://mugqic.hpc.mcgill.ca/cgi-bin/pipeline.cgi?hostname=beluga1.int.ets1.calculquebec.ca&ip=10.74.73.1&pipeline=ChipSeq&steps=qc_metrics,annotation_graphs&samples=4&md5=$LOG_MD5" --quiet --output-document=/dev/null`
