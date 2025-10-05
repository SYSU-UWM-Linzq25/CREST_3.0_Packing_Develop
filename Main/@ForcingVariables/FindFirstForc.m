function date0=FindFirstForc(dateStart0,dateStart,timeStep,intervalForc,fmtForc,convForc,dirForc,extForc,pathSplitor)
%% update history
% 1) add forecast capability
date0=dateStart;
%% begin 1)
% [~,hit]=model2forcDate(date0,intervalForc,convForc,fmtForc,pathSplitor);
% forcNameExt=ForcingVariables.GenerateExtForcingFileName(date0,intervalForc,fmtForc,convForc,dirForc,extForc,pathSplitor);

if ~isnan(dateStart0)
    [~,hit]=model2forcDate(date0,intervalForc,convForc,fmtForc,pathSplitor,dateStart0);
    forcNameExt=ForcingVariables.GenerateExtForcingFileName(date0,intervalForc,fmtForc,convForc,dirForc,extForc,pathSplitor,dateStart0);
else
    [~,hit]=model2forcDate(date0,intervalForc,convForc,fmtForc,pathSplitor,[]);
    forcNameExt=ForcingVariables.GenerateExtForcingFileName(date0,intervalForc,fmtForc,convForc,dirForc,extForc,pathSplitor);
end
%% end 1)
if ~(hit && ForcingVariables.fileExist(forcNameExt))
    %Note that when forecast is used, the first date time must accurately match the available forcing. Therefore, no need of searching back and forth
    offset=1;
    while true
        date0=ForcingVariables.addDatenum(dateStart,offset*timeStep/2);
        [~,hit]=model2forcDate(date0,intervalForc,convForc,fmtForc,pathSplitor,[]);
        forcNameExt=ForcingVariables.GenerateExtForcingFileName(date0,intervalForc,fmtForc,convForc,dirForc,extForc,pathSplitor);
        if hit && ForcingVariables.fileExist(forcNameExt)
            break;
        end
        date0=ForcingVariables.addDatenum(dateStart,-offset*timeStep/2);
        [~,hit]=model2forcDate(date0,intervalForc,convForc,fmtForc,pathSplitor,[]);
        forcNameExt=ForcingVariables.GenerateExtForcingFileName(date0,intervalForc,fmtForc,convForc,dirForc,extForc,pathSplitor);
        if hit && ForcingVariables.fileExist(forcNameExt)
            break;
        end
        offset=offset+1;
    end
end
end
function [dateForc,equal]=model2forcDate(dateModel,intervalForc,convForc,fmtForc,pathSplitor,dateStart0)
%% this function converts models time to a string in the format & convention of the forcing
% then converts the string back to the date number. If the converted date
% number remains unchanged, it indicates that the given model time step
% hits the forcing one
% If the run style is forecast, the start forcing file must be found in the
% first search, indicating the start time the provided date and time
dateForc0=ForcingVariables.offsetDate(dateModel,intervalForc,convForc);
if ~isnan(dateStart0)
    dateForcStr=ForcingVariables.datenum2str(dateForc0,fmtForc,pathSplitor,dateStart0);
else
    dateForcStr=ForcingVariables.datenum2str(dateForc0,fmtForc,pathSplitor);
end
dateForc=ForcingVariables.str2datenum(dateForcStr,fmtForc);
equal=dateForc==dateForc0;
end