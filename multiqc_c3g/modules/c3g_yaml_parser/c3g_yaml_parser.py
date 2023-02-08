""" This is an additional scriprt for the readtsv MultiQC module """

import os, re, base64

# Making the yaml parent object
class ModuleYamlParser:
    # Class the parent yaml parsing object
    def __init__(self, ModuleName, config_module_order, config):
        # Function that initializes the parent object
        # All the child objects run the following init code with
        # different inputs

        # filter the module order to the modules that have a specific ModuleName.
        # Module order is a list of nested dictionaries.
        # [{ModuleName: {...}}, {ModuleName2: {...}}] is a good example of the module_order
        # config module order is passed into the init because I thought it
        # might be different each init. However, upon rexamination
        # it could be placed here if needed
        self.order_list = list(filter(lambda mod: (list(mod.keys())[0] == ModuleName), config_module_order))
        # The module name and the Multiqc config object are used bellow
        # and are here added to the self namespace
        self.ModuleName = ModuleName
        self.config = config

    # Linking the file to the id and the first path_filter.
    # Some of the code here may no longer be useful
    # Specifically those related to the path filters.
    def filepathlink(self, filename):
        for i in self.order_list:
            fileroot = '*' + filename['root'] + '/'
            self.path_filters = i.get(self.ModuleName).get('path_filters', [''])[0]
            if filename['fn'] in self.path_filters:
                self.path_filters = self.path_filters.replace(fileroot, '')
                self.idr = i.get(self.ModuleName).get('id', self.path_filters[:-4])
                return self.order_list.index(i)

    # New function to grab information based on the instance
    def idpathlink(self, count):
        instance = self.order_list[count - 1]
        self.idr = instance.get(self.ModuleName).get('id', None)
        # Get config attributes from multiqc
        self.readtsv_config = getattr(self.config, self.idr, {})
        # Find the table path and put it in self namespace for
        # comparisons with log files
        self.file_path = self.readtsv_config.get('table_path', [''])[0]
        # If the table_path is empty check if there is an
        # image_path.
        if not self.file_path:
            self.file_path = self.readtsv_config.get('image_path', [''])[0]

class Tables(ModuleYamlParser):
    def __init__(self, ModuleName, config_module_order, config):
        super().__init__(ModuleName, config_module_order, config)
        self.table_color_scale = getattr(self.config, 'table_color_scale', None)

    # Run the necessary funtions for the Tables obj.
    def table(self, tsv_file):
        self.tableconfig(tsv_file)
        self.tablevariables(tsv_file)

    def tableconfig(self, tsv_file):
        index = self.filepathlink(tsv_file)

    # Get the necessary variables by using the id set with filepathlink().
    def tablevariables(self, tsv_file):
        # set config variables and return them
        # This is where you can set config options for c3g tables
        self.table_title = self.readtsv_config.get('table_title', '')
        self.parent_title = self.readtsv_config.get('parent_title', None)
        self.html = self.readtsv_config.get('content', '')
        self.section_title = self.readtsv_config.get('section_title', '')
        self.downhtml = "(<a href='{}'>download table</a>)".format(os.path.join(tsv_file['root'], tsv_file['fn']))

    # New function to grab information based on the instance
    def tablepathlink(self, count):
        instance = self.order_list[count - 1]
        self.idr = instance.get(self.ModuleName).get('id', None)
        # Get config attributes from multiqc
        self.readtsv_config = getattr(self.config, self.idr, {})
        # Find the table path and put it in self namespace for
        # comparisons with log files
        self.table_path = self.readtsv_config.get('table_path', [''])[0]

class Images(ModuleYamlParser):
    def __init__(self, ModuleName, config_module_order, config):
        super().__init__(ModuleName, config_module_order, config)

    def image(self, img_file):
        self.imgconfig(img_file)
        #self.imgvariables(img_file)

    def imgconfig(self, img_file):
        index = self.filepathlink(img_file)
        identifier = index.get(self.ModuleName).get('id', None)
        iden_link = getattr(self.config, identifier, {})
        file_path = iden_link.get('file_path', [])
        self.high_res_format = iden_link.get('high_res_format', None)

    def imgvariables(self, instance_self):
        for image in self.path_filters:
            print('This is how we link the image: ', image)
            file_type = re.findall(r'(?!\.)(?!.*?\.).*\S', image)[0]
            if self.high_res_format == '':
                self.high_res_format == file_type
            self.downhtml = "(<a href='{}' style='font-size: large;'>Download the high-res image</a>) ".format(re.sub(r'(?!\.)(?!.*?\.).*\S', self.high_res_format, image))
            with open(image, 'rb') as img:
                base64img = "<img src = 'data:image/{};base64,".format(file_type) +  base64.b64encode(img.read()).decode() + "'>"
                instance_self.add_section(content=self.downhtml + '<br>' + base64img) # Move this to the actual module

class Contents(ModuleYamlParser):
    def __init__(self, ModuleName, config_module_order, config):
        super().__init__(ModuleName, config_module_order, config)

    def content(self, instance):
        self.contentconfig(instance)

    def contentconfig(self, instance):
        identifier = instance.get(self.ModuleName).get('id', '')
        path_filters = instance.get(self.ModuleName).get('path_filters', None)
        self.section_title, self.htmlcontent, self.parent_title  = '', '', ''
        if identifier != '' and not path_filters:
            iden_link = getattr(self.config, identifier, {})
            if iden_link != {}:
                self.section_title = iden_link.get('section_title')
                self.parent_title = iden_link.get('parent_title')
                self.htmlcontent = iden_link.get('content')
