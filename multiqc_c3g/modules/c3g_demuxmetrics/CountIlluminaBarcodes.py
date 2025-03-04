#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from __future__ import print_function
from collections import OrderedDict
from io import StringIO
import logging
import csv
import json
import re

from multiqc_c3g.modules.c3g_runprocessing.validationreport import ValidationReport

from multiqc.plots import table

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

def get_lane_from_file_name(f_name):
    matcher = re.compile(r".*_(?P<lane>\d+)\.metrics")
    m = matcher.search(f_name)
    if m:
        return m.group("lane")
    log.error(f"Could not determine lane from {f_name}")
    return None

def parse_reports(self):

    ## Parse CountIlluminaBarcodes output files
    expected_count_data = dict()
    expected_breakdown_data = dict()
    unexpected_data = dict()
    report_found = []

    for f in self.find_log_files("c3g_demuxmetrics/count_illumina_barcodes"):
        metrics_per_lane = get_metrics(self, f)
    
        expected_count_data = {**expected_count_data, **metrics_per_lane['count']}
        expected_breakdown_data = {**expected_breakdown_data, **metrics_per_lane['breakdown']}
        unexpected_data = {**unexpected_data, **metrics_per_lane['unexpected']}

        report_found.append(f['fn'])

    if report_found:
        largest_total = max([y['read_count'] for (_,y) in expected_count_data.items()])
        headers = OrderedDict()
        headers['barcode'] = {
            'title' : "Barcode",
            'description': 'Barcode sequence',
            'max': largest_total
        }
        headers['read_count'] = {
            'title': 'Total',
            'description': 'Total number of reads assigned to barcode',
            # 'modify': lambda x: x * config.read_count_multiplier,
            # 'suffix': config.read_count_prefix,
            'format': '{:,.0f}',
            'max': largest_total
        }
        headers['project'] = {
            'title': 'Project',
            'description': 'Project of the sample',
            # 'modify': lambda x: x * config.read_count_multiplier,
            # 'suffix': config.read_count_prefix,
            'format': '{:,.0f}',
            'max': largest_total,
        }
        headers['sample_name'] = {
            'title': 'Sample',
            'description': 'Namen of the sample',
            'max': largest_total
        }
        headers['fraction_matches'] = {
            'title' : "Lane composition (%)",
            'description': 'Percentage of the lane assigned to this barcode',
            'suffix': '%',
            'modify': lambda x: float(x) * 100,
            'format': '{:,.1f}'
        }
        if not all([y['percent_expected'] is None for (_,y) in expected_count_data.items()]):
            headers['percent_expected'] = {
                'title' : "Pct from Expected (%)",
                'description': 'Percentage of the lane assigned to this barcode, accounting for the pool fraction',
                'suffix': '%',
                'modify': lambda x: float(x) * 100,
                'format': '{:,.1f}'
            }
        self.add_section(
            name = "Expected Barcodes - Read counts",
            description = "The counts for expected barcodes are shown below. Note that percentage is relative to the lane, not the run as a whole.",
            plot = table.plot(expected_count_data, headers, {"id": "ExpectedBarcodes", "title": "Expected Barcodes", "no_violin": True})
        )

        largest_total = max([y['read_count'] for (_,y) in expected_breakdown_data.items()])
        headers = OrderedDict()
        headers['read_count'] = {
            'title': 'Reads',
            'description': 'Number of reads assigned to this barcode sequence',
            # 'modify': lambda x: x * config.read_count_multiplier,
            # 'suffix': config.read_count_prefix,
            'format': '{:,.0f}',
            'max': float(largest_total)
        }
        headers['sequence'] = {
            'title': 'Sequence',
            'description': 'Sequence that matched the barcode',
        }
        self.add_section(
            name = "Expected Barcodes - Breakdown per index",
            description = "CountIlluminaBarcodes breakdown per index, top 20 per index.",
            plot = table.plot(expected_breakdown_data, headers, {"id": "ExpectedPerIndex", "title": "Expected Barcodes Per Index", "no_violin": True})
        )

        largest_total = max([y['read_count'] for (_,y) in unexpected_data.items()])
        headers = OrderedDict()
        headers['read_count'] = {
            'title': 'Reads',
            'description': 'Total number of reads assigned to barcode sequence',
            # 'modify': lambda x: x * config.read_count_multiplier,
            # 'suffix': config.read_count_prefix,
            'format': '{:,.0f}',
            'max': float(largest_total)
        }
        headers['barcode_names'] = {
            'title': 'Barcode name(s)',
            'description': 'Name of unexpected found barcode sequence',
        }
        self.add_section(
            name = "Barcodes - Unexpected",
            description = "Overview of number of clusters assigned to unexpected barcodes. Only showing top 20 unexpected barcodes per lane.",
            plot = table.plot(unexpected_data, headers, {"id": "UnexpectedBarcodes", "title": "Unexpected Barcodes", "no_violin": True})
        )

    # Return the number of detected samples to the parent module
    return len(report_found)

