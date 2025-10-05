function pathIntTagged=tagPathDT(pathInt,dateStart)
%% this function replace the placeholer 'DTS' with the actual start date time in the format
% yyyymmddHHMM
DTSInd=strfind(pathInt,'DTS');
strDTS=datestr(dateStart,'yyyymmddHHMM');
pathIntTagged=[pathInt(1:DTSInd-1),strDTS,pathInt(DTSInd+3:end)];
end