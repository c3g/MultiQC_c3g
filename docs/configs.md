# This some documentation for C3G pipline MultiQC reports

There are a few things that need to be maintained. For most of the MultiQC config options please visit the [MultiQC](https://multiqc.info/docs/) documentation. Otherwise, follow this documentation to change certain small C3G speciic changes.

## Setting the MUGQIC version number

The MUGQIC version number apears at the end of the report in the footer. It can be set with the main config yaml.

```yaml 
version_MUGQIC: 3.0
```

It is easy to create other yaml adjustable variables. Simply use `config.variableName` in the report template where you want it to apear or be used. Then set the variable using the yaml config.

Furthermore, the date of the genpipes run and the pipeline version need to be specified in the config yaml.

```yaml
report_header_info:
    - Contact E-mail: 'services@computationalgenomics.ca'
    - Application Type: 'ChIPseq Analysis'
    - Pipeline version: 'chipseq V1.0'
```

## Setting the working directiory

The working directory here is the name of the directory where multiqc is run. It is useful for some parts of the code. Setting the working directory is simple. It is important to set the working directory for the table and image renderer.

```yaml
working_dir: 'report'
```

## Excluding modules

Excluding multiqc modules can be done thorugh the config. This way modules that are not in module order but still have files that were collected by Multiqc will not be rendered if they are excluded. The general statistics table can also be skiped using the skip_generalstats config.

```yaml
exclude_modules:
    - samtools
skip_generalstats: True
```

## Changing all table color scales

Multiqc_c3g allows the user to change the color scale of all the tables or for one table or collumn in a table. To set the global color scale use the config option `table_color_scale`. The color scales are use [ColorBrewer2](https://multiqc.info/docs/#table-colour-scales-1), which is also used in multiqc.

```yaml
table_color_scale: 'BuGn'
``` 