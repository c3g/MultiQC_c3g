#!/usr/bin/env python
""" MultiQC module to parse output from Sleuth """

import logging
from multiqc import config
from multiqc.base_module import BaseMultiqcModule


# Initialise the logger
log = logging.getLogger('multiqc')


class MultiqcModule(BaseMultiqcModule):
    """Sleuth is a program for analysis of RNA-Seq experiments for which transcript abundances have been quantified with kallisto. This Module produces:
    XYZ
    """

    def __init__(self):

        # Halt execution if we've disabled the plugin
        if not config.kwargs.get('enable_c3g', True):
            return None


        # Initialise the parent object
        super(MultiqcModule, self).__init__(
            name='Sleuth',
            anchor='sleuth',
            href='https://pachterlab.github.io/sleuth/about.html',
            info="sleuth is a program for analysis of RNA-Seq experiments for which transcript abundances have been quantified with kallisto")


## Start Code here:

    # log.info('Hello World! Sleuth is Alive!')
