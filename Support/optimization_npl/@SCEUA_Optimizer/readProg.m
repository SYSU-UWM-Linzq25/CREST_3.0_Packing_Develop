function [evNum,x,f,criter]=readProg(this,nPar)
%% write a status file to indicate the progress
% this function is called when the calibration was aborted and then resumed
%% output
% evNum: currently finished number of evolution. 0 Indicates the initial
    % population has been simulated
% x: simulated parameter-sets
% f: simulated function value
% criter: the best function value records for evolution from 1-evNum
%% input
% nPar the number of paramters to be calibrated
fileName=this.getProgressFileName();
fid=fopen(fileName,'r');
C=textscan(fid,'Evolution: %d\n',1);
evNum=cell2mat(C);
if evNum>0
    fmt='BestF: ';
    fmt=[fmt,repmat('%f, ',[1,evNum-1]),'%f\n'];
    C=textscan(fid,fmt,1);
    criter=cell2mat(C);
else
    criter=[];
end

fmt=[repmat('%f ',[1, nPar+1]),'\n'];
C=textscan(fid,fmt,'Delimiter',',');
data=cell2mat(C);
f=data(:,1);
x=data(:,2:end);
fclose(fid);
end
