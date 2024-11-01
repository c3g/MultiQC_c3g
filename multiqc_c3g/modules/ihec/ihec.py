#!/usr/bin/env python
""" MultiQC module to parse output from IHEC """
from __future__ import print_function
from collections import OrderedDict
import logging

from multiqc import config
from multiqc.base_module import BaseMultiqcModule

# Import the HOMER submodules
from .ihec_chipseq import ChIPSeqReportMixin
from .ihec_rnaseq import RNASeqReportMixin

# Initialise the logger
log = logging.getLogger('multiqc')


class MultiqcModule(BaseMultiqcModule, ChIPSeqReportMixin, RNASeqReportMixin):
    """ The International Human Epigenome Consortium (IHEC) is a global consortium
    whose primary goal is providing free access to high-resolution reference human 
    epigenome maps for normal and disease cell types to the research community. 
    This module plots IHEC required metrics produced by the GenPipes analysis 
    pipelines by C3G  """

    def __init__(self):

            # Halt execution if we've disabled the plugin
        if not config.kwargs.get('enable_c3g', True):
            return None


        # Initialise the parent object
        super(MultiqcModule, self).__init__(
            name='IHEC', 
            anchor='ihec',
            href='http://ihec-epigenomes.org/',
            info="is an epigenetic consortium and data hub.")


        # # Set up class objects to hold parsed data
        # self.general_stats_headers = OrderedDict()
        # self.general_stats_data = dict()
        n = dict()

        #Set up data structures
        self.ihec_metrics = {
            'chipseq': {},
            'rnaseq': {}
         }

        # # Call submodule functions
        

        n['chipseq'] = self.ihec_chipseq()
        if n['chipseq'] > 0:
            log.info("Found {} IHEC chipseq reports".format(n['chipseq']))
        else:
            log.info("No IHEC chipseq reports")

    
        n['rnaseq'] = self.ihec_rnaseq()
        if n['rnaseq'] > 0:
            log.info("Found {} IHEC rnaseq reports".format(n['rnaseq']))
        else:
            log.info("No IHEC rnaseq reports")

        # Exit if we didn't find anything
        if sum(n.values()) == 0:
            raise UserWarning

