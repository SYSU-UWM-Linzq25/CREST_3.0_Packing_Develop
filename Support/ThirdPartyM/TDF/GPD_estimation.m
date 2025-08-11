function [GPD_param1, GPD_param2, GPD_quantiles, quantiles, sums]=GPD_estimation(data, days_per_year, days_per_season, probability, data_per_day)
%Fits GPD distribution
%for a period of years: starty-endy

%GPD_param1 - parameter ksi
%GPD_param2 - parameter Sigma
%GPD_quantiles - GPD-quantile
%quantiles - ordinary quantiles

% x=1:1:100;
% x=[ones(1,100); x]';
GPD_param1=0;
GPD_param2=0;
GPD_quantiles=0;
quantiles=0;
lll=0;
years=length(data)/days_per_year/data_per_day;
if (days_per_season==days_per_year)|((years-floor(years))<0.25)
    n=floor(years);
else
    n=ceil(years);
end
for j=1:n
    WorkData=data(floor((j-1)*days_per_year*data_per_day+1):floor(((j-1)*days_per_year+days_per_season)*data_per_day));
    sums(j)=sum(WorkData);
    thresh(j)=findthresh(WorkData,'%20');
    ser1=clusters(WorkData,thresh(j));
    if length(ser1)<20
         ser=ser1;
    else
         try
             ser=decluster(ser1,1,0);
         catch
             ser=ser1;
         end
    end
    lll(j)=length(ser);
    nnn=0.2;
    L=lmom(ser(:,2),2);
    GPD_param1(j)=2-(L(1)-thresh(j))/L(2);
    GPD_param2(j)=(1-GPD_param1(j))*(L(1)-thresh(j));
    for i=1:length(probability)
        if probability(i)>0.9
            GPD_quantiles(i,j)=qgpd(1-(1-probability(i))/nnn,GPD_param1(j),thresh(j),GPD_param2(j));
        else
            %quantiles(i,j)=quantile(WorkData, probability(i));  
            quantiles(i,j)=prctile(WorkData, 100*probability(i));  ;  
        end
    end
end