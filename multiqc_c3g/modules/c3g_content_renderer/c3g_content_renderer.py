""" MultiQC module to add html, md, or text content generated by GenPipes """

from __future__ import print_function
import logging
import markdown
from bs4 import BeautifulSoup

from multiqc_c3g.modules.references import references
from multiqc_c3g.modules.c3g_yaml_parser import c3g_yaml_parser

from multiqc import config
from multiqc.base_module import BaseMultiqcModule

# Start the logger
log = logging.getLogger('multiqc')

# Starting the MultiqcModule class to use multiqc name space
class MultiqcModule(BaseMultiqcModule):
    # Starting the a content object using the c3g_yaml_parser
    # Here we provide the name of the module key used in module_order, the current module_order and the config in general
    YamlParser = c3g_yaml_parser.Contents('c3g_content_renderer', config.module_order, config)
    # Start the counter at 1 each time the class is loaded
    count = 1
    def __init__(self):
        # Initialise the parent object
        super(MultiqcModule, self).__init__(
             name="c3g_content_renderer",
             anchor="c3g_content_renderer",
             )
        # Let the user know that the module has begun processing
        log.info(f"The c3g content module is processing")
        # Run the the count_and_content() class method to get content information and increment
        # the count number so that the next initialized c3g_content_renderer will have the next
        # number up. The following demonstrates how Multiqc Modules work. It seems that the MultiqcModule class is
        # loaded at runtime. Then each time the module key in module order is called, Multiqc initiates an object
        # of this class. The loading at runtime and multiple instances allows the count_and_content function to
        # count each time the content module is mentioned in module_order.

        # Runing the count_and_content() function returns the instance, the section_title, the content and parent_title
        # The instance is the count number.
        _, section_title, content, parent_title = MultiqcModule.count_and_content(self)
        # Setting up the logic for rendering the section or parent title. This also makes it more intuitive.
        setname = None
        if (not(section_title) and parent_title) or (section_title and parent_title):
            self.name = parent_title
            if section_title:
                setname = section_title
        elif section_title and not parent_title:
            self.name = section_title
            setname = None
        else:
            self.name = self.name.replace('_', ' ')
            setname = None

        # Only render the content if the content is not empty.
        if content:
            #Starting the reference object
            cita = references.Reference(content)
            self.add_section(name=setname, content=cita.htmlcontent)

    @classmethod
    def count_and_content(cls, self):
        # Function that gets the content and the count number based on where the current instance is in module_order
        for index, instance in enumerate(self.YamlParser.order_list):
            if index + 1 == cls.count:
                self.YamlParser.content(instance)
                self.YamlParser.htmlcontent = markdown.markdown(self.YamlParser.htmlcontent, extensions=['markdown.extensions.tables'])
                if 'table' in self.YamlParser.htmlcontent:
                    # Edit the html of the html tables using Beautiful Soup
                    bs4html = BeautifulSoup(self.YamlParser.htmlcontent, 'html.parser')
                    bs4table = bs4html.find('table')
                    bs4table['style'] = 'width: 100%;'
                    bs4table['class'] = 'md_table_css'
                    styletag = bs4html.new_tag('style')
                    styletag.append('''
                        .md_table_css {background-color: #f5f7fa;}
                        .md_table_css td, th {padding: 10px;}
                        .md_table_css tr:last-child {border-bottom: 1.7px solid #c7c7c7;}
                        .md_table_css thead th { border-bottom: 0.7px solid #c7c7c7; border-top: 1.7px solid #c7c7c7}
                    ''')
                    bs4table.append(styletag)
                    self.YamlParser.htmlcontent = bs4html.prettify()
                cls.count += 1
                return cls.count, self.YamlParser.section_title, self.YamlParser.htmlcontent, self.YamlParser.parent_title
