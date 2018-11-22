function generate_sh_basis(output_dir,ndigits,max_order)
% GENERATE_SH_BASIS   Symbolic representations of solid harmonics
%
% Generates optimized matlab functions for each regular solid harmonic and
% its partial derivatives in Cartesian coordinates using the symbolic
% toolbox. <a
% href="https://en.wikipedia.org/w/index.php?title=Solid_harmonics&oldid=701904662#Real_form">Specifics</a>
%
%    output_dir    Where the functions will be saved
%    ndigits       Number of digits to use for numerical coefficients
%    max_order     All basis functions up to this order
%
% Needs to be run only once. Once the functions are generated there is no
% need to re-run unless it's desired to change the precision or maximum
% order (or the generation code itself has been updated).

syms x y z PI PIbar A B C S real

if ~exist(output_dir,'dir')
	mkdir(output_dir)
end

if isempty(ndigits)
	ndigits = 10;
end

if isempty(max_order)
	max_order = 15;
end

fout = fopen(fullfile(output_dir,'sharm_creation_log.txt'),'wt');
fprintf(fout,'%s\n',char(datetime));

for l = 0:max_order
	for m = 0:l
		
		PI = 0;
		for k = 0:floor((l-m)/2)
			gamma = (-1)^k * 2^(-l) * nchoosek(l,k) * nchoosek(2*l-2*k,l) ...
				* factorial(l-2*k) / factorial(l-2*k-m);
			PI = PI + gamma * (x^2+y^2+z^2)^k * z^(l-2*k-m);
		end
		
		A = 0;
		B = 0;
		for p = 0:m
			term = nchoosek(m,p) * x^p * y^(m-p);
			A = A + term * round(cos((m-p)*pi/2));
			B = B + term * round(sin((m-p)*pi/2));
		end
		
		C = sqrt((2-double(m==0)) * factorial(l-m) / factorial(l+m)) * PI * A;
		
		fprintf(fout,'\n\nl=%d, m=%d, C\n\n',l,m);
		fprintf(fout,'   %s\n\n',char(vpa(expand(C),ndigits)));
		fprintf(fout,'   d/dx: %s\n',char(vpa(expand(diff(C,x)),ndigits)));
		fprintf(fout,'   d/dy: %s\n',char(vpa(expand(diff(C,y)),ndigits)));
		fprintf(fout,'   d/dz: %s\n',char(vpa(expand(diff(C,z)),ndigits)));
		
		matlabFunction( ...
			vpa(expand(C),ndigits), ...
			'vars',{'x','y','z'}, ...
			'file',sprintf(fullfile(output_dir,'sharm_C_%d_%d.m'),l,m) ...
			);
		
		matlabFunction( ...
			vpa(expand(diff(C,x)),ndigits), ...
			'vars',{'x','y','z'}, ...
			'file',sprintf(fullfile(output_dir,'ddx_sharm_C_%d_%d.m'),l,m) ...
			);
		matlabFunction( ...
			vpa(expand(diff(C,y)),ndigits), ...
			'vars',{'x','y','z'}, ...
			'file',sprintf(fullfile(output_dir,'ddy_sharm_C_%d_%d.m'),l,m) ...
			);
		matlabFunction( ...
			vpa(expand(diff(C,z)),ndigits), ...
			'vars',{'x','y','z'}, ...
			'file',sprintf(fullfile(output_dir,'ddz_sharm_C_%d_%d.m'),l,m) ...
			);
		
		if m>0
			
			S = sqrt(2 * factorial(l-m) / factorial(l+m)) * PI * B;
			
			fprintf(fout,'\n\nl=%d, m=%d, S\n\n',l,m);
			fprintf(fout,'   %s\n\n',char(vpa(expand(S),ndigits)));
			fprintf(fout,'   d/dx: %s\n',char(vpa(expand(diff(S,x)),ndigits)));
			fprintf(fout,'   d/dy: %s\n',char(vpa(expand(diff(S,y)),ndigits)));
			fprintf(fout,'   d/dz: %s\n',char(vpa(expand(diff(S,z)),ndigits)));
		
			matlabFunction( ...
				vpa(expand(S),ndigits), ...
				'vars',{'x','y','z'}, ...
				'file',sprintf(fullfile(output_dir,'sharm_S_%d_%d.m'),l,m) ...
				);
			matlabFunction( ...
				vpa(expand(diff(S,x)),ndigits), ...
				'vars',{'x','y','z'}, ...
				'file',sprintf(fullfile(output_dir,'ddx_sharm_S_%d_%d.m'),l,m) ...
				);
			matlabFunction( ...
				vpa(expand(diff(S,y)),ndigits), ...
				'vars',{'x','y','z'}, ...
				'file',sprintf(fullfile(output_dir,'ddy_sharm_S_%d_%d.m'),l,m) ...
				);
			matlabFunction( ...
				vpa(expand(diff(S,z)),ndigits), ...
				'vars',{'x','y','z'}, ...
				'file',sprintf(fullfile(output_dir,'ddz_sharm_S_%d_%d.m'),l,m) ...
				);
			
		end
		
	end
end

fclose(fout);

