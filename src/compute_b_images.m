function [adjbvec_files, adjbval_files] = compute_b_images( ...
    L_file, ...
	bval_file, ...
	bvec_file, ...
    output_dir ...
	)
% COMPUTE_B_IMAGES  Adjust B values for gradient coil nonlinearity
%
% Inputs
%    L_file           L matrix file
%    bval_file        B value text file
%    bvec_file        B vector text file
%
% Outputs
%    <refimg>_bval_*.nii    B value image for each diffusion direction
%    <refimg>_bvec_*.nii    B vector image for each diffusion direction

% Load reference image geometry and L_matrix
Vref = spm_vol(L_file);
L_vecs = spm_read_vols(Vref);
Vref = Vref(1);

L = zeros(3,3, size(L_vecs,1).*size(L_vecs,2).*size(L_vecs,3));
Lxx = L_vecs(:,:,:,1); L(1,1,:) = Lxx(:);
Lxy = L_vecs(:,:,:,2); L(1,1,:) = Lxy(:);
Lxz = L_vecs(:,:,:,3); L(1,1,:) = Lxz(:);
Lyx = L_vecs(:,:,:,4); L(1,1,:) = Lyx(:);
Lyy = L_vecs(:,:,:,5); L(1,1,:) = Lyy(:);
Lyz = L_vecs(:,:,:,6); L(1,1,:) = Lyz(:);
Lzx = L_vecs(:,:,:,7); L(1,1,:) = Lzx(:);
Lzy = L_vecs(:,:,:,8); L(1,1,:) = Lzy(:);
Lzz = L_vecs(:,:,:,9); L(1,1,:) = Lzz(:);


nv = size(L,3);

% Load B values and vectors
bval = load(bval_file);
bvec = load(bvec_file);
nb = length(bval);

% Flip sign of X coordinate of bvec. I.e. FSL convention for bvecs: bvecs
% are always LAS while NII header world coords are always RAS.
%    https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/FAQ#What_conventions_do_the_bvecs_use.3F
%    http://www.mrtrix.org/2016/04/15/bug-in-fsl-bvecs-handling/
disp('Flipping bvec X (LAS to RAS)')
bvec(1,:) = -bvec(1,:);
flipbvecs = true;


% Adjust bvalues and bvectors
adjbvec = nan(nv,3,nb);
adjbval = nan(nv,1,nb);


for v = 1:nv

	% Most simply, the adjusted bvec is simply L * bvec. Here we are
	% operating in the image space.
	ab = L(:,:,v) * bvec;

	% The bvecs were length 1 before adjustment, so now compute the length
	% change and adjust bvals accordingly. NOTE: adjust bval by the square
	% of the length, because the b value has a G^2 term but the vector
	% length is for G.
	len2 = sum(ab.^2);
	adjbval(v,:) = bval .* len2;
	
	% Re-normalize bvecs to length 1 to compensate for the b value
	% adjustment we just made. Skip cases where b=0.
	len = sqrt(sum(ab.^2));
	lenkeeps = len~=0;
	ab(:,lenkeeps) = ab(:,lenkeeps) ./ repmat(len(lenkeeps),3,1);	
	adjbvec(v,:,:) = ab;
	
end

% Flip the bvec X back if we need to
if flipbvecs
	adjbvec(:,1,:) = -adjbvec(:,1,:);
end

% Save bvec image to file
adjbvec_files = [];
for b = 1:nb
	
	Vout = rmfield(Vref,{'pinfo','private'});
	Vout.dt(1) = spm_type('float32');
	Vout.descrip = 'Adjusted bvec';
	%[p,n] = fileparts(Vout.fname);
	adjbvec_files{b,1} = fullfile(output_dir,sprintf('bvec_%04d.nii',b));
	Vout.fname = adjbvec_files{b,1};
	
	for n = 1:3
		Vout.n(1) = n;
		spm_write_vol(Vout,reshape(adjbvec(:,n,b),Vref.dim));
	end

end
	
% Save bval image to file
adjbval_files = [];
for b = 1:nb
	
	Vout = rmfield(Vref,{'pinfo','private'});
	Vout.dt(1) = spm_type('float32');
	Vout.descrip = 'Adjusted bval';
	%[p,n] = fileparts(Vout.fname);
	adjbval_files{b,1} = fullfile(output_dir,sprintf('bval_%04d.nii',b));
	Vout.fname = adjbval_files{b,1};
	spm_write_vol(Vout,reshape(adjbval(:,b),Vref.dim));
end

exit()
