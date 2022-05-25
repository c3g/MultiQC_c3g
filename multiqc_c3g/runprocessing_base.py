#!/usr/bin/env python
""" C3G Genpipes JSON plugin module

Overloading the clean_s_name to pull out the lane name from the file path.
"""

from multiqc.modules.base_module import BaseMultiqcModule
from multiqc.utils import config

from pathlib import PurePath
import re

# Middle class
class RunProcessingBaseModule(BaseMultiqcModule):

    def __init__(self, **kwargs):
        super(RunProcessingBaseModule, self).__init__(**kwargs)

    def get_lane_from_path(self, path):
        dirmatcher = re.compile("[(Una)(A)]ligned\.(?P<lane>\d+)")
        for dir in PurePath(path).parts:
            m = dirmatcher.search(dir)
            if m:
                return m.group("lane")
        return None

    def get_lane(self, f):
        return self.get_lane_from_path(f['root'])

    def clean_s_name(self, s_name, f=None, root=None, filename=None, search_pattern_key=None, lane=None):
        s_name = super().clean_s_name(s_name, f, root, filename, search_pattern_key)
        if lane:
            return "L{} | {}".format(lane, s_name)
        lane_from_path = self.get_lane(f)
        if lane_from_path:
            return "L{} | {}".format(lane_from_path, s_name)

        return s_name
