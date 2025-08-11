function [dateForcStart,dateForcInter]=ForcingTimePar(strForcStart,strForcInter,fmt)
% if strfind(fmt,'yyyy')
%     yearInd=find(fmt,'yyyy');
%     yearInd=yearInd(1);
%     year=str2double(strForcStart(yearInd:yearInd+3));
% end
% if strfind(fmt,'DOY')
%     doyInd=find(fmt,'DOY');
%     
% end
% if strfind(fmt,'yyyy\DOY')
%     content=strsplit(strForcStart,'\');
%     yearStart=str2double(content{1});
%     doyStart=str2double(content{2});
%     dateForcStart=datenum(yearStart,1,1);
%     dateForcStart=dateForcStart+doyStart-1;
% else
%     dateForcStart=datenum(strForcStart,fmt);
% end
dateForcStart=ForcingVariables.str2datenum(strForcStart,fmt);
dateForcInter=GlobalParameters.CalTimeInterval(strForcInter,fmt);
end