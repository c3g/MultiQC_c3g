#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from collections import OrderedDict
import json
import logging

from multiqc.utils import config
from multiqc_c3g.runprocessing_base import RunProcessingBaseModule

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(RunProcessingBaseModule):

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
            'scale': False,
            'scale': False,
            'format': '{:,.0f}',
            'hidden': True,
        }

        for (s_name, data) in sample_data.items():
            self.generaljson_data[s_name] = {colname:data[colname] for colname in list(headers.keys()) if colname in data}
        self.generaljson_data = self.ignore_samples(self.generaljson_data)
        self.general_stats_addcols(self.generaljson_data, headers)


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
            barcode_infos = [self.barcode_subsection_to_dict(barcode_section) for barcode_section in barcodes]
            s_name = self.clean_s_name(readset_name, f)
            data[s_name] = run_data
            data[s_name]["barcodes"] = barcode_infos

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
        self.add_to_sample_renames(data)
        return data


    def barcode_subsection_to_dict(self, s_dct):
        s_dct["Readset name"] = s_dct.pop("SAMPLESHEET_NAME", None)
        s_dct["Library"] = s_dct.pop("LIBRARY", None)
        s_dct["Project"] = s_dct.pop("PROJECT", None)
        s_dct["Index name"] = s_dct.pop("INDEX_NAME", None)
        s_dct["Adapter-i7"] = s_dct.pop("ADAPTERi7", None)
        s_dct["Adapter-i5"] = s_dct.pop("ADAPTERi5", None)
        return s_dct


    def add_to_sample_renames(self, s_dct):

        names_full = [key for key, value in s_dct.items() for barcode in value['barcodes']]
        names_with_indexname = [key.removesuffix(barcode['Library']).removesuffix("_") + " | " + barcode['Index name'] for key, value in s_dct.items() for barcode in value['barcodes']]
        names_simple = [key.removesuffix(barcode['Library']).removesuffix("_") for key, value in s_dct.items() for barcode in value['barcodes']]

        foo = [key for key, value in s_dct.items() for barcode in value['barcodes']]
        [key.removesuffix('_2-2119395') for key, value in s_dct.items() for barcode in value['barcodes']]
        [(key, barcode['Library']) for key, value in s_dct.items() for barcode in value['barcodes']]

        names_all = {x for x in zip(names_full, names_with_indexname, names_simple)}

        config.sample_names_rename_buttons = ["With library ID", "With library Name", "Simple"]
        config.sample_names_rename.extend(names_all)
