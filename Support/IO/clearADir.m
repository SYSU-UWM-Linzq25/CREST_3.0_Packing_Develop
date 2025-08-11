function clearADir(which_dir)
% which_dir = 'directory_to_delete_files_from';
dinfo = dir(which_dir);
dinfo([dinfo.isdir]) = [];   %skip directories
filenames = fullfile(which_dir, {dinfo.name});
if ~isempty(filenames)
    delete( filenames{:} )
end
end