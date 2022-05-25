#!/usr/bin/env python
""" MultiQC hook functions - we tie into the MultiQC
core here to add in extra functionality. """


from __future__ import print_function
from random import sample
from pkg_resources import get_distribution
import logging

from multiqc.utils import report, config

# Initialise the main MultiQC logger
log = logging.getLogger('multiqc')


# Save this plugin's version number (defined in setup.py) to the MultiQC config
config.c3g_plugin_version = get_distribution("multiqc_c3g").version

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
    elif config.kwargs.get('runprocessing', False):

        log.info("Running C3G Runprocessing Plugin v{}".format(config.c3g_plugin_version))
        # Search patterns used by Run Processing
        if "c3g_runprocessing/report" not in config.sp:
            config.update_dict( config.sp, {"c3g_runprocessing/report": {"fn": "*.run_validation_report.json"}} )
        if "c3g_demuxmetrics/metrics" not in config.sp:
            config.update_dict( config.sp, {"c3g_demuxmetrics/metrics": {"fn": "*.DemuxFastqs.metrics.txt"}} )
        if "c3g_blastresults/summary" not in config.sp:
            config.update_dict( config.sp, {"c3g_blastresults/summary": {"fn": "*.blastHit_20MF_species.txt"}} )


        # We replace the default fastp module with our own version and remove fastqc.
        config.avail_modules.pop('fastp', None)
        if "c3g_fastp/json" not in config.sp:
            config.update_dict( config.sp, {"c3g_fastp/json": {"fn": "*.fastp.json"}} )
        config.avail_modules.pop('fastqc', None)


        # Ignore some files generated by the custom pipeline
        config.fn_ignore_paths.extend([
            "*.fasta",
            "*.blastresRrna",
            "*.qual",
            "*.html"
            "*.reportupdated",
        ])

    else:
        return None

        # if "genpipes/barcodestat" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/barcodestat": {"fn": "BarcodeStat.txt"}} )
        # if "genpipes/sequencestat" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/sequencestat": {"fn": "SequenceStat.txt"}} )
        # if "genpipes/i1counts" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/i1counts": {"fn": "Undetermined_*.counts.txt"}} )
        # if "genpipes/blastsummary" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/blastsummary": {"fn": "*.R1.RDP.blastHit_20MF_species.txt"}} )
        # if "c3gverifybamid/selfsm" not in config.sp:
        #     config.update_dict( config.sp, {"c3gverifybamid/selfsm": {"fn": "*.verifyBamId.selfSM"}} )
        # if "genpipes/joblist" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/joblist": {"fn": "RunProcessing_job_list_*"}} )
        # if "genpipes/outfiles" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/outfiles": {"fn": "*.o"}} )
        # if "genpipes/insert_size_metrics" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/insert_size_metrics": {"fn": "*.sorted.metrics.insert_size_metrics"}} )
        # if "genpipes/alignment_summary_metrics" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/alignment_summary_metrics": {"fn": "*.sorted.metrics.alignment_summary_metrics"}} )
        # if "genpipes/target_coverage_metrics" not in config.sp:
        #     config.update_dict( config.sp, {"genpipes/target_coverage_metrics": {"fn": "*.sorted.metrics.targetCoverage.txt"}} )


def c3g_summaries():
    # If at least one fastp file has been parsed, use those metrics to calculate lane-level spread and yield
    if 'FastP' in [mod.name for mod in report.modules_output]:
        yields_by_lane = dict()
        clusters_by_lane = dict()
        foo = next(x for x in report.general_stats_data for name, d in x.items() if "yield" in d and "clusters" in d)
        # for name, d in report.general_stats_data[0].items():
        for name, d in foo.items():
            lane = name.split(' ')[0]
            sample_yield = d['yield']
            sample_clusters = d['clusters']
            yields_by_lane[lane] = yields_by_lane.get(lane, []) + [sample_yield]
            clusters_by_lane[lane] = clusters_by_lane.get(lane, []) + [sample_clusters]
        spreads_by_lane = [(lane, max(vals) / min(vals)) for lane, vals in yields_by_lane.items()]
        spreads_by_lane.sort(key=lambda tupl: tupl[0])
        clusters_by_lane = [(lane, sum(vals)) for lane, vals in clusters_by_lane.items()]
        config.report_header_info.append({"Spreads" : " | ".join([lane + ": {:.2f}".format(spread) for lane, spread in spreads_by_lane])})
        clusters_by_lane.sort(key=lambda tupl: tupl[0])
        config.report_header_info.append({"Total clusters" : " | ".join([f'{lane}: {count:,}' for lane, count in clusters_by_lane])})
