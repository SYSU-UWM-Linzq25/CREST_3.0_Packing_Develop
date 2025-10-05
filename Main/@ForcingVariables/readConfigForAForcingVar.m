%% update history
% 2) Jul. 5, 2019, to add forecast capability by Shen, X.
function [dateFormat,dateConvention,dateForcInter,...
    pathExt,bandExt,pathInt,fmtExt,tsScaling,tsTrans,uLim,dLim]=readConfigForAForcingVar(gfileID,commentSymbol,splitor,...
    kwDateFormat,kwDateConvention,...
    kwDateInterval,kwPathExt,kwBandExt,kwPathInt,kwFmtExt,...
    kwLT,kwULim,kwDLim,dateStart)
dateFormat=ForcingVariables.ReadAKeyword(gfileID,kwDateFormat,commentSymbol);
dateConvention=ForcingVariables.ReadAKeyword(gfileID,kwDateConvention,commentSymbol);
% strDateStart=ForcingVariables.ReadAKeyword(gfileID,kwDateStart,commentSymbol);
strDateInterval=ForcingVariables.ReadAKeyword(gfileID,kwDateInterval,commentSymbol);
bandExt=str2double(ForcingVariables.ReadAKeyword(gfileID,kwBandExt,commentSymbol));
pathExt=ForcingVariables.ReadAKeyword(gfileID,kwPathExt,commentSymbol);
txtLT=ForcingVariables.ReadAKeyword(gfileID,kwLT,commentSymbol);
LTCoe=strsplit(txtLT,',');
tsScaling=str2double(LTCoe(1));
if length(LTCoe)>1
    tsTrans=str2double(LTCoe(2));
else
    tsTrans=0;
end
% tsScaling=str2double(ForcingVariables.ReadAKeyword(gfileID,kwTsScaling,commentSymbol));
uLim=str2double(ForcingVariables.ReadAKeyword(gfileID,kwULim,commentSymbol));
dLim=str2double(ForcingVariables.ReadAKeyword(gfileID,kwDLim,commentSymbol));
pathInt=ForcingVariables.ReadAKeyword(gfileID,kwPathInt,commentSymbol);
%% start 2)
if ~isnan(dateStart)
    pathInt=ForcingVariables.tagPathDT(pathInt,dateStart);
end
%% end 2)
dateForcInter=GlobalParameters.CalTimeInterval(strDateInterval,dateFormat,splitor);
% [dateForcStart,dateForcInter]=ForcingVariables.ForcingTimePar(strDateStart,strDateInterval,dateFormat);
fmtExt=ForcingVariables.ReadAKeyword(gfileID,kwFmtExt,commentSymbol);
% forc0=ForcingVariables.InitializeStartForcTime(dateForcStart,dateForcInter,dateConvention);
end