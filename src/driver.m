%addpath('./sh_basis')
%addpath('./spm_read_nii')

output_dir = '/OUTPUTS/';
fieldmap_hz_0_file = '/INPUTS/B0_NS_Hz.nii';
fieldmap_hz_x_file = '/INPUTS/B0_X0_Hz.nii';
fieldmap_hz_y_file = '/INPUTS/B0_Y0_Hz.nii';
fieldmap_hz_z_file = '/INPUTS/B0_Z0_Hz.nii';
L_file = '/INPUTS/L.nii';


if ~isfile(L_file)
	params = struct;
	params.sh_order = 3;
	params.symmetry = 'sym';
	params.coord_geom = 'Philips_headfirst_supine';
	params.refradius = 250;
	params.image_radius = 135;
	
	text = fileread('/INPUTS/parameters.txt');
	text = strsplit(text, '\n');
	
	for i = 1:length(text)
	    line = text{i};
	    if ~isempty(line)
	        line = line(find(~isspace(line)));
	        parts = strsplit(line, '=');
	        param = parts{1};
	        value = parts{2};
	        
	        if strcmp(param,'symmetry') || strcmp(param,'coord_geom')
	            params.(param) = value;
	        else
	            params.(param) = str2num(value);
	        end
	        
	    end
	end
   
	L_file = estimate_coefs_from_fieldmaps(...
        output_dir, ...
        fieldmap_hz_0_file, ...
        fieldmap_hz_x_file, ...
        fieldmap_hz_y_file, ...
        fieldmap_hz_z_file, ...
        params.sh_order, ...
        params.symmetry, ...
        params.coord_geom, ...
        params.refradius, ...
        params.image_radius ...
        );
end

bval_file = '/INPUTS/bval.txt';
bvec_file = '/INPUTS/bvec.txt';


[ladjbvec_files,adjbval_files] = compute_b_images( ...
    L_file, ...
	bval_file, ...
	bvec_file, ...
    output_dir ...
	);
