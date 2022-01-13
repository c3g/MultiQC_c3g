#!/usr/bin/env python

""" MultiQC module to parse output from IHEC RNASeq reports """

import logging
from multiqc.plots import bargraph, linegraph, scatter, table
from collections import OrderedDict
import re

# Initialise the logger
log = logging.getLogger(__name__)


class RNASeqReportMixin():

    def ihec_rnaseq(self):
        """ Finds IHEC RNASeq logs and parse their data """
        self.parse_rna_ihec_files()
        self.ihec_rna_table()

        return len(self.ihec_metrics['rnaseq'])





    def parse_rna_ihec_files(self):
        '''finds rnaseq ihec log files'''
        re_pattern = ["IHEC_metrics_rnaseq_", ".txt"]
        re_pattern = '|'.join(re_pattern)
        for f in self.find_log_files('ihec/rnaseq', filehandles= True):
            parsed_data = self.parse_ihec_rnaseq(f)
            s_name = f['s_name']
            s_name = re.sub(re_pattern, '', s_name)
            self.ihec_metrics['rnaseq'][s_name] = parsed_data
            # Filter out samples matching ignored sample names
            if parsed_data is not None:
                if s_name in self.ihec_metrics['rnaseq']:
                    log.debug("Duplicate rna sample log found! Overwriting: {}".format(s_name))

        self.ihec_metrics = self.ignore_samples(self.ihec_metrics)




    def parse_ihec_rnaseq(self, f):
        """ Parse IHEC ChIPSeq file. Should have 2 lines: keys & values"""
        keys = f['f'].readline().strip().split()
        vals = f['f'].readline().strip().split()
        parsed_data = dict(zip(keys, vals))

        return parsed_data



    def ihec_rna_table(self):
        """ Add core IHEC stats to the general stats table"""
        rna_headers = OrderedDict()
        rna_headers['Sample'] = {
            'title': 'Sample',
            'description': 'Sample Name',
            'format': '{:,.0f}'
        }
        rna_headers['genomeAssembly'] = {
            'title': 'genomeAssembly',
            'description': 'Genome used for aligning data',
            'format': '{:,.0f}'
        }
        rna_headers['RawReads'] = {
            'title': 'RawReads',
            'description': 'Number of raw reads',
            'format': '{:,.0f}'
        }
        rna_headers['SurvivingReads'] = {
            'title': 'SurvivingReads',
            'description': 'Surviving reads',
            'format': '{:,.0f}'
        }
        rna_headers['SurvivingReads_perc'] = {
            'title': 'SurvivingReads_perc',
            'description': 'Percentage of surviving reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.2f}'
        }
        rna_headers['AlignedReads'] = {
            'title': 'AlignedReads',
            'description': 'ALigned reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        rna_headers['AlignedReads_perc'] = {
            'title': 'AlignedReads_perc',
            'description': 'Percentage of Aligned reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.2f}'
        }
        rna_headers['AlternativeAlignments'] = {
            'title': 'AlternativeAlignments',
            'description': 'ALternative ALignment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        rna_headers['AlternativeAlignments_perc'] = {
            'title': 'AlternativeAlignments_perc',
            'description': 'Percentage of Alternative Alignment',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.2f}'
        }
        rna_headers['rRNA_perc'] = {
            'title': 'rRNA_perc',
            'description': 'Percentage of rRNA',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.2f}'
        }
        rna_headers['DuplicationRate'] = {
            'title': 'DuplicationRate',
            'description': 'Rate of duplication',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.2f}'
        }
        rna_headers['IntergenicRate'] = {
            'title': 'IntergenicRate',
            'description': 'Rate of intergenic reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.2f}'
        }
        rna_headers['IntragenicRate'] = {
            'title': 'IntragenicRate',
            'description': 'Rate of intragenic reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.2f}'
        }
        rna_headers['ExonicRate'] = {
            'title': 'ExonicRate',
            'description': 'Rate of Exonic reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.2f}'
        }
        rna_headers['IntronicRate'] = {
            'title': 'IntronicRate',
            'description': 'Rate of Intronic reads',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.3f}'
        }
        rna_headers['GenesDetected'] = {
            'title': 'GenesDetected',
            'description': 'Number of detected genes',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }
        rna_headers['StrandSpecificity'] = {
            'title': 'StrandSpecificity',
            'description': 'Strand Specificity',
            'min': 0,
            'scale': 'RdYlGn-rev',
            'format': '{:,.0f}'
        }

        self.general_stats_addcols(self.ihec_metrics['rnaseq'], rna_headers, 'IHEC-ChIPSeq')


