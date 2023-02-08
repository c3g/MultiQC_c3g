#!/usr/bin/env python

""" C3G Genpipes alignment metrics module """

from __future__ import print_function
import logging
from pathlib import PurePath
import re
from typing import OrderedDict

from multiqc import config
from multiqc_c3g.runprocessing_base import RunProcessingBaseModule

from . import DemuxFastqs
from . import CountIlluminaBarcodes
from . import bcl2fastq

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

        n = dict()
        n["Bcl2Fastq"] = bcl2fastq.parse_reports(self)
        if n["Bcl2Fastq"] > 0:
            log.info("Found {} Bcl2Fastq reports".format(n["Bcl2Fastq"]))

        n["CountIlluminaBarcodes"] = CountIlluminaBarcodes.parse_reports(self)
        if n["CountIlluminaBarcodes"] > 0:
            log.info("Found {} CountIlluminaBarcodes reports".format(n["CountIlluminaBarcodes"]))

        n["DemuxFastqs"] = DemuxFastqs.parse_reports(self)
        if n["DemuxFastqs"] > 0:
            log.info("Found {} DemuxFastqs reports".format(n["DemuxFastqs"]))


    
