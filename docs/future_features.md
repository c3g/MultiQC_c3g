# Future Feature Ideas

The `multiqc_c3g` module can render content, tables, and images. However, there are some additional features that could imporve its use case. Bellow is a list of some features that may be useful in the future. Each feature discussion bellow inculudes the thought process and some ideas to begin implementing the featrue.

* Code imporvement: The use of path_filters vs. id
* Allow grouping using parent_title
* Typography, color scheming, ans uniqueness of the report
* Intext referencing for multiqc moddules
* Command line options
* Monitor the submitted github multiqc issues
* Enable integration with R plots and R markdown
* Fading highlight for reference
* More comprhensive logging
* Reporting for other piplines

## Code imporvement: The use of path_filters vs. id

Multiqc uses pathfilter in module_order to distiguish where each table or image is rendered. For a whie the multiqcc3g relied on using path_fiters for tables and images. However, multiqc_c3g more recently use a table path and image_path to get the name of the files and an id to specify where it should be rendered. Some of the old path_fiters related code still exists. It especially rmains in the c3g_yaml_parser. Some questions to think about include.

   * Is it benefitial to have both path_fiters and the new system?

## Allow grouping using parent_title

If more than one `add_section()` MultiqcModule functions are called during a current __init__ of the class, then those sections will be grouped under the same parent. As a result, the table of contents shows these sections underneath the parent. At the momment `parent_title` is an alternative to `section_title`. However, it is so posed to be a way to group multiple c3g a sections. Grouping multiple sections may be useful too in the future. One way to achieve this is to change all `module_order` c3g sections to `c3g_section_renderer`. Then, for every __init__ if `parent_title` is found do not call `add_section()` until the parent title in the next __init__ is either `None` or something different. Then call `add_section()` with the `name` parameter set to the `section_title`, but outside of that set the `self.name` __init__ varaible to the `parent_title`. Bellow is an example of a potential new `module_order`.

```yaml
module_order:
  - trimmomatic
  - c3g_section_renderer:
      id: mark_dup
  - c3g_section_renderer:
      id: view_filter
  - picard
  - c3g_section_renderer:
      id: sequencing_alignment_metrics
  - c3g_section_renderer:
      id: qc_tag
  - homer
  - c3g_section_renderer:
      id: ucsc_tracks
  - c3g_section_renderer:
      id: peak_calls
  - macs2
  - c3g_section_renderer:
      id: peaks_annotation
  - c3g_section_renderer:
      id: N_peaks_motifs_analysis
  - c3g_section_renderer:
      id: peak_stats_narrow
  - c3g_section_renderer:
      id: peak_location_stats
  - c3g_section_renderer:
      id: ihec_metrics
  - references
```

## Typography, color scheming, ans uniqueness of the report

The design ofthe new C3G report is more mobliefriendly automated and elegant than before . However, perhaps it could be taken a stepfurther. Multiqc is a growing bioinformatics reporting module. However all multiqc reports regardless of the typical customizations through the configuration yaml file, look quite similar. Therefore, it woud be nice for C3G coud choose a font and typography that is both professional and unique.

The color scheme could also be adjusted to reflect the C3G brand color scheme. There coud aso be css changes in the table of contents or other changes to the logic of the (jinja) template itself. There could also be other desin elements that addto the elegance of the report. 

## Intext referencing for multiqc moddules

At the moment the reference modue only cites refereces keys (ex. \[\[homer\]\]) that are found in c3g rendered sections. It dowsnot cite similar or unique references in multiqc default modules. Extending the refernce module to default modules poses  some logistical challenges. The reference module is pyton based and the referece key detection requires a reference object see the main docs for details. this reference object cannot easily be added to the source code of the default modues. Modifying the mosule itself is an option but is not very sustainable since modules change often. Another issue is the time when the module is modified. Therefore ifthe modification is made by another module, then this now modules would have to be called before the other module. Alternatively to starting a referece object, the self.name and self.extra of the multiqc module can be changed as shown bellow to get a close effect. Still, changing the module source code is not very sustainable or practical. Therefore, consider changing the config options ofthe mosule in module_order.

```yaml
modue_order:
     - homer:
          name: HOMER
          extra: homer<a href='#refence_3'><sup>3</sup></a>
```

This modification would have to be made by the pipline. Since, the pipeline will know the order of the modules in the report and can adjust the yaml accordingly. Furthermore, the reference module will have to be updated to have the pipline generated list of citations. One small issue woud be the difference in nameing of c3g vs. multiqc modules (for example macs vs MACS2). Another consideration would be to replace the numbering system for an alphabetical system. The references would be alphabetically organised in the reference section.

Another method would be to submit a pull request for Multiqc to include the reference module as a main Multiqc module.

## Command line options

Multiqc allows for plugins to specify their own command line options. There are multiple reasons why command line options would be useful. It could be used to specify configurations. It could be used to enable or disable additional features. The reference module coud have command line options that update the list of possible refernces and thier links (references.yaml). The command line is a very powerful way of adding runtime configurability or making changes to the way the modules work.

## Moniter the submitted github multiqc issues

There are a few multiqc github issues that were submited during the development of multiqc_c3g. A ist of the issues is cited bellow for future reference.

   * [TSV Tables overwriting different rows with same sample name](https://github.com/ewels/MultiQC/issues/1476)
   * [Column contents overlap for tables](https://github.com/ewels/MultiQC/issues/1517)

## Enable integration with R plots and R markdown

Multiqc plots are made with matplotlib, a python module. Some pipline outputs use  R ggplots or basic R plots to visualize the data. It would be beneficial to improve the integration of R plots and R markdown files with multiqc. This could bevachieved by creating a multiqc_c3g module that collects R plots and R markdown fies, processes them, and then plots or renders them. To make the plots interactive consider using highcharts-js, which is what multiqc uses. Highcharts-js can used with [R ggplots](https://www.tmbish.me/lab/highcharter-cookbook/). There are a lot of online resources for using highcharts-js the link above is an example of one. 

When mutiqc plots graphs or tables it has a sepaate script that takes in information and converts it to highcharts readable plots in html. There might need to be a link in the html header similar to what is shown bellow.

```html
<head>
     <script language="javascript" type="text/javascript" src="https://code.highcharts.com/highcharts.js"></script>
     <script language="javascript" type="text/javascript" src="https://code.highcharts.com/modules/exporting.js"></script>
</head>
```

Multiqc already has some highcharts links. However, to add a specific one without changing the report template just add the correct script tag with the content in add_section. It is also important to set the search patterns in the main yaml config. See the C3G Sections docs for more details.

## Fading highlight for reference

At the momment the reference items light up when link to it is selected above. It would be nice for the color to fade after a few seconds. It is a minor addition but still a nice one.

## More comprehensive loging

As the multiqc_c3g module grows, it will be important to have better logging and debuging. Most of the multiqc_c3g modules use the multiqc namespace logger but they do not have ogger debugs, warnings or other forms of logging.

## Reporting for other piplines

To use multiqc_c3g on other piplines simply format the module_order and the c3g section ids the way you want them to show. Be sure to read the other docs in this repo for more information.
