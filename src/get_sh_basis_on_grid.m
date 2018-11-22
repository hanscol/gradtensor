function [R,R_scaled,scale_factor,sc,ell,em] = get_sh_basis_on_grid( ...
	sh_order, ...
	symmetry, ...
	axis, ...
	x, ...
	y, ...
	z ...
	)
% GET_SH_BASIS_ON_GRID   Sample the SH basis functions on a specific grid
%
% Inputs:
%   sh_order    Max order of SH basis to use
%   symmetry    'sym' to use odd orders, or 'all'
%   axis        Which gradient coil we are modeling, 'X' 'Y' or 'Z'
%   x           Voxel grid X coordinate list
%   y           Voxel Y
%   z           Voxel Z
%
% Outputs:
%   R               The basis function evaluated at all X,Y,Z
%   R_scaled        Same, but scaled to std dev 1
%   scale_factor    The scaling factors used
%   sc              'S' or 'C' for sine or cosine
%   ell             Order of each function
%   em              Phase

% Initialize
c = 0;
sc = [];
ell = [];
em = [];
R = nan(length(x),0);

% C 00 is the constant term / intercept
c = c + 1;
sc{c} = 'C';
ell(c) = 0;
em(c) = 0;
R(:,c) = evaluate_sharm(sc{c},ell(c),em(c),x,y,z,'');

% Then, the rest, depending what our symmetry option is
switch symmetry
	
	
	case 'all'
		for l = 1:sh_order
			for m = 0:l
				
				c = c + 1;
				sc{c} = 'C';
				ell(c) = l;
				em(c) = m;
				R(:,c) = evaluate_sharm(sc{c},ell(c),em(c),x,y,z,'');
				
				if m>0
					c = c + 1;
					sc{c} = 'S';
					ell(c) = l;
					em(c) = m;
					R(:,c) = evaluate_sharm(sc{c},ell(c),em(c),x,y,z,'');
				end
				
			end
		end
		
		
	case 'sym'
		% For 'sym' option, due to physical symmetry of the gradient coils,
		% For X we use C only: 11, 31, 33, 51, 53, 55, ...
		% For Y we use S only: 11, 31, 33, 51, 53, 55, ...
		% For Z we use C only: 10, 30, 50, ...
		
		switch axis
			case 'Y'
				thesc = 'S';
			otherwise
				thesc = 'C';
		end
		
		for l = 1:2:sh_order
			
			if ismember(axis,{'X','Y'})
				mrange = 1:2:l;
			else
				mrange = 0;
			end
			
			for m = mrange
				
				c = c + 1;
				sc{c} = thesc;
				ell(c) = l;
				em(c) = m;
				R(:,c) = evaluate_sharm(sc{c},ell(c),em(c),x,y,z,'');
				
			end
			
		end
		
		
	case 'symP7'
		% Manufacturer-specific set: sym up to order 5, then add the m=0,1
		% harmonics at order 7
		
		if sh_order~=7
			error('Symmetry symP7 requires order 7')
		end
		
		switch axis
			case 'Y'
				thesc = 'S';
			otherwise
				thesc = 'C';
		end
		
		for l = 1:2:7
			
			if ismember(axis,{'X','Y'})
				if l<7
					mrange = 1:2:l;
				else
					mrange = 1;
				end
			else
				mrange = 0;
			end
			
			for m = mrange
				
				c = c + 1;
				sc{c} = thesc;
				ell(c) = l;
				em(c) = m;
				R(:,c) = evaluate_sharm(sc{c},ell(c),em(c),x,y,z,'');
				
			end
			
		end
		
		
	otherwise
		error('Unknown symmetry option %s',sym)
		
		
end


% Scale to std dev 1 to improve numerics. Constant terms (std dev 0) are
% set to 1.
R_scaled = ones(size(R));
scale_factor = ones(1,size(R,2));
for c = 1:size(R,2)
	if std(R(:,c)) > 0
		scale_factor(c) = std(R(:,c));
		R_scaled(:,c) = R(:,c) / scale_factor(c);
	else
		scale_factor(c) = 1;
		R_scaled(:,c) = ones(size(R,1),1);
	end
end

