import json
import logging
import operator
import os
import re

from collections import OrderedDict, defaultdict
from itertools import islice

from multiqc import config
from multiqc.plots import bargraph, table
from multiqc.base_module import BaseMultiqcModule

log = logging.getLogger(__name__)

def parse_reports(self):

    # Gather data from all json files
    self.bcl2fastq_data = dict()
    report_found = []
    for f in self.find_log_files("c3g_demuxmetrics/bcl2fastq"):
        parse_file_as_json(self, f)
        report_found.append(f['fn'])

    if report_found:
        # Collect counts by lane and sample (+source_files)
        self.bcl2fastq_bylane = dict()
        self.bcl2fastq_bysample = dict()
        self.bcl2fastq_bysample_lane = dict()
        self.source_files = dict()
        split_data_by_lane_and_sample(self)

        # Filter to strip out ignored sample names
        self.bcl2fastq_bylane = self.ignore_samples(self.bcl2fastq_bylane)
        self.bcl2fastq_bysample = self.ignore_samples(self.bcl2fastq_bysample)
        self.bcl2fastq_bysample_lane = self.ignore_samples(self.bcl2fastq_bysample_lane)

        # Return with Warning if no files are found
        if len(self.bcl2fastq_bylane) == 0 and len(self.bcl2fastq_bysample) == 0:
            raise UserWarning

        # Print source files
        for s in self.source_files.keys():
            self.add_data_source(
                s_name=s,
                source=",".join(list(set(self.source_files[s]))),
                module="bcl2fastq",
                section="bcl2fastq-bysample",
            )

        # Add sample counts to general stats table
        add_general_stats(self)
        self.write_data_file(
            {str(k): self.bcl2fastq_bylane[k] for k in self.bcl2fastq_bylane.keys()}, "multiqc_bcl2fastq_bylane"
        )
        self.write_data_file(self.bcl2fastq_bysample, "multiqc_bcl2fastq_bysample")

        # Add section for summary stats per flow cell
        self.add_section(
            name="Lane Statistics",
            anchor="bcl2fastq-lanestats",
            description="Statistics about each lane for each flowcell",
            plot=lane_stats_table(self),
        )

        # Add section for counts by lane
        cats = OrderedDict()
        cats["perfect"] = {"name": "Perfect Index Reads"}
        cats["imperfect"] = {"name": "Mismatched Index Reads"}
        cats["undetermined"] = {"name": "Undetermined Reads"}
        self.add_section(
            name="Clusters by lane",
            anchor="bcl2fastq-bylane",
            description="Number of reads per lane (with number of perfect index reads).",
            helptext="""Perfect index reads are those that do not have a single mismatch.
                All samples of a lane are combined. Undetermined reads are treated as a third category.""",
            plot=bargraph.plot(
                get_bar_data_from_counts(self.bcl2fastq_bylane),
                cats,
                {
                    "id": "bcl2fastq_lane_counts",
                    "title": "bcl2fastq: Clusters by lane",
                    "ylab": "Number of clusters",
                    "hide_zero_cats": False,
                }
            )
        )

        # Add section for counts by sample
        # get cats for per-lane tab
        self.add_section(
            name="Clusters by sample",
            anchor="bcl2fastq-bysample",
            description="Number of reads per sample.",
            helptext="""Perfect index reads are those that do not have a single mismatch.
                All samples are aggregated across lanes combinned. Undetermined reads are ignored.
                Undetermined reads are treated as a separate sample.""",
            plot=bargraph.plot(
                [get_bar_data_from_counts(self.bcl2fastq_bysample)],
                [cats],
                {
                    "id": "bcl2fastq_sample_counts",
                    "title": "bcl2fastq: Clusters by sample",
                    "hide_zero_cats": False,
                    "ylab": "Number of clusters",
                    "data_labels": ["Index mismatches", "Counts per lane"],
                },
            ),
        )

        headers = OrderedDict()
        headers["indexSequence"] = {
            "title": "Index Sequence",
            "description": "Index Sequence for this sample"
            }
        
        headers["total"] = {
            "title": "{} Clusters".format(config.read_count_prefix),
            "description": "Total number of reads for this sample as determined by bcl2fastq demultiplexing ({})".format(config.read_count_desc),
            "scale": "Blues",
            "shared_key": "read_count",
            }
        
        headers["percent_perfectIndex"] = {
            "title": "% Perfect Index",
            "description": "Percent of reads with perfect index (0 mismatches)",
            "max": 100,
            "min": 0,
            "scale": "RdYlGn",
            "suffix": "%",
            }
        
        headers["total_yield"] = {
            "title": "Yield ({})".format(config.base_count_prefix),
            "description": "Total number of bases ({})".format(config.base_count_desc),
            "scale": "Greens",
            "shared_key": "base_count",
            "hidden": True
            }
        
        headers["percent_Q30"] = {
            "title": "% Q30 bases",
            "description": "Percent of bases with score of q30 or higher",
            "max": 100,
            "min": 0,
            "scale": "RdYlGn",
            "suffix": "%",
            }
        
        headers["mean_qscore"] = {
            "title": "Mean Quality Score",
            "description": "Mean quality score for bases in this sample"
        }
        
        self.add_section(
                name="Summary by sample",
                anchor="bcl2fastq-summary-bysample",
                description="bcl2fastq summary per per sample.",
                plot=table.plot(
                    [self.bcl2fastq_bysample],
                    headers,
                    {
                        "id": "bcl2fastq_summary",
                        "title": "bcl2fastq: Summary by sample",
                        "col1_header": "Lane | Sample Name"
                        }
                    )
                )

        # Add section with undetermined barcodes
        headers = OrderedDict()
        for r in range(1,9):
            headers["L{}".format(r)] = {
                "title": "L{}".format(r),
                "description": "Barcode count for Lane {}".format(r),
                }
        self.add_section(
            name="Undetermined barcodes by lane",
            anchor="undetermine_by_lane",
            description="Count of the top twenty most abundant undetermined barcodes by lanes",
            plot=table.plot(
                get_bar_data_from_undetermined(self.bcl2fastq_bylane),
                headers,
                {
                    "id": "bcl2fastq_undetermined",
                    "title": "bcl2fastq: Undetermined barcodes by lane",
                    "col1_header": "Sequence"
                }
            )
        )
    return len(report_found)

