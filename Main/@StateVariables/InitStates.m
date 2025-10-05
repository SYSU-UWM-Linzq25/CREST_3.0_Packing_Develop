function InitStates(this,nLayers)
this.excS=this.Initialize(); % excessive water overland
this.excI=this.Initialize(); % excessive water underground
this.EAct=this.Initialize(); % Actual ET
this.rain=this.Initialize();% rain fall
this.snow=this.Initialize();
this.rainBare=this.Initialize();%/add
this.actTranspir=this.Initialize();%/add
this.EPot=this.Initialize();%/add
%/ modified
this.intRain=this.Initialize();
this.intSnow=this.Initialize();
this.SWE=this.Initialize();% snow water equivalence of the snow pack
this.W0=this.Initialize(nLayers);
end