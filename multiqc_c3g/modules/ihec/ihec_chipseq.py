#!/usr/bin/env python

""" MultiQC module to parse output from IHEC ChIPSeq reports """

import logging
from multiqc import config
from multiqc.plots import bargraph, linegraph, scatter, table
from collections import OrderedDict
import pandas as pd
import os
import re

# Initialise the logger
log = logging.getLogger('multiqc')


class ChIPSeqReportMixin():


    def ihec_chipseq(self):
        """ Finds IHEC ChIPSeq logs and parse their data """
        self.parse_chip_ihec_files()
        self.ihec_chip_table()

        if config.kwargs.get('project').lower() == "ihec":
            self.plot_chip_ihec()

        return len(self.ihec_metrics['chipseq'])





    def parse_chip_ihec_files(self):
        '''finds chip ihec log files'''
        re_pattern = ["IHEC_metrics_chipseq_", ".txt"]
        re_pattern = '|'.join(re_pattern)
        for f in self.find_log_files('ihec/chipseq', filehandles= True):
            parsed_data = self.parse_ihec_chipseq(f)
            s_name = f['s_name']
            s_name = re.sub(re_pattern, '', s_name)
            self.ihec_metrics['chipseq'][s_name] = parsed_data
            # Filter out samples matching ignored sample names
            if parsed_data is not None:
                if s_name in self.ihec_metrics['chipseq']:
                    log.debug("Duplicate chip sample log found! Overwriting: {}".format(s_name))

        self.ihec_metrics = self.ignore_samples(self.ihec_metrics)




    def parse_ihec_chipseq(self, f):
        """ Parse IHEC ChIPSeq file. Should have 2 lines: keys & values"""
        parsed_data = {}
        keys = f['f'].readline().strip().split()
        vals = f['f'].readline().strip().split()

        for key, val in zip(keys, vals):
            key = str(key)
            try:
                cast_val = float(val)
            except ValueError:
                cast_val = str(val)

            parsed_data.update({key:cast_val})


        return parsed_data



    def ihec_chip_table(self):
        """ Add core IHEC stats to the general stats table"""
        # genome_assembly   ChIP_type   treat_name  ctl_name    treat_raw_reads treat_filtered_reads    treat_mapped_reads  treat_duplicated_reads  treat_final_reads   ctl_raw_reads   clt_filtered_reads  clt_mapped_reads    ctl_duplicated_reads    ctl_final_reads treat_filtered_frac ctl_filtered_frac   treat_aln_frac  ctl_aln_frac    treat_dup_frac  ctl_dup_frac    nmb_peaks   reads_in_peaks  frip    treat_nsc   ctrl_nsc    treat_rsc   ctrl_rsc    treat_Quality   ctrl_Quality    singletons  js_dist chance_div
        chip_headers = OrderedDict()
        chip_headers['treat_name'] = {
            'title': 'treat_name',
            'description': 'Name of treatment',
            'format': '{:,.0f}'
        }
        chip_headers['ctl_name'] = {
            'title': 'ctl_name',
            'description': 'Name of Control',
            'format': '{:,.0f}'
        }
        chip_headers['genome_assembly'] = {
            'title': 'genome_assembly',
            'description': 'Genome used for aligning data',
            'format': '{:,.0f}'
        }
        chip_headers['ChIP_type'] = {
            'title': 'ChIP_type',
            'description': 'Broad or Narrow analysis',
            'format': '{:,.0f}'
        }
        chip_headers['treat_raw_reads'] = {
            'title': 'treat_raw_reads',
            'description': 'Raw reads in treatment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_filtered_reads'] = {
            'title': 'treat_filtered_reads',
            'description': 'Filtered reads in treatment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_mapped_reads'] = {
            'title': 'treat_mapped_reads',
            'description': 'Mapped reads in treatment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_duplicated_reads'] = {
            'title': 'treat_duplicated_reads',
            'description': 'Duplicated reads in treatment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_final_reads'] = {
            'title': 'treat_final_reads',
            'description': 'Final reads in treatment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['ctl_raw_reads'] = {
            'title': 'ctl_raw_reads',
            'description': 'Raw reads in control',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['clt_filtered_reads'] = {
            'title': 'clt_filtered_reads',
            'description': 'Filtered reads in control',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['clt_mapped_reads'] = {
            'title': 'clt_mapped_reads',
            'description': 'Mapped reads in control',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['ctl_duplicated_reads'] = {
            'title': 'ctl_duplicated_reads',
            'description': 'Duplicated reads in control',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['ctl_final_reads'] = {
            'title': 'ctl_final_reads',
            'description': 'Final reads in control',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_filtered_frac'] = {
            'title': 'treat_filtered_frac',
            'description': 'Fraction of filtered treatment reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.3f}'
        }
        chip_headers['ctl_filtered_frac'] = {
            'title': 'ctl_filtered_frac',
            'description': 'Fraction of filtered control reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.3f}'
        }
        chip_headers['treat_aln_frac'] = {
            'title': 'treat_aln_frac',
            'description': 'Fraction of aligned treatment reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['ctl_aln_frac'] = {
            'title': 'ctl_aln_frac',
            'description': 'Fraction of aligned control reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_dup_frac'] = {
            'title': 'treat_dup_frac',
            'description': 'Fraction of duplicated treatment reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['ctl_dup_frac'] = {
            'title': 'ctl_dup_frac',
            'description': 'Fraction of duplicated control reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.3f}'
        }
        chip_headers['nmb_peaks'] = {
            'title': 'nmb_peaks',
            'description': 'Number of called peaks',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['reads_in_peaks'] = {
            'title': 'reads_in_peaks',
            'description': 'Number of reads in peaks',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['frip'] = {
            'title': 'frip',
            'description': 'Fraction of reads in peaks',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_nsc'] = {
            'title': 'treat_nsc',
            'description': 'NSC of treatment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['ctrl_nsc'] = {
            'title': 'ctrl_nsc',
            'description': 'NSC of control',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_rsc'] = {
            'title': 'treat_rsc',
            'description': 'RSC of treatment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.3f}'
        }
        chip_headers['ctrl_rsc'] = {
            'title': 'ctrl_rsc',
            'description': 'RSC of control',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['treat_Quality'] = {
            'title': 'treat_Quality',
            'description': 'Quality of treatment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['ctrl_Quality'] = {
            'title': 'ctrl_Quality',
            'description': 'Quality of Control',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['singletons'] = {
            'title': 'singletons',
            'description': 'Singletons',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['js_dist'] = {
            'title': 'js_dist',
            'description': 'JS Distance',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        chip_headers['chance_div'] = {
            'title': 'chance_div',
            'description': 'Chance Divergance',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }

        self.general_stats_addcols(self.ihec_metrics['chipseq'], chip_headers, 'IHEC-ChIPSeq')


    def plot_chip_ihec(self):
        '''plots ihec chipseq metrics'''
        pass


