function [Limg_file] = compute_L( ... 
    coefs_X_file, ...
	coefs_Y_file, ...
	coefs_Z_file, ...
	refimg_file, ...
    output_dir ...
    )

    % Load reference image geometry (take first volume)
    Vref = spm_vol(refimg_file);
    Vref = Vref(1);
    [~,XYZ] = spm_read_vols(Vref);

    % Load the coefficients of the solid harmonic gradient field approximation
    [scx,ellx,emx,wx,refradiusx,~,coord_geomx] = read_coefs(coefs_X_file);
    [scy,elly,emy,wy,refradiusy,~,coord_geomy] = read_coefs(coefs_Y_file);
    [scz,ellz,emz,wz,refradiusz,~,coord_geomz] = read_coefs(coefs_Z_file);
    if ~(refradiusx==refradiusy && refradiusy==refradiusz) || ...
            ~(strcmp(coord_geomx,coord_geomy) && strcmp(coord_geomy,coord_geomz))
        error('Mismatch in coefs files')
    end
    refradius = refradiusx;
    coord_geom = coord_geomx;

    % Convert from the SPM/Nifti coordinate system to scanner physical
    % coordinates. This is specific to scanner and orientation.
    geomat = get_scanner_transform(coord_geom);

    % Convert coords to scanner space
    XYZ = geomat' * XYZ;

    % Now normalize coords by the ref radius
    nv = size(XYZ,2);
    x = XYZ(1,:)'/refradius;
    y = XYZ(2,:)'/refradius;
    z = XYZ(3,:)'/refradius;

    % First column of L is the derivatives of the X coil field w.r.t. x,y,z.
    % Etc. This is computed in the scanner space.
    L_s = zeros(nv,3,3);

    for k = 1:length(ellx)
        fx = sprintf('ddx_sharm_%s_%d_%d',scx{k},ellx(k),emx(k));
        fy = sprintf('ddy_sharm_%s_%d_%d',scx{k},ellx(k),emx(k));
        fz = sprintf('ddz_sharm_%s_%d_%d',scx{k},ellx(k),emx(k));
        L_s(:,1,1) = L_s(:,1,1) + wx(k) * feval(fx,x,y,z);
        L_s(:,2,1) = L_s(:,2,1) + wx(k) * feval(fy,x,y,z);
        L_s(:,3,1) = L_s(:,3,1) + wx(k) * feval(fz,x,y,z);
    end

    for k = 1:length(elly)
        fx = sprintf('ddx_sharm_%s_%d_%d',scy{k},elly(k),emy(k));
        fy = sprintf('ddy_sharm_%s_%d_%d',scy{k},elly(k),emy(k));
        fz = sprintf('ddz_sharm_%s_%d_%d',scy{k},elly(k),emy(k));
        L_s(:,1,2) = L_s(:,1,2) + wy(k) * feval(fx,x,y,z);
        L_s(:,2,2) = L_s(:,2,2) + wy(k) * feval(fy,x,y,z);
        L_s(:,3,2) = L_s(:,3,2) + wy(k) * feval(fz,x,y,z);
    end

    for k = 1:length(ellz)
        fx = sprintf('ddx_sharm_%s_%d_%d',scz{k},ellz(k),emz(k));
        fy = sprintf('ddy_sharm_%s_%d_%d',scz{k},ellz(k),emz(k));
        fz = sprintf('ddz_sharm_%s_%d_%d',scz{k},ellz(k),emz(k));
        L_s(:,1,3) = L_s(:,1,3) + wz(k) * feval(fx,x,y,z);
        L_s(:,2,3) = L_s(:,2,3) + wz(k) * feval(fy,x,y,z);
        L_s(:,3,3) = L_s(:,3,3) + wz(k) * feval(fz,x,y,z);
    end

    % Permute dims to make more friendly. Voxel is dim 3 now.
    L_s = permute(L_s,[2 3 1]);

    % Transform L from the scanner space to the image space
    L = nan(size(L_s));
    for v = 1:size(L,3)
        L(:,:,v) = geomat * L_s(:,:,v) * geomat';
    end

    % Save L to file, reshaping to a 9 vector
    %       Lxx,Lxy,Lxz,Lyx,Lyy,Lyz,Lzx,Lzy,Lzz
    Lxx = reshape(L(1,1,:),Vref.dim);
    Lxy = reshape(L(1,2,:),Vref.dim);
    Lxz = reshape(L(1,3,:),Vref.dim);
    Lyx = reshape(L(2,1,:),Vref.dim);
    Lyy = reshape(L(2,2,:),Vref.dim);
    Lyz = reshape(L(2,3,:),Vref.dim);
    Lzx = reshape(L(3,1,:),Vref.dim);
    Lzy = reshape(L(3,2,:),Vref.dim);
    Lzz = reshape(L(3,3,:),Vref.dim);

    Vout = rmfield(Vref,{'pinfo','private'});
    Vout.dt(1) = spm_type('float32');
    Vout.descrip = 'L matrix';
    %[p,n] = fileparts(Vout.fname);
    Limg_file = fullfile(output_dir,'L.nii');
    Vout.fname = Limg_file;
    Vout.n(1) = 1;
    spm_write_vol(Vout,Lxx);
    Vout.n(1) = 2;
    spm_write_vol(Vout,Lxy);
    Vout.n(1) = 3;
    spm_write_vol(Vout,Lxz);
    Vout.n(1) = 4;
    spm_write_vol(Vout,Lyx);
    Vout.n(1) = 5;
    spm_write_vol(Vout,Lyy);
    Vout.n(1) = 6;
    spm_write_vol(Vout,Lyz);
    Vout.n(1) = 7;
    spm_write_vol(Vout,Lzx);
    Vout.n(1) = 8;
    spm_write_vol(Vout,Lzy);
    Vout.n(1) = 9;
    spm_write_vol(Vout,Lzz);
	
	system(['gzip ' Limg_file]);
	
end

