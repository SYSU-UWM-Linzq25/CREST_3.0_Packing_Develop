function [eh,ev,Rhh,Rvv,s,Lc]=ReadEmissivity(file,sheet)
data=xlsread(strcat(file,'.xlsx'),sheet);
eh=data(:,1);
ev=data(:,2);
Rhh=data(:,3);
Rvv=data(:,4);
s=data(:,7);
Lc=data(:,8);
end