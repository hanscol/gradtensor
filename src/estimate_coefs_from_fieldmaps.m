function [lmatrix_file] = estimate_coefs_from_fieldmaps(...
	output_dir, ...
	fieldmap_hz_0_file, ...
	fieldmap_hz_x_file, ...
	fieldmap_hz_y_file, ...
	fieldmap_hz_z_file, ...
	sh_order, ...
	symmetry, ...
	coord_geom, ...
	refradius, ...
	image_radius ...
	)

    % ESTIMATE_COEFS_FROM_FIELDMAPS  Solid harmonic approx to gradient coil fields
    %
    % For a set of field map images taken with linear shim off, then on to
    % equal degree in each of the X, Y, Z directions, estimate coefficients of
    % the solid harmonic basis functions that yield the best approximation to
    % the gradient coil fields.
    %
    % Coefficients are first estimated to produce field maps in units of Hz.
    % Then they are converted to units of reference radius (or, uT/refradius
    % per mT/m applied gradient) via gamma, the reference radius, and the
    % applied shim value. If the applied shim amplitude is not supplied, the
    % estimated linear coefficient is used instead (this reduces accuracy).
    % Units must be:
    %    Field maps:    Hz
    %    gamma:         Hz/uT (same as MHz/T)
    %    applied shim:  uT/mm (same as mT/m)
    %    coords:        mm (as read directly from Nifti headers)
    %
    % Inputs
    %    output_dir           Where output will be stored
    %    fieldmap_hz_0_file   Shim-off field map in Hz
    %    fieldmap_hz_x_file   X-shim field map in Hz
    %    fieldmap_hz_y_file   Y-shim field map in Hz
    %    fieldmap_hz_z_file   Z-shim field map in Hz
    %    sh_order             maximum basis function order to fit
    %    symmetry             'sym' (limit to odd orders) or 'all'
    %    coord_geom           coordinate geometry e.g. 'Philips_headfirst_supine'
    %    refradius            coordinate scaling factor in mm
    %    image_radius         distance from origin to crop field map images, mm
    %
    % Outputs
    %    coefX.csv    SH coefficients for each coil
    %    coefY.csv
    %    coefZ.csv
    %    fitplot_x.png    Visual report of SH fit quality
    %    fitplot_y.png
    %    fitplot_z.png

    
    H_gamma = 42.5774806;
    
    % Create the output directory if needed
    if ~exist(output_dir,'dir')
        mkdir(output_dir)
    end

    % Load field maps and verify that geometry matches
    [field0,XYZ0] = spm_read_vols(spm_vol(fieldmap_hz_0_file));
    [fieldx,XYZx] = spm_read_vols(spm_vol(fieldmap_hz_x_file));
    [fieldy,XYZy] = spm_read_vols(spm_vol(fieldmap_hz_y_file));
    [fieldz,XYZz] = spm_read_vols(spm_vol(fieldmap_hz_z_file));
    
    if size(field0,4) > 1
        field0 = field0(:,:,:,1);
    end
    if size(fieldx,4) > 1
        fieldx = fieldx(:,:,:,1);
    end
    if size(fieldy,4) > 1
        fieldy = fieldy(:,:,:,1);
    end
    if size(fieldz,4) > 1
        fieldz = fieldz(:,:,:,1);
    end    
    
    if ~all(XYZ0(:)==XYZx(:)) || ...
            ~all(XYZx(:)==XYZy(:)) || ...
            ~all(XYZy(:)==XYZz(:))
        error('Geometry mismatch in field maps')
    end

    % Compute gradient coil maps
    gradx = fieldx - field0;
    grady = fieldy - field0;
    gradz = fieldz - field0;

    % Scale to units of reference radius
    image_radius = image_radius / refradius;
    XYZ = XYZ0 / refradius;

    % Convert from the SPM/Nifti coordinate system to scanner physical
    % coordinates.
    geomat = get_scanner_transform(coord_geom);
    XYZ = geomat' * XYZ;

    % Identify the voxels within image_radius from the origin that we will use
    % in the fit
    dsq = XYZ(1,:).^2 + XYZ(2,:).^2 + XYZ(3,:).^2;
    keeps = dsq' <= (image_radius ^ 2);


    % Fit for each coil

    for coil = {'X','Y','Z'}

        switch coil{1}
            case 'X'
                grad = gradx;
            case 'Y'
                grad = grady;
            case 'Z'
                grad = gradz;
            otherwise
                error('Unknown coil %s',coil{1})
        end

        % Compute relevant solid harmonics. These R are the basis functions
        % evaluated at the actual voxel locations in the field map images.
        [R,R_scaled,scale_factor,sc,ell,em] = get_sh_basis_on_grid( ...
            sh_order,symmetry,coil{1},XYZ(1,keeps),XYZ(2,keeps),XYZ(3,keeps));

        % Use robust fit so a few voxels without signal won't throw things off. The
        % model describes (field in uT at xyz mm) per (mT/m applied gradient).
        % Rescale coefs to the original basis function amplitudes (R) afterwards.
        w = robustfit(R_scaled,grad(keeps),[],[],'off');
        w = w./scale_factor';

        fit = zeros(size(grad));
        fit(keeps) = R * w;

        % Grab just the nonlinear part for visualization
        nlw = w;
        nlw(ell<=1) = 0;
        nlfit = zeros(size(grad));
        nlfit(keeps) = R * nlw;

        % Zero out ex-FOV voxels for visualization
        grad0 = grad;
        grad0(~keeps) = 0;

        % Display and save figure with measured and fitted field
        fieldfitplot(grad0,fit,nlfit,coil{1},fullfile(output_dir,['fitplot_' coil{1} '.png']));

        % Scale coefs to units of reference radius (or, uT/refradius per mT/m
        % applied gradient) via gamma, the reference radius, and the estimated shim
        % value. The estimated linear coefficient is used (this reduces accuracy).
        switch coil{1}
            case 'X'
                this_applied_shim = ...
                    w( strcmp(sc,'C') & ell==1 & em==1 ) ...
                    / H_gamma / refradius;
            case 'Y'
                this_applied_shim = ...
                    w( strcmp(sc,'S') & ell==1 & em==1 ) ...
                    / H_gamma / refradius;
            case 'Z'
                this_applied_shim = ...
                    w( strcmp(sc,'C') & ell==1 & em==0 ) ...
                    / H_gamma / refradius;
            otherwise
                error('Unknown coil %s',coil{1})
        end


        w_final = w / H_gamma / refradius / this_applied_shim;

        % Save coefs to file
        coefs_to_csv(sc,ell,em,w_final, ...
            refradius,this_applied_shim,coord_geom, ...
            fullfile(output_dir,['coefs_' coil{1} '.csv']));

    end

    %L is written to file, but it is also returned as a matrix
    lmatrix_file = compute_L(fullfile(output_dir, 'coefs_X.csv'), ...
                             fullfile(output_dir, 'coefs_Y.csv'), ...
                             fullfile(output_dir, 'coefs_Z.csv'), ... 
                             fieldmap_hz_x_file, ...
                             output_dir)
end
