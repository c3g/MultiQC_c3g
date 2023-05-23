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
    echo -e "\t![Annotation Statistics for Sample $sample and Mark $mark_name ([download high-res image](graphs/${sample}.${mark_name}_Misc_Graphs.ps))](graphs/${sample}.${mark_name}_Misc_Graphs.png)\n" >> report/yaml/ChipSeq.annotation_graphs.yaml
  done
done