def parse_file_as_json(self, f):
    try:
        content = json.loads(f["f"])
    except ValueError:
        log.warning("Could not parse file as json: {}".format(f["fn"]))
        return

    runId = content["RunId"]

    if runId not in self.bcl2fastq_data:
        self.bcl2fastq_data[runId] = dict()
    run_data = self.bcl2fastq_data[runId]
    for conversionResult in content.get("ConversionResults", []):
        l = conversionResult["LaneNumber"]
        lane = f"L{l}"
        if lane in run_data:
            log.debug(
                "Duplicate runId/lane combination found! Overwriting: {}".format(prepend_runid(runId, lane))
            )
        run_data[lane] = {
            "total": 0,
            "total_yield": 0,
            "perfectIndex": 0,
            "samples": dict(),
            "yieldQ30": 0,
            "qscore_sum": 0,
        }
        # simplify the population of dictionaries
        rlane = run_data[lane]

        # Add undetermined barcodes
        unknown_barcode = dict()
        for lane_data in content.get("UnknownBarcodes", list()):
            if lane_data["Lane"] == l:
                unknown_barcode = lane_data["Barcodes"]
                break
        run_data[lane]["unknown_barcodes"] = unknown_barcode

        for demuxResult in conversionResult.get("DemuxResults", []):
            # if demuxResult["SampleName"] == demuxResult["SampleId"]:
            #     sample = demuxResult["SampleName"]
            # else:
            #     sample = "{}-{}".format(demuxResult["SampleId"], demuxResult["SampleName"])
            sample = demuxResult["SampleName"]
            if sample == "undetermined":
                sample = f"{lane} | Undetermined"
            else:
                sample = self.clean_s_name(sample, f)
            if sample in run_data[lane]["samples"]:
                log.debug(
                    "Duplicate runId/lane/sample combination found! Overwriting: {}, {}".format(
                        prepend_runid(runId, lane), sample
                    )
                )
            
            run_data[lane]["samples"][sample] = {
                "total": 0,
                "total_yield": 0,
                "indexSequence": "",
                "perfectIndex": 0,
                "filename": os.path.join(f["root"], f["fn"]),
                "yieldQ30": 0,
                "qscore_sum": 0,
            }
            # simplify the population of dictionaries
            lsample = run_data[lane]["samples"][sample]
            for r in range(1, 5):
                lsample["R{}_yield".format(r)] = 0
                lsample["R{}_Q30".format(r)] = 0
                lsample["R{}_trimmed_bases".format(r)] = 0
            rlane["total"] += demuxResult["NumberReads"]
            rlane["total_yield"] += demuxResult["Yield"]
            lsample["total"] += demuxResult["NumberReads"]
            lsample["total_yield"] += demuxResult["Yield"]
            for indexMetric in demuxResult.get("IndexMetrics", []):
                rlane["perfectIndex"] += indexMetric["MismatchCounts"]["0"]
                lsample["perfectIndex"] += indexMetric["MismatchCounts"]["0"]
                lsample["indexSequence"] = indexMetric["IndexSequence"]
            for readMetric in demuxResult.get("ReadMetrics", []):
                r = readMetric["ReadNumber"]
                rlane["yieldQ30"] += readMetric["YieldQ30"]
                rlane["qscore_sum"] += readMetric["QualityScoreSum"]
                lsample["yieldQ30"] += readMetric["YieldQ30"]
                lsample["qscore_sum"] += readMetric["QualityScoreSum"]
                lsample["R{}_yield".format(r)] += readMetric["Yield"]
                lsample["R{}_Q30".format(r)] += readMetric["YieldQ30"]
                lsample["R{}_trimmed_bases".format(r)] += readMetric["TrimmedBases"]
            # Remove unpopulated read keys
            for r in range(1, 5):
                if (
                    not lsample["R{}_yield".format(r)]
                    and not lsample["R{}_Q30".format(r)]
                    and not lsample["R{}_trimmed_bases".format(r)]
                ):
                    lsample.pop("R{}_yield".format(r))
                    lsample.pop("R{}_Q30".format(r))
                    lsample.pop("R{}_trimmed_bases".format(r))
        undeterminedYieldQ30 = 0
        undeterminedQscoreSum = 0
        undeterminedTrimmedBases = 0
        if "Undetermined" in conversionResult:
            for readMetric in conversionResult["Undetermined"]["ReadMetrics"]:
                undeterminedYieldQ30 += readMetric["YieldQ30"]
                undeterminedQscoreSum += readMetric["QualityScoreSum"]
                undeterminedTrimmedBases += readMetric["TrimmedBases"]
            run_data[lane]["samples"][f"{lane} | Undetermined"] = {
                "total": conversionResult["Undetermined"]["NumberReads"],
                "total_yield": conversionResult["Undetermined"]["Yield"],
                "indexSequence": "Unknown",
                "perfectIndex": 0,
                "yieldQ30": undeterminedYieldQ30,
                "qscore_sum": undeterminedQscoreSum,
                "trimmed_bases": undeterminedTrimmedBases,
            }

    # Calculate Percents and averages
    for _, lane in run_data.items():
        try:
            lane["percent_Q30"] = (float(lane["yieldQ30"]) / float(lane["total_yield"])) * 100.0
        except ZeroDivisionError:
            lane["percent_Q30"] = "NA"
        try:
            lane["percent_perfectIndex"] = (float(lane["perfectIndex"]) / float(lane["total"])) * 100.0
        except ZeroDivisionError:
            lane["percent_perfectIndex"] = "NA"
        try:
            lane["mean_qscore"] = float(lane["qscore_sum"]) / float(lane["total_yield"])
        except ZeroDivisionError:
            lane["mean_qscore"] = "NA"

        for _, sample in lane["samples"].items():
            try:
                sample["percent_Q30"] = (float(sample["yieldQ30"]) / float(sample["total_yield"])) * 100.0
            except ZeroDivisionError:
                sample["percent_Q30"] = "NA"
            try:
                sample["percent_perfectIndex"] = (float(sample["perfectIndex"]) / float(sample["total"])) * 100.0
            except ZeroDivisionError:
                sample["percent_perfectIndex"] = "NA"
            try:
                sample["mean_qscore"] = float(sample["qscore_sum"]) / float(sample["total_yield"])
            except ZeroDivisionError:
                sample["mean_qscore"] = "NA"

