#!/bin/sh
#
# Compile the matlab code so we can run it without a matlab license. Required:
#     Matlab 2017a, including compiler, with license
#
# Need to -a include some local subdirectories, e.g. src/sh_basis
# Grant lenient execute permissions to the matlab executable and runscript

# Module to compute gradient coil tensor image
mcc -m -v src/fieldmaps_to_gradtensor.m \
    -a src/sh_basis \
    -a external/spm_read_nii \
    -d bin
chmod go+rx bin/fieldmaps_to_gradtensor
chmod go+rx bin/run_fieldmaps_to_gradtensor.sh

# Module to adjust b-values/vectors with the gradtensors
mcc -m -v src/apply_gradtensor_to_b.m \
    -a external/spm_read_nii \
    -a external/spm_reslice \
    -d bin
chmod go+rx bin/apply_gradtensor_to_b
chmod go+rx bin/run_apply_gradtensor_to_b.sh
