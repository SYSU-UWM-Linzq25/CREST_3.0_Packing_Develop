function NSCE_Dist()
directory='G:\simulation\US_Basins\Connecticut_River\resultFull\ET_Val\*.csv';
path='G:\simulation\US_Basins\Connecticut_River\resultFull\ET_Val\';
listing = dir(directory);
files={listing.name};
allNSCE=[];
allBias=[];
for i=1:length(files)
    M = csvread([path,files{i}],1,0);
    NSCE_res=M(end-1,:);
    Bias_res=M(end,:);
    if NSCE_res(1)~=0 || NSCE_res(2)~=0
        continue;
    end
    NSCE=NSCE_res(3:2:end);
    Bias=Bias_res(3:2:end);
    nonValid=isnan(NSCE)|isinf(NSCE);
    NSCE(nonValid)=[];
    Bias(nonValid)=[];
    allNSCE=[allNSCE,NSCE];
    allBias=[allBias,Bias];
end
[counts,bins]=hist(allNSCE,-1:0.1:1);
bar(bins,counts/length(allNSCE)*100);
xlabel('NSCE');
ylabel('%')
title(['mean NSCE=',num2str(mean(allNSCE))])
figure
[counts,bins]=hist(allBias,-100:10:100);
bar(bins,counts/length(allBias)*100);
xlabel('Bias');
ylabel('%')
title(['mean Bias=' num2str(mean(allBias)) ,'%']);
end