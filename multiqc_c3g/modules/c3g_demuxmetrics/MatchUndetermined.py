#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from __future__ import print_function
from collections import OrderedDict
from io import StringIO
import logging
import csv
import re

from multiqc.plots import table

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

def parse_reports(self):

    # Parse output files from undetermined barcodes matching
    self.unexpected_barcode_data = dict()
    report_found = []

    for f in self.find_log_files("c3g_demuxmetrics/matchedundetermined"):
        #lane_data = matched_metrics(self, f)
        lane = self.get_lane(f)
        self.unexpected_barcode_data[f"L{lane}"] = matched_metrics(f)
        #self.unexpected_barcode_data = {**self.unexpected_barcode_data, **lane_data}
        report_found.append(f['fn'])

    if report_found:
        self.add_section(
            name = "Barcodes - Unexpected",
            description = "The counts for unexpected barcodes and their potential matches to sequencing barcodes are shown below. Note that only frequent barcodes are shown (>50000 reads).",
            plot = unexpected_barcodes_table(self)
                )
    return len(report_found)

def matched_metrics(f):
    metrics = dict()

    buff = StringIO(f['f'])
    reader = csv.DictReader(buff, delimiter="\t")
    for row in reader:
        #barcode = row.pop('Sequence')
        #metrics[barcode] = row
        readCount = row.pop('ReadCount')
        metrics[ReadCount] = row

    return metrics

def unexpected_barcodes_table(self):
    largest_value = max([y['ReadCount'] for (_,y) in self.unexpected_barcode_data.items()])
    headers = OrderedDict()
    headers['ReadCount'] = {
            'title' : "Number of reads",
            'description' : "number of reads for this barcode in run",
            'format' : '{:,.0f}',
            'max' : largest_value
            }
    headers['Sequence'] = {
            'title' : "Barcode sequence",
            'description' : "sequence of undetermined barcode"
            }
    headers['Matches'] = {
            'title' : "Matches",
            'description' : "sequence and names of any matches to the undetermined barcode in database of sequencing barcodes"
            }
    return table.plot(self.unexpected_barcode_data, headers, {"col1_header": "Lane"})
