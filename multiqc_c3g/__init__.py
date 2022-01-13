#!/usr/bin/env python

from pkg_resources import get_distribution
from multiqc.utils import config

__version__ = get_distribution("multiqc_c3g").version
config.multiqc_c3g_version = __version__

