function LoadModelStates(this,strDateLoad)
%% note that in CREST v3.0, this function only applies to routing
% soil moisture is not reloaded for routing purpose in this version
S=load(strDateLoad);
this.SS0=S.iSS0;
this.SI0=S.iSI0;
% this.pW0=S.ipW0;
clear S
disp('Routing status loaded.')
end