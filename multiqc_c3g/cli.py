#!/usr/bin/env python
""" MultiQC command line options - we tie into the MultiQC
core here and add some new command line parameters. """

import click

##project_c3g adds the project type: rnaseq, chipseq, danseq, hicseq... in order to define the layout and the template type

enable_c3g = click.option('-c3g', '--enable-c3g', 'enable_c3g',
    is_flag = True,
    help = "Enable the MultiQC_C3G plugin on this run"
)

project_c3g = click.option('--project', 'project',
    default = "default",
    help = "Defines the technology type in order to customize the report"
)