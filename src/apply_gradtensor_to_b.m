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
	P.Results.Limg_file, ...
	P.Results.refimg_file, ...
	P.Results.bval_file, ...
	P.Results.bvec_file, ...
	P.Results.out_dir ...
	);

if isdeployed()
	exit()
end
