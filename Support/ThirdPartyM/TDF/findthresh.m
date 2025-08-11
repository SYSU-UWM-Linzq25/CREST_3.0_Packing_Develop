function out=findthresh(data,ne),
%Finds a threshold so that a given number of extremes lie above 
%
%USAGE: out=findthresh(data,ne)
%
% data: Data vector
%   ne: Number of extremes to lie above.
%       It can be supplied as an integer or as a percentage. If as a percentage it should
%       be entered between quotes i.e. '%5' (5% of the data lie above the threshold found). 
%
%  out: threshold calculated
data=surecol(data);
if isstr(ne)==1,
	len=length(data);
	perc=str2num(ne(2:end))/100;
	ne=floor(perc*len);
end
data=flipud(sort(data));
thresholds=flipud(unique(data));
lne=length(ne);
for i=1:lne,
index=data(ne(i))==thresholds;
index=find(index);
ind(i)=min(index+1,length(thresholds));
end
out=thresholds(ind);












