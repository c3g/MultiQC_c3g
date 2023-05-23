""" MultiQC module to render multiple sections across different modules together"""

from __future__ import print_function
import logging

from multiqc_c3g.modules.c3g_yaml_parser import c3g_yaml_parser

from multiqc import config
from multiqc.modules.base_module import BaseMultiqcModule

# Start the logger
log = logging.getLogger(__name__)
# Starting the MultiqcModule class to use multiqc name space
class MultiqcModule(BaseMultiqcModule):
    def __init__(self):

        # Initialise the parent object
        super(MultiqcModule, self).__init__(
             name="c3g_section_renderer",
             anchor="c3g_section_renderer",
             )
        log.debug('The c3g_section_renderer module has just started')
