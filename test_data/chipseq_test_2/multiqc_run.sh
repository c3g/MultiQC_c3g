module purge && \
module load mugqic_dev/MultiQC/c3g-beta && \
multiqc -f  \
\
../metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
../metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
../metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
../metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
../metrics/EW22/input/EW22.input.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
../metrics/EW22/input/EW22.input.sorted.dup.filtered.flagstat  \
../tags/EW22/EW22.input/tagGCcontent.txt  \
../tags/EW22/EW22.input/genomeGCcontent.txt  \
../tags/EW22/EW22.input/tagLengthDistribution.txt  \
../tags/EW22/EW22.input/tagInfo.txt  \
../metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
../metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
../metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
../metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
../metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
../metrics/EW22/H3K27ac/EW22.H3K27ac.sorted.dup.filtered.flagstat  \
../tags/EW22/EW22.H3K27ac/tagGCcontent.txt  \
../tags/EW22/EW22.H3K27ac/genomeGCcontent.txt  \
../tags/EW22/EW22.H3K27ac/tagLengthDistribution.txt  \
../tags/EW22/EW22.H3K27ac/tagInfo.txt  \
../metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
../metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
../metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
../metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
../metrics/EW3/input/EW3.input.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
../metrics/EW3/input/EW3.input.sorted.dup.filtered.flagstat  \
../tags/EW3/EW3.input/tagGCcontent.txt  \
../tags/EW3/EW3.input/genomeGCcontent.txt  \
../tags/EW3/EW3.input/tagLengthDistribution.txt  \
../tags/EW3/EW3.input/tagInfo.txt  \
../metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
../metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
../metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
../metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
../metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
../metrics/EW3/H3K27ac/EW3.H3K27ac.sorted.dup.filtered.flagstat  \
../tags/EW3/EW3.H3K27ac/tagGCcontent.txt  \
../tags/EW3/EW3.H3K27ac/genomeGCcontent.txt  \
../tags/EW3/EW3.H3K27ac/tagLengthDistribution.txt  \
../tags/EW3/EW3.H3K27ac/tagInfo.txt  \
../metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
../metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
../metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
../metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
../metrics/EW7/input/EW7.input.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
../metrics/EW7/input/EW7.input.sorted.dup.filtered.flagstat  \
../tags/EW7/EW7.input/tagGCcontent.txt  \
../tags/EW7/EW7.input/genomeGCcontent.txt  \
../tags/EW7/EW7.input/tagLengthDistribution.txt  \
../tags/EW7/EW7.input/tagInfo.txt  \
../metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
../metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
../metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
../metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
../metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
../metrics/EW7/H3K27ac/EW7.H3K27ac.sorted.dup.filtered.flagstat  \
../tags/EW7/EW7.H3K27ac/tagGCcontent.txt  \
../tags/EW7/EW7.H3K27ac/genomeGCcontent.txt  \
../tags/EW7/EW7.H3K27ac/tagLengthDistribution.txt  \
../tags/EW7/EW7.H3K27ac/tagInfo.txt  \
../metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
../metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
../metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
../metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
../metrics/TC71/input/TC71.input.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
../metrics/TC71/input/TC71.input.sorted.dup.filtered.flagstat  \
../tags/TC71/TC71.input/tagGCcontent.txt  \
../tags/TC71/TC71.input/genomeGCcontent.txt  \
../tags/TC71/TC71.input/tagLengthDistribution.txt  \
../tags/TC71/TC71.input/tagInfo.txt  \
../metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle.pdf  \
../metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.alignment_summary_metrics  \
../metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.quality_by_cycle_metrics  \
../metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution_metrics  \
../metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.all.metrics.quality_distribution.pdf  \
../metrics/TC71/H3K27ac/TC71.H3K27ac.sorted.dup.filtered.flagstat  \
../tags/TC71/TC71.H3K27ac/tagGCcontent.txt  \
../tags/TC71/TC71.H3K27ac/genomeGCcontent.txt  \
../tags/TC71/TC71.H3K27ac/tagLengthDistribution.txt  \
../tags/TC71/TC71.H3K27ac/tagInfo.txt \
IHEC_chipseq_metrics_AllSamples.tsv \
SampleMetrics.tsv \
annotation/peak_stats_AllSamples.csv \
peak_call/ \
../trim/*/*/*.log \
--filename chipseq_multiqc_cstm_test \
-c yaml/ChipSeq.annotation_graphs.yaml \
-c yaml/ChipSeq.homer_annotate_peaks.yaml \
-c yaml/ChipSeq.homer_find_motifs_genome.yaml \
-c yaml/ChipSeq.homer_make_ucsc_file.yaml \
-c yaml/ChipSeq.ihec_metrics.yaml \
-c yaml/ChipSeq.macs2_callpeak.yaml \
-c yaml/ChipSeq.metrics.yaml \
-c yaml/ChipSeq.qc_metrics.yaml \
-c yaml/ChipSeq.sambamba_mark_duplicates.yaml \
-c yaml/ChipSeq.sambamba_view_filter.yaml \
-t chipseq \
-c ../chipseq_multiqc_config_new.yaml


