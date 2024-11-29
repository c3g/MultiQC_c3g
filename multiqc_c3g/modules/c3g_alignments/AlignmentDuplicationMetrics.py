#!/usr/bin/env python

""" C3G MultiQC submodule to parse output from Picard MarkDuplicates  """

from collections import OrderedDict
import logging
import os
import re

# Initialise the logger
log = logging.getLogger(__name__)


def parse_reports(self):
    """Find Picard AlignmentDuplicationMetrics reports and parse their data"""

    # Set up vars
    self.picard_duplication_metrics = dict()

    # Go through logs and find Metrics
    for f in self.find_log_files("c3g_alignments/alignment_duplication_metrics", filehandles=True):
        parsed_data = dict()
        s_name = None
        keys = None
        for l in f["f"]:
            # New log starting
            if "MarkDuplicates" in l and "INPUT" in l:
                s_name = None
                keys = None
                # Pull sample name from input
                fn_search = re.search(r"INPUT(?:=|\s+)(\[?[^\s]+\]?)", l, flags=re.IGNORECASE)
                if fn_search:
                    s_name = os.path.basename(fn_search.group(1).strip("[]"))
                    s_name = self.clean_s_name(s_name, f)
                    parsed_data[s_name] = dict()

            if s_name is not None:
                if "DuplicationMetrics" in l and "## METRICS CLASS" in l:
                    keys = f["f"].readline().strip("\n").split("\t")
                elif keys:
                    vals = l.strip("\n").split("\t")
                    if len(vals) == len(keys):
                        for i, k in enumerate(keys):
                            try:
                                parsed_data[s_name][k] = float(vals[i])
                            except ValueError:
                                parsed_data[s_name][k] = vals[i]
                    else:
                        s_name = None
                        keys = None

        # Remove empty dictionaries
        for s_name in list(parsed_data.keys()):
            if len(parsed_data[s_name]) == 0:
                parsed_data.pop(s_name, None)

        # Manipulate sample names if multiple baits found
        for s_name in parsed_data.keys():
            if s_name in self.picard_duplication_metrics:
                log.debug("Duplicate sample name found in {}! Overwriting: {}".format(f["fn"], s_name))
            self.add_data_source(f, s_name, section="AlignmentDuplicationMetrics")
            self.picard_duplication_metrics[s_name] = parsed_data[s_name]

    # Filter to strip out ignored sample names
    self.picard_duplication_metrics = self.ignore_samples(self.picard_duplication_metrics)

    if len(self.picard_duplication_metrics) > 0:

        # Write parsed data to a file
        self.write_data_file(self.picard_duplication_metrics, "multiqc_picard_AlignmentDuplicationMetrics")

        # Add to general stats table
        self.general_stats_headers["PERCENT_DUPLICATION"] = {
            "title": "% Aligned Duplicate Rate",
            "description": "Percent of aligned duplicate reads",
            "max": 100,
            "min": 0,
            "suffix": "%",
            "format": "{:,.2f}",
            "scale": "RdYlGn",
            "modify": lambda x: self.multiply_hundred(x),
            "hidden": True
        }
        for s_name in self.picard_duplication_metrics:
            if s_name not in self.general_stats_data:
                self.general_stats_data[s_name] = dict()
            self.general_stats_data[s_name].update(self.picard_duplication_metrics[s_name])

    # Return the number of detected samples to the parent module
    return len(self.picard_duplication_metrics)