def split_data_by_lane_and_sample(self):
    for run_id, r in self.bcl2fastq_data.items():
        for lane_id, lane in r.items():
            uniqLaneName = prepend_runid(run_id, lane_id)
            self.bcl2fastq_bylane[uniqLaneName] = {
                "total": lane["total"],
                "total_yield": lane["total_yield"],
                "perfectIndex": lane["perfectIndex"],
                "undetermined": lane["samples"].get("undetermined", {}).get("total", "NA"),
                "yieldQ30": lane["yieldQ30"],
                "qscore_sum": lane["qscore_sum"],
                "percent_Q30": lane["percent_Q30"],
                "percent_perfectIndex": lane["percent_perfectIndex"],
                "mean_qscore": lane["mean_qscore"],
                "unknown_barcodes": get_unknown_barcodes(lane["unknown_barcodes"]),
            }
            for sample_id, sample in lane["samples"].items():
                suffix_matcher = re.compile("(?P<sample_id>.+)_(?P<suffix>[A-Z])$")
                m = suffix_matcher.search(sample_id)
                if m:
                    sample_id = m.group("sample_id")
                if sample_id not in self.bcl2fastq_bysample:
                    self.bcl2fastq_bysample[sample_id] = {
                        "total": 0,
                        "total_yield": 0,
                        "indexSequence": "",
                        "perfectIndex": 0,
                        "yieldQ30": 0,
                        "qscore_sum": 0,
                    }
                    for r in range(1, 5):
                        self.bcl2fastq_bysample[sample_id]["R{}_yield".format(r)] = 0
                        self.bcl2fastq_bysample[sample_id]["R{}_Q30".format(r)] = 0
                        self.bcl2fastq_bysample[sample_id]["R{}_trimmed_bases".format(r)] = 0
                s = self.bcl2fastq_bysample[sample_id]
                s["total"] += sample["total"]
                s["total_yield"] += sample["total_yield"]
                s["perfectIndex"] += sample["perfectIndex"]
                s["indexSequence"] = sample["indexSequence"]
                s["yieldQ30"] += sample["yieldQ30"]
                s["qscore_sum"] += sample["qscore_sum"]
                # Undetermined samples did not have R1 and R2 information
                for r in range(1, 5):
                    try:
                        s["R{}_yield".format(r)] += sample["R{}_yield".format(r)]
                        s["R{}_Q30".format(r)] += sample["R{}_Q30".format(r)]
                        s["R{}_trimmed_bases".format(r)] += sample["R{}_trimmed_bases".format(r)]
                    except KeyError:
                        pass
                try:
                    s["percent_Q30"] = (float(s["yieldQ30"]) / float(s["total_yield"])) * 100.0
                except ZeroDivisionError:
                    s["percent_Q30"] = "NA"
                try:
                    s["percent_perfectIndex"] = (float(s["perfectIndex"]) / float(s["total"])) * 100.0
                except ZeroDivisionError:
                    s["percent_perfectIndex"] = "NA"
                try:
                    s["mean_qscore"] = float(s["qscore_sum"]) / float(s["total_yield"])
                except ZeroDivisionError:
                    s["mean_qscore"] = "NA"
                if sample_id != f"{lane_id} | Undetermined":
                    if sample_id not in self.source_files:
                        self.source_files[sample_id] = []
                    self.source_files[sample_id].append(sample["filename"])
            # Remove unpopulated read keys
            for sample_id, sample in lane["samples"].items():
                suffix_matcher = re.compile("(?P<sample_id>.+)_(?P<suffix>[A-Z])$")
                m = suffix_matcher.search(sample_id)
                if m:
                    sample_id = m.group("sample_id")
                for r in range(1, 5):
                    try:
                        if (
                            not self.bcl2fastq_bysample[sample_id]["R{}_yield".format(r)]
                            and not self.bcl2fastq_bysample[sample_id]["R{}_Q30".format(r)]
                            and not self.bcl2fastq_bysample[sample_id]["R{}_trimmed_bases".format(r)]
                        ):
                            self.bcl2fastq_bysample[sample_id].pop("R{}_yield".format(r))
                            self.bcl2fastq_bysample[sample_id].pop("R{}_Q30".format(r))
                            self.bcl2fastq_bysample[sample_id].pop("R{}_trimmed_bases".format(r))
                    except KeyError:
                        pass

