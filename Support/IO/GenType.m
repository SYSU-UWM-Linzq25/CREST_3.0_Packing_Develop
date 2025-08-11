function [file,sheet]=GenType(dir,type,band,freq,corlType,inc)
file=strcat(dir,'\',type,'_',band,'_',corlType);
if isnumeric(freq)
    freq=num2str(freq);
end
sheet=strcat('freq=',freq,',inc=',num2str(inc));
end