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

    ## Parse splitBarcode metrics output files
    self.barcode_data = dict()
    self.unexpected_per_lane = dict()
    report_found = []

    for f in self.find_log_files("c3g_demuxmetrics/splitbarcode"): 
        lane_data = expected_metrics(self, f)
        lane = self.get_lane(f)
        self.unexpected_per_lane[f"L{lane}"] = unexpected_metrics(f)
        self.barcode_data = {**self.barcode_data, **lane_data}
        report_found.append(f['fn'])

    if report_found:
        self.add_section(
            name = "Barcodes - Expected",
            description = "The counts for expected barcodes are shown below. Note that percentage is relative to the lane, not the run as a whole.",
            plot = expected_barcodes_table(self)
        )
        self.add_section(
            name = "Barcodes - Lane Overview",
            description = "Overview of number of clusters assigned to expected barcodes.",
            plot = lane_overview_table(self)
        )

    return len(report_found)

def unexpected_metrics(f):
    buff = StringIO(f['f'])
    reader = csv.DictReader(buff, delimiter="\t")
    expected_total = 0
    percentage = 0
    for row in reader:
        barcode_name = row.pop('BarcodeName')
        if barcode_name == "Total":
            expected_total += int(row['Total'])
            percentage += float(row['Percentage(%)'])
    return {
        "expected": expected_total,
        "unexpected": ((100 / percentage) * expected_total) - expected_total,
        "fraction_expected": percentage 
    }

def expected_metrics(self, f):
    metrics = dict()

    buff = StringIO(f['f'])
    reader = csv.DictReader(buff, delimiter="\t")
    for row in reader:
        barcode_name = row.pop('BarcodeName')
        if barcode_name != "Total":
           # sample_name = row['Sample_ID']
           # barcode_name = get_clean_barcode_name(barcode_name, row['library_name'])
            # s_name = self.clean_s_name(sample_name, f)
           # s_name = self.clean_s_name(barcode_name, f)
            # row = {**row, **{'barcode_name': barcode_name}}
           # row = {**row, **{'sample_name': sample_name}}
            metrics[barcode_name] = row

    return metrics

#def get_clean_sample_name(barcode, library):
#    raw_sample = barcode.split(f"_{library}_")[0]
#    clean_sample = f"{raw_sample}_{library}"
#    return clean_sample

#def get_clean_barcode_name(barcode, library):
#    raw_barcode = barcode.split(f"_{library}_")[1]
#    prefix_matcher = re.compile("(?P<prefix>[A-Z])_(?P<barcode>.+)")
#    m = prefix_matcher.search(raw_barcode)
#    if m:
#        barcode = m.group("barcode")
#        suffix = m.group("prefix")
#        barcode = f"{barcode}_{suffix}"
#    else:
#        barcode = raw_barcode
#    return barcode

def expected_barcodes_table(self):
    headers = OrderedDict()
    # longest_name = max([len(y['barcode_name']) for (_,y) in self.barcode_data.items()])
    longest_name = max([len(y['Sample_ID']) for (_,y) in self.barcode_data.items()])
    # headers['barcode_name'] = {
    #     'title' : "Barcode ID",
    #     'description': 'Barcode Name',
    #     'max': longest_name,
    #     'format': '{:s}',
    # }
    headers['Sample_ID'] = {
        'title' : "Sample Name",
        'description': 'Sample Name',
        'max': longest_name,
        'format': '{:s}',
    }
#    headers['barcode'] = {
#        'title' : "Barcode Sequence",
#        'description': 'Barcode sequence',
#    }
    largest_total = max([y['Total'] for (_,y) in self.barcode_data.items()])
    headers['Correct'] = {
        'title': 'Perfect',
        'description': 'Number of clusters with perfect barcode sequence',
        'format': '{:,.0f}',
        'min': 0,
        'max': largest_total,
    }
    headers['Corrected'] = {
        'title': 'Imperfect',
        'description': 'Number of clusters assigned to barcode within mismatch distance',
        'format': '{:,.0f}',
        'min': 0,
        'max': largest_total,
    }
    headers['Total'] = {
        'title': 'Total',
        'description': 'Total number of clusters assigned to barcode',
        'format': '{:,.0f}',
        'min': 0,
        'max': largest_total,
    }
    headers['Percentage'] = {
        'title' : "Lane composition (%)",
        'description': 'Percentage of the lane assigned to this barcode',
        'suffix': '%',
        'modify': lambda x: float(x) * 100,
        'format': '{:,.1f}',
        'min': 0,
        'max': 100
    }
    # return table.plot(self.barcode_data, headers, {"col1_header": "Lane | Sample Name"})
    return table.plot(self.barcode_data, headers, {"col1_header": "Lane | Barcode ID"})

def lane_overview_table(self):
    largest_value = max([max(y['expected'],y['unexpected']) for (_,y) in self.unexpected_per_lane.items()])
    headers = OrderedDict()
    headers['expected'] = {
        'title' : "Assigned to barcode",
        'description': 'Clusters assigned to barcodes',
        'format': '{:,.0f}',
        'max': largest_value,
    }
    headers['unexpected'] = {
        'title' : "Unassigned",
        'description': 'Unassigned clusters',
        'format': '{:,.0f}',
        'max': largest_value,
    }
    headers['fraction_expected'] = {
        'title' : "Expected (%)",
        'description': 'Percentage of the lane assigned to barcodes',
        'suffix': '%',
        'format': '{:,.1f}',
    }
    return table.plot(self.unexpected_per_lane, headers, {"col1_header": "Lane"})
