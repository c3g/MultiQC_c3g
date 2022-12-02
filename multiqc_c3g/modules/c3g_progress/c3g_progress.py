#!/usr/bin/env python

""" C3G Genpipes JSON plugin module """

from __future__ import print_function
import functools
import logging
import os
import subprocess
import re
from typing import OrderedDict

from multiqc.plots import table
from multiqc.modules.base_module import BaseMultiqcModule

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(BaseMultiqcModule):
    def __init__(self):

        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Job Progress",
            target="Progress",
            anchor="progress",
            href="https://github.com/c3g/runprocesing_plugin",
            info=" files from run processing output",
        )

        job_data = dict()
        for f in self.find_log_files("c3g_progress"):
            log.info("Found joblist: {}".format(f['fn']))
            for line in f['f'].splitlines():
                id, name, dependencies, outpath = line.split("\t")
                outpath_whole = os.path.join(f['root'], outpath)
                job = Job(id, name, dependencies, outpath_whole)
                if job.name in job_data:
                    if job > job_data[job.name]:
                        job_data[job.name] = job
                else:
                    job_data[job.name] = job

        jobs_by_step = dict()
        for (name, job) in job_data.items():
            if job.step in jobs_by_step:
                if job.status in jobs_by_step[job.step]:
                    jobs_by_step[job.step][job.status] += 1
                else:
                    jobs_by_step[job.step][job.status] = 1
            else:
                jobs_by_step[job.step] = {
                    "Holding"   : 0,
                    "Queued"    : 0,
                    "Running"   : 0,
                    "Complete"  : 0,
                    "Error"     : 0,
                    "Cancelled" : 0,
                    "Unknown"   : 0,
                }
                jobs_by_step[job.step][job.status] += 1

        headers = OrderedDict()
        headers['Holding'] = {'description': 'Jobs waiting on dependencies', 'format': '{:,.0f}'}
        headers['Queued'] = {'description': 'Jobs could start running at any time', 'format': '{:,.0f}'}
        headers['Running'] = {'description': 'Jobs currently running', 'format': '{:,.0f}'}
        headers['Complete'] = {'description': 'Jobs complete', 'format': '{:,.0f}'}
        headers['Error'] = {'description': 'Jobs with errors', 'format': '{:,.0f}'}
        headers['Cancelled'] = {'description': 'Jobs manually cancelled', 'format': '{:,.0f}'}
        headers['Unknown'] = {'description': 'Jobs manually unknown', 'format': '{:,.0f}'}

        self.add_section(
            name = "Jobs",
            description = "Job statuses.",
            plot = table.plot(jobs_by_step, headers)
        )

class Job:
    _name = None
    _status = None
    _queue_status = None
    _exitstatus = None
    _stop = None
    def __init__(self, id, name, dependencies, outfile_path):
        self._id = id
        self._name = name
        self._dependencies = dependencies.split(":")
        self._outfile = outfile_path

    @property
    def jobnum(self):
        return self.id.split(".")[0]

    @property
    def id(self):
        return self._id

    @property
    def name(self):
        return self._name

    @property
    def step(self):
        return self._name.split('.')[0]

    @property
    def outfile(self):
        return self._outfile

    @property
    def queue_status(self):
        if self._queue_status is not None:
            return self._queue_status
        result = subprocess.run(['qstat', '-f', '-1', self.id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        for line in result.stderr.decode('utf-8').splitlines():
            if line.startswith('qstat: Unknown Job Id Error'):
                self._queue_status = 'X'
                return self._queue_status

        for line in result.stdout.decode('utf-8').splitlines():
            if line.lstrip(' ').startswith('job_state ='):
                self._queue_status = line.split(' ')[-1]
                return self._queue_status

        log.warning("Scanned all the lines and could not find job_state!")
        self._queue_status = 'Y'
        return self._queue_status

    @functools.cached_property
    def status(self):
        # Use cached value if available
        if self._status is not None:
            return self._status
        # Otherwise, check status on filesystem
        outfile_exists = os.path.isfile(self.outfile)
        if not outfile_exists:
            # Check the queue
            if self.queue_status == 'H':
                return "Holding"
            elif self.queue_status == 'R':
                return "Running"
            elif self.queue_status == 'Q':
                return "Queued"
            else:
                return "Cancelled"
        else:
            # Outfile exists, just need to determine if the job is incomplete, error, complete, or "other".
            self.parse_outfile()
            if self._exitstatus is not None:
                # Definitely finished
                if self._exitstatus == 0:
                    return "Complete"
                else:
                    return "Error"
            elif self._stop is not None:
                # Job is finished, but we don't know the exit status
                # Note that here, the exit status is missing, so we
                # can't be confident that the job finished without error.
                return "Complete"
            elif self.queue_status == 'R':
                return "Running"
            elif self.queue_status == 'Y':
                return "Unknown"
            else:
                log.warning("Could not determine status (queue status == '{}') for file {}".format(self.queue_status, self._outfile))
                return "Unknown"

    def parse_outfile(self):
        if not os.path.isfile(self.outfile):
            log.warning("Could not find outfile: {}".format(self._outfile))
            return
        jobsrt_p = re.compile("^Begin PBS Prologue.* (\d+)$")
        jobstp_p = re.compile("^Begin PBS Epilogue.* (\d+)$")
        exitid_p = re.compile("^MUGQICexitStatus:(\d+)")

        lines = []
        if os.path.getsize(self.outfile) < 20000:
            with open(self.outfile, 'r') as f:
                lines = f.readlines()
        else:
            head = self.head()
            tail = self.tail()
            lines = head + tail

        for line in lines:
            m = jobsrt_p.match(line)
            if m:
                self._start = m.group(1)
                continue
            m = jobstp_p.match(line)
            if m:
                self._stop = m.group(1)
                continue
            m = exitid_p.match(line)
            if m:
                self._exitstatus = int(m.group(1))
                continue

    def head(self, n=10):
        with open(self.outfile) as myfile:
            return [next(myfile) for x in range(n)]

    def tail(self, n=1024):
        seekback = min(n, os.path.getsize(self.outfile))
        with open(self.outfile, 'rb') as file:
            file.seek(-1 * seekback, os.SEEK_END)  # Note minus sign
            tail = file.read().decode("utf-8")
            return tail.split('\n')

    def __lt__(self, other):
        return self.jobnum < other.jobnum

    def __le__(self, other):
        return self.jobnum <= other.jobnum

    def __gt__(self, other):
        return self.jobnum > other.jobnum

    def __ge__(self, other):
        return self.jobnum >= other.jobnum

    def __eq__(self, other):
        return self.jobnum == other.jobnum

    def __ne__(self, other):
        return self.jobnum != other.jobnum
