function apply_gradtensor_to_b(varargin)

% Parse inputs (defaults specified here)
P = inputParser;
addOptional(P,'Limg_file','/INPUTS/L.nii.gz');
addOptional(P,'refimg_file','/INPUTS/L.nii.gz');
addOptional(P,'bval_file','/INPUTS/bval.txt');
addOptional(P,'bvec_file','/INPUTS/bvec.txt');
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});

% Apply the correction to bval/bvec
compute_b_images( ...
	Limg_file, ...
	refimg_file, ...
	bval_file, ...
	bvec_file, ...
	out_dir ...
	)

if isdeployed()
	exit()
end
