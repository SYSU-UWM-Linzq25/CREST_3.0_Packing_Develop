function [pvalue, direction]=TDF(data, obs_per_day, days_per_year, season, resolution, beginning_date, end_date)
% TDF.m by Agne Burauskaite-Harju, 2008-06-05
%
%   data          - a time series of observations
%   obs_per_day   - how many observations per day
%   days_per_year - how many days per year. Regular 365.25.
%                   If data is regular with leap years beginning_date and
%                   end_date should be suplied.
%   
%   Optional inputs:
%                   For simulated data without leap year date inputs are
%                   not necesary, but data should start on the first day of
%                   the year and end on the last day of a year.
%   beginning_date - a vector [yyyy, mm, dd]. Alternative yyyy if
%                   observations start from the beginning of the year. 
%   end_date      - a vector [yyyy, mm, dd]. Alternative yyyy if
%                   observations end by the end of the year.
%   season        - 'winter' - DJF, 'spring' - MAM, 'summer' - JJA,
%                   'late summer' - JAS, 'autumn' - SON, 'all year'.
%                   Default - 'all year'
%   resolution    - a vector of multipliers. Default - 1.
%
%   For example, if obs_per_day=24 resolution=[1 3 12]results will be
%   calculated for hourly observations, for a sum of 3 hour observations and
%   for a sum of 12 hour observations. Note that the lowest resolution that
%   procedure can handle is one observation per 3 days.

pvalue=[];
direction=[];

if nargin<3
    error('Not enough input variables');
end

if nargin<7
    if days_per_year==365.25
        disp('If data is regular with leap years beginning_date and end_date should be suplied');
        return;
    else
        if nargin<6
            beginning_date=1;    
            if nargin<5
                resolution=1;
                if nargin<4
                    season='all year';
                end
            end
        end
        end_date=beginning_date + floor(length(data)/obs_per_day/days_per_year)-1;
    end
end

if days_per_year==365.25
    if (length(beginning_date)<3)
        beginning_date=[beginning_date, 1, 1];
    end
    if (length(end_date)<3)
        end_date=[end_date, 12, 31];
    end
end

[correct, beginning_date_num, end_date_num]=input_correct(data, obs_per_day, days_per_year, beginning_date, end_date, season, resolution);
if correct
    probability=[0.5 0.6 0.7 0.8 0.9 0.95 0.98 0.99 0.995 0.999 0.9995 0.9999];
    for i=1:length(resolution)
        data1=data;
        for k=1:(resolution(i)-1)
            data1=data1(2:end)+data(1:(end-k));
        end
        data2=data1(1:(resolution(i)):end);
        days_per_season=days_per_year/4;
        data_per_day=obs_per_day/resolution(i);
        if strcmpi(season,'winter')
            if days_per_year==365.25
                date_diff_1=datenum(beginning_date(1),12,1)-beginning_date_num;
                if date_diff_1 >= 0
                    selected_data=data2((1+date_diff_1*data_per_day):end);
                else
                    date_diff_2=datenum(beginning_date(1)+1,12,1)-beginning_date_num;
                    selected_data=data2((1+date_diff_2*data_per_day):end);
                end
            else
                selected_data=data2((1+floor(11*days_per_year/12*data_per_day)):end);
            end;
            
        elseif strcmpi(season,'spring')
            if days_per_year==365.25
                date_diff_1=datenum(beginning_date(1),3,1)-beginning_date_num;
                if date_diff_1 >= 0
                    selected_data=data2((1+date_diff_1*data_per_day):end);
                else
                    date_diff_2=datenum(beginning_date(1)+1,3,1)-beginning_date_num;
                    selected_data=data2((1+date_diff_2*data_per_day):end);
                end
            else
                selected_data=data2((1+floor(2*days_per_year/12*data_per_day)):end);
            end;
                
        elseif strcmpi(season,'summer')
            if days_per_year==365.25
                date_diff_1=datenum(beginning_date(1),6,1)-beginning_date_num;
                if date_diff_1 >= 0
                    selected_data=data2((1+date_diff_1*data_per_day):end);
                else
                    date_diff_2=datenum(beginning_date(1)+1,6,1)-beginning_date_num;
                    selected_data=data2((1+date_diff_2*data_per_day):end);
                end
            else
                selected_data=data2((1+floor(5*days_per_year/12*data_per_day)):end);
            end;
            
        elseif strcmpi(season,'autumn')
            if days_per_year==365.25
                date_diff_1=datenum(beginning_date(1),9,1)-beginning_date_num;
                if date_diff_1 >= 0
                    selected_data=data2((1+date_diff_1*data_per_day):end);
                else
                    date_diff_2=datenum(beginning_date(1)+1,9,1)-beginning_date_num;
                    selected_data=data2((1+date_diff_2*data_per_day):end);
                end
            else
                selected_data=data2((1+floor(8*days_per_year/12*data_per_day)):end);
            end;
            
        elseif strcmpi(season,'late summer')
            if days_per_year==365.25
                date_diff_1=datenum(beginning_date(1),7,1)-beginning_date_num;
                if date_diff_1 >= 0
                    selected_data=data2((1+date_diff_1*data_per_day):end);
                else
                    date_diff_2=datenum(beginning_date(1)+1,7,1)-beginning_date_num;
                    selected_data=data2((1+date_diff_2*data_per_day):end);
                end
            else
                selected_data=data2((1+floor(6*days_per_year/12*data_per_day)):end);
            end;
            
        else
            days_per_season=days_per_year;
            selected_data=data2;
        end
        
        zzz=sum(data2==0)/length(data2);
        [GPD_param1, GPD_param2, GPD_quantiles, quantiles, sums]=GPD_estimation(selected_data, days_per_year, days_per_season, probability ,data_per_day);
        for j=1:length(probability)
            if probability(j)<zzz;
                pvalue(i,j)=0.5;
            else
                %[GPD_param1, GPD_param2, GPD_quantiles, quantiles, sums]=climatedateRRLM2(selected_data, days_per_year, days_per_season, probability(j),data_per_day);
                if probability(j)<=0.9
                    [value(i,j),pvalue(i,j)]=mannkendall(quantiles(j,:),1,length(quantiles(j,:)));
                else
                    [value(i,j),pvalue(i,j)]=mannkendall(GPD_quantiles(j,:),1,length(GPD_quantiles(j,:)));
                end
            end
        end
        [value(i,length(probability)+1),pvalue(i,length(probability)+1)]=mannkendall(sums,1,length(sums));
        i
    end
    direction=sign(value);
    disp('   p-values of Mann-Kendall monotonic trend test');
    disp([[0 24*resolution./obs_per_day]; [[probability 0]; pvalue]']);
    disp('   Trend direction: -1 decreasing trend, 1 increasing trend');
    disp([[0 24*resolution./obs_per_day]; [[probability 0]; direction]']);
end