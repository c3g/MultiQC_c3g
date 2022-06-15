# README #

MultiQC_c3g is a plugin for MultiQC, providing additional tools which are specific to the GenPipes pipelines developed at the Canadian Centre for Computational Genomics (C3G).

For more information about C3G, see http://www.computationalgenomics.ca/

For more information about GenPipes, see https://bitbucket.org/mugqic/genpipes

For more information about MultiQC, see http://multiqc.info


### What is this repository for? ###

This plugin allows C3G to write MultiQC extensions for custom pipeline reporting. It can also render: images, tables (tsv or csv), and content.

### How do I get set up? ###

1- You will need to pip install this branch. You may modify the `load_tem_scr.sh` bash script above and use it to install multiqc_c3g.

2- If it does not work, contact [Rola Dali](rola.dali@mail.mcgill.ca) to dicuss the tool and its uses and to decide if it goes in the main MultiQC repo or in the C3G plugin. You may also contact Paul Stretenowich or Édouard Henrion for the questions related to C3G sections.


### How to run the test data? ###

1- First `git clone` the newton_c3g branch.

2- Run  `cd test_data/chipseq_test_2/report`.

3- Use the `test_data/chipseq_test_2/multiqc_run.sh` bash script to run multiqc. The module loading should already be inculded in the script.

### Where are the example yamls? ###

The example yamls are located in the `example_yamls` folder. Follow the documentation in the `docs` folder for more details.

### 	MultiQc Resources: ###

[Basic intro](https://www.youtube.com/watch?v=t2lV0ucrD2s&feature=youtu.be)

[MultiQc Report of all modules (as of May 2018)](https://drive.google.com/open?id=1mDW6jIV0pKv1XCQSlyXF-pjqM3PeSyYX)

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

[C3G multiQC main repo](https://bitbucket.org/mugqic/multiqc)

[C3G multiQC_C3G plugin repo](https://bitbucket.org/mugqic/multiqc_c3g)

[MultiQC gitter](https://gitter.im/ewels/MultiQC)






### Contribution guidelines ###

MultiQC and the MultiQc C3G plugin are written in python. Contributors must check the [contribution guildines for C3G](https://bitbucket.org/mugqic/genpipes/src/master/README-GenAP_coding_standards.txt), as well as those for [MultiQC](http://multiqc.info/docs/#coding-with-multiqc).


### Who do I talk to? ###

Within C3G, please talk to Rola Dali (rola.dali@mail.mcgill.ca), Mathieu Bourgey (mathieu.bourgey@mcgill.ca) or Edouard Henrion (edouard.henrion@mcgill.ca).
