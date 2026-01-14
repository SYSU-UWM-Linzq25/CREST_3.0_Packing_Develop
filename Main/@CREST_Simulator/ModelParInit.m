function ModelParInit(this,node,nNodes,x0,keywords)
%% updating hisory
% Mar 3 subbasin mask applied to reduce calibration time
% reinitialize model parameters
if nargin==5%calibration
    this.modelPar.ModelParReInitialize(x0,keywords);
else% simulation
    this.modelPar.ModelParReInitialize();
end
if strcmpi(this.globalVar.taskType,'Routing')
    if nargin==5%calibration
        this.basicVar.RunoffAndRoutePre(this.globalVar.timeStepInMRoute,...
        this.modelPar.coeM,this.modelPar.expM,this.modelPar.coeR,this.modelPar.coeS,...
        this.basicVar.rowOutlet,this.basicVar.colOutlet,this.globalVar.hasRiverInterflow);
    else% simulation
        % pretreat all pixels in the river network
        if this.globalVar.output_runoff
            [riverRow,riverCol]=this.basicVar.GetStreamRowAndCol();
            this.basicVar.RunoffAndRoutePre(this.globalVar.timeStepInMRoute,...
                this.modelPar.coeM,this.modelPar.expM,this.modelPar.coeR,this.modelPar.coeS,...
                riverRow,riverCol,this.globalVar.hasRiverInterflow);
        else
            this.basicVar.RunoffAndRoutePre(this.globalVar.timeStepInMRoute,...
                this.modelPar.coeM,this.modelPar.expM,this.modelPar.coeR,this.modelPar.coeS,...
               this.stateVar.hydroSites.row,this.stateVar.hydroSites.col,this.globalVar.hasRiverInterflow);
        end
    end
end
%% initialize medium
if ~strcmpi(this.globalVar.taskType,'Routing')
    this.soilSurf=SoilSurf(this.modelPar,this.globalVar.paramPath,this.dt,node,nNodes);
    this.nCells=this.soilSurf.nCells;
    this.snowpack=SnowPack(this.nCells,this.soilSurf.isOverstory,this.modelPar);
    if sum(this.soilSurf.isOverstory)>0
        this.canopy=Canopy(this.soilSurf.index(this.soilSurf.isOverstory),this.modelPar);
    else
        this.canopy=Canopy([],this.modelPar);
    end
end
this.rain=zeros(this.nCells,1);
this.snow=zeros(this.nCells,1);
this.EAct=zeros(this.nCells,1);

if this.globalVar.hasOutlet% if the outlet is specified, the routing will only be computed within the basin pouring to the outlet
    this.maskRoute=this.basicVar.masks(:,:,this.stateVar.hydroSites.indexOutlets);
else
    this.maskRoute=this.stateVar.basinMask;
end
this.gridArea=this.basicVar.gridArea(this.maskRoute);
if strcmpi(this.globalVar.taskType,'Routing')
    this.KS=this.modelPar.KS(this.maskRoute);
    this.KI=this.modelPar.KI(this.maskRoute);
    % compute routing variables
    [this.SIndexA,this.uSIndexA,this.SIndexAValid]=this.ComputeRoutingIndices(...
        this.basicVar.SRowA(this.maskRoute),...
        this.basicVar.SColA(this.maskRoute));
    this.SFracA=this.basicVar.SFracA(this.maskRoute);
    this.SFracA=this.SFracA(this.SIndexAValid);
    this.SgridAreaA=this.gridArea(this.SIndexAValid);

    [this.SIndexB,this.uSIndexB,this.SIndexBValid]=this.ComputeRoutingIndices(...
        this.basicVar.SRowB(this.maskRoute),...
        this.basicVar.SColB(this.maskRoute));
    this.SFracB=this.basicVar.SFracB(this.maskRoute);
    this.SFracB=this.SFracB(this.SIndexBValid);
    this.SgridAreaB=this.gridArea(this.SIndexBValid);

    [this.IIndexA,this.uIIndexA,this.IIndexAValid]=this.ComputeRoutingIndices(...
        this.basicVar.IRowA(this.maskRoute),...
        this.basicVar.IColA(this.maskRoute));
    this.IFracA=this.basicVar.IFracA(this.maskRoute);
    this.IFracA=this.IFracA(this.IIndexAValid);
    this.IgridAreaA=this.gridArea(this.IIndexAValid);

    [this.IIndexB,this.uIIndexB,this.IIndexBValid]=this.ComputeRoutingIndices(...
        this.basicVar.IRowB(this.maskRoute),...
        this.basicVar.IColB(this.maskRoute));
    this.IFracB=this.basicVar.IFracB(this.maskRoute);
    this.IFracB=this.IFracB(this.IIndexBValid);
    this.IgridAreaB=this.gridArea(this.IIndexBValid);

    % runoff variables
    this.RSPassedIndex=sub2ind(size(this.stateVar.basinMask),...
        this.basicVar.RSPassedRow,this.basicVar.RSPassedCol);
    this.uRSPassedIndex=unique(this.RSPassedIndex);
    this.RSStartedIndex=sub2ind(size(this.stateVar.basinMask),...
        this.basicVar.RSStartedRow,this.basicVar.RSStartedCol);
    this.RIPassedIndex=sub2ind(size(this.stateVar.basinMask),...
        this.basicVar.RIPassedRow,this.basicVar.RIPassedCol);
    this.uRIPassedIndex=unique(this.RIPassedIndex);
    this.RIStartedIndex=sub2ind(size(this.stateVar.basinMask),...
        this.basicVar.RIStartedRow,this.basicVar.RIStartedCol);
end
end