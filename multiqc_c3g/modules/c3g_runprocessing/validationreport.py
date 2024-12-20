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
        proj_by_sample = {x.get('sample'):x.get('project') for x in self.data.get('run_validation')}
        index_dct_by_sample = {x.get('sample'):x.get('index') for x in self.data.get('run_validation')}
        align_dct_by_sample = {x.get('sample'):x.get('alignment') for x in self.data.get('run_validation')}

        if self.version == '1.0':
            reported_sex_by_sample = {x.get('sample'):x.get('reported_sex') for x in self.data.get('run_validation')}
        elif self.version == '2.0':
            reported_sex_by_sample = {x.get('sample'):x.get('alignment').get('reported_sex') for x in self.data.get('run_validation')}
        else:
            reported_sex_by_sample = {x:self.data.get('readsets')[x].get('reported_sex') for x in self.data.get('readsets')}

        return [
            Readset
            .from_dct(dct)
            .with_name(name)
            .with_reported_sex(reported_sex_by_sample.get(name))
            .with_project(proj_by_sample.get(name))
            .with_index_dict(index_dct_by_sample.get(name))
            .with_align_dict(align_dct_by_sample.get(name))
            .with_version(self.data.get('version'))
            for name, dct in self.data.get('readsets').items()
        ]

    @property
    def barcodes(self):
        return [bc for rs in self.readsets for bc in rs.barcodes]

class Readset(UserDict):

    @staticmethod
    def from_dct(dct):
        return Readset(dct)

    def with_name(self, name):
        self.data['name'] = name
        return self

    def with_reported_sex(self, reported_sex):
        self.data['Reported Sex'] = reported_sex
        return self

    def with_project(self, project_name):
        self.data['Project'] = project_name
        return self

    def with_index_dict(self, index_dict):
        self.data['PF Clusters'] = index_dict['pf_clusters']
        return self

    def with_align_dict(self, align_dict):
        self.data['Inferred Sex'] = align_dict['inferred_sex']
        self.data['Sex Concordance'] = align_dict['sex_concordance']
        return self

    def with_version(self, version):
        self.data['version'] = version
        return self

    @property
    def name(self):
        return self.data.get('name')

    @name.setter
    def name(self, newname):
        self.data['name'] = newname

    @property
    def pool_fraction(self):
        if float(self.data.get('version')) >= 3:
            return self.data.get('pool_fraction')
        else:
            return None

    @property
    def library_type(self):
        if float(self.data.get('version')) >= 3:
            return self.data.get('library_type')
        else:
            return None

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
