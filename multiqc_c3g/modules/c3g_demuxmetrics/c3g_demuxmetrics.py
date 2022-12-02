#!/usr/bin/env python

""" C3G Genpipes alignment metrics module """

from __future__ import print_function
import logging
from pathlib import PurePath
import re
from typing import OrderedDict

from multiqc import config
from multiqc.modules.base_module import BaseMultiqcModule

from . import DemuxFastqs
from . import CountIlluminaBarcodes

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(BaseMultiqcModule):
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
        n["DemuxFastqs"] = DemuxFastqs.parse_reports(self)
        if n["DemuxFastqs"]:
            log.info("Found DemuxFastqs report: {}".format(n["DemuxFastqs"]))
        n["CountIlluminaBarcodes"] = CountIlluminaBarcodes.parse_reports(self)
        if n["CountIlluminaBarcodes"]:
            log.info("Found CountIlluminaBarcodes report {} ".format(n["CountIlluminaBarcodes"]))
