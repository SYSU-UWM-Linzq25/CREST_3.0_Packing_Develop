function [timeMark,timeFormat,timeStepInM,timeStep,nTimeSteps,startDate,warmupDate,endDate]=...
    ReadTimeLine(gfileID,commentSymbol,keyMark,keyTF,keyTS,keySD,keyWD,keyED)
timeMark=GlobalParameters.readLine(gfileID,keyMark,commentSymbol,'string');
timeFormat=GlobalParameters.readLine(gfileID,keyTF,commentSymbol,'string');
timeStepInM=GlobalParameters.readLine(gfileID,keyTS,commentSymbol,'double');
strStartDate=GlobalParameters.readLine(gfileID,keySD,commentSymbol,'string');
startDate= datenum(strStartDate,timeFormat);
strWarmupDateLS=GlobalParameters.readLine(gfileID,keyWD,commentSymbol,'string');
strEndDateLS=GlobalParameters.readLine(gfileID,keyED,commentSymbol,'string');
warmupDate=datenum(strWarmupDateLS,timeFormat);
endDate=datenum(strEndDateLS,timeFormat);
switch timeMark
   case 'd'          
       timeStep=datenum(0,0,timeStepInM);
   case 'h'
       timeStep=datenum(0,0,0,timeStepInM,0,0);
end
% if obj.numOfLoaded>0
%    obj.nTimeSteps=round(sum(obj.endDate-obj.warmupDate)/obj.timeStep);
% else
   nTimeSteps=round((endDate-startDate)/timeStep)+1;
% end
end