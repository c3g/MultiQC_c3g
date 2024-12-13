#!/bin/bash

version=1.23 # version of MultiQC to use
commit=8ade80c # commit in MultiQC_c3g repo

mkdir -p $MUGQIC_INSTALL_HOME_DEV/software/MultiQC_C3G/MultiQC_C3G-${version}_${commit}

git clone git@github.com:c3g/MultiQC_c3g.git -b ${commit} $MUGQIC_INSTALL_HOME_DEV/software/MultiQC_C3G/MultiQC_C3G-${commit}

module purge
module load python/3.12.2
pip install --prefix=$MUGQIC_INSTALL_HOME_DEV/software/MultiQC/MultiQC_C3G-${version}_${commit} -U multiqc==${version} git+file:$MUGQIC_INSTALL_HOME_DEV/software/MultiQC_C3G/MultiQC_C3G-${commit}