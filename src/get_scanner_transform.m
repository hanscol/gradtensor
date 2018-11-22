function geomat = get_scanner_transform(coord_geom)
% GET_SCANNER_TRANSFORM   Between SPM/Nifti and scanner systems
%
% Get the matrix that transforms coordinates to/from the SPM/Nifti
% coordinate system to scanner physical coordinates. This is specific to
% scanner and image orientation.
%
%    coord_geom   Specific transform to use

% Scanner coords are called XYZ
% Image coords are RAS
%
% The X,Y,Z can be verified and the geometry matrix determined by noting
% the direction of the applied field gradients in the SPM "Check Reg"
% viewer, where images are shown as
%
%     S         S
%   L + R     A + P 
%     I         I
%
%     A
%   L + R
%     P
%
% E.g. for Philips_headfirst_supine we have the matrix
%
%           X     Y     Z
%     R     0    -1     0
%     A     1     0     0
%     S     0     0    -1
%
% because the X field increases from posterior to anterior; the Y field
% increases from right to left; and the Z field increases from superior to
% inferior. To convert coordinates from SPM (nifti header) RAS to scanner
% XYZ, we premultiply by the transpose of this matrix. (Or postmultiply by
% this matrix, or pre-divide; all the same operation). To convert from
% scanner XYZ to image RAS, we predivide by the transpose, e.g. RAS =
% geomat'\XYZ.

switch coord_geom
	
	case 'Philips_headfirst_supine'  % V
		geomat = [ ...
			0  -1  0 ; ...
			1  0  0 ; ...
			0  0 -1 ; ...
			];
		
	case 'GE_geom1'  % M
		geomat = [ ...
			1  0  0 ; ...
			0  1  0 ; ...
			0  0  1 ; ...
			];
		
	case 'GE_geom2'  % S
		geomat = [ ...
			-1  0  0 ; ...
			0  -1  0 ; ...
			0  0  -1 ; ...
			];
	
	case {'Siemens_geom1','Siemens_HFS'}
		geomat = [ ...
			-1  0  0 ; ...
			0  1  0 ; ...
			0  0  -1 ; ...
			];
		
	case 'Siemens_geom2'  % HFS with +X, -Y, +Z shim
		geomat = [ ...
			-1  0  0 ; ...
			0  -1  0 ; ...
			0  0  -1 ; ...
			];

	otherwise
		error('Unknown scanner geometry %s',coord_geom)
		
end

