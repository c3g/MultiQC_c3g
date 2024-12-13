# README #

MultiQC_c3g is a plugin for MultiQC, providing additional tools which are specific to the GenPipes pipelines developed at the Canadian Centre for Computational Genomics (C3G). At the moment, it is used mostly for reporting for our internal run processing pipeline.

For more information about C3G, see http://www.computationalgenomics.ca/

For more information about GenPipes, see https://genpipes.readthedocs.io/en/latest/

For more information about MultiQC, see http://multiqc.info


### What is this repository for? ###

This plugin allows C3G to write MultiQC extensions for custom pipeline reporting. It can also render: images, tables (tsv or csv), and content.

### How do I get set up? ###

1- You will need to pip install this branch. You may modify the `load_tem_scr.sh` bash script above and use it to install multiqc_c3g.

2- If it does not work, contact [Mareike Janiak](mareike.janiak@computationalgenomics.ca) to dicuss the tool and its uses and to decide if it goes in the main MultiQC repo or in the C3G plugin. You may also contact [Paul Stretenowich](paul.stretenowich@mcgill.ca) for the questions related to C3G sections.


### How to run the plugin? ###

1- First `git clone` the repository and pip install it. Alternatively, if you are working on the abacus cluster, you can load the latest module with `module load mugqic_dev/MultiQC_C3G`

2- Run `multiqc .` to search the current directory for log files and create a report.

3- For use with the c3g run processing template and modules run `multiqc . --template c3g --runprocessing --interactive` 

### Where are the example yamls? ###

The example yamls are located in the `example_yamls` folder. Follow the documentation in the `docs` folder for more details.

### 	MultiQc Resources: ###

[Basic intro](https://www.youtube.com/watch?v=t2lV0ucrD2s&feature=youtu.be)

[MultiQc Core modules](http://multiqc.info/docs/#writing-new-modules)

[MultiQc Plugin](http://multiqc.info/docs/#multiqc-plugins)

[MultiQc custom template](http://multiqc.info/docs/#writing-new-templates)

[MultiQc custom content](http://multiqc.info/docs/#custom-content)

[MegaQc](https://github.com/ewels/MegaQC)

**Custom plugins and content by other organizations:**

[Example Plugin](https://github.com/MultiQC/example-plugin)

[NGI](https://github.com/ewels/MultiQC_NGI)

[alascca](https://github.com/ClinSeq/multiqc-alascca)

[bcbio](https://github.com/MultiQC/MultiQC_bcbio)

[C3G multiQC_C3G plugin repo](https://github.com/c3g/MultiQC_c3g)

[MultiQC gitter](https://gitter.im/ewels/MultiQC)




### Contribution guidelines ###

MultiQC and the MultiQc C3G plugin are written in python. Contributors must check the [contribution guildines for C3G](https://github.com/c3g/GenPipes/blob/master/README-GenAP_coding_standards.txt), as well as those for [MultiQC](http://multiqc.info/docs/#coding-with-multiqc).


### Who do I talk to? ###

Within C3G, please talk to Mareike Janiak (mareike.janiak@computationalgenomics.ca), Paul Stretenowich (paul.stretenowich@mcgill.ca) or Jean-Michel Garant (jean-michel.garant@mcgill.ca).
