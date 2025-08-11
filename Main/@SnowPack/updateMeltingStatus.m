function updateMeltingStatus(this,date,lat,new_snow)
%% Record if snowpack is melting at this time step
global TraceSnow
[y,m,d]=datevec(date);
doy=datenum(y,m,d)-datenum(y,1,1);
isCold=this.CCSurf>=0;
this.melting(this.swqTotal==0)=false;
if (doy>60 && doy<273) % between March 1 and Oct 1
    bMelting=(lat>0)&isCold;
else
    bMelting=(lat<0)&isCold;
end
this.melting(bMelting)=true;
this.melting((~bMelting)& (new_snow>TraceSnow) & this.melting)=false;
end