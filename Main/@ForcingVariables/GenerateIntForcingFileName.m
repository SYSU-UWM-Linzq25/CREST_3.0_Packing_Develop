function [forcNameInt,subName]=GenerateIntForcingFileName(dirIntForc,fmtSub,fmtInt,date)
OS=computer;
if strcmpi(OS,'PCWIN64')
    pathSplitor='\';
elseif strcmpi(OS,'GLNXA64')
    pathSplitor='/';
end
subName=['s',datestr(date,fmtSub)];
strFileInt = datestr(date,fmtInt);
forcNameInt=[dirIntForc,strFileInt,'.mat'];
end