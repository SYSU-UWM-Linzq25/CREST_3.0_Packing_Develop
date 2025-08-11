function [nspl,npg,nps,bl,bu,cf,cx,keywords]=readevpar(this)
%after checking parameter file  read
fid=fopen(this.fileevPar);
%% read paramters of simplex and complex
A=textscan(fid,'%f %f %f\n',1,'Delimiter',',');
xTemp=cell2mat(A);
nspl=xTemp(1);
npg=xTemp(2);
nps=xTemp(3);
%% read calibration keywords
A=fgetl(fid);
keywords=strsplit(A,',');
keywords=strtrim(keywords);
parnum=length(keywords);
%% parameter values
A=textscan(fid,repmat('%f',[1, parnum]),2,'Delimiter',',');
xTemp=cell2mat(A);
bl=xTemp(1,:);
bu=xTemp(2,:);

A=textscan(fid,repmat('%f',[1,nspl]),1,'Delimiter',',');
cf=cell2mat(A);
A=textscan(fid,repmat('%f',[1,parnum]),nspl,'Delimiter',',');
cx=cell2mat(A);

disp(['Core #',num2str(this.coreID),' gained ', num2str(nspl),  ' row cx parameter file']);
fclose(fid);
end