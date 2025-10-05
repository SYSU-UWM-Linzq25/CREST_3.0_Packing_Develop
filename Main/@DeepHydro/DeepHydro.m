classdef DeepHydro < handle
    properties
        fileElevMap;% the file name of elevMap
        fileDistMap;% the file name of distMap
        fileOutletMap;% the file name of outletMap
        outletMap;% stores the 1d index of the closest outlet
        elevMap;% stores the elevation difference to the closest outlet 
        distMap;% stores the hydrological distance to the closest outlet 
        globalVar;
        forcingVar;
        nodes;% all stations with topology
        outlets;% the most downstream stations
        
    end
    properties(Access=private)
        excI;
        excS;
        snowmeltExcI;
        snowmeltExcS;
        SWE;
        resDSave;% distance resoluiton 
        resESave;% elevation resolution
        resD;%temporary distance resolution (1 of elevation resolution) 
        resE;%temporary elevation resolution (1/10 of elevation resolution)
        copiedLSFile;% The old local input file
    end
    methods
        %% constructor
        % resDSave, resESave: 
        % resD,resE: 
        function this=DeepHydro(globalVar,forcingVar,nodes,outlets,resDSave,resESave,resD,resE)
            this.globalVar=globalVar;
            this.forcingVar=forcingVar;
            this.fileElevMap=[globalVar.basicPath,'elevDiff.tif'];
            this.fileDistMap=[globalVar.basicPath,'distHydro.tif'];
            this.fileOutletMap=[globalVar.basicPath,'outlet_index.tif'];
            this.nodes=nodes;
            this.outlets=outlets;
            this.resDSave=resDSave;
            this.resESave=resESave;
            this.resD=resD;
            this.resE=resE;
        end
        %% This function generates the elevation difference and hydrological distance (DE) map
        % input
        % DEM,FDR
        % IDOutlet: the most downstream outlets
        % nodes: all stations with (row,col) and topology
        % outlets: all terminating nodes
        % ratioCO: the speed ratio of channel to overland
        DEMapGen(this,fdrFile,demFile,streamFile,ratioCO);
        %% This function reproject the land surface result from geographic grids to DE grids
        reproject(this,core,nCores);
        %% load direct runoff from geographic grids
        LoadDirectRunoff(this);
        %% the efficient algorithm that converts the LS result to  of all stations at one time step
        fileFlushed=landsurf2DE(this);
        %% covert grids to hydrological distance  
        % This function only converts temporal grids
        dist=col2dist(this,col);
        %% covert row to elevation difference
        % This function only converts temporal grids
        elev=row2elev(this,row,rowMin);
        %% discretize hydrological distance value to grids
        % hydroDist: 
        % offset (in length): usually the min value of the elevation difference (can be
        % negative), otherwise:0
        % the grid is 1-based
        row=elev2row(this,elevDiff,toSave,rowEMin);
        %% discretize hydrological distance value to grids
        % hydroDist: 
        % offset (in length): usually the min value of the elevation difference (can be
        % negative), otherwise:0
        % the grid is 1-based
        col=dist2col(this,hydroDist,toSave);
        %% convert from difference (elevation/hydrological distance) to grid
        % The difference is meausred from the subbasin outlet to the parent basin
        % outlet. It only deals with temporary grids
        n=diff2Out2grid(this,diffVal,isDist);
        %% flush the regridded variable from memory to local disk
        % fileName: flushed file name without directory
        fileName=FlushToRes(this,dirLocDE,varNames,varMats);
    end
    methods(Access=private)
        %% This function offset a child node to the parent relative CS then add the LS contribution
        % output:
        % LSDE: a sparse matrix (rowE,colD,LSDEValue) that records the offset grids
        % of a LS variable
        % input
        % parent: the parent node
        % child: the child node
        % varName: one of the LS variable Name
        % dist2O, elev2O: the elevation difference and hydrological distance from
        % the child node to the parent node
        LSDE=offsetAChild(this,parent,child,varName,dist2O,elev2O);
        %% This function converts from fine temporal LS grids to coarse grids to save
        % out
        % LSMat: a full matrix stores the LS image of the parent node in DE CS
        % input
        % parent: the node to save
        % varSparse: the LS variable in find grids
        LSMat=fine2coarse(this,parent,varSparse);
    end
    methods(Static)
        dirLocMosaic=makeDELocDir(resPathInitLoc,pathSplitor,nCores);
    end
end