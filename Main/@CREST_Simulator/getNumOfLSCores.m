function nCoresLS=getNumOfLSCores(this)
%% get the number of cores used in the land surface process simulation
coreDirs=dir([this.globalVar.resPathInit,'*_*']);
if isempty(coreDirs)
    nCoresLS=1;
else
    strs=strsplit(coreDirs(1).name,'_');
    nCoresLS=str2double(strs{2});
end
end