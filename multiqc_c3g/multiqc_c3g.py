#!/usr/bin/env python
""" MultiQC hook functions - we tie into the MultiQC
core here to add in extra functionality. """


from __future__ import print_function
from pkg_resources import get_distribution
import logging
import os

from multiqc_c3g.modules.c3g_runprocessing import ValidationReport
from multiqc import report, config

# Initialise the main MultiQC logger
log = logging.getLogger('multiqc')


# Save this plugin's version number (defined in setup.py) to the MultiQC config
config.c3g_plugin_version = get_distribution("multiqc_c3g").version

def c3g_config():
    """
    Set config options specific to c3g runprocessing.
    Hook for before_config.
    """
    log.info("Setting C3G Run Processing Configurations")

    if config.kwargs.get('runprocessing', False) is True:
 
        # Ignore some files generated by the custom pipeline
        config.fn_ignore_paths.extend(
            [
                "*.fasta",
                "*.blastresRrna",
                "*.qual",
                "*.html",
                "*.reportupdated",
                "*.filter"
            ]
        )
        
    else:
        return None

def c3g_execution():
    """ Code to execute after the config files and
    command line flags have been parsedself.
    This setuptools hook is the earliest that will be able
    to use custom command line flags.
    """
    # Halt execution if we've disabled the plugin
    if config.kwargs.get('enable_c3g', False):

        log.info("Running MultiQC C3G Plugin v{}".format(config.c3g_plugin_version))

        # Add to the search patterns used by modules
        if 'ihec/chipseq' not in config.sp:
            config.update_dict( config.sp, {'ihec/chipseq': {'fn': 'IHEC_metrics_chipseq_*'}})
        if 'ihec/rnaseq' not in config.sp:
            config.update_dict( config.sp, { 'ihec/rnaseq': {'fn': 'IHEC_metrics_rnaseq_*', 'exclude_fn': 'IHEC_metrics_rnaseq_All.txt'}})
        if 'kallisto_c3g/XYZ' not in config.sp:
            config.update_dict( config.sp, { 'kallisto_c3g/XYZ': {'fn': 'file_pattern*'}})
        if 'sleuth/XYZ' not in config.sp:
            config.update_dict( config.sp, { 'sleuth/XYZ': {'fn': 'file_pattern*'}})


        # Some additional filename cleaning
        config.fn_clean_exts.extend([
            'IHEC_metrics_chipseq_',
            'IHEC_metrics_rnaseq_',
        ])

        # Ignore some files generated by the custom pipeline
        config.fn_ignore_paths.extend([
            "*/Blast_sample/*.qual",
            "*/BasecallQC.txt",
            "*.pdf",
        ])

    # Runprocessing-specific args and options
    elif config.kwargs.get('runprocessing', False) is True:

        log.info("Running C3G Runprocessing Plugin v{}".format(config.c3g_plugin_version))
        # Search patterns used by Run Processing
        if "c3g_runprocessing" not in config.sp:
            config.update_dict( config.sp, {"c3g_runprocessing": {"fn": "*.run_validation_report.json"}} )
        if "c3g_demuxmetrics/demuxfastqs" not in config.sp:
            config.update_dict( config.sp, {"c3g_demuxmetrics/demuxfastqs": {"fn": "*.DemuxFastqs.metrics.txt"}} )
        if "c3g_demuxmetrics/count_illumina_barcodes" not in config.sp:
            config.update_dict( config.sp, {"c3g_demuxmetrics/count_illumina_barcodes": {"fn": "*_[12345678].metrics"}} )
        if "c3g_demuxmetrics/bcl2fastq" not in config.sp:
            config.update_dict( config.sp, {"c3g_demuxmetrics/bcl2fastq": {"fn": "Stats.json"}} )
        if "c3g_demuxmetrics/splitbarcode" not in config.sp:
            config.update_dict( config.sp, {"c3g_demuxmetrics/splitbarcode": {"fn": "*BarcodeStat_*_multiqc.txt"}} )
        if "c3g_demuxmetrics/unassigned" not in config.sp:
            config.update_dict( config.sp, {"c3g_demuxmetrics/unassigned": {"fn": "Undetermined_*.counts.txt"}} )
        if "c3g_demuxmetrics/matchedundetermined" not in config.sp:
            config.update_dict( config.sp, {"c3g_demuxmetrics/matchedundetermined": {"fn": "Undetermined_*.match_table.tsv"}} )
        if "c3g_blastresults" not in config.sp:
            config.update_dict( config.sp, {"c3g_blastresults": {"fn": "*.blastHit_20MF_species.txt"}} )
        if "c3g_progress" not in config.sp:
            config.update_dict( config.sp, {"c3g_progress": {"fn": "RunProcessing_job_list_*"}} )
        if "c3g_alignments/alignment_summary_metrics" not in config.sp:
            config.update_dict( config.sp, {"c3g_alignments/alignment_summary_metrics": {"fn": "*.sorted.metrics.alignment_summary_metrics"}} )
        if "c3g_alignments/alignment_duplication_metrics" not in config.sp:
            config.update_dict( config.sp, {"c3g_alignments/alignment_duplication_metrics": {"fn": "*.sorted.dup.metrics"}} )
        if "c3g_alignments/insert_size_metrics" not in config.sp:
            config.update_dict( config.sp, {"c3g_alignments/insert_size_metrics": {"fn": "*.sorted.metrics.insert_size_metrics"}} )
        if "c3g_alignments/target_coverage_metrics" not in config.sp:
            config.update_dict( config.sp, {"c3g_alignments/target_coverage_metrics": {"fn": "*.sorted.metrics.targetCoverage.txt"}} )

        # We replace the default verifybamid module with our own version
        config.avail_modules.pop('verifybamid', None)
        if "c3g_verifybamid" not in config.sp:
            config.update_dict( config.sp, {"c3g_verifybamid": {"fn": "*.sorted.metrics.verifyBamId.selfSM"}} )

        # We replace the default fastp module with our own version and remove fastqc.
        config.avail_modules.pop('fastp', None)
        if "c3g_fastp" not in config.sp:
            config.update_dict( config.sp, {"c3g_fastp": {"fn": "*.fastp.json"}} )
        config.avail_modules.pop('fastqc', None)

        # We replace the default RNASeq-QC module with our own version
        config.avail_modules.pop('rna_seqc', None)
        if "c3g_rnaseqc" not in config.sp:
            config.update_dict( config.sp, {"c3g_rnaseqc": {"fn": "*.rnaseqc.*.metrics.tsv"}} )

        # We replace the default SortMeRNA module with our own version
        config.avail_modules.pop('sortmerna', None)
        if "c3g_sortmerna" not in config.sp:
            config.update_dict( config.sp, {"c3g_sortmerna": {"fn": "*.aligned.log"}} )

        # Ignore some files generated by the custom pipeline
        config.fn_ignore_paths.extend(
            [
                "*.fasta",
                "*.blastresRrna",
                "*.qual",
                "*.html",
                "*.reportupdated",
                "*.filter"
            ]
        )

        # If no modules are specified using --modules, limit to just the c3g run processing modules.
        rp_modules = [
            'c3g_demuxmetrics',
            'c3g_fastp',
            'c3g_blastresults',
            'c3g_alignments',
            'c3g_runprocessing',
            'c3g_verifybamid',
            'c3g_progress',
            'c3g_rnaseqc',
            'c3g_sortmerna'
        ]
        if not config.run_modules:
            config.run_modules = list(rp_modules)

        # increase threshold to turn tables into violin plots
        config.max_table_rows = 10000

        # Buttons to show/hide by lane
        # TODO dynamic lane list
        config.show_hide_buttons = ["All lanes"] + [f"Lane {lane}" for lane in [1,2,3,4,5,6,7,8]]
        config.show_hide_patterns = [[]] + [f"L{lane} | " for lane in [1,2,3,4,5,6,7,8]]
        config.show_hide_mode = ['hide'] + ["show" for lane in [1,2,3,4,5,6,7,8]]

        # Set module order
        config.report_section_order = {
                'c3g_runprocessing' : {
                    'order' : 100
                    },
                'c3g_demuxmetrics' : {
                    'order': 90
                    },
                'c3g_fastp' : {
                    'order' : 80
                    },
                'c3g_blastresults' : {
                    'order' : 70
                    },
                'c3g_alignments' : {
                    'order' : 60
                    },
                'c3g_rna_seqc' : {
                    'order' : 50
                    },
                'c3g_sortmerna' : {
                    'order' : 40
                    },
                'c3g_verifybamid' : {
                    'order' : 30
                    },
                'c3g_progress' : {
                    'order' : 10
                    }
                }
        
        # customize column order of General Stats table
        config.table_columns_placement = {
                'general_stats_table' : {
                    'Project' : 100,
                    'Lane' : 110,
                    'Reported Sex' : 120,
                    'Inferred Sex' : 130,
                    'Sex Concordance' : 140,
                    'total' : 180,
                    'yieldQ30' : 200,
                    'percent_R1_Q30' : 220,
                    'percent_R2_Q30' : 230,
                    'perfectPercent' : 240,
                    'R1_trimmed_bases' : 250,
                    'R2_trimmed_bases' : 260,
                    'PCT_PF_READS_ALIGNED' : 300,
                    'PERCENT_DUPLICATION' : 310,
                    'summed_median' : 320,
                    'summed_mean' : 330,
                    'MeanCoverage' : 340,
                    'PctBasesCoveredAt10x' : 350,
                    'PctBasesCoveredAt25x' : 360,
                    'clusters' : 190,
                    'yield' : 410,
                    'gc' : 420,
                    'Duplication' : 430,
                    'q30_rate' : 210,
                    'q20_rate' : 450,
                    'blast_hit_1' : 500,
                    'blast_hit_2' : 510,
                    'blast_hit_3' : 520,
                    'FREEMIX' : 600
                    }
                }
    else:
        return None

