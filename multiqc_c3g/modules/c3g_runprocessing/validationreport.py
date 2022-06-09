#!/usr/bin/env python
from collections import UserDict
import json

""" C3G Genpipes Runvalidation Report Class """
class ValidationReport(UserDict):

    @staticmethod
    def from_string(s):
        d = json.loads(s)
        return ValidationReport(d)

    @staticmethod
    def from_path(path):
        with open(path, 'r') as f:
            contents = f.read()
            ValidationReport.from_string(contents)

    @property
    def version(self):
        version = self.data.get('version', '1.0')
        return float(version)

    @property
    def run(self):
        return self.data.get('run')

    @property
    def instrument(self):
        return self.data.get('instrument')

    @property
    def flowcell(self):
        return self.data.get('flowcell')

    @property
    def lane(self):
        return self.data.get('lane')

    @property
    def seqtype(self):
        return self.data.get('seqtype')

    @property
    def sequencing_method(self):
        return self.data.get('sequencing_method')

    @property
    def readset_names(self):
        return [name for name in self.data.get('readsets')]

    @property
    def readsets(self):
        return [Readset.with_name(name, dct) for name, dct in self.data.get('readsets').items()]

    @property
    def barcodes(self):
        return [bc for rs in self.readsets for bc in rs.barcodes]


class Readset(UserDict):

    @staticmethod
    def with_name(name, dct):
        r = Readset(dct)
        r.name = name
        return r

    @property
    def name(self):
        return self.data.get('name')

    @name.setter
    def name(self, newname):
        self.data['name'] = newname

    @property
    def barcodes(self):
        return [Barcode(bc) for bc in self.data.get('barcodes')]

    @property
    def project(self):
        return [bc.get('PROJECT') for bc in self.data.get('barcodes')][0]

    @property
    def library(self):
        return self.barcodes[0].library if 0 < len(self.barcodes) else "unknown library"

    @property
    def index_name(self):
        return self.barcodes[0].index_name if 0 < len(self.barcodes) else "unknown index name"


class Barcode(UserDict):

    @property
    def name(self):
        return self.data.get('SAMPLESHEET_NAME')

    @property
    def library(self):
        return self.data.get('LIBRARY')

    @property
    def project(self):
        return self.data.get('PROJECT')

    @property
    def index_name(self):
        return self.data.get('INDEX_NAME')

    @property
    def index_1(self):
        return self.data.get('INDEX1')

    @property
    def index_2(self):
        return self.data.get('INDEX2')

    @property
    def adapter_i7(self):
        return self.data.get('ADAPTERi7')

    @property
    def adapter_i5(self):
        return self.data.get('ADAPTERi5')

    @property
    def adapters(self):
        return {
            'i7' : self.data.get('ADAPTERi7'),
            'i5' : self.data.get('ADAPTERi5')
        }