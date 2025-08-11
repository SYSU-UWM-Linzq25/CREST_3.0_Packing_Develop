function LogToFile(this,fTemp,tElapse,xTemp)
fid=fopen(this.logFile,'a+');
fprintf(fid,this.fmt,fTemp,tElapse);
fprintf(fid,' %8.6f ',xTemp);
fprintf(fid,'\n');
fclose(fid);
end
