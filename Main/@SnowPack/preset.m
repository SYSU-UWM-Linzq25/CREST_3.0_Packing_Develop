function preset(this)
%% reset all state variables before a simulation 
% the simlulate function is responsible to call this function every time
this.W(:)=0;
this.CCPack(:)=0;
this.CCSurf(:)=0;
this.swqTotal(:)=0;
this.WPack(:)=0;
this.TPack(:)=0;
this.melting(:)=false;
this.last_snow(:)=false;
this.hasSnow(:)=false;
end