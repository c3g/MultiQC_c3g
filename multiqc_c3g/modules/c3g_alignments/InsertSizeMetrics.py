from collections import OrderedDict
import logging
import os
import re

from multiqc import config
from multiqc.plots import linegraph

# Initialise the logger
log = logging.getLogger("multiqc")

def parse_reports(self):
    """Find Picard InsertSizeMetrics reports and parse their data"""

    self.picard_insertSize_data = dict()
    self.picard_insertSize_histogram = dict()
    self.picard_insertSize_samplestats = dict()

    for f in self.find_log_files("c3g_alignments/insert_size_metrics", filehandles=True):
        in_hist = False
        s_name = self.clean_s_name(f['fn'], f)
        s_name = re.sub(r'_L00[1-8]$', '', s_name)
        for l in f["f"]:
            if "InsertSizeMetrics" in l and "## METRICS CLASS" in l:
                self.add_data_source(f, s_name, section="InsertSizeMetrics")
                keys = f["f"].readline().strip("\n").split("\t")
                vals = f["f"].readline().strip("\n").split("\t")
                self.picard_insertSize_samplestats[s_name] = {"total_count": 0, "meansum": 0, "total_pairs": 0}
                orientation_idx = keys.index("PAIR_ORIENTATION")
                while len(vals) == len(keys):
                    pair_orientation = vals[orientation_idx]
                    rowkey = "{}_{}".format(s_name, pair_orientation)
                    self.picard_insertSize_data[rowkey] = OrderedDict()
                    self.picard_insertSize_data[rowkey]["SAMPLE_NAME"] = s_name
                    for i, k in enumerate(keys):
                        try:
                            self.picard_insertSize_data[rowkey][k] = float(vals[i])
                        except ValueError:
                            try:
                                self.picard_insertSize_data[rowkey][k] = float(vals[i].replace(",", "."))
                                log.debug(
                                    "Switching commas for points in '{}': {} - {}".format(
                                        f["fn"], vals[i], vals[i].replace(",", ".")
                                    )
                                )
                            except ValueError:
                                self.picard_insertSize_data[rowkey][k] = vals[i]
                        except IndexError:
                            pass  # missing data
                    rp = self.picard_insertSize_data[rowkey]["READ_PAIRS"]
                    mis = self.picard_insertSize_data[rowkey]["MEAN_INSERT_SIZE"]
                    self.picard_insertSize_samplestats[s_name]["meansum"] += rp * mis
                    self.picard_insertSize_samplestats[s_name]["total_pairs"] += rp

                    vals = f["f"].readline().strip("\n").split("\t")

                # Skip lines on to histogram
                l = f["f"].readline().strip("\n")
                l = f["f"].readline().strip("\n")
                l = f["f"].readline().strip("\n")

                self.picard_insertSize_histogram[s_name] = OrderedDict()
                in_hist = True

            # Catch the histogram values
            if s_name is not None and in_hist is True:
                try:
                    sections = l.split("\t")
                    ins = int(sections[0])
                    tot_count = sum([int(x) for x in sections[1:]])
                    self.picard_insertSize_histogram[s_name][ins] = tot_count
                    self.picard_insertSize_samplestats[s_name]["total_count"] += tot_count
                except ValueError:
                    # Reset in case we have more in this log file
                    s_name = None
                    in_hist = False

    for key in list(self.picard_insertSize_data.keys()):
        if len(self.picard_insertSize_data[key]) == 0:
            self.picard_insertSize_data.pop(key, None)
    for s_name in list(self.picard_insertSize_histogram.keys()):
        if len(self.picard_insertSize_histogram[s_name]) == 0:
            self.picard_insertSize_histogram.pop(s_name, None)
            log.debug("Ignoring '{}' histogram as no data parsed".format(s_name))

    # Calculate summed mean values for all read orientations
    for s_name, v in self.picard_insertSize_samplestats.items():
        self.picard_insertSize_samplestats[s_name]["summed_mean"] = v["meansum"] / v["total_pairs"]

    # Calculate summed median values for all read orientations
    for s_name in self.picard_insertSize_histogram:
        j = 0
        for idx, c in self.picard_insertSize_histogram[s_name].items():
            j += c
            if j > (self.picard_insertSize_samplestats[s_name]["total_count"] / 2):
                self.picard_insertSize_samplestats[s_name]["summed_median"] = idx
                break

    # Filter to strip out ignored sample names
    self.picard_insertSize_data = self.ignore_samples(self.picard_insertSize_data)

    if len(self.picard_insertSize_data) > 0:

        # Write parsed data to a file
        self.write_data_file(self.picard_insertSize_data, "multiqc_picard_insertSize")

        # Do we have median insert sizes?
        missing_medians = False
        for v in self.picard_insertSize_samplestats.values():
            if "summed_median" not in v:
                missing_medians = True

        # Add to general stats table
        self.general_stats_headers["summed_median"] = {
            "title": "Insert Size",
            "description": "Median Insert Size, all read orientations (bp)",
            "min": 0,
            "suffix": " bp",
            "format": "{:,.0f}",
            "scale": "GnBu",
        }
        self.general_stats_headers["summed_mean"] = {
            "title": "Mean Insert Size",
            "description": "Mean Insert Size, all read orientations (bp)",
            "min": 0,
            "suffix": " bp",
            "format": "{:,.0f}",
            "scale": "GnBu",
            "hidden": False if missing_medians else True,
        }
        for s_name in self.picard_insertSize_samplestats:
            if s_name not in self.general_stats_data:
                self.general_stats_data[s_name] = dict()
            self.general_stats_data[s_name].update(self.picard_insertSize_samplestats[s_name])



        # Section with histogram plot
        if len(self.picard_insertSize_histogram) > 0:
            # Make a normalised percentage version of the data
            data_percent = {}
            for s_name, data in self.picard_insertSize_histogram.items():
                data_percent[s_name] = OrderedDict()
                total = float(sum(data.values()))
                for k, v in data.items():
                    data_percent[s_name][k] = (v / total) * 100

            # Allow customisation of how smooth the the plot is
            try:
                insertsize_smooth_points = int(config.picard_config["insertsize_smooth_points"])
                log.debug("Custom Picard insert size smoothing: {}".format(insertsize_smooth_points))
            except (AttributeError, KeyError, ValueError):
                insertsize_smooth_points = 500

            # Plot the data and add section
            pconfig = {
                "smooth_points": insertsize_smooth_points,
                "smooth_points_sumcounts": [True, False],
                "id": "picard_insert_size",
                "title": "Picard: Insert Size",
                "ylab": "Count",
                "xlab": "Insert Size (bp)",
                "x_decimals": False,
                "tt_label": "<b>{point.x} bp</b>: {point.y:.0f}",
                "ymin": 0,
                "data_labels": [
                    {"name": "Counts", "ylab": "Coverage"},
                    {"name": "Percentages", "ylab": "Percentage of Counts"},
                ],
            }
            try:
                pconfig["xmax"] = config.picard_config["insertsize_xmax"]
            except (AttributeError, KeyError):
                pass

            self.add_section(
                name="Insert Size",
                anchor="picard-insertsize",
                description="Plot shows the number of reads at a given insert size. Reads with different orientations are summed. Calculated for all samples aligned to a reference genome.",
                plot=linegraph.plot([self.picard_insertSize_histogram, data_percent], pconfig),
            )

    # Return the number of detected samples to the parent module
    return len(self.picard_insertSize_data)
