#!/bin/sh
#
# Compile the matlab code so we can run it without a matlab license. Required:
#     Matlab 2017a, including compiler, with license

# Need to -I include some local subdirectories:
#    src/sh_basis, external/spm_read_nii
mcc -m -v src/fieldmaps_to_gradtensor.m \
    -I src/sh_basis \
    -I external/spm_read_nii \
    -d bin

# Grant lenient execute permissions to the matlab executable and runscript
chmod go+rx bin/fieldmaps_to_gradtensor
chmod go+rx bin/run_fieldmaps_to_gradtensor.sh


# Same process for the other tool
mcc -m -v src/apply_gradtensor_to_b.m \
    -I external/spm_read_nii \
    -d bin
chmod go+rx bin/apply_gradtensor_to_b
chmod go+rx bin/run_apply_gradtensor_to_b.sh
