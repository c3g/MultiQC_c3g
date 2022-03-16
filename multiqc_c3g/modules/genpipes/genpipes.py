#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from ast import parse
from collections import OrderedDict
from pathlib import PurePath
import logging
import json
import re

from multiqc.utils import config
from multiqc.modules.base_module import BaseMultiqcModule
from multiqc.plots import linegraph, table

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(BaseMultiqcModule):
    def __init__(self):

        # Halt execution if we've disabled the plugin
        if config.kwargs.get("disable_plugin", True):
            return None

        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Runprocessing",
            target="Genpipes",
            anchor="genpipes",
            href="https://genpipes.readthedocs.io",
            info=" outputs presented in more detail.",
        )

        ## Parse Genpipes JSON files into the self.generaljson dict ##

        sample_data = {}
        for f in self.find_log_files("genpipes/general_information"):
            d = self.parse_genpipes_general_info_json(f)
            sample_data.update(d)
            for s_name in d:
                self.add_data_source(f, s_name, section="general_information")

        log.info("Found {} samples in {} JSONs".format(
            len(sample_data),
            len(list(self.find_log_files("genpipes/general_information")))))

        duplication_data = {}
        quality_curves_read1 = {}
        quality_curves_read2 = {}
        for f in self.find_log_files("genpipes/fastps"):
            s_name = f['s_name']
            d = self.parse_fastp_jsons(f)
            duplication_data[s_name] = d.pop("duplication_histogram",[])
            quality_curves_read1[s_name] = d.pop("quality_curves_read1",[])
            quality_curves_read2[s_name] = d.pop("quality_curves_read2",[])
            sample_data[s_name].update(d)
            self.add_data_source(f, s_name, section="fastp")

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

        self.add_section (
            name = 'Duplication rate estimation',
            description = 'Estimated duplication rate from sequencing data alone (without alignment). Provided by fastp.',
            anchor = 'genpipes-fastp-duplication',
            plot = linegraph.plot(duplication_data, {'xLabelFormat': '{value}x'})
        )

        unexpected_barcode_data = {}
        for f in self.find_log_files("genpipes/sequencestat", filehandles=True):
            d = self.parse_sequencestat(f, 20)
            unexpected_barcode_data.update(d)

        barcode_to_id = {"L{} | {}".format(data["Lane"], data['Index name']) : s_name for (s_name, data) in sample_data.items()}
        barcode_data = {}
        for f in self.find_log_files("genpipes/barcodestat"):
            d = self.parse_barcodestat(f, barcode_to_id)
            barcode_data.update(d)
            for s_name in barcode_data:
                self.add_data_source(f, s_name, section="barcodestat")


        headers = OrderedDict()
        headers['Correct'] = {
            'title': 'Perfect',
            'description': 'Number of clusters with perfect barcode sequence',
            'modify': lambda x: x * config.read_count_multiplier,
            'suffix': config.read_count_prefix,
            'format': '{:,.0f}'
        }
        headers['Corrected'] = {
            'title': 'Imperfect',
            'description': 'Number of clusters assigned to barcode within mismatch distance',
            'modify': lambda x: x * config.read_count_multiplier,
            'suffix': config.read_count_prefix,
            'format': '{:,.0f}'
        }
        headers['Total'] = {
            'description': 'Total number of clusters assigned to barcode',
            'modify': lambda x: x * config.read_count_multiplier,
            'suffix': config.read_count_prefix,
            'format': '{:,.0f}'
        }
        headers['Percentage(%)'] = {
            'title' : "Lane composition (%)",
            'description': 'Percentage of the lane assigned to this barcode',
            'suffix': '%',
            'format': '{:,.1f}'
        }

        total_matcher = re.compile(" Clusters assigned to barcode$")
        barcode_data_without_totals = {k: barcode_data[k] for k in barcode_data.keys() if not total_matcher.search(k)}
        barcode_data_for_unexpected = {k: barcode_data[k] for k in barcode_data.keys() if total_matcher.search(k)}

        barcode_data_for_unexpected.update(unexpected_barcode_data)

        self.add_section(
            name = "Barcodes - Expected",
            description = "The counts for expected barcodes are shown below. Note that percentage is relative to the lane, not the run as a whole.",
            plot = table.plot(barcode_data_without_totals, headers)
        )

        headers = OrderedDict()
        headers['Total'] = {
            'description': 'Total number of clusters assigned to barcode',
            'modify': lambda x: x * config.read_count_multiplier,
            'suffix': config.read_count_prefix,
            'format': '{:,.0f}'
        }
        headers['Percentage(%)'] = {
            'title' : "Lane composition (%)",
            'description': 'Percentage of the lane assigned to this barcode',
            'suffix': '%',
            'format': '{:,.4f}'
        }
        self.add_section(
            name = "Barcodes - Unexpected",
            description = "The most abundant 20 unexpected barcodes in each lane are shown in the table below.",
            plot = table.plot(
                barcode_data_for_unexpected,
                headers,
                {'col1_header':'Barcode', 'sortRows': False}
            )
        )


        blast_data = {}
        for f in self.find_log_files("genpipes/blastsummary"):
            cleaner_name = re.sub(r'_\d+_L\d+.R1(R2)?.RDP.blastHit_20MF_species.txt', '', f['fn'])
            s_name = self.clean_s_name(cleaner_name, f)
            d = self.parse_blast_results(f)
            sample_data[s_name].update(d)
            blast_data[s_name] = d
            self.add_data_source(f, s_name, section="blast")

        headers = OrderedDict()
        headers['blast_hit_1'] = {'title': 'Top blast hit'}
        headers['blast_hit_2'] = {'title': 'Second blast hit'}
        headers['blast_hit_3'] = {'title': 'Third blast hit'}
        self.add_section(
            name = "Blast hits",
            plot = table.plot(
                {k:
                    {
                    "blast_hit_1": "{} ({} hits)".format(v['blast_hit_1_name'],v['blast_hit_1_count']),
                    "blast_hit_2": "{} ({} hits)".format(v['blast_hit_2_name'],v['blast_hit_2_count']),
                    "blast_hit_3": "{} ({} hits)".format(v['blast_hit_3_name'],v['blast_hit_3_count']),
                    }
                for (k, v) in blast_data.items()}, headers))

        ## General Summary Section
        self.generaljson_data = dict()
        headers = OrderedDict()
        headers['clusters'] = {
            'title': 'Clusters',
            'modify': lambda x: x * config.read_count_multiplier,
            'suffix': config.read_count_prefix,
            'floor' : 0,
            'format': '{:,.0f}'
        }
        headers['yield'] = {
            'title': 'Yield',
            'modify': lambda x: x * config.yield_multiplier,
            'suffix': ' ' + config.yield_prefix,
            'floor' : 0,
            'format': '{:,.0f}'
        }
        headers['gc'] = {
            'title': 'Raw GC',
            'modify': lambda x: x * 100,
            'suffix': "%",
            'max': 100,
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
            'max': 100
        }
        headers['blast_hit_1_name'] = {
            'title': 'Top Blast Hit'
        }

        for (s_name, data) in sample_data.items():
            self.generaljson_data[s_name] = {colname:data[colname] for colname in list(headers.keys()) if colname in data}
        self.generaljson_data = self.ignore_samples(self.generaljson_data)
        self.general_stats_addcols(self.generaljson_data, headers)

    def parse_blast_results(self, f):
        parsed_data = {}
        lines = [line.lstrip(" ").split(" ") for line in f["f"].splitlines()]
        parsed_data["blast_hit_1_name"] = re.sub(r'_', ' ', lines[0][1])
        parsed_data["blast_hit_1_count"] = lines[0][0]
        parsed_data["blast_hit_2_name"] = re.sub(r'_', ' ', lines[1][1])
        parsed_data["blast_hit_2_count"] = lines[1][0]
        parsed_data["blast_hit_3_name"] = re.sub(r'_', ' ', lines[2][1])
        parsed_data["blast_hit_3_count"] = lines[2][0]
        return parsed_data

    def parse_sequencestat(self, f, num_barcodes=20):
        log.info("Parsing sequencestat!")
        headers = None
        parsed_data = dict()
        for l in f['f']:
            if headers is None:
                s = l.lstrip("#").strip().split("\t")
                headers = [item.strip(' ') for item in s]
            else:
                s = [item.strip() for item in l.split("\t")]
                if s[1] != "undecoded": continue
                s_name = self.clean_s_name(s[0],f)
                parsed_data[s_name] = {
                    "Total": s[headers.index("Count")],
                    "Percentage(%)": s[headers.index("Percentage(%)")]
                }
                if len(parsed_data) >= num_barcodes: return parsed_data
        return parsed_data


    def parse_barcodestat(self, f, barcode_to_id):
        parsed_data = dict()
        headers = None
        for l in f["f"].splitlines():
            s = l.split("\t")
            s_name = None
            if headers is None:
                headers = [item.strip(" ") for item in s]
                continue
            elif s[0] == "Total":
                s_name = self.clean_s_name("Clusters assigned to barcode", f)
            elif s[0] != "Total":
                s_name = self.clean_s_name(s[0].lstrip("barcode"), f)
                s_name = barcode_to_id[s_name]
            parsed_data[s_name] = {}
            for i, v in enumerate(s):
                if i != 0:
                    parsed_data[s_name][headers[i]] = float(v)
        return parsed_data

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


    def parse_genpipes_general_info_json(self, f):
        try:
            parsed_json = json.loads(f["f"])
        except:
            log.warning("Could not parse genpipes JSON: '{}'".format(f["fn"]))
            return None

        if "barcodes" not in parsed_json:
            log.warn("Genpipes JSON did not have 'barcodes' key: '{}'".format(f["fn"]))
            return

        run_data = {
            "Run": parsed_json.get("run", "No run found in JSON"),
            "Instrument": parsed_json.get("instrument", "No instrument found in JSON"),
            "Flowcell": parsed_json.get("flowcell", "No flowcell found in JSON"),
            "Lane": parsed_json.get("lane", ""),
            "Seqtype": parsed_json.get("seqtype", "No seqtype found in JSON"),
            "Sequencing method": parsed_json.get("sequencing_method", "No seqmethod found in JSON"),
        }

        if config.report_header_info is None:
            config.report_header_info = []

        # Add run information to report header
        for (key, value) in run_data.items():
            found = False
            for d in config.report_header_info:
                (h_key, h_value) = next(iter( d.items() ))
                if h_key == key:
                    found = True
                    if value == h_value and key == "Lane":
                        d = {h_key : ", ".join([h_value, value.lstrip("Lane ")])}
                    elif value == h_value:
                        d = {h_key : ", ".join([h_value, value])}

            if not found:
                config.report_header_info.append({key: value.lstrip("Lane ")})

        # Add information from the "barcodes" section
        data = {}
        for readset_name, lst in parsed_json["barcodes"].items():
            sample_barcode_info = self.barcode_subsection_to_dict(lst)
            s_name = self.clean_s_name(readset_name, f, lane=run_data["Lane"])
            # TODO: From python 3.9, we can switch to the nicer "|" syntax for merging dictionaries:
            # data[s_name] = sample_barcode_info | run_data
            data[s_name] = {**sample_barcode_info, **run_data}

        # Add information from the "run_validation" section
        if "run_validation" not in parsed_json:
            log.warn("Genpipes JSON did not have 'run_validation' key: '{}'".format(f["fn"]))
            return
        for obj in parsed_json["run_validation"]:
            s_name = self.clean_s_name(obj["sample"], f, lane=run_data["Lane"])
            data[s_name]["Project"] = obj["project"]
            data[s_name]["Reported Sex"] = obj["alignment"]["reported_sex"]

        return data

    def barcode_subsection_to_dict(self, lst):
        s_dct = lst[0]
        s_dct["Readset name"] = s_dct.pop("SAMPLESHEET_NAME", None)
        s_dct["Library"] = s_dct.pop("LIBRARY", None)
        s_dct["Project"] = s_dct.pop("PROJECT", None)
        s_dct["Index name"] = s_dct.pop("INDEX_NAME", None)
        s_dct["Index 1"] = s_dct.pop("INDEX_NAME", None)
        s_dct["Index 2"] = s_dct.pop("INDEX1", None)
        s_dct["Adapter-i7"] = s_dct.pop("ADAPTERi7", None)
        s_dct["Adapter-i5"] = s_dct.pop("ADAPTERi5", None)
        s_dct["Barcode sequence"] = s_dct.pop("BARCODE_SEQUENCE", None)
        return s_dct

    def clean_s_name(self, s_name, f=None, root=None, filename=None, search_pattern_key=None, lane=None):
        s_name = super().clean_s_name(s_name, f, root, filename, search_pattern_key)
        if lane:
            return "L{} | {}".format(lane, s_name)
        lane = None
        dirmatcher = re.compile("[(Una)(A)]ligned\.(?P<lane>\d+)")
        for dir in PurePath(f["root"]).parts:
            m = dirmatcher.search(dir)
            if m:
                lane = m.group("lane")
                return "L{} | {}".format(lane, s_name)

        return s_name
