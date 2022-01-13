#!/usr/bin/env python

"""
MultiQC_c3g is a plugin for MultiQC, providing additional tools which are
specific to the GenPipes pipelines developed at the
Canadian Centre for Computational Genomics (C3G).
For more information about C3G, see http://www.computationalgenomics.ca/
For more information about GenPipes, see https://bitbucket.org/mugqic/genpipes
For more information about MultiQC, see http://multiqc.info
"""

from setuptools import setup, find_packages


version = '1.0.0'


print("""-----------------------------------
 Installing MultiQC C3G plugin version {}
-----------------------------------
""".format(version))



setup(
    name = 'multiqc_c3g',
    version = version,
    author = 'C3G Tech. Dev. Team',
    author_email = 'info@computationalgenomics.ca',
    description = "MultiQC plugin for C3G at the McGill University and Genome Quebec Innovation Center, Montreal, Canada",
    long_description = __doc__,
    keywords = 'bioinformatics',
    url = 'https://bitbucket.org/mugqic/multiqc_c3g/overview',
    download_url = 'https://bitbucket.org/mugqic/multiqc_c3g/overview',
    license = 'GNU GPL3',
    packages = find_packages(),
    include_package_data = True,
    install_requires = [
        'multiqc>=1.5',
        'bs4>=0.0.1',
        'pybtex>=0.24.0'
    ],
    entry_points = {
        'multiqc.modules.v1': [
            # 'ihec = multiqc_c3g.modules.ihec:MultiqcModule',
            # 'sleuth = multiqc_c3g.modules.sleuth:MultiqcModule',
            # 'kallisto_c3g = multiqc_c3g.modules.kallisto_c3g:MultiqcModule',
            'c3g_content_renderer = multiqc_c3g.modules.c3g_content_renderer:MultiqcModule',
            'c3g_image_renderer = multiqc_c3g.modules.c3g_image_renderer:MultiqcModule',
            'c3g_table_renderer = multiqc_c3g.modules.c3g_table_renderer:MultiqcModule',
            'c3g_section_renderer = multiqc_c3g.modules.c3g_section_renderer:MultiqcModule',
            'references = multiqc_c3g.modules.references:MultiqcModule',
        ],

        'multiqc.templates.v1': [
        ## add one for every experiment type
            # 'c3g = multiqc_c3g.templates.c3g',
            # 'chip = multiqc_c3g.templates.chip',
            # 'hic = multiqc_c3g.templates.hic',
            'c3g = multiqc_c3g.templates.c3g',
            'chipseq = multiqc_c3g.templates.chipseq',
            'rnaseq = multiqc_c3g.templates.rnaseq',
        ],
        'multiqc.cli_options.v1': [
            'enable = multiqc_c3g.cli:enable_c3g',
            'project = multiqc_c3g.cli:project_c3g'
        ],
        ## points of entry into main run: possible hookup insertions:
        #'before_config'
        #'config_loaded'
        #'execution_start'
        #'before_modules'
        #'after_modules'
        #'before_report_generation'
        #'before_template'
        #'execution_finish'
        'multiqc.hooks.v1': [
            'execution_start = multiqc_c3g.multiqc_c3g:c3g_execution',
        ]
    },
    classifiers = [
        'Development Status :: 4 - Beta',
        'Environment :: Console',
        'Environment :: Web Environment',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: GNU GPL3',
        'Natural Language :: English',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: POSIX',
        'Operating System :: Unix',
        'Programming Language :: Python',
        'Programming Language :: JavaScript',
        'Topic :: Scientific/Engineering',
        'Topic :: Scientific/Engineering :: Bio-Informatics',
        'Topic :: Scientific/Engineering :: Visualization',
    ],
)

print("""
--------------------------------
 MultiQC C3G plugin installation complete!
--------------------------------
For help in running MultiQC, please see the documentation available
at http://multiqc.info or run: multiqc --help
For C3G specific bugs and issues, contact us at info@computationalgenomics.ca
""")
