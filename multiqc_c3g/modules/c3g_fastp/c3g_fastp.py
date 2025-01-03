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
            anchor="c3g_fastp",
            href="https://github.com/OpenGene/fastp",
            info=" outputs presented in more detail.",
            doi = ["10.1093/bioinformatics/bty560"]
        )

        # Halt execution if we've disabled the plugin
        if not config.kwargs.get("runprocessing", False):
            return None

        raw_quality_curves_read1 = {}
        raw_quality_curves_read2 = {}
        sample_data = {}
        duplication_data = {}
        quality_curves_read1 = {}
        quality_curves_read2 = {}
        quality_curves_idx1 = {}
        quality_curves_idx2 = {}
        for f in self.find_log_files("c3g_fastp"):
            lane = self.get_lane(f)
            s_name = f['s_name']
            d = self.parse_fastp_jsons(f)
            if 'raw_reads' in s_name:
                raw_quality_curves_read1[s_name] = d.pop("quality_curves_read1",[])
                if "quality_curves_read2" in d:
                    raw_quality_curves_read2[s_name] = d.pop("quality_curves_read2",[])
            elif 'barcodes' in s_name:
                quality_curves_idx1[s_name] = d.pop("quality_curves_read1",[])
                if "quality_curves_read2" in d:
                    quality_curves_idx2[s_name] = d.pop("quality_curves_read2",[])
            else:
                duplication_data[s_name] = d.pop("duplication_histogram",[])
                quality_curves_read1[s_name] = d.pop("quality_curves_read1",[])
                if "quality_curves_read2" in d:
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
            'format': '{:,.0f}',
            'hidden': True
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

        # if(len(raw_quality_curves_read1) > 0):
            
        #     self.add_section (
        #         name = 'Raw reads base quality (no demultiplexing nor index removal)',
        #         anchor = 'genpipes-fastp-raw-reads-quality',
        #         plot = linegraph.plot(
        #             [
        #                 raw_quality_curves_read1,
        #                 raw_quality_curves_read2
        #             ] if len(raw_quality_curves_read2) > 0 else [ raw_quality_curves_read1 ],
        #             {
        #                 'ymin': 0,
        #                 'data_labels':[
        #                     {'name': 'Raw Read 1', 'ylab': 'Phred quality', 'xlab': 'Cycle'},
        #                     {'name': 'Raw Read 2', 'ylab': 'Phred quality', 'xlab': 'Cycle'},
        #                 ]
        #             }
        #         )
        #     )

        quality_curves = []
        data_labels = []
        if(len(quality_curves_read1) > 0):
            quality_curves.append(quality_curves_read1)
            data_labels.append({'name': 'Read 1', 'ylab': 'Phred quality', 'xlab': 'Cycle'})
        if (len(quality_curves_read2) > 0):
            quality_curves.append(quality_curves_read2)
            data_labels.append({'name': 'Read 2', 'ylab': 'Phred quality', 'xlab': 'Cycle'})
        if(len(quality_curves_idx1) > 0):
            quality_curves.append(quality_curves_idx1)
            data_labels.append({'name': 'Index 1', 'ylab': 'Phred quality', 'xlab': 'Cycle'})
        if (len(quality_curves_idx2) > 0):
            quality_curves.append(quality_curves_idx2)
            data_labels.append({'name': 'Index 2', 'ylab': 'Phred quality', 'xlab': 'Cycle'})
        if(len(raw_quality_curves_read1) > 0):
            quality_curves.append(raw_quality_curves_read1)
            data_labels.append({'name': 'Raw Read 1', 'ylab': 'Phred quality', 'xlab': 'Cycle'})
        if (len(raw_quality_curves_read2) > 0):
            quality_curves.append(raw_quality_curves_read2)
            data_labels.append({'name': 'Raw Read 2', 'ylab': 'Phred quality', 'xlab': 'Cycle'})
        
        if(len(quality_curves_read1) > 0):
            self.add_section (
                name = 'Base quality',
                anchor = 'genpipes-fastp-quality',
                plot = linegraph.plot(
                    quality_curves,
                    {
                        'ymin': 0,
                        'data_labels': data_labels,
                        'id': 'fastp',
                        'title': 'fastp'
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
            log.warning("Could not find 'summary' section in fastp json '{}'".format(f['fn']))
            return None

        data = {}
        data["clusters"] = parsed_json["read1_before_filtering"]["total_reads"]
        data["yield"] = parsed_json["summary"]["before_filtering"]["total_bases"]
        data["gc"] = parsed_json["summary"]["before_filtering"]["gc_content"]
        data["q30_rate"] = parsed_json["summary"]["before_filtering"]["q30_rate"]
        data["q20_rate"] = parsed_json["summary"]["before_filtering"]["q20_rate"]
        data["Duplication"] = parsed_json["duplication"]["rate"] * 100
        # histogram_values = parsed_json["duplication"]["histogram"]
        # data['duplication_histogram'] = {i+1 : v for i, v in enumerate(histogram_values)}
        quality_values_1 = parsed_json["read1_before_filtering"]["quality_curves"]["mean"]
        data['quality_curves_read1'] = {i+1 : v for i, v in enumerate(quality_values_1)}
        if "read2_before_filtering" in parsed_json:
            quality_values_2 = parsed_json["read2_before_filtering"]["quality_curves"]["mean"]
            data['quality_curves_read2'] = {i+1 : v for i, v in enumerate(quality_values_2)}
        return data
