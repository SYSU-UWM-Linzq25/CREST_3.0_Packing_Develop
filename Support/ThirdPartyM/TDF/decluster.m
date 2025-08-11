function out=decluster(series,gap,graphopt)
%Declusters clustered point process data so that Poisson assumption is 
%more tenable over a high threshold.
%
%  USAGE: out=decluster(series,gap,graphopt)
%
% series: Data vector (elements are assigned time indices [0,1] corresponding to their
%         sequences).
%    gap: Any consecutive exceedances separated by more than this amount is considered
%         to belong different clusters.
%grapopt: Should be 1 if plots required.
%
%    out: declustered series.

times=series(:,1);
gaps=diff(times);
longgaps=(gaps>gap);
if sum(longgaps)<=1,
    disp('Decluster parameter too large');
    return
end
cluster=[0;cumsum(longgaps)];

for i=0:cluster(end),
ser=[series(:,1) repmat(NaN,length(series),1)];
ser(cluster==i,2)=series(cluster==i,2);
[y,ind]=max(ser(:,2));
inds(i+1)=ind;
out(i+1,:)=series(ind,:);
end
if graphopt==1,
subplot(221)
plot(times,series(:,2),'.')
xlabel('Scaled Time Index');
subplot(222)
qplot(gaps,0);
subplot(223)
plot(times(inds),out(:,2),'.')
xlabel('Scaled Time Index')
subplot(224)
inds2=times(inds);
qplot(diff(inds2),0);
end

function c=mymax(v),
c=find(v==max(v));