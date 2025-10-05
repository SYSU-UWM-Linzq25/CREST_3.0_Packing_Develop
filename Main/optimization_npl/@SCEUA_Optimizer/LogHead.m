function LogHead(obj)
    fid=fopen(obj.logFile,'w');
    fprintf(fid,'NSCE  Elapsed_Time');
    for i=1:length(obj.keywordsAct);
        fprintf(fid,'  %s  ',obj.keywordsAct{i});
    end
    fprintf(fid,'\n');
    fclose(fid);
end