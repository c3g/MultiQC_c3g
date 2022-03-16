#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from __future__ import print_function
from collections import OrderedDict
import logging
import json
from re import S

from multiqc import config
from multiqc.modules.base_module import BaseMultiqcModule

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(BaseMultiqcModule):
    def __init__(self):

        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Genpipes",
            target="Genpipes",
            anchor="genpipes",
            href="https://github.com/c3g/runprocesing_plugin",
            info=" files from run processing output",
        )

        self.data = dict()
