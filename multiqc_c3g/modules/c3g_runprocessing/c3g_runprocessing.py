#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from collections import OrderedDict
import json
import logging

from multiqc.utils import config
from multiqc_c3g.base_module import RunprocessingMultiqcModule
from multiqc_c3g.modules.c3g_runprocessing import runvalidation

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(RunprocessingMultiqcModule):

    def __init__(self):
        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Runprocessing",
            target="genpipes",
            anchor="genpipes",
            href="https://genpipes.readthedocs.io",
            info=" outputs presented in more detail.",
        )

        # Halt execution if we don't have the runprocessing flag set.
        if not config.kwargs.get("runprocessing", False):
            return None

        ## Parse Genpipes JSON files
        sample_data = {}
        for f in self.find_log_files("c3g_runprocessing/report"):
            # report = runvalidation.Report.from_dict(json.loads(f['f']))
            d = self.parse_genpipes_general_info_json(f)

            sample_data.update(d)
            for s_name in d:
                self.add_data_source(f, s_name, section="general_information")

        log.info("Found {} samples in {} JSONs".format(
            len(sample_data),
            len(list(self.find_log_files("c3g_runprocessing/report")))))


        # ## General Summary Section
        self.generaljson_data = dict()
        headers = OrderedDict()
        headers['Project'] = {
            'title': 'Project',
            'description': 'Project ID',
        }
        headers['Lane'] = {
            'title': 'Lane',
            'description': 'Flowcell lane',
            'hidden': True,
        }

        for (s_name, data) in sample_data.items():
            self.generaljson_data[s_name] = {colname:data[colname] for colname in list(headers.keys()) if colname in data}
        self.generaljson_data = self.ignore_samples(self.generaljson_data)
        self.general_stats_addcols(self.generaljson_data, headers)
        # unexpected_barcode_data = {}
        # for f in self.find_log_files("genpipes/sequencestat", filehandles=True):
        #     d = self.parse_sequencestat(f, 20)
        #     unexpected_barcode_data.update(d)

        # barcode_to_id = {"L{} | {}".format(data["Lane"], data['Index name']) : s_name for (s_name, data) in sample_data.items()}
        # barcode_data = {}
        # for f in self.find_log_files("runprocessing/barcodestat"):
        #     d = self.parse_barcodestat(f, barcode_to_id)
        #     barcode_data.update(d)
        #     for s_name in barcode_data:
        #         self.add_data_source(f, s_name, section="barcodestat")

        # for f in self.find_log_files("genpipes/demuxmetrics"):
        #     d = self.parse_barcodemetrics(f)
        #     barcode_data.update(d)

        # headers = OrderedDict()
        # headers['Correct'] = {
        #     'title': 'Perfect',
        #     'description': 'Number of clusters with perfect barcode sequence',
        #     'modify': lambda x: x * config.read_count_multiplier,
        #     'suffix': config.read_count_prefix,
        #     'format': '{:,.0f}'
        # }
        # headers['Corrected'] = {
        #     'title': 'Imperfect',
        #     'description': 'Number of clusters assigned to barcode within mismatch distance',
        #     'modify': lambda x: x * config.read_count_multiplier,
        #     'suffix': config.read_count_prefix,
        #     'format': '{:,.0f}'
        # }
        # headers['Total'] = {
        #     'description': 'Total number of clusters assigned to barcode',
        #     'modify': lambda x: x * config.read_count_multiplier,
        #     'suffix': config.read_count_prefix,
        #     'format': '{:,.0f}'
        # }
        # headers['Percentage(%)'] = {
        #     'title' : "Lane composition (%)",
        #     'description': 'Percentage of the lane assigned to this barcode',
        #     'suffix': '%',
        #     'format': '{:,.1f}'
        # }

        # total_matcher = re.compile(" Clusters assigned to barcode$")
        # barcode_data_without_totals = {k: barcode_data[k] for k in barcode_data.keys() if not total_matcher.search(k)}
        # barcode_data_for_unexpected = {k: barcode_data[k] for k in barcode_data.keys() if total_matcher.search(k)}

        # barcode_data_for_unexpected.update(unexpected_barcode_data)

        # if(len(barcode_data_without_totals)>0):
        #     self.add_section(
        #         name = "Barcodes - Expected",
        #         description = "The counts for expected barcodes are shown below. Note that percentage is relative to the lane, not the run as a whole.",
        #         plot = table.plot(barcode_data_without_totals, headers)
        #     )

        # headers = OrderedDict()
        # headers['Total'] = {
        #     'description': 'Total number of clusters assigned to barcode',
        #     'modify': lambda x: float(x) * config.read_count_multiplier,
        #     'suffix': config.read_count_prefix,
        #     'format': '{:,.0f}'
        # }
        # headers['Percentage(%)'] = {
        #     'title' : "Lane composition (%)",
        #     'description': 'Percentage of the lane assigned to this barcode',
        #     'suffix': '%',
        #     'format': '{:,.4f}'
        # }
        # if(len(barcode_data_for_unexpected)>0):
        #     self.add_section(
        #         name = "Barcodes - Unexpected",
        #         description = "The most abundant 20 unexpected barcodes in each lane are shown in the table below.",
        #         plot = table.plot(
        #             barcode_data_for_unexpected,
        #             headers,
        #             {'col1_header':'Barcode', 'sortRows': False}
        #         )
        #     )


        # blast_data = {}
        # for f in self.find_log_files("genpipes/blastsummary"):
        #     cleaner_name = re.sub(r'_\d+_L\d+.R1(R2)?.RDP.blastHit_20MF_species.txt', '', f['fn'])
        #     s_name = self.clean_s_name(cleaner_name, f)
        #     d = self.parse_blast_results(f)
        #     sample_data[s_name].update(d)
        #     blast_data[s_name] = d
        #     self.add_data_source(f, s_name, section="blast")

        # headers = OrderedDict()
        # headers['blast_hit_1'] = {'title': 'Top blast hit'}
        # headers['blast_hit_2'] = {'title': 'Second blast hit'}
        # headers['blast_hit_3'] = {'title': 'Third blast hit'}
        # if(len(blast_data)>0):
        #     self.add_section(
        #         name = "Blast hits",
        #         plot = table.plot(
        #             {k:
        #                 {
        #                 "blast_hit_1": "{} ({} hits)".format(v['blast_hit_1_name'],v['blast_hit_1_count']),
        #                 "blast_hit_2": "{} ({} hits)".format(v['blast_hit_2_name'],v['blast_hit_2_count']),
        #                 "blast_hit_3": "{} ({} hits)".format(v['blast_hit_3_name'],v['blast_hit_3_count']),
        #                 }
        #             for (k, v) in blast_data.items()}, headers))



    def parse_genpipes_general_info_json(self, f):
        try:
            parsed_json = json.loads(f["f"])
        except:
            log.warning("Could not parse genpipes JSON: '{}'".format(f["fn"]))
            return None

        version = parsed_json.get("version", "1.0")

        if (version == "1.0"):
            return self._json_v1(parsed_json, f)
        elif (version == "2.0"):
            return self._json_v2(parsed_json, f)
        elif (version == "3.0"):
            return self._json_v2(parsed_json, f)
        else:
            return self._json_v1(parsed_json, f)


    def _json_v1(self, parsed_json, f):
        run_data = {
            "Run": parsed_json.get("run", "No run found in JSON"),
            "Instrument": parsed_json.get("instrument", "No instrument found in JSON"),
            "Flowcell": parsed_json.get("flowcell", "No flowcell found in JSON"),
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
                    if value == h_value:
                        d = {h_key : ", ".join([h_value, value])}

            if not found:
                config.report_header_info.append({key: value})

        # Add information from the "barcodes" section
        data = {}
        for readset_name, lst in parsed_json["barcodes"].items():
            first_barcode = lst[0]
            sample_barcode_info = self.barcode_subsection_to_dict(first_barcode)
            s_name = self.clean_s_name(readset_name, f)
            # TODO: From python 3.9, we can switch to the nicer "|" syntax for merging dictionaries:
            # data[s_name] = sample_barcode_info | run_data
            data[s_name] = {**sample_barcode_info, **run_data}

        # Add information from the "run_validation" section
        if "run_validation" in parsed_json:
            for obj in parsed_json["run_validation"]:
                s_name = self.clean_s_name(obj["sample"], f)
                data[s_name]["Project"] = obj["project"]
                data[s_name]["Reported Sex"] = obj["alignment"]["reported_sex"]
        else:
            log.warn("Genpipes JSON did not have 'run_validation' key: '{}'".format(f["fn"]))
            for readset_name, lst in parsed_json["barcodes"].items():
                first_barcode = lst[0]
                s_name = self.clean_s_name(readset_name, f)
                data[s_name]["Project"] = first_barcode["Project"]

        return data

    def _json_v2(self, parsed_json, f):
        run_data = {
            "Run": parsed_json.get("run", "No run found in JSON"),
            "Instrument": parsed_json.get("instrument", "No instrument found in JSON"),
            "Flowcell": parsed_json.get("flowcell", "No flowcell found in JSON"),
            "Seqtype": parsed_json.get("seqtype", "No seqtype found in JSON"),
            "Sequencing method": parsed_json.get("sequencing_method", "No seqmethod found in JSON"),
        }

        if config.report_header_info is None:
            config.report_header_info = [{k:v} for k,v in run_data.items()]
        else:
            # Add run information to report header
            for (rKey, rVal) in run_data.items():
                first_key_matches_rKey = lambda d: list(d.keys())[0] == rKey
                header_idx = next((i for i,d in enumerate(config.report_header_info) if first_key_matches_rKey(d)), None)
                val_set = set(config.report_header_info[header_idx][rKey].split(", "))
                val_set.add(rVal)
                config.report_header_info[header_idx][rKey] = ", ".join(sorted(val_set))

        # Add information from the "barcodes" section
        data = {}
        for readset_name, dct in parsed_json["readsets"].items():
            barcodes = dct.get("barcodes")
            first_barcode_section = barcodes[0]
            sample_barcode_info = self.barcode_subsection_to_dict(first_barcode_section)
            s_name = self.clean_s_name(readset_name, f)
            # TODO: From python 3.9, we can switch to the nicer "|" syntax for merging dictionaries:
            # data[s_name] = sample_barcode_info | run_data
            data[s_name] = {**sample_barcode_info, **run_data}

        # Add information from the "run_validation" section
        if "run_validation" not in parsed_json:
            log.warn("Genpipes JSON did not have 'run_validation' key: '{}'".format(f["fn"]))
            return
        for obj in parsed_json["run_validation"]:
            s_name = self.clean_s_name(obj["sample"], f)
            data[s_name]["Project"] = obj["project"]
            data[s_name]["Reported Sex"] = obj["alignment"]["reported_sex"]

        lane_dict = {'Lane':parsed_json['lane']}
        data = {self.clean_s_name(name, f, lane=parsed_json['lane']): {**items, **lane_dict} for name, items in data.items()}
        return data


    def barcode_subsection_to_dict(self, s_dct):
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