def c3g_summaries():
    """ Add run-level metrics to the report header """
    if 'FastP' in [mod.name for mod in report.modules]:
        yields_by_lane = dict()
        clusters_by_lane = dict()
        clusters_by_sample = []
        foo = next(x for x in report.general_stats_data for name, d in x.items() if "yield" in d and "clusters" in d)
        # for name, d in report.general_stats_data[0].items():
        for name, d in foo.items():
            lane = name.split(' ')[0]
            sample_yield = d['yield']
            sample_clusters = d['clusters']
            yields_by_lane[lane] = yields_by_lane.get(lane, []) + [sample_yield]
            clusters_by_lane[lane] = clusters_by_lane.get(lane, []) + [sample_clusters]
            clusters_by_sample.append(sample_clusters)
        spreads_by_lane = [(lane, max(vals) / min(vals) if min(vals) else (lane, max(vals))) for lane, vals in yields_by_lane.items()]
        spreads_by_lane.sort(key=lambda tupl: tupl[0])
        clusters_by_lane = [(lane, sum(vals)) for lane, vals in clusters_by_lane.items()]
        if config.report_header_info is None:
            config.report_header_info = []
        config.report_header_info.append({"Spreads" : " | ".join([lane + ": {:.2f}".format(spread) for lane, spread in spreads_by_lane])})
        clusters_by_lane.sort(key=lambda tupl: tupl[0])
        config.report_header_info.append({"Total clusters" : " | ".join([f'{lane}: {count:,}' for lane, count in clusters_by_lane])})

def before_modules():
    """
    Replace .{library} with _{library}
    This is necessary because the pipeline uses _{library} for most outputs and
    the .{library} for alignment outputs.
    """
    for f in report.files['c3g_runprocessing']:
        with open(os.path.join(f['root'], f['fn']), 'r') as f:
            v_report = ValidationReport.from_string(f.read())
            for readset in v_report.readsets:
                config.sample_names_replace[f".{readset.library}"] = f"_{readset.library}"
