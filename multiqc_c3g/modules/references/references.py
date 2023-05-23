""" MultiQC module to parse bibtex references in reports and make a reference section """

from __future__ import print_function
import logging

from pybtex.database import parse_file, BibliographyData, Entry
import pybtex.database.input.bibtex
from pybtex.database.format import format_database
import pybtex.plugin
from pybtex.style.formatting import BaseStyle
from pybtex.richtext import Text, Tag
from pybtex.bibtex import bst

from bs4 import BeautifulSoup
import shutil, os, yaml, re, io

from multiqc import config
from multiqc.modules.base_module import BaseMultiqcModule

# Start the logger
log = logging.getLogger('multiqc')
# This variable holds the directory of the module
__location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
log.info(__location__)
# This is the temporary folder name
tmp_directory = 'references_tmp'
# when running the script at any time, if the temporary folder does not exist create it
#, and mention it to the user.
if not os.path.isdir(tmp_directory):
    os.mkdir(tmp_directory)
    log.info(f"The temporary reference directory {tmp_directory} was created")

# The following class is used to find reference keys in content, replace it with the
# appropriate html code, and create a file with the reference keys found.
class Reference:
    # The __init__ takes content as the argument. This content can come from MultiQC modules as any
    # string. Therefore it could be a name, description, content, extra, anything that is a string.
    # But only one string can be processed at a time.

    def __init__(self, content):
        # Open the references yaml that has keys and their correspoding links
        with open(os.path.join(os.getcwd(), "report", "yaml", 'references.yaml'), 'r', encoding="utf8") as yamlfile:
            reference_yaml = yaml.safe_load(yamlfile)
        # Grab a dictionary of the keys and liks and set it to the reference dict
        self.reference_dict = reference_yaml.get('software')
        # The purpose of having content in self namespace is for each change done
        # to the content can be updated easily multiple times.
        self.htmlcontent = content
        # Initiate an instance specific list of citations
        self.citation_list = list()
        #calling the Object functions that will find and replace reference keys
        #in the content and create a temporary file with the relevant keys
        # if the temporary directory described before does not exist, then created
        self.makedir()
        # Finding reference keys
        references = self.find()
        # Adding to the tmp file
        tmpfilelist = self.createonetmpfile()
        # Replacing the reference keys with links
        self.replace(references, tmpfilelist)

    def find(self):
        # Function to find reference keys in the content that was passed by at __init__
        # Use regex to get a list of all the double braketted ([[key]]) keys in the content.
        references = re.findall(r'\[\[.*?\]\]', self.htmlcontent)
        # Sometimes empty items are found in the list which may reflect the level of the regex
        # code. Nevertheless, the regex still works so just remove the empty item ('') if it exists
        if '' in references:
            references.remove('')
        # continue if there is at least one item in the reference list
        if len(references) > 0:
            # Loop through each reference and use regex to remove the double leaving the key. Before: [[key]], After: key
            for reference in references:
                ref_key = re.sub(r'\[\[|\]\]', '', reference)
                # Add the key to the list of citations, but avoid repetition. Recall the list of citations is unique
                # to each instance and is initiated as an empty list in the __init__ above
                if not ref_key in self.citation_list:
                    self.citation_list.append(ref_key)
        return references

    def createonetmpfile(self):
        # Function for creating and updating a temporary file
        # This citation_list check is to exclude the citation_list if no reference keys
        # were found.
        if self.citation_list:
            # Open or create file in append+ mode
            with open(tmp_directory + f'/citation_list.tmp', 'a+', encoding="utf8") as tmpfile:
                # Seek the beginning of the file since it is in append mode.
                # Then filter out the reference keys that are already in the the temporary file
                tmpfile.seek(0)
                self.citation_list = list(filter(lambda x: (not(x in tmpfile.read().split(', '))),
                    self.citation_list))
                tmpfile.seek(0)
                # If the file is not empty add the add the new reference keys with a separator ', ' first
                # Otherwise just add the new reference keys normarlly.
                # This citation_list check is to remove exclude the citation_list if the filtered list
                # is empty
                if self.citation_list:
                    if tmpfile.read(1):
                        tmpfile.write(', ' + ', '.join(self.citation_list))
                    else:
                        tmpfile.write(', '.join(self.citation_list))
                tmpfile.seek(0)
                return tmpfile.read().split(', ')

    def replace(self, references, tmpfile):
        # Function to replace the reference keys in the self namespace content with the html.
        if len(references) > 0:
            for reference in references:
                ref_key = re.sub(r'\[\[|\]\]', '', reference)
                matchref = f'\[\[{ref_key}\]\]'
                # Re assign the htmlcontent variable using regex and the reflink function. The index from the temporary file
                # is used to add subscript numbers in-text and then link the numbers to the reference in the bibliography
                # This is where having content in the self namespace (self.htmlcontent) is important
                # Without htmlcontent in the self namespace the content would not be updated properly.
                self.htmlcontent = re.sub(matchref, self.reflink(ref_key, tmpfile.index(ref_key)), self.htmlcontent)

    def reflink(self, ref_key, index):
        # Function to grab the link to the bioinformatics tool webpage from the reference dict
        # The function also takes the index as determined by the temporary file
        working_ref_link = self.reference_dict.get(ref_key.lower(), None)
        if working_ref_link:
            ref_link = f"""<a href='{working_ref_link}' target='_blank'>{ref_key}</a>
                <a href='#reference_{index + 1}'><sup>{index + 1}</sup></a>"""
        else:
            ref_link = f"<a href='#'>{ref_key}</a><a href='reference_{index + 1}'><sup>{index + 1}</sup></a>"
        return ref_link

    @staticmethod
    def makedir():
        #Function to create the temporary folder directory if it does not exist
        if not os.path.isdir(tmp_directory):
            os.mkdir(tmp_directory)

