function calVP(this)
%% update history
% 1) allow Relative Humidity as input
%% compute vapor pressure based on various input
global EPS
% 1) begin
es=saturatedVaporPressure(this.Tair);
if strcmpi(this.forcingVar.typeHumid,'SH')
    r=this.forcingVar.humidity(this.forcingVar.basinMask)./(1-this.forcingVar.humidity(this.forcingVar.basinMask));
    this.eAct=r.* this.pressure./(r+EPS);
elseif strcmpi(this.forcingVar.typeHumid,'RH')
    this.eAct=this.forcingVar.humidity(this.forcingVar.basinMask)/100.*es;
else
    error('Humidity type must be either SH or RH');
end
% 1) end
this.VPD=es-this.eAct;
overHumid=this.VPD<0;
this.VPD(overHumid)=0;% VPD is non-negative
this.eAct(overHumid)=es(overHumid);
this.airDens = 0.003486*this.pressure./(275.0 + this.Tair);
end