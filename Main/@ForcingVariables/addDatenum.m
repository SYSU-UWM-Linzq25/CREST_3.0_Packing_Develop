function dn=addDatenum(dn1,dn2)
%% this function serves for adds two date numbers precisely
global SECONDS_PER_DAY
dn=(round(dn1*SECONDS_PER_DAY)+round(dn2*SECONDS_PER_DAY))/SECONDS_PER_DAY;
end