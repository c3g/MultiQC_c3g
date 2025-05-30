#!/usr/bin/env python
""" C3G Genpipes JSON plugin module

Overloading the clean_s_name to pull out the lane name from the file path.
"""

from multiqc.base_module import BaseMultiqcModule

from pathlib import PurePath
import re

# Middle class
class RunprocessingMultiqcModule(BaseMultiqcModule):

    def __init__(self, **kwargs):
        super(RunprocessingMultiqcModule, self).__init__(**kwargs)

    def get_lane(self, path):
        dirmatcher = re.compile("[(Una)(A)]ligned\.(?P<lane>\d+)")
        for dir in PurePath(path).parts:
            m = dirmatcher.search(dir)
            if m:
                return m.group("lane")
        return None

    def clean_s_name(self, s_name, f=None, root=None, filename=None, search_pattern_key=None, fn_clean_exts = None, fn_clean_trim = None, prepend_dirs = None, lane=None):
        s_name = super().clean_s_name(s_name, f, root, filename, search_pattern_key, fn_clean_exts, fn_clean_trim, prepend_dirs)
        if lane:
            return "L{} | {}".format(lane, s_name)
        lane_from_path = self.get_lane(f['root'])
        if lane_from_path:
            return "L{} | {}".format(lane_from_path, s_name)

        return s_name