def get_unknown_barcodes(lane_unknown_barcode):
    """Python 2.* dictionaries are not sorted.
    This function return an `OrderedDict` sorted by barcode count.
    """
    try:
        sorted_barcodes = OrderedDict(
            sorted(lane_unknown_barcode.items(), key=operator.itemgetter(1), reverse=True)
        )
    except AttributeError:
        sorted_barcodes = None
    return sorted_barcodes

def add_general_stats(self):
    data = dict()
    for sample_id, sample in self.bcl2fastq_bysample.items():
        if "Undetermined" in sample_id:
            continue
        suffix_matcher = re.compile("(?P<sample_id>.+)_(?P<suffix>[A-Z])$")
        m = suffix_matcher.search(sample_id)
        if m:
            sample_id = m.group("sample_id")

        if sample_id in data:
            # log.error("prout")
            data[sample_id]["nb_barcodes"] += 1
            data[sample_id]["yieldQ30"] += sample["yieldQ30"]
            data[sample_id]["total"] += sample["total"]
            data[sample_id]["perfectIndex"] += sample["perfectIndex"]
            data[sample_id]["R{}_Q30".format(r)] += sample["R{}_Q30".format(r)]
            data[sample_id]["R{}_yield".format(r)] += sample["R{}_yield".format(r)]
            for r in range(1, 5):
                # log.error(data[sample_id]["R{}_Q30".format(r)])
                # log.error(sample["R{}_Q30".format(r)])
                # log.error(data[sample_id]["R{}_yield".format(r)])
                # log.error(sample["R{}_yield".format(r)])
                try:
                    data[sample_id]["R{}_Q30".format(r)] += sample["R{}_Q30".format(r)]
                    data[sample_id]["R{}_yield".format(r)] += sample["R{}_yield".format(r)]
                    data[sample_id]["R{}_trimmed_bases".format(r)] += sample["R{}_trimmed_bases".format(r)]
                except KeyError:
                    pass

        else:
            data[sample_id] = {
                "nb_barcodes": 1,
                "yieldQ30": sample["yieldQ30"],
                "total": sample["total"],
                "perfectIndex": sample["perfectIndex"]
            }
            for r in range(1, 5):
                # log.error(str(r) + " " + sample_id + " " + str(sample["R{}_trimmed_bases".format(r)]))
                # log.error(str(r) + " " + sample_id + " " + str(sample["R{}_Q30".format(r)]))
                # log.error(str(r) + " " + sample_id + " " + str(sample["R{}_yield".format(r)]))
                try:
                    data[sample_id]["R{}_Q30".format(r)] = sample["R{}_Q30".format(r)]
                    data[sample_id]["R{}_yield".format(r)] = sample["R{}_yield".format(r)]
                    data[sample_id]["R{}_trimmed_bases".format(r)] = sample["R{}_trimmed_bases".format(r)]
                except KeyError:
                    pass

        # percent_R_Q30 = dict()
        for r in range(1, 5):
            # Zero division is possible
            try:
                data[sample_id]["percent_R{}_Q30".format(r)] = "{0:.1f}".format(
                    float(100.0 * data[sample_id]["R{}_Q30".format(r)] / data[sample_id]["R{}_yield".format(r)])
                )
            except ZeroDivisionError:
                data[sample_id]["percent_R{}_Q30".format(r)] = "0.0"
            except KeyError:
                pass
        try:
            perfect_percent = "{0:.1f}".format(float(100.0 * data[sample_id]["perfectIndex"] / data[sample_id]["total"]))
        except ZeroDivisionError:
            perfect_percent = "0.0"
        data[sample_id]["perfectPercent"] = perfect_percent

        # for r in range(1, 5):
        #     try:
        #         data[sample_id]["percent_R{}_Q30".format(r)] = percent_R_Q30[r]
        #         data[sample_id]["R{}_trimmed_bases".format(r)] = sample["R{}_trimmed_bases".format(r)]
        #     except KeyError:
        #         pass

    headers = OrderedDict()
    headers["total"] = {
        "title": "{} Clusters".format(config.read_count_prefix),
        "description": "Total number of reads for this sample as determined by bcl2fastq demultiplexing ({})".format(
            config.read_count_desc
        ),
        "scale": "Blues",
        "shared_key": "read_count",
    }
    headers["yieldQ30"] = {
        "title": "Yield ({}) &ge; Q30".format(config.base_count_prefix),
        "description": "Number of bases with a Phred score of 30 or higher ({})".format(config.base_count_desc),
        "scale": "Greens",
        "shared_key": "base_count",
        "hidden": True
    }
    # If no data for a column, header will be automatically ignored
    for r in range(1, 5):
        headers["percent_R{}_Q30".format(r)] = {
            "title": "% R{} Yield &ge; Q30".format(r),
            "description": "Percent of bases in R{} with a Phred score of 30 or higher".format(r),
            "scale": "RdYlGn",
            "max": 100,
            "min": 0,
            "suffix": "%",
        }
    headers["perfectPercent"] = {
        "title": "% Perfect Index",
        "description": "Percent of reads with perfect index (0 mismatches)",
        "max": 100,
        "min": 0,
        "scale": "RdYlGn",
        "suffix": "%",
    }
    # If no data for a column, header will be automatically ignored
    for r in range(1, 5):
        hideCol = True
        for s in data:
            try:
                if data[s]["R{}_trimmed_bases".format(r)] > 0:
                    hideCol = False
            except KeyError:
                pass
        try:
            headers["R{}_trimmed_bases".format(r)] = {
                "title": "{} R{} trimmed".format(config.base_count_prefix, r),
                "description": "Number of bases trimmed ({})".format(config.base_count_desc),
                "scale": "RdYlBu",
                "modify": lambda x: x * 0.000001,
                "hidden": hideCol,
            }
        except KeyError:
            pass
    self.general_stats_addcols(data, headers)

