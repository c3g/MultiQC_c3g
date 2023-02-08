""" Associate C3G module used to count instances of a Multiqc module
    The the count has to be initiated in the MultiqcModule child
    itself like this:

    class MultiqcModule(BaseMultiqcModule):
        count = 1

"""

import os

def count_and_run(cls, self, YamlParser, ModuleName, config):
    ''' Function
        --------
        Takes in the class name, the self object, the YamlParser object, the
        the name of the multiqc module, and the multiqc config object.

        Usage
        -----
        uses a counter variable in class namespace to get the path
        for the image or table as well as the id to grab associated
        c3g content as well.

    '''

    for index, _ in enumerate(self.YamlParser.order_list):
        if index + 1 == cls.count:
            # Grab some useful information including table or image path
            self.YamlParser.idpathlink(cls.count)
    cls.count += 1

    for c3g_file in self.find_log_files(ModuleName):
        # fileloc = os.path.join(c3g_file['root'], c3g_file['fn'])
        # if fileloc[0] != '/':
        #     fileloc = '/' + fileloc
        # Get the working directory from the config
        # Set the default to report
        # The working directory is the directory where multiqc is going to be run
        # filefilter = getattr(config, 'working_dir', 'report') + '/'
        # Both image_path and table_path are saved to file_path
        filename = os.path.basename(self.YamlParser.file_path)
        if c3g_file['fn'] == filename:
            # Your main funtion that plots the content, image or table
            # needs to be called c3g_run to avoid unecessary if statements
            self.c3g_run(c3g_file)
