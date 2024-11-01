#!/usr/bin/env python

""" C3G Genpipes alignment metrics module """

from __future__ import print_function
import logging
from pathlib import PurePath
import re
from typing import OrderedDict

from multiqc.base_module import BaseMultiqcModule

from . import InsertSizeMetrics
from . import AlignmentSummaryMetrics
from . import TargetCoverageMetrics
from . import AlignmentDuplicationMetrics

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(BaseMultiqcModule):
    def __init__(self):

        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Alignment Metrics",
            target="Alignments",
            anchor="c3g_alignments",
            href="https://github.com/c3g/runprocesing_plugin",
            info=" files from run processing output",
        )

        self.general_stats_headers = OrderedDict()
        self.general_stats_data = dict()

        n = dict()
        n["AlignmentMetrics"] = AlignmentSummaryMetrics.parse_reports(self)
        if n["AlignmentMetrics"] > 0:
            log.info("Found {} AlignmentSummaryMetrics reports".format(n["AlignmentMetrics"]))
        n["InsertSizeMetrics"] = InsertSizeMetrics.parse_reports(self)
        if n["InsertSizeMetrics"] > 0:
            log.info("Found {} InsertSizeMetrics reports".format(n["InsertSizeMetrics"]))
        n["TargetCoverageMetrics"] = TargetCoverageMetrics.parse_reports(self)
        if n["TargetCoverageMetrics"] > 0:
            log.info("Found {} TargetCoverageMetrics reports".format(n["TargetCoverageMetrics"]))
        n["AlignmentDuplicationMetrics"] = AlignmentDuplicationMetrics.parse_reports(self)
        if n["AlignmentDuplicationMetrics"] > 0:
            log.info("Found {} AlignmentDuplicationMetrics reports".format(n["AlignmentDuplicationMetrics"]))

        self.general_stats_addcols(self.general_stats_data, self.general_stats_headers)


    def clean_s_name(self, s_name, f=None, root=None, filename=None, search_pattern_key=None, lane=None):
        s_name = super().clean_s_name(s_name, f, root, filename, search_pattern_key)
        if lane:
            return "L{} | {}".format(lane, s_name)
        lane = None
        dirmatcher = re.compile("[(Una)(A)]ligned\.(?P<lane>\d+)")
        for dir in PurePath(f["root"]).parts:
            m = dirmatcher.search(dir)
            if m:
                lane = m.group("lane")
                return "L{} | {}".format(lane, s_name)

        return s_name

    # Helper functions
    def multiply_hundred(self, val):
        try:
            val = float(val) * 100
        except ValueError:
            pass
        return val
