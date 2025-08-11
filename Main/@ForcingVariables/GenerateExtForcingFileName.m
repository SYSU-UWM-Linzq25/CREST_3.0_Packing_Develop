function forcNameExt=GenerateExtForcingFileName(date,timeStep,fmtForc,convForc,dirForc,extForc,pathSplitor,dateStart)
%% updating history
% updated to have the forecast mode (2) on Jul. 5, 2019 
% dateStart is one time step before the starting date time of the forecasting
%% offset the date number by external convention
date=ForcingVariables.offsetDate(date,timeStep,convForc);
%% convert the offset date nubmer to string
% copy the format to the filename
%% (2)
% forcNameExt=ForcingVariables.datenum2str(date,fmtForc,pathSplitor);
if exist('dateStart','var') && (~isnan(dateStart))
    dateStart=ForcingVariables.offsetDate(dateStart,timeStep,convForc);
    forcNameExt=ForcingVariables.datenum2str(date,fmtForc,pathSplitor,dateStart);
else
    forcNameExt=ForcingVariables.datenum2str(date,fmtForc,pathSplitor);
end
%% 
forcNameExt=[dirForc,forcNameExt,extForc];
end