def lane_stats_table(self):
    """Return a table with overview stats for each bcl2fastq lane for a single flow cell"""
    headers = OrderedDict()
    headers["total_yield"] = {
        "title": "{} Total Yield".format(config.base_count_prefix),
        "description": "Number of bases ({})".format(config.base_count_desc),
        "scale": "Greens",
        "shared_key": "base_count",
    }
    headers["total"] = {
        "title": "{} Total Clusters".format(config.read_count_prefix),
        "description": "Total number of clusters for this lane ({})".format(config.read_count_desc),
        "scale": "Blues",
        "shared_key": "read_count",
    }
    headers["percent_Q30"] = {
        "title": "% bases &ge; Q30",
        "description": "Percentage of bases with greater than or equal to Q30 quality score",
        "suffix": "%",
        "max": 100,
        "min": 0,
        "scale": "RdYlGn",
    }
    headers["mean_qscore"] = {
        "title": "Mean Quality",
        "description": "Average phred qualty score",
        "min": 0,
        "scale": "Spectral",
    }
    headers["percent_perfectIndex"] = {
        "title": "% Perfect Index",
        "description": "Percent of reads with perfect index (0 mismatches)",
        "max": 100,
        "min": 0,
        "scale": "RdYlGn",
        "suffix": "%",
    }
    table_config = {
        "namespace": "bcl2fastq",
        "id": "bcl2fastq-lane-stats-table",
        "title": "bcl2fastq Lane Statistics",
        "col1_header": "Run ID - Lane",
        "no_violin": True,
    }
    return table.plot(self.bcl2fastq_bylane, headers, table_config)

def prepend_runid(runId, rest):
    return str(runId) + " - " + str(rest)

def get_bar_data_from_counts(counts):
    bar_data = {}
    for key, value in counts.items():
        bar_data[key] = {
            "perfect": value["perfectIndex"],
            "imperfect": value["total"] - value["perfectIndex"],
        }
        if "undetermined" in value:
            bar_data[key]["undetermined"] = value["undetermined"]
    return bar_data

def get_bar_data_from_undetermined(flowcells):
    """Get data to plot for undetermined barcodes."""
    bar_data = defaultdict(dict)
    # get undetermined barcodes for each lanes
    for lane_id, lane in flowcells.items():
        lane_header = lane_id.split(" ")[2]
        try:
            for barcode, count in islice(lane["unknown_barcodes"].items(), 20):
                bar_data[barcode][lane_header] = count
        except AttributeError:
            pass

    # sort results
    bar_data = OrderedDict(sorted(bar_data.items(), key=lambda x: sum(x[1].values()), reverse=True))
    return OrderedDict((key, value) for key, value in islice(bar_data.items(), 20))
