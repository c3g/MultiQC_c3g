#!/usr/bin/env python

""" MultiQC submodule to parse output from Picard AlignmentSummaryMetrics """

from collections import OrderedDict
import logging
import os
import re

# Initialise the logger
log = logging.getLogger(__name__)


def parse_reports(self):
    """Find TargetCoverageMetrics reports and parse their data"""

    # Set up vars
    self.target_coverage_metrics = dict()

    # Go through logs and find Metrics
    for f in self.find_log_files("genpipes/target_coverage_metrics", filehandles=True):
        s_name = self.clean_s_name(f['fn'], f)
        parsed_data = dict()
        keys = None
        keys = f["f"].readline().strip("\n").split("\t")
        vals = f["f"].readline().strip("\n").split("\t")
        for i, k in enumerate(keys):
            val = vals[i]
            if i == 0: continue
            if val == "NA": continue
            try:
                parsed_data[k] = float(val)
            except ValueError:
                try:
                    parsed_data[k] = float(val.replace(",", "."))
                    log.debug(
                        "Switching commas for points in '{}': {} - {}".format(
                            f["fn"], val, val.replace(",", ".")
                        )
                    )
                except ValueError:
                    parsed_data[k] = val
        self.target_coverage_metrics[s_name] = parsed_data


    self.general_stats_headers["MeanCoverage"] = {
        "title": "Mean Coveage",
        "description": "Mean coverage of genome with mapped reads (X)",
        "min": 0,
        "suffix": "X",
        "format": "{:,.1f}",
        "scale": "GnBu",
        "hidden": False,
    }

    self.general_stats_headers["PctBasesCoveredAt10x"] = {
        "title": "Coverage at 10X",
        "description": "Percentage of genome covered at 10x",
        "min": 0,
        "suffix": "%",
        "format": "{:,.1f}",
        "scale": "GnBu",
        "hidden": True,
    }

    self.general_stats_headers["PctBasesCoveredAt25x"] = {
        "title": "Coverage at 25X",
        "description": "Percentage of genome covered at 25x",
        "min": 0,
        "suffix": "%",
        "format": "{:,.1f}",
        "scale": "GnBu",
        "hidden": False,
    }

    for s_name in self.target_coverage_metrics:
        if s_name not in self.general_stats_data:
            self.general_stats_data[s_name] = dict()
        self.general_stats_data[s_name].update(self.target_coverage_metrics[s_name])

    # Return the number of detected samples to the parent module
    return len(self.target_coverage_metrics)