def get_metrics(self, f):
    metrics = dict()

    lane = get_lane_from_file_name(f['fn'])
    expected_barcodes = get_expected(self, lane)

    buff = StringIO(f['f'])
    records = list(csv.DictReader(filter(lambda row: row != '\n' and row[0]!='#', buff), delimiter='\t', quotechar='"'))
    records.sort(key=lambda row: int(row['PF_READS']), reverse=True)
    filter(lambda row: int(row['PF_READS']) != 0, records)

    metrics['count'] = expected_metrics_count(self, records, expected_barcodes, lane)
    metrics['breakdown'] = expected_metrics_breakdown(self, records, expected_barcodes, lane)
    metrics['unexpected'] = unexpected_metrics(self, records, expected_barcodes, lane)

    return metrics

def get_expected(self, lane):
    # Use the run_processing_json corresponding to the current metrics report
    # to build a dict of expected index
    expected_barcodes = None
    report_found = None
    for j in self.find_log_files("c3g_runprocessing"):
        report = ValidationReport(json.loads(j["f"]))
        if int(report.lane) == int(lane):
            report_found = j['fn']
            expected_barcodes = {
                readset.index_name: {
                    'barcode': readset.index_name if "SI-" in readset.index_name else readset.index_name.split('-')[0],
                    'project': readset.project,
                    'sample_name': readset.name,
                    'lib_type': readset.library_type,
                    'pool_fraction': readset.pool_fraction
                } for readset in report.readsets
            }
            break
    if not report_found:
        log.error(f"Could not find run_processing json report for lane '{lane}'")
    elif not expected_barcodes:
        log.error(f"Could not determined expected barcodes from '{report_found}'...")
    return expected_barcodes

def expected_metrics_count(self, records, expected_barcodes, lane):
    metrics_count = dict()

    total_reads = sum([int(row['PF_READS']) for row in records])

    for barcode, d in expected_barcodes.items():
        d['read_count'] = sum([int(row['PF_READS']) for row in records if len(list(filter(lambda found: d['barcode'] in found, row['BARCODE_NAMES'].split(','))))])
        d['fraction_matches'] = d['read_count'] / float(total_reads)
        d['percent_expected'] = d['fraction_matches'] / d['pool_fraction'] if d['pool_fraction'] else None

        s_name = self.clean_s_name(barcode, lane=lane)
        metrics_count[s_name] = d

    return metrics_count

def expected_metrics_breakdown(self, records, expected_barcodes, lane):
    metrics_breakdown = dict()
    
    for _, d in expected_barcodes.items():
        for row in records:
            if row['BARCODE_NAMES'] and int(row['PF_READS']) > 0 and len(list(filter(lambda barcode_name: d['barcode'] in barcode_name, row['BARCODE_NAMES'].split(',')))):
                s_name = self.clean_s_name(row['BARCODE_NAMES'], lane=lane)
                metrics_breakdown[s_name] = {
                    'read_count': row['PF_READS'],
                    'sequence': row['BARCODE']
                }

    return metrics_breakdown

def unexpected_metrics(self, records, expected_barcodes, lane):
    unexpected_metrics = dict()

    for _, d in expected_barcodes.items():
        for row in records:
            if row['BARCODE_NAMES'] and int(row['PF_READS']) > 0 and not len(list(filter(lambda barcode_name: d['barcode'] in barcode_name, row['BARCODE_NAMES'].split(',')))):
                s_name = self.clean_s_name(row['BARCODE'], lane=lane)
                unexpected_metrics[s_name] = {
                    'read_count': int(row['PF_READS']),
                    'barcode_names': row['BARCODE_NAMES']
                }
    # keep only top 20 most common unexpected barcodes per lane
    unexpected_metrics = OrderedDict(sorted(unexpected_metrics.items(), key=lambda x: x[1]['read_count'], reverse=True)[:20])
    return unexpected_metrics
