#!/bin/bash

mkdir -p $MUGQIC_INSTALL_HOME_DEV/software/MultiQC/MultiQC_C3G-1.0-beta
module load python/3.8.10
pip install --prefix=$MUGQIC_INSTALL_HOME_DEV/software/MultiQC/MultiQC_C3G-1.0-beta -U multiqc git+file:///home/newtonma/apps/multiqc_c3g
#pip install --prefix=$MUGQIC_INSTALL_HOME_DEV/software/MultiQC/MultiQC_C3G-1.0-beta multiqc file:///home/newtonma/apps/multiqc_c3g
#pip install --prefix=$MUGQIC_INSTALL_HOME_DEV/software/MultiQC/MultiQC_C3G-1.0-beta multiqc git+https://newtonma@bitbucket.org/mugqic/multiqc_c3g.git@newton_c3g

