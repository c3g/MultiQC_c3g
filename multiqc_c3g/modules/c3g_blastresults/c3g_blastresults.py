#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from __future__ import print_function
from collections import OrderedDict
from dataclasses import field
from io import StringIO
import logging
import csv
import re

from multiqc import config
from multiqc_c3g.runprocessing_base import RunProcessingBaseModule
from multiqc.plots import table

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(RunProcessingBaseModule):
    def __init__(self):

        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Blast",
            target="Blast",
            anchor="blast",
            href="https://github.com/c3g/runprocesing_plugin",
            info=" files from run processing blast output",
        )

        # Halt execution if we don't have the runprocessing flag set.
        if not config.kwargs.get("runprocessing", False):
            return None

        blast_data = dict()
        for f in self.find_log_files("c3g_blastresults"):
            blast_data = {**blast_data, **self.blast_metrics(f)}

        headers = OrderedDict()
        headers['blast_hit_1'] = {'title': 'Top blast hit'}
        headers['blast_hit_2'] = {'title': 'Second blast hit'}
        headers['blast_hit_3'] = {'title': 'Third blast hit'}
        headers['blast_hit_4'] = {'title': 'Fourth blast hit', 'hidden': True }
        headers['blast_hit_5'] = {'title': 'Fifth blast hit', 'hidden': True }
        headers['blast_hit_6'] = {'title': 'Sixth blast hit', 'hidden': True }
        headers['blast_hit_7'] = {'title': 'Seventh blast hit', 'hidden': True }
        headers['blast_hit_8'] = {'title': 'Eighth blast hit', 'hidden': True }
        headers['blast_hit_9'] = {'title': 'Nineth blast hit', 'hidden': True }
        headers['blast_hit_10'] = {'title': 'Tenth blast hit', 'hidden': True }
        if(len(blast_data)>0):
            self.add_section(
                name = "Blast hits",
                plot = table.plot(blast_data, headers))

        headers = OrderedDict()
        headers['blast_hit_1'] = { 'title' : "Top blast hit", 'hidden': False }
        headers['blast_hit_2'] = { 'title' : "Second blast hit", 'hidden': True }
        headers['blast_hit_3'] = { 'title' : "Third blast hit", 'hidden': True }
        self.general_stats_addcols(blast_data, headers)


    def blast_metrics(self, f):
        buff = StringIO(f['f'])
        reader = csv.DictReader(buff, delimiter=" ", skipinitialspace=True, fieldnames=['count', 'result'])
        blast_hit_dict = {f"blast_hit_{index+1}" : f"{row['result']} ({row['count']} hits)" for index, row in enumerate(reader) }
        cleaner_name = re.sub(r'_\d+_L\d+.R1(R2)?.RDP.blastHit_20MF_species.txt', '', f['fn'])
        s_name = self.clean_s_name(cleaner_name, f)
        return { s_name : blast_hit_dict }
