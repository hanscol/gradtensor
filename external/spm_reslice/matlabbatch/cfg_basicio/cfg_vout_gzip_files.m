function dep = cfg_vout_gzip_files(job)

% Define virtual outputs for "GZip Files". File names can either be
% assigned to a cfg_files input or to a evaluated cfg_entry.
% Note that there is no cfg_run_gzip_files.m. The .prog callback is calling
% MATLAB gzip directly.
%
% This code is part of a batch job configuration system for MATLAB. See 
%      help matlabbatch
% for a general overview.
%_______________________________________________________________________
% Copyright (C) 2007 Freiburg Brain Imaging

% Volkmar Glauche
% $Id: cfg_vout_gzip_files.m 5685 2013-10-11 14:58:24Z volkmar $

rev = '$Rev: 5685 $'; %#ok

dep            = cfg_dep;
dep.sname      = 'GZipped Files';
dep.src_output = substruct('()',{':'});
dep.tgt_spec   = cfg_findspec({{'class','cfg_files', 'strtype','e'}});
