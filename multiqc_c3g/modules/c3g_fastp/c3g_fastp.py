#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from collections import OrderedDict
import logging
import json

from multiqc import config
from multiqc.plots import linegraph

from multiqc_c3g.runprocessing_base import RunProcessingBaseModule

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(RunProcessingBaseModule):
    doi = ["10.1093/bioinformatics/bty560"]

    def __init__(self):

        super(MultiqcModule, self).__init__(
            name="FastP",
            target="FastP",
            anchor="fastp",
            href="https://github.com/OpenGene/fastp",
            info=" outputs presented in more detail.",
        )

        # Halt execution if we've disabled the plugin
        if not config.kwargs.get("runprocessing", False):
            return None

        ## Parse Genpipes JSON files into the self.generaljson dict ##
        sample_data = {}
        duplication_data = {}
        quality_curves_read1 = {}
        quality_curves_read2 = {}
        for f in self.find_log_files("c3g_fastp/json"):
            s_name = f['s_name']
            d = self.parse_fastp_jsons(f)
            duplication_data[s_name] = d.pop("duplication_histogram",[])
            quality_curves_read1[s_name] = d.pop("quality_curves_read1",[])
            quality_curves_read2[s_name] = d.pop("quality_curves_read2",[])
            sample_data.update({s_name:d})
            self.add_data_source(f, s_name, section="fastp")

        headers = OrderedDict()
        headers['clusters'] = {
            'title': 'Clusters',
            'floor' : 0,
            'format': '{:,.0f}'
        }
        headers['yield'] = {
            'title': 'Sample Yield',
            'floor' : 0,
            'format': '{:,.0f}'
        }
        headers['gc'] = {
            'title': 'Raw GC',
            'modify': lambda x: x * 100,
            'suffix': "%",
            'max': 100,
            'hidden': True,
        }
        headers['Project'] = {
            'title': 'Project',
            'description': 'Project ID',
        }
        headers['Lane'] = {
            'title': 'Lane',
            'description': 'Flowcell lane',
            'hidden': True,
        }
        headers['Duplication'] = {
            'title': 'Duplication',
            'description':'Estimated duplication rate',
            'suffix': "%",
        }
        headers['q30_rate'] = {
            'title': 'Q30 rate',
            'modify': lambda x: x * 100,
            'description':'Reads > Q30',
            'suffix': "%",
            'max': 100
        }
        headers['q20_rate'] = {
            'title': 'Q20 rate',
            'modify': lambda x: x * 100,
            'description':'Reads > Q30',
            'suffix': "%",
            'max': 100,
            "hidden": True,
        }
        headers['blast_hit_1_name'] = {
            'title': 'Top Blast Hit'
        }

        self.generaljson_data = {s_name: data for s_name, data in sample_data.items()}
        self.general_stats_addcols(self.generaljson_data, headers)

        if(len(quality_curves_read1) > 0):
            self.add_section (
                name = 'Base quality',
                anchor = 'genpipes-fastp-quality',
                plot = linegraph.plot(
                    [
                        quality_curves_read1,
                        quality_curves_read2
                    ],
                    {
                        'ymin': 0,
                        'data_labels':[
                            {'name': 'Read 1', 'ylab': 'Phred quality', 'xlab': 'Cycle'},
                            {'name': 'Read 2', 'ylab': 'Phred quality', 'xlab': 'Cycle'},
                        ]
                    }
                )
            )

    def parse_fastp_jsons(self, f):
        try:
            parsed_json = json.loads(f["f"])
        except:
            log.warning("Could not parse fastp JSON: '{}'".format(f["fn"]))
            return None

        if "summary" not in parsed_json:
            log.warn("Could not find 'summary' section in fastp json '{}'".format(f['fn']))
            return None

        data = {}
        data["clusters"] = parsed_json["read1_before_filtering"]["total_reads"]
        data["yield"] = parsed_json["summary"]["before_filtering"]["total_bases"]
        data["gc"] = parsed_json["summary"]["before_filtering"]["gc_content"]
        data["q30_rate"] = parsed_json["summary"]["before_filtering"]["q30_rate"]
        data["q20_rate"] = parsed_json["summary"]["before_filtering"]["q20_rate"]
        data["Duplication"] = parsed_json["duplication"]["rate"] * 100
        histogram_values = parsed_json["duplication"]["histogram"]
        data['duplication_histogram'] = {i+1 : v for i, v in enumerate(histogram_values)}
        quality_values_1 = parsed_json["read1_before_filtering"]["quality_curves"]["mean"]
        quality_values_2 = parsed_json["read2_before_filtering"]["quality_curves"]["mean"]
        data['quality_curves_read1'] = {i+1 : v for i, v in enumerate(quality_values_1)}
        data['quality_curves_read2'] = {i+1 : v for i, v in enumerate(quality_values_2)}
        return data
