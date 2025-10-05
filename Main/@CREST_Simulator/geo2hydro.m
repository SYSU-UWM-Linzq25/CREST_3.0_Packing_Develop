function geo2hydro(globalCtlFile,coreNo,nCores)
% this function converts the landsurface result from the geographic domain
% to the hydrological domain

%% update history 
% 1) update for operational stability
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%      DeepHydro, released Jan. 2021             %')
disp('%      contact: xinyi.shen@uconn.edu             %')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('configuring environment...')
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);
addpath([progDir,'/MEX']);
if strcmpi(sysBit,'mexw64')==1
    dllDir=[progDir,'\DLL'];
    setenv('PATH', [getenv('PATH') ';' dllDir]);
end
GDALLoad();
model_settings();
globalPar=GlobalParameters(globalCtlFile);
fileSites=[globalPar.obsPath,globalPar.out_shp];
[xLoc,yLoc,proj,IDs]=readShapeLoc(fileSites,0);
nodes=GaugeNode(IDs,xLoc,yLoc,proj);
end