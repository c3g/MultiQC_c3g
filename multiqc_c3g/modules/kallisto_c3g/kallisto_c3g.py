#!/usr/bin/env python
""" MultiQC module to parse output from Kallisto. This is specific to C3G """

import logging
from multiqc import config
from multiqc.modules.base_module import BaseMultiqcModule


# Initialise the logger
log = logging.getLogger('multiqc')


class MultiqcModule(BaseMultiqcModule):
    """kallisto is a program for quantifying abundances of transcripts from RNA-Seq data. This Module produces:
    XYZ
    """

    def __init__(self):

        # Halt execution if we've disabled the plugin
        if not config.kwargs.get('enable_c3g', True):
            return None


        # Initialise the parent object
        super(MultiqcModule, self).__init__(
            name='Kallisto', 
            anchor='kallisto_c3g',
            href='https://pachterlab.github.io/kallisto/about',
            info="kallisto is a program for quantifying abundances of transcripts from RNA-Seq data")
            

## Start Code here:
    
    log.info('Hello World! Kallisto_c3g is Alive!')