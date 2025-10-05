function [sh,eh,shAP,ehAP]=ReadFloodEvents(FEDB,STCD)% added in Jan, 2016
%% this function read flood events of the given site from a flood event database
%% output
% sh(i): the start time (in datenumber) of all events
% eh(i): the ending time (in datenumber) of all events
%% input
% FEDB; database of flood events
% STCD: code of the given site
S=shaperead(FEDB,'Selector',{@(v) (strcmp(v,STCD)==1),'STCD'});
sh=datenum({S.StartTimeF});
eh=datenum({S.EndTimeF});
perc=[S.Perc];
[year,~,~]=datevec(eh);
ap=accumarray(year,perc+1i*(1:length(sh)),[],@maxInd,[],true);
[~,~,ap]=find(ap);
index=imag(ap);
shAP=sh(index);
ehAP=eh(index);
end