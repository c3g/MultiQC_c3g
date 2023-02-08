"""
=========
 c3g
=========
This theme extends 'default'.  It is specificly designed for use with
c3g reports.
"""
import os

template_parent = "default"

template_dir = os.path.dirname(__file__)
print(template_dir)
base_fn = "base.html"
footer_fn = "footer.html"