# Starting the MultiqcModule class to use multiqc namespace
class MultiqcModule(BaseMultiqcModule):
    def __init__(self):

        # Initialise the parent object
        super(MultiqcModule, self).__init__(
             name="References",
             anchor="references",
                 )
        # Let the user know that the reference bibliography is under construction
        log.info('The references bibliography section is processing.')
        # Run the necessary functions on __init__
        self.RefRenderer()

    def RefRenderer(self):
        # Grab the citation list by reading the temporary file
        citation_list = self.refmergefiles()
        # Recrsively remove the temporary folder and notify the user
        self.refcleantmp()
        # Get the html bibliography content and then add a MultiQC section with the bibliography as the content
        bib_content = self.refmakebib(citation_list)
        # Only add a reference section if the bib_content exists
        if bib_content:
            self.add_section(content=bib_content)
        else:
            log.debug('''The reference section was not plotted because there were no references to render form the content above''')

    @staticmethod
    def refmergefiles():
        # Function has the ability to collect multiple files and add the reference keys into one
        # List of citations
        citation_list = list()
        for filename in os.listdir(tmp_directory):
            with open(tmp_directory + '/' + filename, 'r', encoding="utf8") as filename:
                keys = filename.read().split(', ')
                if '' in keys:
                    keys.remove('')
                # loop through the keys and add them to the citation list if they exist or are not empty strings
                for key in keys:
                    if key:
                        citation_list.append(key)
        return citation_list

    @staticmethod
    def refcleantmp():
        # Function for removing the temporary directory if it exists
        if os.path.isdir(tmp_directory):
            shutil.rmtree(tmp_directory)
            log.info(f"The temporary directory {tmp_directory} was removed recursively.")

    @staticmethod
    def refmakebib(citation_list):
        '''
        Function
        --------
        get the list of citations, and returns the full bibliography
        The function uses the pybtex module to build the bibliography

        Details
        -------
        The pybtex documentation is very difficult to understand
        There is another module called citeproc-py that is easier and more modern
        But some parts do not work with certain versions of python
        This is the example I followed:
        https://github.com/brechtm/citeproc-py/blob/master/examples/bibtex.py
        And this is the error I encountered:
        https://github.com/brechtm/citeproc-py/issues/103

        Load a bst. This is not used later on but theoretically it is a good lead
        for specifying the citation style such as apa, mla, or etc. The one used here
        is natbib, which I found on a oxford bioinformatics journal. I got the bst file
        from a Google search there are multiple ways to find bst files.
        '''
        bstload = bst.parse_file(os.path.join(__location__, 'natbib.bst'))


        # Load the pybtex plain style
        style = pybtex.plugin.find_plugin('pybtex.style.formatting', 'plain')()

        # Load the backend. The backend is like a reservoir that catches the bibliography entries
        # as they are rendered
        backend = pybtex.plugin.find_plugin('pybtex.backends', 'html')()

        # Load the file containing all of the BibTeX citaions. Not all of the citations in the
        # file will be used.
        data = parse_file(os.path.join(__location__, 'citations.bibtex'), bib_format = 'bibtex')

        # Format the bibliography the citations from the BibTeX are filtered to only those in the list of citations
        formated_bib = style.format_bibliography(data, citations=citation_list)

        # Conform the order of the bibliography to the order in the list of citations
        # This corresponds with the order that is extracted from the temporary file
        ordered_entries = list()
        for citation in citation_list:
            for entry in formated_bib.entries:
                if entry.key == citation.lower():
                    ordered_entries.append(entry)

        formated_bib.entries = ordered_entries

        # Output the formated bibliography to the backend
        output = io.StringIO()
        backend.write_to_stream(formated_bib, output)

        #Set the output to rendered_bib
        rendered_bib = output.getvalue()

        # Edit the html tags
        # dl to ol
        rendered_bib = re.sub(r'(?!<.*)dl>', 'ol>', rendered_bib)

        # remove dt
        rendered_bib = re.sub(r'<dt>.*<\/dt>', '', rendered_bib)

        # dd to li
        rendered_bib = re.sub(r'<dd>', f"<li class='bib_item'>", rendered_bib)
        rendered_bib = re.sub(r'<\/dd>', '</li>', rendered_bib)

        # Convert rendered_bib to a BeautifulSoup4 object
        rendered_bib = BeautifulSoup(rendered_bib, 'html.parser')

        # Add the numbered ancor for the list items
        for index, _ in enumerate(formated_bib.entries):
            li = rendered_bib.find_all('li')[index]
            li['id'] = f'reference_{index + 1}'
        ref_target_color = getattr(config, 'references', []).get('ref_target_color', '#bfffd7')

        # add css to the head tag
        head = rendered_bib.find('head')
        style_tag = rendered_bib.new_tag('style')

        # Add any additional css here
        # If you want to add javascript you can use beautifulsoup4 object to place it wherever you want
        # Then you can add a script tag and add your script there
        style_tag.append('''
            .bib_item {padding-left: 2.5%; text-indent: -2.5%; line-height: 1.8em; border-radius: 5px;}
            li.bib_item:not(:last-child) {margin-bottom: 0.5em;}
            li:target {background: ''' + ref_target_color + ''';}
        ''')
        head.append(style_tag)

        # Returning the finished bibliography. The prettify method is from beautifulsoup and just makes the html reader friendly.
        return rendered_bib.prettify()
