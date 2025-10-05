function [remCC,remliquid,ice]=refreeze(CC,liquid)
global RHO_W Lf m2mm SMALL
ice=min(liquid,-CC/(Lf*RHO_W)*m2mm);
remCC=CC+ice/m2mm*(Lf*RHO_W);
remliquid=liquid-ice;
remliquid(abs(remliquid)<SMALL)=0;
ice(abs(ice)<SMALL)=0;
end