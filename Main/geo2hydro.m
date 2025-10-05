function geo2hydro(globalCtlFile,rCO,resDSave,resESave,coreNo,nCores)
% this function converts the landsurface result from the geographic domain
% to the hydrological domain
%% update history 
% 1) update for operational stability
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%      DeepHydro (v0.0), released ?. 2021        %')
disp('%      contact: xinyi.shen@uconn.edu             %')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('configuring environment...')
curFile = mfilename('fullpath');
[curDir,~,~]=fileparts(curFile);
[progDir,~,~]=fileparts(curDir);
addpath([progDir,'/IO']);
addpath([progDir,'/MEX']);
addpath([progDir,'/river_topology']);
addpath([progDir,'/geomorphology/common']);
sysBit=mexext;
if strcmpi(sysBit,'mexw64')==1
    dllDir=[progDir,'\DLL'];
    setenv('PATH', [getenv('PATH') ';' dllDir]);
end

GDALLoad();
model_settings();
define_constant();
globalPar=GlobalParameters(globalCtlFile);

[xLoc,yLoc,proj,IDs]=readShapeLoc(globalPar.out_shp,0);
[fileDEM,fileFDR,fileFAC,fileStream]=BasinVariables.GenerateFileNames(globalPar.basicPath,globalPar.basicFormat);
[fdr,geoTrans,projFDR]=ReadRaster(fileFDR);
basinMask=fdr>0;
forcingVar=ForcingVariables(basinMask,basinMask,geoTrans,projFDR,...
            globalPar.startDateRoute,globalPar.endDateRoute,globalPar.timeStepRoute,globalPar.timeFormatRoute,globalPar.timeMarkRoute,...
            [],[],[],...
            globalPar.forcingCtl,...    
            globalPar.decompBeforeSrc,globalPar.decompBeforeDst,globalPar.OS,false,true);
%% construct river topology
%% read the stream flow to remove data scarse stations
fileNodes=[globalPar.basicPath,'nodes.mat'];
if exist(fileNodes,'file')==2
    load(fileNodes);
else
    nodes=GaugeNode(IDs,xLoc,yLoc,proj);
    nNodes=length(nodes);
    disp('import observed flow...')
    for i=nNodes:-1:1
        nodes(i).ImportFlow2(globalPar.obsPath,globalPar.timeFormatRoute,-9999,forcingVar.timeStep);
        if ~nodes(i).HasObs
            nodes(i)=[];
            disp('Too many missing records or observed file missing. Sites removed')
        else
            disp([num2str(nNodes-i),'/',num2str(nNodes)]);
        end
    end
end
nodes.GetRowCol(projFDR,geoTrans);
outlets=nodes.findOutlets(fdr);
for no=1:length(outlets)
    outlets(no).constructNetwork(fdr,nodes);
end
clear fdr
%% generate elevation difference and hydrological distance for all geographic grids
deepHydro=DeepHydro(globalPar,forcingVar,nodes,outlets,resDSave,resESave,10,1);
deepHydro.DEMapGen(fileFDR,fileDEM,fileStream,rCO);
%% reproject the grids to elevation difference and hydrological distance
deepHydro.reproject(coreNo,nCores);
disp('done!')
end