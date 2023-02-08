#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from collections import OrderedDict
import json
import logging

from multiqc.utils import config
from multiqc_c3g.runprocessing_base import RunProcessingBaseModule
from .validationreport import ValidationReport

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(RunProcessingBaseModule):

    def __init__(self):
        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Runprocessing",
            target="c3g_runprocessing",
            anchor="c3g_runprocessing",
            href="https://genpipes.readthedocs.io",
            info=" outputs presented in more detail.",
        )

        # Halt execution if we don't have the runprocessing flag set.
        if not config.kwargs.get("runprocessing", False):
            return None

        ## Parse Genpipes JSON files
        sample_data = {}
        for f in self.find_log_files("c3g_runprocessing"):
            d = self.parse_genpipes_run_processing_json(f)

            sample_data.update(d)
            for s_name in d:
                self.add_data_source(f, s_name, section="general_information")

        log.info("Found {} samples in {} JSONs".format(
            len(sample_data),
            len(list(self.find_log_files("c3g_runprocessing")))),
        )

        # ## General Summary Section
        self.generaljson_data = dict()
        headers = OrderedDict()
        headers['Project'] = {
            'title': 'Project',
            'description': 'Project ID'
        }
        headers['Lane'] = {
            'title': 'Lane',
            'description': 'Flowcell lane',
            'scale': False,
            'scale': False,
            'format': '{:,.0f}',
            'hidden': True
        }
        headers['Reported Sex'] = {
            'title': 'Reported Sex',
            'description': 'Reported Sex',
            'hidden': True
        }
        headers['Inferred Gender'] = {
            'title': 'Inferred Sex',
            'description': 'Inferred Sex',
            'hidden': True
        }
        headers['Gender Concordance'] = {
            'title': 'Sex Concordance',
            'description': 'Sex Concordance',
            'hidden': True
        }

        for (s_name, data) in sample_data.items():
            self.generaljson_data[s_name] = {colname:data[colname] for colname in list(headers.keys()) if colname in data}
        self.generaljson_data = self.ignore_samples(self.generaljson_data)
        self.general_stats_addcols(self.generaljson_data, headers)


    def parse_genpipes_run_processing_json(self, f):
        try:
            parsed_json = json.loads(f["f"])
        except:
            log.warning("Could not parse genpipes JSON: '{}'".format(f["fn"]))
            return None

        version = parsed_json.get("version", "1.0")

        if (version == "1.0"):
            return self._json_v1(parsed_json, f)
        else:
            return self._from_report(parsed_json, f)

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

    def _from_report(self, parsed_json, f):
        report = ValidationReport(parsed_json)
        self.add_to_sample_renames(report)

        run_data = {
            "Run": report.run,
            "Instrument": report.instrument,
            "Flowcell": report.flowcell,
            "Seqtype": report.seqtype,
            "Sequencing method": report.sequencing_method,
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

        data = {self.clean_s_name(readset.name, f, lane=report.lane): {**readset, **{'Lane':report.lane}} for readset in report.readsets}
        return data

    def barcode_subsection_to_dict(self, s_dct):
        s_dct["Readset name"] = s_dct.pop("SAMPLESHEET_NAME", None)
        s_dct["Library"] = s_dct.pop("LIBRARY", None)
        s_dct["Project"] = s_dct.pop("PROJECT", None)
        s_dct["Index name"] = s_dct.pop("INDEX_NAME", None)
        s_dct["Adapter-i7"] = s_dct.pop("ADAPTERi7", None)
        s_dct["Adapter-i5"] = s_dct.pop("ADAPTERi5", None)
        return s_dct

    # Automatically add sample rename buttons.
    # In `config.sample_names_rename`, we add a list of lists that have sample names in various formats.
    def add_to_sample_renames(self, report):
        names_full = [readset.name for readset in report.readsets]
        names_with_indexname = [readset.name.removesuffix(readset.library).removesuffix("_") + f" | {readset.index_name}" for readset in report.readsets]
        names_simple = [readset.name.removesuffix(readset.library).removesuffix("_") for readset in report.readsets]

        names_all = {x for x in zip(names_full, names_with_indexname, names_simple)}
        config.sample_names_rename_buttons = ["With library ID", "With library Name", "Simple"]
        config.sample_names_rename.extend(names_all)