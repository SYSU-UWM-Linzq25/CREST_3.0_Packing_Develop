function reset(this,nLayers,taskType)
%% initializing some output variables
% simulator calls this function after preset
% soil moisture is assigend in the reset function of the soilSurf media
% this.W0(this.basinMask)=this.pW0(this.basinMask).*WM(this.basinMask)/100;
% state variables calculated from simulation
this.excS=this.Initialize();
this.excI=this.Initialize();
this.RS=this.Initialize();
this.RI=this.Initialize();
this.runoff=this.Initialize();
this.SWE=this.Initialize();
if ~strcmpi(taskType,'Routing')
    this.rain=this.Initialize();
    this.snow=this.Initialize();
    this.iceSurf=this.Initialize();
    this.icePack=this.Initialize();
    this.EAct=this.Initialize();
    this.intRain=this.Initialize();
    this.intSnow=this.Initialize();
   
%     this.WSurf=this.Initialize();
%     this.WPack=this.Initialize();
%     this.CCPack=this.Initialize();
%     this.CCSurf=this.Initialize();
    this.W0=this.Initialize(nLayers);
    this.hydroSites.reset();
    this.SM=this.Initialize();
end
end