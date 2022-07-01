#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from __future__ import print_function
from collections import OrderedDict
from io import StringIO
import logging
import csv

from multiqc import config
from multiqc_c3g.runprocessing_base import RunProcessingBaseModule
from multiqc.plots import table

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(RunProcessingBaseModule):
    def __init__(self):

        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Barcodes",
            target="Barcodes",
            anchor="barcodes",
            href="https://github.com/c3g/runprocesing_plugin",
            info=" files from run processing output",
        )

        # Halt execution if we don't have the runprocessing flag set.
        if not config.kwargs.get("runprocessing", False):
            return None

        ## Parse Genpipes JSON files
        barcode_data = dict()
        unexpected_per_lane = dict()

        for f in self.find_log_files("c3g_demuxmetrics"):
            lane_data = self.expected_metrics(f)
            lane = self.get_lane(f)
            unexpected_per_lane[f"L{lane}"] = self.unexpected_metrics(f)
            barcode_data = {**barcode_data, **lane_data}

        largest_total = max([y['templates'] for (_,y) in barcode_data.items()])
        headers = OrderedDict()
        headers['barcode'] = {
            'title' : "Barcode",
            'description': 'Barcode sequence',
        }
        headers['pf_templates'] = {
            'title': 'Total',
            'description': 'Total number of clusters assigned to barcode',
            # 'modify': lambda x: x * config.read_count_multiplier,
            # 'suffix': config.read_count_prefix,
            'format': '{:,.0f}',
            'max': largest_total,
        }
        headers['perfect_matches'] = {
            'title': 'Perfect',
            'description': 'Number of clusters with perfect barcode sequence',
            # 'modify': lambda x: x * config.read_count_multiplier,
            # 'suffix': config.read_count_prefix,
            'format': '{:,.0f}',
            'max': largest_total,
        }
        headers['one_mismatch_matches'] = {
            'title': 'Imperfect',
            'description': 'Number of clusters assigned to barcode within mismatch distance',
            # 'modify': lambda x: x * config.read_count_multiplier,
            # 'suffix': config.read_count_prefix,
            'format': '{:,.0f}',
            'max': largest_total,
        }
        headers['fraction_matches'] = {
            'title' : "Lane composition (%)",
            'description': 'Percentage of the lane assigned to this barcode',
            'suffix': '%',
            'modify': lambda x: float(x) * 100,
            'format': '{:,.1f}'
        }

        self.add_section(
            name = "Barcodes - Expected",
            description = "The counts for expected barcodes are shown below. Note that percentage is relative to the lane, not the run as a whole.",
            plot = table.plot(barcode_data, headers)
        )

        largest_value = max([max(y['expected'],y['unexpected']) for (_,y) in unexpected_per_lane.items()])
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
            'description': 'Percentage of the lane assigned to this barcode',
            'suffix': '%',
            'modify': lambda x: x * 100,
            'format': '{:,.1f}',
        }
        self.add_section(
            name = "Barcodes - Lane Overview",
            description = "Overview of number of clusters assigned to expected barcodes.",
            plot = table.plot(unexpected_per_lane, headers)
        )


    def unexpected_metrics(self, f):
        buff = StringIO(f['f'])
        reader = csv.DictReader(buff, delimiter="\t")
        expected_total = 0
        unexpected_total = 0
        for row in reader:
            barcode_name = row.pop('barcode_name')
            if barcode_name == "unmatched":
                unexpected_total += int(row['templates'])
            else:
                expected_total += int(row['templates'])
        return {
            "expected": expected_total,
            "unexpected": unexpected_total,
            "fraction_expected": expected_total / float(expected_total + unexpected_total)
        }


    def expected_metrics(self, f):
        metrics = dict()

        buff = StringIO(f['f'])
        reader = csv.DictReader(buff, delimiter="\t")
        for row in reader:
            barcode_name = row.pop('barcode_name')
            if barcode_name != "unmatched":
                s_name = self.clean_s_name(barcode_name, f)
                metrics[s_name] = row

        return metrics

