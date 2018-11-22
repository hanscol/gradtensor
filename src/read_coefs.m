function [sc,ell,em,w,refradius,applied_shim,coord_geom] = read_coefs(filename)

fid = fopen(filename,'rt');

ln = fgetl(fid);
if ~strcmp(ln,'CS,ell,em,coef,refradius,applied_shim,coord_geom')
	error('Wrong type of coefficient file')
end

sc = [];
ell = [];
em = [];
w = [];

while 1
	
	ln = fgetl(fid);
	if ln == -1
		break
	end
	
	q = strsplit(ln,',');
	
	sc = [sc; q(1)];
	ell = [ell; str2double(q{2})];
	em = [em; str2double(q{3})];
	w = [w; str2double(q{4})];
	
end

refradius = str2double(q{5});
applied_shim = str2double(q{6});
coord_geom = q{7};

fclose(fid);





