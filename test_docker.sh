docker run \
--mount type=bind,src=`pwd`/INPUTS,dst=/INPUTS \
--mount type=bind,src=`pwd`/OUTPUTS,dst=/OUTPUTS \
gradtensor \
/opt/gradtensor/bin/run_fieldmaps_to_gradtensor.sh \
/usr/local/MATLAB/MATLAB_Runtime/v92 \
fieldmap_hz_0_file /INPUTS/B0_0_Hz.nii.gz \
fieldmap_hz_X_file /INPUTS/B0_X_Hz.nii.gz \
fieldmap_hz_Y_file /INPUTS/B0_Y_Hz.nii.gz \
fieldmap_hz_Z_file /INPUTS/B0_Z_Hz.nii.gz \
sh_order 3 \
symmetry sym \
coord_geom Philips_headfirst_supine \
image_radius 135 \
out_dir /OUTPUTS


docker run \
--mount type=bind,src=`pwd`/INPUTS,dst=/INPUTS \
--mount type=bind,src=`pwd`/OUTPUTS,dst=/OUTPUTS \
gradtensor \
/opt/gradtensor/bin/run_apply_gradtensor_to_b.sh \
/usr/local/MATLAB/MATLAB_Runtime/v92 \
Limg_file /OUTPUTS/L.nii.gz \
refimg_file /INPUTS/dti.nii.gz \
bval_file /INPUTS/bval.txt \
bvec_file /INPUTS/bvec.txt \
out_dir /OUTPUTS